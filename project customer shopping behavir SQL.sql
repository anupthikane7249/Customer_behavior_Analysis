USE customer_shopping;

SELECT * FROM customer_shopping LIMIT 10;

-- Q1. what is the total revenue genrated by mal vs female customer?

USE customer_shopping;

SELECT
    gender,
    SUM(purchase_amount) AS total_revenue
FROM customer_shopping
GROUP BY gender;


-- Q2. which customers used a discount but still spent more than the avrage purchase amount?

SELECT *
FROM customer_shopping
WHERE discount_applied = 'Yes'
  AND purchase_amount > (
      SELECT AVG(purchase_amount)
      FROM customer_shopping
  );

-- Q3.which are the top 5 product with the highest avarge review rating?
SELECT
    item_purchased,
    AVG(review_rating) AS average_rating
FROM customer_shopping
GROUP BY item_purchased
ORDER BY average_rating DESC
LIMIT 5;

-- Q4.compare the avarge purchase amounts between standerd and express shipping?
SELECT
    shipping_type,
    AVG(purchase_amount) AS average_purchase_amount
FROM customer_shopping
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type;

-- Q5.do subscibed customers spend more? compare avarge spend and total revenue between subscribers and non- subscribers?
SELECT
    subscription_status,
    AVG(purchase_amount) AS average_spend,
    SUM(purchase_amount) AS total_revenue
FROM customer_shopping
GROUP BY subscription_status;

-- Q6.which 5 products have the highest percentage of purchse with discount applied?
SELECT
    item_purchased,
    COUNT(*) AS total_purchases,
    SUM(CASE
        WHEN discount_applied = 'Yes' THEN 1
        ELSE 0
    END) AS discounted_purchases,
    ROUND(
        100.0 * SUM(CASE
            WHEN discount_applied = 'Yes' THEN 1
            ELSE 0
        END) / COUNT(*), 2
    ) AS discount_percentage
FROM customer_shopping
GROUP BY item_purchased
ORDER BY discount_percentage DESC
LIMIT 5;

-- Q7.segment customer into new, returning ,and loyel based on their total number of previous purchases and show the count of each segment?
SELECT
    CASE
        WHEN previous_purchases = 1 THEN 'New'
        WHEN previous_purchases BETWEEN 2 AND 5 THEN 'Returning'
        WHEN previous_purchases > 5 THEN 'Loyal'
        ELSE 'Other'
    END AS customer_segment,
    COUNT(*) AS customer_count
FROM customer_shopping
GROUP BY customer_segment
ORDER BY customer_count DESC;

-- Q8.what are the top 3 most purchsed products withion each category?
WITH product_counts AS (
    SELECT
        category,
        item_purchased,
        COUNT(*) AS total_purchases,
        DENSE_RANK() OVER (
            PARTITION BY category
            ORDER BY COUNT(*) DESC
        ) AS product_rank
    FROM customer_shopping
    GROUP BY category, item_purchased
)
SELECT
    category,
    item_purchased,
    total_purchases,
    product_rank
FROM product_counts
WHERE product_rank <= 3
ORDER BY category, product_rank;

-- Q9.are custmore who are repeat buyers(more than 5 purchase)also likely to subscribe?
SELECT
    CASE
        WHEN previous_purchases > 5 THEN 'Repeat Buyer'
        ELSE 'Other Customer'
    END AS customer_type,
    subscription_status,
    COUNT(*) AS total_customers,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (PARTITION BY
            CASE
                WHEN previous_purchases > 5 THEN 'Repeat Buyer'
                ELSE 'Other Customer'
            END
        ), 2
    ) AS percentage
FROM customer_shopping
GROUP BY customer_type, subscription_status
ORDER BY customer_type, subscription_status;

-- Q10.what is the revenue contrubution of each age group?
SELECT
    age_group,
    total_revenue,
    ROUND(
        100.0 * total_revenue /
        (SELECT SUM(purchase_amount)
         FROM customer_shopping),
        2
    ) AS revenue_percentage
FROM (
    SELECT
        CASE
            WHEN age < 20 THEN 'Under 20'
            WHEN age BETWEEN 20 AND 29 THEN '20-29'
            WHEN age BETWEEN 30 AND 39 THEN '30-39'
            WHEN age BETWEEN 40 AND 49 THEN '40-49'
            WHEN age BETWEEN 50 AND 59 THEN '50-59'
            ELSE '60+'
        END AS age_group,
        SUM(purchase_amount) AS total_revenue
    FROM customer_shopping
    GROUP BY
        CASE
            WHEN age < 20 THEN 'Under 20'
            WHEN age BETWEEN 20 AND 29 THEN '20-29'
            WHEN age BETWEEN 30 AND 39 THEN '30-39'
            WHEN age BETWEEN 40 AND 49 THEN '40-49'
            WHEN age BETWEEN 50 AND 59 THEN '50-59'
            ELSE '60+'
        END
) AS age_summary
ORDER BY total_revenue DESC;	


