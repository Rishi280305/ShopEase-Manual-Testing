# ShopEase – E-Commerce Manual Testing and SQL Database Validation

A portfolio project for **Manual Tester / QA Tester** roles. It contains requirements and business rules, a test plan, 67 manual test cases, a MySQL database, 48 SQL validation queries, a requirement traceability matrix, sample defect reports, report templates, and an Excel workbook.

> **Important:** ShopEase is a **simulated, fictional** application. No real website was tested. All test cases are **Not Executed** and all defects are **samples** until you run the tests yourself. No pass percentage is claimed anywhere.

## Technologies
Manual testing, MySQL 8.0.16+, Excel (workbook with formulas), Markdown, GitHub.

## Project structure
```
ShopEase-QA-Project/
├── README.md
├── ShopEase_QA_Workbook.xlsx          Test cases, execution tracker, defect tracker, RTM, summary (formulas)
├── requirements/
│   └── requirements_and_business_rules.md   Overview, scope, assumptions, BR-01..BR-18, FR-01..FR-13
├── test-plan/
│   └── test_plan.md                   Strategy, plan, entry/exit criteria, environment, scenarios, risks
├── test-cases/
│   └── manual_test_cases.md           67 test cases
├── traceability-matrix/
│   └── requirement_traceability_matrix.md   Requirement -> test case -> table -> SQL query -> expected DB state
├── bug-reports/
│   └── sample_defect_reports.md       10 SIMULATED defects + severity vs priority
├── sql/
│   ├── 01_schema.sql                  Database and 10 tables
│   ├── 02_sample_data.sql             Fictional data
│   ├── 03_validation_queries.sql      48 queries (Q01..Q48)
│   └── 04_inject_defects_for_practice.sql   Optional: plants 6 bugs
├── test-data/
│   └── test_data.md                   Users, products, payment inputs, valid/invalid values
├── reports/
│   └── execution_and_reporting_templates.md   Trackers, daily report, final summary, how to count results
├── docs/
│   ├── data_dictionary.md             Tables and columns
│   ├── sql_query_guide.md             What each query validates, why, correct result, defect meaning
│   └── interview_guide.md             Interview explanation and resume text
└── screenshots/                       Put your own evidence here (see below)
```

## Setup
1. Install MySQL 8.0.16 or later and a client (MySQL Workbench, DBeaver or CLI).
2. Run the scripts in order:
```
mysql -u root -p < sql/01_schema.sql
mysql -u root -p < sql/02_sample_data.sql
mysql -u root -p < sql/03_validation_queries.sql
```
3. All CHECK queries should return 0 rows on the clean data. Optionally run `04_inject_defects_for_practice.sql` to see the queries catch bugs, then re-run 01 and 02 to reset.
4. Open `ShopEase_QA_Workbook.xlsx`, go to **Execution Tracker**, and record results as you execute test cases. The **Summary** sheet updates by itself.

## Suggested learning order
1. `requirements/requirements_and_business_rules.md` (understand the rules)
2. `test-plan/test_plan.md`
3. `test-cases/manual_test_cases.md`
4. `docs/data_dictionary.md` and `sql/` scripts
5. `docs/sql_query_guide.md`
6. `traceability-matrix/requirement_traceability_matrix.md`
7. `bug-reports/sample_defect_reports.md`
8. `reports/execution_and_reporting_templates.md`
9. `docs/interview_guide.md`

## Verification status (honest)
- The SQL scripts were **not executed on a MySQL server** while preparing this project. They were run through a translation into SQLite to check table and column names, foreign keys and query logic. Re-run them in MySQL and treat your own results as the real evidence. Details are in `docs/sql_query_guide.md`.
- No UI test case has been executed.

## Screenshots (add your own after execution)
Create files such as `screenshots/TC_REG_01_actual.png` and `screenshots/Q16_result.png`, then list them here:

| Evidence | File | Related test / query |
|---|---|---|
| (none yet) | | |

## Limitations
The application and payment gateway are simulated, there is one payment per order, concurrency tests need two browser sessions, and automation is not included.
