-- =====================================================================
-- ShopEase QA Project | 03_validation_queries.sql
-- 48 queries grouped by purpose. Run AFTER 01 and 02.
-- "CHECK" queries: expected result on clean sample data = 0 rows.
-- "REPORT" queries: used to compare the UI/report with the database.
-- =====================================================================
USE shopease_db;

-- =====================================================================
-- GROUP A: CUSTOMER AND REGISTRATION VALIDATION
-- =====================================================================

-- Q01 [VERIFY] After test TC_REG_01, confirm the new customer was saved correctly.
-- Expected: 1 row, status ACTIVE, failed_login_attempts 0, password_hash NOT the plain password.
SELECT customer_id, first_name, last_name, email, phone, status, failed_login_attempts, created_at, password_hash
FROM customers
WHERE email = 'anitha.rao@example.com';

-- Q02 [CHECK] Duplicate emails (case-insensitive). Expected: 0 rows.
SELECT LOWER(email) AS email_lower, COUNT(*) AS total
FROM customers
GROUP BY LOWER(email)
HAVING COUNT(*) > 1;

-- Q03 [CHECK] Duplicate phone numbers. Expected: 0 rows.
SELECT phone, COUNT(*) AS total
FROM customers
GROUP BY phone
HAVING COUNT(*) > 1;

-- Q04 [CHECK] Customers with an invalid email format. Expected: 0 rows.
SELECT customer_id, email
FROM customers
WHERE email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$';

-- Q05 [CHECK] ACTIVE customers who do not have exactly one default address. Expected: 0 rows.
SELECT c.customer_id, c.email, COALESCE(SUM(a.is_default), 0) AS default_addresses
FROM customers c
LEFT JOIN addresses a ON a.customer_id = c.customer_id
WHERE c.status = 'ACTIVE'
GROUP BY c.customer_id, c.email
HAVING COALESCE(SUM(a.is_default), 0) <> 1;

-- Q06 [CHECK] Account-lock rule: 5 or more failed logins but account is not BLOCKED. Expected: 0 rows.
SELECT customer_id, email, failed_login_attempts, status
FROM customers
WHERE failed_login_attempts >= 5 AND status <> 'BLOCKED';

-- =====================================================================
-- GROUP B: PRODUCTS AND CATEGORIES
-- =====================================================================

-- Q07 [CHECK] Products where selling price is higher than MRP. Expected: 0 rows.
SELECT product_id, product_name, price, mrp
FROM products
WHERE price > mrp;

-- Q08 [CHECK] Active products that have no inventory record. Expected: 0 rows.
SELECT p.product_id, p.product_name
FROM products p
LEFT JOIN inventory i ON i.product_id = p.product_id
WHERE p.is_active = 1 AND i.product_id IS NULL;

-- Q09 [CHECK] Active products placed in an inactive category. Expected: 0 rows.
SELECT p.product_id, p.product_name, c.category_name
FROM products p
JOIN categories c ON c.category_id = p.category_id
WHERE p.is_active = 1 AND c.is_active = 0;

-- Q10 [REPORT] Product count per category, including sub-category totals under the parent.
-- Compare with the category page in the UI (Electronics should show 6 products incl. Mobiles).
SELECT COALESCE(parent.category_name, c.category_name) AS main_category,
       COUNT(p.product_id) AS total_products
FROM categories c
LEFT JOIN categories parent ON parent.category_id = c.parent_category_id
LEFT JOIN products p ON p.category_id = c.category_id AND p.is_active = 1
GROUP BY COALESCE(parent.category_name, c.category_name)
ORDER BY main_category;

-- Q11 [REPORT] Discount percentage per product. Compare with "x% off" on the product page.
SELECT product_id, product_name, price, mrp,
       ROUND((mrp - price) / mrp * 100, 0) AS discount_percent
FROM products
ORDER BY discount_percent DESC;

-- =====================================================================
-- GROUP C: SHOPPING CART AND QUANTITY
-- =====================================================================

-- Q12 [REPORT] Cart summary: number of lines, units and value per cart. Compare with the cart page.
SELECT c.cart_id, c.customer_id, c.status,
       COUNT(ci.cart_item_id) AS item_lines,
       SUM(ci.quantity) AS total_units,
       SUM(ci.quantity * ci.unit_price) AS cart_value
FROM carts c
LEFT JOIN cart_items ci ON ci.cart_id = c.cart_id
GROUP BY c.cart_id, c.customer_id, c.status;

-- Q13 [CHECK] Customers with more than one ACTIVE cart. Expected: 0 rows.
SELECT customer_id, COUNT(*) AS active_carts
FROM carts
WHERE status = 'ACTIVE'
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Q14 [CHECK] ACTIVE cart items whose saved price differs from the current product price.
-- Expected: 0 rows (a row means the cart did not refresh after a price change).
SELECT ci.cart_id, p.product_name, ci.unit_price AS cart_price, p.price AS current_price
FROM cart_items ci
JOIN carts c ON c.cart_id = ci.cart_id AND c.status = 'ACTIVE'
JOIN products p ON p.product_id = ci.product_id
WHERE ci.unit_price <> p.price;

-- Q15 [CHECK] ACTIVE cart items that exceed the product limit or the available stock. Expected: 0 rows.
SELECT ci.cart_id, p.product_name, ci.quantity, p.max_qty_per_order, i.quantity_available
FROM cart_items ci
JOIN carts c ON c.cart_id = ci.cart_id AND c.status = 'ACTIVE'
JOIN products p ON p.product_id = ci.product_id
JOIN inventory i ON i.product_id = ci.product_id
WHERE ci.quantity > p.max_qty_per_order OR ci.quantity > i.quantity_available;

-- =====================================================================
-- GROUP D: ORDERS AND CHECKOUT CALCULATIONS
-- =====================================================================

-- Q16 [CHECK] Order amounts that do not add up. Expected: 0 rows.
-- Rule: subtotal = sum of items; total = subtotal + shipping + tax - discount.
SELECT o.order_number, o.subtotal, SUM(oi.line_total) AS items_total, o.total_amount,
       (o.subtotal + o.shipping_fee + o.tax_amount - o.discount_amount) AS expected_total
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.order_number, o.subtotal, o.shipping_fee, o.tax_amount, o.discount_amount, o.total_amount
HAVING ROUND(o.subtotal, 2) <> ROUND(SUM(oi.line_total), 2)
    OR ROUND(o.total_amount, 2) <> ROUND(o.subtotal + o.shipping_fee + o.tax_amount - o.discount_amount, 2);

-- Q17 [CHECK] GST (18% of subtotal) calculated wrongly. Expected: 0 rows.
SELECT order_number, subtotal, tax_amount, ROUND(subtotal * 0.18, 2) AS expected_tax
FROM orders
WHERE tax_amount <> ROUND(subtotal * 0.18, 2);

-- Q18 [CHECK] Shipping fee rule violations (Rs.40 if subtotal < 500, else free). Expected: 0 rows.
SELECT order_number, subtotal, shipping_fee
FROM orders
WHERE (subtotal >= 500 AND shipping_fee <> 0)
   OR (subtotal <  500 AND shipping_fee <> 40);

-- Q19 [CHECK] Orders that have no order items. Expected: 0 rows.
SELECT o.order_id, o.order_number
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.order_id
WHERE oi.order_item_id IS NULL;

-- Q20 [CHECK] Orders shipped to an address that belongs to a different customer. Expected: 0 rows.
SELECT o.order_number, o.customer_id AS order_customer, a.customer_id AS address_owner
FROM orders o
JOIN addresses a ON a.address_id = o.shipping_address_id
WHERE a.customer_id <> o.customer_id;

-- Q21 [REPORT] Order history for one customer, newest first. Compare with the Order History page.
SELECT order_number, placed_at, order_status, payment_method, total_amount
FROM orders
WHERE customer_id = 1
ORDER BY placed_at DESC;

-- Q22 [REPORT] Full detail of one order across 6 tables. Compare with the Order Details page.
SELECT o.order_number, o.order_status, CONCAT(c.first_name, ' ', c.last_name) AS customer,
       CONCAT(a.address_line1, ', ', a.city, ', ', a.state, ' - ', a.pincode) AS ship_to,
       p.product_name, oi.quantity, oi.unit_price, oi.line_total,
       o.shipping_fee, o.tax_amount, o.discount_amount, o.total_amount,
       pay.payment_status, pay.transaction_id
FROM orders o
JOIN customers c   ON c.customer_id = o.customer_id
JOIN addresses a   ON a.address_id = o.shipping_address_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p    ON p.product_id = oi.product_id
LEFT JOIN payments pay ON pay.order_id = o.order_id
WHERE o.order_number = 'SE-20260915-0001';

-- =====================================================================
-- GROUP E: PAYMENT AND TRANSACTION VALIDATION
-- =====================================================================

-- Q23 [CHECK] Orders with no payment record. Expected: 0 rows.
SELECT o.order_number, o.order_status
FROM orders o
LEFT JOIN payments p ON p.order_id = o.order_id
WHERE p.payment_id IS NULL;

-- Q24 [CHECK] Payment amount different from the order total. Expected: 0 rows.
SELECT o.order_number, o.total_amount, p.amount AS paid_amount
FROM orders o
JOIN payments p ON p.order_id = o.order_id
WHERE p.amount <> o.total_amount;

-- Q25 [CHECK] Cancelled prepaid orders whose payment is not REFUNDED. Expected: 0 rows.
SELECT o.order_number, o.payment_method, p.payment_status
FROM orders o
JOIN payments p ON p.order_id = o.order_id
WHERE o.order_status = 'CANCELLED' AND o.payment_method <> 'COD' AND p.payment_status <> 'REFUNDED';

-- Q26 [CHECK] Cancelled COD orders whose payment is not CANCELLED. Expected: 0 rows.
SELECT o.order_number, p.payment_status
FROM orders o
JOIN payments p ON p.order_id = o.order_id
WHERE o.order_status = 'CANCELLED' AND o.payment_method = 'COD' AND p.payment_status <> 'CANCELLED';

-- Q27 [CHECK] PAYMENT_FAILED orders whose payment status is not FAILED. Expected: 0 rows.
SELECT o.order_number, p.payment_status
FROM orders o
JOIN payments p ON p.order_id = o.order_id
WHERE o.order_status = 'PAYMENT_FAILED' AND p.payment_status <> 'FAILED';

-- Q28 [CHECK] Prepaid orders that are CONFIRMED/SHIPPED/DELIVERED without a SUCCESS payment. Expected: 0 rows.
SELECT o.order_number, o.order_status, p.payment_status
FROM orders o
JOIN payments p ON p.order_id = o.order_id
WHERE o.order_status IN ('CONFIRMED','SHIPPED','DELIVERED')
  AND o.payment_method <> 'COD'
  AND p.payment_status <> 'SUCCESS';

-- Q29 [CHECK] COD orders above the Rs.10,000 limit. Expected: 0 rows.
SELECT order_number, total_amount
FROM orders
WHERE payment_method = 'COD' AND total_amount > 10000;

-- Q30 [CHECK] Duplicate transaction IDs. Expected: 0 rows.
SELECT transaction_id, COUNT(*) AS total
FROM payments
WHERE transaction_id IS NOT NULL
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- =====================================================================
-- GROUP F: INVENTORY VALIDATION
-- =====================================================================

-- Q31 [REPORT] Low-stock and out-of-stock products (stock <= reorder level).
-- Compare with "Only N left" and "Out of Stock" labels in the UI.
SELECT p.product_id, p.product_name, i.quantity_available, i.reorder_level,
       CASE WHEN i.quantity_available = 0 THEN 'OUT OF STOCK' ELSE 'LOW STOCK' END AS stock_state
FROM products p
JOIN inventory i ON i.product_id = p.product_id
WHERE i.quantity_available <= i.reorder_level
ORDER BY i.quantity_available;

-- Q32 [CHECK] Negative stock. Expected: 0 rows (the CHECK constraint should also block it).
SELECT product_id, quantity_available
FROM inventory
WHERE quantity_available < 0;

-- Q33 [REPORT] Units sold per product (cancelled and payment-failed orders are excluded).
SELECT p.product_id, p.product_name, COALESCE(s.units, 0) AS units_sold
FROM products p
LEFT JOIN (
    SELECT oi.product_id, SUM(oi.quantity) AS units
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('CANCELLED','PAYMENT_FAILED')
    GROUP BY oi.product_id
) s ON s.product_id = p.product_id
ORDER BY units_sold DESC;

-- Q34 [VERIFY] Stock check for one order: use before/after execution of an order or cancellation test.
-- Step 1: note quantity_available BEFORE the test. Step 2: run the test in the UI. Step 3: run this query.
-- Placed order -> stock should be (before - ordered qty). Cancelled order -> stock back to (before).
SELECT o.order_number, o.order_status, p.product_name, oi.quantity AS ordered_qty, i.quantity_available AS stock_now
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
JOIN inventory i ON i.product_id = p.product_id
WHERE o.order_number = 'SE-20261022-0003';

-- =====================================================================
-- GROUP G: BUSINESS REPORTS (compare with dashboards/reports)
-- =====================================================================

-- Q35 [REPORT] Order count and value by status.
SELECT order_status, COUNT(*) AS total_orders, SUM(total_amount) AS total_value
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- Q36 [REPORT] Monthly revenue (only orders that earned revenue).
SELECT DATE_FORMAT(placed_at, '%Y-%m') AS month, COUNT(*) AS orders, SUM(total_amount) AS revenue
FROM orders
WHERE order_status IN ('CONFIRMED','SHIPPED','DELIVERED')
GROUP BY DATE_FORMAT(placed_at, '%Y-%m')
ORDER BY month;

-- Q37 [REPORT] Top customers by spend.
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer, COUNT(o.order_id) AS orders, SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_status IN ('CONFIRMED','SHIPPED','DELIVERED')
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 5;

-- Q38 [REPORT] Customers who have never placed an order.
SELECT c.customer_id, c.email, c.status
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

-- =====================================================================
-- GROUP H: NULL / BLANK VALUE CHECKS
-- =====================================================================

-- Q39 [CHECK] Mandatory text fields that are NULL or only blank spaces (customers, addresses). Expected: 0 rows.
SELECT 'customers' AS table_name, customer_id AS record_id, 'name/email/phone blank' AS problem
FROM customers
WHERE TRIM(first_name) = '' OR TRIM(last_name) = '' OR TRIM(email) = '' OR TRIM(phone) = ''
   OR first_name IS NULL OR last_name IS NULL OR email IS NULL OR phone IS NULL
UNION ALL
SELECT 'addresses', address_id, 'address field blank'
FROM addresses
WHERE TRIM(full_name) = '' OR TRIM(address_line1) = '' OR TRIM(city) = '' OR TRIM(state) = '' OR TRIM(pincode) = ''
   OR full_name IS NULL OR address_line1 IS NULL OR city IS NULL OR state IS NULL OR pincode IS NULL;

-- Q40 [CHECK] Cancellation columns: CANCELLED orders must have cancelled_at and a reason;
-- other orders must NOT have cancelled_at. Expected: 0 rows.
SELECT order_number, order_status, cancelled_at, cancellation_reason
FROM orders
WHERE (order_status = 'CANCELLED' AND (cancelled_at IS NULL OR cancellation_reason IS NULL OR TRIM(cancellation_reason) = ''))
   OR (order_status <> 'CANCELLED' AND cancelled_at IS NOT NULL);

-- Q41 [CHECK] Payment columns must be filled according to status. Expected: 0 rows.
-- SUCCESS and REFUNDED online payments need transaction_id and paid_at; FAILED needs failure_reason.
SELECT o.order_number, p.payment_method, p.payment_status, p.transaction_id, p.paid_at, p.failure_reason
FROM payments p
JOIN orders o ON o.order_id = p.order_id
WHERE (p.payment_status IN ('SUCCESS','REFUNDED') AND p.payment_method <> 'COD' AND (p.transaction_id IS NULL OR p.paid_at IS NULL))
   OR (p.payment_status = 'FAILED' AND p.failure_reason IS NULL);

-- Q42 [CHECK] COD payments must not have a transaction id and must not be marked paid while order is not delivered.
-- Expected: 0 rows.
SELECT o.order_number, o.order_status, p.payment_status, p.transaction_id
FROM payments p
JOIN orders o ON o.order_id = p.order_id
WHERE p.payment_method = 'COD'
  AND (p.transaction_id IS NOT NULL OR (p.payment_status = 'SUCCESS' AND o.order_status <> 'DELIVERED'));

-- =====================================================================
-- GROUP I: DATA INTEGRITY AND DUPLICATE CHECKS
-- =====================================================================

-- Q43 [CHECK] Orphan records (child rows whose parent is missing). Expected: every bad_rows = 0.
SELECT 'order_items without order' AS check_name, COUNT(*) AS bad_rows
FROM order_items oi LEFT JOIN orders o ON o.order_id = oi.order_id WHERE o.order_id IS NULL
UNION ALL
SELECT 'payments without order', COUNT(*)
FROM payments p LEFT JOIN orders o ON o.order_id = p.order_id WHERE o.order_id IS NULL
UNION ALL
SELECT 'cart_items without cart', COUNT(*)
FROM cart_items ci LEFT JOIN carts c ON c.cart_id = ci.cart_id WHERE c.cart_id IS NULL
UNION ALL
SELECT 'inventory without product', COUNT(*)
FROM inventory i LEFT JOIN products p ON p.product_id = i.product_id WHERE p.product_id IS NULL
UNION ALL
SELECT 'orders without customer', COUNT(*)
FROM orders o LEFT JOIN customers c ON c.customer_id = o.customer_id WHERE c.customer_id IS NULL;

-- Q44 [VERIFY] Row count of every table after loading 02_sample_data.sql (data-load check).
-- Expected on the sample data: customers 8, addresses 9, categories 6, products 13, inventory 13,
-- carts 4, cart_items 6, orders 9, order_items 13, payments 9.
SELECT 'customers' AS table_name, COUNT(*) AS total_rows FROM customers
UNION ALL SELECT 'addresses', COUNT(*) FROM addresses
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'inventory', COUNT(*) FROM inventory
UNION ALL SELECT 'carts', COUNT(*) FROM carts
UNION ALL SELECT 'cart_items', COUNT(*) FROM cart_items
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'payments', COUNT(*) FROM payments;

-- Q45 [CHECK] Date logic: order placed before the customer registered, or cancelled before it was placed.
-- Expected: 0 rows.
SELECT o.order_number, c.created_at AS customer_created, o.placed_at, o.cancelled_at
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.placed_at < c.created_at
   OR (o.cancelled_at IS NOT NULL AND o.cancelled_at < o.placed_at);

-- Q46 [CHECK] Same product appearing twice in one order. Expected: 0 rows.
SELECT order_id, product_id, COUNT(*) AS times_listed
FROM order_items
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;

-- Q47 [CHECK] Duplicate addresses for the same customer (same line 1 and pincode). Expected: 0 rows.
SELECT customer_id, address_line1, pincode, COUNT(*) AS times_saved
FROM addresses
GROUP BY customer_id, address_line1, pincode
HAVING COUNT(*) > 1;

-- Q48 [CHECK] Payment method on the payment record differs from the order's payment method. Expected: 0 rows.
SELECT o.order_number, o.payment_method AS order_method, p.payment_method AS payment_method
FROM orders o
JOIN payments p ON p.order_id = o.order_id
WHERE o.payment_method <> p.payment_method;
