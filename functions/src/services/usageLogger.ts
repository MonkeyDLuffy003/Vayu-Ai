import * as admin from "firebase-admin";

/**
 * Writes usage as a subcollection doc per user per day rather than
 * incrementing one global counter — avoids Firestore's ~1 write/sec
 * hot-document limit once you have many concurrent users.
 */
export async function logUsage(
  uid: string,
  provider: "gemini" | "grok",
  tokensUsed: number
) {
  const db = admin.firestore();
  const today = new Date().toISOString().slice(0, 10);
  const ref = db
    .collection("users")
    .doc(uid)
    .collection("usage_logs")
    .doc(today);

  await ref.set(
    {
      date: today,
      [`requestCount_${provider}`]: admin.firestore.FieldValue.increment(1),
      [`tokensUsed_${provider}`]: admin.firestore.FieldValue.increment(
        tokensUsed
      ),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true }
  );
}
