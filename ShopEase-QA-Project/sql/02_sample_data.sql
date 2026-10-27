-- =====================================================================
-- ShopEase QA Project | 02_sample_data.sql   (run AFTER 01_schema.sql)
-- All data is fictional. password_hash values are placeholders.
-- Simulated app login password for every sample user: Test@1234
-- Business rules used for the amounts:
--   Tax = 18% GST on subtotal | Shipping = Rs.40 if subtotal < 500 else 0
--   total = subtotal + shipping_fee + tax_amount - discount_amount
-- =====================================================================
USE shopease_db;

INSERT INTO customers (customer_id, first_name, last_name, email, phone, password_hash, status, failed_login_attempts, created_at, last_login_at) VALUES
(1,'Ravi','Kumar','ravi.kumar@example.com','9876543210','$2b$10$samplehash_ravi','ACTIVE',0,'2026-08-01 10:15:00','2026-10-20 09:30:00'),
(2,'Sneha','Reddy','sneha.reddy@example.com','9876543211','$2b$10$samplehash_sneha','ACTIVE',0,'2026-08-03 11:00:00','2026-10-18 20:10:00'),
(3,'Arjun','Sharma','arjun.sharma@example.com','9876543212','$2b$10$samplehash_arjun','ACTIVE',0,'2026-08-10 14:20:00','2026-10-22 18:45:00'),
(4,'Priya','Nair','priya.nair@example.com','9876543213','$2b$10$samplehash_priya','ACTIVE',1,'2026-08-15 09:05:00','2026-10-05 12:00:00'),
(5,'Mohammed','Faiz','faiz.mohammed@example.com','9876543214','$2b$10$samplehash_faiz','ACTIVE',0,'2026-08-20 16:40:00','2026-09-28 08:55:00'),
(6,'Lakshmi','Devi','lakshmi.devi@example.com','9876543215','$2b$10$samplehash_lakshmi','ACTIVE',0,'2026-08-25 13:30:00','2026-09-01 10:10:00'),
(7,'Karthik','Rao','karthik.rao@example.com','9876543216','$2b$10$samplehash_karthik','BLOCKED',5,'2026-09-02 17:00:00','2026-09-30 22:15:00'),
(8,'Anita','Desai','anita.desai@example.com','9876543217','$2b$10$samplehash_anita','INACTIVE',0,'2026-09-05 12:00:00',NULL);

INSERT INTO addresses (address_id, customer_id, full_name, phone, address_line1, address_line2, city, state, pincode, address_type, is_default) VALUES
(1,1,'Ravi Kumar','9876543210','12-4 Gandhi Road',NULL,'Tirupati','Andhra Pradesh','517501','HOME',1),
(2,1,'Ravi Kumar','9876543210','Plot 21, Madhapur','Near Metro Station','Hyderabad','Telangana','500081','WORK',0),
(3,2,'Sneha Reddy','9876543211','8-2-120 Banjara Hills',NULL,'Hyderabad','Telangana','500034','HOME',1),
(4,3,'Arjun Sharma','9876543212','45 MG Road',NULL,'Bengaluru','Karnataka','560001','HOME',1),
(5,4,'Priya Nair','9876543213','7 Anna Salai',NULL,'Chennai','Tamil Nadu','600001','HOME',1),
(6,5,'Mohammed Faiz','9876543214','22 Marine Drive',NULL,'Mumbai','Maharashtra','400001','HOME',1),
(7,6,'Lakshmi Devi','9876543215','5-9 Beach Road',NULL,'Visakhapatnam','Andhra Pradesh','530001','HOME',1),
(8,7,'Karthik Rao','9876543216','16 FC Road',NULL,'Pune','Maharashtra','411001','HOME',1),
(9,3,'Arjun Sharma','9876543212','10 Connaught Place','3rd Floor','New Delhi','Delhi','110001','WORK',0);

INSERT INTO categories (category_id, category_name, parent_category_id, is_active) VALUES
(1,'Electronics',NULL,1),
(2,'Fashion',NULL,1),
(3,'Home & Kitchen',NULL,1),
(4,'Books',NULL,1),
(5,'Mobiles',1,1),
(6,'Footwear',2,1);

INSERT INTO products (product_id, category_id, sku, product_name, description, price, mrp, max_qty_per_order, is_active) VALUES
(1,5,'MOB-001','Nova X5 Smartphone 128GB','6.5 inch display, 50MP camera, 5000mAh battery',14999.00,17999.00,10,1),
(2,5,'MOB-002','Nova Lite Smartphone 64GB','6.1 inch display, 13MP camera',8999.00,9999.00,10,1),
(3,1,'ELE-001','SoundMax Wireless Headphones','Bluetooth 5.0, 20 hours battery',1499.00,2999.00,10,1),
(4,1,'ELE-002','ChargePro 20W Fast Charger','USB-C fast charger with cable',599.00,999.00,10,1),
(5,1,'ELE-003','PowerMax 10000mAh Power Bank','Dual USB output, 10000mAh',999.00,1499.00,10,1),
(6,2,'FAS-001','Mens Cotton T-Shirt','100% cotton, regular fit',399.00,799.00,10,1),
(7,2,'FAS-002','Womens Printed Kurti','Cotton blend, printed',699.00,1199.00,10,1),
(8,6,'FTW-001','RunFast Sports Shoes','Lightweight running shoes',1999.00,3499.00,10,1),
(9,3,'HOM-001','Steel Water Bottle 1L','Stainless steel, leak proof',349.00,499.00,10,1),
(10,3,'HOM-002','Non-Stick Cookware Set (3 pcs)','Induction base, non-stick coating',1799.00,2999.00,10,1),
(11,4,'BOK-001','Learn SQL in 30 Days','Beginner friendly SQL book',299.00,399.00,10,1),
(12,1,'ELE-004','Smart Watch Pro','Heart rate and sleep tracking',2999.00,5999.00,10,1),
(13,4,'BOK-002','Notebook Pack of 5','Ruled notebooks, 200 pages each',250.00,300.00,10,1);

INSERT INTO inventory (product_id, quantity_available, reorder_level) VALUES
(1,50,10),(2,30,10),(3,100,10),(4,200,20),(5,8,10),(6,150,20),(7,90,15),
(8,60,10),(9,120,20),(10,25,5),(11,300,30),(12,0,10),(13,200,25);

INSERT INTO carts (cart_id, customer_id, status, created_at) VALUES
(1,1,'ACTIVE','2026-10-20 09:35:00'),
(2,2,'ACTIVE','2026-10-18 20:15:00'),
(3,3,'CONVERTED','2026-10-22 18:50:00'),
(4,5,'ABANDONED','2026-09-28 09:00:00');

INSERT INTO cart_items (cart_id, product_id, quantity, unit_price) VALUES
(1,3,1,1499.00),(1,9,2,349.00),
(2,8,1,1999.00),
(3,6,2,399.00),(3,9,1,349.00),
(4,12,1,2999.00);

INSERT INTO orders (order_id, order_number, customer_id, shipping_address_id, order_status, payment_method, subtotal, shipping_fee, discount_amount, tax_amount, total_amount, placed_at, cancelled_at, cancellation_reason) VALUES
(1,'SE-20260915-0001',1,1,'DELIVERED','UPI',2697.00,0.00,0.00,485.46,3182.46,'2026-09-15 11:20:00',NULL,NULL),
(2,'SE-20260918-0002',2,3,'SHIPPED','CREDIT_CARD',14999.00,0.00,0.00,2699.82,17698.82,'2026-09-18 15:05:00',NULL,NULL),
(3,'SE-20261022-0003',3,4,'PLACED','COD',1147.00,0.00,0.00,206.46,1353.46,'2026-10-22 18:55:00',NULL,NULL),
(4,'SE-20260925-0004',4,5,'CANCELLED','NET_BANKING',1999.00,0.00,0.00,359.82,2358.82,'2026-09-25 10:10:00','2026-09-26 09:00:00','Changed my mind'),
(5,'SE-20260928-0005',5,6,'PAYMENT_FAILED','DEBIT_CARD',8999.00,0.00,0.00,1619.82,10618.82,'2026-09-28 09:05:00',NULL,NULL),
(6,'SE-20261005-0006',1,2,'CONFIRMED','UPI',1597.00,0.00,150.00,287.46,1734.46,'2026-10-05 19:30:00',NULL,NULL),
(7,'SE-20260901-0007',6,7,'DELIVERED','UPI',3197.00,0.00,0.00,575.46,3772.46,'2026-09-01 10:10:00',NULL,NULL),
(8,'SE-20261002-0008',2,3,'CANCELLED','COD',599.00,0.00,0.00,107.82,706.82,'2026-10-02 12:00:00','2026-10-03 08:30:00','Ordered by mistake'),
(9,'SE-20260910-0009',4,5,'DELIVERED','CREDIT_CARD',399.00,40.00,0.00,71.82,510.82,'2026-09-10 16:45:00',NULL,NULL);

-- line_total is a generated column, so it is NOT inserted
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1,3,1,1499.00),(1,4,2,599.00),
(2,1,1,14999.00),
(3,6,2,399.00),(3,9,1,349.00),
(4,8,1,1999.00),
(5,2,1,8999.00),
(6,11,2,299.00),(6,5,1,999.00),
(7,7,2,699.00),(7,10,1,1799.00),
(8,4,1,599.00),
(9,6,1,399.00);

INSERT INTO payments (order_id, transaction_id, payment_method, payment_status, amount, paid_at, failure_reason) VALUES
(1,'TXN260915000101','UPI','SUCCESS',3182.46,'2026-09-15 11:21:10',NULL),
(2,'TXN260918000102','CREDIT_CARD','SUCCESS',17698.82,'2026-09-18 15:06:00',NULL),
(3,NULL,'COD','PENDING',1353.46,NULL,NULL),
(4,'TXN260925000104','NET_BANKING','REFUNDED',2358.82,'2026-09-25 10:11:00',NULL),
(5,'TXN260928000105','DEBIT_CARD','FAILED',10618.82,NULL,'Insufficient funds (simulated)'),
(6,'TXN261005000106','UPI','SUCCESS',1734.46,'2026-10-05 19:31:00',NULL),
(7,'TXN260901000107','UPI','SUCCESS',3772.46,'2026-09-01 10:11:00',NULL),
(8,NULL,'COD','CANCELLED',706.82,NULL,NULL),
(9,'TXN260910000109','CREDIT_CARD','SUCCESS',510.82,'2026-09-10 16:46:00',NULL);
