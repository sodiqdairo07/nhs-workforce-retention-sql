/* =========================================================
   Query 05 — Mandatory training compliance by department
   ---------------------------------------------------------
   Question: Which departments are below the NHS 85% compliance
             threshold for mandatory training, and on which modules?
   Why it matters: training non-compliance is a Care Quality
                   Commission risk and correlates with absence and
                   incident rates.
   ---------------------------------------------------------
   Concepts used: FILTER (PostgreSQL) for conditional aggregates,
                  multi-table JOIN, threshold flagging.
   Difficulty:    Intermediate
   ========================================================= */

SELECT
    d.department_name,
    tr.module_name,
    COUNT(*)                                                              AS records,
    COUNT(*) FILTER (WHERE tr.status = 'Valid')                           AS valid_records,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE tr.status = 'Valid') / COUNT(*)
    , 1)                                                                  AS compliance_pct,
    CASE
        WHEN 100.0 * COUNT(*) FILTER (WHERE tr.status = 'Valid') / COUNT(*) >= 85.0
            THEN 'Above target'
        WHEN 100.0 * COUNT(*) FILTER (WHERE tr.status = 'Valid') / COUNT(*) >= 70.0
            THEN 'Watch'
        ELSE 'Below target'
    END                                                                   AS rag_status
FROM training_records tr
JOIN staff       s ON tr.staff_id     = s.staff_id
JOIN departments d ON s.department_id = d.department_id
GROUP BY d.department_name, tr.module_name
ORDER BY compliance_pct, d.department_name, tr.module_name;
