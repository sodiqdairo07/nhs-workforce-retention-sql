/* =========================================================
   Query 06 — Vacancy fill rate and recruitment funnel
   ---------------------------------------------------------
   Question: For each role, how many vacancies are open vs filled,
             how many applications did each receive, and what
             share of applicants reached the offer stage?
   Why it matters: a high turnover rate combined with a low fill
                   rate is the worst combination for any workforce
                   planning team.
   ---------------------------------------------------------
   Concepts used: subquery joining recruitment_applications to
                  vacancies, conditional aggregation, rate math.
   Difficulty:    Intermediate
   ========================================================= */

SELECT
    jr.role_title,
    COUNT(DISTINCT v.vacancy_id)                                          AS total_vacancies,
    COUNT(DISTINCT v.vacancy_id) FILTER (WHERE v.status = 'Filled')       AS filled_vacancies,
    COUNT(DISTINCT v.vacancy_id) FILTER (WHERE v.status = 'Closed Unfilled')
                                                                          AS closed_unfilled,
    ROUND(
        100.0 * COUNT(DISTINCT v.vacancy_id) FILTER (WHERE v.status = 'Filled')
              / NULLIF(COUNT(DISTINCT v.vacancy_id), 0)
    , 1)                                                                  AS fill_rate_pct,
    COUNT(ra.application_id)                                              AS total_applications,
    ROUND(
        COUNT(ra.application_id)::NUMERIC
              / NULLIF(COUNT(DISTINCT v.vacancy_id), 0)
    , 1)                                                                  AS applications_per_vacancy,
    COUNT(ra.application_id) FILTER (WHERE ra.application_stage IN ('Offer Made','Hired'))
                                                                          AS offers_or_hires,
    ROUND(
        100.0 * COUNT(ra.application_id) FILTER (WHERE ra.application_stage IN ('Offer Made','Hired'))
              / NULLIF(COUNT(ra.application_id), 0)
    , 1)                                                                  AS offer_rate_pct
FROM vacancies v
JOIN job_roles jr ON v.role_id = jr.role_id
LEFT JOIN recruitment_applications ra ON ra.vacancy_id = v.vacancy_id
GROUP BY jr.role_title
HAVING COUNT(DISTINCT v.vacancy_id) >= 3
ORDER BY fill_rate_pct, total_vacancies DESC;
