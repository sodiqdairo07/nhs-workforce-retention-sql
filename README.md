# NHS Workforce Retention Analysis

**An SQL portfolio project investigating staff turnover, absence patterns, and the financial cost of churn across a simulated NHS Trust network.**

---

## The business question

> **Which roles, departments, and trusts are losing staff fastest — and what is it costing the organisation?**

NHS workforce retention is one of the most pressing operational challenges in UK healthcare. Vacancies in nursing and Allied Health Professional (AHP) roles regularly exceed 10% of established posts, and the cost of replacing a single qualified clinician has been estimated by the King's Fund at over £30,000 once recruitment, onboarding, and lost productivity are accounted for. This project uses SQL to dissect a realistic NHS workforce dataset and surface the levers a workforce planning team could pull to reduce attrition.

The analysis answers six connected sub-questions:

1. What is the overall annual turnover rate, and how does it break down by role category, department, and pay band?
2. Which leaver reasons dominate, and how do they differ across staff groups?
3. Is there a measurable difference in sickness absence between staff who later left and those who stayed?
4. How does training compliance correlate with attrition risk?
5. What is the estimated replacement cost of staff lost in the last 12 months?
6. Where should management intervene first to deliver the largest retention impact for the least effort?

---

## Headline findings

| Metric | Value |
| --- | --- |
| Active staff (current) | **2,758** |
| Leavers in last 12 months | **146** |
| Annual turnover rate | **5.3%** |
| Top leaver reason | Resignation — Work-Life Balance (20% of leavers) |
| Highest-attrition role category | AHP (55 leavers), narrowly ahead of Nursing (54) |
| Top department for leavers | Patient Records (21 leavers) |
| Estimated replacement cost (12mo) | **£1.27 million** |
| Mandatory training compliance (overall) | **60.0%** |

> The training compliance figure is a flag — NHS expected standards typically sit above 85%. This dataset surfaces it as a candidate operational risk that an analyst would escalate.

---

## Dataset

![NHS Workforce Schema ERD](schema_erd.png)

The schema models a small NHS-flavoured Trust network: 10 NHS Trusts → 30 hospital sites → 150 departments → 3,000 staff, with full HR operational data layered on top.

**15 tables, ~53,000 rows:**

| Domain | Tables |
| --- | --- |
| Organisation | `trusts`, `hospitals`, `departments` |
| Role framework | `bands` (NHS Agenda for Change), `job_roles` |
| People | `staff`, `employment_contracts` |
| Operations | `shifts`, `shift_assignments` |
| HR | `absences`, `vacancies`, `recruitment_applications`, `turnover_events` |
| Compliance & finance | `training_records`, `payroll` |

The data is **synthetic but realistic**: NHS Agenda for Change pay bands use actual 2024 salary ranges; role categories (Medical, Nursing, AHP, Admin, Estates) follow NHS Digital workforce taxonomy; ratios for turnover (~5%), absence patterns, contract mix, and ethnicity distribution are calibrated against published NHS workforce statistics. No real patient or staff data was used at any point.

---

## Approach

1. **Data modelling.** A normalised relational schema with 15 tables and 18 foreign keys, designed to support analytical queries across HR, operations, and finance simultaneously.
2. **Headline KPIs.** Single-statement aggregations to establish the overall picture — total headcount, turnover rate, average tenure.
3. **Segmentation.** GROUP BY queries slicing attrition by role, department, band, gender, and ethnicity.
4. **Comparative analysis.** Self-joins and CTEs comparing leavers vs. stayers across sickness, training compliance, and pay.
5. **Window functions.** Running totals of monthly leavers, rank of departments by attrition cost, period-over-period change in vacancy fill rate.
6. **Cost modelling.** A final query that monetises the findings — replacement cost per leaver × leavers per department = where the money is leaking.

---

## Repository contents

- `README.md` — this file
- `nhs_workforce.sql` — schema + sample data (run once to load)
- `schema_erd.png` — entity-relationship diagram
- `queries/` — folder containing 10 numbered SQL files
- `screenshots/` — folder containing query output captures

---

## How to reproduce

1. Install PostgreSQL 15+ and pgAdmin 4.
2. Create a database called `nhs_workforce`.
3. Open `nhs_workforce.sql` in pgAdmin's Query Tool and press F5 to load the schema and data.
4. Run any query in the `queries/` folder against the `nhs_workforce` database.

Expected load time: under 5 seconds on a modern machine. Total disk footprint: ~3 MB.

---

## Tech stack

- **Database:** PostgreSQL 18
- **Client:** pgAdmin 4
- **SQL features demonstrated:** multi-table JOINs (INNER, LEFT, SELF), CTEs, window functions (ROW_NUMBER, LAG, SUM OVER), filtered aggregates, conditional aggregation, date arithmetic, subqueries, and views.

---

## About the data

This dataset was generated programmatically to support relational SQL practice at a level of complexity that public NHS open data (typically pre-aggregated single-table CSVs) cannot offer. The schema, ratios, and pay bands are modelled on real NHS workforce structures, but no individual record corresponds to a real person, department, or trust. The aim is to demonstrate analytical thinking and SQL fluency, not to publish findings about the actual NHS.

For analyses based on real NHS data, see NHS Digital Workforce Statistics at digital.nhs.uk.

---

## Author

**Sodiq Dairo** — Data analyst portfolio project, May 2026.
