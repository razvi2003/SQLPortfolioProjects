
-------------------------- Cleaning data in sql queries
select * from NashvilleHousing

-------------------------- standardize date format

select saledate, CONVERT(date,saledate) from NashvilleHousing

Alter table NashvilleHousing
Add saledateconverted date;

Update NashvilleHousing
set saledateconverted = CONVERT(date,saledate)

select saledate, saledateconverted from NashvilleHousing

-- populate property address data
select PropertyAddress from NashvilleHousing
where PropertyAddress is null


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set propertyaddress = ISNULL(a.propertyaddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]

-------------------------- Breaking address into columns
select PropertyAddress, SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))
from NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Alter table NashvilleHousing
Add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

--Another of splitting columns using PARSE
select owneraddress, PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from NashvilleHousing

select propertyaddress, PARSENAME(REPLACE(propertyaddress,',','.'),1),
PARSENAME(REPLACE(propertyaddress,',','.'),2)
from NashvilleHousing

-------------------------- Add split owner address as new columns
Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter table NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-------------------------- Change Y and N to Yes and No in 'Sold as Vacant' Field

select distinct(SoldAsVacant), count(SoldAsVacant) from NashvilleHousing
group by SoldAsVacant

select SoldAsVacant, 
Case when SoldAsVacant='Y' then 'Yes'
     when SoldAsVacant='N' then 'No'
	 Else SoldAsVacant
End
from NashvilleHousing

--Now lets do and update
Update NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant='Y' then 'Yes'
     when SoldAsVacant='N' then 'No'
	 Else SoldAsVacant
End

--------------------------  Remove Duplicates
With RowNumCTE As(
select *,
ROW_NUMBER () Over(Partition by
	ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference order by UniqueID) as ROWNUM
from NashvilleHousing 
)
Delete from RowNumCTE where ROWNUM > 1

--------------------------  Drop Unused Column

Alter table NashvilleHousing
Drop column 