<h1>StoreCars: Customers and Products Analysis</h1>

![StoreCarsImage](https://github.com/dayannefuentes/Portfolio-Projects/assets/167659572/50f6e41b-e862-49b6-a9e3-fa9171bcdfcc)



<h1><a name="Introduction">Introduction</a></h1>
<p>StoreCars is a fictitious wholesale distributor of scale model classic cars that operates globally. It is requesting an analysis of its database in order to learn valuable information about its products and consumers that will allow it to make strategic decisions for its business.</p>

<h1><a name="Objetive">Objetive</a></h1>
<p>To obtain valuable information about customers and the products offered by the company. This may include sales trends, customer preferences, product profitability analysis, among other relevant aspects.</p>

<h1><a name="Database">Database</a></h1>
<p>The original database for this project was SQLite, for its correct use in SSMS the Linked Servers and the ODBC Migration tool were used.</p>

<h1><a name="Exploring the data set">Exploring the data set</a></h1>
<p>The database is as follows:
  
The scale model cars database contains eight tables: 

- Customers: basic customer information such as name, phone and address. 

- Employees: basic employee information such as name, email, job title and who they report to.

- Offices: basic sales office information such as address and phone number. Orders: customer sales orders with order dates, require dates, process status and comments. OrderDetails: detailed information or sales order line for each sales order. 

- Payments: customers' payment records Products: a list of scale model vehicles ProductLines: a list of product line categories.

Each table contains a column with its primary key, and is linked to the key of another table as shown in the schematic (IMAGE)  



<img width="500" alt="Schema" src="https://github.com/dayannefuentes/Portfolio-Projects/blob/main/schema%20stores.png">

Information about the relationships between tables can also be obtained in tabular form using the following query:

```sql
SELECT OBJECT_NAME(f.parent_object_id) AS TableWithForeignKey,
       COL_NAME(fc.parent_object_id, fc.parent_column_id) AS ForeignKeyColumn,
       OBJECT_NAME(f.referenced_object_id) AS ReferencedTable,
       COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS ReferencedColumn
  FROM sys.foreign_keys AS f
  JOIN sys.foreign_key_columns AS fc
    ON f.object_id = fc.constraint_object_id   -- The information for the main tables to be used is queried.
```
```sql
SELECT *
  FROM OPENQUERY(STORES , 'SELECT * FROM customers')
```
```sql
SELECT *
  FROM OPENQUERY(STORES , 'SELECT * FROM orderdetails')
```
```sql
SELECT *
  FROM OPENQUERY(STORES , 'SELECT * FROM products') 
```
</p>

<h1><a name="Analyzing the data set">Analyzing the data set</a></h1>
<p>
To begin the analysis of the information, the behavior of the company's products must be known. A series of questions will be answered to analyze the product and below the question the query used to answer the question will be displayed. 
</p>
<ol>
<li><h5>What are the best-selling products?</h5></li>
  
```sql
SELECT od.productCode,           
       p.productName, 		 
       p.productLine, 		 
       SUM(od.quantityOrdered) AS TotalProductSold     
  FROM OPENQUERY(STORES , 'SELECT * FROM orderdetails') od     
  JOIN OPENQUERY(STORES , 'SELECT * FROM products') p 	  
    ON od.productCode = p.productCode    
 GROUP BY od.productCode, p.productName, p.productLine   
 ORDER BY TotalProductSold DESC
```
<h6>Answer:</h6>
<img width="373" alt="a)" src="https://github.com/dayannefuentes/Portfolio-Projects/assets/167659572/47cad453-e81d-4218-9c89-f30503cc0f4e">

 <p>The best-selling product is the 1992 Ferrari 360 Spider red with a total of 1808 sales, followed by 1937 Lincoln Berline with 1111 sales and in third place American Airlines: MD-11S with 1085 products sold. 
  
The product with the lowest product sold was 1957 Ford Thunderbird.
</p>

<li><h5>What is the best product per office?</h5></li>

```sql
WITH CTE_products_rank AS (
SELECT offices.city, 	        
       od.productCode, 			  
       p.productName,  			 
       p.productLine, 			 
       SUM(od.quantityOrdered) AS TotalProductSold, 			 
       RANK() OVER (PARTITION BY offices.city ORDER BY SUM(od.quantityOrdered)DESC) AS rank 		
  FROM OPENQUERY(STORES , 'SELECT * FROM products') p 	   
  JOIN OPENQUERY(STORES , 'SELECT * FROM orderdetails') od 	      
    ON od.productCode = p.productCode 		
  JOIN OPENQUERY(STORES , 'SELECT * FROM orders') o 		
    ON o.orderNumber = od.orderNumber 	
  JOIN OPENQUERY(STORES , 'SELECT * FROM customers') c 		 
    ON c.customerNumber = o.customerNumber 	   
  JOIN OPENQUERY(STORES , 'SELECT * FROM employees') e 		  
    ON e.employeeNumber = c.salesRepEmployeeNumber 		
  JOIN OPENQUERY(STORES , 'SELECT * FROM offices') offices 		  
    ON offices.officeCode = e.officeCode 	  
 GROUP BY offices.city, od.productCode, p.productName, p.productLine  
)  
SELECT * 
  FROM CTE_products_rank
 WHERE rank = 1
 ORDER BY TotalProductSold DESC
```
<h6>Answer:</h6>
<img width="407" alt="b2)" src="https://github.com/dayannefuentes/Portfolio-Projects/assets/167659572/595ff5e7-1b35-4cc4-b32f-f414a2baecaf">

<p>In three of the seven offices, the product with the highest sales is 1992 Ferrari 360 Spider red. Paris is the office with the highest sales of this product with 744 sales.</p>

<li><h5>What is the best-selling product line?</h5></li>

```sql
SELECT p.productLine,
       SUM(od.quantityOrdered) AS TotalProductSold,
       CAST((SUM(od.quantityOrdered)*1.0/(SELECT SUM(quantityOrdered) FROM OPENQUERY(STORES , 'SELECT * FROM orderdetails')))*100 AS DECIMAL(10,2)) AS PercentageProductSold
  FROM OPENQUERY(STORES , 'SELECT * FROM orderdetails') od
  JOIN OPENQUERY(STORES , 'SELECT * FROM products') p
    ON od.productCode = p.productCode
 GROUP BY p.productLine
 ORDER BY TotalProductSold DESC 
```
<h6>Answer:</h6>
 <img width="262" alt="c)" src="https://github.com/dayannefuentes/Portfolio-Projects/assets/167659572/65d32ae5-e6db-49d1-8e25-57d9123dac48">

<p>The best-selling product line is Classic Cars with a total of 35582 sales, which represents 33.72% of the total product sold.
  
The product line with the lowest sales is Trains.</p>

<li><h5>In which country do customers buy the most products?</h5></li>

```sql
SELECT c.country,
       SUM(od.quantityOrdered) AS TotalProductSold,
       CAST((SUM(od.quantityOrdered)*1.0/(SELECT SUM(quantityOrdered) FROM OPENQUERY(STORES , 'SELECT * FROM orderdetails')))*100 AS DECIMAL(10,2)) AS percentageProductSold
  FROM OPENQUERY(STORES , 'SELECT * FROM customers') c
  JOIN OPENQUERY(STORES , 'SELECT * FROM orders') o
    ON c.customerNumber = o.customerNumber
  JOIN OPENQUERY(STORES , 'SELECT * FROM orderdetails') od
    ON o.orderNumber = od.orderNumber
 GROUP BY c.country
 ORDER BY TotalProductSold DESC
```
<h6>Answer:</h6>
 <img width="239" alt="d)" src="https://github.com/dayannefuentes/Portfolio-Projects/assets/167659572/7484eff5-4ae4-4439-9fed-1993f1424f28">

<p>The U.S. is where consumers buy the most, with 33.97% of the products sold. Followed by Spain and France with 11.78% and 10.51% respectively.
  
The countries with the lowest sales are the Philippines, Hong Kong and Ireland.</p>

<li><h5>What is the performance of the products</h5></li>

```sql
 SELECT p.productCode,
        p.productName,
        ROUND(SUM(od.quantityOrdered*od.priceEach),2) AS productperformance
   FROM OPENQUERY(STORES , 'SELECT * FROM orderdetails') od
   JOIN OPENQUERY(STORES , 'SELECT * FROM products') p
     ON od.productCode = p.productCode
  GROUP BY p.productCode, p.productName
  ORDER BY SUM(od.quantityOrdered*od.priceEach) DESC
```
<h6>Answer:</h6>
 <img width="302" alt="e)" src="https://github.com/dayannefuentes/Portfolio-Projects/assets/167659572/d61aa83b-e56b-4182-b5d9-e6d8ddfaf93c">

<p>The product performance represents the sum of sales per product (Quantity ordered by price). The product with the highest performance was 1992 Ferrari 360 Spider red, this product as seen before was also one of the best sellers. In performance is followed by 2001 Ferrari Enzo and 1952 Alpine Renault 1300, these were not the best sellers but due to their selling price they are much more significant in terms of performance.

Although Ford Thunderbird, 1937 Lincoln Berline and American Airlines: MD-11S are the least sold, they have a good level of performance with respect to the total. The lowest performing products are 1982 Lamborghini Diablo, 1936 Mercedes Benz 500k Roadster and 1939 Chevrolet Deluxe Coupe.</p>

<li><h5>What are those products with low stock levels (i.e. products in demand)?</h5></li>

```sql
 SELECT p.productCode,
        p.productName,
        p.productLine,
        SUM(od.quantityOrdered) AS quantityOrdered,
        p.quantityInStock,
        ROUND(SUM(od.quantityOrdered)*1.0/p.quantityInStock ,2) AS lowstock
   FROM OPENQUERY(STORES , 'SELECT * FROM products') p
   JOIN OPENQUERY(STORES , 'SELECT * FROM orderdetails') od
     ON p.productCode = od.productCode
  GROUP BY p.productCode, p.productName, p.productLine, p.quantityInStock
  ORDER BY SUM(od.quantityOrdered)*1.0/p.quantityInStock DESC
```
<h6>Answer:</h6>
<img width="500" alt="f)" src="https://github.com/dayannefuentes/Portfolio-Projects/assets/167659572/c3c9aa1e-ae8c-4f62-92d5-7f5cd8810152">

<p>The low stock represents the quantity of the sum of each product ordered divided by the quantity of product in stock. The highest rates will be the products that are almost out-of-stock or completely out-of-stock. These products are 1960 BSA Gold Star DBD34, 1968 Ford Mustang and 1928 Ford Phaeton Deluxe. </p>

<li><h5>Which products should be ordered more?</h5></li>

```sql
WITH  CTE_product_performance AS (
SELECT p.productCode,
       p.productName,
       ROUND(SUM(od.quantityOrdered*od.priceEach),2) AS productperformance
  FROM OPENQUERY(STORES , 'SELECT * FROM orderdetails') od
  JOIN OPENQUERY(STORES , 'SELECT * FROM products') p
    ON od.productCode = p.productCode 	  GROUP BY p.productCode, p.productName ),

CTE_low_stock AS (
SELECT p.productCode,
       p.productName,
       p.productLine,
       SUM(od.quantityOrdered) AS quantityOrdered,
       p.quantityInStock,
       ROUND(SUM(od.quantityOrdered)*1.0/p.quantityInStock ,2) AS lowstock
  FROM OPENQUERY(STORES , 'SELECT * FROM products') p
  JOIN OPENQUERY(STORES , 'SELECT * FROM orderdetails') od
    ON p.productCode = od.productCode
 GROUP BY p.productCode, p.productName, p.productLine, p.quantityInStock
)

SELECT ls.*,
       pp.productperformance
 FROM (SELECT TOP 10 *
         FROM CTE_product_performance
        ORDER BY productperformance DESC) pp
 JOIN CTE_low_stock ls
   ON pp.productCode = ls.productCode
ORDER BY ls.lowstock DESC
```
<h6>Answer:</h6>
<img width="541" alt="g)" src="https://github.com/dayannefuentes/Portfolio-Projects/assets/167659572/d3fcde91-c43e-4747-be32-a67c43ffe084">

<p>Priority products for restocking are those with high product performance that are on the brink of being out of stock. As mentioned above, the Classic Cars product line is the one with the highest sales, and 6 of the 10 products with the highest performance belong to this category. Taking this into account the primary focus for restocking should be on classic cars. These items have a high sales frequency and are among the top-performing products. In addition to this product line, it is important to take into account the other products that are in the top 10 in performance and to give priority to their replenishment, taking into account their low stock levels.   

Knowing this will improve supply chain efficiency and increase user satisfaction by ensuring that the best performing products are always in stock and available.

 <ul><li><h5>Considering the low stock</h5></li></ul>

On the other hand, and just as important, we have the products that are low in stock, and that must be replenished by prioritizing those that have a better performance. 
</p>

```sql
WITH  CTE_product_performance AS (
SELECT p.productCode,
       p.productName,
       ROUND(SUM(od.quantityOrdered*od.priceEach),2) AS productperformance
  FROM OPENQUERY(STORES , 'SELECT * FROM orderdetails') od
  JOIN OPENQUERY(STORES , 'SELECT * FROM products') p
    ON od.productCode = p.productCode
 GROUP BY p.productCode, p.productName ),

CTE_low_stock AS (
SELECT p.productCode,
       p.productName,
       p.productLine,
       SUM(od.quantityOrdered) AS quantityOrdered,
       p.quantityInStock,
       ROUND(SUM(od.quantityOrdered)*1.0/p.quantityInStock ,2) AS lowstock
  FROM OPENQUERY(STORES , 'SELECT * FROM products') p
  JOIN OPENQUERY(STORES , 'SELECT * FROM orderdetails') od
    ON p.productCode = od.productCode
 GROUP BY p.productCode, p.productName, p.productLine, p.quantityInStock
)

SELECT ls.*,
       pp.productperformance
  FROM (SELECT TOP 10 *
          FROM CTE_low_stock
         ORDER BY lowstock DESC) ls
  JOIN CTE_product_performance pp
    ON pp.productCode = ls.productCode
 ORDER BY pp.productperformance DESC
```
<h6>Answer:</h6>
<img width="509" alt="g2)" src="https://github.com/dayannefuentes/Portfolio-Projects/assets/167659572/eb6edb0c-6c23-4594-865d-da48b299865c">

<p>Having this list we can point out the product 1968 Ford Mustang, this is in both lists, and should be the priority to be restocked, having high sales and good performance. Knowing this will improve supply chain efficiency and enhance user satisfaction by ensuring that the highest-demand products are consistently in stock and available.

This strategy guarantees that the most successful and in-demand products are restocked promptly, supporting the objective of maintaining sufficient inventory levels and satisfying customer needs.</p>

<li><h5> Which product has a higher profit? </h5></li>

```sql

SELECT p.productCode,
       p.productName,
       p.productLine,
       SUM(od.quantityOrdered*od.PriceEach) AS Revenue,
       SUM(od.quantityOrdered*(od.PriceEach-p.buyPrice)) AS Profit,
       CAST(SUM(od.quantityOrdered*(od.PriceEach-p.buyPrice))/SUM(od.quantityOrdered*od.PriceEach)*100 AS DECIMAL(10,2)) AS ProfitMargin
  FROM OPENQUERY(STORES , 'SELECT * FROM orderdetails') od
  JOIN OPENQUERY(STORES , 'SELECT * FROM products') p
    ON od.productCode = p.productCode
 GROUP BY p.productCode, p.productName, p.productLine
 ORDER BY Profit DESC

```
<h6>Answer:</h6>
 <img width="442" alt="h)" src="https://github.com/dayannefuentes/Portfolio-Projects/assets/167659572/44844d37-e942-4c33-ac96-b2aa56618752">

 
<p> The most profitable product is 1992 Ferrari 360 Spider red. Note that the second place and third place according to profit are the third and second place respectively according to revenue. This indicates that although 2001 Ferrari Enzo has higher revenue, the product 1952 Alpine Renault 1300 is more efficient in converting revenue into profit. Of these three products, the one with the highest Profit Margin is 1952 Alpine Renault 1300, which tells us that of the three, it is the most profitable.
</p>

<li><h5> Use the Pareto principle to analyze revenue by product line. </h5></li>

```sql
WITH ProductRevenue AS (
SELECT p.productLine,
       SUM(od.quantityOrdered*od.PriceEach) AS Revenue
  FROM OPENQUERY(STORES , 'SELECT * FROM orderdetails') od
  JOIN OPENQUERY(STORES , 'SELECT * FROM products') p
    ON od.productCode = p.productCode
 GROUP BY p.productLine )
,
Pareto AS (
SELECT *,
       SUM(Revenue) OVER (ORDER BY Revenue DESC) AS CumulativeRevenue,
       SUM(Revenue) OVER () AS TotalRevenue
  FROM ProductRevenue
)

SELECT *,
       (CumulativeRevenue / TotalRevenue) * 100 AS CumulativePercentage
  FROM Pareto
 ORDER BY CumulativeRevenue
```
<h6>Answer:</h6>
 <img width="372" alt="i)" src="https://github.com/dayannefuentes/Portfolio-Projects/assets/167659572/076e9cb4-3617-4d72-912c-340faee98740">

<p> 
Based on the Pareto principle, it can be seen that 70.5% of the revenue comes from the Classic Cars, Vintage Cars and Motorcycles product lines. Motorcycles 
</p>

<li><h5> Are there any products that have never been sold? </h5></li>

```sql
SELECT *
  FROM OPENQUERY(STORES , 'SELECT * FROM products')
 WHERE productCode NOT IN ( SELECT productCode
                              FROM OPENQUERY(STORES , 'SELECT * FROM orderdetails'))
```
<h6>Answer:</h6>
<img width="210" alt="j)" src="https://github.com/dayannefuentes/Portfolio-Projects/assets/167659572/322e2649-ba84-430b-8968-bcab7eff2b9e">

<p> 
The 1985 Toyota Supra has never been sold and has 7733 products in stock, an alarming number. This product is known as deadstock, as it has not been sold for a long period of time.  This product can become a financial burden, as they take up storage space and, over time, can cause losses due to possible damage. 
</p>

<li><h5> How is the revenue trend? </h5></li>

```sql
SELECT YEAR(o.orderDate) AS year,
       SUM(od.quantityOrdered) AS TotalProductSold,
       COUNT(*) AS TotalSales,
       ROUND(SUM(od.quantityOrdered*od.priceEach),2) AS Revenue,
       CAST(ISNULL((SUM(od.quantityOrdered*od.priceEach) - LAG(SUM(od.quantityOrdered*od.priceEach), 1) OVER (ORDER BY YEAR(o.orderDate)))/LAG(SUM(od.quantityOrdered*od.priceEach), 1) OVER (ORDER BY YEAR(o.orderDate)),0)*100 AS DECIMAL(10,2)) AS DiffRevenue
  FROM OPENQUERY(STORES , 'SELECT * FROM orders') o
  JOIN OPENQUERY(STORES , 'SELECT * FROM orderdetails') od
    ON o.orderNumber = od.orderNumber
  JOIN OPENQUERY(STORES , 'SELECT * FROM products') p
    ON od.productCode = p.productCode
 GROUP BY YEAR(o.orderDate)
 ORDER BY year 
```
<h6>Answer:</h6>
<img width="275" alt="k)" src="https://github.com/dayannefuentes/Portfolio-Projects/assets/167659572/3f26f6c1-9154-4a41-a34c-e6955277b18e">

<p> 
Overall sales, performance and profit increased from 2003 to 2004, revenue increased by 36.13%, but in 2005 seems to be decreasing. However, with the query below you can see that the complete information for the last year is not shown.
</p>

```sql
  SELECT MAX(orderDate) AS LastDate
    FROM OPENQUERY(STORES , 'SELECT * FROM orders')
```
<h6>Output:</h6>
<img width="76" alt="k2)" src="https://github.com/dayannefuentes/Portfolio-Projects/assets/167659572/26eec498-0f99-46d6-b430-48c22513d8f3">


 <ul><li><h5> Taking into account the YTD </h5></li></ul>
<p> YTD information will be used to know the sales made in the year up to May. </p>
 
 ```sql
WITH
CTE_YTD AS(
SELECT YEAR(o.orderDate) AS year,
       MONTH(o.orderDate) AS month,
       DATENAME(MONTH, o.orderDate) AS monthName,
       SUM(od.quantityOrdered) AS TotalProductSold,
       COUNT(*) AS TotalSales,
       ROUND(SUM(od.quantityOrdered*od.priceEach),2) AS Revenue,
       SUM(SUM(od.quantityOrdered*od.priceEach)) OVER (PARTITION BY YEAR(o.orderDate) ORDER BY MONTH(o.orderDate)) AS cumulativeRevenue, 		   
       CAST(ISNULL((SUM(od.quantityOrdered*od.priceEach) - LAG(SUM(od.quantityOrdered*od.priceEach), 1) OVER (ORDER BY YEAR(o.orderDate)))/LAG(SUM(od.quantityOrdered*od.priceEach), 1) OVER (PARTITION BY YEAR(o.orderDate) ORDER BY YEAR(o.orderDate),MONTH(o.orderDate)),0)*100 AS DECIMAL(10,2)) AS DiffRevenue
  FROM OPENQUERY(STORES , 'SELECT * FROM orders') o
  JOIN OPENQUERY(STORES , 'SELECT * FROM orderdetails') od
    ON o.orderNumber = od.orderNumber
  JOIN OPENQUERY(STORES , 'SELECT * FROM products') p
    ON od.productCode = p.productCode
 GROUP BY YEAR(o.orderDate),MONTH(o.orderDate),DATENAME(MONTH, o.orderDate)
)

SELECT year,
       monthName,
       Revenue,
       cumulativeRevenue,
       CAST(ISNULL((SUM(Revenue) - LAG(SUM(Revenue), 1) OVER (ORDER BY year))/LAG(SUM(Revenue), 1) OVER (ORDER BY year),0)*100 AS DECIMAL(10,2)) AS DiffRevenue,
       CAST(ISNULL((SUM(cumulativeRevenue) - LAG(SUM(cumulativeRevenue), 1) OVER (ORDER BY year))/LAG(SUM(cumulativeRevenue), 1) OVER (ORDER BY year),0)*100 AS DECIMAL(10,2)) AS DiffRevenueCumulative
  FROM CTE_YTD  WHERE month = 5
 GROUP BY year,month, monthName,Revenue, cumulativeRevenue
 ORDER BY year,month
```
<h6>Answer:</h6>
<img width="374" alt="k3)" src="https://github.com/dayannefuentes/Portfolio-Projects/assets/167659572/46bbde98-a06b-4216-8598-335c6ab2a2d2">

<p> 
It can be seen from the total accumulated revenue up to the month of May of each year that there is a significant increase, from 2003 to 2004 of 38.39%, and from 2004 to 2005 a much greater increase of 77.78%. This indicates an upward trend in revenue.
</p>

<li><h5> What is the best and worst selling product according to the product line? </h5></li>

```sql
WITH
CTE_BestProducts_Line AS (
SELECT p.productLine,
       p.productCode,
       p.productName,
       SUM(od.quantityOrdered) AS TotalProductSold,
       MAX(SUM(od.quantityOrdered)) OVER(PARTITION BY p.productLine) AS MaxProductSold,
       MIN(ISNULL(SUM(od.quantityOrdered),0)) OVER(PARTITION BY p.productLine) AS MinProductSold,
       RANK() OVER(PARTITION BY p.productLine ORDER BY SUM(od.quantityOrdered) DESC) AS RankMax,
       RANK() OVER(PARTITION BY p.productLine ORDER BY ISNULL(SUM(od.quantityOrdered),0) ASC) AS RankMin,
       MAX(SUM(od.quantityOrdered)) OVER(PARTITION BY p.productLine) - MIN(ISNULL(SUM(od.quantityOrdered),0)) OVER(PARTITION BY p.productLine) AS range   
  FROM OPENQUERY(STORES , 'SELECT * FROM orderdetails') od
 RIGHT JOIN OPENQUERY(STORES , 'SELECT * FROM products') p
    ON od.productCode = p.productCode
 GROUP BY p.productLine, p.productCode, p.productName
)

SELECT plmax.productLine,
       plmax.productCode AS Best_productCode,
       plmax.productName AS Best_productName,
       plmax.MaxProductSold AS Best_MaxProductSold,
       plmin.productCode AS Worst_productCode,
       plmin.productName AS Worst_productName,
       plmin.MinProductSold AS Worst_MinProductSold,
       plmax.range
 FROM (SELECT * FROM CTE_BestProducts_Line WHERE RankMax=1) plmax
 JOIN (SELECT * FROM CTE_BestProducts_Line WHERE RankMin=1) plmin
   ON plmax.productLine = plmin.productLine
ORDER BY plmax.MaxProductSold DESC
```
<h6>Answer:</h6>
<img width="692" alt="l)" src="https://github.com/dayannefuentes/Portfolio-Projects/assets/167659572/ad4cc57b-255e-49cd-a435-a586db2d7144">

<p> 
Although the product line has the best-selling product, it also has a product that has no sales. This makes for a very large range of sales. This shows a great variability in the demand for this category. In the case of the train product line, it is the lowest sales category and the range is very small, there is not much difference between the product that sells the most and the one that sells the least, so it is a category that could be for a specific customer segment, this segment could be identified and a marketing study could be done.
</p>

<li><h5> What is the best and worst selling product line according to the country? </h5></li>

```sql
WITH
CTE_BestProducts_country AS (
SELECT c.country,
       p.productLine,
       MAX(SUM(od.quantityOrdered)) OVER(PARTITION BY c.country) AS MaxProductSold,
       MIN(ISNULL(SUM(od.quantityOrdered),0)) OVER(PARTITION BY c.country) AS MinProductSold,
       RANK() OVER(PARTITION BY c.country ORDER BY SUM(od.quantityOrdered) DESC) AS RankMax,
       RANK() OVER(PARTITION BY c.country ORDER BY ISNULL(SUM(od.quantityOrdered),0) ASC) AS RankMin,
       MAX(SUM(od.quantityOrdered)) OVER(PARTITION BY c.country) - MIN(ISNULL(SUM(od.quantityOrdered),0)) OVER(PARTITION BY c.country) AS range
  FROM OPENQUERY(STORES , 'SELECT * FROM products') p
  JOIN OPENQUERY(STORES , 'SELECT * FROM orderdetails') od
    ON od.productCode = p.productCode
  JOIN OPENQUERY(STORES , 'SELECT * FROM orders') o
	  ON o.orderNumber = od.orderNumber
  JOIN OPENQUERY(STORES , 'SELECT * FROM customers') c
    ON c.customerNumber = o.customerNumber
 GROUP BY c.country,  p.productLine
)

SELECT plmax.country,
       plmax.productLine AS Best_productLine,
       plmax.MaxProductSold AS Best_MaxProductSold,
       plmin.productLine AS Worst_productLine,
       plmin.MinProductSold AS Worst_MinProductSold,
       plmax.range
  FROM (SELECT * FROM CTE_BestProducts_country WHERE RankMax=1) plmax
  JOIN (SELECT * FROM CTE_BestProducts_country WHERE RankMin=1) plmin
    ON plmax.country = plmin.country
 ORDER BY plmax.country, plmax.MaxProductSold DESC
```
<h6>Answer:</h6>
<img width="436" alt="m)" src="https://github.com/dayannefuentes/Portfolio-Projects/assets/167659572/f0d15138-7198-4c12-8139-1e8aca2a410f">
<p> 
Most countries prefer the Classic Cars product line. However, in Canada they prefer Trucks and Buses, in Hong Kong and Japan they prefer Planes. The latter two categories are known to have the lowest sales. More research could be done on the market in these specific countries, understanding the customer's needs, increasing their visibility or complementing with other products to diversify it.
</p>

<li><h5> Which product lines have zero sales by country? </h5></li>

```sql
WITH
CTE_ProductLine_country AS (
SELECT p.productLine,
       c.country,
       ISNULL(SUM(od.quantityOrdered),0) AS TotalProductSold
  FROM OPENQUERY(STORES , 'SELECT * FROM products') p
  JOIN OPENQUERY(STORES , 'SELECT * FROM orderdetails') od
    ON od.productCode = p.productCode
  JOIN OPENQUERY(STORES , 'SELECT * FROM orders') o
    ON o.orderNumber = od.orderNumber
  JOIN OPENQUERY(STORES , 'SELECT * FROM customers') c
    ON c.customerNumber = o.customerNumber
 GROUP BY p.productLine, c.country
)

SELECT c.country,
       pl.productLine,
       ISNULL(cte.TotalProductSold,0) AS TotalProductSold
  FROM OPENQUERY(STORES , 'SELECT * FROM productlines') pl
 CROSS JOIN (SELECT DISTINCT(country)
  FROM OPENQUERY(STORES , 'SELECT * FROM customers')) c
  LEFT JOIN CTE_ProductLine_country cte
    ON pl.productLine = cte.productLine
       AND c.country = cte.country
 WHERE ISNULL(cte.TotalProductSold,0) = 0
 ORDER BY c.country, pl.productLine
```
<h6>Answer:</h6>
<img width="215" alt="n)" src="https://github.com/dayannefuentes/Portfolio-Projects/assets/167659572/4b742723-4eb7-4b78-a7df-ea93b1143eaa">
<p> 
Austria is a country where only the Trains category has not sold, the company could begin to explore how to introduce this category to the market. Hong Kong is a country where there are no sales of Classic cars (the best line of the company), the company could campaign to introduce this category as a complement to the Planes products. In general there are many countries that have many categories without purchases, therefore, there is a lot of market to explore. 
</p>

<li><h5> What is the best and worst selling product according to the country </h5></li>

```sql
WITH
CTE_BestProducts_country AS (
SELECT c.country,
       p.productCode,
       p.productName,
       SUM(od.quantityOrdered) AS TotalProductSold,
       MAX(SUM(od.quantityOrdered)) OVER(PARTITION BY c.country) AS MaxProductSold,
       MIN(ISNULL(SUM(od.quantityOrdered),0)) OVER(PARTITION BY c.country) AS MinProductSold,
       RANK() OVER(PARTITION BY c.country ORDER BY SUM(od.quantityOrdered) DESC) AS RankMax,
       RANK() OVER(PARTITION BY c.country ORDER BY ISNULL(SUM(od.quantityOrdered),0) ASC) AS RankMin,
       MAX(SUM(od.quantityOrdered)) OVER(PARTITION BY c.country) - MIN(ISNULL(SUM(od.quantityOrdered),0)) OVER(PARTITION BY c.country) AS range
  FROM OPENQUERY(STORES , 'SELECT * FROM products') p
  JOIN OPENQUERY(STORES , 'SELECT * FROM orderdetails') od
    ON od.productCode = p.productCode
  JOIN OPENQUERY(STORES , 'SELECT * FROM orders') o
    ON o.orderNumber = od.orderNumber
  JOIN OPENQUERY(STORES , 'SELECT * FROM customers') c
    ON c.customerNumber = o.customerNumber
 GROUP BY c.country,  p.productCode, p.productName
)

SELECT plmax.country,
       plmax.productCode AS Best_productCode,
       plmax.productName AS Best_productName,
       plmax.MaxProductSold AS Best_MaxProductSold,
       plmin.productCode AS Worst_productCode,
       plmin.productName AS Worst_productName,
       plmin.MinProductSold AS WorstMinProductSold,
       plmax.range
  FROM (SELECT * FROM CTE_BestProducts_country WHERE RankMax=1) plmax
  JOIN (SELECT * FROM CTE_BestProducts_country WHERE RankMin=1) plmin
    ON plmax.country = plmin.country
 ORDER BY plmax.country, plmax.MaxProductSold DESC
```
<h6>Answer:</h6>
<img width="672" alt="o)" src="https://github.com/dayannefuentes/Portfolio-Projects/assets/167659572/d26e6b77-9c6c-47ac-b530-955e1f0de331">
<p> Knowing the most and least sold products could help in inventory management, prioritizing by country those products with higher demand and reducing overstock for those that are not. In addition, depending on the most popular products, marketing strategies could be oriented to increase sales, and the least popular products could be used to boost sales and, depending on consumer behavior, the least sold products could be used as a complement to the best sellers. </p>


