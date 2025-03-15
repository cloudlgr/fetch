--Q1: What are the top 5 brands by receipts scanned for most recent month?
with temp as (
SELECT 

b.name as BrandName
,count(r.receipt_id) as num_scanned

FROM item r
JOIN brands b ON r.barcode = b.barcode;

where cast(createDate as date) between DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)  and EOMONTH(GETDATE())  -- current month range
group by b.name
)

,base as (
select

b.*
dense_rank() over (order by num_scanned desc) as rk
from temp

)

select
BrandName,
num_scanned
from base
where rk<=5




---Q2 How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?

with temp as (
SELECT 

year(createDate)*100+month(createDate) as YYYYMM
,b.name as BrandName
,count(r.receipt_id) as num_scanned

FROM item r
JOIN brands b ON r.barcode = b.barcode;

where cast(createDate as date) between DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0)  and EOMONTH(GETDATE())  -- first day of previous month to current month end
group by 
b.name
,year(createDate)*100+month(createDate)
)

,base as (
select

b.*
dense_rank() over (partition by YYYYMM order by num_scanned desc) as rk
from temp

)

select
case when YYYYMM = year(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0))*100+month(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0)) then BrandName end as 'PreviousMonthTop5Brands'
,case when YYYYMM = year(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0))*100+month(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0)) then num_scanned end as 'PreviousMonthTop5BrandsNumScanned'
case when YYYYMM = year(EOMONTH(GETDATE()))*100+month(EOMONTH(GETDATE())) then BrandName end as 'CurrentMonthTop5Brands'
,case when YYYYMM = year(EOMONTH(GETDATE()))*100+month(EOMONTH(GETDATE())) then num_scanned end as 'CurrentMonthTop5BrandsNumScanned'
from base
where rk<=5

---Q3 When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?

select
r.rewardsReceiptStatus
,avg(totalSpent) as AvgSpent

from receipt as r
where r.rewardsReceiptStatus in ("Accepted" , "Rejected")

group by r.rewardsReceiptStatus


---Q4 When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
select
r.rewardsReceiptStatus
,sum(purchasedItemCount) as TotalPurchasedItemCount

from receipt as r
where r.rewardsReceiptStatus in ("Accepted" , "Rejected")

group by r.rewardsReceiptStatus


-- Q5 Which brand has the most spend among users who were created within the past 6 months?
with base as (
select

b.name as BrandName
sum(i.finalPrice) as TotalSpend

from users as u 
join receipt as r on u.user_id = r.user_id
join items as i on i.receipt_id = r.receipt_id
join brands as b on r.barcode = i.barcode

where cast(u.createdDate as date) >= DATEADD(MONTH, -6, GETDATE()) 
group by b.name

)

,temp as (
select

b.*,
dense_rank() over (order by TotalSpend desc) as rk
from base as b

)

select
BrandName
TotalSpend
from temp
where rk==1


---Q6 Which brand has the most transactions among users who were created within the past 6 months?

with base as (
select

b.name as BrandName
count(i.receipt_id) as TNumTrans

from users as u 
join receipt as r on u.user_id = r.user_id
join items as i on i.receipt_id = r.receipt_id
join brands as b on r.barcode = i.barcode

where cast(u.createdDate as date) >= DATEADD(MONTH, -6, GETDATE()) 
group by b.name

)

,temp as (
select

b.*,
dense_rank() over (order by TotalSpend desc) as rk
from base as b

)

select
BrandName
TNumTrans
from temp
where rk==1
