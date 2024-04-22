/*

DATA CLEANING IN SQL QUERIES

*/

select * from PortfolioProject..NashvilleHousing

-----------------------------------------------------------------------------------------------------------------
--Standardize date format

select SaleDate, convert(date,SaleDate)  
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing -------this did not work
set SaleDate=convert(date,SaleDate)

alter table NashvilleHousing   -- adding new colunm
add SaleDateConverted date;

update PortfolioProject..NashvilleHousing  -- now updating the new column
set SaleDateConverted =convert(date,SaleDate)

select SaleDateConverted from NashvilleHousing

-----------------------------------------------------------------------------------------------------------------

-- Populate property address data

select * 
from PortfolioProject..NashvilleHousing
where PropertyAddress is null

---- if two PracelID are same it means the property address of those 2 parcelids will be same
---this way we are going to populate the property adress

select ParcelID, propertyAddress from PortfolioProject..NashvilleHousing
order by ParcelID

select a.ParcelID, a.PropertyAddress,a.[UniqueID ] ,b.[UniqueID ],b.ParcelID,b.PropertyAddress
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]

select a.ParcelID, a.PropertyAddress,a.[UniqueID ] ,b.[UniqueID ],b.ParcelID,b.PropertyAddress
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]


select a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null



update a      ----while using update with joins donot put the actual table name instead put alias
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


select PropertyAddress from   ----------to check wheter the data is populated or not
PortfolioProject..NashvilleHousing
where PropertyAddress is null


-------------------------------------------------------------------------------------------------------------------
--- Breaking the PROPERTY ADDRESS into individual coloums (address,city,state)

select PropertyAddress from   
PortfolioProject..NashvilleHousing


select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

--- the problem in the above is that we are getting the delimiter ie "," after tbhe addresss
-- in order to remove the comma


select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
from PortfolioProject..NashvilleHousing

---here we dont want to start with the pos 1 instead we want to start from where the comma ends

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as state
from PortfolioProject..NashvilleHousing      --as after "," different rows have diff vales ,so we used LEN()

-- we cannot seperate two values from the same column. So for doing so we must need to cretae two seperaten columns


alter table PortfolioProject..NashvilleHousing   -- adding new colunm
add PropertySplitAddress nvarchar(255);

update PortfolioProject..NashvilleHousing  -- now updating the new column
set PropertySplitAddress =SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table PortfolioProject..NashvilleHousing   -- adding new colunm
add PropertySplitState nvarchar(255);

update PortfolioProject..NashvilleHousing  -- now updating the new column
set  PropertySplitState =SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

select PropertySplitAddress, PropertySplitState from PortfolioProject..NashvilleHousing


-------------------------------------------------------------------------------------------------------------------
  

  --- Breaking the OWNER ADDRESS into individual coloums (address,city,state)


  SELECT OwnerAddress from PortfolioProject..NashvilleHousing

  select PARSENAME(replace(OwnerAddress,',','.'),1)     --parsenames are useful with periods(.) and these are commas. so by using REPLACE func we cahnge the comma to period
  from PortfolioProject..NashvilleHousing               ---- parsename detects the period from backwards


  
  select PARSENAME(replace(OwnerAddress,',','.'),3) as OwnerSplitAddress,
  PARSENAME(replace(OwnerAddress,',','.'),2) as OwnerSplitCity,
  PARSENAME(replace(OwnerAddress,',','.'),1) as OwnerSplitState
  from PortfolioProject..NashvilleHousing



  alter table PortfolioProject..NashvilleHousing   -- adding new colunm
add OwnerSplitAddress nvarchar(255);

update PortfolioProject..NashvilleHousing  -- now updating the new column
set OwnerSplitAddress =PARSENAME(replace(OwnerAddress,',','.'),3) 



  alter table PortfolioProject..NashvilleHousing   -- adding new colunm
add OwnerSplitCity nvarchar(255);

update PortfolioProject..NashvilleHousing  -- now updating the new column
set OwnerSplitCity =PARSENAME(replace(OwnerAddress,',','.'),2) 


  alter table PortfolioProject..NashvilleHousing   -- adding new colunm
add OwnerSplitState nvarchar(255);

update PortfolioProject..NashvilleHousing  -- now updating the new column
set OwnerSplitState =PARSENAME(replace(OwnerAddress,',','.'),1) 


select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from PortfolioProject..NashvilleHousing



----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "SOLD AS VACANT" field

select distinct(SoldAsVacant),count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case 
	when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
end		
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SoldAsVacant = case 
	when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
end		


------------------------------------------------------------------------------------------------------------------------------------

---- remove duplications
/*
The ROW_NUMBER() function in MySQL is used to returns the sequential number for each row
within its partition. It is a kind of window function. The row number starts from 1 to the
number of rows present in the partition.
*/
with RowNumCTE as(
select *, 
	ROW_NUMBER() OVER(
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by 
				UniqueID
				) row_num
from PortfolioProject..NashvilleHousing
)
select * from             --- i used delete here to delet the duplicate and after that in order to recheck i used select statement
RowNumCTE
where row_num>1
--order by PropertyAddress




-----------------------------------------------------------------------------------------------------------------------------

--- delete unused columns

select * from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress,PropertyAddress, TaxDistrict

alter table PortfolioProject..NashvilleHousing
drop column
SaleDate


