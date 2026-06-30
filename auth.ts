import { Request, Response, NextFunction } from "express";
import * as admin from "firebase-admin";

export interface AuthedRequest extends Request {
  uid?: string;
}

/**
 * Verifies the Firebase ID token sent as `Authorization: Bearer <token>`.
 * Never trust a client-supplied uid — always derive it from the verified token.
 */
export async function authMiddleware(
  req: AuthedRequest,
  res: Response,
  next: NextFunction
) {
  const header = req.headers.authorization || "";
  const token = header.startsWith("Bearer ") ? header.slice(7) : null;

  if (!token) {
    return res.status(401).json({ error: "missing_auth_token" });
  }

  try {
    const decoded = await admin.auth().verifyIdToken(token);
    req.uid = decoded.uid;
    next();
  } catch (err) {
    return res.status(401).json({ error: "invalid_auth_token" });
  }
}
