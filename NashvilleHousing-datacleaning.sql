/*
Cleaning Data in SQL Queries
*/


Select *
From project.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select SaleDateConverted, CONVERT(Date,SaleDate)
From project.dbo.NashvilleHousing


Update project.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE project.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update project.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From project.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From project.dbo.NashvilleHousing a
JOIN project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From project.dbo.NashvilleHousing a
JOIN project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From project.dbo.NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) AS address,
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress)) AS city
From project.dbo.NashvilleHousing 

ALTER TABLE project.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update project.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE project.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update project.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

select *
FROM project.dbo.NashvilleHousing




Select OwnerAddress
From project.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From project.dbo.NashvilleHousing



ALTER TABLE project.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update project.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE project.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update project.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE project.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update project.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From project.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From project.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From project.dbo.NashvilleHousing


Update project.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
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

From project.dbo.NashvilleHousing
--order by ParcelID
)
SELECT *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From project.dbo.NashvilleHousing


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From project.dbo.NashvilleHousing


ALTER TABLE project.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
