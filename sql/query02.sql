WITH MonthlyRevenue AS (
	SELECT
		EXTRACT (YEAR FROM o.order_date) AS year,
		EXTRACT (MONTH FROM o.order_date) AS month,
		SUM ((os.unit_price*os.quantity)*(1.0-os.discount)) AS total_revenue
	FROM
		orders AS o
	INNER JOIN
		order_details AS os ON o.order_id = os.order_id
	GROUP BY 1, 2
	),
	
AcumulatedRevenue AS (
	SELECT
		year,
		month,
		total_revenue,
		SUM (total_revenue) OVER (PARTITION BY year ORDER BY month) AS acumulated_revenue 
	FROM
		MonthlyRevenue
)
 SELECT 
 	year,
	month,
	acumulated_revenue,
	total_revenue- LAG(total_revenue) OVER (PARTITION BY year ORDER BY month) AS month_difference,
	(total_revenue - LAG(total_revenue) OVER (PARTITION BY year ORDER BY month)) / LAG(total_revenue) OVER (PARTITION BY year ORDER BY month) * 100 AS month_difference_percentual
 FROM AcumulatedRevenue
 ORDER BY 1, 2;