--cleaning data in sql 
select *
from project.dbo.Nashville_housing

--standardize date format
select cast(SaleDate as date) 
from project.dbo.Nashville_housing

update project.dbo.Nashville_housing
set SaleDate=cast(SaleDate as date) 


--populate property address date
select *
from project.dbo.Nashville_housing
where PropertyAddress is null

select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from project.dbo.Nashville_housing a
join project.dbo.Nashville_housing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from project.dbo.Nashville_housing a
join project.dbo.Nashville_housing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out address into individual columns
select PropertyAddress
from project.dbo.Nashville_housing
where PropertyAddress is null

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Adress,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as Address
from project.dbo.Nashville_housing

alter table project.dbo.Nashville_housing
add addresssplit varchar(200)

update project.dbo.Nashville_housing
set addresssplit=SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

alter table  project.dbo.Nashville_housing
add addresssplitcity varchar(200)

update  project.dbo.Nashville_housing
set addresssplitcity=SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))

select *
from project.dbo.Nashville_housing

select OwnerAddress
from project.dbo.Nashville_housing

select
parsename(replace(OwnerAddress, ',','.'),3),
parsename(replace(OwnerAddress, ',','.'),2),
parsename(replace(OwnerAddress, ',','.'),1)
from project.dbo.Nashville_housing

alter table project.dbo.Nashville_housing
add ownersplitaddress varchar(100)

update project.dbo.Nashville_housing
set ownersplitaddress=parsename(replace(OwnerAddress, ',','.'),3)

alter table project.dbo.Nashville_housing
add ownersplitcity varchar(100)

update project.dbo.Nashville_housing
set ownersplitcity=parsename(replace(OwnerAddress, ',','.'),2)

alter table project.dbo.Nashville_housing
add ownersplitstate varchar(100)

update project.dbo.Nashville_housing
set ownersplitstate=parsename(replace(OwnerAddress, ',','.'),1)

select *
from project.dbo.Nashville_housing

--convert Y and N to Yes or No in soldasvacant field

select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from project.dbo.Nashville_housing
group by SoldAsVacant

select SoldAsVacant,
case
	when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end
from project.dbo.Nashville_housing

update project.dbo.Nashville_housing
set SoldAsVacant=case
	when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end
from project.dbo.Nashville_housing

select distinct(SoldAsVacant)
from project.dbo.Nashville_housing

--delete duplicates

with rowcte as(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From project.dbo.Nashville_housing
)
select *
from rowcte
where row_num>1
order by PropertyAddress


select *
from project.dbo.Nashville_housing

--delete unused columns

alter table project.dbo.Nashville_housing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

select *
from project.dbo.Nashville_housing