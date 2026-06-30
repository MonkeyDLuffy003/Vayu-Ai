import { Response, NextFunction } from "express";
import * as admin from "firebase-admin";
import { AuthedRequest } from "./auth";

const TIER_LIMITS: Record<string, number> = {
  free: 30, // messages per day
  pro: 1000,
};

/**
 * Atomic per-user daily counter using a Firestore transaction.
 * Resets automatically when the stored date != today (UTC).
 * This is what stops a single user from exhausting the shared API key pool.
 */
export async function rateLimitMiddleware(
  req: AuthedRequest,
  res: Response,
  next: NextFunction
) {
  // Only chat/translate calls consume quota — reads (usage, conversations
  // list) and billing actions (checkout session creation) don't.
  if (req.method === "GET" || req.path.startsWith("/billing")) return next();

  const uid = req.uid!;
  const db = admin.firestore();
  const userRef = db.collection("users").doc(uid);
  const today = new Date().toISOString().slice(0, 10);

  try {
    const allowed = await db.runTransaction(async (tx) => {
      const snap = await tx.get(userRef);
      const data = snap.data() || {};
      const tier = data.tier || "free";
      const limit = TIER_LIMITS[tier] ?? TIER_LIMITS.free;

      let count = data.dailyMessageCount || 0;
      const lastReset = data.lastResetDate || "";

      if (lastReset !== today) {
        count = 0;
      }

      if (count >= limit) {
        return false;
      }

      tx.set(
        userRef,
        { dailyMessageCount: count + 1, lastResetDate: today },
        { merge: true }
      );
      return true;
    });

    if (!allowed) {
      return res.status(429).json({
        error: "daily_limit_reached",
        message: "Daily message limit reached. Upgrade to Pro for more.",
      });
    }

    next();
  } catch (err) {
    console.error("rateLimitMiddleware error", err);
    return res.status(500).json({ error: "internal_error" });
  }
}
