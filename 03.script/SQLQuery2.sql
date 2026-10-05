---08.CREATE DIMENSION AND FACT TABLES IN THE DATAWAREHOUSE

-- 08.1 Customer Dimension
CREATE TABLE dwh_bank_enroll.dbo.dim_customer
(
    customer_key    INT IDENTITY(1,1) PRIMARY KEY,
    client_number   VARCHAR(250),
    first_name      VARCHAR(250),
    last_name       VARCHAR(250),
    email           VARCHAR(250),
    mobile_number   VARCHAR(250),
    date_of_birth   DATE,
    gender          VARCHAR(250)
);


-- 08.2 Account Dimension
CREATE TABLE dwh_bank_enroll.dbo.dim_account
(
    account_key     INT IDENTITY(5,5) PRIMARY KEY,
    account_number  VARCHAR(250),
    product_type    VARCHAR(250),
    account_status  VARCHAR(250)
);


-- 08.3 Channel Dimension
CREATE TABLE dwh_bank_enroll.dbo.dim_channel
(
    channel_key INT IDENTITY(2,2) PRIMARY KEY,
    channnel     VARCHAR(250)
);


-- 08.4 Location Dimension
CREATE TABLE dwh_bank_enroll.dbo.dim_location
(
    location_key INT IDENTITY(10,10) PRIMARY KEY,
    province     VARCHAR(250),
    city         VARCHAR(250)
);


-- 08.5 Date Dimension
CREATE TABLE dwh_bank_enroll.dbo.dim_date
(
    date_key    INT IDENTITY(20,20) PRIMARY KEY,
    signup_date DATE,
    event_date  DATE
);


-- 08.6 Event Dimension
CREATE TABLE dwh_bank_enroll.dbo.dim_event
(
    event_key   INT IDENTITY(40,40) PRIMARY KEY,
    event_type  VARCHAR(250)
);


-- 08.7 Interaction Dimension
CREATE TABLE dwh_bank_enroll.dbo.dim_interaction
(
    interaction_key  INT IDENTITY(50,50) PRIMARY KEY,
    interaction_type VARCHAR(250),
    resolved_flag    VARCHAR(250)
);


-- 08.8 Transaction Dimension
CREATE TABLE dwh_bank_enroll.dbo.dim_transaction
(
    transaction_key INT IDENTITY(100,100) PRIMARY KEY,
    transaction_type VARCHAR(250)
);


-- 08.9 Enrollment Fact
CREATE TABLE dwh_bank_enroll.dbo.fact_enrollment
(
    enrollment_key  INT IDENTITY(1000,5) PRIMARY KEY,

    customer_key    INT,
    account_key     INT,
    channel_key     INT,
    location_key    INT,
    date_key        INT,
    event_key       INT,
    interaction_key INT,
    transaction_key INT,

    credit_limit    INT,
    loan_amount     INT,
    account_balance INT,
    amount          INT,

    CONSTRAINT fk_customers
        FOREIGN KEY (customer_key)
        REFERENCES dwh_bank_enroll.dbo.dim_customer (customer_key),

    CONSTRAINT fk_account
        FOREIGN KEY (account_key)
        REFERENCES dwh_bank_enroll.dbo.dim_account (account_key),

    CONSTRAINT fk_channel
        FOREIGN KEY (channel_key)
        REFERENCES dwh_bank_enroll.dbo.dim_channel (channel_key),

    CONSTRAINT fk_location
        FOREIGN KEY (location_key)
        REFERENCES dwh_bank_enroll.dbo.dim_location (location_key),

    CONSTRAINT fk_date
        FOREIGN KEY (date_key)
        REFERENCES dwh_bank_enroll.dbo.dim_date (date_key),

    CONSTRAINT fk_event
        FOREIGN KEY (event_key)
        REFERENCES dwh_bank_enroll.dbo.dim_event (event_key),

    CONSTRAINT fk_interaction
        FOREIGN KEY (interaction_key)
        REFERENCES dwh_bank_enroll.dbo.dim_interaction (interaction_key),

    CONSTRAINT fk_transaction
        FOREIGN KEY (transaction_key)
        REFERENCES dwh_bank_enroll.dbo.dim_transaction (transaction_key)
);


/* ============================================================
   09. LOAD CLEANED STAGING DATA INTO DATA WAREHOUSE
   ============================================================ */

USE dwh_bank_enroll;
GO

/* ============================================================
   09.1 LOAD CUSTOMER DIMENSION
   ============================================================ */

INSERT INTO dwh_bank_enroll.dbo.dim_customer
(
    client_number,
    first_name,
    last_name,
    email,
    mobile_number,
    gender
)
SELECT DISTINCT
    client_number,
    first_name,
    last_name,
    email,
    mobile_number,
    gender
FROM stg_bank_enroll.dbo.dim_customer AS s
WHERE NOT EXISTS
(
    SELECT 1
    FROM dwh_bank_enroll.dbo.dim_customer AS d
    WHERE d.client_number = s.client_number
);


/* ============================================================
   09.2 LOAD ACCOUNT DIMENSION
   ============================================================ */

INSERT INTO dwh_bank_enroll.dbo.dim_account
(
    account_number,
    product_type,
    account_status
)
SELECT DISTINCT
    account_number,
    product_type,
    account_status
FROM stg_bank_enroll.dbo.dim_account AS s
WHERE NOT EXISTS
(
    SELECT 1
    FROM dwh_bank_enroll.dbo.dim_account AS d
    WHERE d.account_number = s.account_number
);


/* ============================================================
   09.3 LOAD CHANNEL DIMENSION
   ============================================================ */

INSERT INTO dwh_bank_enroll.dbo.dim_channel
(
    channnel
)
SELECT DISTINCT
    channnel
FROM stg_bank_enroll.dbo.dim_channel AS s
WHERE NOT EXISTS
(
    SELECT 1
    FROM dwh_bank_enroll.dbo.dim_channel AS d
    WHERE d.channnel = s.channnel
);


/* ============================================================
   09.4 LOAD LOCATION DIMENSION
   ============================================================ */

INSERT INTO dwh_bank_enroll.dbo.dim_location
(
    province,
    city
)
SELECT DISTINCT
    province,
    city
FROM stg_bank_enroll.dbo.dim_location AS s
WHERE NOT EXISTS
(
    SELECT 1
    FROM dwh_bank_enroll.dbo.dim_location AS d
    WHERE d.province = s.province
      AND d.city = s.city
);


/* ============================================================
   09.5 LOAD DATE DIMENSION
   ============================================================ */

INSERT INTO dwh_bank_enroll.dbo.dim_date
(
    event_date,
    signup_date
)
SELECT DISTINCT
    event_date,
    signup_date
FROM stg_bank_enroll.dbo.dim_date AS s
WHERE NOT EXISTS
(
    SELECT 1
    FROM dwh_bank_enroll.dbo.dim_date AS d
    WHERE d.event_date = s.event_date
      AND d.signup_date = s.signup_date
);


/* ============================================================
   09.6 LOAD EVENT DIMENSION
   ============================================================ */

INSERT INTO dwh_bank_enroll.dbo.dim_event
(
    event_type
)
SELECT DISTINCT
    event_type
FROM stg_bank_enroll.dbo.dim_event AS s
WHERE NOT EXISTS
(
    SELECT 1
    FROM dwh_bank_enroll.dbo.dim_event AS d
    WHERE d.event_type = s.event_type
);


/* ============================================================
   09.7 LOAD INTERACTION DIMENSION
   ============================================================ */

INSERT INTO dwh_bank_enroll.dbo.dim_interaction
(
    interaction_type,
    resolved_flag
)
SELECT DISTINCT
    interaction_type,
    resolved_flag
FROM stg_bank_enroll.dbo.dim_interaction AS s
WHERE NOT EXISTS
(
    SELECT 1
    FROM dwh_bank_enroll.dbo.dim_interaction AS d
    WHERE d.interaction_type = s.interaction_type
      AND d.resolved_flag = s.resolved_flag
);


/* ============================================================
   09.8 LOAD TRANSACTION DIMENSION
   ============================================================ */

INSERT INTO dwh_bank_enroll.dbo.dim_transaction
(
    transaction_type
)
SELECT DISTINCT
    transaction_type
FROM stg_bank_enroll.dbo.dim_transaction AS s
WHERE NOT EXISTS
(
    SELECT 1
    FROM dwh_bank_enroll.dbo.dim_transaction AS d
    WHERE d.transaction_type = s.transaction_type
);


/* ============================================================
   09.9 LOAD FACT ENROLLMENT INTO DATA WAREHOUSE
   ============================================================ */

USE dwh_bank_enroll;
GO

INSERT INTO dwh_bank_enroll.dbo.fact_enrollment
(
    customer_key,
    account_key,
    channel_key,
    location_key,
    date_key,
    event_key,
    interaction_key,
    transaction_key,
    credit_limit,
    loan_amount,
    account_balance,
    amount
)
SELECT
    customer_key,
    account_key,
    channel_key,
    location_key,
    date_key,
    event_key,
    interaction_key,
    transaction_key,
    credit_limit,
    loan_amount,
    account_balance,
    amount
FROM stg_bank_enroll.dbo.fact_enrollment;

---10. Check loaded cleaned data

SELECT TOP 500 *
FROM dwh_bank_enroll.dbo.dim_customer;


SELECT TOP 500 *
FROM dwh_bank_enroll.dbo.dim_account;


SELECT TOP 500 *
FROM dwh_bank_enroll.dbo.dim_channel;


SELECT TOP 500 *
FROM dwh_bank_enroll.dbo.dim_location;


SELECT TOP 500 *
FROM dwh_bank_enroll.dbo.dim_date;


SELECT TOP 500 *
FROM dwh_bank_enroll.dbo.dim_event;


SELECT TOP 500 *
FROM dwh_bank_enroll.dbo.dim_interaction;


SELECT TOP 500 *
FROM dwh_bank_enroll.dbo.dim_transaction;


SELECT TOP 500 *
FROM dwh_bank_enroll.dbo.fact_enrollment;