/* =========================================================
   Query 02 — Turnover by role category and pay band
   ---------------------------------------------------------
   Question: Which roles and pay bands are losing the most people?
   Why it matters: tells workforce planners where attrition is
                   concentrated so interventions target the right
                   staff group.
   ---------------------------------------------------------
   Concepts used: multi-table JOIN, GROUP BY rollup, percentage
                  calculation across groups.
   Difficulty:    Intermediate
   ========================================================= */

SELECT
    jr.role_category,
    b.band_label,
    COUNT(DISTINCT s.staff_id)                                         AS headcount,
    COUNT(te.event_id)                                                 AS leavers,
    ROUND(
        100.0 * COUNT(te.event_id) / NULLIF(COUNT(DISTINCT s.staff_id), 0)
    , 1)                                                               AS turnover_pct
FROM staff s
JOIN job_roles jr ON s.role_id = jr.role_id
JOIN bands     b  ON s.band_id = b.band_id
LEFT JOIN turnover_events te
    ON s.staff_id = te.staff_id
    AND te.event_type = 'Leaver'
    AND te.event_date >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY jr.role_category, b.band_label
HAVING COUNT(DISTINCT s.staff_id) >= 20      -- ignore tiny segments
ORDER BY turnover_pct DESC, leavers DESC;
