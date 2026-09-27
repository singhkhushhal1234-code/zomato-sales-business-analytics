SELECT count(*) FROM zomato_data.zomato_orders;
select * from zomato_orders;
describe zomato_orders;
SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM zomato_orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT *
FROM zomato_orders
WHERE order_id IN (
    SELECT order_id
    FROM zomato_orders
    GROUP BY order_id
    HAVING COUNT(*) > 1
)
ORDER BY order_id;

SELECT *
FROM zomato_orders
WHERE order_id = '19';

CREATE TABLE zomato_orders_backup AS
SELECT *
FROM zomato_orders;

CREATE TABLE zomato_orders_clean AS
SELECT DISTINCT *
FROM zomato_orders;

SELECT COUNT(*) AS cleaned_rows
FROM zomato_orders_clean;

SELECT
    (SELECT COUNT(*) FROM zomato_orders) AS original_rows,
    (SELECT COUNT(*) FROM zomato_orders_clean) AS cleaned_rows;
    
DROP TABLE zomato_orders;

RENAME TABLE
    zomato_orders_clean TO zomato_orders;
    
SELECT
    COUNT(*) AS total_rows,
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(order_amount_inr IS NULL) AS missing_order_amount,
    SUM(delivery_time_mins IS NULL) AS missing_delivery_time,
    SUM(order_date IS NULL) AS missing_order_date,
    SUM(rating IS NULL) AS missing_rating,
    SUM(number_of_items IS NULL) AS missing_items,
    SUM(delivery_distance_km IS NULL) AS missing_distance,
    SUM(payment_method IS NULL) AS missing_payment_method,
    SUM(order_status IS NULL) AS missing_order_status,
    SUM(city IS NULL) AS missing_city,
    SUM(state IS NULL) AS missing_state
FROM zomato_orders;

SELECT
    MIN(order_amount_inr) AS minimum_amount,
    MAX(order_amount_inr) AS maximum_amount,
    AVG(order_amount_inr) AS average_amount
FROM zomato_orders;

SELECT
    MIN(delivery_time_mins) AS minimum_delivery_time,
    MAX(delivery_time_mins) AS maximum_delivery_time,
    AVG(delivery_time_mins) AS average_delivery_time
FROM zomato_orders;

SELECT
    MIN(rating) AS minimum_rating,
    MAX(rating) AS maximum_rating
FROM zomato_orders;

SELECT
    order_status,
    COUNT(*) AS total_orders
FROM zomato_orders
GROUP BY order_status
ORDER BY total_orders DESC;

select * from zomato_orders;

select sum(order_amount_inr) as total_revenue, round(avg(order_amount_inr), 2) as average_order_value, min(order_amount_inr) as min_order_amount, max(order_amount_inr) as max_order_amount from zomato_orders;

select 
year(order_date) as order_year,
month(order_date) as order_month,
monthname(order_date) as order_month_name,
sum(order_amount_inr) as total_revenue,
count(*) as total_orders,
round(avg(order_amount_inr), 2) as average_order_value
from zomato_orders
group by 
year(order_date),
month(order_date),
monthname(order_date)
order by 
year(order_date),
month(order_date);

select city, count(*) as total_orders, sum(order_amount_inr) as total_revenue, round(avg(order_amount_inr), 2) as average_order_value from zomato_orders
group by city
order by sum(order_amount_inr) desc;

select * from zomato_orders;

alter table zomato_orders
rename column 
	name to rest_name;
    
select res_id, rest_name, count(*) as total_orders, sum(order_amount_inr) as total_revenue, round(avg(order_amount_inr), 2) as avg_order_amount from zomato_orders
group by res_id, rest_name
order by sum(order_amount_inr) desc limit 10;

select
dayofweek(order_date) as day_name,
dayname(order_date) as date_of_the_month,
count(*) as total_orders,
sum(order_amount_inr) as total_revenue,
round(avg(order_amount_inr), 2) as avg_order_value from zomato_orders
group by dayname(order_date), dayofweek(order_date)
order by count(*) desc;

select city, round(avg(delivery_time_mins), 2) as avg_delivery_time, count(*) as total_orders, max(delivery_time_mins), ROUND(AVG(delivery_distance_km), 2) AS avg_delivery_distance from zomato_orders
group by city
order by round(avg(delivery_time_mins), 2) desc;

select payment_method, count(*) as total_orders, sum(order_amount_inr) as total_revenue, round(avg(order_amount_inr), 2) as avg_order_amount, ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM zomato_orders), 2
    ) AS order_percentage from zomato_orders
group by payment_method
order by count(*) desc;

select order_status, count(*) as total_orders, ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM zomato_orders),
        2
    ) AS order_percentage, sum(order_amount_inr) as total_revenue from zomato_orders
group by order_status
order by count(*) desc;

SELECT
    rating,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM zomato_orders),
        2
    ) AS rating_percentage
FROM zomato_orders
GROUP BY rating
ORDER BY rating;

SELECT
    ROUND(AVG(rating), 2) AS average_rating,
    MIN(rating) AS minimum_rating,
    MAX(rating) AS maximum_rating,
    COUNT(*) AS total_rated_orders
FROM zomato_orders;

select rest_name, round(avg(rating), 2) as avg_ratings, count(*) as total_rated_orders from zomato_orders
group by rest_name
HAVING COUNT(*) >= 10
order by round(avg(rating), 2) limit 10;

SELECT
    CASE
        WHEN delivery_distance_km < 2 THEN '0-2 km'
        WHEN delivery_distance_km < 5 THEN '2-5 km'
        WHEN delivery_distance_km < 10 THEN '5-10 km'
        ELSE '10+ km'
    END AS distance_category,

    COUNT(*) AS total_orders,

    ROUND(AVG(delivery_time_mins), 2)
        AS avg_delivery_time,

    ROUND(AVG(delivery_distance_km), 2)
        AS avg_distance,

    ROUND(AVG(order_amount_inr), 2)
        AS avg_order_value

FROM zomato_orders

GROUP BY distance_category

ORDER BY avg_distance;

SELECT
    ROUND(
        (
            COUNT(*) * SUM(delivery_distance_km * delivery_time_mins)
            - SUM(delivery_distance_km) * SUM(delivery_time_mins)
        )
        /
        NULLIF(
            SQRT(
                (
                    COUNT(*) * SUM(delivery_distance_km * delivery_distance_km)
                    - POWER(SUM(delivery_distance_km), 2)
                )
                *
                (
                    COUNT(*) * SUM(delivery_time_mins * delivery_time_mins)
                    - POWER(SUM(delivery_time_mins), 2)
                )
            ),
            0
        ),
        4
    ) AS distance_delivery_time_correlation
FROM zomato_orders;

select promo_code_applied, count(*) from zomato_orders
group by promo_code_applied
order by count(*) desc;

select has_free_delivery, promo_code_applied, sum(order_amount_inr), round(avg(order_amount_inr), 2), count(*) from zomato_orders
group by has_free_delivery, promo_code_applied
order by count(*) desc;

select sum(order_amount_inr), count(*) number_of_items from zomato_orders
group by number_of_items
order by number_of_items desc;

SELECT
    ROUND(
        (
            COUNT(*) * SUM(number_of_items * order_amount_inr)
            - SUM(number_of_items) * SUM(order_amount_inr)
        ) /
        SQRT(
            (COUNT(*) * SUM(number_of_items * number_of_items)
            - POW(SUM(number_of_items), 2))
            *
            (COUNT(*) * SUM(order_amount_inr * order_amount_inr)
            - POW(SUM(order_amount_inr), 2))
        ),
        3
    ) AS correlation_items_order_value
FROM zomato_orders;

select rest_name, count(*), round(avg(rating), 2), sum(order_amount_inr), round(avg(order_amount_inr), 2) from zomato_orders
group by rest_name
having count(*) >= 10
order by sum(order_amount_inr) desc limit 15;

SELECT
    order_status,
    COUNT(*) AS total_orders,
    SUM(order_amount_inr) AS total_order_value,
    ROUND(AVG(order_amount_inr), 2) AS average_order_value,
    ROUND(
        SUM(order_amount_inr) * 100.0 /
        (SELECT SUM(order_amount_inr) FROM zomato_orders),
        2
    ) AS revenue_percentage
FROM zomato_orders
GROUP BY order_status
ORDER BY total_order_value DESC;   

select year(order_date), monthname(order_date), month(order_date), count(*), sum(order_amount_inr), round(avg(order_amount_inr), 2) from zomato_orders
group by monthname(order_date), year(order_date), month(order_date)
order by year(order_date), month(order_date);

WITH monthly_revenue AS (
    SELECT
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS month_number,
        MONTHNAME(order_date) AS month_name,
        SUM(order_amount_inr) AS total_revenue
    FROM zomato_orders
    GROUP BY
        YEAR(order_date),
        MONTH(order_date),
        MONTHNAME(order_date)
)

SELECT
    order_year,
    month_number,
    month_name,
    total_revenue,
    LAG(total_revenue) OVER (
        ORDER BY order_year, month_number
    ) AS previous_month_revenue,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (
            ORDER BY order_year, month_number
        )) * 100.0 /
        LAG(total_revenue) OVER (
            ORDER BY order_year, month_number
        ),
        2
    ) AS mom_revenue_growth_percentage
FROM monthly_revenue
ORDER BY order_year, month_number;

WITH monthly_orders AS (
    SELECT
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS month_number,
        MONTHNAME(order_date) AS month_name,
        COUNT(*) AS total_orders
    FROM zomato_orders
    GROUP BY
        YEAR(order_date),
        MONTH(order_date),
        MONTHNAME(order_date)
)

SELECT
    order_year,
    month_number,
    month_name,
    total_orders,
    LAG(total_orders) OVER (
        ORDER BY order_year, month_number
    ) AS previous_month_orders,
    ROUND(
        (total_orders - LAG(total_orders) OVER (
            ORDER BY order_year, month_number
        )) * 100.0 /
        LAG(total_orders) OVER (
            ORDER BY order_year, month_number
        ),
        2
    ) AS mom_order_growth_percentage
FROM monthly_orders
ORDER BY order_year, month_number;

SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_time_mins), 2) AS avg_delivery_time,
    MAX(delivery_time_mins) AS max_delivery_time,
    ROUND(AVG(delivery_distance_km), 2) AS avg_delivery_distance,
    ROUND(AVG(order_amount_inr), 2) AS average_order_value
FROM zomato_orders
GROUP BY order_status
ORDER BY avg_delivery_time DESC;

SELECT
    CASE
        WHEN delivery_time_mins <= 20 THEN '0-20 mins'
        WHEN delivery_time_mins <= 30 THEN '21-30 mins'
        WHEN delivery_time_mins <= 45 THEN '31-45 mins'
        WHEN delivery_time_mins <= 60 THEN '46-60 mins'
        ELSE '60+ mins'
    END AS delivery_time_category,
    COUNT(*) AS total_orders,
    ROUND(AVG(rating), 2) AS average_customer_rating,
    ROUND(AVG(order_amount_inr), 2) AS average_order_value
FROM zomato_orders
GROUP BY delivery_time_category
ORDER BY
    CASE delivery_time_category
        WHEN '0-20 mins' THEN 1
        WHEN '21-30 mins' THEN 2
        WHEN '31-45 mins' THEN 3
        WHEN '46-60 mins' THEN 4
        ELSE 5
    END;
    
SELECT
    CASE
        WHEN tip_amount_inr = 0 THEN 'No Tip'
        WHEN tip_amount_inr <= 20 THEN '₹1-20'
        WHEN tip_amount_inr <= 50 THEN '₹21-50'
        WHEN tip_amount_inr <= 100 THEN '₹51-100'
        ELSE '₹100+'
    END AS tip_category,
    COUNT(*) AS total_orders,
    ROUND(AVG(order_amount_inr), 2) AS average_order_value,
    ROUND(AVG(tip_amount_inr), 2) AS average_tip,
    SUM(tip_amount_inr) AS total_tips
FROM zomato_orders
GROUP BY tip_category
ORDER BY total_tips DESC;

SELECT
    CASE
        WHEN order_amount_inr < 500 THEN 'Below ₹500'
        WHEN order_amount_inr < 1000 THEN '₹500-999'
        WHEN order_amount_inr < 1500 THEN '₹1000-1499'
        WHEN order_amount_inr < 2000 THEN '₹1500-1999'
        ELSE '₹2000+'
    END AS order_value_category,
    COUNT(*) AS total_orders,
    ROUND(AVG(order_amount_inr), 2) AS average_order_value,
    ROUND(AVG(tip_amount_inr), 2) AS average_tip,
    ROUND(
        AVG(tip_amount_inr / NULLIF(order_amount_inr, 0)) * 100,
        2
    ) AS average_tip_percentage
FROM zomato_orders
GROUP BY order_value_category
ORDER BY
    CASE order_value_category
        WHEN 'Below ₹500' THEN 1
        WHEN '₹500-999' THEN 2
        WHEN '₹1000-1499' THEN 3
        WHEN '₹1500-1999' THEN 4
        ELSE 5
    END;
    
select rest_name, count(*), SUM(order_amount_inr) AS total_revenue,
    ROUND(AVG(rating), 2) AS average_rating, max(votes) from zomato_orders
group by rest_name
order by max(votes) desc limit 15;

SELECT
    CASE
        WHEN delivery_distance_km < 2 THEN '0-2 km'
        WHEN delivery_distance_km < 5 THEN '2-5 km'
        WHEN delivery_distance_km < 10 THEN '5-10 km'
        ELSE '10+ km'
    END AS distance_category,
    COUNT(*) AS total_orders,
    ROUND(AVG(delivery_distance_km), 2) AS average_distance,
    ROUND(AVG(delivery_time_mins), 2) AS average_delivery_time,
    ROUND(AVG(order_amount_inr), 2) AS average_order_value
FROM zomato_orders
GROUP BY distance_category
ORDER BY
    CASE distance_category
        WHEN '0-2 km' THEN 1
        WHEN '2-5 km' THEN 2
        WHEN '5-10 km' THEN 3
        ELSE 4
    END;

SELECT
    ROUND(
        (
            COUNT(*) * SUM(delivery_distance_km * delivery_time_mins)
            - SUM(delivery_distance_km) * SUM(delivery_time_mins)
        ) /
        SQRT(
            (
                COUNT(*) * SUM(delivery_distance_km * delivery_distance_km)
                - POW(SUM(delivery_distance_km), 2)
            ) *
            (
                COUNT(*) * SUM(delivery_time_mins * delivery_time_mins)
                - POW(SUM(delivery_time_mins), 2)
            )
        ),
        3
    ) AS correlation_distance_delivery_time
FROM zomato_orders;

SELECT
    city,
    COUNT(*) AS total_orders,
    SUM(order_amount_inr) AS total_revenue,
    ROUND(AVG(order_amount_inr), 2) AS average_order_value,
    ROUND(AVG(delivery_time_mins), 2) AS average_delivery_time,
    ROUND(AVG(delivery_distance_km), 2) AS average_delivery_distance
FROM zomato_orders
GROUP BY city
ORDER BY total_orders DESC;

SELECT
    payment_method,
    COUNT(*) AS total_orders,
    SUM(order_amount_inr) AS total_revenue,
    ROUND(AVG(order_amount_inr), 2) AS average_order_value,
    ROUND(AVG(tip_amount_inr), 2) AS average_tip
FROM zomato_orders
GROUP BY payment_method
ORDER BY total_revenue DESC;

SELECT
    rest_name,
    COUNT(*) AS total_orders,
    SUM(order_amount_inr) AS total_revenue,
    ROUND(AVG(order_amount_inr), 2) AS average_order_value,
    ROUND(AVG(rating), 2) AS average_rating
FROM zomato_orders
GROUP BY rest_name
HAVING COUNT(*) >= 10
ORDER BY total_revenue DESC
LIMIT 20;

SELECT
    city,
    COUNT(*) AS total_orders,
    SUM(order_amount_inr) AS total_revenue,
    ROUND(AVG(order_amount_inr), 2) AS average_order_value,
    ROUND(AVG(delivery_time_mins), 2) AS average_delivery_time,
    ROUND(AVG(delivery_distance_km), 2) AS average_delivery_distance
FROM zomato_orders
GROUP BY city
HAVING COUNT(*) >= 100
ORDER BY average_delivery_time DESC;

SELECT
    rest_name,
    COUNT(*) AS total_orders,
    SUM(order_amount_inr) AS total_revenue,
    ROUND(AVG(rating), 2) AS average_rating,
    ROUND(AVG(delivery_time_mins), 2) AS average_delivery_time
FROM zomato_orders
GROUP BY rest_name
HAVING COUNT(*) >= 50
ORDER BY average_rating ASC, total_orders DESC
LIMIT 15;


	