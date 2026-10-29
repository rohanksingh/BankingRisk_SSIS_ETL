if db_id('BankingRiskDW') IS NULL 
Begin 
create database BankingRiskDW;
END;
GO

use BankingRiskDW;
go

create schema bronze;
go

create schema silver;
go

create schema gold;
go

create schema audit;
go



use BankingRiskDW;
go

select name from sys.schemas
where name in ('bronze', 'silver', 'gold', 'audit');



use BankingRiskDW;
go

CREATE TABLE bronze.Customers (
    CustomerID INT,
    CustomerName VARCHAR(100),
    State VARCHAR(50),
    CreditScore INT,
    AnnualIncome DECIMAL(18,2),
    LoanApplicationDate DATE,
    SourceFile VARCHAR(255),
    LoadDate DATETIME2 DEFAULT SYSDATETIME()
);
GO


select top 10 * from bronze.Customers; 

CREATE TABLE bronze.Loans (
    LoanID INT,
    CustomerID INT,
    LoanType VARCHAR(50),
    LoanAmount DECIMAL(18,2),
    OutstandingBalance DECIMAL(18,2),
    InterestRate DECIMAL(8,4),
    LoanStartDate DATE,
    MaturityDate DATE,
    LoanStatus VARCHAR(30),
    SourceFile VARCHAR(255),
    LoadDate DATETIME2 DEFAULT SYSDATETIME()
);
GO

SELECT TOP 10 *
FROM bronze.Loans;


USE BankingRiskDW;
GO

CREATE TABLE bronze.Payments (
    PaymentID INT,
    LoanID INT,
    PaymentDueDate DATE,
    PaymentDate DATE,
    AmountDue DECIMAL(18,2),
    AmountPaid DECIMAL(18,2),
    PaymentStatus VARCHAR(30),
    SourceFile VARCHAR(255),
    LoadDate DATETIME2 DEFAULT SYSDATETIME()
);
GO

SELECT TOP 10 *
FROM bronze.Payments;

CREATE TABLE bronze.CreditRisk (
    LoanID INT,
    RiskGrade VARCHAR(10),
    CreditScore INT,
    DaysPastDue INT,
    PD DECIMAL(10,6),
    LGD DECIMAL(10,6),
    EAD DECIMAL(18,2),
    AssessmentDate DATE,
    SourceFile VARCHAR(255),
    LoadDate DATETIME2 DEFAULT SYSDATETIME()
);
GO

SELECT TOP 10 *
FROM bronze.CreditRisk;

USE BankingRiskDW;
GO


SELECT COUNT(*) AS TotalCustomers
FROM bronze.Customers;

SELECT TOP 10 *
FROM bronze.Customers;

USE BankingRiskDW;
GO

select 
count(*) as TotalRecords,
count(distinct CustomerID) as UniqueCustomers,
count(*) - count(distinct CustomerID) as DuplicateRecords,
sum(case when CustomerID is null then 1 else 0 end) as NullCustomerIDs
from bronze.Customers;


USE BankingRiskDW;
GO

CREATE TABLE silver.Customers (
    CustomerID INT NOT NULL PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    State VARCHAR(50),
    CreditScore INT,
    AnnualIncome DECIMAL(18,2),
    LoanApplicationDate DATE,
    SourceFile VARCHAR(255),
    LoadDate DATETIME2 DEFAULT SYSDATETIME(),

    CONSTRAINT CK_Customer_CreditScore
        CHECK (CreditScore BETWEEN 300 AND 850),

    CONSTRAINT CK_Customer_AnnualIncome
        CHECK (AnnualIncome >= 0)
);
GO

SELECT TOP 10 *
FROM silver.Customers;



USE BankingRiskDW;
GO

CREATE TABLE audit.RejectedCustomers (
    RejectionID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NULL,
    CustomerName VARCHAR(100) NULL,
    State VARCHAR(50) NULL,
    CreditScore INT NULL,
    AnnualIncome DECIMAL(18,2) NULL,
    LoanApplicationDate DATE NULL,
    SourceFile VARCHAR(255) NULL,
    LoadDate DATETIME2 NULL,
    RejectionReason VARCHAR(255) NULL,
    RejectedAt DATETIME2 DEFAULT SYSDATETIME()
);
GO

SELECT TOP 10 *
FROM audit.RejectedCustomers;


USE BankingRiskDW;
GO

SELECT
    CustomerID,
    COUNT(*) AS DuplicateCount
FROM bronze.Customers
GROUP BY CustomerID
HAVING COUNT(*) > 1
ORDER BY DuplicateCount DESC;



USE BankingRiskDW;
GO

SELECT
    'Bronze Customers' AS TableName,
    COUNT(*) AS RecordCount
FROM bronze.Customers

UNION ALL

SELECT
    'Silver Customers',
    COUNT(*)
FROM silver.Customers

UNION ALL

SELECT
    'Rejected Customers',
    COUNT(*)
FROM audit.RejectedCustomers;


USE BankingRiskDW;
GO

SELECT 'Bronze' AS DataLayer, COUNT(*) AS RecordCount
FROM bronze.Customers

UNION ALL

SELECT 'Silver', COUNT(*)
FROM silver.Customers

UNION ALL

SELECT 'Rejected', COUNT(*)
FROM audit.RejectedCustomers;


USE BankingRiskDW;
GO

SELECT COUNT(*) AS SilverCustomerCount
FROM silver.Customers;


USE BankingRiskDW;
GO

SELECT COUNT(*) AS SilverCustomerCount
FROM silver.Customers;

SELECT COUNT(*) AS RejectedCustomerCount
FROM audit.RejectedCustomers;



USE BankingRiskDW;
GO

SELECT
    (SELECT COUNT(*) FROM bronze.Customers) AS BronzeCustomers,
    (SELECT COUNT(*) FROM silver.Customers) AS SilverCustomers,
    (SELECT COUNT(*) FROM audit.RejectedCustomers) AS RejectedCustomers;

USE BankingRiskDW;
GO

INSERT INTO bronze.Customers
(
    CustomerID,
    CustomerName,
    State,
    CreditScore,
    AnnualIncome,
    LoanApplicationDate,
    SourceFile
)
VALUES
(
    10001,
    'Test Customer',
    'NJ',
    740,
    95000.00,
    '2026-10-27',
    'incremental_customers.csv'
);
GO


SELECT *
FROM bronze.Customers
WHERE CustomerID = 10001;




USE BankingRiskDW;
GO

SELECT COUNT(*) AS BronzeCustomers
FROM bronze.Customers;

SELECT COUNT(*) AS SilverCustomers
FROM silver.Customers;

SELECT *
FROM silver.Customers
WHERE CustomerID = 10001;

USE BankingRiskDW;
GO

INSERT INTO bronze.Customers
(
    CustomerID,
    CustomerName,
    State,
    CreditScore,
    AnnualIncome,
    LoanApplicationDate,
    SourceFile
)
VALUES
(
    10002,
    'Invalid Test Customer',
    'NJ',
    950,
    75000.00,
    '2026-10-27',
    'data_quality_test.csv'
);
GO

SELECT CustomerID, CustomerName, CreditScore
FROM bronze.Customers
WHERE CustomerID = 10002;

USE BankingRiskDW;
GO

SELECT COUNT(*) AS SilverCustomers
FROM silver.Customers;

SELECT COUNT(*) AS RejectedCustomers
FROM audit.RejectedCustomers;

SELECT *
FROM audit.RejectedCustomers
WHERE CustomerID = 10002;

SELECT *
FROM silver.Customers
WHERE CustomerID = 10002;


USE BankingRiskDW;
GO

SELECT
    RejectionID,
    CustomerID,
    CreditScore,
    RejectionReason
FROM audit.RejectedCustomers
WHERE CustomerID = 10002;


DELETE FROM audit.RejectedCustomers
WHERE CustomerID = 10002
  AND CreditScore = 950
  AND SourceFile = 'data_quality_test.csv';

SELECT COUNT(*) AS RemainingTestRejections
FROM audit.RejectedCustomers
WHERE CustomerID = 10002;


USE BankingRiskDW;
GO

SELECT
    RejectionID,
    CustomerID,
    CreditScore,
    RejectionReason,
    RejectedAt
FROM audit.RejectedCustomers
WHERE CustomerID = 10002;


SELECT COUNT(*) AS SilverCustomers
FROM silver.Customers;

SELECT COUNT(*) AS InvalidCustomerInSilver
FROM silver.Customers
WHERE CustomerID = 10002;


USE BankingRiskDW;
GO

CREATE TABLE audit.ETLExecutionLog
(
    ExecutionID INT IDENTITY(1,1) PRIMARY KEY,
    PackageName VARCHAR(150) NOT NULL,
    StartTime DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    EndTime DATETIME2 NULL,
    ExecutionStatus VARCHAR(30) NOT NULL DEFAULT 'Running',
    SourceRowCount INT DEFAULT 0,
    InsertedRowCount INT DEFAULT 0,
    SkippedRowCount INT DEFAULT 0,
    RejectedRowCount INT DEFAULT 0,
    ErrorMessage VARCHAR(MAX) NULL
);
GO


SELECT TOP 10 *
FROM audit.ETLExecutionLog;

SELECT
    RejectionID,
    CustomerID,
    CreditScore,
    RejectionReason,
    RejectedAt
FROM audit.RejectedCustomers
WHERE CustomerID = 10002
ORDER BY RejectionID DESC;

SELECT
    CustomerID,
    COUNT(*) AS RejectionCount
FROM audit.RejectedCustomers
GROUP BY CustomerID
HAVING COUNT(*) > 1;


SELECT TOP 5
    ExecutionID,
    PackageName,
    StartTime,
    EndTime,
    ExecutionStatus
FROM audit.ETLExecutionLog
ORDER BY ExecutionID DESC;


USE BankingRiskDW;
GO

CREATE TABLE gold.CustomerRiskSummary
(
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    State VARCHAR(50),
    CreditScore INT,
    AnnualIncome DECIMAL(18,2),
    RiskCategory VARCHAR(20),
    LastUpdated DATETIME2
        DEFAULT SYSDATETIME()
);
GO


USE BankingRiskDW;
GO

SELECT
    RiskCategory,
    COUNT(*) AS CustomerCount
FROM gold.CustomerRiskSummary
GROUP BY RiskCategory
ORDER BY RiskCategory;



USE BankingRiskDW;
GO

SELECT
    (SELECT COUNT(*) FROM silver.Customers)
        AS SilverCustomerCount,

    (SELECT COUNT(*) FROM gold.CustomerRiskSummary)
        AS GoldCustomerCount,

    (
        SELECT COUNT(*)
        FROM silver.Customers s
        LEFT JOIN gold.CustomerRiskSummary g
            ON s.CustomerID = g.CustomerID
        WHERE g.CustomerID IS NULL
    ) AS MissingInGold;


--Validate Gold Risk Classification

    USE BankingRiskDW;
GO

SELECT
    CustomerID,
    CreditScore,
    RiskCategory
FROM gold.CustomerRiskSummary
WHERE RiskCategory <>
    CASE
        WHEN CreditScore >= 750 THEN 'Low Risk'
        WHEN CreditScore >= 650 THEN 'Medium Risk'
        ELSE 'High Risk'
    END;


    USE BankingRiskDW;
GO

CREATE OR ALTER VIEW gold.vw_CustomerRiskAnalytics
AS
SELECT
    RiskCategory,
    COUNT(*) AS TotalCustomers,
    CAST(
        AVG(CAST(CreditScore AS DECIMAL(10,2)))
        AS DECIMAL(10,2)
    ) AS AverageCreditScore,
    CAST(
        AVG(AnnualIncome)
        AS DECIMAL(18,2)
    ) AS AverageAnnualIncome,
    SUM(AnnualIncome) AS TotalAnnualIncome
FROM gold.CustomerRiskSummary
GROUP BY RiskCategory;
GO


SELECT *
FROM gold.vw_CustomerRiskAnalytics
ORDER BY
    CASE RiskCategory
        WHEN 'High Risk' THEN 1
        WHEN 'Medium Risk' THEN 2
        WHEN 'Low Risk' THEN 3
    END;



    USE BankingRiskDW;
GO

-- Check the Loans table structure
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'bronze'
  AND TABLE_NAME = 'Loans'
ORDER BY ORDINAL_POSITION;

-- Check how many loans are loaded
SELECT COUNT(*) AS TotalBronzeLoans
FROM bronze.Loans;

-- Preview loan records
SELECT TOP 5 *
FROM bronze.Loans;