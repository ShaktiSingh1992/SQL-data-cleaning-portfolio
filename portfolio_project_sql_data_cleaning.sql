/*
Cleaning Data in SQL Queries

*/
use PORTFOLIOPROJECT
select * from nashvillehousing

----------------------------------------------------------------------------------------------------------------
--Standardiza Date Format

SELECT SaleDateConverted, CONVERT(DATE, SaleDate)  FROM NASHVILLEHOUSING

ALTER TABLE NASHVILLEHOUSING
ADD SaleDateConverted Date;

UPDATE NashvilleHousing 
SET SaleDateConverted = CONVERT(Date, SaleDate) 

---------------------------------------------------------------------------------------------------------------
--Populate Property Address Data

SELECT * FROM NASHVILLEHOUSING
WHERE PROPERTYADDRESS IS NULL
ORDER BY PARCELID

SELECT A.PARCELID, A.PROPERTYADDRESS, B.PARCELID, B.PROPERTYADDRESS, ISNULL(a.PropertyAddress,b.propertyaddress)
FROM PORTFOLIOPROJECT.dbo.NashvilleHousing AS A
JOIN PORTFOLIOPROJECT.dbo.NashvilleHousing AS B 
ON A.PARCELID = B.PARCELID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PROPERTYADDRESS IS NULL

UPDATE A
SET PropertyAddress = ISNULL(a.PropertyAddress,b.propertyaddress)
FROM PORTFOLIOPROJECT.dbo.NashvilleHousing AS A
JOIN PORTFOLIOPROJECT.dbo.NashvilleHousing AS B 
ON A.PARCELID = B.PARCELID
AND A.[UniqueID ] <> B.[UniqueID ]

---------------------------------------------------------------------------------------------------
---BREAKING OUT ADDRESS INTO INDIVIDUAL COLOUMNS(ADDRESS, CITY, STATE)

---FIRSTLY SPLITTING PROPERTY ADDRESS COLOUMN

SELECT PropertyAddress FROM NashvilleHousing

SELECT 
SUBSTRING(PROPERTYADDRESS, 1, CHARINDEX(',',PropertyAddress)-1) AS ADDRESS
--1 IS THE STARTING POINT, CHARINDEX',' IS THE ENDING POINT
,SUBSTRING(PROPERTYADDRESS, CHARINDEX(',',PropertyAddress)+1, LEN(PROPERTYADDRESS) ) AS CITY 
--CHARINDEX',' IS THE STARTING POINT AND LEN(PROPADDRESS) IS THE ENDING POINT

--CHARACTER INDEX(CHARINDEX) LOOKS FOR A SPECIFIT VALUE, HERE IT IS LOOKING FOR A COMMA

FROM NashvilleHousing

ALTER TABLE NASHVILLEHOUSING 
ADD StreetAddress NVARCHAR(255);

update NashvilleHousing
SET StreetAddress = SUBSTRING(PROPERTYADDRESS, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NASHVILLEHOUSING
ADD CITY NVARCHAR(50);

UPDATE NashvilleHousing
SET CITY = SUBSTRING(PROPERTYADDRESS, CHARINDEX(',',PropertyAddress)+1, LEN(PROPERTYADDRESS) )

SELECT * FROM NashvilleHousing

--SPLIT OWNERS ADDRESS
 SELECT OwnerAddress FROM NashvilleHousing

 SELECT 
 PARSENAME(REPLACE(OWNERADDRESS,',','.'),3),
 PARSENAME(REPLACE(OWNERADDRESS,',','.'),2),
 PARSENAME(REPLACE(OWNERADDRESS,',','.'),1)
 FROM NashvilleHousing

 ALTER TABLE nashvillehousing
 ADD OwnerSplitAddress nvarchar(255);
 
 UPDATE NashvilleHousing
 SET OwnerSplitAddress = PARSENAME(REPLACE(OWNERADDRESS,',','.'),3)

 ALTER TABLE Nashvillehousing
 ADD OwnerSplitCity nvarchar(255);
 
 UPDATE NashvilleHousing
 SET OwnerSplitCity = PARSENAME(REPLACE(OWNERADDRESS,',','.'),2)

 ALTER TABLE Nashvillehousing
 ADD OwnerSplitState nvarchar(255);
 
 UPDATE NashvilleHousing
 SET OwnerSplitState = PARSENAME(REPLACE(OWNERADDRESS,',','.'),1)

 SELECT * FROM NashvilleHousing

 --------------------------------------------------------------------------------------------------------
 ----CHANGE 'Y' AND 'N' TO YES AND NO IN "SOLD AS VACANT" FIELD 

 SELECT SoldAsVacant FROM NashvilleHousing

 SELECT DISTINCT(SoldAsVacant), COUNT(SOLDASVACANT) FROM NashvilleHousing
 GROUP BY SoldAsVacant
 ORDER BY 2

 SELECT SoldAsVacant, 
 CASE 
 WHEN SoldAsVacant = 'Y' THEN 'Yes'
 WHEN SoldAsVacant = 'N' THEN 'No'
 ELSE SoldAsVacant
 END
 FROM NashvilleHousing

 UPDATE NashvilleHousing
 SET SoldAsVacant = CASE 
 WHEN SoldAsVacant = 'Y' THEN 'Yes'
 WHEN SoldAsVacant = 'N' THEN 'No'
 ELSE SoldAsVacant
 END

 
 SELECT DISTINCT(SoldAsVacant), COUNT(SOLDASVACANT) FROM NashvilleHousing
 GROUP BY SoldAsVacant
 ORDER BY 2

 -------------------------------------------------------------------------------------------------
 -----REMOVING DUPLICATES UING CTE
  WITH ROWNUMCTE AS (

 SELECT *,
 ROW_NUMBER() OVER(
 PARTITION BY PARCELID, PROPERTYADDRESS,SALEDATE, SALEPRICE, LEGALREFERENCE
 ORDER BY UNIQUEID 
 ) AS ROW_NUM
 FROM NASHVILLEHOUSING
 --ORDER BY ParcelID
 )

 SELECT * FROM ROWNUMCTE
 WHERE ROW_NUM >1
 --ORDER BY PropertyAddress

   WITH ROWNUMCTE AS (

 SELECT *,
 ROW_NUMBER() OVER(
 PARTITION BY PARCELID, PROPERTYADDRESS,SALEDATE, SALEPRICE, LEGALREFERENCE
 ORDER BY UNIQUEID 
 ) AS ROW_NUM
 FROM NASHVILLEHOUSING
 --ORDER BY ParcelID
 )

 DELETE FROM ROWNUMCTE
 WHERE ROW_NUM >1
 --ORDER BY PropertyAddress

 -----------------------------------------------------------------------------------------------------
 -----DELETE UNUSED COLUMN

 SELECT * FROM NashvilleHousing

 ALTER TABLE NashvilleHousing
 DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

 ALTER TABLE NashvilleHousing
 DROP COLUMN SaleDate