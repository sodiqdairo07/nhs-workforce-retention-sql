/* =========================================================
   Query 03 — Why are people leaving?
   ---------------------------------------------------------
   Question: What share of leavers cite each reason, and which
             role categories are most affected by each?
   Why it matters: 'Resignation - Work Life Balance' implies
                   different interventions than 'Retirement'.
   ---------------------------------------------------------
   Concepts used: WINDOW function (SUM OVER), nested ranking
                  per group, JOIN to add staff context.
   Difficulty:    Intermediate
   ========================================================= */

SELECT
    te.reason,
    jr.role_category,
    COUNT(*)                                              AS leavers,
    SUM(COUNT(*)) OVER (PARTITION BY te.reason)           AS total_for_reason,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER ()
    , 1)                                                  AS pct_of_all_leavers,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY te.reason)
    , 1)                                                  AS pct_within_reason
FROM turnover_events te
JOIN staff      s  ON te.staff_id = s.staff_id
JOIN job_roles  jr ON s.role_id   = jr.role_id
WHERE te.event_type = 'Leaver'
GROUP BY te.reason, jr.role_category
ORDER BY total_for_reason DESC, leavers DESC;
