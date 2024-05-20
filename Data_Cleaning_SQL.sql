-- Data Cleaning


Select * from layoffs; 


Create Table layoffs_staging
Like layoffs;

Select * from layoffs_staging;

Insert layoffs_staging
Select * from layoffs;

-- Removing Duplicates

With CTE As(
Select *, ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,date,
stage,country,funds_raised_millions) as row_num
From layoffs_staging
)
Select * from CTE
Where row_num >1;

CREATE TABLE `layoffs_staging_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


Select * from layoffs_staging_2;
INSERT INTO layoffs_staging_2
 Select *, ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,date,
stage,country,funds_raised_millions) as row_num
From layoffs_staging;

DELETE from layoffs_staging_2
WHERE row_num>1;

SELECT * FROM layoffs_staging_2;

-- Standardizing Data

Update layoffs_staging_2
SET company = Trim(company);

Update layoffs_staging_2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

Update layoffs_staging_2
Set country = Trim(trailing '.' from country);

Update layoffs_staging_2
Set date = str_to_date(date,'%m/%d/%Y');
Alter Table layoffs_staging_2
Modify column date DATE;


-- Handling with Null/Blank values

Select tab1.industry,tab2.industry from layoffs_staging_2 tab1
Join layoffs_staging_2 tab2
ON tab1.company = tab2.company AND
tab1.location = tab2.location 
WHERE (tab1.industry is NULL OR tab1.industry= '')
 AND
tab2.industry is not NULL;

Update layoffs_staging_2 t1
Join layoffs_staging_2 t2
ON t1.company = t2.company
Set t1.industry = t2.industry
WHERE (t1.industry is NULL OR t2.industry = '')
 AND
t2.industry is not NULL;


DELETE from layoffs_staging_2
WHERE total_laid_off is NULL 
AND percentage_laid_off is NULL;

-- Dropping Any Columns

Alter Table layoffs_staging_2
Drop Column row_num;

Select * from layoffs_staging_2;