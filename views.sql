CREATE or REPLACE SECURE VIEW Dim_Channel_v as
SELECT  DimChannelID,
        SourceChannelID,
        SourceChannelCategoryID,
        ChannelName,
        ChannelCategory
FROM Dim_Channel;

CREATE or REPLACE SECURE VIEW Dim_Customer_v as 
SELECT DimCustomerID, 
       DimLocationID,
       SourceCustomerID,
       CUSTOMERFULLNAME,
       CUSTOMERFIRSTNAME,
       CUSTOMERLASTNAME,
       CUSTOMERGENDER
FROM Dim_Customer;

CREATE or REPLACE SECURE VIEW Dim_Location_v as 
SELECT DimLocationID,
       ADDRESS,
       CITY,
       POSTALCODE,
       STATE_PROVINCE,
       COUNTRY
FROM Dim_Location;

CREATE or REPLACE SECURE VIEW Dim_Date_v as 
SELECT DATE_PKEY,
	DATE,
	FULL_DATE_DESC,
	DAY_NUM_IN_WEEK,
	DAY_NUM_IN_MONTH,
	DAY_NUM_IN_YEAR,
	DAY_NAME,
	DAY_ABBREV,
	WEEKDAY_IND,
	US_HOLIDAY_IND,
	_HOLIDAY_IND,
	MONTH_END_IND,
	WEEK_BEGIN_DATE_NKEY,
	WEEK_BEGIN_DATE,
	WEEK_END_DATE_NKEY,
	WEEK_END_DATE,
	WEEK_NUM_IN_YEAR,
	MONTH_NAME,
	MONTH_ABBREV,
	MONTH_NUM_IN_YEAR,
	YEARMONTH,
	QUARTER,
	YEARQUARTER,
	YEAR,
	FISCAL_WEEK_NUM,
	FISCAL_MONTH_NUM,
	FISCAL_YEARMONTH,
	FISCAL_QUARTER,
	FISCAL_YEARQUARTER,
	FISCAL_HALFYEAR,
	FISCAL_YEAR,
	SQL_TIMESTAMP,
	CURRENT_ROW_IND,
	EFFECTIVE_DATE,
	EXPIRATION_DATE
FROM Dim_Date;

CREATE or REPLACE SECURE VIEW Dim_Product_v as 
SELECT DIMPRODUCTID,
	PRODUCTID,
	PRODUCTTYPEID,
	PRODUCTCATEGORYID,
	PRODUCTNAME,
	PRODUCTTYPE,
	PRODUCTCATEGORY,
	PRODUCTRETAILPRICE,
	PRODUCTWHOLESALEPRICE,
	PRODUCTCOST,
	PRODUCTRETAILPROFIT,
	PRODUCTWHOLESALEUNITPROFIT,
	PRODUCTPROFITMARGINUNITPERCENT
FROM Dim_Product;

CREATE or REPLACE SECURE VIEW Dim_Reseller_v as 
SELECT DIMRESELLERID,
	DIMLOCATIONID,
	SOURCERESELLERID,
	RESELLERNAME,
	CONTACTNAME,
	PHONENUMBER,
	EMAIL 
FROM Dim_Reseller;

CREATE or REPLACE SECURE VIEW Dim_Store_v as 
SELECT DIMSTOREID,
	DIMLOCATIONID,
	SOURCESTOREID,
	STORENUMBER,
	STOREMANAGER 
FROM Dim_Store;

CREATE or REPLACE SECURE VIEW Fact_SalesActual_v as 
SELECT DIMPRODUCTID,
	DIMSTOREID,
	DIMRESELLERID,
	DIMCUSTOMERID,
	DIMCHANNELID,
	DIMSALEDATEID,
	DIMLOCATIONID,
	SALESHEADERID,
	SALESDETAILID,
	SALEAMOUNT,
	SALEQUANTITY,
	SALEUNITPRICE,
	SALEEXTENDEDCOST,
	SALETOTALPROFIT 
FROM FACT_SALESACTUAL;

CREATE or REPLACE SECURE VIEW Fact_ProductSalesTarget_v as 
SELECT DIMPRODUCTID,
	DIMTARGETDATEID,
	PRODUCTTARGETSALESQUANTITY 
FROM Fact_ProductSalesTarget;

CREATE or REPLACE SECURE VIEW Fact_SRCSalesTarget_v as 
SELECT DIMSTOREID,
	DIMRESELLERID,
	DIMCHANNELID,
	DIMTARGETDATEID,
	SALESTARGETAMOUNT 
FROM Fact_SRCSalesTarget;

--SELECT * from fact_salesactual;

SELECT * from BQ1;

CREATE or REPLACE SECURE VIEW BQ1 as 
SELECT 
    Dim_date.Day_num_in_week, 
    Dim_date.Day_name, 
    Dim_date.YearMonth, 
    Dim_date.month_name, 
    Dim_date.year, 
    Dim_date.fiscal_quarter, 
    Dim_date.Date, 
    Dim_store.storenumber, 
    fact_srcsalestarget.salestargetamount,
    SUM(fact_salesactual.saleamount) AS TotalSalesAmount
FROM 
    FACT_SRCSALESTARGET
LEFT JOIN 
    DIM_DATE ON FACT_SRCSalesTarget.DIMTARGETDATEID = DIM_DATE.DATE_PKEY
LEFT JOIN 
    DIM_STORE ON fact_SRCSalesTarget.dimstoreid = dim_store.dimstoreid
LEFT JOIN 
    FACT_SALESACTUAL ON DIM_DATE.date_pkey = FACT_SalesActual.DIMSALEDATEID
                    AND Dim_store.dimstoreid = FACT_SalesActual.dimstoreid
GROUP BY 
    Dim_date.Day_num_in_week, 
    Dim_date.Day_name, 
    Dim_date.YearMonth, 
    Dim_date.month_name, 
    Dim_date.year, 
    Dim_date.fiscal_quarter, 
    Dim_date.Date, 
    Dim_store.storenumber, 
    fact_srcsalestarget.salestargetamount
HAVING 
    Dim_store.STORENUMBER IN (5, 8, 10, 21, 34, 39)
ORDER BY 
    DIM_DATE.DATE

select * from BQ2;

--BQ2
CREATE or REPLACE SECURE VIEW producttype_targetsale as 
SELECT  
    FACT_PRODUCTSALESTARGET.dimtargetdateid, 
    dim_product.producttype, 
    SUM(fact_productsalestarget.producttargetsalesquantity) AS TargetSaleQuantity
FROM 
    fact_productsalestarget
LEFT JOIN 
    dim_product ON fact_productsalestarget.dimproductid = dim_product.dimproductid
GROUP BY 
    FACT_PRODUCTSALESTARGET.dimtargetdateid, 
    dim_product.producttype 
ORDER BY 
    fact_productsalestarget.dimtargetdateid;

select * from fact_productsalestarget;
select * from producttype_targetsale;
select * from fact_salesactual;
select * from dim_product;
select * from dim_store;
select * from dim_date;

select * from BQ2;

select sum(fact_salesactual.salequantity)
from fact_salesactual
where dimsaledateid = 20130101 and dimstoreid = 1 and dimproductid in (3,4,5);

--
select sum(salequantity)
from
BQ2
where producttype = 'Men\'s Casual' AND storenumber = 5 AND year(date)=2014;


CREATE or REPLACE SECURE VIEW BQ2 as 
SELECT 
    d.date,
    s.storenumber,
    p.producttype,
    p.productcategory,
    p.productname,
    SUM(fa.salequantity) AS salequantity,
    SUM(fa.saleamount) AS saleamount
FROM 
    fact_salesactual fa
JOIN 
    dim_date d ON fa.dimsaledateid = d.date_pkey
JOIN 
    dim_store s ON fa.dimstoreid = s.dimstoreid
JOIN
    dim_product p ON fa.dimproductid = p.dimproductid
GROUP BY 
    d.date,
    s.storenumber,
    p.producttype,
    p.productcategory,
    p.productname
HAVING s.storenumber in (5, 8, 10, 21, 34, 39)
ORDER BY 
    d.date,
    s.storenumber,
    p.producttype;





-- BQ3
CREATE SECURE VIEW BQ3a as 
SELECT 
    d.day_name AS day_of_week,
    p.producttype,
    s.storenumber,
    SUM(fa.salequantity) AS totalsalequantity
FROM 
    fact_salesactual fa
JOIN 
    dim_date d ON fa.dimsaledateid = d.date_pkey
JOIN 
    dim_store s ON fa.dimstoreid = s.dimstoreid
JOIN 
    dim_product p ON fa.dimproductid = p.dimproductid
GROUP BY 
    d.day_name,
    p.producttype,
    s.storenumber
HAVING s.storenumber in (5, 8, 10, 21, 34, 39)
    ORDER BY 
    d.day_name,
    p.producttype,
    s.storenumber;

CREATE SECURE VIEW BQ3b as 
SELECT 
    d.day_name AS day_of_week,
    p.producttype,
    p.productname,
    s.storenumber,
    SUM(fa.salequantity) AS totalsalequantity
FROM 
    fact_salesactual fa
JOIN 
    dim_date d ON fa.dimsaledateid = d.date_pkey
JOIN 
    dim_store s ON fa.dimstoreid = s.dimstoreid
JOIN 
    dim_product p ON fa.dimproductid = p.dimproductid
GROUP BY 
    d.day_name,
    p.producttype,
    p.productname,
    s.storenumber
HAVING 
    s.storenumber IN (5, 8, 10, 21, 34, 39)
ORDER BY 
    d.day_name,
    p.producttype,
    p.productname,
    s.storenumber;

CREATE SECURE VIEW BQ3c as
SELECT 
    d.day_name AS day_of_week,
    p.producttype,
    p.productcategory,
    s.storenumber,
    SUM(fa.salequantity) AS totalsalequantity
FROM 
    fact_salesactual fa
JOIN 
    dim_date d ON fa.dimsaledateid = d.date_pkey
JOIN 
    dim_store s ON fa.dimstoreid = s.dimstoreid
JOIN 
    dim_product p ON fa.dimproductid = p.dimproductid
GROUP BY 
    d.day_name,
    p.producttype,
    p.productcategory,
    s.storenumber
HAVING 
    s.storenumber IN (5, 8, 10, 21, 34, 39)
ORDER BY 
    d.day_name,
    p.producttype,
    p.productcategory,
    s.storenumber;

select * from BQ2;

select * from fact_productsalestarget;

CREATE or REPLACE SECURE VIEW BQ3all as
SELECT 
    d.date,
    d.day_name AS day_of_week,
    p.producttype,
    p.productcategory,
    p.productname,
    s.storenumber,
    SUM(fa.salequantity) AS totalsalequantity,
    SUM(fa.saleamount) AS saleamount
FROM 
    fact_salesactual fa
JOIN 
    dim_date d ON fa.dimsaledateid = d.date_pkey
JOIN 
    dim_store s ON fa.dimstoreid = s.dimstoreid
JOIN 
    dim_product p ON fa.dimproductid = p.dimproductid
GROUP BY 
    d.date,
    d.day_name,
    p.producttype,
    p.productcategory,
    p.productname,
    s.storenumber
HAVING 
    s.storenumber IN (5, 8, 10, 21, 34, 39)
ORDER BY 
    d.day_name,
    p.producttype,
    p.productcategory,
    p.productname,
    s.storenumber;
    

select * from BQ3all;    

-- BQ4
select STATE_PROVINCE, count(*) from
(select * from dim_location
where dimlocationid in (8, 9, 10, 11, 12, 13))
group by STATE_PROVINCE;

 
    CREATE or REPLACE SECURE VIEW BQ4 as
SELECT 
    d.date,
    s.storenumber,
    p.producttype,
    p.productname,
    p.productcategory,
    l.state_province,
    SUM(fa.salequantity) AS totalsalequantity,
    SUM(fa.saleamount) AS saleamount
FROM 
    fact_salesactual fa
JOIN 
    dim_date d ON fa.dimsaledateid = d.date_pkey
JOIN 
    dim_store s ON fa.dimstoreid = s.dimstoreid
JOIN 
    dim_location l ON fa.dimlocationid = l.dimlocationid
JOIN
    dim_product p ON fa.dimproductid = p.dimproductid
GROUP BY 
    d.date,
    s.storenumber,
    l.state_province,
    p.producttype,
    p.productname,
    p.productcategory
HAVING 
    s.storenumber IN (5, 8, 10, 21, 34, 39)
ORDER BY 
    d.date,
    s.storenumber,
    l.state_province;

select * from dim_product
order by productprofitmarginunitpercent desc;

CREATE or REPLACE SECURE VIEW BQP as 
SELECT 
    Dim_date.Day_num_in_week, 
    Dim_date.Day_name, 
    Dim_date.YearMonth, 
    Dim_date.month_name, 
    Dim_date.year, 
    Dim_date.fiscal_quarter, 
    Dim_date.Date, 
    Dim_store.storenumber,
    Dim_product.producttype,
    Dim_product.productcategory,
    Dim_product.productname,
    SUM(fact_salesactual.saleamount) AS TotalSalesAmount,
    fact_salesactual.saleamount - fact_salesactual.saleextendedcost as TotalSalesProfit
FROM 
    FACT_SALESACTUAL
LEFT JOIN 
    DIM_DATE ON FACT_SalesActual.DIMSALEDATEID= DIM_DATE.DATE_PKEY
LEFT JOIN 
    DIM_STORE ON FACT_SalesActual.dimstoreid = dim_store.dimstoreid
LEFT JOIN
    DIM_PRODUCT ON FACT_SalesActual.DIMPRODUCTID = DIM_PRODUCT.dimproductid
GROUP BY 
    Dim_date.Day_num_in_week, 
    Dim_date.Day_name, 
    Dim_date.YearMonth, 
    Dim_date.month_name, 
    Dim_date.year, 
    Dim_date.fiscal_quarter, 
    Dim_date.Date, 
    Dim_store.storenumber, 
    Dim_product.producttype,
    Dim_product.productcategory,
    Dim_product.productname,
    TotalSalesProfit
HAVING 
    Dim_store.STORENUMBER IN (5, 8, 10, 21, 34, 39)
ORDER BY 
    DIM_DATE.DATE


select * from fact_salesactual;
where dimsaledateid=20130101 and dimstoreid=5 and dimproductid=17

select * from BQP
where YEAR = 2014;

select * from BQ4;

select year(BQ2.DATE), STORENUMBER, SUM(SALEAMOUNT) from BQ2;

CREATE or REPLACE SECURE VIEW Bonus as 
SELECT 
    YEAR(DATE) AS year, 
    STORENUMBER, 
    SUM(SALEAMOUNT) AS total_sale_amount
FROM 
    BQ2
WHERE 
    PRODUCTTYPE IN ('Men''s Casual', 'Women''s Casual')
GROUP BY 
    YEAR(DATE), 
    STORENUMBER
HAVING STORENUMBER IN (5, 8);

select * from bonus;

select * from salesbonussummary;

select * from bq3all;
