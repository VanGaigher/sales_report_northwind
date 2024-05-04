SELECT 
	c.customer_id,
	c.company_name,
	c.contact_name,
	SUM((ord.unit_price*ord.quantity)*(1-ord.discount)) AS sales_for_customers
FROM customers as c
	INNER JOIN 
		orders AS o ON c.customer_id = o.customer_id
	INNER JOIN 
		order_details AS ord ON o.order_id = ord.order_id
GROUP BY 1,2,3
ORDER BY sales_for_customers DESC;