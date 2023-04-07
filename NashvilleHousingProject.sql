select *
from NashvilleHousing
order by ParcelID

---------------------------------------------------------------------
--Update SaleDate field
---------------------------------------------------------------------

alter  table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted=CAST(SaleDate as date)

select SaleDateConverted,CAST(SaleDate as date)
from NashvilleHousing

---------------------------------------------------------------------
--Populte Property Address data
---------------------------------------------------------------------

-- get the Property Address null values 

select Nlift.ParcelID,Nlift.PropertyAddress,Nright.ParcelID,Nright.PropertyAddress,
ISNULL(Nlift.PropertyAddress,Nright.PropertyAddress) as Populted
from NashvilleHousing as Nlift join NashvilleHousing as Nright
on Nlift.ParcelID=Nright.ParcelID and Nlift.[UniqueID ] <> Nright.[UniqueID ]
where Nlift.PropertyAddress is null

-- update Property Address null values 

update Nlift
set PropertyAddress=ISNULL(Nlift.PropertyAddress,Nright.PropertyAddress)
from NashvilleHousing as Nlift join NashvilleHousing as Nright
on Nlift.ParcelID=Nright.ParcelID and Nlift.[UniqueID ] <> Nright.[UniqueID ]
where Nlift.PropertyAddress is null

---------------------------------------------------------------------
--Split PropertyAddress into Address and City
---------------------------------------------------------------------

--Split PropertyAddress

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as City
from NashvilleHousing 

--Altering the new columns

alter  table NashvilleHousing
add Address nvarchar(255),City nvarchar(255);

--Asign the data

update NashvilleHousing
set Address=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
City=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

---------------------------------------------------------------------
--Split OwnerAddress into OwnerSplitAddress and OwnerSplitCity and OwnerSplitState
---------------------------------------------------------------------

--Split OwnerAddress

select PARSENAME(REPLACE(OwnerAddress,',','.'),3) as Address,PARSENAME(REPLACE(OwnerAddress,',','.'),2) as City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as State
from NashvilleHousing

--Altering the new columns

alter  table NashvilleHousing
add OwnerSplitAddress nvarchar(255),OwnerSplitCity nvarchar(255),OwnerSplitState nvarchar(255);

--Asign the data

update NashvilleHousing
set OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3),
OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2),
OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

---------------------------------------------------------------------
-- Standardization of SoldAsVacant values
---------------------------------------------------------------------

--get the number of SoldAsVacant values

select distinct (SoldAsVacant),COUNT(SoldAsVacant) as Count
from NashvilleHousing
group by SoldAsVacant
order by COUNT(SoldAsVacant)

--Change Y to Yes and N to No

select SoldAsVacant,
 case 
	when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
    end ShouldBe
from NashvilleHousing
order by SoldAsVacant

--Updating the values

update NashvilleHousing
set SoldAsVacant=case 
	when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
    end 

	
---------------------------------------------------------------------
-- Remove Duplicates
---------------------------------------------------------------------

with RDCTE as (select * ,ROW_NUMBER() over (partition by ParcelID,  
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by UniqueID) as DCount 
from NashvilleHousing )
delete 
from RDCTE 
where DCount >1

---------------------------------------------------------------------
-- Drop Useless columns
---------------------------------------------------------------------

alter table NashvilleHousing
Drop column PropertyAddress ,OwnerAddress ,TaxDistrict,SaleDate

