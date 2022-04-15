-- Standardize Date Format


Select saleDateConverted, CONVERT(SaleDate , date)
From h1;


Update h1
SET SaleDate = CONVERT(saledate,date);

-- Populate Property Address data
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IfNULL(a.PropertyAddress,b.PropertyAddress)
From h1 a
JOIN h1 b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID  <> b.UniqueID 
    Where a.PropertyAddress is null;
    
Update h1 a
join h1 b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID 
SET PropertyAddress = IfNULL(a.PropertyAddress,b.PropertyAddress)    
Where a.PropertyAddress is null;

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From h1;

SELECT
SUBSTRING(PropertyAddress, 1, position(','in PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, position(','in PropertyAddress) + 1 , LENgth(PropertyAddress)) as Address
From h1;

ALTER TABLE h1
Add PropertySplitAddress Nvarchar(255);

Update h1
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, position(','in PropertyAddress) -1 );

ALTER TABLE h1
Add PropertySplitCity Nvarchar(255);

Update h1
SET PropertySplitCity = SUBSTRING(PropertyAddress, position(',' in PropertyAddress) + 1 , LENGTH(PropertyAddress));

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From h1
Group by SoldAsVacant
order by 2;

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From h1;

Update h1
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;

-- removing duplicates

with rownumCTE as(
select *,
	row_number() over(
    partition by parcelid,
				 propertyaddress,
                 saleprice,
                 saledate,
                 legalreference
                 order by uniqueid
    ) as row_num
    from h1
    )
select * from rownumcte
where row_num>1;

DELETE
from h1
where parcelid in (
select parcelid from (
select *,
	row_number() over(
    partition by parcelid,
				 propertyaddress,
                 saleprice,
                 saledate,
                 legalreference
                 order by uniqueid
    ) as row_num
    from h1)
    as temp_table 
    where row_num>1
);

-- removing unused columns

alter table h1
	drop owneraddress,
    drop taxdistrict,
    drop propertyaddress;
    
select * from h1;
