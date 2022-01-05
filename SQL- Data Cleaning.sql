-- Data Cleaning with SQL

-- 1. Check to see if all Columns have the correct Data Type
SELECT 
COLUMN_NAME, 
DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'NashvilleHousing' 

-- 2.  Standardise Date Format
ALTER TABLE Projects.dbo.NashvilleHousing
ALTER COLUMN SaleDate Date;
-- This converts the SaleDate column from Datetime format to Date format.

-- 3. Populate Property Address Data. Some columns are NULL
SELECT *
FROM Projects.dbo.NashvilleHousing 
ORDER BY ParcelID
-- Doing this shows that ParcelIDs that are the same have the same PropertyAddress. 

-- Now, Popualte NULL PropertyAddress with the Property address when ParcelIDs are the same but UniqueIDs are different
-- Doing this using Self Join(A self join is a regular join, but the table is joined with itself)
SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
From NashvilleHousing A
JOIN NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


UPDATE A
SET PropertyAddress =  ISNULL(A.PropertyAddress, B.PropertyAddress)
From NashvilleHousing A
JOIN NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

-- 4. Breaking out Address into Individual Columns (Address, City, State)

-- PropertyAddress
-- Use SUBSTRING function to do this (The function extracts characters from a string)
SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address , 
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) 
	AS City
FROM NashvilleHousing

--Add two new columns to the table
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

--Populate new columns with the PropertAddress and PropertCity
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


-- Same process for OwnerAddress
SELECT
	SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress) - 1) AS Address , 
    SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 1, LEN(OwnerAddress)) 
	AS City
FROM NashvilleHousing

--Add two new columns to the table
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

--Populate new columns with the OwnerAddress and OwnerCity
UPDATE NashvilleHousing
SET OwnerSplitAddress = SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress) - 1)

UPDATE NashvilleHousing
SET OwnerSplitCity = SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 1, LEN(OwnerAddress))

-- 5. Change Y and N to Yes and No in "SoldAsVacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS Countof 
	From NashvilleHousing
	GROUP BY SoldAsVacant
	ORDER BY Countof 
-- More columns are in YES or NO format so columns in Y or N will be changed to match YES or NO
-- Use CASE statement  
SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
	END 
FROM NashVilleHousing 

-- Update table with changes 
UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
	END 

-- 6. Remove Duplicates
-- Duplicates will be removed based on ParcelID, PropertyAddress, LegalReference and SaleDate
WITH RowNumberCTE AS(
SELECT *,
	row_num = ROW_NUMBER() OVER (
	PARTITION BY
		ParcelID,
		PropertyAddress,
		LegalReference,
		SaleDate
		ORDER BY
		UniqueID
					)

FROM NashvilleHousing
)
DELETE
FROM RowNumberCTE
WHERE row_num > 1 

-- No duplicates 
SELECT *
FROM Projects.dbo.NashvilleHousing

-- 7. Remove Unused columns 
ALTER TABLE Projects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
