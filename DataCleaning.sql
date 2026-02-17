/*

Cleanning Data in SQL Queries

*/ 

select *
from PortfolioProject.dbo.Real_Estate_Dataset


/*

Standardize Date Format, Rmovoing Zeros

*/ 

select SaleDateConverted, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.Real_Estate_Dataset

Update PortfolioProject.dbo.Real_Estate_Dataset
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE Real_Estate_Dataset
Add SaleDateConverted Date;

Update PortfolioProject.dbo.Real_Estate_Dataset
SET SaleDateConverted = CONVERT(Date,SaleDate)



/*

POPULATE PROPERTY ADDRESS 
Remove deplicate and null values
<> MEANS NOT EQUAL TO
*/

select *
from PortfolioProject.dbo.Real_Estate_Dataset
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.parcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) as UpdatedPropertyAddress
from PortfolioProject.dbo.Real_Estate_Dataset a
JOIN PortfolioProject.dbo.Real_Estate_Dataset b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
SET propertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.Real_Estate_Dataset a
JOIN PortfolioProject.dbo.Real_Estate_Dataset b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



/*

Breaking out Address into an Individual Columns (Address, City, State)

*/



select PropertyAddress
from PortfolioProject.dbo.Real_Estate_Dataset
--where PropertyAddress is null
--order by ParcelID

--here we are using the charindex function to find the position 
--of the comma in the PropertyAddress column and then using 
--the substring function to extract the portion of 
--the address before the comma as the Address column.

select
SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) as Address
,	-- here we are using the charindex function to find the position 
 SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address 
from PortfolioProject.dbo.Real_Estate_Dataset


--here we are using the charindex function to find the position
--and make a new column for the address and city. We are using the substring 
--function to extract the portion of the address before the comma as 
--the Address column and the portion after the comma as the City column.

ALTER TABLE PortfolioProject.dbo.Real_Estate_Dataset
Add PropertySplitAddress Nvarchar(255);


Update PortfolioProject.dbo.Real_Estate_Dataset
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress) -1)



ALTER TABLE PortfolioProject.dbo.Real_Estate_Dataset
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.Real_Estate_Dataset
SET PropertySplitCity =  SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress) + 1, LEN(PropertyAddress))


select *
from PortfolioProject.dbo.Real_Estate_Dataset


----------------------------------------


select OwnerAddress
from PortfolioProject.dbo.Real_Estate_Dataset


select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
from PortfolioProject.dbo.Real_Estate_Dataset


ALTER TABLE PortfolioProject.dbo.Real_Estate_Dataset
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.Real_Estate_Dataset
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE PortfolioProject.dbo.Real_Estate_Dataset
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.Real_Estate_Dataset
SET OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE PortfolioProject.dbo.Real_Estate_Dataset
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.Real_Estate_Dataset
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


select *
from PortfolioProject.dbo.Real_Estate_Dataset


------------------------------------------------------------

--we want to change Y,N to Yes and No in the SoldAsVacant column

select Distinct(SoldAsVacant),Count(SoldAsVacant)
from PortfolioProject.dbo.Real_Estate_Dataset
Group by SoldAsVacant
order by SoldAsVacant

/*
Y	52
N	399
Yes	4623
No	51403
*/


select SoldAsVacant, 
CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END 
from PortfolioProject.dbo.Real_Estate_Dataset


Update PortfolioProject.dbo.Real_Estate_Dataset
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END

------------------------------------------------------------

--Remove Duplicates from the Dataset
--CTE stands for Common Table Expression, 
--it is a temporary result set that you can reference 
--within a SELECT, INSERT, UPDATE, or DELETE statement.

WITH RowNumCTE AS (
select *,
	ROW_NUMBER() OVER (
	PARTITION BY PARCELID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY UniqueID) RowNum 

from PortfolioProject.dbo.Real_Estate_Dataset
--order by ParcelID
)

-- after we made the duplicates we are going to select only the rows where the RowNum is greater than 1, which means that we are selecting only the duplicate values in a temporary result set called RowNumCTE. We are using the ROW_NUMBER() function to assign a unique number to each row within a partition of the result set, based on the specified columns (ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference). The PARTITION BY clause is used to group the rows based on these columns, and the ORDER BY clause is used to determine the order of the rows within each partition. By selecting only the rows where RowNum is greater than 1, we are effectively filtering out the duplicate rows and keeping only one instance of each unique combination of values in the specified columns.
-- we delete the duplicate values by using the DELETE statement and referencing the RowNumCTE. We are deleting all rows from the RowNumCTE where the RowNum is greater than 1, which means that we are deleting all duplicate rows and keeping only one instance of each unique combination of values in the specified columns. By doing this, we are effectively removing duplicates from the Real_Estate_Dataset table based on the specified columns (ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference).

select * 
from RowNumCTE
Where RowNum > 1
--order by PropertyAddress



SELECT *
from PortfolioProject.dbo.Real_Estate_Dataset
order by ParcelID

------------------------------------------------------------


--Delete Unused Columns data


SELECT *
from PortfolioProject.dbo.Real_Estate_Dataset


ALTER TABLE PortfolioProject.dbo.Real_Estate_Dataset
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.Real_Estate_Dataset
DROP COLUMN SaleDate