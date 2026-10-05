/* ============================================================
   07. CLEAN AND TRANSFORM STAGING TABLES
   ============================================================ */


/* ============================================================
   07.1 CLEAN CUSTOMER DIMENSION
   ============================================================ */

UPDATE stg_bank_enroll.dbo.dim_customer
SET
    first_name = TRIM(first_name),
    last_name = TRIM(last_name),
    email = LOWER(TRIM(email)),
    mobile_number = REPLACE(
                        REPLACE(
                            REPLACE(mobile_number, ' ', ''),
                            '-',
                            ''
                        ),
                        '+',
                        ''
                    ),
    gender = CASE
                WHEN UPPER(TRIM(gender)) = 'M' THEN 'Male'
                WHEN UPPER(TRIM(gender)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(gender)) = 'U' THEN 'Unknown'
                ELSE 'Unknown'
             END;


/* ============================================================
   07.2 CLEAN ACCOUNT DIMENSION
   ============================================================ */

UPDATE stg_bank_enroll.dbo.dim_account
SET
    account_number = TRIM(account_number),
    product_type = CASE
                    WHEN UPPER(TRIM(product_type)) = 'SAVINGS'
                        THEN 'Savings'
                    WHEN UPPER(TRIM(product_type)) = 'PERSONAL LOAN'
                        THEN 'Personal Loan'
                    WHEN UPPER(TRIM(product_type)) = 'CREDIT CARD'
                        THEN 'Credit Card'
                    ELSE TRIM(product_type)
                   END,
    account_status = CASE
                        WHEN UPPER(TRIM(account_status)) = 'ACTIVE'
                            THEN 'Active'
                        WHEN UPPER(TRIM(account_status)) = 'INACTIVE'
                            THEN 'Inactive'
                        WHEN UPPER(TRIM(account_status)) = 'CLOSED'
                            THEN 'Closed'
                        ELSE TRIM(account_status)
                     END;


/* ============================================================
   07.3 CLEAN CHANNEL DIMENSION
   ============================================================ */

UPDATE stg_bank_enroll.dbo.dim_channel
SET
    channnel = CASE
                WHEN UPPER(TRIM(channnel)) = 'ATM'
                    THEN 'ATM'
                WHEN UPPER(TRIM(channnel)) = 'BRANCH'
                    THEN 'Branch'
                WHEN UPPER(TRIM(channnel)) = 'CALL'
                    THEN 'Call'
                WHEN UPPER(TRIM(channnel)) = 'CHAT'
                    THEN 'Chat'
                WHEN UPPER(TRIM(channnel)) = 'EFT'
                    THEN 'EFT'
                WHEN UPPER(TRIM(channnel)) = 'EMAIL'
                    THEN 'Email'
                WHEN UPPER(TRIM(channnel)) = 'MOBILE APP'
                    THEN 'Mobile App'
                WHEN UPPER(TRIM(channnel)) = 'ONLINE BANKING'
                    THEN 'Online Banking'
                WHEN UPPER(TRIM(channnel)) = 'POS'
                    THEN 'POS'
                WHEN UPPER(TRIM(channnel)) = 'WHATSAPP'
                    THEN 'WhatsApp'
                ELSE TRIM(channnel)
              END;


/* ============================================================
   07.4 CLEAN LOCATION DIMENSION
   ============================================================ */

UPDATE stg_bank_enroll.dbo.dim_location
SET
    province = TRIM(province),
    city = TRIM(city);


/* ============================================================
   07.5 CLEAN DATE DIMENSION
   ============================================================ */

-- Check for invalid date relationships before loading the DWH.

SELECT *
FROM stg_bank_enroll.dbo.dim_date
WHERE event_date < signup_date;


/* ============================================================
   07.6 CLEAN EVENT DIMENSION
   ============================================================ */

UPDATE stg_bank_enroll.dbo.dim_event
SET
    event_type = CASE
                    WHEN UPPER(TRIM(event_type)) = 'PRODUCT ENROLLMENT'
                        THEN 'Product Enrollment'
                    WHEN UPPER(TRIM(event_type)) = 'TRANSACTION'
                        THEN 'Transaction'
                    WHEN UPPER(TRIM(event_type)) = 'CRM INTERACTION'
                        THEN 'CRM Interaction'
                    ELSE TRIM(event_type)
                 END;


/* ============================================================
   07.7 CLEAN INTERACTION DIMENSION
   ============================================================ */

UPDATE stg_bank_enroll.dbo.dim_interaction
SET
    interaction_type = TRIM(interaction_type),
    resolved_flag = CASE
                        WHEN UPPER(TRIM(resolved_flag)) IN ('Y', 'YES')
                            THEN 'Yes'
                        WHEN UPPER(TRIM(resolved_flag)) IN ('N', 'NO')
                            THEN 'No'
                        ELSE 'Unknown'
                    END;


/* ============================================================
   07.8 CLEAN TRANSACTION DIMENSION
   ============================================================ */

UPDATE stg_bank_enroll.dbo.dim_transaction
SET
    transaction_type = TRIM(transaction_type);


/* ============================================================
   07.9 STANDARDISE FACT TABLE MONETARY DATA TYPES
   ============================================================ */

ALTER TABLE stg_bank_enroll.dbo.fact_enrollment
ALTER COLUMN credit_limit DECIMAL(18,4);

ALTER TABLE stg_bank_enroll.dbo.fact_enrollment
ALTER COLUMN loan_amount DECIMAL(18,4);

ALTER TABLE stg_bank_enroll.dbo.fact_enrollment
ALTER COLUMN account_balance DECIMAL(18,4);

ALTER TABLE stg_bank_enroll.dbo.fact_enrollment
ALTER COLUMN amount DECIMAL(18,4);


/* ============================================================
   07.10 DATA QUALITY CHECKS ON FACT TABLE
   ============================================================ */

-- Check for negative account balances

SELECT *
FROM stg_bank_enroll.dbo.fact_enrollment
WHERE account_balance < 0;


-- Check for negative credit limits

SELECT *
FROM stg_bank_enroll.dbo.fact_enrollment
WHERE credit_limit < 0;


-- Check for negative loan amounts

SELECT *
FROM stg_bank_enroll.dbo.fact_enrollment
WHERE loan_amount < 0;


-- Check for missing dimension keys

SELECT *
FROM stg_bank_enroll.dbo.fact_enrollment
WHERE customer_key IS NULL
   OR account_key IS NULL
   OR channel_key IS NULL
   OR location_key IS NULL
   OR date_key IS NULL
   OR event_key IS NULL
   OR interaction_key IS NULL
   OR transaction_key IS NULL;


/* ============================================================
   07.11 CHECK FOR DUPLICATE CUSTOMERS
   ============================================================ */

SELECT
    client_number,
    COUNT(*) AS customer_count
FROM stg_bank_enroll.dbo.dim_customer
GROUP BY client_number
HAVING COUNT(*) > 1;


/* ============================================================
   07.12 CHECK FOR DUPLICATE ACCOUNTS
   ============================================================ */

SELECT
    account_number,
    COUNT(*) AS account_count
FROM stg_bank_enroll.dbo.dim_account
GROUP BY account_number
HAVING COUNT(*) > 1;


/* ============================================================
   07.13 FINAL CHECK OF CLEANED STAGING TABLES
   ============================================================ */

SELECT TOP 500 *
FROM stg_bank_enroll.dbo.dim_customer;

SELECT TOP 500 *
FROM stg_bank_enroll.dbo.dim_account;

SELECT TOP 500 *
FROM stg_bank_enroll.dbo.dim_channel;

SELECT TOP 500 *
FROM stg_bank_enroll.dbo.dim_location;

SELECT TOP 500 *
FROM stg_bank_enroll.dbo.dim_date;

SELECT TOP 500 *
FROM stg_bank_enroll.dbo.dim_event;

SELECT TOP 500 *
FROM stg_bank_enroll.dbo.dim_interaction;

SELECT TOP 500 *
FROM stg_bank_enroll.dbo.dim_transaction;

SELECT TOP 500 *
FROM stg_bank_enroll.dbo.fact_enrollment;