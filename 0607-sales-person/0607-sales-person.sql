SELECT s.name
FROM SalesPerson s
WHERE NOT EXISTS (
    SELECT o.order_id
    FROM Orders o
    JOIN Company c
    ON o.com_id = c.com_id
    WHERE o.sales_id = s.sales_id
    AND c.name = 'RED');