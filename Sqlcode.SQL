
---------------------------------------1st Part (5 Queries) ----------------------------------------------------------

----------------1st Query (Rank for Countries per No. of Orders ------------------------------------------------------

select "Country", "No of Orders per Country",
row_number() over(order by "No of Orders per Country" DESC)
from (select "Country", count("Country") as "No of Orders per Country"
from public."Online_Retail"
group by "Country") as sub_query


-----------------2nd Query ( Rank for Countries per Sales------------------------------------------------------------

select "Country", "Sales Per Country",
row_number() over(order by "Sales Per Country" DESC)
from (select "Country",
	  round(sum("Quantity"*"UnitPrice")::numeric,2) as "Sales Per Country"
from public."Online_Retail"
group by "Country") as sub_query


--------------------3rd Query (Rank for Products per Quantity-------------------------------------------------------

select "Description", "Total Quantitiy",
row_number() over(order by "Total Quantitiy" DESC) as "Rank"
from (select "Description", sum("Quantity") as "Total Quantitiy"  
	from public."Online_Retail"
	group by "Description") as sub_query

--------------4th Query (Rank for Products per Sales---------------------------------------------------------------

select "Description", "Product Sales",
row_number() over(order by "Product Sales" DESC) as "Sales Rank per Product"
from (select "Description", round(sum("Quantity"*"UnitPrice")::numeric,2) as "Product Sales"  
	from public."Online_Retail"
	group by "Description") as sub_query	

--------------5th Query (Highest and Lowest Product Sales Per Country------------------------------------------------

select distinct "Country", first_value("Description") over (partition by "Country" order by  "Product Sales per Country" 
                                                   rows between unbounded preceding and unbounded following) as "Highest Sold Product",
last_value("Description") over (partition by "Country" order by "Product Sales per Country" 
                                rows between unbounded preceding and unbounded following) as "Lowest Sold Product"
from (select "Country", "Description",
	  round(sum("Quantity"*"UnitPrice")::numeric,2) as "Product Sales per Country"
from public."Online_Retail"
    group by "Country", "Description" ) as sub_query


-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
------------------------------2nd Part of Project------------------------------------------------------------------

with "cte" AS
( 
	SELECT 
   "CustomerID", "Recency", "Frequency", "Monetary",
	ntile(5) over(order by "Recency" Desc) as "Recency_score", 
    ((NTILE(5) OVER( ORDER BY ("Frequency"))) + (NTILE(5) OVER( ORDER BY ("Monetary"))) )/2 AS "FM_Score"
	 
	from ( select "CustomerID", count("InvoiceNo") as "Frequency",
		   round(sum("Quantity"*"UnitPrice")::numeric,2) as "Monetary",
           (select max("InvoiceDate") from public."Online_Retail") - max("InvoiceDate") as "Recency"
		 from public."Online_Retail" group by "CustomerID") as Sub_Query
	
) 
select "CustomerID", "Recency", "Frequency", "Monetary",
case when ("Recency_score" = 5 and "FM_Score" in (5,4)) or ("Recency_score" = 4 and "FM_Score" = 5) then 'Champions'
when ("Recency_score" in(5,4) and "FM_Score" = 2) or ("Recency_score" in (3,4) and "FM_Score" = 3) then 'Potential Loyalists'
when ("Recency_score" = 5 and "FM_Score" = 3) or ("Recency_score" = 4 and "FM_Score" = 4) 
or ("Recency_score" = 3 and "FM_Score" in (4,5)) then 'Loyal Customers'
when "Recency_score" = 5 and "FM_Score" = 1 then 'Recent Customers'
when "Recency_score" in(4,3) and "FM_Score" = 1 then 'Promising'
when ("Recency_score" = 2 and "FM_Score" in(2,3)) or ("Recency_score" = 3 and "FM_Score" = 2) then 'Customers Needing Attention'
when ("Recency_score" = 2 and "FM_Score" in(4,5)) or ("Recency_score" = 1 and "FM_Score" = 3) then 'At Risk'
when "Recency_score" = 1 and "FM_Score" in (5,4) then 'Cant Lose Them'
when "Recency_score" = 1 and "FM_Score" = 2 then 'Hibernating'
when "Recency_score" = 1 and "FM_Score" = 1 then 'Lost'
end as "Cust_Segment"
from "cte";



