SELECT
    c.company_name,
    c.contact_name,
    SUM((unit_price * quantity) * (1 - discount)) AS total_sales,
    c.country
FROM customers AS c
    INNER JOIN orders AS o ON c.customer_id = o.customer_id
    INNER JOIN order_details AS ord ON o.order_id = ord.order_id
WHERE UPPER(c.country) = 'UK'
GROUP BY 1, 2, 4
HAVING SUM((unit_price * quantity) * (1 - discount)) > 1000
ORDER BY total_sales DESC;