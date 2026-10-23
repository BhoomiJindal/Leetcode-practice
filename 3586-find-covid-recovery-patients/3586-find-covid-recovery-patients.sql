WITH FirstPositive AS (
    SELECT
        patient_id,
        MIN(test_date) AS positive_date
    FROM covid_tests
    WHERE result = 'Positive'
    GROUP BY patient_id
),
FirstNegative AS (
    SELECT
        fp.patient_id,
        fp.positive_date,
        MIN(ct.test_date) AS negative_date
    FROM FirstPositive fp
    JOIN covid_tests ct
        ON fp.patient_id = ct.patient_id
        AND ct.result = 'Negative'
        AND ct.test_date > fp.positive_date
    GROUP BY
        fp.patient_id,
        fp.positive_date
)
SELECT
    p.patient_id,
    p.patient_name,
    p.age,
    DATEDIFF(fn.negative_date, fn.positive_date) AS recovery_time
FROM FirstNegative fn
JOIN patients p
    ON fn.patient_id = p.patient_id
ORDER BY
    recovery_time ASC,
    p.patient_name ASC;# Write your MySQL query statement below
