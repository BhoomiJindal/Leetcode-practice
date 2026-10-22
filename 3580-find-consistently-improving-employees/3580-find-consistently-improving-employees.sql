WITH RankedReviews AS (
    SELECT
        employee_id,
        review_date,
        rating,
        ROW_NUMBER() OVER (
            PARTITION BY employee_id
            ORDER BY review_date DESC
        ) AS rn
    FROM performance_reviews
),
LastThree AS (
    SELECT
        employee_id,
        MAX(CASE WHEN rn = 1 THEN rating END) AS latest_rating,
        MAX(CASE WHEN rn = 2 THEN rating END) AS second_rating,
        MAX(CASE WHEN rn = 3 THEN rating END) AS earliest_rating
    FROM RankedReviews
    WHERE rn <= 3
    GROUP BY employee_id
    HAVING COUNT(*) = 3
)
SELECT
    e.employee_id,
    e.name,
    (lt.latest_rating - lt.earliest_rating) AS improvement_score
FROM LastThree lt
JOIN employees e
    ON lt.employee_id = e.employee_id
WHERE lt.latest_rating > lt.second_rating
  AND lt.second_rating > lt.earliest_rating
ORDER BY
    improvement_score DESC,
    e.name ASC;