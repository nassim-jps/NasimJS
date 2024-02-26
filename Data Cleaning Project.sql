/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
select saleDateConverted,CONVERT(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

-- If it doesn't Update properly

alter table NashvilleHousing
ADD saleDateConverted  Date

update NashvilleHousing
set SaleDateConverted = CONVERT(Date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
select * from PortfolioProject.dbo.NashvilleHousing
order by ParcelID


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress ,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join  PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.uniqueID
where a.propertyAddress is null 


update a 
SET propertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join  PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.uniqueID
where a.propertyAddress is null 


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State
Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From PortfolioProject.dbo.NashvilleHousing





Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject.dbo.NashvilleHousing





--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant),count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
		Case when SoldAsVacant='Y' THEN 'YES'
		when SoldAsVacant='N' THEN 'NO'
		ELSE SoldAsVacant
		END
From PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant=Case when SoldAsVacant='Y' THEN 'YES'
		when SoldAsVacant='N' THEN 'NO'
		ELSE SoldAsVacant
		END
From PortfolioProject.dbo.NashvilleHousing


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
With RowNumCTE AS(
select *,ROW_NUMBER() OVER (

	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by 
					uniqueID
					)row_num

From PortfolioProject.dbo.NashvilleHousing
)
--DELETE
--From RowNumCTE
--Where row_num > 1

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
From PortfolioProject.dbo.NashvilleHousing

alter table  PortfolioProject.dbo.NashvilleHousing
DROP column OwnerAddress,TaxDistrict,PropertyAddress

alter table  PortfolioProject.dbo.NashvilleHousing
DROP column SaleDate