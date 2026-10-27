# ShopEase – Execution and Reporting Templates

All templates start **empty or Not Executed**. Do not write a pass percentage before real execution. The Excel workbook `ShopEase_QA_Workbook.xlsx` already contains the Execution Tracker, Defect Tracker and RTM with working formulas.

---
## 1. How to record results and count them
1. Run the test case steps exactly as written.
2. Compare the **real behaviour** with the **Expected Result**. Write what you saw in **Actual Result** (facts, not opinions).
3. Set **Status**:
   - **Pass** – actual result matches expected result.
   - **Fail** – actual result differs. Log a defect and write its ID in the tracker.
   - **Blocked** – you cannot run the test (environment down, earlier defect stops the flow). Write the reason.
   - **Not Executed** – not yet run (starting status of every test case).
4. Counts: Total = number of test cases. Executed = Pass + Fail + Blocked. Not Executed = Total - Executed.
5. Pass % = Pass / Executed x 100 (use Executed, not Total, when the cycle is still running). Execution progress % = Executed / Total x 100.
6. Example of the arithmetic only (not real results): if a cycle had 10 tests with 6 Pass, 2 Fail, 1 Blocked, 1 Not Executed then Executed = 9, Pass % = 6/9 = 66.7%, progress = 90%.

---
## 2. Test execution tracker (template)
| TC ID | Module | Priority | Status | Executed by | Date | Actual result | Defect ID | Remarks |
|---|---|---|---|---|---|---|---|---|
| TC_REG_01 | User Registration | High | Not Executed | | | | | |
| TC_REG_02 | User Registration | High | Not Executed | | | | | |
| (one row for every test case, 67 in total) | | | | | | | | |

## 3. Defect tracker (template)
| Bug ID | Type (ACTUAL/SAMPLE) | Summary | Module | Linked TC | Severity | Priority | Status | Reported by | Reported date | Assigned to | Fixed in build | Retest result |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| BUG-001 | ACTUAL | | | | | | New | | | | | |

## 4. Requirement Traceability Matrix (template)
| Requirement ID | Test Case ID | Manual test | Related table | SQL query ID | Expected database state | Execution status |
|---|---|---|---|---|---|---|
The filled matrix is in `traceability-matrix/requirement_traceability_matrix.md`.

## 5. Daily testing report (template)
**Project:** ShopEase  **Date:** ____  **Prepared by:** ____  **Build:** ____  **Cycle:** ____

| Item | Count |
|---|---|
| Test cases planned for today | |
| Executed today | |
| Pass | |
| Fail | |
| Blocked | |
| Not Executed (remaining in cycle) | |
| New defects raised | |
| Defects fixed and retested | |
| Open Critical / High defects | |

**Work done today:** ____

**Blockers and risks:** ____

**Plan for tomorrow:** ____

**SQL validation notes (queries run, any non-zero CHECK results):** ____

## 6. Final test summary report (template)
**1. Project and build tested:** ____
**2. Scope tested / not tested:** ____
**3. Test environment:** ____
**4. Test execution summary**
| Total | Executed | Pass | Fail | Blocked | Not Executed | Pass % (of executed) |
|---|---|---|---|---|---|---|
| | | | | | | |

**5. Results by module**
| Module | Total | Pass | Fail | Blocked | Not Executed |
|---|---|---|---|---|---|

**6. Defect summary**
| Severity | Total | Open | Closed |
|---|---|---|---|
| Critical | | | |
| High | | | |
| Medium | | | |
| Low | | | |

**7. Requirement coverage:** requirements with all tests executed ___ of 13

**8. Database validation summary:** list the CHECK queries that returned rows and the defect IDs raised.

**9. Open risks and known issues:** ____

**10. Exit criteria check** (from `test-plan/test_plan.md`)
| Criterion | Met? (Yes/No) | Evidence |
|---|---|---|
| All planned test cases executed | | |
| 95% or more High priority tests pass | | |
| No open Critical or High defects | | |
| Fixed defects retested | | |

**11. Conclusion and recommendation (Go / No-Go):** ____
**12. Sign-off:** ____
