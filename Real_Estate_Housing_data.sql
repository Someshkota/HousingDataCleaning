--changing the date, datetime type to date-- 


ALTER TABLE ResidentialData
ADD SaleDate_converted Date;

UPDATE ResidentialData
SET SaleDate_converted = CONVERT(date,SaleDate)


--populating the property adresses --

select PropertyAddress
from ResidentialHousingData..ResidentialData
where PropertyAddress is null

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from ResidentialHousingData..ResidentialData a
join ResidentialHousingData..ResidentialData b
	on a.ParcelID=b.ParcelID 
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from ResidentialHousingData..ResidentialData a
join ResidentialHousingData..ResidentialData b
	on a.ParcelID=b.ParcelID 
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


--breaking out the PropertyAddress to (Address,City and State)--

select 
SUBSTRING(PropertyAddress , 1,CHARINDEX(',',PropertyAddress)-1) as Address,	
SUBSTRING(PropertyAddress ,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address	
from ResidentialHousingData..ResidentialData

ALTER TABLE ResidentialData
ADD Property_split_Address nvarchar(255);

UPDATE ResidentialData
SET Property_split_Address=SUBSTRING(PropertyAddress , 1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE ResidentialData
ADD Property_split_city nvarchar(255);

UPDATE ResidentialData
SET Property_split_city=SUBSTRING(PropertyAddress ,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select 
parsename (REPLACE(OwnerAddress,',','.'),1)
from ResidentialHousingData..ResidentialData


ALTER TABLE ResidentialData
ADD owner_split_state nvarchar(255);

UPDATE ResidentialData
SET owner_split_state=parsename(REPLACE(OwnerAddress,',','.'),1)

ALTER TABLE ResidentialData
ADD owner_split_city nvarchar(255);

UPDATE ResidentialData
SET owner_split_city=parsename(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE ResidentialData
ADD owner_split_Address nvarchar(255);

UPDATE ResidentialData
SET owner_split_Address=parsename(REPLACE(OwnerAddress,',','.'),3)


--changing data from Y and N to YES and NO --


select DISTINCT(soldasvacant),count(SoldAsVacant)
from ResidentialHousingData..ResidentialData
group by SoldAsVacant
order by 2

select DISTINCT(soldasvacant)
,Case when soldasvacant='Y' then 'Yes'
	when soldasvacant='N' then 'No'
	Else SoldAsVacant
	END
from ResidentialHousingData..ResidentialData

UPDATE ResidentialData
SET SoldAsVacant=Case when soldasvacant='Y' then 'Yes'
	when soldasvacant='N' then 'No'
	Else SoldAsVacant
	END


--removing duplicates--
WITH RowNumCTE  as(		
select * ,
	ROW_NUMBER() OVER
	(PARTITION BY ParcelId,
				  propertyAddress,
				  SalePrice,
				  LegalReference
				  ORDER BY 
				  uniqueID 
				  )row_num
	
from ResidentialHousingData..ResidentialData
--order by ParcelID--
)
DELETE 
from RowNumCTE
where row_num>1
--order by PropertyAddress


--delete unused columns -- 

select * 
from ResidentialHousingData..ResidentialData


alter table ResidentialHousingData..ResidentialData
DROP COLUMN OwnerAddress,PropertyAddress,TaxDistrict

alter table ResidentialHousingData..ResidentialData
DROP COLUMN Property_split_state

alter table ResidentialHousingData..ResidentialData
DROP COLUMN SaleDate