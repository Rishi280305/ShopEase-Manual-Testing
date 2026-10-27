# ShopEase – Sample Defect Reports
> **SIMULATED SAMPLES.** These 10 defects were written to teach bug reporting. They were **not** found by running tests against a real application. Bug IDs start with `S` (sample). When you find real defects, use IDs like `BUG-001` and set Type = ACTUAL in the workbook.
## Severity vs Priority
| | Severity | Priority |
|---|---|---|
| Question answered | How badly does the defect hurt the system or the business? | How soon should it be fixed? |
| Decided by | Usually the tester (technical and business impact) | Usually the product owner or manager (urgency, release date, customers) |
| Levels used here | Critical, High, Medium, Low | High, Medium, Low |
| Can they differ? | Yes | Yes |
**Examples that show the difference**
- *High severity, low priority:* a crash in a feature almost nobody uses (e.g. a hidden admin report). Big damage, but little urgency.
- *Low severity, high priority:* the brand name misspelled on the home page (BUG-S10). No function is broken, but every customer sees it, so it is fixed fast.
- *Critical severity, high priority:* order shown CONFIRMED after the payment failed (BUG-S04). Money and trust are at risk, fix immediately.
**Severity guide used in this project:** Critical = money or data loss, system unusable. High = major feature broken. Medium = feature partly wrong, a workaround exists. Low = cosmetic.
## Summary table
| Bug ID | Summary | Module | Severity | Priority | Linked test | SQL evidence |
|---|---|---|---|---|---|---|
| BUG-S01 | Cart subtotal wrong after increasing quantity | Quantity Updates | High | High | TC_QTY_01 | Q12 |
| BUG-S02 | Stock not reduced after a successful order | Inventory Validation | High | High | TC_INV_01 | Q34, Q32 |
| BUG-S03 | Checkout accepts pincode starting with 0 | Address Validation | Medium | Medium | TC_ADR_03 | Q39 (and review addresses table) |
| BUG-S04 | Order shows CONFIRMED after card payment failed | Payment Status Simulation | Critical | High | TC_PAY_02 | Q27, Q28 |
| BUG-S05 | Double click on Place Order creates two orders | Order Placement | High | High | TC_ORD_02 | Q46, Q30, Q34 |
| BUG-S06 | Cash on Delivery offered for order above Rs.10,000 | Payment Status Simulation | High | Medium | TC_PAY_04 | Q29 |
| BUG-S07 | Account not blocked after 5 wrong passwords | Login and Logout | High | High | TC_LOG_05 | Q06 |
| BUG-S08 | Cancelled prepaid order is not refunded | Order Cancellation | Critical | High | TC_CAN_02 | Q25, Q40 |
| BUG-S09 | Shipping fee charged when subtotal is exactly Rs.500 | Checkout | Medium | Medium | TC_CHK_03 | Q18, Q16 |
| BUG-S10 | Brand name misspelled in site header | Product Search | Low | High | TC_SRC_01 | None (UI text only) |

## Defect reports

### BUG-S01 – Cart subtotal wrong after increasing quantity  *(SAMPLE / SIMULATED)*
| Field | Details |
|---|---|
| Bug ID | BUG-S01 |
| Summary | Cart subtotal wrong after increasing quantity |
| Module | Quantity Updates |
| Linked test case | TC_QTY_01 |
| Preconditions | User logged in. Steel Water Bottle (Rs.349) in cart with quantity 1. |
| Steps to reproduce | 1. Open the cart.<br>2. Change quantity of Steel Water Bottle from 1 to 3.<br>3. Click Update.<br>4. Read line total and cart subtotal. |
| Expected result | Line total Rs.1,047.00 and cart subtotal Rs.1,047.00 (Q12 shows the same). |
| Actual result | Line total shows Rs.1,047.00 but cart subtotal shows Rs.698.00 (quantity counted as 2). |
| Severity | High |
| Priority | High |
| Environment | Simulated ShopEase test build v0.1 (fictional), Chrome latest, Windows 11, MySQL 8.0 database shopease_db |
| SQL evidence | Q12 |
| Status | New (SAMPLE, not a real finding) |

### BUG-S02 – Stock not reduced after a successful order  *(SAMPLE / SIMULATED)*
| Field | Details |
|---|---|
| Bug ID | BUG-S02 |
| Summary | Stock not reduced after a successful order |
| Module | Inventory Validation |
| Linked test case | TC_INV_01 |
| Preconditions | ChargePro stock noted as 200. User has valid cart and address. |
| Steps to reproduce | 1. Note quantity_available of ChargePro (200).<br>2. Add ChargePro x2 to cart.<br>3. Place order and pay with UPI success@shopease.<br>4. Query inventory for the product. |
| Expected result | quantity_available = 198 (reduced by 2, rule BR-16). |
| Actual result | quantity_available is still 200. Order shows CONFIRMED. Risk of selling stock that does not exist. |
| Severity | High |
| Priority | High |
| Environment | Simulated ShopEase test build v0.1 (fictional), Chrome latest, Windows 11, MySQL 8.0 database shopease_db |
| SQL evidence | Q34, Q32 |
| Status | New (SAMPLE, not a real finding) |

### BUG-S03 – Checkout accepts pincode starting with 0  *(SAMPLE / SIMULATED)*
| Field | Details |
|---|---|
| Bug ID | BUG-S03 |
| Summary | Checkout accepts pincode starting with 0 |
| Module | Address Validation |
| Linked test case | TC_ADR_03 |
| Preconditions | User at checkout, Add Address form open. |
| Steps to reproduce | 1. Enter valid name, phone, line 1, city, state.<br>2. Enter pincode 017501.<br>3. Click Save and continue to payment. |
| Expected result | Error 'Enter a valid 6-digit pincode' and address not saved (BR-12). |
| Actual result | Address saved and checkout continues. A row with pincode 017501 is stored. |
| Severity | Medium |
| Priority | Medium |
| Environment | Simulated ShopEase test build v0.1 (fictional), Chrome latest, Windows 11, MySQL 8.0 database shopease_db |
| SQL evidence | Q39 (and review addresses table) |
| Status | New (SAMPLE, not a real finding) |

### BUG-S04 – Order shows CONFIRMED after card payment failed  *(SAMPLE / SIMULATED)*
| Field | Details |
|---|---|
| Bug ID | BUG-S04 |
| Summary | Order shows CONFIRMED after card payment failed |
| Module | Payment Status Simulation |
| Linked test case | TC_PAY_02 |
| Preconditions | Order ready for payment. Simulated card ending 0002 declines. |
| Steps to reproduce | 1. Place an order and choose Debit Card.<br>2. Enter the declined test card with valid expiry and CVV.<br>3. Click Pay.<br>4. Open Order History and query the order. |
| Expected result | Order status PAYMENT_FAILED, payment FAILED with a failure reason (BR-15). |
| Actual result | Payment row is FAILED but order status is CONFIRMED, so the order would be shipped without payment. |
| Severity | Critical |
| Priority | High |
| Environment | Simulated ShopEase test build v0.1 (fictional), Chrome latest, Windows 11, MySQL 8.0 database shopease_db |
| SQL evidence | Q27, Q28 |
| Status | New (SAMPLE, not a real finding) |

### BUG-S05 – Double click on Place Order creates two orders  *(SAMPLE / SIMULATED)*
| Field | Details |
|---|---|
| Bug ID | BUG-S05 |
| Summary | Double click on Place Order creates two orders |
| Module | Order Placement |
| Linked test case | TC_ORD_02 |
| Preconditions | Cart ready, address selected. |
| Steps to reproduce | 1. Open checkout.<br>2. Double-click Place Order quickly.<br>3. Open Order History and query orders for the customer. |
| Expected result | Exactly one order is created. |
| Actual result | Two orders with different order numbers and the same items are created; stock reduced twice. |
| Severity | High |
| Priority | High |
| Environment | Simulated ShopEase test build v0.1 (fictional), Chrome latest, Windows 11, MySQL 8.0 database shopease_db |
| SQL evidence | Q46, Q30, Q34 |
| Status | New (SAMPLE, not a real finding) |

### BUG-S06 – Cash on Delivery offered for order above Rs.10,000  *(SAMPLE / SIMULATED)*
| Field | Details |
|---|---|
| Bug ID | BUG-S06 |
| Summary | Cash on Delivery offered for order above Rs.10,000 |
| Module | Payment Status Simulation |
| Linked test case | TC_PAY_04 |
| Preconditions | Cart contains Nova Lite Smartphone (total Rs.10,618.82). |
| Steps to reproduce | 1. Open checkout with the cart.<br>2. Go to payment step.<br>3. Select Cash on Delivery and place the order. |
| Expected result | COD option disabled with a message (BR-13). |
| Actual result | COD is selectable and the order is placed with total 10,618.82. |
| Severity | High |
| Priority | Medium |
| Environment | Simulated ShopEase test build v0.1 (fictional), Chrome latest, Windows 11, MySQL 8.0 database shopease_db |
| SQL evidence | Q29 |
| Status | New (SAMPLE, not a real finding) |

### BUG-S07 – Account not blocked after 5 wrong passwords  *(SAMPLE / SIMULATED)*
| Field | Details |
|---|---|
| Bug ID | BUG-S07 |
| Summary | Account not blocked after 5 wrong passwords |
| Module | Login and Logout |
| Linked test case | TC_LOG_05 |
| Preconditions | User priya.nair@example.com ACTIVE with 0 failed attempts. |
| Steps to reproduce | 1. Enter a wrong password 5 times.<br>2. Enter the correct password Test@1234. |
| Expected result | Account status BLOCKED after the 5th failure; correct password rejected (BR-04). |
| Actual result | Status stays ACTIVE with failed_login_attempts 6; login with the correct password succeeds. |
| Severity | High |
| Priority | High |
| Environment | Simulated ShopEase test build v0.1 (fictional), Chrome latest, Windows 11, MySQL 8.0 database shopease_db |
| SQL evidence | Q06 |
| Status | New (SAMPLE, not a real finding) |

### BUG-S08 – Cancelled prepaid order is not refunded  *(SAMPLE / SIMULATED)*
| Field | Details |
|---|---|
| Bug ID | BUG-S08 |
| Summary | Cancelled prepaid order is not refunded |
| Module | Order Cancellation |
| Linked test case | TC_CAN_02 |
| Preconditions | UPI order in CONFIRMED state. |
| Steps to reproduce | 1. Open the order in My Orders.<br>2. Click Cancel Order and choose a reason.<br>3. Query orders and payments for the order. |
| Expected result | Order CANCELLED, payment REFUNDED (BR-17). |
| Actual result | Order CANCELLED but payment still SUCCESS; no refund recorded. |
| Severity | Critical |
| Priority | High |
| Environment | Simulated ShopEase test build v0.1 (fictional), Chrome latest, Windows 11, MySQL 8.0 database shopease_db |
| SQL evidence | Q25, Q40 |
| Status | New (SAMPLE, not a real finding) |

### BUG-S09 – Shipping fee charged when subtotal is exactly Rs.500  *(SAMPLE / SIMULATED)*
| Field | Details |
|---|---|
| Bug ID | BUG-S09 |
| Summary | Shipping fee charged when subtotal is exactly Rs.500 |
| Module | Checkout |
| Linked test case | TC_CHK_03 |
| Preconditions | Notebook Pack (Rs.250) available. |
| Steps to reproduce | 1. Add 2 Notebook Packs (subtotal Rs.500).<br>2. Open checkout and read shipping fee. |
| Expected result | Shipping Rs.0, GST 90.00, total 590.00 (BR-10: free from Rs.500). |
| Actual result | Shipping Rs.40.00 and total 630.00 (rule applied as 'above 500'). |
| Severity | Medium |
| Priority | Medium |
| Environment | Simulated ShopEase test build v0.1 (fictional), Chrome latest, Windows 11, MySQL 8.0 database shopease_db |
| SQL evidence | Q18, Q16 |
| Status | New (SAMPLE, not a real finding) |

### BUG-S10 – Brand name misspelled in site header  *(SAMPLE / SIMULATED)*
| Field | Details |
|---|---|
| Bug ID | BUG-S10 |
| Summary | Brand name misspelled in site header |
| Module | Product Search |
| Linked test case | TC_SRC_01 |
| Preconditions | Home page open. |
| Steps to reproduce | 1. Open the home page.<br>2. Read the header text. |
| Expected result | Header shows 'ShopEase'. |
| Actual result | Header shows 'ShopEse'. |
| Severity | Low |
| Priority | High |
| Environment | Simulated ShopEase test build v0.1 (fictional), Chrome latest, Windows 11, MySQL 8.0 database shopease_db |
| SQL evidence | None (UI text only) |
| Status | New (SAMPLE, not a real finding) |

## Defect life cycle
New, then Assigned, then Fixed, then Retest, then Closed. If the retest fails the defect goes to Reopened. Other states: Rejected (not a defect), Duplicate, Deferred.

## Tips for writing a good defect report
1. One defect per report. 2. A clear summary that says what is wrong and where. 3. Exact steps and test data so anyone can reproduce it. 4. Expected result taken from a requirement or business rule. 5. Attach evidence: screenshot, query result. 6. Do not blame the developer; describe facts.
