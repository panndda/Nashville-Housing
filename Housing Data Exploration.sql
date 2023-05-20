--EXPLORATORY ANALYSIS
--number of distinct cities where the poperties are located. (14)
select distinct(property_split_city),count(*) number_of_properties 
from nash
group by 1
order by 2 desc;


--property types and their population
select land_use,count(*) as population
from nash
group by land_use
order by 2 desc


--Properties sold as vacant
select sold_as_vacant, count(*)
from nash
group by 1

--Total Properties sold by year
select sale_year,count(*)
from nash
group by sale_year
order by 2

--number of properties in each neighborhood 
select property_split_street, count(*)
from nash
group by 1
order by 2 desc


--Average housing price in neighborhoods /streets
select property_split_street,round(avg(sale_price),2) as average_price
from nash
group by property_split_street
order by 2 desc


--Distribution of housing prices across different property types 
select land_use,round(avg(sale_price),2) as average_price
from nash
group by land_use
order by 2 desc


--Average acreage of properties in neighborhoods /streets
select property_split_street,round(avg(cast(acreage as numeric)),2) as average_acreage
from nash
group by property_split_street
having avg(cast(acreage as numeric)) is not null
order by 2  desc

--Correlation between the sale price of property and the year it was built(0.037)
select corr(sale_price,year_built)
from nash
where sale_price is not null and year_built is not null


--Correlation between the sale price of property and the number of bedrooms (0.37)
select corr(sale_price,bedrooms)
from nash
where sale_price is not null and bedrooms is not null


-- Distribution of housing prices across different property types over time
select sale_year,land_use,round(avg(sale_price),2) as average_price
from nash
group by land_use,sale_year
order by land_use,sale_year


--Neighborhoods with the highest increase in housing prices over the years
-- with uni_on as (
-- with a as (
-- Select property_split_street,min(sale_year)as sale_year
-- from nash
-- group by 1
-- 	),

-- b as (
-- Select property_split_street,max(sale_year)as sale_year
-- from nash
-- group by 1
-- 	)
-- 	select a.property_split_street, a.sale_year
-- 	from a
-- 	union
-- 	select b.property_split_street, b.sale_year
--  	from b
-- 	)
-- select uni.property_split_street, uni.sale_year, round(avg(na.sale_price),2)as avg_sale,
-- 		lag(round(avg(sale_price),2)) over(partition by uni.property_split_street order by uni.sale_year) as last_year,
-- 		(round(avg(na.sale_price),2)-lag(round(avg(sale_price),2)) over(partition by uni.property_split_street order by uni.sale_year )
-- 		)/lag(round(avg(sale_price),2)) over(partition by uni.property_split_street order by uni.sale_year)		as percent_change
-- from uni_on as uni
-- join nash as na
--  	on uni.property_split_street =na.property_split_street and uni.sale_year=na.sale_year
-- 	group by 1,2
--  	order by 5 desc




	
--Alternative
--Neighborhoods with the highest increase in housing prices over the years
with sort as (
select uni.property_split_street, uni.sale_year, round(avg(na.sale_price),2)as avg_sale,
		lag(uni.sale_year) over(partition by uni.property_split_street order by uni.sale_year) as base_year,
		lag(round(avg(sale_price),2)) over(partition by uni.property_split_street order by uni.sale_year) as base_price,
		((round(avg(na.sale_price),2)-lag(round(avg(sale_price),2)) over(partition by uni.property_split_street order by uni.sale_year )
		)/lag(round(avg(sale_price),2)) over(partition by uni.property_split_street order by uni.sale_year))*100		as percent_change
from (select a.property_split_street, a.sale_year
		from (Select property_split_street,min(sale_year)as sale_year
				from nash
				group by 1) as a
				union
		select b.property_split_street, b.sale_year
 		from (Select property_split_street,max(sale_year)as sale_year
				from nash
				group by 1) as b) as uni
join nash as na
 	on uni.property_split_street =na.property_split_street and uni.sale_year=na.sale_year
	group by 1,2
 	order by 5 desc
)
select property_split_street, sale_year,avg_sale,base_year,base_price, round(percent_change,2)as percent_change
from sort
where percent_change is not null
order by  6 desc

