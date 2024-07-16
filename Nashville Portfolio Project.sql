SELECT * 
FROM PortfolioProject..NashvilleHousing

--Removing the Unnecessary Elements in SaleDate

SELECT SaleDate, cast(SaleDate as date) as StandartDate
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SaleDate = cast(SaleDate as date)

ALTER TABLE PortfolioProject..NashvilleHousing
ALTER COLUMN SaleDate date;

ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDateConverted date;

UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted = cast(SaleDate as date)

SELECT SaleDateConverted
FROM PortfolioProject..NashvilleHousing

--Populate Property Address Data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET a.PropertyAddress = b.PropertyAddress
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]

--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT PropertySplitAddress, PropertySplitCity
FROM NashvilleHousing

SELECT *
FROM NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),--PARSENAME only works with periods
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerPropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerPropertySplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerPropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerPropertySplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerPropertySplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerPropertySplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM PortfolioProject..NashvilleHousing

--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant) as Count
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY Count

SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
END as ChangedResults
FROM PortfolioProject..NashvilleHousing
WHERE SoldAsVacant = 'Y' OR SoldAsVacant = 'N'

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = 
	CASE 
		WHEN SoldAsVacant = 'N' THEN 'No'
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		ELSE SoldAsVacant
	END 

--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY ParcelID,
									PropertyAddress,
									SalePrice,
									SaleDate,
									LegalReference
									ORDER BY UniqueID) as row_num
FROM PortfolioProject..NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1

SELECT *,
	ROW_NUMBER() OVER (PARTITION BY ParcelID,
									PropertyAddress,
									SalePrice,
									SaleDate,
									LegalReference
									ORDER BY UniqueID) as row_num
FROM PortfolioProject..NashvilleHousing

--DELETE UNUSED COLUMNS

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate

SELECT *
FROM PortfolioProject..NashvilleHousing