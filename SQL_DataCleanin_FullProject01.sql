Project Summary: Data Cleaning for Company Layoff Dataset

Overview:
In this data-intensive project, I meticulously tackled the complexities of a company's layoff dataset. 
My mission? To ensure data quality, consistency, and reliability—essential for informed decision-making. 
Leveraging MySQLWorkbench, I executed complex SQL queries, transforming raw data into a pristine, actionable resource.

Key Focus Areas:

1. Removing Duplicates:
   - Identified and eliminated duplicate records.
   - Ensured data integrity by retaining unique entries.

2. Standardizing the Data:
   - Normalized inconsistent formats (dates, periods, etc.).
   - Applied consistent naming conventions for categorical variables.

3. Handling Null Values or Blank Entries:
   - Strategically addressed missing values
   - Categorized categorical values (e.g., "Unknown" or "Null").
   - Ensured data completeness and accuracy.

4. Trimming Unwanted Columns or Rows:
   - Identified irrelevant or redundant columns
   - Safely dropped unnecessary columns, streamlining the dataset.
   - Removed rows with incomplete or irrelevant information.

Technical Details:
- Database Platform: MySQL workbench
- SQL Techniques Used:
  - `SELECT`, `UPDATE`, `DELETE` statements
  - `DISTINCT`, `GROUP BY`, and aggregate functions
  - `CASE` statements
  - Joins and subqueries 

Impact and Takeaways:
- The cleaned dataset now serves as a reliable foundation for subsequent analyses:
  - Predicting layoff trends
  - Identifying risk factors
  - Assessing workforce dynamics
- By mastering complex SQL queries, I demonstrated my ability to handle real-world data challenges and contribute to data quality improvement.

As a data enthusiast, I'm excited to continue refining my skills and applying them to meaningful projects. 

*********************************************************************
Code:

SELECT * FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Vlues or Blank Values
-- 4. Remove Any Columns (Risky)

CREATE TABLE layoffs_staging LIKE layoffs;

SELECT * FROM layoffs_staging;

INSERT layoffs_staging
SELECT * FROM layoffs;


SELECT * FROM world_layoffs.layoffs_staging;

-- ---------------------------------------------- Remove Duplicates ---------------------------

-- Using ROW_NUMBER() Methood
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, 
industry,total_laid_off, percentage_laid_off, `date`, 
stage, country, funds_raised_millions )
AS 'row_num'
FROM world_layoffs.layoffs_staging;

-- Using CTE Further
WITH duplicate_cte AS 
(SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, 
industry,total_laid_off, percentage_laid_off, `date`, 
stage, country, funds_raised_millions )
AS 'row_num'
FROM world_layoffs.layoffs_staging)
SELECT * FROM duplicate_cte
WHERE row_num > 1;

-- Using New Table (layoffs_staging2)
CREATE TABLE layoffs_staging2 LIKE layoffs_staging;
SELECT * FROM layoffs_staging2; -- Empty

-- Clipboard operation did'nt work, hence the create table code and then right click on table and ALTER.
INSERT INTO layoffs_staging2
(SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, 
industry,total_laid_off, percentage_laid_off, `date`, 
stage, country, funds_raised_millions )
AS 'row_num'
FROM world_layoffs.layoffs_staging);

DELETE FROM layoffs_staging2
WHERE row_num > 1;



-- --------------------Standardizing Data (Finding issues in data and fixing it)--------------

SELECT * FROM world_layoffs.layoffs_staging2;


-- |To remove the space|
SELECT company, TRIM(company)
FROM world_layoffs.layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT company
FROM world_layoffs.layoffs_staging2;

-- |To filter and correct entries|

-- industry COL ********
SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY 1;

SELECT industry
FROM world_layoffs.layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- country COL (Trim, Trailing --Full Stop) ******
SELECT DISTINCT country
FROM world_layoffs.layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country, TRIM(Trailing '.' FROM country)
FROM world_layoffs.layoffs_staging2;

UPDATE layoffs_staging2
SET country = TRIM(Trailing '.' FROM country)
WHERE country LIKE 'United States%';

-- date COL (str_to_date) --- ****
SELECT `date`, str_to_date(`date`, '%m/%d/%Y')
FROM world_layoffs.layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');




-- --------------------------------Null Vlues or Blank Values------------------------------------------------

SELECT * FROM world_layoffs.layoffs_staging2;

SELECT * FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- To Check the corresponding values, in-order to populate the Null/Blank entries.
SELECT * FROM world_layoffs.layoffs_staging2
WHERE company = 'Airbnb';


-- Performing JOIN Operation to Populate
SELECT t1.industry, t2.industry
FROM world_layoffs.layoffs_staging2 t1
JOIN world_layoffs.layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2. industry IS NOT NULL;

-- This didn't work, why? Could be blank values!
UPDATE world_layoffs.layoffs_staging2 t1
JOIN world_layoffs.layoffs_staging2 t2
	ON t1.company = t2.company
	AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL)
AND t2. industry IS NOT NULL;

-- Change blank values to NULL values
UPDATE world_layoffs.layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Now this will work
UPDATE world_layoffs.layoffs_staging2 t1
JOIN world_layoffs.layoffs_staging2 t2
	ON t1.company = t2.company
	AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL)
AND t2. industry IS NOT NULL;

-- ***Hence all the null/blank values are populated.***
-- *
-- *


-- --------------------------------- Remove Any Columns (Risky)--------------------------------------------------

SELECT * FROM world_layoffs.layoffs_staging2;


-- We could delete the following s well
SELECT * FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


-- DROP Coloum by: OR By right click Method
ALTER TABLE world_layoffs.layoffs_staging2
DROP COLUMN row_num;
