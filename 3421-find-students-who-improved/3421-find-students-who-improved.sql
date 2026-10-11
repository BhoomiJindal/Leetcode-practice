WITH ranked AS (
    SELECT
        student_id,
        subject,
        score,
        ROW_NUMBER() OVER (
            PARTITION BY student_id, subject
            ORDER BY exam_date
        ) AS first_rank,
        ROW_NUMBER() OVER (
            PARTITION BY student_id, subject
            ORDER BY exam_date DESC
        ) AS last_rank
    FROM Scores
)
SELECT
    f.student_id,
    f.subject,
    f.score AS first_score,
    l.score AS latest_score
FROM ranked f
JOIN ranked l
    ON f.student_id = l.student_id
   AND f.subject = l.subject
WHERE f.first_rank = 1
  AND l.last_rank = 1
  AND f.score < l.score
  AND f.student_id IN (
      SELECT student_id
      FROM Scores
      GROUP BY student_id, subject
      HAVING COUNT(*) >= 2
  )
ORDER BY f.student_id, f.subject;