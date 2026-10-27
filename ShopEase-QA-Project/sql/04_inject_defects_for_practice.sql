-- =====================================================================
-- ShopEase QA Project | 04_inject_defects_for_practice.sql  (OPTIONAL)
-- Purpose: on clean data every CHECK query returns 0 rows. This script plants
-- 6 "bugs" so you can see your queries catch them and practise writing defect reports.
-- To restore clean data: re-run 01_schema.sql and then 02_sample_data.sql.
-- =====================================================================
USE shopease_db;

-- Bug 1: order total changed without changing items      -> caught by Q16, Q24
UPDATE orders SET total_amount = 3000.00 WHERE order_id = 1;

-- Bug 2: wrong shipping fee on a big order                -> caught by Q18 (and Q16)
UPDATE orders SET shipping_fee = 40.00 WHERE order_id = 2;

-- Bug 3: prepaid order cancelled but refund never done    -> caught by Q25
UPDATE payments SET payment_status = 'SUCCESS' WHERE order_id = 4;

-- Bug 4: invalid email stored for a customer              -> caught by Q04
UPDATE customers SET email = 'anita.desai.example.com' WHERE customer_id = 8;

-- Bug 5: account not locked after too many failed logins  -> caught by Q06
UPDATE customers SET failed_login_attempts = 6 WHERE customer_id = 2;

-- Bug 6: cart price not refreshed after a price change    -> caught by Q14
UPDATE cart_items SET unit_price = 1299.00 WHERE cart_id = 1 AND product_id = 3;
