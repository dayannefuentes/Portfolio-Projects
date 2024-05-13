<h1>StoreCars: Customers and Products Analysis</h1>
<img width="500" alt="Coding" src="https://github.com/dayannefuentes/Portfolio-Projects/blob/main/StoreCarsImage.jpg">

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



<img width="500" alt="Coding" src="https://github.com/dayannefuentes/Portfolio-Projects/blob/main/schema%20stores.png">

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
 <img width="500" alt="Coding" src="https://github.com/dayannefuentes/Portfolio-Projects/blob/main/a).png">
 <p>The best-selling product is the 1992 Ferrari 360 Spider red with a total of 1808 sales, followed by 1937 Lincoln Berline with 1111 sales and in third place American Airlines: MD-11S with 1085 products sold. 
  
The product with the lowest product sold was 1957 Ford Thunderbird.
</p>
