Email Capture Service — Architecture Summary
Overview
Event-driven AWS Lambda pipeline that captures order confirmation emails from retailers (THE ICONIC and NET-A-PORTER), extracts structured order data, and sends it to the AirRobe Marketplace via webhooks.
7 Lambda Functions

1. updateUser.ts — User Authorization
   Trigger: SQS (USER_DETAILS_SQS_QUEUE_URL) with Command message attribute
   AddUser: Stores OAuth tokens in DynamoDB, sets nextDateEmailsFetchedAt to tomorrow, then sends message to USER_DETAILS_SQS_QUEUE_URL to kick off first email sync (3 years of history)
   RevokeUser: Soft-deletes user (nulls tokens, sets deleted: true)
2. getUsers.ts — Batch User Query
   Trigger: SQS (GET_USERS_SQS_QUEUE_URL), typically scheduled
   Queries DynamoDB GSI nextDateEmailsFetchedAt where value equals today's date (from SQS SentTimestamp)
   For each user found, sends their details to USER_DETAILS_SQS_QUEUE_URL
   After processing, updates user's nextDateEmailsFetchedAt to tomorrow
   Self-loops to GET_USERS_SQS_QUEUE_URL if DynamoDB returns >1MB (pagination via LastEvaluatedKey)
   Daily sync uses afterDate: yesterday, but new retailer syncs use afterDate: 3 years ago
3. getEmailIds.ts — Gmail Email ID Discovery
   Trigger: SQS (USER_DETAILS_SQS_QUEUE_URL)
   Sets up Gmail OAuth client (refreshes expired tokens)
   Queries Gmail API with vendor-specific search filters, max 50 results per request
   Sends batch of email IDs to EMAIL_IDS_QUEUE_URL
   Self-loops to USER_DETAILS_SQS_QUEUE_URL if Gmail returns nextPageToken (pagination)
4. getRawEmailBodies.ts — Raw Email Retrieval
   Trigger: SQS (EMAIL_IDS_QUEUE_URL)
   Batch-fetches raw emails from Gmail API
   Saves base64-encoded email bodies to S3 (gmail/raw/YYYY/MM/DD/HH/gmail-raw-email-body-\*.json)
5. parseRawEmailBodies.ts — Email Parsing
   Trigger: S3 ObjectCreated:Put event
   Reads raw email JSON from S3, parses with mailparser
   Routes to vendor-specific parser (cheerio HTML DOM traversal):
   The Iconic: from iconic, subject thank you for shopping, extracts order date (DD/MM/YYYY), order number, items (image, brand, title, size, qty, price)
   NET-A-PORTER: from net-a-porter, subject order confirmation, extracts order number from account link, items from variant images
   Stores parsed order in DynamoDB (email-capture-parsed-emails)
6. handleDynamoDbEvents.ts — DynamoDB Stream Processor
   Trigger: DynamoDB Streams
   email-capture-retailers table INSERT → sends message to GET_USERS_SQS_QUEUE_URL (triggers bulk re-sync for new retailer)
   email-capture-parsed-emails table INSERT → sends message to PARSED_EMAILS_SQS_QUEUE_URL
   Ignores REMOVE events
7. sendOrderToMarketplace.ts — Marketplace Webhook
   Trigger: SQS (PARSED_EMAILS_SQS_QUEUE_URL)
   Signs payload with HMAC-SHA256 (shared secret from SSM)
   POSTs to {MARKETPLACE_DOMAIN}/webhooks/email_orders/add_order
   Header: X_AIRROBE_HMAC_SHA256
   SQS Re-queuing Patterns (Self-loops)
   Three functions send data back to SQS queues that trigger themselves or earlier stages:
   updateUser.ts → USER_DETAILS_SQS_QUEUE_URL: After adding a user, immediately triggers first email sync (3 years of history)
   getEmailIds.ts → USER_DETAILS_SQS_QUEUE_URL (self-loop): Gmail pagination — re-queues with emailIdsNextPageToken to fetch next 50 email IDs
   getUsers.ts → GET_USERS_SQS_QUEUE_URL (self-loop): DynamoDB pagination — re-queues with usersNextPageToken when results exceed 1MB
   handleDynamoDbEvents.ts → GET_USERS_SQS_QUEUE_URL: New retailer added triggers bulk user re-sync
   nextDateEmailsFetchedAt — Daily Scheduling Mechanism
   This field acts as a simple daily scheduler for per-user email syncs:
   User added (addUserDetails): Set to tomorrow (tomorrowsDate())
   getUsers runs (scheduled trigger): Queries GSI where nextDateEmailsFetchedAt = today's date — only picks up users due for sync
   After processing (updateNextDateEmailsFetchAt): Set to tomorrow again
   Result: Each user's emails are fetched once per day
   No double-sync on user's first day:
   When a user is added, addUserDetails sets nextDateEmailsFetchedAt = tomorrow. The first sync happens immediately via updateUser sending directly to USER_DETAILS_SQS_QUEUE_URL. When getUsers runs later that same day, it queries for nextDateEmailsFetchedAt = today, so the newly added user (set to tomorrow) is skipped — preventing a duplicate sync on day one. They first appear in the getUsers query the following day.
   First sync vs daily sync:
   First sync (via updateUser): afterDate = 3 years ago, beforeDate = today — fetches full email history
   Daily sync (via getUsers): each subsequent sync only fetches one day's worth of emails (afterDate = yesterday, beforeDate = today)
   Potential bug in getUsers.ts filter logic (line 77-79):
   const filterCriteria = retailerName
   ? { afterDate: yesterdaysDate() }
   : { afterDate: threeYearsAgoDate(), retailerName };

The condition appears inverted. When retailerName exists (new retailer sync — should do 3-year lookback), it uses yesterdaysDate(). When retailerName is undefined (daily sync — should only get yesterday), it uses threeYearsAgoDate() and passes the undefined retailerName. The intended behavior seems like it should be the opposite.
Data Flow
User OAuth → [updateUser] → DynamoDB (users table)
→ SQS (user details) ─────────────────────┐
│
Scheduled ─→ [getUsers] → SQS (user details) ──────────────────────┤
→ self-loop (DynamoDB pagination) │
▼
[getEmailIds]
→ Gmail API (list, max 50)
→ SQS (email IDs) → [getRawEmailBodies]
→ self-loop (Gmail pagination) │
▼
Gmail API (get raw)
│
S3 (raw emails)
│
[parseRawEmailBodies]
│
DynamoDB (parsed emails)
│
DynamoDB Stream
│
[handleDynamoDbEvents]
│
SQS (parsed emails)
│
[sendOrderToMarketplace]
│
Marketplace API

AWS Services Used
Lambda — 7 functions (compute)
SQS — 4 queues (stage coordination, pagination)
S3 — raw email transient storage
DynamoDB — 3 tables: users, parsed-emails, retailers (with streams)
SSM Parameter Store — secrets (Google OAuth creds, HMAC key)
Key Libraries
@googleapis/gmail + google-auth-library — Gmail API with OAuth2
mailparser — MIME email parsing
cheerio — HTML DOM parsing for order extraction
axios — marketplace webhook HTTP client
accounting + currency-codes — price/currency parsing
AWS SDK v3 — DynamoDB, S3, SQS, SSM clients
Build & Deploy
Webpack bundles each Lambda into individual .zip files in dist/
S3 artifact bucket (stg/prod) stores zips
Terraspace (infrastructure-as-code) deploys Lambda functions, triggers, IAM roles
Environments: .env.stg, .env.prod
Design Limitations & Proposed Solutions

1. Missed days are never recovered
   Problem: getUsers queries nextDateEmailsFetchedAt = today (exact equality). If it fails to run on a given day, users with that date are orphaned forever. Solution: Restructure the GSI so nextDateEmailsFetchedAt is a sort key (not partition key) with a fixed partition key (e.g., status = "active"). Query with nextDateEmailsFetchedAt <= today to catch any missed days.
2. Inverted filter logic in getUsers.ts (line 77-79)
   Problem: The ternary is backwards — daily syncs get 3-year lookback, new retailer syncs get yesterday only. Solution: Swap the ternary:
   const filterCriteria = retailerName
   ? { afterDate: threeYearsAgoDate(), retailerName }
   : { afterDate: yesterdaysDate() };

3. No deduplication on marketplace webhooks
   Problem: Re-parsed emails (SQS retries, duplicate fetches) trigger DynamoDB stream MODIFY events, which re-send the same order to the marketplace. Solution: In handleDynamoDbEvents, filter on eventName === "INSERT" only for the parsed-emails table. Currently it only skips REMOVE, so MODIFY events still trigger re-sends.
4. Gmail token revocation with no retry/backoff
   Problem: If a user's refresh token is revoked, OAuth fails but nextDateEmailsFetchedAt was already updated to tomorrow (in getUsers), so the user keeps getting queued and failing every day with no alerting. Solution:
   Add authFailureCount field on user record
   On OAuth failure, increment counter; after N failures (e.g., 3), set status = "auth_failed" and stop queuing
   Move the nextDateEmailsFetchedAt update from getUsers to getEmailIds — only update after a successful Gmail call
   Send SNS/SES notification to alert that a user needs to re-authorize
5. Single-region deployment
   Problem: Everything runs in us-east-1 with no failover. Solution: For resilience, use DynamoDB global tables and deploy a standby in another region. Shorter term: enable S3 cross-region replication. May not be worth the complexity if us-east-1 uptime is acceptable for the business.
6. No dead letter queues visible in application code
   Problem: Poison SQS messages (repeated failures) retry indefinitely with no apparent DLQ. Solution: Add DLQ configuration in Terraspace for each SQS queue:

Add CloudWatch alarm on DLQ message count to alert when messages land there. 7. Tight coupling to retailer email HTML structure
Problem: Cheerio parsers rely on specific DOM structures and text patterns. Any email template change by THE ICONIC or NET-A-PORTER silently breaks parsing — only visible in CloudWatch logs. Solution:
Add integration tests against real sample emails (some exist in samples/), validate on every deploy
On parse failure, store raw email reference with status = "parse_failed" for manual review or retry when parser is updated
Consider a generic fallback parser (regex for order numbers and prices)
Set up CloudWatch alarms on ParsingError log frequency — a spike indicates a template change 8. No Gmail API rate limiting
Problem: Self-looping SQS pagination with no throttling. Many users doing 3-year lookbacks (especially with the inverted filter bug) can hit Gmail API rate limits, causing cascading failures. Solution:
Set reserved concurrency on getEmailIds and getRawEmailBodies Lambdas to cap parallel Gmail calls
Add DelaySeconds on self-loop SQS messages (e.g., 5-10 seconds between pagination calls):await sendSqsMessage(messageBody, USER_DETAILS_SQS_QUEUE_URL, { DelaySeconds: 5 });
Implement exponential backoff on Gmail 429 responses instead of letting the Lambda fail 9. S3 raw emails are never cleaned up
Problem: Raw emails accumulate in S3 indefinitely with no lifecycle policy. Only needed transiently between getRawEmailBodies and parseRawEmailBodies. Solution: Add S3 lifecycle policy in Terraspace:

10. Hot partition on nextDateEmailsFetchedAt GSI
    Problem: All users due on the same day share the same GSI partition key, creating a hot partition that limits DynamoDB throughput at scale. Solution options:
    A) Shard the key: Append random suffix (e.g., 2026-03-17#0 through 2026-03-17#9), query all shards in parallel in getUsers
    B) Replace GSI with scan: Use a scheduled EventBridge rule triggering a DynamoDB Scan with filter nextDateEmailsFetchedAt <= today AND status = active. Acceptable at moderate user counts.
    C) Deprioritize: If user count is small (thousands, not millions), the hot partition likely isn't a practical issue
