# Plan: Payment Research and Implementation

## Goal
Research and design a payment system for the "Automated Artist & Event Platform" (kasi_hustle) that allows for:
1. Flutter integration.
2. 10% platform commission (marketplace model).
3. Transaction cancellation/refunds.

## Research Findings
### 1. Payment Gateways for South Africa
- **Paystack (Recommended for ZA)**:
  - Robust Flutter SDK.
  - Features "Subaccounts" for automated 10% commission splitting.
  - Fees: 2.9% + R1 per transaction.
- **Flutterwave**:
  - Pan-African reach, supports "Subaccounts".
  - Good Flutter integration.
- **Stripe Connect**:
  - Best for complex marketplaces, but requires international business setup for full ZA support (indirectly via Paystack/Stripe partners).

### 2. Implementing 10% Commission
- **Direct Split**: When a user pays R100, the gateway automatically routes R90 to the "Hustler" (service provider) and R10 to the platform.
- **Managed via Subaccounts**: Each Hustler will need a linked subaccount on the gateway.

### 4. Escrow (Hold & Release) Logic
- **The Flow**:
  1. **Job Start**: Provider pays the full amount. Funds are captured by the platform but NOT paid out to the Hustler immediately.
  2. **Holding State**: Transaction is recorded in Supabase as `escrowed` or `pending_completion`.
  3. **Verification**: 
     - Hustler marks job as `finished`.
     - Provider clicks `confirm`.
  4. **The Split**: Once both sides confirm, a Supabase Edge Function triggers the **Transfer API** (Paystack) or **Settlement API** (Flutterwave) to:
     - Release 90% to the Hustler's linked bank account/wallet.
     - Keep 10% in the platform's balance.

### 5. Cancellation Policy (10% Platform Fee)
- **Scenario**: Job provider cancels the job after payment but before completion.
- **Logic**:
  1. **Void/Refund**: The platform triggers a partial refund via the gateway.
  2. **The Split (Cancellation)**:
     - **90%** is returned to the original payment method (Job Provider).
     - **10%** is retained by the platform as a cancellation fee/commission.
- **Implementation**: Supabase Edge Function calls the gateway's `Refund` API with the specific amount (90% of original).

### 6. Card Management (Adding & Verifying)
- **Tokenization**: Both gateways support saving card "tokens" (Authorization Codes in Paystack, Tokens in Flutterwave) after the first successful charge.
- **Verification**: 
  - The first time a user adds a card, we process a small charge (or the first job payment) to verify.
  - Verification includes 3D Secure (OTP) for security.
  - Once verified, the user can pay for future jobs with "One-Click" using the saved token.

### 7. UI & PCI Compliance (Security)
- **Hosted UI (Recommended)**: Both Paystack and Flutterwave provide a "Standard/Checkout" UI.
  - **Benefit**: You don't have to build the card form. The SDK shows a secure modal or page.
  - **PCI Compliance**: Since the card details never touch your code/server directly, your security requirements are much simpler (SAQ A).
- **Custom UI**: Possible but **NOT recommended**. You would need to handle raw card data, which requires high-level PCI DSS certification and extreme security audits.

## Proposed Implementation Architecture
1. **Supabase Integration**: 
   - New `transactions` table with `status` (pending, escrowed, completed, cancelled).
   - `hustler_accounts` table to store linked subaccount IDs.
   - `saved_payment_methods` table to store card tokens (never raw numbers).
2. **Edge Functions**: 
   - `initialize-payment`: Setup the transaction or verify a new card.
   - `release-funds`: Securely trigger the payout once verification is complete.
   - `handle-refund`: Process the 90/10 split on cancellation.
3. **Wallet UI Updates**: 
   - "Manage Cards" screen to add/delete tokens.
   - "Funds in Escrow" vs "Available Balance" display.
   - "Confirm Job Done" button for the provider.
