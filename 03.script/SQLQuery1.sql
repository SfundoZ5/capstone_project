/* ============================================================
   01. CREATE STAGING AND DATA WAREHOUSE DATABASES
   ============================================================ */

CREATE DATABASE stg_bank_enroll;
CREATE DATABASE dwh_bank_enroll;


/* ============================================================
   02. CREATE DIMENSION AND FACT TABLES
       IN THE STAGING DATABASE
   ============================================================ */

-- 02.1 Customer Dimension
CREATE TABLE stg_bank_enroll.dbo.dim_customer
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


-- 02.2 Account Dimension
CREATE TABLE stg_bank_enroll.dbo.dim_account
(
    account_key     INT IDENTITY(5,5) PRIMARY KEY,
    account_number  VARCHAR(250),
    product_type    VARCHAR(250),
    account_status  VARCHAR(250)
);


-- 02.3 Channel Dimension
CREATE TABLE stg_bank_enroll.dbo.dim_channel
(
    channel_key INT IDENTITY(2,2) PRIMARY KEY,
    channnel     VARCHAR(250)
);


-- 02.4 Location Dimension
CREATE TABLE stg_bank_enroll.dbo.dim_location
(
    location_key INT IDENTITY(10,10) PRIMARY KEY,
    province     VARCHAR(250),
    city         VARCHAR(250)
);


-- 02.5 Date Dimension
CREATE TABLE stg_bank_enroll.dbo.dim_date
(
    date_key    INT IDENTITY(20,20) PRIMARY KEY,
    signup_date DATE,
    event_date  DATE
);


-- 02.6 Event Dimension
CREATE TABLE stg_bank_enroll.dbo.dim_event
(
    event_key   INT IDENTITY(40,40) PRIMARY KEY,
    event_type  VARCHAR(250)
);


-- 02.7 Interaction Dimension
CREATE TABLE stg_bank_enroll.dbo.dim_interaction
(
    interaction_key  INT IDENTITY(50,50) PRIMARY KEY,
    interaction_type VARCHAR(250),
    resolved_flag    VARCHAR(250)
);


-- 02.8 Transaction Dimension
CREATE TABLE stg_bank_enroll.dbo.dim_transaction
(
    transaction_key INT IDENTITY(100,100) PRIMARY KEY,
    transaction_type VARCHAR(250)
);


-- 02.9 Enrollment Fact
CREATE TABLE stg_bank_enroll.dbo.fact_enrollment
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
        REFERENCES stg_bank_enroll.dbo.dim_customer (customer_key),

    CONSTRAINT fk_account
        FOREIGN KEY (account_key)
        REFERENCES stg_bank_enroll.dbo.dim_account (account_key),

    CONSTRAINT fk_channel
        FOREIGN KEY (channel_key)
        REFERENCES stg_bank_enroll.dbo.dim_channel (channel_key),

    CONSTRAINT fk_location
        FOREIGN KEY (location_key)
        REFERENCES stg_bank_enroll.dbo.dim_location (location_key),

    CONSTRAINT fk_date
        FOREIGN KEY (date_key)
        REFERENCES stg_bank_enroll.dbo.dim_date (date_key),

    CONSTRAINT fk_event
        FOREIGN KEY (event_key)
        REFERENCES stg_bank_enroll.dbo.dim_event (event_key),

    CONSTRAINT fk_interaction
        FOREIGN KEY (interaction_key)
        REFERENCES stg_bank_enroll.dbo.dim_interaction (interaction_key),

    CONSTRAINT fk_transaction
        FOREIGN KEY (transaction_key)
        REFERENCES stg_bank_enroll.dbo.dim_transaction (transaction_key)
);


/* ============================================================
   03. LOAD DATA INTO DIMENSION TABLES
   ============================================================ */

-- 03.1 Load Customer Dimension
INSERT INTO stg_bank_enroll.dbo.dim_customer
(
    client_number,
    first_name,
    last_name,
    email,
    mobile_number,
    date_of_birth,
    gender
)
SELECT DISTINCT
    client_number,
    first_name,
    last_name,
    email,
    mobile_number,
    date_of_birth,
    gender
FROM stg_bank_enroll.dbo.activity_extract;


-- 03.2 Load Account Dimension
INSERT INTO stg_bank_enroll.dbo.dim_account
(
    account_number,
    product_type,
    account_status
)
SELECT DISTINCT
    account_number,
    product_type,
    account_status
FROM stg_bank_enroll.dbo.activity_extract;


-- 03.3 Load Channel Dimension
INSERT INTO stg_bank_enroll.dbo.dim_channel
(
    channnel
)
SELECT DISTINCT
    channel
FROM stg_bank_enroll.dbo.activity_extract;


-- 03.4 Load Location Dimension
INSERT INTO stg_bank_enroll.dbo.dim_location
(
    province,
    city
)
SELECT DISTINCT
    province,
    city
FROM stg_bank_enroll.dbo.activity_extract;


-- 03.5 Load Date Dimension
INSERT INTO stg_bank_enroll.dbo.dim_date
(
    signup_date,
    event_date
)
SELECT DISTINCT
    signup_date,
    event_date
FROM stg_bank_enroll.dbo.activity_extract;


-- 03.6 Load Event Dimension
INSERT INTO stg_bank_enroll.dbo.dim_event
(
    event_type
)
SELECT DISTINCT
    event_type
FROM stg_bank_enroll.dbo.activity_extract;


-- 03.7 Load Interaction Dimension
INSERT INTO stg_bank_enroll.dbo.dim_interaction
(
    interaction_type,
    resolved_flag
)
SELECT DISTINCT
    interaction_type,
    resolved_flag
FROM stg_bank_enroll.dbo.activity_extract;


-- 03.8 Load Transaction Dimension
INSERT INTO stg_bank_enroll.dbo.dim_transaction
(
    transaction_type
)
SELECT DISTINCT
    transaction_type
FROM stg_bank_enroll.dbo.activity_extract;


/* ============================================================
   04. ALTER FACT TABLE DATA TYPES
   ============================================================ */

ALTER TABLE stg_bank_enroll.dbo.fact_enrollment
ALTER COLUMN account_balance DECIMAL(18,4);

ALTER TABLE stg_bank_enroll.dbo.fact_enrollment
ALTER COLUMN amount DECIMAL(18,4);


/* ============================================================
   05. LOAD DATA INTO FACT TABLE
   ============================================================ */

INSERT INTO stg_bank_enroll.dbo.fact_enrollment
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
SELECT DISTINCT
    c.customer_key,
    a.account_key,
    h.channel_key,
    l.location_key,
    d.date_key,
    e.event_key,
    i.interaction_key,
    t.transaction_key,
    RWSTG.credit_limit,
    RWSTG.loan_amount,
    RWSTG.account_balance,
    RWSTG.amount
FROM stg_bank_enroll.dbo.activity_extract AS RWSTG

LEFT JOIN stg_bank_enroll.dbo.dim_customer AS c
    ON RWSTG.client_number = c.client_number

LEFT JOIN stg_bank_enroll.dbo.dim_account AS a
    ON RWSTG.account_number = a.account_number

LEFT JOIN stg_bank_enroll.dbo.dim_channel AS h
    ON RWSTG.channel = h.channnel

LEFT JOIN stg_bank_enroll.dbo.dim_location AS l
    ON RWSTG.province = l.province
    AND RWSTG.city = l.city

LEFT JOIN stg_bank_enroll.dbo.dim_date AS d
    ON RWSTG.signup_date = d.signup_date
    AND RWSTG.event_date = d.event_date

LEFT JOIN stg_bank_enroll.dbo.dim_event AS e
    ON RWSTG.event_type = e.event_type

LEFT JOIN stg_bank_enroll.dbo.dim_interaction AS i
    ON RWSTG.interaction_type = i.interaction_type
    AND RWSTG.resolved_flag = i.resolved_flag

LEFT JOIN stg_bank_enroll.dbo.dim_transaction AS t
    ON RWSTG.transaction_type = t.transaction_type;


/* ============================================================
   06. CHECK LOADED DATA
   ============================================================ */

-- 06.1 Customer Dimension
SELECT TOP 500 *
FROM stg_bank_enroll.dbo.dim_customer;


-- 06.2 Account Dimension
SELECT TOP 500 *
FROM stg_bank_enroll.dbo.dim_account;


-- 06.3 Channel Dimension
SELECT TOP 500 *
FROM stg_bank_enroll.dbo.dim_channel;


-- 06.4 Location Dimension
SELECT TOP 500 *
FROM stg_bank_enroll.dbo.dim_location;


-- 06.5 Date Dimension
SELECT TOP 500 *
FROM stg_bank_enroll.dbo.dim_date;


-- 06.6 Event Dimension
SELECT TOP 500 *
FROM stg_bank_enroll.dbo.dim_event;


-- 06.7 Interaction Dimension
SELECT TOP 500 *
FROM stg_bank_enroll.dbo.dim_interaction;


-- 06.8 Transaction Dimension
SELECT TOP 500 *
FROM stg_bank_enroll.dbo.dim_transaction;


-- 06.9 Enrollment Fact
SELECT TOP 500 *
FROM stg_bank_enroll.dbo.fact_enrollment;