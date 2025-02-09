create database pizza;
select * from pizza.pizza_sales;

-- Calculate the total revenue generated from pizza sales
select round(sum(total_price),2) total_revenue from pizza.pizza_sales;

-- Total Pizzas Sold
select sum(quantity) Total_Pizzas_Sold from pizza.pizza_sales;

-- the total number of orders placed
select count(distinct order_id) total_orders from pizza.pizza_sales;

-- List the top 5 most ordered pizza types along with their quantities
select pizza_name,sum(quantity) total_quantity from pizza.pizza_sales group by pizza_name order by total_quantity desc limit 5;

-- Total quantity of each pizza category ordered
select pizza_name,sum(quantity) as total_quantity from pizza.pizza_sales group by pizza_name order by total_quantity ;

-- Category-wise distribution of pizzas
SELECT pizza_category, pizza_name, COUNT(*) AS order_count
FROM pizza.pizza_sales
GROUP BY pizza_category, pizza_name
ORDER BY pizza_category, order_count DESC;

--  Peak Hours (Order distribution by hour)
select extract(hour from  order_time) hour_of_day,count(distinct order_id) total_orders,sum(quantity) total_sales from pizza.pizza_sales group by hour_of_day order by total_sales desc;

-- High Sales by Month
update pizza.pizza_sales
set order_date = 
    case
        when str_to_date(order_date, '%m/%d/%Y') is not null then date_format(str_to_date(order_date, '%m/%d/%Y'), '%Y-%m-%d')
        when str_to_date(order_date, '%d/%m/%Y') is not null then date_format(str_to_date(order_date, '%d/%m/%Y'), '%Y-%m-%d')
        else order_date
    end
where order_id is not null;

select month(order_date) as month_wise, count(distinct order_id) as total_orders, sum(quantity) as total_sales from pizza.pizza_sales
group by month_wise order by total_sales desc;


-- Daily Trend for Total Orders
select dayname(order_date) days,count(order_id) total_orders from pizza.pizza_sales group by days order by weekday(min(order_date));

-- Identify the most common pizza size ordered
select pizza_size,count(order_id) total_orders from pizza.pizza_sales group by pizza_size order by total_orders desc;

--  Top 5 most ordered pizza types based on revenue
select pizza_name, sum(total_price) total_revenue from pizza.pizza_sales group by pizza_name order by total_revenue desc limit 5;

-- Revenue Contribution by Pizza Category
select pizza_category,round(sum(total_price),2) total_revenue,concat(round((sum(total_price) / (select sum(total_price) from pizza_sales)*100),2),'%') revenue_percentage
from pizza.pizza_sales group by pizza_category order by revenue_percentage desc;

-- Top 5 Most Common Pizza Pairings
select s1.pizza_name,count(*) pairing_count from pizza.pizza_sales s1 join pizza.pizza_sales s2 on s1.order_id=s2.order_id and s1.pizza_name<>s2.pizza_name
group by s1.pizza_name order by pairing_count desc limit 5;

-- Cumulative Revenue Over Time
select extract(month from order_date) month,round(sum(total_price),2) monthly_revenue,round(sum(sum(total_price)) over (order by extract(month from order_date)),2) cumulative_revenue
from pizza.pizza_sales group by month order by month;

-- Month-on-Month Order Growth
with monthly_orders as(select extract(month from order_date) month,count(distinct order_id) total_orders from pizza.pizza_sales group by month)
select month,total_orders,(total_orders-lag(total_orders) over (order by month)) order_growth,
concat(round(((total_orders-lag(total_orders) over (order by month))/lag(total_orders) over (order by month))*100,2),'%') percentage_growth
from monthly_orders order by month;
