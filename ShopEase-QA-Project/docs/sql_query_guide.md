# ShopEase – SQL Validation Query Guide
This guide explains all 48 queries in `sql/03_validation_queries.sql`. Each query has four notes: **What it validates**, **Why a QA tester needs it**, **Correct result**, **What a defect would mean**.
## Simple SQL checking idea
A CHECK query is written so that it returns only the *wrong* rows. If it returns **0 rows**, the data is correct. A REPORT query returns numbers that you compare with what you see on the screen. A VERIFY query is run before and after a manual test.
## How the queries were checked (honest status)
- No MySQL server was available while preparing this project. The scripts were **not executed in MySQL**.
- The scripts were run through a translation into **SQLite** to catch wrong table or column names and to see rows returned. In that run: foreign key check found no problems; all CHECK queries returned 0 rows on the clean data; the planted bugs of `04_inject_defects_for_practice.sql` were caught by Q04, Q06, Q14, Q16, Q18, Q24, Q25 as designed.
- SQLite is not MySQL. Examples below marked 'SQLite run' are real outputs from that run, but MySQL formatting (for example `2697.00` instead of `2697`) will differ. Q11 is hand-calculated because SQLite divides integers differently.
- **Run the scripts in your own MySQL 8.0.16+ and treat your own results as the real evidence.**
## Queries grouped by purpose
| Purpose | Query IDs |
|---|---|
| Customer data validation | Q01, Q04, Q05, Q06, Q39 |
| Product and price validation | Q07, Q08, Q09, Q11 |
| Cart validation | Q12, Q13, Q14, Q15 |
| Order and order-item validation | Q16, Q17, Q18, Q19, Q20, Q46 |
| Payment status validation | Q25, Q26, Q27, Q28, Q29, Q41, Q42, Q48 |
| Inventory validation | Q31, Q32, Q33, Q34 |
| Duplicate records checks | Q02, Q03, Q30, Q46, Q47 |
| NULL value checks | Q39, Q40, Q41, Q42 |
| Total order amount verification | Q16, Q17, Q18, Q24 |
| Cancelled orders | Q25, Q26, Q40 |
| Orders without matching payment records | Q23 |
| Products with low inventory | Q31 |
| JOIN queries | Q10, Q22, Q38 (and most checks above) |
| GROUP BY and aggregate queries | Q10, Q12, Q33, Q35, Q36, Q37, Q44 |
| Data integrity checks | Q20, Q43, Q44, Q45, Q48 |

## Query-by-query explanation

### Q01 – Verify a newly registered customer
- **What it validates:** The new customer row exists with correct name, email, phone, status ACTIVE and a hashed password.
- **Why a QA tester needs it:** After TC_REG_01 the screen says 'Registered', but only the database proves the data was really saved correctly.
- **Correct result:** 1 row; status ACTIVE; failed_login_attempts 0; password_hash is not the plain password. (0 rows on the untouched sample data, because Anitha is created only when you run TC_REG_01.)
- **Defect meaning:** 0 rows after a successful registration means data was not saved. A readable password in password_hash is a Critical security defect.

### Q02 – Duplicate emails
- **What it validates:** No two customers share the same email (ignoring upper/lower case).
- **Why a QA tester needs it:** Duplicate accounts break login and let one person register twice.
- **Correct result:** 0 rows.
- **Defect meaning:** Rows returned mean the app allows duplicate registration (see TC_REG_02).

### Q03 – Duplicate phone numbers
- **What it validates:** No two customers share a phone number.
- **Why a QA tester needs it:** Phone is used for contact and order calls; duplicates cause wrong-customer issues.
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean the phone uniqueness rule (BR-01) is not enforced.

### Q04 – Invalid email format
- **What it validates:** Every stored email looks like name@domain.ext.
- **Why a QA tester needs it:** The UI may validate, but an API or old data may still store bad emails.
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean invalid emails reached the database; validation is missing on the server side (TC_REG_04).

### Q05 – Default address per active customer
- **What it validates:** Each ACTIVE customer has exactly one default address.
- **Why a QA tester needs it:** Checkout pre-selects the default address. Zero or two defaults confuses the page (TC_ADR_04).
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean the app saved two defaults or none.

### Q06 – Account-lock rule
- **What it validates:** No account has 5+ failed logins and still stays unblocked.
- **Why a QA tester needs it:** Proves the brute-force protection (BR-04) really works in the data.
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean lock-out is not applied (TC_LOG_05); a security defect.

### Q07 – Price greater than MRP
- **What it validates:** Selling price is never above MRP.
- **Why a QA tester needs it:** A price above MRP shows a negative discount and is a legal/pricing risk.
- **Correct result:** 0 rows (the CHECK constraint also blocks it).
- **Defect meaning:** Rows mean wrong price data or a missing constraint.

### Q08 – Active product without inventory
- **What it validates:** Every active product has an inventory row.
- **Why a QA tester needs it:** Without a row the product page cannot show stock status.
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean the product shows wrong stock or errors on the page.

### Q09 – Active product in an inactive category
- **What it validates:** Active products are not hidden inside inactive categories.
- **Why a QA tester needs it:** Such products are visible in search but missing from category pages.
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean inconsistent catalogue data.

### Q10 – Product count per main category (REPORT)
- **What it validates:** Count of active products per main category, with sub-category products rolled up.
- **Why a QA tester needs it:** Compare with the category page count (TC_CAT_01).
- **Correct result:** Example (from the SQLite practice run): Books 2, Electronics 6, Fashion 3, Home & Kitchen 2.
- **Defect meaning:** UI count different from this count means products are missing or wrongly shown.

### Q11 – Discount percentage per product (REPORT)
- **What it validates:** Discount % = (MRP - price) / MRP x 100, rounded.
- **Why a QA tester needs it:** The '17% off' label on the product page must come from correct arithmetic (TC_CAT_02).
- **Correct result:** Hand-calculated example, not an executed output: Nova X5 17, Nova Lite 10, SoundMax 50, ChargePro 40, PowerMax 33, T-shirt 50, Kurti 42, Shoes 43, Bottle 30, Cookware 40, SQL book 25, Smart Watch 50, Notebook 17. (SQLite does integer division and shows 0, which is a SQLite behaviour, not a MySQL result.)
- **Defect meaning:** UI percentage different from this value means a calculation or rounding defect.

### Q12 – Cart summary (REPORT)
- **What it validates:** Number of lines, units and value of each cart.
- **Why a QA tester needs it:** Compare with the cart page totals (TC_CRT_01, TC_QTY_01).
- **Correct result:** Example (SQLite run): cart 1 has 2 lines, 3 units, 2197; cart 2: 1 line, 1999; cart 3: 2 lines, 1147; cart 4: 1 line, 2999.
- **Defect meaning:** UI cart total different from this value means a cart calculation defect.

### Q13 – More than one ACTIVE cart
- **What it validates:** Each customer has at most one ACTIVE cart.
- **Why a QA tester needs it:** Two active carts means items 'disappear' for the user.
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean the app creates a new cart on every login.

### Q14 – Cart price differs from current price
- **What it validates:** Active cart prices match the current product price.
- **Why a QA tester needs it:** Shows whether the cart refreshes after a price change (TC_CHK_04).
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean the customer may be charged an outdated price.

### Q15 – Cart quantity over limit or stock
- **What it validates:** No active cart line exceeds max-per-order or available stock.
- **Why a QA tester needs it:** Proves quantity rules (BR-08) are enforced in saved data (TC_QTY_02, TC_QTY_04).
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean limits are checked only on screen, not on the server.

### Q16 – Order total verification
- **What it validates:** subtotal = sum of items; total = subtotal + shipping + GST - discount.
- **Why a QA tester needs it:** The most important money check. A single wrong total is a Critical defect.
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean customers are charged wrongly (TC_CHK_02, TC_ORD_01).

### Q17 – GST calculation
- **What it validates:** tax_amount = 18% of subtotal (rounded to 2 decimals).
- **Why a QA tester needs it:** Tax errors are a financial and legal risk.
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean GST is calculated wrongly.

### Q18 – Shipping fee rule
- **What it validates:** Shipping is Rs.40 below Rs.500 and free from Rs.500.
- **Why a QA tester needs it:** The boundary (Rs.499.99 vs Rs.500) is a classic place for bugs (TC_CHK_03).
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean the shipping boundary is wrong.

### Q19 – Orders without items
- **What it validates:** Every order has at least one order item.
- **Why a QA tester needs it:** An order with no items cannot be shipped but may be charged.
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean a partially saved order (header saved, items failed).

### Q20 – Address belongs to the same customer
- **What it validates:** The shipping address of an order belongs to the order's customer.
- **Why a QA tester needs it:** Prevents sending parcels to another user's address (TC_ADR_05).
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean a security defect (IDs not checked on the server).

### Q21 – Order history of one customer (REPORT)
- **What it validates:** All orders of customer 1, newest first.
- **Why a QA tester needs it:** Compare with the My Orders page (TC_HIS_01).
- **Correct result:** Example (SQLite run): SE-20261005-0006 (CONFIRMED, 1734.46) then SE-20260915-0001 (DELIVERED, 3182.46).
- **Defect meaning:** Missing, extra or wrongly sorted orders on the page are defects.

### Q22 – Full order detail (REPORT)
- **What it validates:** Joins 6 tables to show one order as the customer sees it.
- **Why a QA tester needs it:** Lets you compare every field of the Order Details page with the database (TC_HIS_02, TC_E2E_01).
- **Correct result:** Example (SQLite run): 2 rows for SE-20260915-0001 (SoundMax x1 1499 and ChargePro x2 1198), total 3182.46, payment SUCCESS, TXN260915000101.
- **Defect meaning:** Any field different from the UI is a defect.

### Q23 – Orders without a payment record
- **What it validates:** Every order has a payment row.
- **Why a QA tester needs it:** An order without payment cannot be reconciled with money received.
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean payment record creation failed (TC_ORD_01).

### Q24 – Payment amount equals order total
- **What it validates:** payments.amount = orders.total_amount.
- **Why a QA tester needs it:** Amount mismatch means under- or over-charging.
- **Correct result:** 0 rows.
- **Defect meaning:** Rows are Critical money defects.

### Q25 – Cancelled prepaid orders are refunded
- **What it validates:** CANCELLED online orders have payment_status REFUNDED.
- **Why a QA tester needs it:** Customers must get money back (TC_CAN_02).
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean refund was never marked.

### Q26 – Cancelled COD orders
- **What it validates:** CANCELLED COD orders have payment_status CANCELLED.
- **Why a QA tester needs it:** COD has no money to refund, so the pending payment must be closed (TC_CAN_01).
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean a dangling PENDING or wrong payment state.

### Q27 – Failed payments
- **What it validates:** PAYMENT_FAILED orders have payment_status FAILED.
- **Why a QA tester needs it:** Order status and payment status must agree (TC_PAY_02).
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean inconsistent status handling.

### Q28 – Confirmed prepaid orders are paid
- **What it validates:** CONFIRMED/SHIPPED/DELIVERED online orders have payment SUCCESS.
- **Why a QA tester needs it:** Prevents shipping goods that were never paid for (TC_PAY_01).
- **Correct result:** 0 rows.
- **Defect meaning:** Rows are Critical: goods shipped without payment.

### Q29 – COD limit
- **What it validates:** No COD order is above Rs.10,000.
- **Why a QA tester needs it:** Business rule BR-13 (TC_PAY_04).
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean the COD limit is not enforced on the server.

### Q30 – Duplicate transaction IDs
- **What it validates:** A transaction ID appears only once.
- **Why a QA tester needs it:** A repeated ID means double processing of one payment.
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean duplicate payment records (TC_ORD_02).

### Q31 – Low and out-of-stock products (REPORT)
- **What it validates:** Products whose stock is at or below the reorder level.
- **Why a QA tester needs it:** Compare with 'Out of Stock' and 'Only N left' labels (TC_CAT_03, TC_CAT_04).
- **Correct result:** Example (SQLite run): Smart Watch Pro stock 0 (OUT OF STOCK) and PowerMax Power Bank stock 8 (LOW STOCK).
- **Defect meaning:** UI label different from the data is a defect.

### Q32 – Negative stock
- **What it validates:** No product has negative stock.
- **Why a QA tester needs it:** Negative stock means overselling (TC_INV_03).
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean stock was reduced without checking availability.

### Q33 – Units sold per product (REPORT)
- **What it validates:** Units in orders that are not CANCELLED or PAYMENT_FAILED.
- **Why a QA tester needs it:** Cross-check of stock movement and sales reports.
- **Correct result:** Example (SQLite run): T-shirt 3, ChargePro 2, Kurti 2, SQL book 2; Nova Lite, RunFast Shoes, Smart Watch, Notebook 0.
- **Defect meaning:** Sales numbers that include cancelled orders are a reporting defect.

### Q34 – Stock check for one order (VERIFY)
- **What it validates:** Shows ordered quantity next to current stock for one order.
- **Why a QA tester needs it:** Use it before and after tests to prove stock moves correctly (TC_INV_01, TC_CAN_01).
- **Correct result:** Example (SQLite run, before any test): order SE-20261022-0003 shows T-shirt qty 2 with stock 150 and Water Bottle qty 1 with stock 120. After TC_CAN_01 the stock should be higher.
- **Defect meaning:** Stock not changing, or changing twice, is a defect.

### Q35 – Orders by status (REPORT)
- **What it validates:** Count and value of orders per status.
- **Why a QA tester needs it:** Compare with admin dashboards; shows if any status is stuck.
- **Correct result:** Example (SQLite run): DELIVERED 3, CANCELLED 2, SHIPPED 1, PLACED 1, PAYMENT_FAILED 1, CONFIRMED 1.
- **Defect meaning:** A dashboard figure that differs from this is a reporting defect.

### Q36 – Monthly revenue (REPORT)
- **What it validates:** Revenue of CONFIRMED, SHIPPED and DELIVERED orders per month.
- **Why a QA tester needs it:** Finance report check; cancelled and failed orders must not count.
- **Correct result:** Example (SQLite run): 2026-09: 4 orders, 25164.56; 2026-10: 1 order, 1734.46.
- **Defect meaning:** Revenue including cancelled orders is a defect.

### Q37 – Top customers by spend (REPORT)
- **What it validates:** Customers ranked by total spend on earning orders.
- **Why a QA tester needs it:** Marketing and loyalty reports depend on it.
- **Correct result:** Example (SQLite run): Sneha Reddy 17698.82, Ravi Kumar 4916.92, Lakshmi Devi 3772.46, Priya Nair 510.82.
- **Defect meaning:** Wrong ranking means a wrong join or filter.

### Q38 – Customers who never ordered (REPORT)
- **What it validates:** Customers without any order (LEFT JOIN example).
- **Why a QA tester needs it:** Useful to understand JOIN types and for follow-up campaigns.
- **Correct result:** Example (SQLite run): Karthik Rao (BLOCKED) and Anita Desai (INACTIVE).
- **Defect meaning:** A customer who ordered but appears here means a broken link between orders and customers.

### Q39 – NULL or blank mandatory fields
- **What it validates:** No customer or address has NULL or empty mandatory text.
- **Why a QA tester needs it:** Spaces-only values can pass weak UI validation (TC_REG_05, TC_ADR_02).
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean blank data is accepted.

### Q40 – Cancellation columns
- **What it validates:** CANCELLED orders have cancelled_at and reason; other orders have no cancelled_at.
- **Why a QA tester needs it:** Audit trail of cancellations (TC_CAN_01, TC_CAN_05).
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean cancellation details are missing or wrongly set.

### Q41 – Payment columns by status
- **What it validates:** SUCCESS or REFUNDED online payments have transaction ID and paid_at; FAILED has a reason.
- **Why a QA tester needs it:** Needed for payment reconciliation and support calls.
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean incomplete payment records (TC_PAY_01, TC_PAY_02).

### Q42 – COD payment columns
- **What it validates:** COD payments have no transaction ID and are not SUCCESS before delivery.
- **Why a QA tester needs it:** COD money is collected only at delivery (TC_PAY_03).
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean COD is treated like an online payment.

### Q43 – Orphan records
- **What it validates:** Counts of child rows whose parent is missing.
- **Why a QA tester needs it:** Foreign keys should prevent this; the check proves the data is clean (also useful when data is imported).
- **Correct result:** 5 rows, every bad_rows = 0.
- **Defect meaning:** Any number above 0 is a data integrity defect.

### Q44 – Row counts after data load (VERIFY)
- **What it validates:** Row count of each table.
- **Why a QA tester needs it:** Confirms that the sample data loaded fully before you start testing.
- **Correct result:** Expected: customers 8, addresses 9, categories 6, products 13, inventory 13, carts 4, cart_items 6, orders 9, order_items 13, payments 9 (matched in the SQLite run).
- **Defect meaning:** A different count means a failed or partial data load.

### Q45 – Date logic
- **What it validates:** No order is placed before the customer registered or cancelled before it was placed.
- **Why a QA tester needs it:** Timestamps show system clock or logic errors.
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean wrong timestamps.

### Q46 – Duplicate order items
- **What it validates:** A product appears once per order.
- **Why a QA tester needs it:** Duplicate lines double-count quantity and money (TC_ORD_02).
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean the order was saved twice.

### Q47 – Duplicate addresses
- **What it validates:** The same address is not saved twice for one customer.
- **Why a QA tester needs it:** Clutters the address book (TC_ADR_01).
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean no duplicate protection.

### Q48 – Payment method consistency
- **What it validates:** Payment method on the payment row matches the order.
- **Why a QA tester needs it:** Wrong method breaks refund routing.
- **Correct result:** 0 rows.
- **Defect meaning:** Rows mean order and payment records disagree.

## Which queries catch the planted bugs (`04_inject_defects_for_practice.sql`)
| Planted bug | Caught by |
|---|---|
| Order total changed | Q16, Q24 |
| Wrong shipping fee on a large order | Q18, Q16 |
| Cancelled prepaid order shows SUCCESS payment | Q25 |
| Invalid email stored | Q04 |
| Account not locked after 6 failed logins | Q06 |
| Cart price not refreshed | Q14 |
