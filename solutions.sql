-- ALl Tables

select * from EDH.CORE_DATA.CUSTOMERS;
select * from EDH.CORE_DATA.CUSTOMERTYPE;
select * from EDH.CORE_DATA.DISCVOUCHER;
select * from EDH.CORE_DATA.ORDERS;
select * from EDH.CORE_DATA.TABLES;

-- 1. What is the name of the customer who name has the maximum length?

select name 
from customers
having length(name) = (select max(length(name)) from customers);

-- 2. Retrive orderno, customerid , orderdate , amount and name of customer?
select ord.OrderNo, ord.CustomerID, ord.OrderDate, ord.Amount , cust.Name
from orders ord
join  customers cust
ON ord.customerid = cust.customerid;

-- 3. What is the total orders made by each customer?
select cust.customerid, count(orderno) as total_orders
from customers cust
left join orders ord
on cust.customerid = ord.customerid
group by cust.customerid;

-- 4. How many customers belong to each catergory type?

select ctype.name , count(cust.customerid) as total_cust
from EDH.CORE_DATA.CUSTOMERTYPE ctype
join EDH.CORE_DATA.CUSTOMERS cust using(customertypeid)
group by ctype.name;

-- 5. what is the discount for each customer on each single buy?

select  cust.name ,
        ord.orderno , 
        ord.amount , 
        case 
        when ord.amount >= 0 and ord.amount <= 3000
             then ord.amount
        when ord.amount >= 3001 and ord.amount <= 8000
             then round((ord.amount) - (ord.amount*10)/100,2)
        when ord.amount >= 8001 and ord.amount <= 99999
             then round((ord.amount) - (ord.amount*25)/100,2)
        END as final_price    
from orders ord
left join customers cust 
ON ord.customerid = cust.customerid;

-- 6. What is the total sales of each customer?
select  cust.name,
        coalesce(sum(ord.amount),0) as total_spend,
from customers cust
left join orders ord
on ord.customerid = cust.customerid
group by cust.name;

-- 7. What is the average spend of each customer?
select  cust.name,
        coalesce(round(sum(ord.amount)/count(ord.orderno),2),0) as avg_spend
from customers cust
left join orders ord
on ord.customerid = cust.customerid
group by cust.name;


-- 8. What is the total spend based on customertype?

select ct.name, round(sum(ord.amount),2) as total_spend
from orders ord
left join customers cust
ON ord.customerid = cust.customerid
left join customertype ct
ON cust.customertypeid = ct.customertypeid
group by ct.name ;

-- 9. What is the avg spend based on customertype?

select ct.name, round(sum(ord.amount) / count(cust.customertypeid),2) as avg_spend
from orders ord
left join customers cust
ON ord.customerid = cust.customerid
left join customertype ct
ON cust.customertypeid = ct.customertypeid
group by ct.name ;

-- 10. Which customer has spent the most and what is the amount?

select cust.name as cust_name , SUM(ord.amount) as total_spent
from orders ord
left join customers cust
On ord.customerid = cust.customerid
group by cust.name
HAVING total_spent = (select max(total_spent) from (select sum(amount) as total_spent from orders group by customerid));

-- 11. What are the name of the customer/s whose name start's with A or K ?

select name from customers
where lower(name) ilike 'a%' or lower(name) ilike 'k%';


-- 12. What is the total sales for each day?

select orderdate , sum(amount) as tot_sales
from orders
group by orderdate;

-- 13. What is the total sales for each day having less than total sales less than 5000?

select orderdate , sum(amount) as tot_sales
from orders
group by orderdate
having sum(amount) < 5000;

-- 14. On which day max sale was done?

select orderdate , sum(amount) as tot_sales
from orders 
group by orderdate
having sum(amount) = (select max(tot_sum) from (select sum(amount) as tot_sum from orders 
group by orderdate ));

-- 15. What is the number of orders made by each customer type?

select ct.name, count(ord.orderno) as total_order
from orders ord
left join customers cust on ord.customerid = cust.customerid
left join customertype ct on ct.customertypeid = cust.customertypeid
group by ct.name;

-- 16. What is the max and min number of orders placed by customer along with name and customerid?

(SELECT cust.name, cust.customerid , COALESCE(max(o.t_count),0) AS tot_orders
FROM customers cust
LEFT JOIN (
    SELECT customerid , COUNT(orderno) AS t_count 
    FROM orders
    GROUP BY customerid
) AS o ON o.customerid = cust.customerid
GROUP BY cust.name, cust.customerid
ORDER BY COALESCE(MAX(o.t_count),0) DESC
LIMIT 1)
UNION ALL 
(SELECT cust.name, cust.customerid , COALESCE(min(o.t_count),0) AS tot_orders
FROM customers cust
LEFT JOIN (
    SELECT customerid , COUNT(orderno) AS t_count 
    FROM orders
    GROUP BY customerid
) AS o ON o.customerid = cust.customerid
GROUP BY cust.name, cust.customerid
ORDER BY COALESCE(min(o.t_count),0) limit 1);


-- 17. Which customer has got the max discount on which date?

select  ord.orderdate as order_dt, cust.name as c_name, sum(ord.amount) as t_sales, 
        case 
        when t_sales >= 0 and t_sales <= 3000
             then t_sales
        when t_sales >= 3001 and t_sales <= 8000
             then round((t_sales) - (t_sales*10)/100,2)
        when t_sales >= 8001 and t_sales <= 99999
             then round((t_sales) - (t_sales*25)/100,2)
        END as discounted_price
from customers cust
left join orders ord
ON cust.customerid = ord.customerid
group by ord.orderdate,cust.name
having sum(ord.amount) = (select max(sales_amount) from (select o.orderdate, c.name, sum(o.amount) as sales_amount from customers c
left join orders o
ON c.customerid = o.customerid
group by o.orderdate,c.name));

-- 18. Which customer did not make any purchase?

select cust.name
from customers cust
left join orders ord on cust.customerid = ord.customerid
where ord.customerid is null;

-- 19. What is the min and max amount on the maximum transactional day?

select orderdate ,max(amount) as max_amount ,min(amount) as min_amount 
from 
(
select orderdate , amount
from orders
where orderdate = (
select max(max_trans_date) from (
select ord.orderdate as max_trans_date, count(ord.orderno)
from orders ord
group by ord.orderdate))
order by amount)
group by orderdate;

-- 20. Show the respective day name on which the orders were placed and total transactions on that particular day?

select date(orderdate) as dates, dayname(date(orderdate)) as days , count(orderno) as  t_transactions from orders
group by date(orderdate)
order by dates;