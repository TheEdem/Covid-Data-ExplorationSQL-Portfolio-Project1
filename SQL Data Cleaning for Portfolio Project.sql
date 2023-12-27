/*

Cleaning Data with SQL Queries

*/


Select *
From PortfolioProject1.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------


-- Populate Property Address data

Select *
From PortfolioProject1.dbo.NashvilleHousing
order by ParcelID

-- Use ISNULL and Self Join to populate missing address fields

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject1.dbo.NashvilleHousing a
JOIN PortfolioProject1.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--Update table

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject1.dbo.NashvilleHousing a
JOIN PortfolioProject1.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Run a check 

Select *
From PortfolioProject1.dbo.NashvilleHousing
where PropertyAddress is null
order by ParcelID


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortfolioProject1.dbo.NashvilleHousing

--Using SUBSTRING & CHARINDEX to split street address and city

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From PortfolioProject1.dbo.NashvilleHousing

--Update table

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
Add PropertyAddressSplit Nvarchar(255);

Update PortfolioProject1.dbo.NashvilleHousing
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
Add PropertyCity Nvarchar(255);

Update PortfolioProject1.dbo.NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



-- Check 

Select *
From PortfolioProject1.dbo.NashvilleHousing

 

--Split owner address



Select OwnerAddress
From PortfolioProject1.dbo.NashvilleHousing

--Use PARSENAME to seperate street, city and state into different columns
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject1.dbo.NashvilleHousing

--Update table with new columns

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
Add OwnerAddressSplit Nvarchar(255);

Update PortfolioProject1.dbo.NashvilleHousing
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
Add OwnerAddressCity Nvarchar(255);

Update PortfolioProject1.dbo.NashvilleHousing
SET OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
Add OwnerAddressState Nvarchar(255);

Update PortfolioProject1.dbo.NashvilleHousing
SET OwnerAddressState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject1.dbo.NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select saleDate, CONVERT(Date,SaleDate)
From PortfolioProject1.dbo.NashvilleHousing


Update PortfolioProject1.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- Or Alter table manually

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
Add StandardSaleDate Date;

Update PortfolioProject1.dbo.NashvilleHousing
SET StandardSaleDate = CONVERT(Date,SaleDate)



 --------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

--First take a look at content of "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject1.dbo.NashvilleHousing
Group by SoldAsVacant


--Case staement

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject1.dbo.NashvilleHousing

--Update table

Update PortfolioProject1.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
-- Use ROWNUMBER and PARTITION in a CTE to find duplicates and then DELETE
WITH NewRowNumCTE AS(
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

From PortfolioProject1.dbo.NashvilleHousing
)
Delete *
From NewRowNumCTE
Where row_num > 1


--Check

Select *
From PortfolioProject1.dbo.NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
--Columns that we split and are now surplus


Select *
From PortfolioProject1.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate
