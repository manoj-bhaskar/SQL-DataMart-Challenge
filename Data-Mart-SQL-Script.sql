USE data_mart;

SELECT * FROM weekly_sales;

/* Data Cleansing Steps */

/* 1) Convert the week_date to a DATE format */

alter table weekly_sales
change column week_date week_date date;

/* 2) Add a week_number as the second column for each week_date value,
	  for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
	3) Add a month_number with the calendar month for each week_date value as the 3rd column
    4) Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
    5) Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value
    6) Add a new demographic column using the following mapping for the first letter in the segment values
    8) Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record*/

create table clean_weekly_sales as
select 
	CAST(week_date as date) week_date,
	week(cast(week_date as date)) as week_number,
	month(cast(week_date as date)) as month_number,
	year(cast(week_date as date)) as calendar_year,
	region,
	platform,
	segment,
	case when RIGHT(segment, 1) = '1' then 'Young Adults'
		when RIGHT(segment, 1) = '2' then 'Middle Aged'
		when RIGHT(segment, 1) = '3' or RIGHT(segment, 1) = '4' then 'Retirees'
		else 'unknown' end age_band,
	case when LEFT(segment, 1) = 'C' then 'Couples'
		when LEFT(segment, 1) = 'F' then 'Families'
		else 'unknown' end demographic,
	customer_type,
	CAST(transactions as float) transactions,
	CAST(sales as float) sales,
	ROUND(CAST(sales as float)/CAST(transactions as float), 2) avg_transaction
from weekly_sales;

select * from clean_weekly_sales;

/* Another Method */

select*, month(week_date) as month_number, year(week_date) as calendar_year,
	case
		when dayofmonth(week_date) between 1 and 7 then 1
		when dayofmonth(week_date) between 8 and 14 then 2
		when dayofmonth(week_date) between 15 and 21 then 3
		when dayofmonth(week_date) between 22 and 28 then 4
		when dayofmonth(week_date) between 29 and 35 then 5
	end as week_number,
    case
		when segment like "%1" then "Young Adults"
        when segment like "%2" then "Middle Aged"
        when segment like "%3" or "%4" then "Retirees"
        else "unknown"
	end as age_band,
	case
		when segment like "C%" then "Couples"
        when segment like "F%" then "Families"
        else "unknown"
	end as demographic,
round((sales/transactions),2) as avg_transaction
from weekly_sales;

/* 3) Add a month_number with the calendar month for each week_date value as the 3rd column */

alter table weekly_sales
modify column segment varchar(10);

/* 7) Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns */
update weekly_sales
set segment = "unknown"
where segment = "null";



								  /* DATA EXPLORATION*/
                                                              
/* 1) What day of the week is used for each week_date value? */
select dayname(week_date) as day_name from weekly_sales;

/* 2) What range of week numbers are missing from the dataset? */

/* 3) How many total transactions were there for each year in the dataset? */
select *, sum(transactions) as transactions_per_year
from weekly_sales
group by year(week_date)
order by week_date;

/* 4) What is the total sales for each region for each month? */
select *, sum(sales) as total_sales
from weekly_sales
group by region, month(week_date)
order by region;

/* 5) What is the total count of transactions for each platform */
select *, count(transactions) as transactions_count
from weekly_sales
group by platform;

/* 6) What is the percentage of sales for Retail vs Shopify for each month? */

SELECT 
  week_date,
  retail_sales,
  shopify_sales,
  total_sales,
  (retail_sales / total_sales) * 100 as retail_percentage,
  (shopify_sales / total_sales) * 100 as shopify_percentage
FROM 
  (
    SELECT 
      week_date,
      SUM(CASE WHEN platform = 'retail' THEN sales ELSE 0 END) as retail_sales,
      SUM(CASE WHEN platform = 'shopify' THEN sales ELSE 0 END) as shopify_sales,
      SUM(sales) as total_sales
    FROM 
      weekly_sales 
    GROUP BY 
      month(week_date)
  ) as subquery;

  
/* 7) What is the percentage of sales by demographic for each year in the dataset? */

select *, ((couples_sales / total_sales) * 100) as couple_sales_percent_per_year,
((families_sales / total_sales) * 100) as families_sales_percent_per_year,
((unknown_sales / total_sales) * 100) as unknown_sales_percent_per_year
from
(with cte as (
select*, year(week_date) as calendar_year,
	case
		when segment like "C%" then "Couples"
        when segment like "F%" then "Families"
        else "unknown"
	end as demographic,
round((sales/transactions),2) as avg_transaction
from weekly_sales)

select year(week_date) as year,
	sum(case when demographic = "couples" then sales else 0 end) as couples_sales,
    sum(case when demographic = "Families" then sales else 0 end) as families_sales,
    sum(case when demographic = "unknown" then sales else 0 end) as unknown_sales,
    sum(sales) as total_sales
from cte
group by year(week_date)
order by year(week_date) desc) as subquery;

/* 8) Which age_band and demographic values contribute the most to Retail sales? */

/* Maximum contributors to retail sales age_band wise */

with cte as (select*,
    case
		when segment like "%1" then "Young Adults"
        when segment like "%2" then "Middle Aged"
        when segment like "%3" or "%4" then "Retirees"
        else "unknown"
	end as age_band,
round((sales/transactions),2) as avg_transaction
from weekly_sales)

select *, sum(sales) as age_band_sales from cte
where platform = "Retail"
group by age_band
order by age_band_sales desc;

/* Maximum contributors to retail sales demographic wise */

with cte as (select*,
	case
		when segment like "C%" then "Couples"
        when segment like "F%" then "Families"
        else "unknown"
	end as demographic,
round((sales/transactions),2) as avg_transaction
from weekly_sales)

select *, sum(sales) as demographic_sales from cte
where platform = "Retail"
group by demographic
order by demographic_sales desc;

/* 9) find the average transaction size for each year for Retail vs Shopify? */

select week_date, transactions,
avg(case when platform = "retail" then transactions else 0 end) as avg_retail_transactions_per_year,
avg(case when platform = "shopify" then transactions else 0 end) as avg_shopify_transactions_per_year,
avg(transactions) as avg_total_transactions_per_year
from weekly_sales
group by year(week_date)
order by year(week_date) desc;

                                                             	   /* Insights Generated */

/* What was the quantifiable impact of the changes introduced in June 2020? */

with cte as(
select
sum(case when (month(week_date) >= 6 and year(week_date) >= 2020) then sales else 0 end) as after_june_2020_sales,
sum(case when (month(week_date) <= 6 and year(week_date) <= 2020) then sales else 0 end) as before_june_2020_sales
from weekly_sales)

select *,
(case when after_june_2020_sales > before_june_2020_sales then "profit" else "loss" end) as profit_or_loss_after_change,
round((((after_june_2020_sales - before_june_2020_sales) / before_june_2020_sales) * 100),2) as percent_increase_or_decrease
from cte;

