-- =================================================================
-- Retail Sales & Customer Segmentation (RFM Analysis)
-- Purpose: Clean raw sales data, handle missing values, and segment customers.
-- =================================================================

-- Step 1: Data Cleaning & Creating a Staging View
CREATE VIEW vw_Cleaned_Retail_Sales AS
SELECT 
    TransactionID,
    CustomerID,
    UPPER(TRIM(ProductCategory)) AS ProductCategory,
    Quantity,
    UnitPrice,
    (Quantity * UnitPrice) AS TotalSalesAmount,
    COALESCE(Discount, 0) AS DiscountAmount,
    TransactionDate
FROM 
    Raw_Retail_Transactions
WHERE 
    Quantity > 0 AND UnitPrice > 0;

-- Step 2: Customer RFM (Recency, Frequency, Monetary) Calculation
-- This query helps businesses identify high-value customers for targeted marketing.
WITH CustomerRFM AS (
    SELECT 
        CustomerID,
        DATEDIFF(day, MAX(TransactionDate), '2026-01-01') AS Recency, -- Days since last purchase
        COUNT(DISTINCT TransactionID) AS Frequency,                    -- Total number of orders
        SUM(TotalSalesAmount) AS Monetary                            -- Total spend
    FROM 
        vw_Cleaned_Retail_Sales
    GROUP BY 
        CustomerID
)
SELECT 
    CustomerID,
    Recency,
    Frequency,
    Monetary,
    NTILE(5) OVER (ORDER BY Recency DESC) AS RecencyScore,
    NTILE(5) OVER (ORDER BY Frequency ASC) AS FrequencyScore,
    NTILE(5) OVER (ORDER BY Monetary ASC) AS MonetaryScore
FROM 
    CustomerRFM;
