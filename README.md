# CASE-STUDY-8-WEEK-SQL-CHALLENGE

> This repository contains my submission by solving case studies on the #8WEEKSQLCHALLENGE given by [DANNY MA](https://www.linkedin.com/in/datawithdanny/).

## CASE STUDY #5 DATA MART
![This is an image](https://8weeksqlchallenge.com/images/case-study-designs/5.png)

## Introduction

Data Mart is Danny’s latest venture and after running international operations for his online supermarket that specialises in fresh produce - Danny is asking for your support to analyse his sales performance.

In June 2020 - large scale supply changes were made at Data Mart. All Data Mart products now use sustainable packaging methods in every single step from the farm all the way to the customer.

Danny needs your help to quantify the impact of this change on the sales performance for Data Mart and it’s separate business areas.

## Available Data

For this case study there is only a single table: **"data_mart.weekly_sales"**

The **Entity Relationship Diagram** is shown below with the data types made clear, please note that there is only this one table - hence why it looks a little bit lonely!

![This is an image](https://8weeksqlchallenge.com/images/case-study-5-erd.png)

## Column Dictionary

The columns are pretty self-explanatory based on the column names but here are some further details about the dataset:

  * Data Mart has international operations using a multi-**region** strategy
  * Data Mart has both, a retail and online **platform** in the form of a Shopify store front to serve their customers
  * Customer **segment** and **customer_type** data relates to personal age and demographics information that is shared with Data Mart
  * **transactions** is the count of unique purchases made through Data Mart and sales is the actual dollar amount of purchases
  
Each record in the dataset is related to a specific aggregated slice of the underlying sales data rolled up into a week_date value which represents the start of the sales week.

## Case Study Questions
### 1. Data Cleansing Steps
In a single query, perform the following operations and generate a new table in the **data_mart** schema named **clean_weekly_sales**:
  * Convert the **week_date** to a **DATE** format
  * Add a **week_number** as the second column for each **week_date** value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
  * Add a **month_number** with the calendar month for each **week_date** value as the 3rd column
  * Add a **calendar_year** column as the 4th column containing either 2018, 2019 or 2020 values
  * Add a new column called **age_band** after the original **segment** column using the following mapping on the number inside the **segment** value
  
![This is an image](https://user-images.githubusercontent.com/124523532/217332642-091c33ce-17c2-4a0a-8cc0-258dd9cab027.png)

 * Add a new **demographic** column using the following mapping for the first letter in the **segment** values:
  
