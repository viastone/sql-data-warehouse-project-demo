-- ===============================================
-- Checks for crm_prd_info
-- ===============================================
SELECT
prd_id,
prd_key,
prd_nm,
prd_start_dt,
prd_end_dt,
LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS prd_end_dt_test -- accessing the next record (to access the previous, use LAG())
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509')


-- ===============================================
-- Checks for erp_px_cat_g1v2
-- ===============================================
SELECT
id,
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2;

-- Check if id matches with id from other column
SELECT id FROM bronze.erp_px_cat_g1v2 
WHERE id NOT IN (SELECT cat_id FROM silver.crm_prd_info);

-- Check for data integrity
SELECT DISTINCT cat FROM bronze.erp_px_cat_g1v2;

-- Check for data integrity
SELECT DISTINCT subcat FROM bronze.erp_px_cat_g1v2;

-- Check for data integrity
SELECT DISTINCT maintenance FROM bronze.erp_px_cat_g1v2;

-- Check for unwanted spaces
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE id != TRIM(id) OR cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);




-- ===============================================
-- Checks for crm_sales_details
-- ===============================================
-- Check for Invalid Dates
SELECT 
NULLIF(sls_order_dt,0) AS sls_order_dt -- returns NULL if the value is equal to 0.
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 
OR LEN(sls_order_dt) != 8-- checks if date is not YYYY-MM-DD (8 digits)
OR sls_order_dt > 20500101; -- check for boundaries of the date range



-- Check for Sales, Quanity and Price
-- Rules:
-- If Sales in negative, zero or null, derive it using Quantity and Price
-- If Price is zero or null, calculate it using Sales and Quantity
-- If Price is negative, convert it to a positive value
SELECT DISTINCT 
sls_sales AS old_sls_sales,
sls_quantity,
sls_price AS old_sls_price,
CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) -- ABS = converts negative price to positive
	THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END AS sls_sales,
CASE WHEN sls_price IS NULL OR sls_price <= 0 
	THEN sls_sales / NULLIF(sls_quantity, 0)
	ELSE sls_price
END AS sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;
