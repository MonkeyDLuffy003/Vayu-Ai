import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Fires automatically when a new Firebase Auth user is created.
 * Initializes their Firestore profile so downstream code (rate limiter,
 * conversations) never has to handle a "doc doesn't exist" edge case.
 */
export const onUserCreate = functions
  .region("asia-south1")
  .auth.user()
  .onCreate(async (user) => {
    const db = admin.firestore();
    await db.collection("users").doc(user.uid).set({
      email: user.email || null,
      displayName: user.displayName || null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      tier: "free",
      preferredLanguage: "en",
      dailyMessageCount: 0,
      lastResetDate: new Date().toISOString().slice(0, 10),
    });
  });
