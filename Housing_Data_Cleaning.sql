--SQL Data Cleaning Project

SELECT * 
FROM PortfolioProject..NashvilleHousing;

------------------------------------------------------------------------------

--Standardizing Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing;

UPDATE PortfolioProject..NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate);

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);

------------------------------------------------------------------------------

--Populate Property Address Data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null;
order by ParcelID;



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a 
JOIN PortfolioProject.dbo.NashvilleHousing b 
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a 
JOIN PortfolioProject.dbo.NashvilleHousing b 
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

------------------------------------------------------------------------------

--Breaking out Address into Indivisual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM PortfolioProject.dbo.NashvilleHousing



ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
FROM PortfolioProject..NashvilleHousing;


Select OwnerAddress
FROM PortfolioProject..NashvilleHousing;


Select 
PARSENAME(REPLACE(OwnerAddress,',', '.'),3)
, PARSENAME(REPLACE(OwnerAddress,',', '.'),2)
, PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
from PortfolioProject..NashvilleHousing


------------------------------------------------------------------------------

--Change "Y" & "N" to "Yes" & "No" in the Sold as Vacant field

Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP by SoldAsVacant
order by 2;

SELECT SoldAsVacant,
 CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
FROM PortfolioProject.dbo.NashvilleHousing;

Update PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END;

------------------------------------------------------------------------------

--Remove Duplicates 

WITH ROWNumCTE AS(
SELECT *, 
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY 
					UniqueID
				 ) row_num

FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID;
)
SELECT *
FROM ROWNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

------------------------------------------------------------------------------

--Delete Unused Columns

Select *
FROM PortfolioProject..NashvilleHousing;

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate