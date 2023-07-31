
# Data Cleaning in SQL Queries

# 1. Standardize the date format
# Add a new column to store the converted date and then update that column to ensure all dates are in the desired format.

# Add a column for the converted date
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted DATE;

# Update the column with the converted date
UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate);

# 2. Populate missing Property Address data
# Fill in the records with null Property Address using related records with the same ParcelID.

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;

# 3. Break out the Address into individual columns (Address, City)
# Add new columns to store the address split into individual parts (address and city).
# Then update these columns with the corresponding values.

# Add columns for the split address
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255),
    PropertySplitCity NVARCHAR(255);

# Update the columns with the split values
UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
    PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

# 4. Break out the Owner Address into individual columns (Address, City, State) using PARSENAME
# Add new columns to store the split owner address (address, city, and state).
# Then update these columns with the split values using PARSENAME.

# Add columns for the split owner address
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255),
    OwnerSplitCity NVARCHAR(255),
    OwnerSplitState NVARCHAR(255);

# Update the columns with the split values using PARSENAME
UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
    OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

# 5. Change "Y" and "N" to "Yes" and "No" in the "SoldAsVacant" field
# Update the values "Y" to "Yes" and "N" to "No" in the "SoldAsVacant" column.

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE
                       WHEN SoldAsVacant = 'Y' THEN 'Yes'
                       WHEN SoldAsVacant = 'N' THEN 'No'
                       ELSE SoldAsVacant
                   END;

# 6. Remove duplicates based on a key column
# Use a Common Table Expression (CTE) to number the rows within duplicate groups.
# Then select rows with row_num > 1 (duplicates) and delete them if necessary.

WITH RowNumCTE AS
(
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
    FROM PortfolioProject.dbo.NashvilleHousing
)
#DELETE
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

# 7. Delete unused columns
# Remove columns that are no longer needed in the table.

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress,
    TaxDistrict,
    PropertyAddress,
    SaleDate;
