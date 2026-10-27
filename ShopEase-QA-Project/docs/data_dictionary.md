# ShopEase – Data Dictionary

Database: `shopease_db` (MySQL 8.0.16+). PK = primary key, FK = foreign key.

## Relationship summary
```
customers 1---* addresses
customers 1---* carts 1---* cart_items *---1 products
customers 1---* orders 1---* order_items *---1 products
orders    1---1 payments
orders    *---1 addresses   (shipping address)
categories 1---* products  (categories also self-link: parent -> sub-category)
products  1---1 inventory
```

## customers – registered users
| Column | Type | Notes |
|---|---|---|
| customer_id | INT PK, auto | Unique user ID |
| first_name, last_name | VARCHAR(30) | Letters only (BR-03) |
| email | VARCHAR(100) UNIQUE | Login ID |
| phone | CHAR(10) UNIQUE | CHECK: 10 digits starting 6-9 |
| password_hash | VARCHAR(255) | Encrypted password; plain text must never be stored |
| status | ENUM | ACTIVE, INACTIVE, BLOCKED |
| failed_login_attempts | TINYINT | Wrong password counter; 5 means BLOCKED |
| created_at, last_login_at | DATETIME | Registration and last successful login time |

## addresses – delivery addresses
| Column | Type | Notes |
|---|---|---|
| address_id | INT PK | |
| customer_id | INT FK -> customers | Owner (deleted with customer) |
| full_name, phone | | Receiver details |
| address_line1/2, city, state | VARCHAR | Line 1, city, state mandatory |
| pincode | CHAR(6) | CHECK: 6 digits, first digit 1-9 |
| address_type | ENUM | HOME, WORK, OTHER |
| is_default | TINYINT(1) | 1 = default address; each active customer should have exactly one |

## categories – product groups
| Column | Type | Notes |
|---|---|---|
| category_id | INT PK | |
| category_name | VARCHAR(60) UNIQUE | |
| parent_category_id | INT FK -> categories (nullable) | NULL = main category; Mobiles sits under Electronics |
| is_active | TINYINT(1) | |

## products – items for sale
| Column | Type | Notes |
|---|---|---|
| product_id | INT PK | |
| category_id | INT FK -> categories | |
| sku | VARCHAR(20) UNIQUE | Stock keeping code |
| product_name, description | | Shown on the product page |
| price | DECIMAL(10,2) | Selling price, CHECK > 0 |
| mrp | DECIMAL(10,2) | Maximum retail price, CHECK mrp >= price; used for "x% off" |
| max_qty_per_order | TINYINT | Default 10 (BR-08) |
| is_active | TINYINT(1) | 0 hides the product |

## inventory – stock per product
| Column | Type | Notes |
|---|---|---|
| inventory_id | INT PK | |
| product_id | INT FK UNIQUE | One row per product |
| quantity_available | INT | CHECK >= 0 (cannot go negative) |
| reorder_level | INT | Low-stock threshold |
| last_updated | DATETIME | Auto-updated on every change |

## carts – one shopping cart per visit/session
| Column | Type | Notes |
|---|---|---|
| cart_id | INT PK | |
| customer_id | INT FK | |
| status | ENUM | ACTIVE (in use), CONVERTED (became an order), ABANDONED |
| created_at, updated_at | DATETIME | |

## cart_items – products inside a cart
| Column | Type | Notes |
|---|---|---|
| cart_item_id | INT PK | |
| cart_id | INT FK (cascade delete) | |
| product_id | INT FK | UNIQUE with cart_id: same product cannot repeat in a cart |
| quantity | TINYINT | CHECK 1 to 10 |
| unit_price | DECIMAL(10,2) | Price when added |
| added_at | DATETIME | |

## orders – placed orders
| Column | Type | Notes |
|---|---|---|
| order_id | INT PK | |
| order_number | VARCHAR(20) UNIQUE | Format SE-YYYYMMDD-NNNN, shown to customer |
| customer_id | INT FK | |
| shipping_address_id | INT FK -> addresses | Must belong to same customer |
| order_status | ENUM | PLACED, CONFIRMED, SHIPPED, DELIVERED, CANCELLED, PAYMENT_FAILED |
| payment_method | ENUM | UPI, CREDIT_CARD, DEBIT_CARD, NET_BANKING, COD |
| subtotal, shipping_fee, discount_amount, tax_amount, total_amount | DECIMAL(10,2) | total = subtotal + shipping + tax - discount |
| placed_at, cancelled_at | DATETIME | cancelled_at filled only for cancelled orders |
| cancellation_reason | VARCHAR(200) | |

## order_items – products inside an order
| Column | Type | Notes |
|---|---|---|
| order_item_id | INT PK | |
| order_id | INT FK (cascade delete) | |
| product_id | INT FK | UNIQUE with order_id |
| quantity | TINYINT | CHECK 1 to 10 |
| unit_price | DECIMAL(10,2) | Price at the time of order (history is preserved) |
| line_total | DECIMAL(12,2) generated | quantity x unit_price; calculated by MySQL, never inserted |

## payments – simulated payment records
| Column | Type | Notes |
|---|---|---|
| payment_id | INT PK | |
| order_id | INT FK UNIQUE | One payment per order |
| transaction_id | VARCHAR(30) UNIQUE, nullable | NULL for COD |
| payment_method | ENUM | Same list as orders |
| payment_status | ENUM | PENDING, SUCCESS, FAILED, REFUNDED, CANCELLED |
| amount | DECIMAL(10,2) | Must equal order total |
| paid_at | DATETIME | NULL if not paid |
| failure_reason | VARCHAR(150) | Filled for failed payments |

## Order and payment status combinations (expected)
| Order status | Prepaid payment status | COD payment status |
|---|---|---|
| PLACED | n/a (COD only) | PENDING |
| CONFIRMED / SHIPPED / DELIVERED | SUCCESS | PENDING until delivered, then SUCCESS |
| CANCELLED | REFUNDED | CANCELLED |
| PAYMENT_FAILED | FAILED | n/a |
