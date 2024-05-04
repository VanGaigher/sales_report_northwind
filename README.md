# Northwind Sales Report

## Introduction

In the corporate environment, the ability to extract valuable insights from data is essential for strategic decision-making. This current project is based on advanced reporting from the Northwind database using SQL language. This repository aims to provide different analyses that can be applied in structured companies of all sizes, giving them support to transform themselves into a more analytical organization.  

## Goal:

The main goal of this project is to provide analytical tools which are able to help companies to understand better their data and, for consequence, taking more informated and strategics iniformations
Using SQL queries, will be explored differents aspects from NorthWind database, since revenue analysis until customers segmentation and the top sellers products.

## Setup:

To iniciate it will be necessary setup the development envieroment. It could be done manually, using the file ##### to create the NorthWind database.
The other choice (and I suppose to be the best one) is using Docker and Docker Compose, following the steps provided above:

< STEPS TO USE DOCKER FILES>

## Context:

The Northwind database is a representation of an ERP (Enterprise Resource Planning) system that contains a variety of data related to the operations of a fictitious company called Northwind Traders. With tables ranging from customer and product information to order and inventory details, Northwind offers a wealth of data for analysis.

The Northwind dataset includes sample data for the following:

- Vendors: Northwind Suppliers & Vendors
- Customers: Customers who purchase products from Northwind
- Employees: Northwind Traders Employee Details
- Products: Product Information
- Carriers: The details of the carriers that ship the products from merchants to end customers
- Orders and Order Details: Sales order transactions taking place between customers and the company

 The Northwind database includes 14 tables, and the relationships between the tables are shown in the following entity relationship diagram.

![northwind](https://github.com/VanGaigher/sales_report_northwind/blob/main/pics/northwind_relationship.png)

# Analysis

## REVENUE
* 1- What were the revenue in 1997?
``` sql
SELECT SUM((order_details.unit_price) * order_details.quantity * (1.0 - order_details.discount)) AS total_revenues_1997
FROM order_details
INNER JOIN (
    SELECT order_id 
    FROM orders 
    WHERE EXTRACT(YEAR FROM order_date) = '1997'
) AS ord 
ON ord.order_id = order_details.order_id;
```

* 2- Monthly Growth Analysis and YTD Calculation
``` sql
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

```

## CUSTOMERS

* 3- How much each customers paid until "now"?

```sql
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
```
* 4- Separate customers into 5 groups according to the amount paid per customer.

```sql
SELECT 
	c.customer_id,
	c.company_name,
	c.contact_name,
	SUM((ord.unit_price*ord.quantity)*(1-ord.discount)) AS sales_for_customers,
	NTILE(5) OVER (ORDER BY SUM((ord.unit_price*ord.quantity)*(1-ord.discount)))
FROM customers as c
	INNER JOIN 
		orders AS o ON c.customer_id = o.customer_id
	INNER JOIN 
		order_details AS ord ON o.order_id = ord.order_id
GROUP BY 1,2,3
ORDER BY sales_for_customers DESC;
```

* 5- Select only the customers who are in groups 4 and 5 for a targeted marketing analysis to be made.

```sql
WITH MarketingCampaign AS (
	SELECT 
		c.customer_id,
		c.company_name,
		c.contact_name,
		SUM((ord.unit_price*ord.quantity)*(1-ord.discount)) AS sales_for_customers,
		NTILE(5) OVER (ORDER BY SUM((ord.unit_price*ord.quantity)*(1-ord.discount))) AS customers_group
	FROM customers as c
		INNER JOIN 
			orders AS o ON c.customer_id = o.customer_id
		INNER JOIN 
			order_details AS ord ON o.order_id = ord.order_id
	GROUP BY 1,2,3
	ORDER BY sales_for_customers DESC
	)
SELECT 
	*
FROM MarketingCampaign
WHERE customers_group BETWEEN 4 AND 5;
```
 