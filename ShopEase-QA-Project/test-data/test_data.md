# ShopEase – Test Data

All data is **fictional**. No real person, card or bank detail is used. The same data is loaded by `sql/02_sample_data.sql`.

## Users (simulated login password for every user: `Test@1234`)
| ID | Name | Email | Phone | Status | Use in tests |
|---|---|---|---|---|---|
| 1 | Ravi Kumar | ravi.kumar@example.com | 9876543210 | ACTIVE | Main user: login, cart, history (2 orders), 2 addresses |
| 2 | Sneha Reddy | sneha.reddy@example.com | 9876543211 | ACTIVE | Second user: security tests, last-unit test |
| 3 | Arjun Sharma | arjun.sharma@example.com | 9876543212 | ACTIVE | COD order in PLACED state (cancel test) |
| 4 | Priya Nair | priya.nair@example.com | 9876543213 | ACTIVE | Account lock test |
| 5 | Mohammed Faiz | faiz.mohammed@example.com | 9876543214 | ACTIVE | Failed payment order |
| 6 | Lakshmi Devi | lakshmi.devi@example.com | 9876543215 | ACTIVE | Delivered order |
| 7 | Karthik Rao | karthik.rao@example.com | 9876543216 | BLOCKED | Blocked login |
| 8 | Anita Desai | anita.desai@example.com | 9876543217 | INACTIVE | Inactive login; never ordered |
| New | Anitha Rao | anitha.rao@example.com | 9123456780 | (created in TC_REG_01) | Registration and end-to-end tests |

## Products
| ID | SKU | Name | Price | MRP | Stock | Notes |
|---|---|---|---|---|---|---|
| 1 | MOB-001 | Nova X5 Smartphone 128GB | 14999 | 17999 | 50 | Discount 17% |
| 2 | MOB-002 | Nova Lite Smartphone 64GB | 8999 | 9999 | 30 | Used for COD limit (total 10618.82) |
| 3 | ELE-001 | SoundMax Wireless Headphones | 1499 | 2999 | 100 | Search test |
| 4 | ELE-002 | ChargePro 20W Fast Charger | 599 | 999 | 200 | |
| 5 | ELE-003 | PowerMax 10000mAh Power Bank | 999 | 1499 | 8 | Low stock; stock boundary 8 and 9 |
| 6 | FAS-001 | Mens Cotton T-Shirt | 399 | 799 | 150 | Shipping fee below 500 |
| 7 | FAS-002 | Womens Printed Kurti | 699 | 1199 | 90 | |
| 8 | FTW-001 | RunFast Sports Shoes | 1999 | 3499 | 60 | Sub-category Footwear |
| 9 | HOM-001 | Steel Water Bottle 1L | 349 | 499 | 120 | Quantity 10 and 11 boundary |
| 10 | HOM-002 | Non-Stick Cookware Set | 1799 | 2999 | 25 | |
| 11 | BOK-001 | Learn SQL in 30 Days | 299 | 399 | 300 | |
| 12 | ELE-004 | Smart Watch Pro | 2999 | 5999 | 0 | Out of stock |
| 13 | BOK-002 | Notebook Pack of 5 | 250 | 300 | 200 | 2 units = exactly Rs.500 boundary |

## Simulated payment inputs
| Purpose | Input | Result |
|---|---|---|
| UPI success | UPI ID `success@shopease` | SUCCESS |
| Card decline | Simulated card number ending `0002`, any future expiry, any 3-digit CVV | FAILED |
| COD | Select Cash on Delivery (total up to Rs.10,000) | PENDING |

## Input lists for validation tests
| Field | Valid | Invalid |
|---|---|---|
| Email | anitha.rao@example.com | ravi.kumar@, ravi@.com, ravi kumar@example.com, ravi.example.com |
| Phone | 9123456780 | 12345, 5876543210, 98765abcde, 98765432101 |
| Password | Pass@1234 (9), Pass@123 (8 = minimum), 20-char with all types | abcd1234, PASSWORD@1, Password@, Pass1234, Pass@12 (7), 21 characters |
| Pincode | 517501, 500081 | 12345, 1234567, 51750A, 017501 |
| Quantity | 1, 10, stock limit | 0, -1, 11, abc, 2.5, blank |
| Search text | headphones, nova, so | a, xyzabc, `' OR 1=1 --`, `<script>alert(1)</script>` |

## Expected checkout calculations (business rules BR-09 to BR-11)
| Cart | Subtotal | Shipping | GST 18% | Total |
|---|---|---|---|---|
| SoundMax x1 + ChargePro x2 | 2697.00 | 0.00 | 485.46 | 3182.46 |
| Notebook Pack x1 | 250.00 | 40.00 | 45.00 | 335.00 |
| Notebook Pack x2 | 500.00 | 0.00 | 90.00 | 590.00 |
| Nova Lite x1 | 8999.00 | 0.00 | 1619.82 | 10618.82 |
| Mens T-Shirt x1 | 399.00 | 40.00 | 71.82 | 510.82 |

## Resetting test data
Re-run `sql/01_schema.sql` then `sql/02_sample_data.sql`. This deletes everything you created during testing.
