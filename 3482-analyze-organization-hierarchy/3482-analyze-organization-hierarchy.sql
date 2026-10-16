WITH RECURSIVE Hierarchy AS (
    SELECT
        employee_id,
        employee_name,
        manager_id,
        salary,
        1 AS level
    FROM Employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,
        e.salary,
        h.level + 1
    FROM Employees e
    JOIN Hierarchy h
        ON e.manager_id = h.employee_id
),
Reports AS (
    SELECT
        employee_id AS manager_id,
        employee_id AS report_id,
        salary
    FROM Employees

    UNION ALL

    SELECT
        r.manager_id,
        e.employee_id,
        e.salary
    FROM Reports r
    JOIN Employees e
        ON e.manager_id = r.report_id
),
Stats AS (
    SELECT
        manager_id,
        COUNT(*) - 1 AS team_size,
        SUM(salary) AS budget
    FROM Reports
    GROUP BY manager_id
)
SELECT
    h.employee_id,
    h.employee_name,
    h.level,
    s.team_size,
    s.budget
FROM Hierarchy h
JOIN Stats s
    ON h.employee_id = s.manager_id
ORDER BY
    h.level ASC,
    s.budget DESC,
    h.employee_name ASC;