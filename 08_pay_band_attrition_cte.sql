/* =========================================================
   Query 08 — Pay band attrition with peer-group ranking
   ---------------------------------------------------------
   Question: Within each NHS pay band, which role categories
             lose people fastest? Rank them so the worst offenders
             surface first.
   Why it matters: pay band tells you the cost of replacing
                   someone; role category tells you the skill
                   shortage. Combining them shows where churn
                   hurts most.
   ---------------------------------------------------------
   Concepts used: multiple CTEs, JOIN to derived table, ROW_NUMBER
                  for ranking within partitions, NULLIF + ROUND
                  for safe rate maths.
   Difficulty:    Advanced
   ========================================================= */

WITH band_role_headcount AS (
    SELECT
        b.band_label,
        jr.role_category,
        COUNT(*) AS headcount
    FROM staff s
    JOIN bands     b  ON s.band_id = b.band_id
    JOIN job_roles jr ON s.role_id = jr.role_id
    GROUP BY b.band_label, jr.role_category
),
band_role_leavers AS (
    SELECT
        b.band_label,
        jr.role_category,
        COUNT(*) AS leavers
    FROM turnover_events te
    JOIN staff     s  ON te.staff_id = s.staff_id
    JOIN bands     b  ON s.band_id   = b.band_id
    JOIN job_roles jr ON s.role_id   = jr.role_id
    WHERE te.event_type = 'Leaver'
    GROUP BY b.band_label, jr.role_category
),
combined AS (
    SELECT
        h.band_label,
        h.role_category,
        h.headcount,
        COALESCE(l.leavers, 0)                                  AS leavers,
        ROUND(
            100.0 * COALESCE(l.leavers, 0) / NULLIF(h.headcount, 0)
        , 1)                                                    AS turnover_pct
    FROM band_role_headcount h
    LEFT JOIN band_role_leavers l
        ON h.band_label   = l.band_label
        AND h.role_category = l.role_category
)
SELECT
    band_label,
    role_category,
    headcount,
    leavers,
    turnover_pct,
    ROW_NUMBER() OVER (PARTITION BY band_label ORDER BY turnover_pct DESC, leavers DESC)
                                                                AS rank_within_band
FROM combined
WHERE headcount >= 10                          -- statistical floor
ORDER BY band_label, rank_within_band;
