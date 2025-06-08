/*

Cleaning Nashville Housing's Data in SQL Queries

*/


SELECT *
FROM PortfolioProject..NashvilleHousing$

-----------------------------------------------------------------------------------------------------------------

-- Standardizing Date Format


SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM PortfolioProject..NashvilleHousing$

UPDATE PortfolioProject..NashvilleHousing$
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE PortfolioProject..NashvilleHousing$
ADD SaleDateConverted DATE;

UPDATE PortfolioProject..NashvilleHousing$
SET SaleDateConverted = CONVERT(DATE,SaleDate)

SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM PortfolioProject..NashvilleHousing$


-----------------------------------------------------------------------------------------------------------------

-- Populating Property Adress Data

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing$
WHERE PropertyAddress IS NULL

-- We check by ParcelID. If we know a parcel ID has an address associated, we can populate the missing data with that

SELECT *
FROM PortfolioProject..NashvilleHousing$
ORDER BY ParcelID

-- We will do a self JOIN

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing$ a
JOIN PortfolioProject..NashvilleHousing$ b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- We update the row now:

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing$ a
JOIN PortfolioProject..NashvilleHousing$ b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- If we check we now have no NULL values on the Property Address

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing$ 
--WHERE PropertyAddress IS NULL


-----------------------------------------------------------------------------------------------------------------

-- Breaking out Adress into Individual Coluns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing$ 

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address -- -1 gets rid of the comma on the result
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City

FROM PortfolioProject..NashvilleHousing$ 

-- Adding new tables for the splitted parts of the Property Address

ALTER TABLE PortfolioProject..NashvilleHousing$
ADD PropertySplitAddress NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject..NashvilleHousing$
ADD PropertySplitCity NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- We check the columns added

SELECT *
FROM PortfolioProject..NashvilleHousing$ 

-- We check for the Owner Adress now that has the same format.

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing$ 

-- We use the parse method

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
, PARSENAME(REPLACE(OwnerAddress,',','.'),2)
, PARSENAME(REPLACE(OwnerAddress,',','.'),1)

FROM PortfolioProject..NashvilleHousing$ 

-- Adding new tables for the splitted parts of the Property Address

ALTER TABLE PortfolioProject..NashvilleHousing$
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject..NashvilleHousing$
ADD OwnerSplitCity NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject..NashvilleHousing$
ADD OwnerSplitState NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- We check the columns added

SELECT *
FROM PortfolioProject..NashvilleHousing$ 



-----------------------------------------------------------------------------------------------------------------

-- Changing Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing$ 
GROUP BY SoldAsVacant
ORDER BY 2

-- Changing the values now

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject..NashvilleHousing$ 

-- Updateing the columns

UPDATE PortfolioProject..NashvilleHousing$
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- We check the data:

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing$ 
GROUP BY SoldAsVacant
ORDER BY 2

-----------------------------------------------------------------------------------------------------------------

-- Removing Duplicates USING A CTE

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

FROM PortfolioProject..NashvilleHousing$ 
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-- We now can delete de duplicates:

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

FROM PortfolioProject..NashvilleHousing$ 
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

-- We can check with the previous querie that there aro no more duplicates

-----------------------------------------------------------------------------------------------------------------

-- Deleting Unused Columns

SELECT *
FROM PortfolioProject..NashvilleHousing$ 

ALTER TABLE PortfolioProject..NashvilleHousing$ 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------



