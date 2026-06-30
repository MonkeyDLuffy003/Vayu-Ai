import { Router, Response } from "express";
import * as admin from "firebase-admin";
import { AuthedRequest } from "../middleware/auth";

export const usageRouter = Router();

usageRouter.get("/", async (req: AuthedRequest, res: Response) => {
  const db = admin.firestore();
  const userSnap = await db.collection("users").doc(req.uid!).get();
  const data = userSnap.data() || {};

  const TIER_LIMITS: Record<string, number> = { free: 30, pro: 1000 };
  const tier = data.tier || "free";
  const today = new Date().toISOString().slice(0, 10);
  const used = data.lastResetDate === today ? data.dailyMessageCount || 0 : 0;

  return res.json({
    tier,
    used,
    limit: TIER_LIMITS[tier] ?? TIER_LIMITS.free,
    resetsAt: `${today}T23:59:59Z`,
  });
});
