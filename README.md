# Query catalogue

Ten progressively complex SQL queries answering the project's central question: **which roles, departments, and trusts are losing staff fastest, and what is it costing the organisation?**

Each query stands alone, can be copy-pasted into pgAdmin, and assumes the database `nhs_workforce` has been loaded from `nhs_workforce.sql`.

| # | File | Question answered | Concepts demonstrated | Level |
|---|---|---|---|---|
| 01 | `01_kpi_overview.sql` | What are the headline workforce numbers right now? | Scalar subqueries, conditional aggregation, date arithmetic | Beginner |
| 02 | `02_turnover_by_role.sql` | Which roles and pay bands are losing the most people? | Multi-table JOIN, GROUP BY, percentage calculation | Intermediate |
| 03 | `03_leaver_reasons.sql` | What share of leavers cite each reason? | Window function (`SUM OVER`), partitioned percentages | Intermediate |
| 04 | `04_absence_compare_leavers_stayers.sql` | Did leavers show higher sickness in the year before leaving? | CTEs, CASE-WHEN labelling, LEFT JOIN with conditional filters | Intermediate |
| 05 | `05_training_compliance.sql` | Which departments fall below NHS 85% training compliance? | `FILTER` clause, RAG status logic, conditional aggregates | Intermediate |
| 06 | `06_vacancy_fill_rate.sql` | What's the fill rate and offer rate per role? | Conditional aggregation, recruitment funnel maths | Intermediate |
| 07 | `07_running_total_monthly_leavers.sql` | How is attrition trending month-over-month? | `DATE_TRUNC`, `SUM OVER`, `LAG`, rolling 3-month average | Advanced |
| 08 | `08_pay_band_attrition_cte.sql` | Within each pay band, which role categories churn fastest? | Multi-CTE, `ROW_NUMBER` peer ranking, safe NULL handling | Advanced |
| 09 | `09_department_cost_of_churn.sql` | Which departments are bleeding the most £ to churn? | Cost modelling, `DENSE_RANK`, four-way JOIN across HR and finance | Advanced |
| 10 | `10_executive_summary.sql` | One-row board-level summary of the workforce position | Parallel CTEs, `CROSS JOIN` aggregation, `TO_CHAR` formatting | Advanced |

## How to run

Open any file in pgAdmin's Query Tool against the `nhs_workforce` database and press F5. All queries use PostgreSQL syntax (the project's target database).

## Replacement-cost model used in queries 09 and 10

`3 × monthly gross pay × 1.25 onboarding loading`

This is a conservative proxy aligned with NHS Improvement's published estimates of clinical staff replacement cost. Real cost models would include agency cover, training time, and productivity loss curves.
