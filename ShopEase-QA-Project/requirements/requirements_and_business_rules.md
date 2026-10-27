# ShopEase – Requirements and Business Rules

> **Important:** ShopEase is a **fictional, simulated** application created for QA practice. No real production website was tested. Test cases are written to be executed against a simulated app or the MySQL database in `/sql`. Until you execute them, every test case stays **Not Executed**.

---

## 1. Project Overview
ShopEase is an online shopping website where customers register, search for products, add them to a cart, enter a delivery address, pay, and track or cancel orders.

This project shows how a QA engineer tests such a system in two ways:
1. **Manual testing** of the user interface (UI) and business rules.
2. **SQL validation** to confirm that the data saved in the database is correct.

**Why both?** A screen may say "Order placed", but the database may have a wrong total or missing stock update. SQL checks catch these hidden defects.

## 2. Scope and Out-of-Scope

| In scope (we test) | Out of scope (we do not test) |
|---|---|
| Registration, Login, Logout | Real payment gateway integration (payments are simulated) |
| Product search, categories, product details | Performance / load testing |
| Cart and quantity updates | Mobile app testing |
| Checkout and address validation | Admin panel and seller portal |
| Order placement, order history, cancellation | Email/SMS delivery testing |
| Simulated payment status (success, failed, COD) | Coupon engine (only a stored discount amount is verified) |
| Inventory updates | Return/exchange process, delivery tracking |
| SQL validation of all above data | Automation tools (Selenium, Cypress, Playwright) – optional future work |

## 3. Assumptions
- The application is available in a test environment, or you simulate it using the database and screenshots/mock pages.
- Test data from `02_sample_data.sql` is loaded. Every sample user's password is `Test@1234`.
- Payments are simulated: UPI ID `success@shopease` succeeds; card number ending `0002` is declined.
- Amounts are in Indian Rupees (Rs.).
- One payment record exists per order (simplification for learning).
- Testing is done on the Chrome browser (latest) unless a test says otherwise.

## 4. Business Rules (used to decide expected results)

| ID | Rule |
|---|---|
| BR-01 | Email must be valid and unique. Phone must be 10 digits starting with 6, 7, 8 or 9 and unique. |
| BR-02 | Password: 8 to 20 characters with at least 1 uppercase, 1 lowercase, 1 digit and 1 special character. |
| BR-03 | Name fields: letters and spaces only, 2 to 30 characters. |
| BR-04 | After 5 consecutive wrong passwords the account becomes BLOCKED. |
| BR-05 | Search needs at least 2 characters (maximum 100). Search is case-insensitive and supports partial words. |
| BR-06 | A parent category page also shows products of its sub-categories (Electronics includes Mobiles). |
| BR-07 | Out-of-stock products show "Out of Stock" and cannot be added to cart. When stock is 10 or fewer, show "Only N left". |
| BR-08 | Quantity per product: minimum 1, maximum 10 per order, and never more than available stock. |
| BR-09 | Subtotal = sum of (price x quantity). GST = 18% of subtotal. |
| BR-10 | Shipping fee = Rs.40 if subtotal is below Rs.500, otherwise free. |
| BR-11 | Total = subtotal + shipping + GST - discount. |
| BR-12 | Pincode: exactly 6 digits, cannot start with 0. Address needs name, phone, line 1, city, state, pincode. |
| BR-13 | COD is allowed only when order total is Rs.10,000 or less. |
| BR-14 | Order statuses: PLACED, CONFIRMED, SHIPPED, DELIVERED, CANCELLED, PAYMENT_FAILED. |
| BR-15 | Prepaid + payment success = CONFIRMED. COD = PLACED with payment PENDING. Payment failure = PAYMENT_FAILED. |
| BR-16 | Stock reduces when an order is placed with successful or COD payment. Failed payment does not reduce stock. |
| BR-17 | Cancellation is allowed only for PLACED and CONFIRMED orders. Stock is restored. Prepaid payment becomes REFUNDED; COD payment becomes CANCELLED. |
| BR-18 | A customer can see and cancel only their own orders. |

## 5. Functional Requirements

| Req ID | Module | Requirement (simple words) |
|---|---|---|
| FR-01 | User Registration | A new user can create an account using valid details (BR-01 to BR-03). |
| FR-02 | Login / Logout | A registered user can log in and log out; blocked/inactive users cannot log in (BR-04). |
| FR-03 | Product Search | User can search products by name (BR-05). |
| FR-04 | Categories and Details | User can browse by category and view product details (BR-06, BR-07). |
| FR-05 | Shopping Cart | User can add, view and remove items; cart is saved for the user. |
| FR-06 | Quantity Updates | User can change quantity within limits (BR-08). |
| FR-07 | Checkout | Checkout shows correct price summary (BR-09 to BR-11). Only logged-in users with items can check out. |
| FR-08 | Address Validation | Delivery address is validated (BR-12); user can only use their own addresses. |
| FR-09 | Order Placement | A valid order creates an order number, order items and reduces stock. |
| FR-10 | Payment Simulation | Payment outcome sets payment and order status correctly (BR-13, BR-15). |
| FR-11 | Order History | User sees their own orders with correct details (BR-18). |
| FR-12 | Order Cancellation | User can cancel eligible orders (BR-17). |
| FR-13 | Inventory | Stock stays accurate and never goes below zero (BR-16). |

