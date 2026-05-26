/* =========================================================
   Query 04 — Did leavers show warning signs in their absences?
   ---------------------------------------------------------
   Question: In the 12 months before leaving, did people who
             eventually left have higher sickness absence than
             those who stayed?
   Why it matters: if absence is a leading indicator of
                   attrition, HR can flag at-risk staff early.
   ---------------------------------------------------------
   Concepts used: CTEs, CASE-WHEN labelling, LEFT JOIN to handle
                  staff with zero absences, comparative aggregation.
   Difficulty:    Intermediate
   ========================================================= */

WITH staff_status AS (
    SELECT
        s.staff_id,
        CASE
            WHEN te.staff_id IS NOT NULL THEN 'Leaver'
            ELSE 'Stayer'
        END AS status_group
    FROM staff s
    LEFT JOIN turnover_events te
        ON s.staff_id = te.staff_id
        AND te.event_type = 'Leaver'
),
absence_days AS (
    SELECT
        ss.status_group,
        ss.staff_id,
        COALESCE(SUM(a.days_absent), 0) AS sick_days
    FROM staff_status ss
    LEFT JOIN absences a
        ON ss.staff_id = a.staff_id
        AND a.reason NOT IN
            ('Annual Leave','Maternity Leave','Paternity Leave','Study Leave','Compassionate Leave')
        AND a.start_date >= CURRENT_DATE - INTERVAL '12 months'
    GROUP BY ss.status_group, ss.staff_id
)
SELECT
    status_group,
    COUNT(*)                                AS staff_in_group,
    ROUND(AVG(sick_days), 2)                AS avg_sick_days_per_head,
    ROUND(
        100.0 * SUM(CASE WHEN sick_days > 0 THEN 1 ELSE 0 END) / COUNT(*)
    , 1)                                    AS pct_with_any_sickness,
    MAX(sick_days)                          AS max_sick_days
FROM absence_days
GROUP BY status_group
ORDER BY status_group;
