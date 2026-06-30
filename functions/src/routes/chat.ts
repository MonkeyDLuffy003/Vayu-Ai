import { Router, Response } from "express";
import * as admin from "firebase-admin";
import fetch from "node-fetch";
import { AuthedRequest } from "../middleware/auth";
import { acquireApiKey } from "../services/keyPool";
import { logUsage } from "../services/usageLogger";

export const chatRouter = Router();

const GEMINI_ENDPOINT =
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

chatRouter.post("/", async (req: AuthedRequest, res: Response) => {
  const uid = req.uid!;
  const { conversationId, message, language } = req.body || {};

  if (!message || typeof message !== "string") {
    return res.status(400).json({ error: "missing_message" });
  }

  const db = admin.firestore();

  try {
    // 1. Resolve or create the conversation
    let convoRef = conversationId
      ? db.collection("conversations").doc(conversationId)
      : db.collection("conversations").doc();

    const convoSnap = await convoRef.get();
    if (!convoSnap.exists) {
      await convoRef.set({
        userId: uid,
        title: message.slice(0, 60),
        language: language || "en",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        model: "gemini-2.5-flash",
      });
    } else if (convoSnap.data()?.userId !== uid) {
      return res.status(403).json({ error: "forbidden" });
    }

    // 2. Persist the user's message
    const messagesRef = convoRef.collection("messages");
    await messagesRef.add({
      role: "user",
      content: message,
      language: language || "en",
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 3. Acquire a rotated Gemini key and call the model
    const { keyId, key } = await acquireApiKey("gemini");

    const upstream = await fetch(`${GEMINI_ENDPOINT}?key=${key}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ role: "user", parts: [{ text: message }] }],
        generationConfig: { temperature: 0.7, maxOutputTokens: 1024 },
      }),
    });

    if (!upstream.ok) {
      const errText = await upstream.text();
      console.error("gemini_upstream_error", keyId, upstream.status, errText);
      return res.status(502).json({ error: "model_unavailable" });
    }

    const data: any = await upstream.json();
    const reply =
      data?.candidates?.[0]?.content?.parts?.[0]?.text ??
      "I couldn't generate a response — please try again.";
    const tokensUsed = data?.usageMetadata?.totalTokenCount ?? 0;

    // 4. Persist the assistant's reply
    await messagesRef.add({
      role: "assistant",
      content: reply,
      language: language || "en",
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      tokensUsed,
      model: "gemini-2.5-flash",
    });

    await convoRef.update({
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 5. Fire-and-forget usage logging — never blocks the response
    logUsage(uid, "gemini", tokensUsed).catch((e) =>
      console.error("usage_log_failed", e)
    );

    return res.status(200).json({
      conversationId: convoRef.id,
      reply,
      tokensUsed,
    });
  } catch (err: any) {
    console.error("chat_handler_error", err);
    if (String(err.message).startsWith("all_keys_exhausted")) {
      return res.status(503).json({ error: "capacity_exceeded" });
    }
    return res.status(500).json({ error: "internal_error" });
  }
});
