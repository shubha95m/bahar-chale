# Bahar Chale — Security & Privacy Architecture

## 1. Zero Trust Database Access (Row Level Security)
- Row Level Security (RLS) is enabled on 100% of public tables.
- Table policies use the `TO authenticated` and `TO anon` role definitions rather than deprecated `auth.role()` functions.
- `UPDATE` policies enforce identical predicates on both `USING` and `WITH CHECK` clauses to prevent IDOR / ownership hijack attacks.
- Only open, full, or completed rides are queryable publicly; private phone numbers and draft data are never exposed.

## 2. Token & Credential Management
- No `service_role` keys are ever shipped or referenced in the Flutter client bundle.
- Only the Supabase publishable key and legacy anon key are used for client interaction.
- On Android, session tokens are saved in Android Keystore via `flutter_secure_storage`.
- On Web, sessions use local browser storage with PKCE exchange.

## 3. Privacy & Contact Protection
- Phone numbers and exact residential pickup points are not displayed on public ride cards.
- Contact sharing is strictly opt-in and handled via the mutual Agreement workflow.
- In-app chat messages are restricted strictly to conversation participants (`owner_id` or `requester_id`).

## 4. Abuse Prevention & Safety
- Database-backed user blocking (`user_blocks`) and user reports (`user_reports`).
- Unique database constraints (`UNIQUE(ride_id, requester_id)`) prevent spamming multiple requests.
