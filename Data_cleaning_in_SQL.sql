Select *
from Portfolio_Projects.dbo.NashvilleHousing

-- Standardize date format

Alter table NashvilleHousing
ADD SalesDateConverted Date

UPDATE NashvilleHousing
SET SalesDateConverted = CONVERT(date, SaleDate)

-- Populate Property Address Data

Select *
from Portfolio_Projects.dbo.NashvilleHousing
--WHERE PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Projects.dbo.NashvilleHousing a
JOIN Portfolio_Projects.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
	from Portfolio_Projects.dbo.NashvilleHousing a
	JOIN Portfolio_Projects.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Breaking out Address in separate Columns

Select PropertyAddress
from Portfolio_Projects.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as City
FROM Portfolio_Projects.dbo.NashvilleHousing

Alter table NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1)

Alter table NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))

Select OwnerAddress
from Portfolio_Projects.dbo.NashvilleHousing

SELECT
PARSENAME(Replace(OwnerAddress,',','.'),3)
, PARSENAME(Replace(OwnerAddress,',','.'),2)
, PARSENAME(Replace(OwnerAddress,',','.'),1)
from Portfolio_Projects.dbo.NashvilleHousing


Alter table NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter table NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter table NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

Select *
from Portfolio_Projects.dbo.NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" Column

Select distinct(SoldAsVacant)
from Portfolio_Projects.dbo.NashvilleHousing

Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' Then 'Yes'
		WHEN SoldAsVacant = 'N' Then 'No'
		ELSE SoldAsVacant
		END
from Portfolio_Projects.dbo.NashvilleHousing
Group by SoldAsVacant

Update Portfolio_Projects.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' Then 'Yes'
		WHEN SoldAsVacant = 'N' Then 'No'
		ELSE SoldAsVacant
		END

-- Remove duplicates


With RowNumCTE as(
Select *,
	ROW_number()	OVER(
	Partition by ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				ORDER BY UniqueID
				) as row_num					
From Portfolio_Projects.dbo.NashvilleHousing
)

Select *
From RowNumCTE
where row_num > 1

-- Delete unused columns

Select *
from Portfolio_Projects.dbo.NashvilleHousing

Alter table Portfolio_Projects.dbo.NashvilleHousing
DROP column OwnerAddress, TaxDistrict, PropertyAddress

