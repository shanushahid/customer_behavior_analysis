SELECT TOP 20 * FROM customer_data

-- Q1. what is the totl revenue generate by male vs female cutomers?
select gender, SUM([purchase_amount_(usd)])  as revenue
from customer_data
group by gender



--Q2. Which customers used a discount but still spent more than the average purchase amount?
select customer_id, [purchase_amount_(usd)]
from customer_data
where discount_applied = 'Yes' and [purchase_amount_(usd)] >= (select AVG([purchase_amount_(usd)]) from customer_data)



-- Q3. Which are the top 5 products with the highest average review rating?
SELECT TOP 5 
    item_purchased,
    ROUND(AVG(CAST(review_rating AS FLOAT)), 2) AS [Average Product Rating]
FROM customer_data
GROUP BY item_purchased
ORDER BY AVG(CAST(review_rating AS FLOAT)) DESC;



--Q4.Compare the average purchase Amounts between standard and Express shipping
SELECT 
    shipping_type,
    ROUND(AVG(CAST([purchase_amount_(usd)] AS FLOAT)), 2) AS avg_purchase
FROM customer_data
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type;



--Q5 Do subscribed customers spend more? Compare average spend and total revenue
-- between subscribers and non-subscribers.
SELECT  
    subscription_status,
    COUNT(customer_id) AS total_customers,
    ROUND(AVG([purchase_amount_(usd)]), 2) AS avg_spend,
    ROUND(SUM([purchase_amount_(usd)]), 2) AS total_revenue
FROM customer_data
GROUP BY subscription_status
ORDER BY total_revenue DESC, avg_spend DESC;




--Q6 Which 5 product have the highest percentage of purchase with discount applied?
SELECT TOP 5
    item_purchased,
    ROUND(
        (SUM(CASE 
                WHEN discount_applied = 'Yes' THEN 1 
                ELSE 0 
             END) * 100.0) / COUNT(*),
        2
    ) AS discount_rate
FROM customer_data
GROUP BY item_purchased
ORDER BY discount_rate DESC;




--Q7. Segment customers into New, Returning, and loyal based on their total
-- number of previous purchases, and show the count of each segment.
WITH customer_type AS (
    SELECT 
        customer_id, 
        previous_purchases,
        CASE
            WHEN previous_purchases = 1 THEN 'New'
            WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
            ELSE 'Loyal'
        END AS customer_segment
    FROM customer_data
)

SELECT 
    customer_segment, 
    COUNT(*) AS [Number of Customers]
FROM customer_type
GROUP BY customer_segment;



--Q8. What are the top 3 most purchased products within each category?
WITH item_counts AS ( 
    SELECT 
        category,
        item_purchased,
        COUNT(customer_id) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY category 
            ORDER BY COUNT(customer_id) DESC
        ) AS item_rank
    FROM customer_data
    GROUP BY category, item_purchased
)

SELECT 
    item_rank, 
    category, 
    item_purchased, 
    total_orders
FROM item_counts
WHERE item_rank <= 3;



-- Q9. Are customers who are repeat buyers (more than 5 previous purchase) also likely to subscribe?
select subscription_status,
count (customer_id) as repeat_buyers
from customer_data
where previous_purchases > 5
group by subscription_status





--Q10. What is the revenue contribution of each age group?
SELECT 
    age_group,
    SUM([purchase_amount_(usd)]) AS total_revenue
FROM customer_data
GROUP BY age_group
ORDER BY total_revenue DESC;