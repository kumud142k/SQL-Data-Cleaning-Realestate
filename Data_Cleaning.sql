
------------------------------------------------------------------------------------------------------------
--NASHVILLE HOUSING DATACLEANING USING SQL COMMANDS--
------------------------------------------------------------------------------------------------------------

SELECT 
*
FROM PortfolioProject.dbo.NashvilleHousing;

----------------------------------------------------------------------------------------------------------------
-- Updating saleDate column

Select  SaleDate, CONVERT(date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing;

Alter Table NashvilleHousing
ADD SaledateModified date;

Update NashvilleHousing
Set SaledateModified= Convert(date, SaleDate);

------------------------------------------------------------------------------------------------------------
--Updating the Property address column

select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is Null
;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, Isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is Null;

-- Replacing null values with the property addresses

Update a
Set PropertyAddress= Isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is Null;

------------------------------------------------------------------------------------------------------------------
--Spliting PropertyAddress into address and city 
Select PropertyAddress 
from PortfolioProject.dbo.NashvilleHousing
;

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) Address1,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) Address2
From PortfolioProject.dbo.NashvilleHousing;

-- Updating this in new columns

Alter Table NashvilleHousing
ADD PropertyAddressNew nvarchar(255);

Update NashvilleHousing
Set PropertyAddressNew=SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

Alter Table NashvilleHousing
ADD PropertyCity nvarchar(255);

Update NashvilleHousing
Set PropertyCity =SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));


-------------------------------------------------------------------------------------------------------------
--Splitting OwnerAddress into address, city, country

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing;

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing;

Alter Table NashvilleHousing
ADD OwnerAddressNew nvarchar(255);

Update NashvilleHousing
Set OwnerAddressNew  =PARSENAME(REPLACE(OwnerAddress,',','.'),3);

Alter Table NashvilleHousing
ADD OwnerAddressCity nvarchar(255);

Update NashvilleHousing
Set OwnerAddressCity =PARSENAME(REPLACE(OwnerAddress,',','.'),2);

Alter Table NashvilleHousing
ADD OwnerAddressState nvarchar(255);

Update NashvilleHousing
Set OwnerAddressState  =PARSENAME(REPLACE(OwnerAddress,',','.'),1);

Select *
From PortfolioProject.dbo.NashvilleHousing;

------------------------------------------------------------------------------------------------------------
-- Changing Y and N for Yes and No

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2;

Select SoldAsVacant,
	Case When SoldAsVacant='Y' Then 'Yes'
		 When SoldAsVacant='N' Then 'No'
		 Else SoldAsVacant
		 End
From PortfolioProject.dbo.NashvilleHousing;

Update NashvilleHousing
	Set SoldAsVacant= Case When SoldAsVacant='Y' Then 'Yes'
		 When SoldAsVacant='N' Then 'No'
		 Else SoldAsVacant
		 End

Select Distinct(SoldAsVacant)
, Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2;

------------------------------------------------------------------------------------------------------------
--Remove Duplicates

Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order By UniqueID
				 ) ROW_NUM
	FROM PortfolioProject.dbo.NashvilleHousing;

-- USING CTE 

With rownumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order By UniqueID
				 ) ROW_NUM

	FROM PortfolioProject.dbo.NashvilleHousing
	)
Delete 
From rownumCTE
WHERE ROW_NUM>1;

----------------------------------------------------------------------------------------------------------------
--Delete irrelevant Columns

Alter Table NashvilleHousing
DROP Column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict;

Select * 
From PortfolioProject.dbo.NashvilleHousing