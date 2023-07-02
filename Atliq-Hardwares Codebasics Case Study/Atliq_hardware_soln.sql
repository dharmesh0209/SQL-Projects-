-- Checking all the database Tables.
select * from dim_customer;
select * from dim_product;
select * from fact_gross_price;
select * from fact_manufacturing_cost;
select * from fact_pre_invoice_deductions;
select * from fact_sales_monthly;

-- Checking Total Records present in each database tables
select Count(*) from dim_customer;
select count(*) from dim_product;
select count(*) from fact_gross_price;
select count(*) from fact_manufacturing_cost;
select count(*) from fact_pre_invoice_deductions;
select count(*) from fact_sales_monthly;

-- Adhoc Queries
-- 1) Provide the list of Markets in which customer " Atliq Exclusive" operates business in APAC Region.
select distinct customer,market from dim_customer 
where customer = 'Atliq Exclusive' and region= 'APAC'
order by market;

/* 2) What is the % of unique product increase in 2021 vs 2020? 
the final output contains fields  unique_products_2020, unique_products_2021,percentage_change*/
with cte1 as (
select count(*) as p20 from fact_manufacturing_cost where cost_year=2020),
cte2 as (
select count(*) as p21 from fact_manufacturing_cost where cost_year=2021)
select p20 as unique_product_2020, p21 as unique_product_2021,
round(((p21-p20)/p20)*100,2) as " % product increase" from cte1,cte2;

/* 3) Provide a report with all the  unique product counts for each sgement 
and sort them in descending order of product counts. The final output 2 fields segment,product_count.*/
select segment,count(product) as product_count from dim_product 
group by segment
order by 2 desc;

/* 4) Which segment had the most increase in unique product in 2020 vs 2021? The final output  
contains these fields product_count_2020,product_count_2021,difference.*/
with cte1 as (
select distinct p.segment,count(p.product) as product_count,m.cost_year from dim_product p 
join fact_manufacturing_cost m on p.product_code=m.product_code
group by 1,3),
cte21 as (
select segment as s1,product_count as p21, cost_year 
from cte1 where cost_year=2021),
cte20 as (
select segment as s2,product_count as p20,cost_year 
from cte1 where cost_year=2020)
select s1,p21 as product_count_21,p20 as product_count_20,(p21-p20) as Prod_Diff 
from cte21,cte20 where s1=s2
order by 4 desc;

/* 5) Get the Products that have the highest and lowest manufacturing costs. 
The Final Product should contain these fields product_code,product,manufacturing cost.*/
with cte1 as (
select  p.product_code,p.product,m.manufacturing_cost from dim_product p 
join fact_manufacturing_cost m on p.product_code=m.product_code)
select *
from cte1 where manufacturing_cost = (select min(manufacturing_cost) from cte1)
union
select * from cte1 where manufacturing_cost=(select max(manufacturing_cost) from cte1);

/* 6) Generate a report which contains the top5 customers who received an average high pre_invoice 
discount_pct for fiscal year 2021 and in indian market. The final output should contain fields customer_code,
customer,average_discount_percentage.*/

select c.customer_code,c.customer,c.market,round(Avg(i.pre_invoice_discount_pct),4) from dim_customer c
join fact_pre_invoice_deductions i on c.customer_code=i.customer_code
where i.fiscal_year=2021 and c.market="India"
group by 1,2,3
order by 4 desc
limit 5;

/* 7) Get the complete report of the Gross sales amount for the customer "Atliq Exclusive" for each month.
This analysis helps to get an idea of low and high-performing months and take strategic decsions.
The final report contains these columns: Month, Year, Gross sales Amount.*/
with cte1 as (
select extract(month from date) as "Month",extract(Year from date) as "Year",
m.customer_code,m.product_code,(m.sold_quantity*g.gross_price) as Total_gross from fact_sales_monthly m join 
fact_gross_price g on m.product_code=g.product_code join dim_customer c 
on m.customer_code=c.customer_code
where c.customer="Atliq Exclusive")
select Month,Year,round(Sum(Total_gross)/1000000,2) as "Total_gross_sales(mil)" from cte1
group by 2,1;

/* 8) In Which Quarter of 2020 got the maximum total_sold_quantity?The final output contains these fields 
sorted by the total_sold_quantity. Quarter and total_sold_quantity.*/

select case
when date between '2019-09-01' and '2019-11-01' then 'Q1' 
when date between '2019-12-01' and '2020-02-01' then 'Q2'
when date between '2020-03-01' and '2020-05-01' then 'Q3'
when date between '2020-06-01' and '2020-08-01' then 'Q4'
end as 'Quarter',
round(sum(sold_quantity)/1000000,2) as 'Total_Quantity(M)',fiscal_year from fact_sales_monthly
where fiscal_year=2020 group by 1;

/* 9) Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage contribution?
The Final output contains these fields, Channel,gross_sales_mln, percentage*/
with cte1 as (
select c.channel,m.fiscal_year,round(Sum((m.sold_quantity*g.gross_price)/1000000),2) as "Total_gross_sales_mln" from dim_customer c
join fact_sales_monthly m on c.customer_code=m.customer_code join fact_gross_price g on 
m.product_code=g.product_code where m.fiscal_year=2021
group by 1,2)
select channel,Total_gross_sales_mln,
round((total_gross_sales_mln/sum(total_gross_sales_mln) over())*100,2) as percentage from cte1
order by 3 desc;


/* 10) Get the top 3 products in each division that have a high total_sold_quantity in the fiscal year 2021?
the final output contains these fields. division,product_Code,product,total_qty_sold, rank.*/
with cte1 as (
select p.division,p.product_code,p.product,sum(m.sold_quantity) as "Qty_Sold"
from dim_product p 
join fact_sales_monthly m on p.product_code=m.product_code
where m.fiscal_year=2021
group by 1,2,3
order by 1,4 desc),
cte2 as (
select division,product_code,product,Qty_sold,rank() over(partition by division order by Qty_sold desc) as rk
from cte1 order by division,Qty_sold desc)
select * from cte2 where rk in (1,2,3);






