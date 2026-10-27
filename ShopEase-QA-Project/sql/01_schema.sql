-- =====================================================================
-- ShopEase QA Project | 01_schema.sql
-- Requires MySQL 8.0.16+ (CHECK constraints are enforced from this version)
-- Run order: 01_schema.sql -> 02_sample_data.sql -> 03_validation_queries.sql
-- WARNING: this script DROPS and recreates shopease_db (practice database only)
-- =====================================================================
DROP DATABASE IF EXISTS shopease_db;
CREATE DATABASE shopease_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE shopease_db;

-- 1. customers -------------------------------------------------------
CREATE TABLE customers (
  customer_id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  first_name            VARCHAR(30)  NOT NULL,
  last_name             VARCHAR(30)  NOT NULL,
  email                 VARCHAR(100) NOT NULL,
  phone                 CHAR(10)     NOT NULL,
  password_hash         VARCHAR(255) NOT NULL,
  status                ENUM('ACTIVE','INACTIVE','BLOCKED') NOT NULL DEFAULT 'ACTIVE',
  failed_login_attempts TINYINT UNSIGNED NOT NULL DEFAULT 0,
  created_at            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_login_at         DATETIME     NULL,
  PRIMARY KEY (customer_id),
  UNIQUE KEY uq_customers_email (email),
  UNIQUE KEY uq_customers_phone (phone),
  CONSTRAINT chk_customers_phone CHECK (phone REGEXP '^[6-9][0-9]{9}$')
) ENGINE=InnoDB;

-- 2. addresses -------------------------------------------------------
CREATE TABLE addresses (
  address_id     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  customer_id    INT UNSIGNED NOT NULL,
  full_name      VARCHAR(60)  NOT NULL,
  phone          CHAR(10)     NOT NULL,
  address_line1  VARCHAR(100) NOT NULL,
  address_line2  VARCHAR(100) NULL,
  city           VARCHAR(50)  NOT NULL,
  state          VARCHAR(50)  NOT NULL,
  pincode        CHAR(6)      NOT NULL,
  address_type   ENUM('HOME','WORK','OTHER') NOT NULL DEFAULT 'HOME',
  is_default     TINYINT(1)   NOT NULL DEFAULT 0,
  PRIMARY KEY (address_id),
  KEY idx_addresses_customer (customer_id),
  CONSTRAINT fk_addresses_customer FOREIGN KEY (customer_id)
    REFERENCES customers (customer_id) ON DELETE CASCADE,
  CONSTRAINT chk_addresses_pincode CHECK (pincode REGEXP '^[1-9][0-9]{5}$'),
  CONSTRAINT chk_addresses_phone   CHECK (phone REGEXP '^[6-9][0-9]{9}$')
) ENGINE=InnoDB;

-- 3. categories (self-referencing for sub-categories) ----------------
CREATE TABLE categories (
  category_id        INT UNSIGNED NOT NULL AUTO_INCREMENT,
  category_name      VARCHAR(60)  NOT NULL,
  parent_category_id INT UNSIGNED NULL,
  is_active          TINYINT(1)   NOT NULL DEFAULT 1,
  PRIMARY KEY (category_id),
  UNIQUE KEY uq_categories_name (category_name),
  CONSTRAINT fk_categories_parent FOREIGN KEY (parent_category_id)
    REFERENCES categories (category_id)
) ENGINE=InnoDB;

-- 4. products ---------------------------------------------------------
CREATE TABLE products (
  product_id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  category_id        INT UNSIGNED NOT NULL,
  sku                VARCHAR(20)  NOT NULL,
  product_name       VARCHAR(120) NOT NULL,
  description        VARCHAR(500) NULL,
  price              DECIMAL(10,2) NOT NULL,
  mrp                DECIMAL(10,2) NOT NULL,
  max_qty_per_order  TINYINT UNSIGNED NOT NULL DEFAULT 10,
  is_active          TINYINT(1)   NOT NULL DEFAULT 1,
  created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (product_id),
  UNIQUE KEY uq_products_sku (sku),
  KEY idx_products_category (category_id),
  CONSTRAINT fk_products_category FOREIGN KEY (category_id)
    REFERENCES categories (category_id),
  CONSTRAINT chk_products_price CHECK (price > 0),
  CONSTRAINT chk_products_mrp   CHECK (mrp >= price)
) ENGINE=InnoDB;

-- 5. inventory (one row per product) ---------------------------------
CREATE TABLE inventory (
  inventory_id       INT UNSIGNED NOT NULL AUTO_INCREMENT,
  product_id         INT UNSIGNED NOT NULL,
  quantity_available INT NOT NULL DEFAULT 0,
  reorder_level      INT NOT NULL DEFAULT 10,
  last_updated       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (inventory_id),
  UNIQUE KEY uq_inventory_product (product_id),
  CONSTRAINT fk_inventory_product FOREIGN KEY (product_id)
    REFERENCES products (product_id),
  CONSTRAINT chk_inventory_qty CHECK (quantity_available >= 0)
) ENGINE=InnoDB;

-- 6. carts --------------------------------------------------------------
CREATE TABLE carts (
  cart_id     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  customer_id INT UNSIGNED NOT NULL,
  status      ENUM('ACTIVE','CONVERTED','ABANDONED') NOT NULL DEFAULT 'ACTIVE',
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (cart_id),
  KEY idx_carts_customer (customer_id),
  CONSTRAINT fk_carts_customer FOREIGN KEY (customer_id)
    REFERENCES customers (customer_id)
) ENGINE=InnoDB;

-- 7. cart_items ---------------------------------------------------------
CREATE TABLE cart_items (
  cart_item_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  cart_id      INT UNSIGNED NOT NULL,
  product_id   INT UNSIGNED NOT NULL,
  quantity     TINYINT UNSIGNED NOT NULL DEFAULT 1,
  unit_price   DECIMAL(10,2) NOT NULL,
  added_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (cart_item_id),
  UNIQUE KEY uq_cart_product (cart_id, product_id),
  CONSTRAINT fk_cart_items_cart    FOREIGN KEY (cart_id)    REFERENCES carts (cart_id) ON DELETE CASCADE,
  CONSTRAINT fk_cart_items_product FOREIGN KEY (product_id) REFERENCES products (product_id),
  CONSTRAINT chk_cart_items_qty    CHECK (quantity BETWEEN 1 AND 10),
  CONSTRAINT chk_cart_items_price  CHECK (unit_price > 0)
) ENGINE=InnoDB;

-- 8. orders -------------------------------------------------------------
CREATE TABLE orders (
  order_id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_number        VARCHAR(20)  NOT NULL,
  customer_id         INT UNSIGNED NOT NULL,
  shipping_address_id INT UNSIGNED NOT NULL,
  order_status        ENUM('PLACED','CONFIRMED','SHIPPED','DELIVERED','CANCELLED','PAYMENT_FAILED') NOT NULL DEFAULT 'PLACED',
  payment_method      ENUM('UPI','CREDIT_CARD','DEBIT_CARD','NET_BANKING','COD') NOT NULL,
  subtotal            DECIMAL(10,2) NOT NULL,
  shipping_fee        DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  discount_amount     DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  tax_amount          DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  total_amount        DECIMAL(10,2) NOT NULL,
  placed_at           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  cancelled_at        DATETIME NULL,
  cancellation_reason VARCHAR(200) NULL,
  PRIMARY KEY (order_id),
  UNIQUE KEY uq_orders_number (order_number),
  KEY idx_orders_customer (customer_id),
  KEY idx_orders_status (order_status),
  CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)         REFERENCES customers (customer_id),
  CONSTRAINT fk_orders_address  FOREIGN KEY (shipping_address_id) REFERENCES addresses (address_id),
  CONSTRAINT chk_orders_amounts CHECK (subtotal >= 0 AND shipping_fee >= 0 AND discount_amount >= 0 AND tax_amount >= 0 AND total_amount >= 0)
) ENGINE=InnoDB;

-- 9. order_items --------------------------------------------------------
CREATE TABLE order_items (
  order_item_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id      INT UNSIGNED NOT NULL,
  product_id    INT UNSIGNED NOT NULL,
  quantity      TINYINT UNSIGNED NOT NULL,
  unit_price    DECIMAL(10,2) NOT NULL,
  line_total    DECIMAL(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
  PRIMARY KEY (order_item_id),
  UNIQUE KEY uq_order_product (order_id, product_id),
  CONSTRAINT fk_order_items_order   FOREIGN KEY (order_id)   REFERENCES orders (order_id) ON DELETE CASCADE,
  CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES products (product_id),
  CONSTRAINT chk_order_items_qty    CHECK (quantity BETWEEN 1 AND 10),
  CONSTRAINT chk_order_items_price  CHECK (unit_price > 0)
) ENGINE=InnoDB;

-- 10. payments (simulated gateway: one payment record per order) --------
CREATE TABLE payments (
  payment_id     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id       INT UNSIGNED NOT NULL,
  transaction_id VARCHAR(30) NULL,
  payment_method ENUM('UPI','CREDIT_CARD','DEBIT_CARD','NET_BANKING','COD') NOT NULL,
  payment_status ENUM('PENDING','SUCCESS','FAILED','REFUNDED','CANCELLED') NOT NULL DEFAULT 'PENDING',
  amount         DECIMAL(10,2) NOT NULL,
  paid_at        DATETIME NULL,
  failure_reason VARCHAR(150) NULL,
  PRIMARY KEY (payment_id),
  UNIQUE KEY uq_payments_order (order_id),
  UNIQUE KEY uq_payments_txn (transaction_id),
  CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES orders (order_id),
  CONSTRAINT chk_payments_amount CHECK (amount > 0)
) ENGINE=InnoDB;
