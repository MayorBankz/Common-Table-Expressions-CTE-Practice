/* Common Table Expressions Tasks
Step 1: Find the total sales per customer
Step 2: Find the last order date per customer
Step 3: Rank customers based on total sales per customer 
Step 4: Segment customers based on their total sales */


with customer_total as (select customerid,
sum(sales) as total_sales
from salesdb.orders
group by customerid
)
, last_order as (
select customerid,
max(orderdate) as last_order_date
from salesdb.orders
group by customerid
)
, customer_rank as (
select customerid,
rank() over(order by total_sales desc) as sales_rank
from customer_total
)
, customer_segment as (
select customerid,
total_sales,
case 
	when total_sales > 100 then 'High'
    when total_sales > 60 then 'Medium'
    else 'low'
end as customersegments
from customer_total
)

-- main query
select c.customerid,
c.firstname,
c.lastname,
cs.total_sales,
lo.last_order_date,
cr.sales_rank,
csm.customersegments
from salesdb.customers as c
left join customer_total as cs
	on c.customerid = cs.customerid
left join last_order as lo
	on c.customerid = lo.customerid
left join customer_rank as cr
	on c.customerid = cr.customerid
left join customer_segment as csm
	on c.customerid = csm.customerid
;


/* 1. Generate a Sequence of numbers from 1 to 20
2. Show the employee hierarchy by displaying each employee's level with the organization
*/

with recursive employee_hierarchy as (
-- Anchor: Top-Level employees (no manager)
select employeeid,
firstname, 
lastname,
managerid,
1 as level
from employees
where managerid is null

union all

-- Recursive: Find employees under each manager

select e.employeeid,
e.firstname,
e.lastname,
e.managerid,
eh.level + 1
from employees as e
join employee_hierarchy eh
	on e.managerid = eh.employeeid
) 
select *
from employee_hierarchy
order by level, employeeid
;