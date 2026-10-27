# ShopEase – Interview Guide and Resume Description

Be honest in interviews. This is a **practice project on a simulated application**. Say it clearly, then show what you did and what you learned. Interviewers respect honesty and can easily test whether you understand your own project.

## 1. Two-minute project explanation (example script)
"ShopEase is a fictional e-commerce application that I used to build a complete manual testing and SQL validation project. There was no real production site, so I defined the business rules myself, for example 18% GST, free shipping from Rs.500, a maximum of 10 items per product, and cash on delivery only up to Rs.10,000.

I wrote a requirements and test plan document, then 67 manual test cases for 13 modules: registration, login, search, cart, checkout, payment, order history, cancellation and inventory. They include positive, negative, boundary and end-to-end cases. For example, I tested password lengths 7, 8, 20 and 21, and a subtotal of exactly Rs.500 for the shipping rule.

I also designed a MySQL database with 10 tables and wrote 48 SQL queries. A manual test checks what the screen shows; the SQL queries check what was really saved. For example, after an order I check that the order total equals items plus tax plus shipping, that the payment amount matches, and that stock was reduced. I mapped every test case to a requirement and to SQL queries in a traceability matrix, and I wrote 10 sample defect reports to practise bug reporting.

The test cases are prepared and marked Not Executed; I execute them when I have an application build. I chose this project to show how I think about testing, not only the tools I know."

## 2. Resume project description
**ShopEase – E-Commerce Manual Testing and SQL Database Validation (Practice Project)**
*Tools: Manual testing, MySQL, Excel, Markdown, GitHub*
- Analysed requirements and defined 18 business rules and 13 functional requirements for a simulated e-commerce application.
- Designed 67 manual test cases (positive, negative, boundary, validation, end-to-end) across 13 modules, with a Requirement Traceability Matrix.
- Designed a 10-table MySQL schema with primary keys, foreign keys and CHECK constraints, and wrote 48 SQL queries to validate customers, carts, orders, payments and inventory.
- Prepared a test plan, entry and exit criteria, risk assessment, defect tracker, execution tracker and report templates; wrote 10 sample defect reports with severity and priority.
- Published the project on GitHub with documentation.

(Do not write "executed" or give pass percentages on your resume until you have actually executed the tests.)

## 3. Questions you may be asked, with short answer ideas
**Q: Why test the database in a manual testing project?**
A: A screen can show success while the stored data is wrong, for example a wrong total, a missing payment record or stock not reduced. SQL gives proof.

**Q: What is the difference between severity and priority?**
A: Severity is the technical or business impact of the defect. Priority is how soon it should be fixed. Example: a misspelled brand name has low severity but can have high priority. See `bug-reports/sample_defect_reports.md`.

**Q: Explain boundary value analysis with an example from your project.**
A: Quantity limit is 1 to 10, so I test 0, 1, 10 and 11. Free shipping starts at Rs.500, so I test subtotals 250 and 500 using one and two Notebook Packs.

**Q: What did you check after placing an order?**
A: Order exists, order items correct, amounts add up (Q16 to Q18), payment row with the same amount and correct status (Q23, Q24, Q28), stock reduced (Q34), and no duplicates (Q30, Q46).

**Q: What is a LEFT JOIN and where did you use it?**
A: It returns all rows from the left table even when there is no match on the right. I used it to find orders without payments (Q23) and customers who never ordered (Q38).

**Q: Why does one of your queries return rows that are "bad"?**
A: Check queries return only wrong records. Zero rows means the data is correct. If rows come back, I raise a defect.

**Q: How do you decide the expected result when there is no real requirement document?**
A: I write assumptions and business rules first and get them reviewed. Expected results come from those rules, not from what the application does.

**Q: What is an RTM and why is it useful?**
A: It links requirements to test cases and queries. It shows missing coverage and tells me which tests to repeat when a requirement changes.

**Q: Which tests would you automate first?**
A: Stable, repeated, high-risk flows such as login, checkout calculation and the SQL CHECK queries. Manual testing stays for exploratory and usability checks.

**Q: What are entry and exit criteria?**
A: Entry criteria say when testing can start (build ready, data loaded). Exit criteria say when it can stop (all tests run, no open Critical or High defects).

**Q: Did you really run these tests?**
A: Answer truthfully. For example: "The SQL scripts were checked in an SQLite translation and I ran them in MySQL myself. The UI test cases are ready and marked Not Executed until I have a build." Use only what is true for you.

## 4. Things to practise before an interview
1. Load the database and run every query yourself. Explain each query without reading it.
2. Run `04_inject_defects_for_practice.sql` and explain how each bug is found.
3. Execute at least 10 test cases against any simple mock page or form you build, and write real defect reports.
4. Explain three test cases in detail: one boundary, one negative, one end-to-end.
