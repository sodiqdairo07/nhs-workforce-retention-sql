/* =========================================================
   Query 09 — Department cost of churn (£)
   ---------------------------------------------------------
   Question: Which departments are bleeding the most money to
             staff turnover, using replacement cost as a proxy?
   Replacement cost model:
             3 months of leaver's gross salary
             + 25% recruitment/onboarding loading
             (industry standard for clinical roles).
   Why it matters: ranks departments by financial impact so a
                   workforce planning team can allocate retention
                   budget to where it pays back fastest.
   ---------------------------------------------------------
   Concepts used: multi-CTE, derived measures, joins across HR
                  and payroll, ranking with DENSE_RANK, formatted
                  monetary output.
   Difficulty:    Advanced
   ========================================================= */

WITH leaver_pay AS (
    SELECT
        te.staff_id,
        s.department_id,
        AVG(p.gross_pay_gbp) AS avg_monthly_gross
    FROM turnover_events te
    JOIN staff   s ON te.staff_id = s.staff_id
    JOIN payroll p ON p.staff_id  = te.staff_id
    WHERE te.event_type = 'Leaver'
    GROUP BY te.staff_id, s.department_id
),
dept_cost AS (
    SELECT
        d.department_id,
        d.department_name,
        h.hospital_name,
        t.trust_name,
        COUNT(lp.staff_id)                                          AS leavers,
        ROUND(AVG(lp.avg_monthly_gross), 0)                         AS avg_leaver_monthly_pay,
        ROUND(
            SUM(lp.avg_monthly_gross * 3 * 1.25)
        , 0)                                                        AS replacement_cost_gbp
    FROM departments d
    JOIN hospitals h ON d.hospital_id = h.hospital_id
    JOIN trusts    t ON h.trust_id    = t.trust_id
    LEFT JOIN leaver_pay lp ON lp.department_id = d.department_id
    GROUP BY d.department_id, d.department_name, h.hospital_name, t.trust_name
)
SELECT
    trust_name,
    hospital_name,
    department_name,
    leavers,
    avg_leaver_monthly_pay,
    replacement_cost_gbp,
    DENSE_RANK() OVER (ORDER BY replacement_cost_gbp DESC NULLS LAST) AS cost_rank
FROM dept_cost
WHERE leavers > 0
ORDER BY cost_rank
LIMIT 25;
