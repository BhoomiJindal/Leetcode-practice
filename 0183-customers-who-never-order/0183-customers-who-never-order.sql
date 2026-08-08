SELECT c.name AS Customers
FROM Customers c
LEFT OUTER JOIN Orders o
ON c.id = o.customerId
WHERE c.id NOT IN (SELECT customerId FROM Orders);