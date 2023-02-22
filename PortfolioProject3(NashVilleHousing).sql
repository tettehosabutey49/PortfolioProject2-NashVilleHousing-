SELECT *
FROM PortfolioProject1..NashvilleHousing


--1. Standardize Date Format
--changing the date format into a standardized form.
SELECT SaleDateConverted, Convert(Date, SaleDate)
FROM PortfolioProject1..NashvilleHousing

UPDATE PortfolioProject1..NashvilleHousing
SET SaleDate = Convert(Date, SaleDate)

ALTER TABLE PortfolioProject1..NashvilleHousing
ADD SaleDateConverted Date;

UPDATE PortfolioProject1..NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)



---2. Popupulate Property Address Data
--NB Part of the property address has null, so we join the same table and populate the other with the property adrress wherever we find null in the other. 
--NB we also want to specify that the uniqueIDs arent the same in both tables
SELECT *
FROM PortfolioProject1..Nashvillehousing
--WHERE PropertyAddress is null
order by ParcelID

SELECT a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, ISNULL(a.propertyaddress, b.propertyaddress)
FROM PortfolioProject1..NashvilleHousing a
JOIN PortfolioProject1..NashvilleHousing b
  ON a.ParcelID = b.ParcelID
    AND a.[uniqueID]<>b.[uniqueID]
WHERE a.propertyaddress is null

UPDATE a
SET a.propertyaddress = ISNULL(a.propertyaddress, b.propertyaddress)
FROM PortfolioProject1..NashvilleHousing a
JOIN PortfolioProject1..NashvilleHousing b
  ON a.ParcelID = b.ParcelID
    AND a.[uniqueID]<>b.[uniqueID]
WHERE a.propertyaddress is null

----AFter making these changes, we notice after running the initial code before the change, 
--there is no null anymore, hence the changes have occurred.
--NB Update only takes the aliase

---3. Breaking out Address into individual columns(Address, City, State)
--NB we use use the comma as our reference point to divide the address into address and city.
--Charindex helps us with the positions to begin our extraction and the end
--Then we seperate them as new columns and add to out table to make computations easier

SELECT 

SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

FROM PortfolioProject1..Nashvillehousing

ALTER TABLE PortfolioProject1..NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE PortfolioProject1..NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE PortfolioProject1..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 


Select *
from nashvillehousing

---using parsename
--nb parsename makes use of fullstops. so we'd have to convert our comma to fullstop to use it
--nb alter all tables before updating them
--now by splitting it, it can be used for more computations easily
Select
PARSENAME(REPLACE(owneraddress, ',','.'), 3),
PARSENAME(REPLACE(owneraddress, ',','.'), 2),
PARSENAME(REPLACE(owneraddress, ',','.'), 1)
from Portfolioproject1..nashvillehousing

ALTER TABLE PortfolioProject1..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

ALTER TABLE PortfolioProject1..NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

ALTER TABLE PortfolioProject1..NashvilleHousing
ADD OwnerSplitState nvarchar(255);


UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(owneraddress, ',','.'), 3)



UPDATE PortfolioProject1..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(owneraddress, ',','.'), 2)


UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(owneraddress, ',','.'), 1)

Select *
From PortfolioProject1..Nashvillehousing



--4. Change Y and N to Yes and No in "Sold as Vacant" field
Select distinct soldasvacant ,
count(soldasvacant)
from PortfolioProject1..Nashvillehousing
group by Soldasvacant

SELECT soldasvacant,
Case
when soldasvacant = 'N' then 'No'
when soldasvacant = 'Y' then 'Yes'
else soldasvacant
end
From PortfolioProject1..Nashvillehousing

Update Nashvillehousing
SET soldasvacant = Case
when soldasvacant = 'N' then 'No'
when soldasvacant = 'Y' then 'Yes'
else soldasvacant
end


--5. Remove Duplicates
--by using CTE we can easily store what we need temporarily and find repeated rows
--also by using the CTE, because we need to delete rows, we could easily delete them from our temporary storage to 
--avoid mistakenly deleting useful data from our original table.
--After obtaining the data here, we can now delete
WITH RowNumCTE AS(
Select * ,
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
               PropertyAddress,
			   SalePrice,
			   LegalReference
			   ORDER BY UniqueID
			   ) row_num
FROM PortfolioProject1..nashvillehousing
--order by parcelID
)
select *
FROM RowNumCTE
where row_num > 1
order by propertyaddress




--6. Delete Unused Columns
SELECT *
FROM PortfolioProject1..nashvillehousing

ALTER TABLE PortfolioProject1..nashvillehousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE PortfolioProject1..nashvillehousing
DROP COLUMN SaleDate

                   
 