/* =========================================================
   Query 10 — Executive summary (the headline KPIs in one shot)
   ---------------------------------------------------------
   Question: If a board member asked for one query that
             summarises the entire workforce position, what
             would I send?
   ---------------------------------------------------------
   Concepts used: parallel CTEs producing scalar metrics,
                  CROSS JOIN to combine them into one row,
                  string formatting for monetary output.
   Difficulty:    Advanced
   Output:        single-row executive dashboard.
   ========================================================= */

WITH headcount AS (
    SELECT
        COUNT(*) FILTER (WHERE is_active)                                     AS active_staff,
        COUNT(*)                                                              AS total_staff
    FROM staff
),
turnover AS (
    SELECT
        COUNT(*) FILTER (WHERE event_type = 'Leaver'
                           AND event_date >= CURRENT_DATE - INTERVAL '12 months')
                                                                              AS leavers_12mo,
        COUNT(*) FILTER (WHERE event_type = 'Joiner'
                           AND event_date >= CURRENT_DATE - INTERVAL '12 months')
                                                                              AS joiners_12mo
    FROM turnover_events
),
financial_impact AS (
    SELECT
        SUM(p.gross_pay_gbp * 3 * 1.25) AS replacement_cost_gbp
    FROM turnover_events te
    JOIN payroll p ON te.staff_id = p.staff_id
    WHERE te.event_type = 'Leaver'
      AND te.event_date >= CURRENT_DATE - INTERVAL '12 months'
),
absence AS (
    SELECT
        ROUND(
            SUM(days_absent)::NUMERIC
            / NULLIF((SELECT COUNT(*) FROM staff WHERE is_active), 0)
        , 2) AS sick_days_per_head_12mo
    FROM absences
    WHERE reason NOT IN
        ('Annual Leave','Maternity Leave','Paternity Leave','Study Leave','Compassionate Leave')
    AND start_date >= CURRENT_DATE - INTERVAL '12 months'
),
recruitment AS (
    SELECT
        COUNT(*) FILTER (WHERE status IN ('Open','Shortlisting','Interviewing')) AS open_vacancies,
        ROUND(
            100.0 * COUNT(*) FILTER (WHERE status = 'Filled') / NULLIF(COUNT(*), 0)
        , 1) AS fill_rate_pct
    FROM vacancies
),
training AS (
    SELECT
        ROUND(
            100.0 * COUNT(*) FILTER (WHERE status = 'Valid') / NULLIF(COUNT(*), 0)
        , 1) AS training_compliance_pct
    FROM training_records
)
SELECT
    h.active_staff,
    t.leavers_12mo,
    t.joiners_12mo,
    ROUND(100.0 * t.leavers_12mo / NULLIF(h.active_staff, 0), 1) AS annual_turnover_pct,
    t.joiners_12mo - t.leavers_12mo                              AS net_workforce_change,
    '£' || TO_CHAR(fi.replacement_cost_gbp, 'FM999,999,999')     AS est_replacement_cost,
    a.sick_days_per_head_12mo,
    r.open_vacancies,
    r.fill_rate_pct,
    tr.training_compliance_pct
FROM headcount h
CROSS JOIN turnover         t
CROSS JOIN financial_impact fi
CROSS JOIN absence          a
CROSS JOIN recruitment      r
CROSS JOIN training         tr;
