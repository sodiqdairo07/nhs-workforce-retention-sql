/* =========================================================
   Query 07 — Monthly leavers with running total and MoM change
   ---------------------------------------------------------
   Question: How is attrition trending month over month, and what
             does the cumulative leaver count look like over the
             year?
   Why it matters: trend analysis lets leadership see whether
                   recent retention efforts are working.
   ---------------------------------------------------------
   Concepts used: DATE_TRUNC for grouping by month, two WINDOW
                  functions (SUM OVER for running total, LAG for
                  month-over-month change), CTE for clean structure.
   Difficulty:    Advanced
   ========================================================= */

WITH monthly_leavers AS (
    SELECT
        DATE_TRUNC('month', event_date)::DATE AS month,
        COUNT(*)                              AS leavers
    FROM turnover_events
    WHERE event_type = 'Leaver'
      AND event_date >= CURRENT_DATE - INTERVAL '18 months'
    GROUP BY DATE_TRUNC('month', event_date)
)
SELECT
    month,
    leavers,
    SUM(leavers) OVER (ORDER BY month)                          AS running_total,
    LAG(leavers) OVER (ORDER BY month)                          AS prev_month_leavers,
    leavers - LAG(leavers) OVER (ORDER BY month)                AS mom_change,
    ROUND(
        100.0 * (leavers - LAG(leavers) OVER (ORDER BY month))
              / NULLIF(LAG(leavers) OVER (ORDER BY month), 0)
    , 1)                                                        AS mom_change_pct,
    ROUND(
        AVG(leavers) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
    , 1)                                                        AS rolling_3mo_avg
FROM monthly_leavers
ORDER BY month;
