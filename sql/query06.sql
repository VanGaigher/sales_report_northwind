SELECT
	p.product_name,
	SUM(ord.quantity) AS total_unity,
	SUM ((ord.quantity * ord.unit_price)* (1-ord.discount)) AS sales
FROM
	order_details AS ord
INNER JOIN products AS p ON ord.product_id = p.product_id
GROUP BY 1
ORDER BY 3 DESC;