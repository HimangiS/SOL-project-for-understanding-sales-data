select * from customer;
select * from date;
select * from geography;
select * from internet_sales;
select * from product;
select * from productcategory;
select * from productsubcategory;
select * from sales_customer;

-- Create the internetsales table if it doesn't exist
CREATE TABLE internet_sales (
    productkey INT,
    orderdatekey INT,
    duedatekey INT,
    shipdatekey INT,
    customerkey INT,
    salesordernumber VARCHAR(50),
    salesamount NUMERIC
);

-- Import data from the CSV file into the internetsales table
COPY internet_sales(productkey, orderdatekey, duedatekey, shipdatekey, customerkey, salesordernumber, salesamount)
FROM 'C:\Program Files\PostgreSQL\16\data\data copy\sales.csv' DELIMITER ',' CSV HEADER;




COPY internetsales FROM 'C:\Program Files\PostgreSQL\16\data\data copy\internetsales.csv' DELIMITER ',' CSV HEADER;


SELECT COUNT(*) FROM internetsales;


CREATE TABLE productmerged AS
SELECT 
    p.productkey,
    p.englishproductname,
    pc.englishproductcategoryname,
    psc.englishproductsubcategoryname,
    p.color,
    p.size,
    p.startdate,
    p.enddate,
    p.status,
    p.reorderpoint,
    p.daystomanufacture,
    p.productline
FROM 
    product p
JOIN 
    productsubcategory psc ON p.productsubcategorykey = psc.productsubcategorykey
JOIN 
    productcategory pc ON psc.productcategorykey = pc.productcategorykey;

select * from productmerged;


ALTER TABLE internet_sales
ALTER COLUMN orderdatekey TYPE DATE USING TO_DATE(orderdatekey::text, 'YYYYMMDD'),
ALTER COLUMN shipdatekey TYPE DATE USING TO_DATE(shipdatekey::text, 'YYYYMMDD'),
ALTER COLUMN duedatekey TYPE DATE USING TO_DATE(duedatekey::text, 'YYYYMMDD');



/*Q1*/
CREATE TABLE top_10_products_by_sales AS
SELECT 
    p.productkey,
    p.englishproductname AS product_name,
    SUM(salesamount) AS total_sales_amount
FROM 
    internet_sales i
JOIN 
    productmerged p ON i.productkey = p.productkey
GROUP BY 
    p.productkey, p.englishproductname
ORDER BY 
    total_sales_amount DESC
LIMIT 
    10;
	
	
select * from top_10_products_by_sales;	


/*Q2*/
CREATE TABLE top_10_customers AS
SELECT 
    c.customerkey,
    CONCAT(c.firstname, ' ', c.lastname) AS customer_name,
    SUM(s.salesamount) AS total_sales_amount
FROM 
    internet_sales s
JOIN 
    customer c ON s.customerkey = c.customerkey
GROUP BY 
    c.customerkey, customer_name
ORDER BY 
    total_sales_amount DESC
LIMIT 
    10;

select * from top_10_customers;

/*Q3*/

CREATE TABLE sales_budget (
    date DATE,
    budget NUMERIC
);

COPY sales_budget(date, budget) FROM 'C:\Program Files\PostgreSQL\16\data\data copy\salesbudget.csv' DELIMITER ',' CSV HEADER;

select * from sales_budget;

CREATE TABLE sales_vs_budget AS
SELECT 
    TO_CHAR(s.orderdatekey, 'YYYY-MM') AS month_year,
    SUM(s.salesamount) AS actual_sales,
    sb.budget AS budgeted_sales,
    SUM(s.salesamount) - sb.budget AS sales_difference
FROM 
    internet_sales s
JOIN 
    sales_budget sb ON TO_CHAR(s.orderdatekey, 'YYYY-MM') = TO_CHAR(sb.date, 'YYYY-MM')
GROUP BY 
    month_year, sb.budget;

select * from sales_vs_budget;

/*Q4*/
CREATE TABLE sales_by_region_city AS
SELECT 
    g.city,
    g.stateprovincename AS state_province,
    g.countryregioncode AS country_region,
    SUM(s.salesamount) AS total_sales_amount
FROM 
    internet_sales s
JOIN 
    customer c ON s.customerkey = c.customerkey
JOIN 
    geography g ON c.geographykey = g.geographykey
GROUP BY 
    g.city, g.stateprovincename, g.countryregioncode;


select * from sales_by_region_city;

/*Q5*/
CREATE TABLE product_categories_sales AS
SELECT 
    pm.englishproductcategoryname AS product_category,
    SUM(s.salesamount) AS total_sales_amount
FROM 
    internet_sales s
JOIN 
    productmerged pm ON s.productkey = pm.productkey
GROUP BY 
    pm.englishproductcategoryname;

select * from product_categories_sales;

