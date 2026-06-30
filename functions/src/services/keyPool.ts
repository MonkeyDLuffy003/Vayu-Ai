import * as admin from "firebase-admin";

interface ApiKeyDoc {
  provider: "gemini" | "grok";
  key: string; // stored encrypted at rest via Firestore CMEK; never logged
  usageCount: number;
  dailyLimit: number;
  lastUsedAt: admin.firestore.Timestamp | null;
  status: "active" | "exhausted" | "disabled";
  lastResetDate?: string;
}

/**
 * Picks the least-recently-used active key for a provider and atomically
 * increments its usage counter. This is what lets you scale by simply
 * adding more keys/accounts to the pool — no code changes required.
 *
 * Falls back across keys if one is exhausted/disabled, so a single dead
 * key never takes down the chat feature.
 */
export async function acquireApiKey(
  provider: "gemini" | "grok"
): Promise<{ keyId: string; key: string }> {
  const db = admin.firestore();
  const today = new Date().toISOString().slice(0, 10);
  const pool = db
    .collection("api_key_pool")
    .where("provider", "==", provider)
    .where("status", "==", "active")
    .orderBy("lastUsedAt", "asc")
    .limit(5); // candidate window — avoids hot-spotting one doc under load

  const snap = await pool.get();
  if (snap.empty) {
    throw new Error(`no_active_keys_for_provider:${provider}`);
  }

  // Try candidates in order; transaction enforces the daily limit per key.
  for (const doc of snap.docs) {
    const ref = doc.ref;
    try {
      const acquired = await db.runTransaction(async (tx) => {
        const fresh = await tx.get(ref);
        const data = fresh.data() as ApiKeyDoc;

        let usageCount = data.usageCount || 0;
        if (data.lastResetDate !== today) usageCount = 0;

        if (usageCount >= data.dailyLimit) {
          tx.update(ref, { status: "exhausted" });
          return null;
        }

        tx.update(ref, {
          usageCount: usageCount + 1,
          lastResetDate: today,
          lastUsedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return { keyId: doc.id, key: data.key };
      });

      if (acquired) return acquired;
    } catch (err) {
      console.error(`key acquisition failed for ${doc.id}`, err);
      // try next candidate
    }
  }

  throw new Error(`all_keys_exhausted_for_provider:${provider}`);
}
