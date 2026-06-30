import { Router, Response } from "express";
import * as admin from "firebase-admin";
import Stripe from "stripe";
import { AuthedRequest } from "../middleware/auth";

export const billingRouter = Router();

// Use Firebase Secret Manager in prod: `firebase functions:secrets:set STRIPE_SECRET_KEY`
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || "", {
  apiVersion: "2024-04-10",
});

const PRO_PRICE_ID = process.env.STRIPE_PRO_PRICE_ID || ""; // recurring monthly price
const APP_BASE_URL = process.env.APP_BASE_URL || "https://vayu.ai";

billingRouter.post(
  "/create-checkout-session",
  async (req: AuthedRequest, res: Response) => {
    const uid = req.uid!;
    const db = admin.firestore();

    try {
      const userRef = db.collection("users").doc(uid);
      const userSnap = await userRef.get();
      const userData = userSnap.data() || {};

      // Reuse an existing Stripe customer if we've already created one,
      // so repeated checkout attempts don't fragment billing history.
      let customerId = userData.stripeCustomerId as string | undefined;
      if (!customerId) {
        const customer = await stripe.customers.create({
          metadata: { firebaseUid: uid },
          email: userData.email || undefined,
        });
        customerId = customer.id;
        await userRef.set({ stripeCustomerId: customerId }, { merge: true });
      }

      const session = await stripe.checkout.sessions.create({
        mode: "subscription",
        customer: customerId,
        line_items: [{ price: PRO_PRICE_ID, quantity: 1 }],
        success_url: `${APP_BASE_URL}/billing/success?session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: `${APP_BASE_URL}/billing/cancelled`,
        metadata: { firebaseUid: uid },
      });

      return res.status(200).json({ url: session.url });
    } catch (err) {
      console.error("create_checkout_session_failed", err);
      return res.status(500).json({ error: "checkout_failed" });
    }
  }
);
