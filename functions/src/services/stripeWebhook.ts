import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import Stripe from "stripe";

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || "", {
  apiVersion: "2024-04-10",
});
const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET || "";

/**
 * Separate HTTPS function (not behind the Express app / authMiddleware) —
 * Stripe calls this directly and signs the *raw* request body, which the
 * JSON-parsing middleware in the main app would otherwise mangle.
 *
 * This is the single source of truth for tier upgrades/downgrades. The
 * client never sets `tier` directly — Firestore rules deny that write.
 */
export const stripeWebhook = functions
  .region("asia-south1")
  .https.onRequest(async (req, res) => {
    const signature = req.headers["stripe-signature"] as string;
    let event: Stripe.Event;

    try {
      event = stripe.webhooks.constructEvent(
        req.rawBody,
        signature,
        webhookSecret
      );
    } catch (err) {
      console.error("stripe_signature_verification_failed", err);
      res.status(400).send("invalid signature");
      return;
    }

    const db = admin.firestore();

    try {
      switch (event.type) {
        case "checkout.session.completed": {
          const session = event.data.object as Stripe.Checkout.Session;
          const uid = session.metadata?.firebaseUid;
          if (uid) {
            await db
              .collection("users")
              .doc(uid)
              .set(
                {
                  tier: "pro",
                  stripeSubscriptionId: session.subscription,
                },
                { merge: true }
              );
          }
          break;
        }

        case "customer.subscription.deleted":
        case "customer.subscription.updated": {
          const sub = event.data.object as Stripe.Subscription;
          const customer = await stripe.customers.retrieve(
            sub.customer as string
          );
          const uid = (customer as Stripe.Customer).metadata?.firebaseUid;
          if (uid) {
            const isActive = sub.status === "active" || sub.status === "trialing";
            await db
              .collection("users")
              .doc(uid)
              .set({ tier: isActive ? "pro" : "free" }, { merge: true });
          }
          break;
        }

        default:
          break; // ignore other event types
      }

      res.status(200).send("ok");
    } catch (err) {
      console.error("stripe_webhook_handler_failed", event.type, err);
      res.status(500).send("internal_error");
    }
  });
