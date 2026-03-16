# Common-Table-Expressions-CTE-Practice
## TOOL - MySQL
## DATE - 16-03-2026

## OVERVIEW
This exercise demonstrates how Common Table Expressions (CTEs) can be used to break complex SQL problems into smaller logical steps.
Each CTE performs a specific task, and the results are later combined in the main query.

---

### DATASET USED

**Customers**

| column     | description               |
| ---------- | ------------------------- |
| customerid | Unique ID of the customer |
| firstname  | Customer first name       |
| lastname   | Customer last name        |

**Orders**

| column     | description                   |
| ---------- | ----------------------------- |
| orderid    | Unique order ID               |
| customerid | Customer who placed the order |
| orderdate  | Date of the order             |
| sales      | Sales amount                  |

---

### TASK 1: Customer Sales Analysis Using CTEs
* Objectives
1. Find the total sales per customer
2. Find the last orderdate per customer
3. Rank customers based on total sales
4. Segment customers based on their total sales

---

### STEP 1: Find total sales per customer

This CTE calculates how much each customer has spent in total

```sql
with customer_total as (
select customerid,
sum(sales) as total_sales
from salesdb.orders
group by customerid
)
```

### Explanation:

* `sum(sales)` calculates the total sales for each customer.

* `group by` customerid ensures the total is calculated per customer.

---

### STEP 2: Find Last Order Date per Customer

This CTE finds the most recent order date for each customer.

```sql
last_order as (
select customerid,
max(orderdate) as last_order_date
from salesdb.orders
group by customerid
)
```

### Explanation
* `max(orderdate)` finds the latest order date for each customer.
Example result:

| customerid	| last_order_date |
| ---------- | -------------- |
| 1 |	2025-02-10 |
| 2	| 2025-01-22 |

---

### Step 3: Rank Customers by Total Sales 
This CTE ranks customers based on their spending.
```sql
customer_rank as (
select customerid,
rank() over(order by total_sales desc) as sales_rank
from customer_total
)
```
### Explanation
This CTE ranks customers based on their spending.

```sql
customer_rank as (
select customerid,
rank() over(order by total_sales desc) as sales_rank
from customer_total
)
```

### Explanation
* `rank` is a window function.
* Customers with the highest sales get rank 1.

### Example result
| customerid | sales_rank |
| ---------- | ---------- |
| 1          | 1          |
| 2          | 2          |
| 3          | 3          |

---

### Step 4: Segment Customers Based on Sales
Customers are categorized into groups depending on their total spending.

```sql
customer_segment as (
select customerid,
total_sales,
case 
	when total_sales > 100 then 'High'
    when total_sales > 60 then 'Medium'
    else 'Low'
end as customersegments
from customer_total
)
```
### Explanation

| Sales Range | Segment                |
| ----------- | ---------------------- |
| >100        | High Value Customers   |
| 61–100      | Medium Value Customers |
| ≤60         | Low Value Customers    |

---

### Final Query
All CTE results are combined with the customers table to create a complete customer analysis.

```sql
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
```

### Why LEFT JOIN?
LEFT JOIN ensures all customers appear, even if they have not placed any orders.

---

### TASK 2: Recursive CTE (Employee Hierarchy)
Recursive CTEs are used when a query needs to reference itself.
A common use case is organizational hierarchies.

---
### Employee Table Example

| employeeid | firstname | lastname | managerid |
| ---------- | --------- | -------- | --------- |
| 1          | John      | Doe      | NULL      |
| 2          | Jane      | Smith    | 1         |
| 3          | Mike      | Brown    | 1         |
| 4          | Sarah     | Lee      | 2         |

`managerid` refers to another employee.

---
### Objective

Display the organizational hierarchy and show each employee's level.

---

### Recursive Query
```sql
with recursive employee_hierarchy as (

-- Anchor Query (Top-level employees)
select employeeid,
firstname, 
lastname,
managerid,
1 as level
from employees
where managerid is null

union all

-- Recursive Query
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
order by level, employeeid;
```

---

### How Recursive CTE Works
1. Anchor Query

Finds the top-level employees.

```sql
where managerid is null
```
These are usually CEOs or department heads.

Level = 1

---

2. Recursive Query
Finds employees who report to those managers.

```sql
eh.level + 1
```
Each level represents the depth in the organization.

---

### Example Output

| employeeid | firstname | managerid | level |
| ---------- | --------- | --------- | ----- |
| 1          | John      | NULL      | 1     |
| 2          | Jane      | 1         | 2     |
| 3          | Mike      | 1         | 2     |
| 4          | Sarah     | 2         | 3     |

Hierarchy meaning:

| Level | Role                     |
| ----- | ------------------------ |
| 1     | Top management           |
| 2     | Managers                 |
| 3     | Employees under managers |

### Key Takeaways
CTE Benefits

* Breaks complex queries into readable steps

* Improves query organization

* Makes debugging easier

Types of CTEs

* Non-Recursive CTE → Used for step-by-step data transformations

* Recursive CTE → Used for hierarchical or iterative problems
