import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import express from "express";
import cors from "cors";
import { authMiddleware } from "./middleware/auth";
import { rateLimitMiddleware } from "./middleware/rateLimit";
import { chatRouter } from "./routes/chat";
import { translateRouter } from "./routes/translate";
import { conversationsRouter } from "./routes/conversations";
import { usageRouter } from "./routes/usage";
import { billingRouter } from "./routes/billing";

admin.initializeApp();

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());
app.use(authMiddleware); // verifies Firebase ID token, attaches req.uid
app.use(rateLimitMiddleware); // enforces per-tier daily message limits

app.use("/chat", chatRouter);
app.use("/translate", translateRouter);
app.use("/conversations", conversationsRouter);
app.use("/usage", usageRouter);
app.use("/billing", billingRouter);

// Single HTTPS function — Express handles internal routing.
// Region pinned close to primary user base; add more regions as you scale geographically.
export const api = functions
  .region("asia-south1")
  .runWith({ memory: "256MB", timeoutSeconds: 30, minInstances: 0 })
  .https.onRequest(app);

// Firestore trigger: initialize a user doc the moment they sign up.
export { onUserCreate } from "./services/onUserCreate";

// Stripe webhook — standalone function, bypasses the JSON-parsing Express
// app above because Stripe requires the raw request body for signature checks.
export { stripeWebhook } from "./services/stripeWebhook";
