# Vayu AI — MVP Architecture & Setup

Voice-first multi-LLM assistant. Flutter client (Android-first) + Firebase
serverless backend acting as a proxy/router over Gemini 2.5 Flash and Grok.

## 1. System Architecture

```
Flutter App ──HTTPS(ID token)──▶ Cloud Functions (Express on /api)
                                    │
                                    ├─ authMiddleware     (verifies Firebase ID token)
                                    ├─ rateLimitMiddleware (per-tier daily quota, Firestore txn)
                                    ├─ /chat   ──▶ keyPool.acquireApiKey('gemini') ──▶ Gemini 2.5 Flash
                                    ├─ /translate ──▶ keyPool.acquireApiKey('grok') ──▶ Grok
                                    ├─ /conversations (read-only CRUD)
                                    └─ /usage (read-only stats)
                                    │
                                    ▼
                                Firestore (users, conversations, messages,
                                            api_key_pool, usage_logs)
```

**Why this scales to a real user base, not just a demo:**

- **Stateless compute.** Cloud Functions scale horizontally per-request; no server to provision.
- **Key-pool rotation** (`functions/src/services/keyPool.ts`) means adding capacity = adding a row to `api_key_pool`, not redeploying code. Each key has its own daily limit and auto-disables on exhaustion.
- **Rate limiting is server-side and transactional** — a malicious or buggy client can't bypass quota by spamming requests, because the counter increment and the limit check happen in the same Firestore transaction.
- **Usage logging is fire-and-forget** and date-partitioned per user (not one global counter), avoiding Firestore's hot-document write limits as you grow.
- **Firestore security rules deny all direct client writes** to conversations/messages/keys — every mutation goes through the validated Cloud Function path. This closes the most common "client can fake the AI response" exploit in chat apps.

## 2. File Structure

```
vayu-ai/
├── mobile/                      # Flutter client
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/                # theme, constants, utils
│   │   ├── models/               # ChatMessage, etc.
│   │   ├── providers/            # Riverpod: orb state, chat state
│   │   ├── services/             # ApiService (talks to Cloud Functions)
│   │   ├── screens/              # splash, home, settings, history, onboarding
│   │   └── widgets/
│   │       ├── orb/              # HolographicOrb (GLSL shader)
│   │       └── chat/             # ChatList, VoiceInputButton
│   ├── assets/shaders/orb.frag
│   └── pubspec.yaml
├── functions/                   # Firebase Cloud Functions (TypeScript)
│   └── src/
│       ├── index.ts
│       ├── middleware/          # auth.ts, rateLimit.ts
│       ├── routes/              # chat.ts, translate.ts, conversations.ts, usage.ts
│       └── services/            # keyPool.ts, usageLogger.ts, onUserCreate.ts
├── firestore/
│   ├── firestore.rules
│   └── firestore.indexes.json
├── firebase.json
└── .github/workflows/ci.yml
```

## 3. Database Schema (Firestore)

| Collection | Doc shape | Notes |
|---|---|---|
| `users/{uid}` | `email, displayName, tier (free/pro), preferredLanguage, dailyMessageCount, lastResetDate, createdAt, stripeCustomerId, stripeSubscriptionId` | Created by the `onUserCreate` auth trigger. Client read-only; `tier` is set exclusively by `stripeWebhook`. |
| `users/{uid}/usage_logs/{date}` | `requestCount_gemini, tokensUsed_gemini, requestCount_grok, tokensUsed_grok` | One doc per user per day — avoids hot-document contention. |
| `conversations/{id}` | `userId, title, language, model, createdAt, updatedAt` | Client read-only; written only by `/chat`. |
| `conversations/{id}/messages/{id}` | `role, content, language, timestamp, tokensUsed, model` | Subcollection; ordered by `timestamp`. |
| `api_key_pool/{id}` | `provider, key, usageCount, dailyLimit, lastUsedAt, status, lastResetDate` | **Never client-readable.** Admin-managed (console or a future admin tool). |
| `subscription_tiers/{id}` | `name, dailyMessageLimit, price, features[]` | Reference data for future billing integration. |

## 4. API Endpoints

All routes live behind one HTTPS function (`/api`) and require `Authorization: Bearer <Firebase ID token>`.

| Method | Path | Purpose |
|---|---|---|
| POST | `/chat` | Send a message, get an AI reply. Creates conversation if `conversationId` omitted. Enforces daily quota. |
| POST | `/translate` | Translate text + return romanized transliteration via Grok. Doesn't consume chat quota. |
| GET | `/conversations` | List the caller's conversations, most recent first. |
| GET | `/conversations/:id/messages` | Get messages for one conversation (ownership-checked). |
| DELETE | `/conversations/:id` | Delete a conversation. |
| GET | `/usage` | Current tier, daily usage, and limit. |
| POST | `/billing/create-checkout-session` | Creates a Stripe Checkout session for the Pro subscription; returns a hosted URL. Doesn't consume chat quota. |

Separately, `stripeWebhook` is its own standalone Cloud Function (not behind `/api`) because Stripe requires the raw, unparsed request body to verify its signature. It listens for `checkout.session.completed` and `customer.subscription.updated/deleted`, and is the **only** path that ever sets `users/{uid}.tier` — the client can't set it directly (denied by Firestore rules).

Errors use consistent JSON: `{ "error": "rate_limit_reached" | "capacity_exceeded" | "internal_error" | ... }`.

## 5. UI Architecture (Flutter)

- **State management:** Riverpod. `orbStateProvider` drives the shader (idle/listening/thinking/speaking); `chatProvider` owns conversation messages and talks to `ApiService`; `languageProvider` persists the user's chosen language via `shared_preferences`.
- **Screen flow:** `SplashScreen` → (anonymous auth) → `HomeScreen` (orb + chat list + voice button + settings icon) → `SettingsScreen` → `LanguageScreen`.
- **HolographicOrb:** a `CustomPainter` driving a GLSL `FragmentShader` (`assets/shaders/orb.frag`). Energy uniform smoothly interpolates toward the target value each frame so state transitions don't pop.
- **Voice:** `speech_to_text` for STT feeds directly into `chatProvider.sendMessage`; `flutter_tts` (dependency included) is the next wire-up for spoken replies.
- **Translation:** when `languageProvider` isn't `en`, every assistant reply is auto-translated via `/translate` and shown as a second line under the English text (with romanization). Translation failure never blocks showing the original reply.
- **Offline cache:** `LocalCacheService` (Hive) mirrors every chat update to disk keyed by conversation id (or `'draft'` before one exists). `ChatNotifier` loads the cached draft on startup so the UI has something to show before the network round-trip completes.
- **Billing:** `SettingsScreen` calls `/billing/create-checkout-session` and opens the returned Stripe Checkout URL via `url_launcher`. The app never talks to Stripe directly — only your backend does, and only the `stripeWebhook` function ever flips `tier` in Firestore.

## 6. What's intentionally NOT in this MVP

To stay "minimal but scalable" rather than over-built:
- No multi-region Functions — single region (`asia-south1`) pinned for now; the stateless design means adding regions later is a config change, not a rewrite.
- No admin dashboard for the key pool — managed via Firebase console/scripts until usage justifies tooling.
- iOS build target not configured in CI yet (Android-first per your roadmap).
- Stripe is wired for subscriptions only (no metered billing, proration handling beyond Stripe's defaults, or in-app native payment sheets — Checkout is a hosted web flow, simplest to ship first).

## 7. Local Setup

```bash
# Backend
cd functions && npm install
firebase functions:secrets:set STRIPE_SECRET_KEY
firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
# also set STRIPE_PRO_PRICE_ID and APP_BASE_URL as regular env config
firebase emulators:start --only functions,firestore

# Mobile
cd mobile && flutter pub get
flutterfire configure   # generates firebase_options.dart
flutter run
```

After deploying, register the webhook URL (`.../stripeWebhook`) in the Stripe Dashboard under Developers → Webhooks, subscribed to `checkout.session.completed` and `customer.subscription.updated/deleted`.

Populate `api_key_pool` with at least one Gemini key and one Grok key before testing `/chat` and `/translate`:

```js
// one-off via Firebase console or an admin script
db.collection('api_key_pool').add({
  provider: 'gemini', key: '...', usageCount: 0,
  dailyLimit: 1000, lastUsedAt: null, status: 'active'
});
```
