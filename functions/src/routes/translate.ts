import { Router, Response } from "express";
import fetch from "node-fetch";
import { AuthedRequest } from "../middleware/auth";
import { acquireApiKey } from "../services/keyPool";

export const translateRouter = Router();

const GROK_ENDPOINT = "https://api.x.ai/v1/chat/completions";

translateRouter.post("/", async (req: AuthedRequest, res: Response) => {
  const { text, targetLanguage } = req.body || {};
  if (!text || !targetLanguage) {
    return res.status(400).json({ error: "missing_text_or_target" });
  }

  try {
    const { keyId, key } = await acquireApiKey("grok");

    const upstream = await fetch(GROK_ENDPOINT, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${key}`,
      },
      body: JSON.stringify({
        model: "grok-4",
        messages: [
          {
            role: "system",
            content: `Translate the user's text into ${targetLanguage}. Include a romanized transliteration on a second line. Return nothing else.`,
          },
          { role: "user", content: text },
        ],
      }),
    });

    if (!upstream.ok) {
      console.error("grok_upstream_error", keyId, upstream.status);
      return res.status(502).json({ error: "translation_unavailable" });
    }

    const data: any = await upstream.json();
    const translated = data?.choices?.[0]?.message?.content ?? "";

    return res.status(200).json({ translated });
  } catch (err: any) {
    console.error("translate_handler_error", err);
    return res.status(500).json({ error: "internal_error" });
  }
});
