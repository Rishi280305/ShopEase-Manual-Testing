# ShopEase – Requirement Traceability Matrix (RTM)
**What is an RTM?** A table that links each requirement to the test cases that check it, and to the database queries that prove the result. It shows that no requirement is left untested, and which tests to repeat when a requirement changes.
Requirement IDs (FR-xx) and business rules (BR-xx) are defined in `requirements/requirements_and_business_rules.md`. Query IDs (Qxx) are in `sql/03_validation_queries.sql` and explained in `docs/sql_query_guide.md`.
> Execution status is **not** stored here. All test cases are **Not Executed** until you run them. Track status in `ShopEase_QA_Workbook.xlsx` (Execution Tracker).
## Worked example: what to verify after placing an order (TC_ORD_01)
Business rules used to judge correctness (defined before testing): BR-09 to BR-11 (amounts), BR-15 (statuses), BR-16 (stock).
| Step | What you check | Query | Correct state |
|---|---|---|---|
| 1 | The order exists | Q22 (by order number) | 1 order, status CONFIRMED for UPI success, PLACED for COD |
| 2 | Order items are right | Q22, Q19 | Every product and quantity from the cart is present; no order without items |
| 3 | Amounts add up | Q16, Q17, Q18 | 0 rows (subtotal, 18% GST, shipping, discount and total all agree) |
| 4 | Payment record matches | Q23, Q24, Q28, Q41 | 1 payment row, same amount, SUCCESS with transaction ID (UPI) or PENDING with no transaction ID (COD) |
| 5 | Inventory updated | Q34 (before and after) | quantity_available = value before minus ordered quantity |
| 6 | No duplicates or orphans | Q30, Q43, Q46 | 0 rows / all counts 0 |
## Coverage by requirement
| Requirement | Module | Test cases mapped |
|---|---|---|
| FR-01 | User Registration | 10 (REG_01, REG_02, REG_03, REG_04, REG_05, REG_06...) |
| FR-02 | Login and Logout | 8 (LOG_01, LOG_02, LOG_03, LOG_04, LOG_05, LOG_06...) |
| FR-03 | Product Search | 5 (SRC_01, SRC_02, SRC_03, SRC_04, E2E_01) |
| FR-04 | Categories and Product Details | 5 (CAT_01, CAT_02, CAT_03, CAT_04, E2E_01) |
| FR-05 | Shopping Cart | 6 (CRT_01, CRT_02, CRT_03, CRT_04, CRT_05, E2E_01) |
| FR-06 | Quantity Updates | 6 (QTY_01, QTY_02, QTY_03, QTY_04, QTY_05, E2E_01) |
| FR-07 | Checkout | 5 (CHK_01, CHK_02, CHK_03, CHK_04, E2E_01) |
| FR-08 | Address Validation | 6 (ADR_01, ADR_02, ADR_03, ADR_04, ADR_05, E2E_01) |
| FR-09 | Order Placement | 7 (ORD_01, ORD_02, ORD_03, ORD_04, E2E_01, E2E_02...) |
| FR-10 | Payment Status Simulation | 8 (PAY_01, PAY_02, PAY_03, PAY_04, PAY_05, E2E_01...) |
| FR-11 | Order History | 4 (HIS_01, HIS_02, HIS_03, E2E_01) |
| FR-12 | Order Cancellation | 6 (CAN_01, CAN_02, CAN_03, CAN_04, CAN_05, E2E_02) |
| FR-13 | Inventory Validation | 6 (INV_01, INV_02, INV_03, INV_04, E2E_02, E2E_03) |

## Full traceability matrix
| Requirement ID | Test Case ID | Manual test | Related database table | SQL validation query ID | Expected database state |
|---|---|---|---|---|---|
| FR-01 (BR-01, BR-02, BR-03) | TC_REG_01 | Register with valid details | customers | Q01, Q02, Q03, Q44 | 1 new customers row; status ACTIVE; failed_login_attempts 0; password_hash is not plain text |
| FR-01 (BR-01) | TC_REG_02 | Register with an already registered email | customers | Q02 | Row count unchanged; no duplicate email |
| FR-01 (BR-01) | TC_REG_03 | Register with an already registered phone number | customers | Q03 | Row count unchanged; no duplicate phone |
| FR-01 (BR-01) | TC_REG_04 | Invalid email formats are rejected | customers | Q04 | No new row; no invalid email stored |
| FR-01 | TC_REG_05 | Mandatory fields left blank | customers | Q39, Q44 | No new row; no blank mandatory value stored |
| FR-01 (BR-02) | TC_REG_06 | Weak passwords are rejected (password policy) | customers | Q44 | No new row for each weak password |
| FR-01 (BR-02) | TC_REG_07 | Password length boundary values | customers | Q44 | New rows only for 8 and 20 character passwords; none for 7 and 21 |
| FR-01 (BR-02) | TC_REG_08 | Confirm password does not match | customers | Q44 | No new row |
| FR-01 (BR-01) | TC_REG_09 | Phone number validation | customers | Q39, Q44 | No new row; stored phones are all 10 digits starting 6-9 |
| FR-02 | TC_LOG_01 | Login with valid credentials | customers | Q06 | last_login_at updated; failed_login_attempts = 0 |
| FR-02 (BR-04) | TC_LOG_02 | Login with wrong password | customers | Q06 | failed_login_attempts increased by 1; status still ACTIVE |
| FR-02 | TC_LOG_03 | Login with unregistered email | customers | Q44 | No change in any table |
| FR-02 | TC_LOG_04 | Login with blank fields | customers | Q06 | No change in failed_login_attempts |
| FR-02 (BR-04) | TC_LOG_05 | Account locks after 5 wrong passwords (boundary 4 vs 5) | customers | Q06 | After 4 failures status ACTIVE; after the 5th status BLOCKED |
| FR-02 (BR-04) | TC_LOG_06 | Blocked and inactive users cannot log in | customers | Q06 | Status remains BLOCKED / INACTIVE; last_login_at unchanged |
| FR-02 | TC_LOG_07 | Logout ends the session | None (session only) | - | No database change; verify by UI |
| FR-03 (BR-05) | TC_SRC_01 | Search is case-insensitive | products | Q10 | Read-only; result matches products with name containing 'headphones' |
| FR-03 | TC_SRC_02 | Search with no matching product | products | - | No database change |
| FR-03 (BR-05) | TC_SRC_03 | Search keyword length boundary | products | - | No database change |
| FR-03 | TC_SRC_04 | Unsafe text in the search box is treated as plain text | all tables | Q44 | Row counts of all tables unchanged (no injection effect) |
| FR-04 (BR-06) | TC_CAT_01 | Parent category shows sub-category products | categories, products | Q10 | UI count for Electronics equals Q10 (6 on sample data) |
| FR-04 | TC_CAT_02 | Product details page shows correct data | products | Q07, Q08, Q09, Q11 | UI price, MRP and discount % equal database values |
| FR-04 (BR-07) | TC_CAT_03 | Out-of-stock product cannot be purchased | products, inventory | Q31 | Smart Watch Pro quantity_available = 0 |
| FR-04 (BR-07) | TC_CAT_04 | Low-stock message | products, inventory | Q31 | PowerMax Power Bank quantity_available = 8 (<= reorder level) |
| FR-05 | TC_CRT_01 | Add a product to cart | carts, cart_items | Q12, Q14 | 1 cart_items row for the product, quantity 1, unit_price 1499.00 |
| FR-05 | TC_CRT_02 | Adding the same product twice increases quantity | cart_items | Q12 | Still one cart_items row for the product, quantity 2 |
| FR-05 | TC_CRT_03 | Remove an item from the cart | cart_items | Q12 | Removed product row is gone; remaining total matches the UI |
| FR-05 | TC_CRT_04 | Cart is saved after logout and login | carts, cart_items | Q12, Q13 | Same cart_items rows; one ACTIVE cart per customer |
| FR-05 | TC_CRT_05 | Empty cart behaviour | carts, cart_items | Q12 | Cart has no cart_items rows |
| FR-06 | TC_QTY_01 | Increase quantity updates totals | cart_items | Q12 | quantity = 3; cart value updated |
| FR-06 (BR-08) | TC_QTY_02 | Maximum quantity per order boundary | cart_items, products | Q15 | quantity = 10 allowed; 11 never stored |
| FR-06 (BR-08) | TC_QTY_03 | Minimum quantity boundary | cart_items | Q15 | No row with quantity below 1 |
| FR-06 (BR-08) | TC_QTY_04 | Quantity cannot exceed available stock | cart_items, inventory | Q15 | quantity 8 stored; 9 never stored |
| FR-06 | TC_QTY_05 | Invalid quantity input | cart_items | Q15 | Quantity unchanged after invalid input |
| FR-07 | TC_CHK_01 | Checkout requires login | None (session only) | - | No order or cart change |
| FR-07 (BR-09, BR-10, BR-11) | TC_CHK_02 | Price summary is calculated correctly | carts, cart_items | Q12, Q16, Q17 | Cart value 2697.00 equals checkout subtotal; later order total equals 3182.46 |
| FR-07 (BR-10) | TC_CHK_03 | Shipping fee boundary around Rs.500 | orders | Q18 | Order of 250 has shipping_fee 40; order of 500 has shipping_fee 0 |
| FR-07 | TC_CHK_04 | Price change after adding to cart | cart_items, products | Q14 | Checkout uses products.price; Q14 shows no stale price after refresh |
| FR-08 (BR-12) | TC_ADR_01 | Add a valid new address | addresses | Q47, Q39 | 1 new addresses row linked to the logged-in customer |
| FR-08 | TC_ADR_02 | Mandatory address fields blank | addresses | Q39 | No new row |
| FR-08 (BR-12) | TC_ADR_03 | Pincode validation and boundary | addresses | Q39 | Only the 517501 address is stored |
| FR-08 | TC_ADR_04 | Default address is pre-selected | addresses, orders | Q05, Q20 | Exactly one default address per customer; order uses chosen address |
| FR-08 (BR-18) | TC_ADR_05 | User cannot use another customer's address | orders, addresses | Q20 | No order exists whose address belongs to another customer |
| FR-09 | TC_ORD_01 | Place an order successfully | orders, order_items, payments, inventory | Q16, Q19, Q22, Q23, Q24, Q34 | 1 order, correct items, 1 payment with equal amount, stock reduced by ordered quantity |
| FR-09 | TC_ORD_02 | Double click on Place Order | orders, order_items, payments | Q30, Q46, Q23 | Exactly one new order; no duplicate lines or transactions; stock reduced once |
| FR-09 | TC_ORD_03 | Refresh or Back after order placement | orders | Q23, Q46 | Order count unchanged after refresh/back |
| FR-09 (BR-16) | TC_ORD_04 | Product becomes out of stock before payment | inventory, orders | Q32, Q44 | No new order or payment row; stock stays 0, not negative |
| FR-10 (BR-15) | TC_PAY_01 | UPI payment success | orders, payments | Q28, Q41 | Order CONFIRMED; payment SUCCESS with transaction_id and paid_at |
| FR-10 (BR-15, BR-16) | TC_PAY_02 | Card payment fails | orders, payments, inventory | Q27, Q41, Q34 | Order PAYMENT_FAILED; payment FAILED with reason; stock unchanged |
| FR-10 (BR-13, BR-15) | TC_PAY_03 | COD within the limit | orders, payments, inventory | Q29, Q42 | Order PLACED; payment PENDING; transaction_id NULL; stock reduced |
| FR-10 (BR-13) | TC_PAY_04 | COD not available above Rs.10,000 | orders | Q29 | No COD order above 10000 |
| FR-10 | TC_PAY_05 | Invalid card details | payments | Q23 | No payment row created |
| FR-11 (BR-18) | TC_HIS_01 | Order history shows only own orders, newest first | orders | Q21 | UI list equals the Q21 result for that customer |
| FR-11 | TC_HIS_02 | Order details match the database | orders, order_items, products, addresses, payments | Q22 | Every UI field equals the Q22 row values |
| FR-11 (BR-18) | TC_HIS_03 | Cannot open another user's order by changing the URL | orders | Q20 | No data change; access denied for another customer's order |
| FR-12 (BR-17) | TC_CAN_01 | Cancel a PLACED COD order | orders, payments, inventory | Q26, Q34, Q40 | Order CANCELLED with cancelled_at and reason; payment CANCELLED; stock restored |
| FR-12 (BR-17) | TC_CAN_02 | Cancel a CONFIRMED prepaid order | orders, payments, inventory | Q25, Q34, Q40 | Order CANCELLED; payment REFUNDED; stock restored |
| FR-12 (BR-17) | TC_CAN_03 | Shipped and delivered orders cannot be cancelled | orders | Q40 | SHIPPED and DELIVERED orders keep status; cancelled_at stays NULL |
| FR-12 (BR-17) | TC_CAN_04 | Cancelling an already cancelled order | orders, payments, inventory | Q25, Q34 | Stock restored once only; payment not refunded twice |
| FR-12 | TC_CAN_05 | Cancellation reason is mandatory | orders | Q40 | No cancellation stored without a reason |
| FR-13 (BR-16) | TC_INV_01 | Stock reduces by the ordered quantity | inventory, order_items | Q34, Q32 | quantity_available reduced by exactly the ordered quantity (2) |
| FR-13 (BR-16) | TC_INV_02 | Failed payment does not reduce stock | inventory, orders | Q34, Q27 | Stock equals value noted before the test |
| FR-13 (BR-16) | TC_INV_03 | Last unit bought by two users at the same time | inventory, orders | Q32 | One new order only; stock = 0 and never negative |
| FR-13 | TC_INV_04 | Database blocks negative stock | inventory | Q32 | MySQL rejects the UPDATE; stock unchanged |
| FR-01 to FR-11 | TC_E2E_01 | Complete purchase with UPI | customers, carts, cart_items, orders, order_items, payments, inventory | Q01, Q16, Q19, Q22, Q23, Q24, Q28, Q34, Q43, Q45, Q48 | Order CONFIRMED; items, amounts, payment and stock all consistent; all CHECK queries return 0 rows |
| FR-09, FR-10, FR-12, FR-13 | TC_E2E_02 | COD order then cancellation | orders, payments, inventory | Q26, Q34, Q40 | PLACED/PENDING then CANCELLED/CANCELLED; stock back to the start value |
| FR-09, FR-10, FR-13 | TC_E2E_03 | Failed payment then successful retry | orders, payments, inventory | Q19, Q23, Q27, Q28, Q34 | One order ends CONFIRMED; one payment SUCCESS; stock reduced once |

## Queries not tied to one test case
Q08 and Q09 are covered through TC_CAT_02. Q33, Q35, Q36, Q37, Q38 are report queries used to check dashboards and reports; run them in every test cycle and compare with the reports you see. Q43, Q44, Q45, Q48 are integrity checks run at the end of every cycle and after every end-to-end test.
