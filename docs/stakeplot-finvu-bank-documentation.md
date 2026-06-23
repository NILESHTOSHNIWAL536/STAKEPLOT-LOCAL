# Stakeplot Mobile Project Documentation

Generated: 2026-06-11

Scope: this document focuses on the Finvu account-linking flow and bank transaction APIs requested first. It also includes a short project-wide map so the Finvu and bank modules are understandable in the full mobile project.

## 1. Project Map

| Area | Path | Main responsibility |
| --- | --- | --- |
| Flutter mobile frontend | `mobile-frontend/` | Screens, app navigation, API route constants, Finvu SDK integration, bank dashboards, transaction history, collections, community, rewards, auth. |
| Main backend | `mobile-backend/mobile-backend/` | Core app APIs under `/api/v1`: auth, user, community, chat, budget, bill, notifications, bank proxy, email proxy. |
| Bank service | `mobile-backend/bank-service/` | Bank/Finvu APIs, transaction automation, bank account storage, categorization, insights, collections, reserve, referral, webhooks. |
| Email service | `mobile-backend/email-service/` | Gmail/email token handling, email scraping, statement passwords, pending statement processing, credit card statement extraction. |

## 2. API Base URLs From Flutter

Defined in `mobile-frontend/lib/routes/index_route.dart`.

| Constant | Value pattern | Used for |
| --- | --- | --- |
| `API.mainBackendUrl` | `${Credentials.LIVE_API_TEST or LIVE_API}api/v1` | Main backend modules like auth, user, budget, chat, post, split. |
| `API.EmailUrl` | `${base}api/v1/email` | Email service proxy endpoints. |
| `API.BankApiUrl` | `${base}api/v1/bank` | Bank service proxy endpoints. |
| `BackendApiEndPoints.finvu` | `${API.BankApiUrl}/finvu` | Finvu consent and fetch APIs. |
| `BackendApiEndPoints.transactionauto` | `${API.BankApiUrl}/transactionauto` | Automated bank transaction APIs. |
| `BackendApiEndPoints.transaction` | `${API.BankApiUrl}/transaction` | Older/manual transaction APIs. |

Backend note: the bank service itself mounts routes at `/api` in `mobile-backend/bank-service/src/app.ts`, while the public mobile app calls them through the main backend proxy at `/api/v1/bank/...`.

## 3. Mobile Page Routes

Defined in `mobile-frontend/lib/routes/routes.dart`.

| App route | Screen class | File | Purpose |
| --- | --- | --- | --- |
| `/discover` | `DiscoverAccount` | `mobile-frontend/lib/finvu_screens/discoverAccount.dart` | Shows Finvu-supported banks/FIPs and starts account discovery/linking. |
| `/ShareAccountLogin` | `ShareAccountLogin` | `mobile-frontend/lib/finvu_screens/shareAccountLogin.dart` | Entry page for sharing account data with Finvu. |
| `/FetchTransaction` | `FetchTransaction` | `mobile-frontend/lib/finvu_screens/FetchTransaction.dart` | Screen shown while fetching linked account transactions. |
| `/OnboardingScreen` | `OnboardingScreen` | `mobile-frontend/lib/onboarding_screens/onboarding_screen.dart` | Onboarding destination after linking/fetch flow for new users. |
| `/FinanceDashboard` | `FinanceDashboard` | `mobile-frontend/lib/finance_screen/finanace_dashboard/index_finances.dart` | Main finance dashboard after bank data exists. |
| `/home` | `HomePage` | `mobile-frontend/lib/Home_Screen/home_screen_state/home_page.dart` | Home page, includes bank-linked state and finance widgets. |

Finvu folder screens:

| Screen/helper | File | Role |
| --- | --- | --- |
| `ShareAccountLogin` | `finvu_screens/shareAccountLogin.dart` | Starts the consent/share journey. |
| `MobileNumber` | `finvu_screens/mobileNumber.dart` | Captures mobile number and triggers Finvu login/OTP. |
| `FinvuVerifyOtpScreen` | `finvu_screens/finvu_otp_screen.dart` | Verifies Finvu OTP. |
| `DiscoverAccount` | `finvu_screens/discoverAccount.dart` | Lists/discovers FIPs and selected bank accounts. |
| `LinkingAccount` | `finvu_screens/LinkingAccount.dart` | Links discovered accounts through Finvu SDK. |
| `Access` | `finvu_screens/access.dart` | Consent/access confirmation screen before fetch. |
| `FetchLinkedAccounts` | `finvu_screens/FetchLinkedAccounts.dart` | Fetches already linked accounts. |
| `FetchTransaction` | `finvu_screens/FetchTransaction.dart` | Transaction fetch progress/finalization screen. |
| `integration.dart` | `finvu_screens/integration.dart` | Core Finvu SDK initialization, login, backend consent-handle call, transaction fetch call. |
| `bottombar.dart`, `appbar_widget.dart` | `finvu_screens/` | Shared Finvu UI components. |
| `skipFInvuProcess.dart` | `finvu_screens/skipFInvuProcess.dart` | Lets user skip the Finvu flow. |

## 4. Finvu Frontend API Routes

Defined in `mobile-frontend/lib/routes/route_finvu.dart`.

| Flutter route field | Public endpoint | Method in backend | Auth | Purpose |
| --- | --- | --- | --- | --- |
| `FinvuRoutes.login` | `/api/v1/bank/finvu/login` | `POST` | Yes | Create a Finvu consent request and return `consentHandleId`. |
| `FinvuRoutes.fetchData` | `/api/v1/bank/finvu/fetchData` | `POST` | Yes | Poll consent, create FI request, queue final transaction fetch. |
| `FinvuRoutes.fetchWeekly` | `/api/v1/bank/finvu/fetchWeekly` | `POST` | Yes | Re-fetch/update bank data for an existing consent/account. |
| `FinvuRoutes.getFipsMetric` | `/api/v1/bank/finvu/fipsmetric` | `GET` | No backend middleware | Fetch and store latest FIP metrics. |
| `FinvuRoutes.getStatus(id)` | `/api/v1/bank/finvu/status/:id` | `GET` | No backend middleware | Check consent status using stored handle record id. |
| `FinvuRoutes.getFipDetails` | `/api/v1/bank/finvu/fip-details` | `POST` | Yes | Get latest metrics for selected FIP ids. |
| `FinvuRoutes.addFinvuData` | `/api/v1/bank/finvu/add` | Not present | N/A | Frontend constant exists, but no matching backend route was found. |

## 5. Finvu Backend Routes

Defined in `mobile-backend/bank-service/src/routes/finvu-routes.ts`.

| Method | Bank service route | Public mobile route | Controller | Request body / params | Response notes |
| --- | --- | --- | --- | --- | --- |
| `POST` | `/api/finvu/login` | `/api/v1/bank/finvu/login` | `loginAndGetHandleId` | Body: `custId`, `number` | Returns `consentHandleId` and `metric`. Creates Finvu consent via `/ConsentRequestPlus`, stores handle in `ConsentHandleId`. |
| `POST` | `/api/finvu/fetchData` | `/api/v1/bank/finvu/fetchData` | `fetchTransactions` | Body: `handleId`, `custId` | Polls consent status, fetches consent details, creates FI request, stores `finvu:{sessionId}` in Redis, writes `Finvu`, queues fetch in non-production, returns `sessionId`. |
| `POST` | `/api/finvu/fetchWeekly` | `/api/v1/bank/finvu/fetchWeekly` | `fetchTransactionsWeekly` | Body: `custId`, `userId`, `consentId`, `handleId`, `FROM`, optional `token`, `isCron`, `bankName`, `accountId`, `fipId`, `fetchCount` | Creates update FI request for existing consent and returns fetch progress data. |
| `POST` | `/api/finvu/fip-details` | `/api/v1/bank/finvu/fip-details` | `getFipsDetails` | Body: `{ "fipIds": ["..."] }` | Returns matching `FipsMetric` rows for `FIFetchResponse` events. |
| `GET` | `/api/finvu/fipsmetric` | `/api/v1/bank/finvu/fipsmetric` | `getFipsLatestMetricsAll` | None | Generates token, calls Finvu `/fips/latest-metrics-all`, drops and reinserts metric collection. |
| `GET` | `/api/finvu/status/:id` | `/api/v1/bank/finvu/status/:id` | `getStatus` | Param: `id` = `ConsentHandleId` Mongo id | Loads stored handle and calls Finvu `/ConsentStatus/:handleId/:custId`. |

Security note: `login`, `fetchData`, `fetchWeekly`, and `fip-details` use `AuthMiddlewares.protect`. `fipsmetric` and `status/:id` currently do not use auth middleware in the route file.

## 6. Finvu Controller Flow

Defined in `mobile-backend/bank-service/src/controllers/finvu-controller.ts`.

### Initial consent flow

1. Flutter calls `getConsentHandleId(context)` in `finvu_screens/integration.dart`.
2. The function posts to `FinvuRoutes.login` with:

```json
{
  "custId": "<mobile>@finvu",
  "number": "<mobile>"
}
```

3. Backend `loginAndGetHandleId`:
   - Reads `req.user._id`.
   - Generates a Finvu auth token using `generateToken()`.
   - Calls Finvu `ConsentRequestPlus`.
   - Stores or updates `ConsentHandleId` with `custId`, `handleId`, `userId`, and 24 hour expiry.
   - Fetches and stores FIP metrics.
   - Returns `consentHandleId` to Flutter.

### Finvu SDK login and account linking

1. Flutter initializes `finvuManager` in `initFinvuManager`.
2. Flutter calls `finvuManager.loginWithUsernameOrMobileNumberAndConsentHandle`.
3. OTP reference is stored in `otpReference`.
4. `verify(otp, context)` calls `finvuManager.verifyLoginOtp`.
5. After OTP success, Flutter fetches linked accounts and navigates to `DiscoverAccount`.

### Transaction fetch flow

1. Flutter calls `FetchTransactionFromFinvuApi(context)` in `integration.dart`.
2. It marks the user fetch state using `UserRoutes.updateFetchStatus`.
3. It posts to `FinvuRoutes.fetchData` with:

```json
{
  "token": "",
  "handleId": "<consentHandleId>",
  "custId": "<mobile>@finvu"
}
```

4. Backend `fetchTransactions`:
   - Reads Redis `auth_token`.
   - Polls `fetchConsentStatus` up to 2 attempts.
   - If consent is accepted, gets `consentId`.
   - Calls `fetchConsentDetails` to get FI data range.
   - Calls `initiateFIRequest` up to 5 attempts.
   - Stores session payload in Redis key `finvu:<sessionId>` for 600 seconds.
   - Stores the same payload in Mongo `Finvu`.
   - In non-production, enqueues `enqueueFinvuFetch` because the staging Finvu webhook is not registered.
   - Returns `{ "message": "FI Request started", "sessionId": "..." }`.

### Final data fetch / webhook path

The FI request does not immediately return transactions. Final data is fetched later by either:

| Trigger | Location | Purpose |
| --- | --- | --- |
| Finvu webhook | `mobile-backend/bank-service/src/routes/index.ts` route `POST /api/FI/Notification` to `webHook` | Production data-ready notification path. |
| Bull queue fallback | `mobile-backend/bank-service/src/services/bull-queue-service/finvu-fetch-queue.ts` | Non-production delayed final fetch path. |
| Manual queue trigger | `/api/finvu-queue/trigger` | Staging test route. |

The queue worker calls `fetchFinalData`, stores/updates bank details, creates transactions, sends notifications, and publishes websocket events through Redis `bank_events`.

### Weekly/update fetch flow

1. Flutter `BankInfoController.getWeeklyfetchData` posts to `FinvuRoutes.fetchWeekly`.
2. Request includes existing `consentId`, `consendHandleId`, `sessionId`, `custId`, `last`/`FROM`, `bankName`, `fipId`, `fetchCount`, and `accountId`.
3. Backend `fetchTransactionsWeekly` creates a fresh FI request for the updated range.
4. It stores Redis/Mongo `Finvu` data with `isUpdate: true`.
5. It returns `sessionId`, `accountId`, `handleId`, `consentId`, `bankName`, and `fetchInProgress: true`.

## 7. Bank Transaction Frontend Routes

Defined in `mobile-frontend/lib/routes/route_transactions.dart`.

Base: `/api/v1/bank/transactionauto`

| Flutter route field | Endpoint | Backend match |
| --- | --- | --- |
| `getAutoPays` | `GET /autopays` | Yes |
| `createRecurringPaymentFromTransaction(transactionId)` | `POST /recurring-payments/from-transaction/:transactionId` | Yes |
| `categorizeGroupedTransaction(groupId)` | `POST /grouped/:groupId/categorize` | Yes |
| `verifyPendingTransaction(transactionId, isCorrect)` | `POST /verify-pending-transaction/:transactionId/:isCorrect` | Yes |
| `updateTransaction(transactionId)` | `PATCH /updateTransaction/:transactionId` | Yes |
| `getSearchedTransactions(page, search, isBankAccount)` | `GET /getTransactions/:page` | Yes; search/filter values are passed as query/body helper data, not path segments. |
| `getTransactionsOfUser` | `GET /getTransactionsOfUser` | Yes |
| `categorizeTransactions` | `GET /categorize` | Yes |
| `getUserMonthlySpending` | `GET /getUserMonthlySpending` | Yes |
| `getGroupedTransactions` | `GET /get-grouped-transactions` | Yes |
| `getPendingForReviewTransactions` | `GET /pending-for-review-transactions` | Yes |
| `getDayWiseTransactionsSummary` | `GET /get-day-wise-transactions` | Yes |
| `getTransactionsByDate(date)` | `GET /get-day-wise-transactions/:date` | Yes |
| `getRecurringPayments(isActive)` | `GET /get-recurring-payments/:isActive` | Yes |
| `updateRecurringPayment(id)` | `PATCH /recurring-payments/:id` | Yes |
| `deleteRecurringPayment(id)` | `DELETE /recurring-payments/:id` | Yes |
| `getLoanCalculation` | `POST /get-loan-calculation` | Yes |
| `getAllCustomTransactions(accountId,type,value)` | `GET /getAllCustomTransactions/:accountId/:type/:value` | Yes |
| `getWholeTransactionsGraph(type,value)` | `GET /getWholeTransactionsGraph/:type/:value` | Yes |
| `getUserDetails` | `GET /user-details` | Yes |
| `getBanksLinkedAndAccounts` | `GET /get-banks-linked` | Yes |
| `getQuickCheck` | `GET /get-banksdebitcredit` | Yes |
| `getMonthlyTransactionsHistory(accountId,type,page)` | `GET /get-monthly-transactions-history/:accountId/:type/:page` | Yes |
| `getPreviousTransactions(date,accountId)` | `GET /get-previous-transactions/:date/:accountId` | Yes |
| `getTopThreeTransactionsOfWeek` | `GET /top-three-transactions-of-week` | Yes |
| `getIncomeAndCategorySpent` | `GET /get-income-average-monthly-category-expenses` | Yes |
| `deleteBankAccount(bankId,accountId)` | `DELETE /:bankId/:accountId` | Yes |
| `deleteTransactions` | `POST /delete` | Yes |
| `createTransaction` | `POST /create` | Backend exists, frontend constant not named directly except route file comments. |
| `top-five-categories` | `GET /top-five-categories` | Backend exists as `getBudgetTopFiveCategories`. |
| `category-wise-spendings` | `GET /category-wise-spendings` | Backend exists; no obvious frontend route field found. |
| `budget-transactions` | `GET /budget-transactions` | Backend exists; no obvious frontend route field found. |
| `get-budget-spents` | `GET /get-budget-spents` | Backend exists; no obvious frontend route field found. |
| `PUT /:transactionId` | `PUT /:transactionId` | Backend exists for alternate transaction update. |

Known frontend constants without matching backend routes in `transactionsAuto/transactions.ts`:

| Flutter route field | Endpoint | Note |
| --- | --- | --- |
| `getTransactionsForAccount` | `/getTransactionsForAccount/:accountId/:page` | Not present in current backend route file. |
| `getAllTransactionsByMonth` | `/getalltransactionsbymonth/:month` | Not present in current backend route file. |
| `getAllTransactionsByWeek` | `/getalltransactionbyweek/:week` | Not present in current backend route file. |
| `getHideTransactions` | `/get-hide-transactions` | Not present in current backend route file, but used in repository. |
| `getHeadsUpMessages` | `/get-headsup-messages` | Not present in current backend route file. |
| `getMoneyMapMessages` | `/get-money-map-messages` | Not present in current backend route file. |
| `getHighestSpentInsight` | `/insights` | Not present in current backend route file; insight routes exist separately under `/api/v1/bank/insights`. |
| `createReserve` | `/api/reserves` | Not present under `transactionauto`; reserve routes are mounted separately. |
| salary income routes | `/salary-income/...` | Not shown in current bank route index snippet; verify mount before using. |

## 8. Bank Transaction Backend Routes

Defined in `mobile-backend/bank-service/src/routes/transactionsAuto/transactions.ts`.

All routes below use `AuthMiddlewares.protect` unless marked as unauthenticated. Some routes also use `validateRequestMiddleware`.

| Method | Public mobile endpoint | Controller | Purpose |
| --- | --- | --- | --- |
| `GET` | `/api/v1/bank/transactionauto/autopays` | `getAutoPays` | Fetch detected auto-pay/recurring debit groups. |
| `POST` | `/api/v1/bank/transactionauto/recurring-payments/from-transaction/:transactionId` | `createRecurringPaymentFromTransactionController` | Create recurring payment record from a transaction. |
| `POST` | `/api/v1/bank/transactionauto/grouped/:groupId/categorize` | `categorizeGroupedTransaction` | Categorize a grouped set of transactions. |
| `POST` | `/api/v1/bank/transactionauto/verify-pending-transaction/:transactionId/:isCorrect` | `verifyPendingTransaction` | Mark an auto/pending transaction prediction as correct or incorrect. |
| `PATCH` | `/api/v1/bank/transactionauto/updateTransaction/:transactionId` | `updateTransaction` | Update category, subcategory, hidden/excluded fields, etc. |
| `GET` | `/api/v1/bank/transactionauto/getTransactions/:page` | `getSearchedTransactions` | Fetch paginated searched/filtered transactions. |
| `GET` | `/api/v1/bank/transactionauto/getTransactionsOfUser` | `getAllTransactionsOfUser` | Fetch all transactions for current user. |
| `GET` | `/api/v1/bank/transactionauto/dummy-categorize-preview` | `dummyCategorizationPreview` | Unauthenticated categorization preview. |
| `POST` | `/api/v1/bank/transactionauto/dummy-categorize-preview` | `dummyCategorizationPreview` | Unauthenticated categorization preview. |
| `GET` | `/api/v1/bank/transactionauto/categorize` | `categorizeTransactions` | Run or fetch categorization logic for transactions. |
| `POST` | `/api/v1/bank/transactionauto/create` | `createTransaction` | Create a transaction manually/custom. |
| `GET` | `/api/v1/bank/transactionauto/top-five-categories` | `getTopFiveCategories` | Top spend categories. |
| `GET` | `/api/v1/bank/transactionauto/category-wise-spendings` | `getCategoryWiseSpendings` | Category-wise spending summary. |
| `GET` | `/api/v1/bank/transactionauto/budget-transactions` | `getBudgetTransactions` | Transactions related to budgets. |
| `GET` | `/api/v1/bank/transactionauto/get-budget-spents` | `getBudgetSpents` | Budget spending totals. |
| `PUT` | `/api/v1/bank/transactionauto/:transactionId` | `updateTransaction` | Alternate transaction update route. |
| `GET` | `/api/v1/bank/transactionauto/getUserMonthlySpending` | `getUserMonthlySpending` | Monthly spending summary. |
| `GET` | `/api/v1/bank/transactionauto/get-grouped-transactions` | `getGroupedTransactions` | Group similar transactions. |
| `GET` | `/api/v1/bank/transactionauto/pending-for-review-transactions` | `getPendingForReviewTransactions` | Transactions awaiting user review. |
| `GET` | `/api/v1/bank/transactionauto/get-day-wise-transactions` | `getDayWiseTransactionsSummary` | Day-wise summary for calendar/dashboard. |
| `GET` | `/api/v1/bank/transactionauto/get-day-wise-transactions/:date` | `getTransactionsByDate` | Transactions for a selected date. |
| `GET` | `/api/v1/bank/transactionauto/get-recurring-payments/:isActive` | `getRecurringPayments` | Active/inactive recurring payment list. |
| `PATCH` | `/api/v1/bank/transactionauto/recurring-payments/:id` | `updateRecurringPayment` | Update recurring payment. |
| `DELETE` | `/api/v1/bank/transactionauto/recurring-payments/:id` | `deleteRecurringPayment` | Delete recurring payment. |
| `POST` | `/api/v1/bank/transactionauto/get-loan-calculation` | `getLoanCalculation` | Loan calculation based on income/spend. |
| `GET` | `/api/v1/bank/transactionauto/getAllCustomTransactions/:accountId/:type/:value` | `getAllCustomTransactions` | Account-specific graph/custom-date transactions. |
| `GET` | `/api/v1/bank/transactionauto/getWholeTransactionsGraph/:type/:value` | `getWholeTransactionsGraph` | Overall graph data. |
| `GET` | `/api/v1/bank/transactionauto/user-details` | `getUser` | Current user detail from bank context. |
| `GET` | `/api/v1/bank/transactionauto/get-banks-linked` | `getBanksLinkedAndAccounts` | Linked banks and account details. |
| `GET` | `/api/v1/bank/transactionauto/get-banksdebitcredit` | `getBankBalanceAndDebitSummary` | Bank balance/debit/credit summary. |
| `GET` | `/api/v1/bank/transactionauto/get-monthly-transactions-history/:accountId/:type/:page` | `getMonthlyTransactionsHistory` | Paginated monthly/yearly/custom transaction history. |
| `GET` | `/api/v1/bank/transactionauto/get-previous-transactions/:date/:accountId` | `getPreviousTransactions` | Previous transactions from a selected date/account. |
| `GET` | `/api/v1/bank/transactionauto/top-three-transactions-of-week` | `getTopThreeTransactionsOfWeek` | Top three weekly transactions. |
| `GET` | `/api/v1/bank/transactionauto/get-income-average-monthly-category-expenses` | `getIncomeAndCategorySpent` | Income and average monthly category expenses. |
| `DELETE` | `/api/v1/bank/transactionauto/:bankId/:accountId` | `deleteBankAccount` | Delete one bank account and related data. |
| `POST` | `/api/v1/bank/transactionauto/delete` | `deleteTransactions` | Bulk delete transactions. |

## 9. Other Bank Routes Used By Transaction Code

### Manual/legacy transaction routes

Defined in `mobile-backend/bank-service/src/routes/transaction-routes.ts`, mounted at `/api/v1/bank/transaction`.

| Method | Endpoint | Controller | Purpose |
| --- | --- | --- | --- |
| `POST` | `/api/v1/bank/transaction/add` | `enterTransaction` | Add manual transaction. |
| `POST` | `/api/v1/bank/transaction/updateGroupTransactions/:id` | `updateGroupTransaction` | Update group transaction amount. |
| `GET` | `/api/v1/bank/transaction/all` | `getAllTransactions` | Fetch old transaction list. |
| `DELETE` | `/api/v1/bank/transaction/:id` | `deleteSpecificTransaction` | Delete a specific old transaction. |

### Custom category routes

Defined in `mobile-backend/bank-service/src/routes/transactionsAuto/custom-category-routes.ts`, mounted at `/api/v1/bank/custom`.

| Method | Endpoint | Controller | Purpose |
| --- | --- | --- | --- |
| `POST` | `/api/v1/bank/custom/custom-category` | `addCustomCategory` | Add user custom category. |
| `GET` | `/api/v1/bank/custom/custom-category` | `getCustomCategories` | Fetch user custom categories. |

Frontend note: `BankTransactionRoutes.customCategory` currently points to `${API.mainBackendUrl}/custom/custom-category`, not `${API.BankApiUrl}/custom/custom-category`. Since the backend route is mounted in the bank service, this should be verified through the main backend proxy.

## 10. Screen / Repository To API Mapping

| Frontend file | Functions/classes | API routes used |
| --- | --- | --- |
| `finvu_screens/integration.dart` | `getConsentHandleId`, `FetchTransactionFromFinvuApi`, `login`, `verify` | `FinvuRoutes.login`, `FinvuRoutes.fetchData`, `UserRoutes.updateFetchStatus`, Finvu SDK login/OTP APIs. |
| `repository/bankinfo.dart` | `BankInfoController.getBankAccounts` | `BankTransactionRoutes.getBanksLinkedAndAccounts`. |
| `repository/bankinfo.dart` | `BankInfoController.getWeeklyfetchData` | `FinvuRoutes.fetchWeekly`, `UserRoutes.updateFetchStatus`. |
| `repository/bankinfo.dart` | `BankInfoController.getFipAccountInfo` | `FinvuRoutes.getFipDetails`. |
| `repository/transactions_repository.dart` | transaction history and filters | `getSearchedTransactions`, `getMonthlyTransactionsHistory`, `getDayWiseTransactionsSummary`, `getTransactionsByDate`. |
| `repository/transactions_repository.dart` | update/tag/hide/exclude | `updateTransaction`, `categorizeGroupedTransaction`, `verifyPendingTransaction`, `deleteTransactions`. |
| `repository/autopay_repository.dart` | auto-pay CRUD | `getAutoPays`, `createRecurringPaymentFromTransaction`, `updateRecurringPayment`, `deleteRecurringPayment`. |
| `repository/delete_banks_users.dart` | bank deletion | `deleteBankAccount`. |
| `repository/finance_repository.dart`, `repository/expanded_finance_repository.dart` | graphs/custom finance views | `getAllCustomTransactions`. |
| `finance_screen/Calculators/loan_calculator.dart` | loan/income calculation | `getIncomeAndCategorySpent`, `getLoanCalculation`. |

## 11. Important Data Models / Storage

| Model/storage | Backend path | Used for |
| --- | --- | --- |
| `ConsentHandleId` | `models/transactions-automation/consent-handle_model.ts` | Stores `custId`, consent handle id, user id, expiry for Finvu consent status lookup. |
| `Finvu` | `models/transactions-automation/finvu.ts` | Stores FI fetch sessions and metadata for async processing. |
| `FipsMetric` | `models/transactions-automation/fipsMetric` via model index | Stores latest FIP metrics fetched from Finvu. |
| `Bank`, `Account`, `Profile`, `Summary`, `Transaction` | `models/transactions-automation/` | Persist linked bank, account, profile, balance summary, and transaction records. |
| Redis key `auth_token` | `redis-config` usage | Finvu auth token used by fetch/status calls. |
| Redis key `finvu:<sessionId>` | Finvu controller and queue | Temporary FI request metadata for queue/webhook final fetch. |
| Redis pubsub channel `bank_events` | Finvu controller and queue | Publishes websocket events for fetch success/failure. |

## 12. Environment Variables Used By Finvu

Used in `finvu-controller.ts` and related helpers.

| Variable | Purpose |
| --- | --- |
| `FINVU_URL` | Base Finvu API URL. |
| `FINVU_RID` | Finvu request header `rid`. |
| `FINVU_TS` | Finvu request header `ts`. |
| `FINVU_CHANNEL_ID` | Finvu request header `channelId`. |
| `FINVU_CONSENT_DESCRIPTION` | Consent request description. |
| `FINVU_TEMPLATE_NAME` | Finvu consent template. |
| `FINVU_USER_SESSION_ID` | User session id included in consent request. |
| `NODE_ENV` | Controls whether fallback Bull queue is triggered for non-production. |

## 13. Known Gaps / Follow-up Items

| Item | Why it matters |
| --- | --- |
| `FinvuRoutes.addFinvuData` has no backend route. | Remove the unused frontend constant or add the missing backend endpoint. |
| `fipsmetric` and `status/:id` are unauthenticated in `finvu-routes.ts`. | Consider adding `AuthMiddlewares.protect` if these expose sensitive operational or user-specific data. |
| Several frontend `BankTransactionRoutes` constants do not match current backend routes. | Causes runtime 404s if screens call them: `get-hide-transactions`, `getTransactionsForAccount`, month/week routes, heads-up/money-map routes. |
| `customCategory` frontend base points to `API.mainBackendUrl`, but backend route is in bank service under `/custom`. | Verify the main backend proxy supports `/api/v1/custom`; otherwise change to `API.BankApiUrl`. |
| `app.ts` contains mojibake characters in comments. | Does not affect runtime, but comments should be cleaned for readability. |
| Public mobile path goes through `/api/v1/bank`, while bank service internal mount is `/api`. | Keep docs and route constants explicit to avoid confusing service-local paths with public app paths. |

## 14. Quick End-to-End Sequence

1. User opens Finvu sharing flow from `ShareAccountLogin`.
2. User enters mobile number in `MobileNumber`.
3. Flutter calls backend `POST /api/v1/bank/finvu/login`.
4. Backend creates Finvu consent and returns `consentHandleId`.
5. Flutter uses Finvu SDK to login with mobile number and handle id.
6. User verifies OTP in `FinvuVerifyOtpScreen`.
7. Flutter discovers and links accounts through Finvu SDK screens.
8. User confirms access in `Access`.
9. Flutter calls `POST /api/v1/bank/finvu/fetchData`.
10. Backend creates FI request and stores `sessionId`.
11. Webhook or Bull queue fetches final FI data.
12. Bank service stores bank/account/profile/summary/transactions.
13. Flutter finance/dashboard/history screens call `transactionauto` endpoints to show the data.

