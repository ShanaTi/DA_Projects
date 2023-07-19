--Data cleaning with sql 


SELECT * 
FROM Project1..NashvilleHousing

--Standardize date format (remove time)
SELECT SaleDate, CONVERT(Date,SaleDate) 
FROM Project1..NashvilleHousing

--UPDATE NashvilleHousing
--SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE Project1..NashvilleHousing
ADD SaleDateConverted Date;

Update Project1..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted
FROM Project1..NashvilleHousing

-- Populate Property Address data
Select *
From Project1..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

--if parcelid is the same, property address should be the same
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Project1..NashvilleHousing a
JOIN Project1..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Project1..NashvilleHousing a
JOIN Project1..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


--Breaking apart address into individual columns (address, city, state)
SELECT PropertyAddress
FROM Project1..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM Project1..NashvilleHousing

ALTER TABLE Project1..NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

Update Project1..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE Project1..NashvilleHousing
ADD PropertySplitCity nvarchar(255)

Update Project1..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


--breaking apart owner address (address, city, state) using parse
SELECT OwnerAddress
FROM Project1..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2), 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Project1..NashvilleHousing

ALTER TABLE Project1..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

Update Project1..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Project1..NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

Update Project1..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Project1..NashvilleHousing
ADD OwnerSplitState nvarchar(255)

Update Project1..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--change the y & n in "sold as vacant" -> yes and no to keep responses consistent
SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant) 
FROM Project1..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM Project1..NashvilleHousing

UPDATE Project1..NashvilleHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

--remove duplicates
WITH RowNumCTE AS(
SELECT *, 
ROW_NUMBER() OVER (
PARTITION BY	ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

FROM Project1..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--delete unused columns
SELECT * 
FROM Project1..NashvilleHousing

ALTER TABLE Project1..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate