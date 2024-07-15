/*Operation Analysis and Investigating Metric Spike EXPLORATORY DATA ANALYSIS USING MySql*/

/* Create database Operation_Analysis;*/

use Operation_Analysis;

---------------------------------------------------------------------------

/* Case Study 1 (Job Data)*/

## A. Number of jobs reviewed: Amount of jobs reviewed over time.

-- Calculate the number of jobs reviewed per hour per day for November 2020?

SELECT ds AS DATES, round((count(job_id)/sum(time_spent))*3600)
AS 'JObs reviewed
per hour per day'
FROM
job_data
WHERE
ds BETWEEN '2020-11-01' AND '2020-11-30'
GROUP BY ds
order by ds;


## B.Throughput: It is the no. of events happening per second.

-- Calculate 7 day rolling average of throughput? For throughput, do you prefer daily metric or 7-day rolling and why?
select round(Count(event)/sum(time_spent),2)as 'weekly throughput'
From job_data;


select ds as dates,round(Count(event)/sum(time_spent),2)as 'Daily
Throughput' From job_data
group by ds
order by ds ;

## C.Percentage share of each language: Share of each language for different contents.

-- C. Calculate the percentage share of each language in the last 30 days?

select language,count(job_data.language)as
total,((count(job_data.language)/(select count(*)from
job_data))*100)per_share_of_each_lang
from job_data
group by job_data.language;

## D.Duplicate rows: Rows that have the same value present in them.

-- D.Let’s say you see some duplicate rows in the data. How will you display duplicates from the table?

SELECT * FROM(SELECT*,ROW_NUMBER() OVER(PARTITION BY JOB_ID) AS
ROWNUM FROM job_data)A WHERE
ROWNUM>1;


/* Case Study 2 (Investigating metric spike) */

## A.User Engagement: To measure the activeness of a user. Measuring if the user finds quality in a product/service.

-- 1. Calculate the weekly user engagement?

select extract(week from occurred_at)as week_number,
count(distinct user_id)as users
from events
group by week_number;

## B.User Growth: Amount of users growing over time for a product.

-- 2.Calculate the user growth for the product?

select years,week_number,num_users,
sum(num_users)over(order by years,week_number rows between unbounded
preceding and current row) as cumulative_active_usurs
from
(
select extract(year from activated_at) as years,
extract(week from activated_at) as week_number,
count(distinct user_id)as num_users
from users
where state='active'
group by years, week_number
order by years, week_number)A;

## C.Weekly Retention: Users getting retained weekly after signing-up for aproduct

-- 3.Calculate the weekly retention of users-sign up cohort?

SELECT EXTRACT(YEAR FROM OCCURRED_AT)AS YEAR,
EXTRACT(WEEK FROM OCCURRED_AT)AS WEEK_NUMBER,
DEVICE, COUNT(DISTINCT USER_ID) USER_TYPE
FROM events
WHERE EVENT_TYPE ='ENGAGEMENT'
GROUP BY 1,2,3
ORDER BY 1,2,3;

## D.Weekly Engagement: To measure the activeness of a user. Measuring if the user finds quality in a product/service weekly.

-- 4.Calculate the weekly engagement per device?

SELECT DISTINCT device FROM events;
SELECT WEEK(occurred_at) AS week_of_theYEAR,
COUNT(DISTINCT user_id) AS weekly_users,
COUNT(DISTINCT CASE WHEN device IN ('macbook pro', 'acer aspire
notebook','acer aspire desktop','lenovo thinkpad', 'mac mini', 'dell
inspiron desktop','dell inspiron notebook','windows surface','macbook
air','asus chromebook','hp pavilion desktop') THEN user_id ELSE NULL
END) AS computer,
COUNT(DISTINCT CASE WHEN device IN ('iphone 5s','nokia lumia
635','amazon fire phone','iphone 4s','htc one','iphone 5','samsung
galaxy s4') THEN user_id ELSE NULL END) AS phone,
COUNT(DISTINCT CASE WHEN device IN ('kindle fire','samsung galaxy
note','ipad mini','nexus 7','nexus 10','samsung galaxy tablet','nexus
5','ipad air') THEN user_id ELSE NULL END) AS tablet
FROM events
WHERE event_type = 'engagement'
AND event_name = 'login'
GROUP BY 1
ORDER BY 1;

## E.Email Engagement: Users engaging with the email service.

-- 5. Calculate the email engagement metrics?

SELECT ACTION,
EXTRACT(MONTH FROM OCCURRED_AT) AS MONTH,
COUNT(ACTION) AS NUMBER_OF_MAILS
FROM email_events
GROUP BY ACTION,MONTH
ORDER BY ACTION,MONTH;