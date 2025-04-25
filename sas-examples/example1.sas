/* Step 1: Connecting to a database and creating a library */
libname mydb odbc dsn='your_dsn' user='your_user' password='your_password';

/* Step 2: Retrieving data from a table */
proc sql;
   create table sales_data as
   select
      customer_id,
      product_id,
      sale_date,
      sale_amount,
      quantity_sold
   from mydb.sales
   where sale_date between '01JAN2024'd and '31DEC2024'd;
quit;

/* Step 3: Aggregating sales data */
proc sql;
   create table sales_summary as
   select
      product_id,
      sum(sale_amount) as total_sales,
      sum(quantity_sold) as total_quantity,
      avg(sale_amount) as avg_sale
   from sales_data
   group by product_id
   having sum(sale_amount) > 10000;
quit;

/* Step 4: Joining with another table for product details */
proc sql;
   create table sales_report as
   select
      s.product_id,
      p.product_name,
      s.total_sales,
      s.total_quantity,
      s.avg_sale
   from sales_summary s
   left join mydb.products p
   on s.product_id = p.product_id;
quit;

/* Step 5: Creating a report with calculated fields */
proc sql;
   create table final_report as
   select
      product_id,
      product_name,
      total_sales,
      total_quantity,
      avg_sale,
      total_sales / total_quantity as avg_sale_per_unit,
      case
         when total_sales > 50000 then 'High Performer'
         when total_sales between 20000 and 50000 then 'Medium Performer'
         else 'Low Performer'
      end as performance_category
   from sales_report;
quit;

/* Step 6: Outputting the results to a report */
proc print data=final_report;
   var product_name total_sales total_quantity avg_sale avg_sale_per_unit performance_category;
   title 'Sales Performance Report for 2024';
run;

/* Step 7: Exporting the report to a CSV file */
proc export data=final_report
   outfile='/path/to/sales_report_2024.csv'
   dbms=csv
   replace;
run;
