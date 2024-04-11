--Cleaning Data in SQl Queries
Select * 
from [Portfolio Project].dbo.NashvilleHousing


--Standardise the Date column

Select SaleDate 
from [Portfolio Project].dbo.NashvilleHousing

Alter Table NashvilleHousing 
Add SaleDateConverted  Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)

Select SaleDateConverted 
From NashvilleHousing


--Populate Property Address Data
Select PropertyAddress 
From [Portfolio Project].dbo.NashvilleHousing
Where PropertyAddress is null;

Select a.ParcelID, a.PropertyAddress ,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project].dbo.NashvilleHousing a
Join [Portfolio Project].dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID 
And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
set PropertyAddress =ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project].dbo.NashvilleHousing a
Join [Portfolio Project].dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID 
And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking Out Address into Individual Colums (Address, City, State)

Select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 ,LEN(PropertyAddress) )
From [Portfolio Project].dbo.NashvilleHousing 

Alter Table NashvilleHousing 
Add PropertyAddressSplit  NVARCHAR(255);

Update NashvilleHousing
Set PropertyAddressSplit = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


Alter Table NashvilleHousing 
Add PropertyCitySplit  NVARCHAR(255);

Update NashvilleHousing
Set PropertyCitySplit = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 ,LEN(PropertyAddress) )


-- OwnerAddress
Select OwnerAddress
From [Portfolio Project].dbo.NashvilleHousing

Select PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From [Portfolio Project].dbo.NashvilleHousing




Alter Table NashvilleHousing 
Add OwnerAddressSplit  NVARCHAR(255);

Update NashvilleHousing
Set OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


Alter Table NashvilleHousing 
Add OwnerCitySplit  NVARCHAR(255);

Update NashvilleHousing
Set OwnerCitySplit = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


Alter Table NashvilleHousing 
Add OwnerStatesSplit  NVARCHAR(255);

Update NashvilleHousing
Set OwnerStateSplit = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



--Change Y and N to Yes and No in SoldAsVacant' Field

Select Distinct(SoldAsVacant),Count(SoldAsVacant)
From [Portfolio Project].dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant, 
CASE WHEN SoldAsVacant ='Y' Then 'Yes'
	WHEN SoldAsVacant ='N' Then 'No'
	ELSE SoldAsVacant
END
From [Portfolio Project].dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant =CASE WHEN SoldAsVacant ='Y' Then 'Yes'
	WHEN SoldAsVacant ='N' Then 'No'
	ELSE SoldAsVacant
END


--Remove Duplicates

With CTE As(
Select *, 
ROW_NUMBER() Over (
PARTITION BY
	ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER By
	UniqueId ) As DuplicateRowNum
From [Portfolio Project].dbo.NashvilleHousing )

Delete From  CTE
Where DuplicateRowNum >1




--Delete Unused Columns

Alter Table [Portfolio Project].dbo.NashvilleHousing
Drop Column PropertyAddress, OwnerAddress, TaxDistrict

Alter Table [Portfolio Project].dbo.NashvilleHousing
Drop Column SaleDate

Select * from [Portfolio Project].dbo.NashvilleHousing 