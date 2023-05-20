--Data Cleaning of Dataset
--Glance at the dataset
select *
from nash
limit 100;

--Create a new date format
select sale_date, sale_date::date as sale_date_new, cast(sale_date as date)
from nash;

--ADD the new date as a column in the nash table
AlTER TABLE nash
add sale_date_new date;

update nash
set sale_date_new=sale_date::date

--drop the former sale_date column
alter table nash
drop sale_date;

--rename sale_date_new column to sale_date
alter table NASH
rename column sale_date_new to sale_date

--extract year from the date
select *, sale_date, date_part('year',sale_date) as year
from nash

--ADD the new date as a column in the nash table
AlTER TABLE nash
add sale_year real;

update nash
set sale_year=date_part('year',sale_date)


--populate missing property address
select *
from nash
where property_address is null
order by parcel_id;


		--new column to carry property_address
		alter table nash
		add property_address_new varchar(255)

		--Using a cte table and windows function to populate a new COLUMN that fill out the null values in property address
		with address as (
				select unique_id, parcel_id, property_address,	
				first_value(property_address)over(partition by parcel_id order by property_address ) as fill_null_address
				from nash
			)
			
			--select *
			--from address

			--update the nashville table
			update nash
			set property_address_new= address.fill_null_address
										from address
										where nash.unique_id=address.unique_id
										
										
--split the address into city and address
select substring(property_address,1,position(',' in property_address)-1), 
		substring(property_address, position(',' in property_address)+2, length(property_address) )
from nash

--add the address to the dataset
alter table nash
add property_split_address varchar(255);

update nash
set property_split_address=substring(property_address_new,1,position(',' in property_address_new)-1)


--add the property city to the table
alter table nash
add property_split_city varchar(255);

update nash
set property_split_city=substring(property_address_new, position(',' in property_address_new)+2, length(property_address_new))



--Split property address to get streets
select concat(trim(substring(property_split_address, position(' ' in property_split_address)+2, length(property_split_address))),', ',property_split_city)
from nash


alter table nash
add property_split_street varchar(255);


update nash
set property_split_street= concat(trim(substring(property_split_address, position(' ' in property_split_address)+2, length(property_split_address))),', ',property_split_city)


--split the owner address coulmn
select split_part(owner_address,', ',1), split_part(owner_address,', ',2), split_part(owner_address,', ',3)
from nash

--update the nashville table with owner address, city and state
alter table nash
add owner_split_address varchar(255);

update nash
set owner_split_address=split_part(owner_address,', ',1)

--owner city
alter table nash
add owner_split_city varchar(255);

update nash
set owner_split_city= split_part(owner_address,', ',2)

--owner state
alter table nash
add owner_split_state varchar(255);

update nash
set owner_split_state= split_part(owner_address,', ',3)


--cross check
select *
from nash
limit 100


--Normalize the variables in the Sold_as_vacant coulmn
select case when Sold_as_vacant='Y' then 'Yes'
			when sold_as_vacant='N' THEN 'No'
			else Sold_as_vacant
			end
from nash

UPDATE NASH
set sold_as_vacant= case when Sold_as_vacant='Y' then 'Yes'
			when sold_as_vacant='N' THEN 'No'
			else Sold_as_vacant
			end
			
--Normalize the land_use column
select case when land_use='RESIDENTIAL COMBO/MISC' then 'RESIDENTIAL CONDO'
			when land_use='VACANT RESIENTIAL LAND' THEN 'VACANT RESIDENTIAL LAND'
			when land_use='VACANT RES LAND' THEN 'VACANT RESIDENTIAL LAND'
			else land_use
			end
from nash

UPDATE NASH
set land_use= case when land_use='RESIDENTIAL COMBO/MISC' then 'RESIDENTIAL CONDO'
			when land_use='VACANT RESIENTIAL LAND' THEN 'VACANT RESIDENTIAL LAND'
			when land_use='VACANT RES LAND' THEN 'VACANT RESIDENTIAL LAND'
			else land_use
			end
			
			
--Treat the duplicates (row with 2 as their row_num are duplicates)
select *, row_number() over(partition by parcel_id, property_address, 
							sale_price,sale_date,legal_reference order by unique_id) as row_num
from nash
			
			
--Delete duplicates
with row as(
			select unique_id 
			from (select *, row_number() over(partition by parcel_id, property_address, 
							sale_price,sale_date,legal_reference order by unique_id) as row_num
					from nash) as rows
			where row_num > 1
			)
	
DELETE FROM nash
where unique_id in (select unique_id from row)


--Non duplicate rows (56,373)
select *
from nash


--Drop unused columns
alter table nash
drop column owner_address, drop column property_address, drop column tax_district;

