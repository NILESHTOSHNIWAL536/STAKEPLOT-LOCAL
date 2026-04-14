# Collection API — Frontend Integration Guide

Base path: `/api/collections`  
All endpoints require `Authorization: Bearer <token>` header.

---

## Table of Contents

1. [Balance System (toPay / toReceive)](#1-balance-system)
2. [Payment Recording — Payer Side (Pay button)](#2-payment-recording--payer-side)
3. [Payment Clearing — Receiver Side (Clear button)](#3-payment-clearing--receiver-side)
4. [Bulk Member Limits (Owner only)](#4-bulk-member-limits)
5. [Existing Endpoints Reference](#5-existing-endpoints-reference)
6. [Full Flow Walkthrough](#6-full-flow-walkthrough)
7. [Data Models Reference](#7-data-models-reference)

---

## 1. Balance System

### `GET /api/collections/:id/balances`

Returns the logged-in user's **toPay** (debts they owe) and **toReceive** (amounts owed to them), broken down **per split**.

**Response:**

```json
{
  "success": true,
  "message": "Balances calculated successfully",
  "data": {
    "totalToPay": 600,
    "totalToReceive": 1200,
    "toPay": [
      {
        "splitId": "664abc123...",
        "friend": {
          "_id": "663user1...",
          "name": "Arjun Mehta",
          "email": "arjun@example.com",
          "avatar": "https://..."
        },
        "totalAmount": 300,
        "paidAmount": 0,
        "remainingAmount": 300,
        "status": "PENDING",
        "date": "2024-11-07T10:00:00.000Z"
      },
      {
        "splitId": "664abc456...",
        "friend": { "_id": "663user1...", "name": "Arjun Mehta" },
        "totalAmount": 600,
        "paidAmount": 300,
        "remainingAmount": 300,
        "status": "PARTIAL",
        "date": "2024-11-08T10:00:00.000Z"
      }
    ],
    "toReceive": [
      {
        "splitId": "664abc789...",
        "friend": {
          "_id": "663user2...",
          "name": "Rahul Verma"
        },
        "totalAmount": 500,
        "clearedAmount": 0,
        "pendingAmount": 500,
        "status": "PENDING",
        "date": "2024-11-07T10:00:00.000Z"
      },
      {
        "splitId": "664abcdef...",
        "friend": { "_id": "663user3...", "name": "Sneha Patel" },
        "totalAmount": 700,
        "clearedAmount": 700,
        "pendingAmount": 0,
        "status": "SETTLED",
        "date": "2024-11-06T10:00:00.000Z"
      }
    ]
  }
}
```

**`status` values:**
| Value | Meaning |
|-------|---------|
| `PENDING` | No payment has been made yet |
| `PARTIAL` | Some amount has been paid, remainder still outstanding |
| `SETTLED` | Fully paid — this item can be shown as "Cleared" in UI |

**UI Guidance:**
- Show `toPay` items with a **Pay** button if `status !== 'SETTLED'`
- Show `toReceive` items with a **Clear** button if `status !== 'SETTLED'`
- Show green **Cleared** badge if `status === 'SETTLED'`
- Display `remainingAmount` (toPay) or `pendingAmount` (toReceive) as the actionable figure
- The `totalAmount / someAmount` format in the design maps to `paidAmount / totalAmount`

---

## 2. Payment Recording — Payer Side

### `POST /api/collections/:id/splits/:splitId/pay`

**Who calls this:** The **payer (X)** — the person who owes money — taps the "Pay" button.

**Path Params:**
- `:id` — collection ID
- `:splitId` — the `splitId` from the balance item

**Request Body:**
```json
{
  "amount": 300,
  "note": "Paid via UPI"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `amount` | `number` | **Yes** | Amount being paid. Must be > 0 and ≤ remaining balance. |
| `note` | `string` | No | Optional memo (e.g., "Cash", "Paid via GPay") |

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Payment recorded successfully",
  "data": {
    "_id": "pay123...",
    "collectionId": "col456...",
    "splitId": "664abc123...",
    "payerId": "663userX...",
    "receiverId": "663userY...",
    "splitAmount": 600,
    "paidAmount": 300,
    "initiatedBy": "663userX...",
    "note": "Paid via UPI",
    "createdAt": "2024-11-10T14:00:00.000Z",
    "payer": { "_id": "663userX...", "name": "X" },
    "receiver": { "_id": "663userY...", "name": "Y" },
    "newRemainingAmount": 300
  }
}
```

**Validation errors (400):**
- `"You do not have a share in this split"` — splitId doesn't involve the calling user as debtor
- `"This split debt is already fully settled"` — nothing left to pay
- `"Amount must be > 0 and ≤ remaining balance of N"` — amount out of range
- `"You cannot record a payment to yourself"` — split paidBy is the same as caller

---

## 3. Payment Clearing — Receiver Side

### `POST /api/collections/:id/splits/:splitId/clear`

**Who calls this:** The **receiver (Y)** — the person who is owed money — taps the "Clear" button.  
This can be called **independently** (no need for the payer to have called `/pay` first — useful for cash settlements).

**Path Params:**
- `:id` — collection ID
- `:splitId` — the `splitId` from the balance item

**Request Body:**
```json
{
  "payerId": "663userX...",
  "amount": 500,
  "note": "Received cash"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `payerId` | `string` | **Yes** | The `_id` of the debtor being cleared. Use `friend._id` from the toReceive item. |
| `amount` | `number` | **Yes** | Amount received. Must be > 0 and ≤ pending balance. |
| `note` | `string` | No | Optional memo |

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Payment cleared successfully",
  "data": {
    "_id": "pay789...",
    "collectionId": "col456...",
    "splitId": "664abc789...",
    "payerId": "663userX...",
    "receiverId": "663userY...",
    "splitAmount": 500,
    "paidAmount": 500,
    "initiatedBy": "663userY...",
    "createdAt": "2024-11-10T15:00:00.000Z",
    "payer": { "_id": "663userX...", "name": "X" },
    "receiver": { "_id": "663userY...", "name": "Y" },
    "newRemainingAmount": 0
  }
}
```

**Validation errors (400 / 403):**
- `"Only the creditor (person who paid the split) can clear payments"` — caller is not the split's `paidBy`
- `"This user does not have a share in this split"` — payerId not in split
- `"This split debt is already fully settled"` — already cleared
- `"Amount must be > 0 and ≤ remaining balance of N"` — amount too large

---

## 4. Bulk Member Limits

### `PATCH /api/collections/:id/members/limits`

**Who calls this:** The **collection owner** only.  
Sets (or updates) the spending limit for one or more members in a single request.

**Request Body:**
```json
{
  "limits": [
    { "userId": "663userA...", "limitAmount": "5000" },
    { "userId": "663userB...", "limitAmount": "3000" },
    { "userId": "663userC...", "limitAmount": "10000" }
  ]
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `limits` | `array` | **Yes** | Array of `{ userId, limitAmount }` pairs |
| `limits[].userId` | `string` | **Yes** | Member's user ID |
| `limits[].limitAmount` | `string` | **Yes** | Limit as a string (e.g., `"5000"`) |

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Member limits updated successfully",
  "data": [
    {
      "_id": "mem1...",
      "collectionId": "col456...",
      "userId": "663userA...",
      "role": "CONTRIBUTE",
      "limitAmount": "5000",
      "user": { "_id": "663userA...", "name": "Arjun Mehta" }
    },
    {
      "_id": "mem2...",
      "collectionId": "col456...",
      "userId": "663userB...",
      "role": "VIEW",
      "limitAmount": "3000",
      "user": { "_id": "663userB...", "name": "Rahul Verma" }
    }
  ]
}
```

**Errors:**
- `403 Forbidden` — caller is not the collection owner
- `404 Not Found` — a userId in the array is not a member of the collection
- `400 Bad Request` — `limits` is empty or not an array

---

## 5. Existing Endpoints Reference

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/api/collections` | Create a collection |
| `GET` | `/api/collections` | Get user's collections |
| `GET` | `/api/collections/:id` | Get collection detail (members, splits, transactions) |
| `DELETE` | `/api/collections/:id` | Delete collection (owner only) |
| `PATCH` | `/api/collections/:id/updateCollections` | Update name / description / expiryAt |
| `PATCH` | `/api/collections/:id/closeCollection` | Close collection (owner only) |
| `POST` | `/api/collections/:id/members` | Send invitations to friends |
| `PATCH` | `/api/collections/:id/members/limits` | **NEW** Bulk set member limits (owner only) |
| `PATCH` | `/api/collections/:id/members/:memberId` | Update single member role / limit |
| `DELETE` | `/api/collections/:id/exit` | Logged-in user exits collection |
| `POST` | `/api/collections/:id/transactions` | Add transactions + create split |
| `GET` | `/api/collections/:id/available-transactions` | User's bank txns not yet in collection |
| `GET` | `/api/collections/:id/all-transactions` | All transactions in collection (paginated) |
| `GET` | `/api/collections/:id/splits` | All splits in collection |
| `PUT` | `/api/collections/:id/splits/:splitId` | Update split with custom amounts |
| `GET` | `/api/collections/:id/balances` | **UPDATED** toPay / toReceive per split with payment tracking |
| `POST` | `/api/collections/:id/splits/:splitId/pay` | **NEW** Payer records payment |
| `POST` | `/api/collections/:id/splits/:splitId/clear` | **NEW** Receiver clears payment |
| `GET` | `/api/collections/invitations/pending` | Logged-in user's pending invitations |
| `POST` | `/api/collections/invitations/:invitationId/accept` | Accept invitation |
| `POST` | `/api/collections/invitations/:invitationId/reject` | Reject invitation |
| `GET` | `/api/collections/:id/invitations` | Collection's invitations (with `?status=PENDING`) |
| `DELETE` | `/api/collections/:id/invitations/:invitationId` | Cancel invitation |

---

## 6. Full Flow Walkthrough

### Scenario: Group of 4 (Alice, Bob, Carol, Dave). Alice paid ₹1,200 for dinner.

**Step 1 — Alice adds the transaction with EQUAL split**

```
POST /api/collections/:collectionId/transactions
Body: {
  "transactionIds": ["bankTxId_abc"],
  "splitType": "EQUAL"
}
```

Each person's share: ₹300. Split doc created: `paidBy = Alice`, splits = [{Bob, 300}, {Carol, 300}, {Dave, 300}, {Alice, 300}]

---

**Step 2 — Bob checks balances**

```
GET /api/collections/:collectionId/balances
```

Response includes:
```json
"toPay": [
  {
    "splitId": "splitXYZ",
    "friend": { "name": "Alice" },
    "totalAmount": 300,
    "paidAmount": 0,
    "remainingAmount": 300,
    "status": "PENDING"
  }
]
```

---

**Step 3 — Bob pays ₹150 (partial)**

```
POST /api/collections/:collectionId/splits/splitXYZ/pay
Body: { "amount": 150, "note": "First installment" }
```

---

**Step 4 — Alice checks toReceive**

Alice's `toReceive` for Bob now shows:
```json
{
  "splitId": "splitXYZ",
  "friend": { "name": "Bob" },
  "totalAmount": 300,
  "clearedAmount": 150,
  "pendingAmount": 150,
  "status": "PARTIAL"
}
```

---

**Step 5 — Alice clears the remaining ₹150 (Bob paid cash)**

```
POST /api/collections/:collectionId/splits/splitXYZ/clear
Body: {
  "payerId": "bobUserId",
  "amount": 150,
  "note": "Cash received"
}
```

---

**Step 6 — Bob's balance is now SETTLED**

Both Bob's `toPay` and Alice's `toReceive` for this split will show `status: "SETTLED"`.  
`newRemainingAmount: 0` in the clear response confirms full settlement.

---

### Scenario: Owner sets limits for all members

```
PATCH /api/collections/:collectionId/members/limits
Body: {
  "limits": [
    { "userId": "bobId", "limitAmount": "5000" },
    { "userId": "carolId", "limitAmount": "3000" },
    { "userId": "daveId", "limitAmount": "7500" }
  ]
}
```

Returns updated member objects with user hydration.

---

## 7. Data Models Reference

### SplitPayment (new)

```typescript
{
  _id: string
  collectionId: string         // collection this payment belongs to
  splitId: string              // split being settled
  payerId: string              // the debtor
  receiverId: string           // the creditor (split.paidBy)
  splitAmount: number          // original split item amount (snapshot)
  paidAmount: number           // amount settled in this record
  initiatedBy: string          // who created this record (payer or receiver)
  note?: string
  createdAt: string
  updatedAt: string
}
```

### Balance Item — toPay

```typescript
{
  splitId: string
  friend: UserObject           // the person you owe (receiver)
  totalAmount: number          // your original share in the split
  paidAmount: number           // how much you've already paid
  remainingAmount: number      // what's still owed
  status: 'PENDING' | 'PARTIAL' | 'SETTLED'
  date: string
}
```

### Balance Item — toReceive

```typescript
{
  splitId: string
  friend: UserObject           // the person who owes you (payer)
  totalAmount: number          // their original share in the split
  clearedAmount: number        // how much they've paid so far
  pendingAmount: number        // what they still owe you
  status: 'PENDING' | 'PARTIAL' | 'SETTLED'
  date: string
}
```

### CollectionMember (with limitAmount)

```typescript
{
  _id: string
  collectionId: string
  userId: string
  role: 'VIEW' | 'CONTRIBUTE'
  limitAmount?: string         // spending limit, e.g. "5000"
  joinedAt: string
  createdAt: string
  updatedAt: string
  user: UserObject             // hydrated user data
}
```
