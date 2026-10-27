# ShopEase – Test Strategy and Test Plan

> **Important:** ShopEase is a **fictional, simulated** application created for QA practice. No real production website was tested. Test cases are written to be executed against a simulated app or the MySQL database in `/sql`. Until you execute them, every test case stays **Not Executed**.

---

Business rules (BR-01 to BR-18) and requirements (FR-01 to FR-13) are defined in `requirements/requirements_and_business_rules.md`.

## 6. Test Strategy
**Approach:** Requirement-based manual testing with SQL back-end verification.

| Technique | How we use it |
|---|---|
| Positive testing | Valid data should work (e.g. register with correct details). |
| Negative testing | Invalid data should be rejected with a clear message. |
| Boundary Value Analysis | Test at the limits: password 7/8/20/21 characters, quantity 0/1/10/11, subtotal around Rs.500. |
| Equivalence partitioning | One sample from each group of similar inputs (e.g. invalid email styles). |
| Validation testing | Field rules, error messages, mandatory fields. |
| End-to-end testing | Full customer journeys from registration to cancellation, verified in the database. |
| Database testing | SQL queries confirm data correctness, relationships, and calculations. |
| Security-basic | Access to other users' data, script/SQL text in inputs. |

**Defect handling (summary):** Log each defect with ID, summary, steps, expected vs actual, severity, priority, status (New, Assigned, Fixed, Retest, Closed, Reopened).

| Severity | Meaning | Example |
|---|---|---|
| Critical | System unusable or money/data loss | Order total wrong, payment succeeded but order not created |
| High | Major feature broken, no workaround | Cannot add to cart |
| Medium | Feature partly wrong, workaround exists | Wrong error message |
| Low | Cosmetic | Spelling mistake |

## 7. Test Plan

| Item | Details |
|---|---|
| Test objective | Verify all 13 modules meet requirements and that database data is consistent. |
| Test deliverables | Requirements and plan (this file), test cases, SQL scripts, data dictionary, defect log, execution report. |
| Roles | QA engineer (you): design, execute, report. Developer (imaginary): fixes defects. |
| Suggested schedule | Day 1: study requirements and set up DB. Day 2-3: design test cases. Day 4-5: execute and log defects. Day 6: retest, summary report. |
| Test cycles | Cycle 1: all test cases. Cycle 2: retest of fixed defects plus regression of High priority cases. |
| Tools | MySQL 8 (Workbench or CLI), Chrome, Excel/Google Sheets, GitHub, screenshot tool. |
| Execution order | Registration, Login, Search/Categories, Cart/Quantity, Checkout/Address, Order/Payment, History, Cancellation, Inventory, End-to-end. |

## 8. Entry and Exit Criteria

| Entry criteria (start testing when) | Exit criteria (stop testing when) |
|---|---|
| Requirements and business rules are reviewed | 100% of planned test cases are executed |
| Test cases are written and reviewed | 95% or more High priority test cases pass |
| Test environment and database are ready | No open Critical or High defects |
| Test data is loaded | All fixed defects are retested |
| Build is deployed and basic smoke test passes | Test summary report is prepared and shared |

## 9. Test Environment

| Component | Details |
|---|---|
| Application | ShopEase (simulated / mock) |
| Database | MySQL 8.0.16 or later, database `shopease_db` |
| Browser | Google Chrome (latest); optional: Firefox, Edge |
| Operating system | Windows 10/11 or Linux |
| SQL client | MySQL Workbench, DBeaver or MySQL CLI |
| Test data | `sql/02_sample_data.sql` |

## 10. Test Scenarios (high level)

| Module | Scenarios |
|---|---|
| Registration | Register with valid data; duplicate email/phone; invalid formats; password rules and limits; blank fields |
| Login/Logout | Valid login; wrong password; unknown user; account lock; blocked/inactive user; session ends on logout |
| Search | Case-insensitive search; no results; minimum length; unsafe input |
| Categories/Details | Category listing incl. sub-category; product details accuracy; out-of-stock; low stock message |
| Cart | Add; add same item twice; remove; cart persists; empty cart |
| Quantity | Increase; minimum and maximum; stock limit; invalid input |
| Checkout | Login required; price summary; shipping boundary; price change |
| Address | Add valid address; mandatory fields; pincode rules; default address; other user's address |
| Order placement | Successful order; double click; refresh/back; stock gone before payment |
| Payment | UPI success; card failure; COD allowed; COD above limit; invalid card |
| Order history | Own orders only; details match DB; access to other's order |
| Cancellation | Cancel PLACED/CONFIRMED; not allowed for SHIPPED/DELIVERED; repeat cancel; reason |
| Inventory | Stock reduces; unchanged on failure; last unit by two users; never negative |
| End-to-end | Full UPI journey; COD then cancel; failed payment then retry |

## 11. Risk Assessment

| # | Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|---|
| R1 | Wrong price/tax/total calculation | High (money) | Medium | Boundary tests plus SQL checks Q16-Q18 |
| R2 | Payment status and order status mismatch | High | Medium | Payment test cases plus SQL checks Q24-Q28 |
| R3 | Stock goes negative or is not restored on cancel | High | Medium | Inventory tests plus SQL Q32, Q34 |
| R4 | One user sees another user's data | High | Low | Security-basic tests (HIS_03, ADR_05) |
| R5 | Duplicate orders on double click | High | Medium | ORD_02, ORD_03 |
| R6 | Application not available (simulated only) | Medium | High | Use DB scripts and mock pages; document limitations |
| R7 | Test data gets corrupted | Medium | Medium | Re-run 01 and 02 SQL scripts to reset |
| R8 | Requirements change late | Medium | Medium | Keep a traceability link from FR to test case IDs |

## 12. Limitations of this Project
- The application is simulated; actual results depend on what you build or mock.
- Payment gateway behaviour is assumed, not real.
- Concurrency tests (two users, last item) need two browsers/sessions.
- SQL scripts target MySQL 8.0.16+. They were written to run in order (01, 02, 03, optional 04); run them on your own MySQL to confirm.
