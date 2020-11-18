### SQL questions - regression ###




### 4)	Select all the data from table house_price_data to check if the data was imported correctly

SELECT * FROM house_price_data;

# ps: I've imported the date data without changing the type to date as this created conflicts and destroyed the literacy of the data. Will look into reworking the date data in case it was needed in the case. Else we can just skip.
;


### 5) Use the alter table command to drop the column date from the database, as we would not use it in the analysis with SQL. Select all the data from the table to verify if the command worked. Limit your returned results to 10.

ALTER TABLE house_price_data
DROP COLUMN DATE;

SELECT *
FROM house_price_data
LIMIT 10;



### 6) Use sql query to find how many rows of data you have.

SELECT count(*) as num_row FROM house_price_data;



### 7) Now we will try to find the unique values in some of the categorical columns:

# What are the unique values in the column bedrooms?
select distinct bedrooms from house_price_data
order by bedrooms asc;

# What are the unique values in the column bathrooms?
select distinct bathrooms from house_price_data
order by bathrooms asc;

# What are the unique values in the column floors?
select distinct floors from house_price_data
order by floors asc;

# What are the unique values in the column condition?
select distinct hp.condition from house_price_data hp
order by hp.condition asc;

# What are the unique values in the column grade?
select distinct grade from house_price_data
order by grade asc;



### 8) Arrange the data in a decreasing order by the price of the house. Return only the IDs of the top 10 most expensive houses in your data.
select hp.id
from house_price_data hp
order by price DESC
limit 10;



### 9) What is the average price of all the properties in your data?
select round(avg(price),0) as 'average_price' from house_price_data;



### 10) In this exercise we will use simple group by to check the properties of some of the categorical variables in our data

# What is the average price of the houses grouped by bedrooms? The returned result should have only two columns, bedrooms and Average of the prices. Use an alias to change the name of the second column.
select bedrooms, round(avg(price),0) as 'average_price' from house_price_data group by bedrooms order by bedrooms asc;

# What is the average sqft_living of the houses grouped by bedrooms? The returned result should have only two columns, bedrooms and Average of the sqft_living. Use an alias to change the name of the second column.
select bedrooms, round(avg(sqft_living),0) as 'average_sqft_living' from house_price_data group by bedrooms order by bedrooms asc;

# What is the average price of the houses with a waterfront and without a waterfront? The returned result should have only two columns, waterfront and Average of the prices. Use an alias to change the name of the second column.
select waterfront, round(avg(price),0) as 'average_price' from house_price_data group by waterfront order by waterfront asc;

# Is there any correlation between the columns condition and grade? You can analyse this by grouping the data by one of the variables and then aggregating the results of the other column. Visually check if there is a positive correlation or negative correlation or no correlation between the variables.
select hp.condition, round(avg(grade),0) as 'average_grade' from house_price_data hp group by hp.condition order by hp.condition desc;
select hp.condition, count(hp.condition) from house_price_data hp group by hp.condition order by hp.condition desc; 
#we notice there is not a correlation between the condition of the house and the grade provided. This is based on focusing on the conditions 5,4,3 as those have a big enough population to make a deduction from.



### 11) One of the customers is only interested in the following houses:

/* Number of bedrooms either 3 or 4
Bathrooms more than 3
One Floor
No waterfront
Condition should be 3 at least
Grade should be 5 at least
Price less than 300000

For the rest of the things, they are not too concerned. Write a simple query to find what are the options available for them?
 */

select *
from house_price_data hp
where
hp.bedrooms in (3,4)
and hp.bathrooms >3
and hp.floors =1
and hp.waterfront = 0
and hp.condition >=3
and hp.grade >=5
and hp.price < 300000
-- order by price asc
;
#there is currently nothing available for them on that buget. they could however get all their criteria for the lowest price of 345,100 USD



### 12) Your manager wants to find out the list of properties whose prices are twice more than the average of all the properties in the database. Write a query to show them the list of such properties. You might need to use a sub query for this problem.
select hp.id, hp.price
from house_price_data hp
having hp.price > (select avg(price)*2 from house_price_data)
order by hp.price asc;



### 13) Since this is something that the senior management is regularly interested in, create a view of the same query.
create or replace view house_price_avg2X as
select hp.id, hp.price
from house_price_data hp
having hp.price > (select avg(price)*2 from house_price_data)
order by hp.price asc;



### 14) Most customers are interested in properties with three or four bedrooms. What is the difference in average prices of the properties with three and four bedrooms?
select row_number() over() AS num_row, round(avg(price),0) from house_price_data where bedrooms = 3;
select round(avg(price),0) from house_price_data where bedrooms = 4;

drop temporary table if exists temp1; 

create temporary table temp1
select row_number() over() AS num_row, round(avg(price),0) as 'avg_price_3bd' from house_price_data where bedrooms = 3;

#select * from temp1;

drop temporary table if exists temp2; 

create temporary table temp2
select row_number() over() AS num_row, round(avg(price),0) as 'avg_price_4bd' from house_price_data where bedrooms = 4;

#select * from temp2;

select t1.avg_price_3bd, t2.avg_price_4bd, (t2.avg_price_4bd - t1.avg_price_3bd) as avg_diff_4vs3bd
from temp1 t1
join temp2 t2 on t2.num_row = t1.num_row
;


/*
# PS: can't group by as mode incompatible with current SQL setup

select bedrooms,
avg(price) OVER (
    PARTITION BY bedrooms
    ORDER BY bedrooms asc
) as "avg_cat_price"
from house_price_data
group by bedrooms
having bedrooms in (3,4);
*/
;


### 15) What are the different locations where properties are available in your database? (distinct zip codes)
select distinct zipcode from house_price_data order by zipcode asc;



### 16) Show the list of all the properties that were renovated.
select * from house_price_data where yr_renovated <> 0;



### 17) Provide the details of the property that is the 11th most expensive property in your database.
with CTE1 as (
select *, rank() over (order by price desc) as "rank_price"
from house_price_data
)

select * from CTE1
where rank_price =11;

