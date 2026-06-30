import { Router, Response } from "express";
import * as admin from "firebase-admin";
import { AuthedRequest } from "../middleware/auth";

export const conversationsRouter = Router();

// List the current user's conversations, most recent first.
conversationsRouter.get("/", async (req: AuthedRequest, res: Response) => {
  const db = admin.firestore();
  const snap = await db
    .collection("conversations")
    .where("userId", "==", req.uid)
    .orderBy("updatedAt", "desc")
    .limit(50)
    .get();

  return res.json({
    conversations: snap.docs.map((d) => ({ id: d.id, ...d.data() })),
  });
});

// Get messages for one conversation (ownership enforced).
conversationsRouter.get(
  "/:id/messages",
  async (req: AuthedRequest, res: Response) => {
    const db = admin.firestore();
    const convoRef = db.collection("conversations").doc(req.params.id);
    const convoSnap = await convoRef.get();

    if (!convoSnap.exists || convoSnap.data()?.userId !== req.uid) {
      return res.status(404).json({ error: "not_found" });
    }

    const msgsSnap = await convoRef
      .collection("messages")
      .orderBy("timestamp", "asc")
      .limit(200)
      .get();

    return res.json({
      messages: msgsSnap.docs.map((d) => ({ id: d.id, ...d.data() })),
    });
  }
);

conversationsRouter.delete(
  "/:id",
  async (req: AuthedRequest, res: Response) => {
    const db = admin.firestore();
    const convoRef = db.collection("conversations").doc(req.params.id);
    const convoSnap = await convoRef.get();

    if (!convoSnap.exists || convoSnap.data()?.userId !== req.uid) {
      return res.status(404).json({ error: "not_found" });
    }

    await convoRef.delete(); // Note: at scale, move message subcollection
    // deletion to a Cloud Function trigger (onDelete) to avoid orphaned docs.
    return res.status(204).send();
  }
);
