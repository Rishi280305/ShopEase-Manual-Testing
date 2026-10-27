# ShopEase – Manual Test Cases
**Total test cases: 67**  |  Application: simulated ShopEase (fictional)  |  Sample login password: `Test@1234`
How to use: execute each case, fill **Actual Result**, then change **Status** to Pass / Fail / Blocked. Log every Fail as a defect. SQL references (Q01 to Q48) point to `sql/03_validation_queries.sql` (see `docs/sql_query_guide.md`).
Priority: High = core business flow or money/data risk, Medium = important but has workaround, Low = minor.

## User Registration

| TC ID | Module | Test Scenario | Preconditions | Test Data | Test Steps | Expected Result | Actual Result | Status | Priority | Test Type |
|---|---|---|---|---|---|---|---|---|---|---|
| TC_REG_01 | User Registration | Register with valid details | User not logged in; email and phone not registered | First: Anitha, Last: Rao, Email: anitha.rao@example.com, Phone: 9123456780, Password: Pass@1234, Confirm: Pass@1234 | 1. Open Register page<br>2. Enter the test data<br>3. Click Register | Account created, success message shown, user redirected to Login. DB: 1 new customers row, status ACTIVE, password stored as hash (SQL Q01) |  | Not Executed | High | Positive |
| TC_REG_02 | User Registration | Register with an already registered email | ravi.kumar@example.com already exists | Email: ravi.kumar@example.com, Phone: 9123456781, other fields valid | 1. Open Register page<br>2. Enter data with the existing email<br>3. Click Register | Error 'Email already registered'; no new customer row (SQL Q02 returns 0 rows) |  | Not Executed | High | Negative |
| TC_REG_03 | User Registration | Register with an already registered phone number | Phone 9876543210 already exists | Phone: 9876543210, Email: new.user1@example.com, other fields valid | 1. Open Register page<br>2. Enter data with the existing phone<br>3. Click Register | Error 'Phone number already registered'; no new row (SQL Q03 returns 0 rows) |  | Not Executed | Medium | Negative |
| TC_REG_04 | User Registration | Invalid email formats are rejected | Register page open | ravi.kumar@ ; ravi@.com ; ravi kumar@example.com ; ravi.example.com | 1. Enter each invalid email one by one with other valid data<br>2. Click Register after each | Each attempt shows 'Enter a valid email address'; no account created |  | Not Executed | High | Validation |
| TC_REG_05 | User Registration | Mandatory fields left blank | Register page open | All fields empty | 1. Click Register without entering anything | Inline error shown for every mandatory field; form not submitted |  | Not Executed | High | Negative |
| TC_REG_06 | User Registration | Weak passwords are rejected (password policy) | Register page open | abcd1234 (no uppercase/special) ; PASSWORD@1 (no lowercase) ; Password@ (no digit) ; Pass1234 (no special) | 1. Fill valid data and enter one weak password<br>2. Click Register<br>3. Repeat for each password | Each is rejected and the message lists the missing rule (BR-02) |  | Not Executed | High | Validation |
| TC_REG_07 | User Registration | Password length boundary values | Register page open | 7 chars: Pass@12 ; 8 chars: Pass@123 ; 20 chars: Passw@rd123456789012 ; 21 chars: Passw@rd1234567890123 | 1. Enter each password with valid other data<br>2. Click Register | 7 and 21 characters rejected; 8 and 20 characters accepted (use a unique email each time) |  | Not Executed | High | Boundary |
| TC_REG_08 | User Registration | Confirm password does not match | Register page open | Password: Pass@1234, Confirm: Pass@12345 | 1. Enter mismatching passwords<br>2. Click Register | Error 'Passwords do not match'; account not created |  | Not Executed | Medium | Negative |
| TC_REG_09 | User Registration | Phone number validation | Register page open | 12345 ; 5876543210 (starts with 5) ; 98765abcde ; 98765432101 (11 digits) | 1. Enter each phone value with other valid data<br>2. Click Register | All rejected; only 10 digits starting 6-9 allowed (BR-01) |  | Not Executed | High | Validation |

## Login and Logout

| TC ID | Module | Test Scenario | Preconditions | Test Data | Test Steps | Expected Result | Actual Result | Status | Priority | Test Type |
|---|---|---|---|---|---|---|---|---|---|---|
| TC_LOG_01 | Login and Logout | Login with valid credentials | Registered ACTIVE user | ravi.kumar@example.com / Test@1234 | 1. Open Login page<br>2. Enter email and password<br>3. Click Login | Login succeeds, home page shows user name. DB: last_login_at updated, failed_login_attempts = 0 |  | Not Executed | High | Positive |
| TC_LOG_02 | Login and Logout | Login with wrong password | Registered ACTIVE user | ravi.kumar@example.com / Wrong@123 | 1. Enter valid email and wrong password<br>2. Click Login | Generic message 'Invalid email or password'; not logged in. DB: failed_login_attempts increased by 1 |  | Not Executed | High | Negative |
| TC_LOG_03 | Login and Logout | Login with unregistered email | None | nobody@example.com / Test@1234 | 1. Enter unregistered email and any password<br>2. Click Login | Same generic message (does not reveal that the email is unknown) |  | Not Executed | Medium | Negative |
| TC_LOG_04 | Login and Logout | Login with blank fields | Login page open | Empty email and password | 1. Click Login with both fields empty<br>2. Enter only email and click Login | Mandatory field messages shown; no login attempt counted |  | Not Executed | Medium | Validation |
| TC_LOG_05 | Login and Logout | Account locks after 5 wrong passwords (boundary 4 vs 5) | Use a fresh ACTIVE user with 0 failed attempts | priya.nair@example.com wrong password Bad@1234 | 1. Reset failed_login_attempts to 0 using SQL<br>2. Enter wrong password 4 times; check message and DB<br>3. Enter wrong password a 5th time<br>4. Now enter the correct password Test@1234 | After 4 attempts the account is still usable; after the 5th the status becomes BLOCKED and even the correct password is rejected (SQL Q06 returns 0 rows) |  | Not Executed | High | Boundary |
| TC_LOG_06 | Login and Logout | Blocked and inactive users cannot log in | Users with BLOCKED and INACTIVE status exist | karthik.rao@example.com (BLOCKED) ; anita.desai@example.com (INACTIVE), password Test@1234 | 1. Login as the blocked user<br>2. Login as the inactive user | Blocked: 'Account blocked, contact support'. Inactive: 'Account is inactive'. No session created |  | Not Executed | High | Negative |
| TC_LOG_07 | Login and Logout | Logout ends the session | User logged in | ravi.kumar@example.com | 1. Click Logout<br>2. Press browser Back button<br>3. Try to open the Order History URL directly | Redirected to Login; protected pages are not accessible after logout |  | Not Executed | High | Positive |

## Product Search

| TC ID | Module | Test Scenario | Preconditions | Test Data | Test Steps | Expected Result | Actual Result | Status | Priority | Test Type |
|---|---|---|---|---|---|---|---|---|---|---|
| TC_SRC_01 | Product Search | Search is case-insensitive | Home page open | headphones ; HEADPHONES ; HeadPhones | 1. Type each keyword in search box<br>2. Press Enter | Same result each time: SoundMax Wireless Headphones |  | Not Executed | High | Positive |
| TC_SRC_02 | Product Search | Search with no matching product | Home page open | xyzabc | 1. Search xyzabc | 'No products found' message with suggestion; no error page |  | Not Executed | Medium | Negative |
| TC_SRC_03 | Product Search | Search keyword length boundary | Home page open | 1 char: a ; 2 chars: so ; 100 chars of 'a' ; 101 chars of 'a' | 1. Search each value | 1 char: 'Enter at least 2 characters'; 2 chars returns SoundMax; 100 chars handled without error; 101 chars blocked or truncated (BR-05) |  | Not Executed | Medium | Boundary |
| TC_SRC_04 | Product Search | Unsafe text in the search box is treated as plain text | Home page open | ' OR 1=1 -- ; <script>alert(1)</script> | 1. Enter each text in search box<br>2. Press Enter | No script runs, no database error, not all products returned; shows 'No products found' |  | Not Executed | High | Negative |

## Categories and Product Details

| TC ID | Module | Test Scenario | Preconditions | Test Data | Test Steps | Expected Result | Actual Result | Status | Priority | Test Type |
|---|---|---|---|---|---|---|---|---|---|---|
| TC_CAT_01 | Categories and Product Details | Parent category shows sub-category products | Products exist under Electronics and Mobiles | Category: Electronics | 1. Open Electronics category | 6 products shown: Nova X5, Nova Lite, SoundMax, ChargePro, PowerMax Power Bank, Smart Watch Pro (compare with SQL Q10) |  | Not Executed | High | Positive |
| TC_CAT_02 | Categories and Product Details | Product details page shows correct data | Product Nova X5 exists | Nova X5 Smartphone 128GB | 1. Open the product from search or category<br>2. Compare page with DB | Name, description, price Rs.14,999, MRP Rs.17,999, '17% off', 'In Stock' shown correctly (SQL Q11) |  | Not Executed | High | Validation |
| TC_CAT_03 | Categories and Product Details | Out-of-stock product cannot be purchased | Smart Watch Pro stock = 0 | Smart Watch Pro | 1. Open Smart Watch Pro<br>2. Try to click Add to Cart | 'Out of Stock' label shown and Add to Cart is disabled (BR-07) |  | Not Executed | High | Negative |
| TC_CAT_04 | Categories and Product Details | Low-stock message | PowerMax Power Bank stock = 8 | PowerMax 10000mAh Power Bank | 1. Open the product page | 'Only 8 left' message displayed (SQL Q31 lists the product) |  | Not Executed | Medium | Positive |

## Shopping Cart

| TC ID | Module | Test Scenario | Preconditions | Test Data | Test Steps | Expected Result | Actual Result | Status | Priority | Test Type |
|---|---|---|---|---|---|---|---|---|---|---|
| TC_CRT_01 | Shopping Cart | Add a product to cart | User logged in; empty cart | SoundMax Wireless Headphones (Rs.1,499) | 1. Open product page<br>2. Click Add to Cart<br>3. Open cart | Cart icon count 1; cart shows the item, quantity 1, price Rs.1,499. DB: 1 cart_items row (SQL Q12) |  | Not Executed | High | Positive |
| TC_CRT_02 | Shopping Cart | Adding the same product twice increases quantity | SoundMax already in cart | SoundMax Wireless Headphones | 1. Click Add to Cart again on the same product<br>2. Open cart | Single cart line with quantity 2; no duplicate line (DB unique rule cart_id + product_id) |  | Not Executed | High | Positive |
| TC_CRT_03 | Shopping Cart | Remove an item from the cart | Cart has 2 items | SoundMax and Steel Water Bottle | 1. Click Remove on SoundMax<br>2. Check cart totals | Item removed, totals recalculated, DB cart_items row deleted |  | Not Executed | High | Positive |
| TC_CRT_04 | Shopping Cart | Cart is saved after logout and login | Cart has 1 item | ravi.kumar@example.com | 1. Logout<br>2. Login again<br>3. Open cart | Same items and quantities still in cart |  | Not Executed | Medium | Positive |
| TC_CRT_05 | Shopping Cart | Empty cart behaviour | User logged in; cart empty | None | 1. Open cart page | 'Your cart is empty' message; Checkout button disabled |  | Not Executed | Medium | Negative |

## Quantity Updates

| TC ID | Module | Test Scenario | Preconditions | Test Data | Test Steps | Expected Result | Actual Result | Status | Priority | Test Type |
|---|---|---|---|---|---|---|---|---|---|---|
| TC_QTY_01 | Quantity Updates | Increase quantity updates totals | Steel Water Bottle (Rs.349) in cart, qty 1 | Quantity 1 to 3 | 1. Change quantity to 3<br>2. Click Update | Line total Rs.1,047 and cart subtotal update immediately; DB quantity = 3 |  | Not Executed | High | Positive |
| TC_QTY_02 | Quantity Updates | Maximum quantity per order boundary | Steel Water Bottle in cart (stock 120) | Quantity 10 and 11 | 1. Set quantity to 10 and update<br>2. Set quantity to 11 and update | 10 accepted; 11 rejected with 'Maximum 10 per order' (BR-08) |  | Not Executed | High | Boundary |
| TC_QTY_03 | Quantity Updates | Minimum quantity boundary | Item in cart | Quantity 0 and -1 | 1. Enter 0 and update<br>2. Enter -1 and update | 0 asks to remove the item or is rejected; -1 rejected; cart never holds quantity below 1 |  | Not Executed | High | Boundary |
| TC_QTY_04 | Quantity Updates | Quantity cannot exceed available stock | PowerMax Power Bank stock = 8 | Quantity 8 and 9 | 1. Set quantity to 8 and update<br>2. Set quantity to 9 and update | 8 accepted; 9 rejected with 'Only 8 available' (SQL Q15 returns 0 rows) |  | Not Executed | High | Boundary |
| TC_QTY_05 | Quantity Updates | Invalid quantity input | Item in cart | abc ; 2.5 ; blank | 1. Enter each value in quantity box<br>2. Click Update | Each value rejected with a message; previous quantity retained |  | Not Executed | Medium | Validation |

## Checkout

| TC ID | Module | Test Scenario | Preconditions | Test Data | Test Steps | Expected Result | Actual Result | Status | Priority | Test Type |
|---|---|---|---|---|---|---|---|---|---|---|
| TC_CHK_01 | Checkout | Checkout requires login | User logged out; cart exists in guest session | None | 1. Click Checkout while logged out | User is redirected to Login; after login returns to checkout |  | Not Executed | High | Negative |
| TC_CHK_02 | Checkout | Price summary is calculated correctly | Cart: SoundMax x1 (1499) and ChargePro x2 (599) | Expected: subtotal 2697.00, shipping 0.00, GST 485.46, total 3182.46 | 1. Open Checkout<br>2. Compare each amount with expected values | All amounts match BR-09 to BR-11 exactly to 2 decimals |  | Not Executed | High | Functional |
| TC_CHK_03 | Checkout | Shipping fee boundary around Rs.500 | Notebook Pack (Rs.250) available | 1 unit: subtotal 250 ; 2 units: subtotal 500 | 1. Add 1 Notebook Pack and open Checkout<br>2. Change quantity to 2 and open Checkout | 1 unit: shipping 40, GST 45.00, total 335.00. 2 units: shipping 0, GST 90.00, total 590.00 (SQL Q18) |  | Not Executed | High | Boundary |
| TC_CHK_04 | Checkout | Price change after adding to cart | SoundMax in cart at Rs.1,499 | Change price in DB to 1399 for the test | 1. Update products.price via SQL<br>2. Refresh cart and open Checkout | Checkout uses the latest price and shows a notice about the price change (otherwise log defect; SQL Q14) |  | Not Executed | Medium | Functional |

## Address Validation

| TC ID | Module | Test Scenario | Preconditions | Test Data | Test Steps | Expected Result | Actual Result | Status | Priority | Test Type |
|---|---|---|---|---|---|---|---|---|---|---|
| TC_ADR_01 | Address Validation | Add a valid new address | User logged in; at checkout | Name: Ravi Kumar, Phone: 9876543210, Line1: 12-4 Gandhi Road, City: Tirupati, State: Andhra Pradesh, Pincode: 517501 | 1. Click Add New Address<br>2. Enter data<br>3. Click Save | Address saved and selectable. DB: new addresses row linked to the customer |  | Not Executed | High | Positive |
| TC_ADR_02 | Address Validation | Mandatory address fields blank | Add Address form open | All fields empty | 1. Click Save with empty form | Errors for name, phone, line 1, city, state, pincode; address not saved |  | Not Executed | High | Negative |
| TC_ADR_03 | Address Validation | Pincode validation and boundary | Add Address form open | 12345 ; 1234567 ; 51750A ; 017501 ; 517501 | 1. Enter each pincode with other valid fields<br>2. Click Save | First four rejected (length, letters, leading 0); 517501 accepted (BR-12) |  | Not Executed | High | Boundary |
| TC_ADR_04 | Address Validation | Default address is pre-selected | Customer has 2 addresses, one default | ravi.kumar@example.com | 1. Go to Checkout<br>2. Check the selected address<br>3. Select the other address | Default (Home - Tirupati) is pre-selected; user can switch; final order uses the chosen address (SQL Q20) |  | Not Executed | Medium | Positive |
| TC_ADR_05 | Address Validation | User cannot use another customer's address | Two users exist; note an address_id of the other user | Address ID 3 belongs to Sneha; logged in as Ravi | 1. As Ravi, start checkout<br>2. Using browser dev tools or URL, change address ID to 3<br>3. Place order | Request rejected (error/403); order not created (SQL Q20 returns 0 rows) |  | Not Executed | High | Negative |

## Order Placement

| TC ID | Module | Test Scenario | Preconditions | Test Data | Test Steps | Expected Result | Actual Result | Status | Priority | Test Type |
|---|---|---|---|---|---|---|---|---|---|---|
| TC_ORD_01 | Order Placement | Place an order successfully | Cart ready, address selected | SoundMax x1, ChargePro x2, UPI success@shopease | 1. Click Place Order<br>2. Pay using UPI success@shopease<br>3. Note the order number | Order confirmation page with order number. DB: orders, order_items and payments rows created; amounts correct (SQL Q16, Q22, Q24) |  | Not Executed | High | Positive |
| TC_ORD_02 | Order Placement | Double click on Place Order | Cart ready | Any cart | 1. Double-click the Place Order button quickly<br>2. Check Order History and DB | Only one order created; stock reduced only once |  | Not Executed | High | Negative |
| TC_ORD_03 | Order Placement | Refresh or Back after order placement | Order just placed | None | 1. Press F5 on confirmation page<br>2. Press Back and resubmit if possible | No second order is created; user sees the same confirmation or a safe page |  | Not Executed | Medium | Negative |
| TC_ORD_04 | Order Placement | Product becomes out of stock before payment | Item in cart; checkout page open | Set stock to 0 via SQL after opening checkout | 1. Open checkout<br>2. Run: UPDATE inventory SET quantity_available=0 for the product<br>3. Click Place Order | Order blocked with 'item out of stock' message; no order or payment row created |  | Not Executed | High | Negative |

## Payment Status Simulation

| TC ID | Module | Test Scenario | Preconditions | Test Data | Test Steps | Expected Result | Actual Result | Status | Priority | Test Type |
|---|---|---|---|---|---|---|---|---|---|---|
| TC_PAY_01 | Payment Status Simulation | UPI payment success | Order ready for payment | UPI ID: success@shopease | 1. Choose UPI<br>2. Enter UPI ID and pay | Order CONFIRMED, payment SUCCESS, transaction id saved, paid_at filled (SQL Q28) |  | Not Executed | High | Positive |
| TC_PAY_02 | Payment Status Simulation | Card payment fails | Order ready for payment | Card number ending 0002 (simulated decline), valid expiry and CVV | 1. Choose Debit Card<br>2. Enter test card and pay | Message with option to retry; order PAYMENT_FAILED, payment FAILED with reason; stock NOT reduced (SQL Q27) |  | Not Executed | High | Negative |
| TC_PAY_03 | Payment Status Simulation | COD within the limit | Order total <= Rs.10,000 | Total Rs.1,353.46 | 1. Choose Cash on Delivery<br>2. Place order | Order PLACED, payment PENDING, transaction id NULL, stock reduced |  | Not Executed | Medium | Positive |
| TC_PAY_04 | Payment Status Simulation | COD not available above Rs.10,000 | Cart with Nova Lite (total 10,618.82) | Total Rs.10,618.82 | 1. Go to payment step | COD option disabled with a message; online methods available (SQL Q29 returns 0 rows) |  | Not Executed | Medium | Boundary |
| TC_PAY_05 | Payment Status Simulation | Invalid card details | Payment page open | Card 1234 5678 (too short) ; expiry 01/24 (expired) ; CVV 12 | 1. Enter each invalid detail<br>2. Click Pay | Field-level errors shown; no payment record created |  | Not Executed | Medium | Validation |

## Order History

| TC ID | Module | Test Scenario | Preconditions | Test Data | Test Steps | Expected Result | Actual Result | Status | Priority | Test Type |
|---|---|---|---|---|---|---|---|---|---|---|
| TC_HIS_01 | Order History | Order history shows only own orders, newest first | User has 2 orders | ravi.kumar@example.com (orders SE-20261005-0006 and SE-20260915-0001) | 1. Login<br>2. Open My Orders | Only Ravi's 2 orders, newest first; matches SQL Q21 |  | Not Executed | High | Positive |
| TC_HIS_02 | Order History | Order details match the database | Order SE-20260915-0001 exists | Order SE-20260915-0001 | 1. Open the order details<br>2. Run SQL Q22 and compare each field | Items, quantity, price, shipping, GST, total, address and payment status all match |  | Not Executed | High | Validation |
| TC_HIS_03 | Order History | Cannot open another user's order by changing the URL | Logged in as Ravi | Order ID of Sneha (order 2) | 1. Open Ravi's order details<br>2. Change order ID in URL to 2 | Access denied or 'Order not found'; no data of another user is shown |  | Not Executed | High | Negative |

## Order Cancellation

| TC ID | Module | Test Scenario | Preconditions | Test Data | Test Steps | Expected Result | Actual Result | Status | Priority | Test Type |
|---|---|---|---|---|---|---|---|---|---|---|
| TC_CAN_01 | Order Cancellation | Cancel a PLACED COD order | COD order in PLACED state; note stock before | Order SE-20261022-0003 | 1. Open order details<br>2. Click Cancel Order<br>3. Select reason and confirm | Order CANCELLED, cancelled_at set, payment CANCELLED, stock restored to previous value (SQL Q26, Q34) |  | Not Executed | High | Positive |
| TC_CAN_02 | Order Cancellation | Cancel a CONFIRMED prepaid order | UPI order in CONFIRMED state | Order SE-20261005-0006 | 1. Cancel the order with a reason | Order CANCELLED, payment REFUNDED, stock restored (SQL Q25, Q34) |  | Not Executed | High | Positive |
| TC_CAN_03 | Order Cancellation | Shipped and delivered orders cannot be cancelled | Orders in SHIPPED and DELIVERED state | SE-20260918-0002 (SHIPPED), SE-20260915-0001 (DELIVERED) | 1. Open each order<br>2. Look for the Cancel button<br>3. Try the cancel request directly via URL | Cancel option hidden or disabled; direct request rejected; status unchanged (BR-17) |  | Not Executed | High | Negative |
| TC_CAN_04 | Order Cancellation | Cancelling an already cancelled order | Order already CANCELLED | Order SE-20260925-0004 | 1. Open the order<br>2. Try to cancel again (repeat the request) | Rejected; stock restored only once and refund not duplicated |  | Not Executed | High | Negative |
| TC_CAN_05 | Order Cancellation | Cancellation reason is mandatory | PLACED order available | Reason: blank ; 'Other' with 201 characters | 1. Click Cancel Order<br>2. Submit without reason<br>3. Enter a 201-character reason | Blank reason rejected; reason over 200 characters rejected (column limit) |  | Not Executed | Low | Validation |

## Inventory Validation

| TC ID | Module | Test Scenario | Preconditions | Test Data | Test Steps | Expected Result | Actual Result | Status | Priority | Test Type |
|---|---|---|---|---|---|---|---|---|---|---|
| TC_INV_01 | Inventory Validation | Stock reduces by the ordered quantity | Note stock of ChargePro (Q34 style check before) | ChargePro x2 via UPI | 1. Note quantity_available<br>2. Place and pay for the order<br>3. Check quantity_available again | Stock is exactly 2 lower than before |  | Not Executed | High | Positive |
| TC_INV_02 | Inventory Validation | Failed payment does not reduce stock | Note stock before | Card ending 0002 | 1. Note stock<br>2. Place an order and fail the payment<br>3. Check stock | Stock unchanged |  | Not Executed | High | Negative |
| TC_INV_03 | Inventory Validation | Last unit bought by two users at the same time | Product stock set to 1 | Two browsers: Ravi and Sneha | 1. Both users add the product<br>2. Both open checkout<br>3. Both click Place Order within seconds | Only one order succeeds; other user gets out-of-stock message; stock = 0 (never -1) (SQL Q32) |  | Not Executed | High | Negative |
| TC_INV_04 | Inventory Validation | Database blocks negative stock | DB access | UPDATE inventory SET quantity_available = -1 WHERE product_id = 3 | 1. Run the UPDATE in SQL client | MySQL rejects with CHECK constraint error chk_inventory_qty; data unchanged |  | Not Executed | Medium | Validation |

## End-to-End

| TC ID | Module | Test Scenario | Preconditions | Test Data | Test Steps | Expected Result | Actual Result | Status | Priority | Test Type |
|---|---|---|---|---|---|---|---|---|---|---|
| TC_E2E_01 | End-to-End | Complete purchase with UPI | Anitha Rao registered (TC_REG_01) | Search: headphones; add SoundMax x1 and ChargePro x2; UPI success@shopease | 1. Login<br>2. Search headphones and add to cart<br>3. Add ChargePro x2<br>4. Checkout, select address<br>5. Pay with UPI<br>6. Open Order History<br>7. Run SQL Q22, Q16, Q24, Q34 | Order CONFIRMED; UI and DB agree on items, amounts, payment and stock; all CHECK queries return 0 rows |  | Not Executed | High | End-to-End |
| TC_E2E_02 | End-to-End | COD order then cancellation | Logged-in user with address | Steel Water Bottle x2, COD | 1. Add product x2 and place COD order<br>2. Verify PLACED/PENDING in DB<br>3. Cancel from Order History<br>4. Verify status and stock again | Order moves PLACED to CANCELLED; payment PENDING to CANCELLED; stock restored (SQL Q26, Q34) |  | Not Executed | High | End-to-End |
| TC_E2E_03 | End-to-End | Failed payment then successful retry | Logged-in user with address | Nova Lite x1; first card ending 0002, then UPI success@shopease | 1. Place order and fail card payment<br>2. Verify PAYMENT_FAILED and stock unchanged<br>3. Retry payment using UPI<br>4. Verify final state in DB | Single order ends CONFIRMED, payment SUCCESS with transaction id, stock reduced once, no duplicate order (SQL Q19, Q23, Q27) |  | Not Executed | High | End-to-End |

## Coverage Summary

| Module | Count |
|---|---|
| User Registration | 9 |
| Login and Logout | 7 |
| Product Search | 4 |
| Categories and Product Details | 4 |
| Shopping Cart | 5 |
| Quantity Updates | 5 |
| Checkout | 4 |
| Address Validation | 5 |
| Order Placement | 4 |
| Payment Status Simulation | 5 |
| Order History | 3 |
| Order Cancellation | 5 |
| Inventory Validation | 4 |
| End-to-End | 3 |

| Test Type | Count |
|---|---|
| Positive | 20 |
| Negative | 23 |
| Validation | 10 |
| Boundary | 9 |
| Functional | 2 |
| End-to-End | 3 |

| Priority | Count |
|---|---|
| High | 49 |
| Medium | 17 |
| Low | 1 |
