-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Phase 1: Account Foundation Setup

-- Step 1: Configure Account Settings
-- Set account-level parameters
USE ROLE ACCOUNTADMIN;

ALTER ACCOUNT SET 
    DATA_RETENTION_TIME_IN_DAYS = 1  -- Dev/Test: 1 day (per Section 6.3)
    -- NETWORK_POLICY = <your_policy>   -- Optional: IP whitelisting
;

-- Enable required features
ALTER ACCOUNT SET 
    -- Allow any supported region (recommended for maximum flexibility)
    CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION'  -- For AI features
;


-- Step 2: Configure SSO/OAuth (if applicable)
--  TODO Later
-- Create security integration for Azure AD SSO (per Section 11.1)
-- CREATE SECURITY INTEGRATION azure_ad_sso
--     TYPE = SAML2
--     ENABLED = TRUE
--     SAML2_ISSUER = 'https://sts.windows.net/<tenant-id>/'
--     SAML2_SSO_URL = 'https://login.microsoftonline.com/<tenant-id>/saml2'
--     SAML2_PROVIDER = 'CUSTOM'
--     SAML2_X509_CERT = '<certificate>'
-- ;

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Phase 2: Create Role Hierarchy (RBAC)

-- Step 3: Create Functional Roles (per Section 7.1 & Appendix D Step 2)
USE ROLE SECURITYADMIN;

-- Admin Roles
CREATE ROLE IF NOT EXISTS DATA_ENGINEER_ROLE 
    COMMENT = 'Full access to Dev/Test databases, dbt models, pipelines';
    
CREATE ROLE IF NOT EXISTS DEVELOPER_ROLE 
    COMMENT = 'Dev database access only with masked data';

-- Governance Roles
CREATE ROLE IF NOT EXISTS DATA_STEWARD_ROLE 
    COMMENT = 'Read access to all layers, manage quarantine, quality monitoring';

-- Consumption Roles (for Dev/Test)
CREATE ROLE IF NOT EXISTS CLINICAL_ANALYST_DEV_ROLE 
    COMMENT = 'Read Gold layer in Dev/Test for clinical analytics';
    
CREATE ROLE IF NOT EXISTS ANALYST_ROLE 
    COMMENT = 'Read Gold layer for general analytics';

-- Role Hierarchy
GRANT ROLE DATA_ENGINEER_ROLE TO ROLE SYSADMIN;
GRANT ROLE DATA_STEWARD_ROLE TO ROLE SYSADMIN;
GRANT ROLE DEVELOPER_ROLE TO ROLE SYSADMIN;
GRANT ROLE CLINICAL_ANALYST_DEV_ROLE TO ROLE SYSADMIN;
GRANT ROLE ANALYST_ROLE TO ROLE SYSADMIN;

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Phase 3: Create Database & Schema Structure

-- Step 4: Create Dev/Test Database

USE ROLE SYSADMIN;

-- Create HH_DEV Database
CREATE DATABASE IF NOT EXISTS HH_DEV
    DATA_RETENTION_TIME_IN_DAYS = 1  -- Dev/Test: 1 day
    COMMENT = 'Development environment with masked data';

-- Create HH_TEST Database (optional - or use HH_DEV for both)
CREATE DATABASE IF NOT EXISTS HH_TEST
    DATA_RETENTION_TIME_IN_DAYS = 1
    COMMENT = 'Testing environment with masked data';

-- Step 5: Create Medallion Architecture Schemas
USE DATABASE HH_DEV;
USE DATABASE HH_TEST;

-- Bronze Layer Schemas
CREATE SCHEMA IF NOT EXISTS BRONZE_DB 
    COMMENT = 'Raw data ingestion layer - append-only, full history';

CREATE SCHEMA IF NOT EXISTS BRONZE_QUARANTINE 
    COMMENT = 'Failed Bronze records for Data Steward review';

-- Silver Layer Schemas
CREATE SCHEMA IF NOT EXISTS SILVER_DB 
    COMMENT = 'Cleansed, validated, conformed data with SCD Type 2';

CREATE SCHEMA IF NOT EXISTS SILVER_QUARANTINE 
    COMMENT = 'Failed Silver records for Data Steward review';

-- Gold Layer Schemas by Domain
CREATE SCHEMA IF NOT EXISTS GOLD_DB 
    COMMENT = 'Business-ready dimensional models - star schema';

-- CREATE SCHEMA IF NOT EXISTS GOLD_CLINICAL 
--     COMMENT = 'Clinical KPIs, care classifications, incidents';
    
-- CREATE SCHEMA IF NOT EXISTS GOLD_WORKFORCE 
--     COMMENT = 'Employee, staffing, payroll analytics';
    
-- CREATE SCHEMA IF NOT EXISTS GOLD_FINANCIAL 
--     COMMENT = 'Financial reporting, QFR/ACFR data';
    
-- CREATE SCHEMA IF NOT EXISTS GOLD_OPERATIONAL 
--     COMMENT = 'Facilities, occupancy, capacity management';

-- Metadata/Governance Schema
CREATE SCHEMA IF NOT EXISTS GOVERNANCE 
    COMMENT = 'Data quality logs, audit tables, DMF results';

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Phase 4: Create Warehouses

-- Step 6: Create Compute Warehouses
USE ROLE SYSADMIN;

-- Dev Warehouse (X-Small for development)
CREATE WAREHOUSE IF NOT EXISTS DEV_WH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 300  -- 5 minutes
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Development warehouse with 5-min auto-suspend';

-- ETL Warehouse (Small for Dev/Test - not Large like Production)
CREATE WAREHOUSE IF NOT EXISTS ETL_DEV_WH
    WAREHOUSE_SIZE = 'SMALL'
    AUTO_SUSPEND = 600  -- 10 minutes
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'ETL processing for Bronze→Silver transformations in Dev';

-- Transform Warehouse (X-Small for Dev/Test)
CREATE WAREHOUSE IF NOT EXISTS TRANSFORM_DEV_WH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 600  -- 10 minutes
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Silver→Gold dbt transformations in Dev';

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Phase 5: Grant Privileges to Roles

-- Step 7: Grant Database & Schema Privileges
USE ROLE SYSADMIN;

-- DATA_ENGINEER_ROLE: Full access to all schemas
GRANT USAGE ON DATABASE HH_DEV TO ROLE DATA_ENGINEER_ROLE;
GRANT USAGE ON ALL SCHEMAS IN DATABASE HH_DEV TO ROLE DATA_ENGINEER_ROLE;
GRANT CREATE SCHEMA ON DATABASE HH_DEV TO ROLE DATA_ENGINEER_ROLE;

GRANT ALL PRIVILEGES ON ALL TABLES IN DATABASE HH_DEV TO ROLE DATA_ENGINEER_ROLE;
GRANT ALL PRIVILEGES ON ALL VIEWS IN DATABASE HH_DEV TO ROLE DATA_ENGINEER_ROLE;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN DATABASE HH_DEV TO ROLE DATA_ENGINEER_ROLE;
GRANT ALL PRIVILEGES ON FUTURE VIEWS IN DATABASE HH_DEV TO ROLE DATA_ENGINEER_ROLE;

-- DATA_STEWARD_ROLE: Read all, Write quarantine only
GRANT USAGE ON DATABASE HH_DEV TO ROLE DATA_STEWARD_ROLE;
GRANT USAGE ON ALL SCHEMAS IN DATABASE HH_DEV TO ROLE DATA_STEWARD_ROLE;

GRANT SELECT ON ALL TABLES IN DATABASE HH_DEV TO ROLE DATA_STEWARD_ROLE;
GRANT SELECT ON ALL VIEWS IN DATABASE HH_DEV TO ROLE DATA_STEWARD_ROLE;
GRANT SELECT ON FUTURE TABLES IN DATABASE HH_DEV TO ROLE DATA_STEWARD_ROLE;
GRANT SELECT ON FUTURE VIEWS IN DATABASE HH_DEV TO ROLE DATA_STEWARD_ROLE;

-- Write access to quarantine schemas for Data Stewards
GRANT ALL PRIVILEGES ON SCHEMA HH_DEV.BRONZE_QUARANTINE TO ROLE DATA_STEWARD_ROLE;
GRANT ALL PRIVILEGES ON SCHEMA HH_DEV.SILVER_QUARANTINE TO ROLE DATA_STEWARD_ROLE;

-- ANALYST_ROLE: Read Gold layer only
GRANT USAGE ON DATABASE HH_DEV TO ROLE ANALYST_ROLE;
GRANT USAGE ON SCHEMA HH_DEV.GOLD_DB TO ROLE ANALYST_ROLE;
GRANT USAGE ON SCHEMA HH_DEV.GOLD_CLINICAL TO ROLE ANALYST_ROLE;
GRANT USAGE ON SCHEMA HH_DEV.GOLD_WORKFORCE TO ROLE ANALYST_ROLE;
GRANT USAGE ON SCHEMA HH_DEV.GOLD_FINANCIAL TO ROLE ANALYST_ROLE;
GRANT USAGE ON SCHEMA HH_DEV.GOLD_OPERATIONAL TO ROLE ANALYST_ROLE;

GRANT SELECT ON ALL TABLES IN SCHEMA HH_DEV.GOLD_DB TO ROLE ANALYST_ROLE;
GRANT SELECT ON ALL VIEWS IN SCHEMA HH_DEV.GOLD_DB TO ROLE ANALYST_ROLE;
GRANT SELECT ON FUTURE TABLES IN SCHEMA HH_DEV.GOLD_DB TO ROLE ANALYST_ROLE;
GRANT SELECT ON FUTURE VIEWS IN SCHEMA HH_DEV.GOLD_DB TO ROLE ANALYST_ROLE;

-- Repeat for other GOLD schemas...

-- Step 8: Grant Warehouse Privileges
-- DATA_ENGINEER_ROLE: All warehouses
GRANT USAGE ON WAREHOUSE DEV_WH TO ROLE DATA_ENGINEER_ROLE;
GRANT USAGE ON WAREHOUSE ETL_DEV_WH TO ROLE DATA_ENGINEER_ROLE;
GRANT USAGE ON WAREHOUSE TRANSFORM_DEV_WH TO ROLE DATA_ENGINEER_ROLE;

-- DATA_STEWARD_ROLE: Dev warehouse only
GRANT USAGE ON WAREHOUSE DEV_WH TO ROLE DATA_STEWARD_ROLE;

-- ANALYST_ROLE: Dev warehouse only
GRANT USAGE ON WAREHOUSE DEV_WH TO ROLE ANALYST_ROLE;

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Phase 6: Implement Data Classification & Tagging

-- Step 9: Create Classification Tags
USE ROLE ACCOUNTADMIN;

-- Create tag schema
CREATE SCHEMA IF NOT EXISTS HH_DEV.TAGS 
    COMMENT = 'Centralized tag definitions for governance';

-- Classification Tags
CREATE TAG IF NOT EXISTS HH_DEV.TAGS.CLASSIFICATION
    ALLOWED_VALUES 'PUBLIC', 'INTERNAL', 'CONFIDENTIAL'
    COMMENT = 'Data sensitivity classification';

-- Privacy Tags
CREATE TAG IF NOT EXISTS HH_DEV.TAGS.PRIVACY_CATEGORY
    ALLOWED_VALUES 'PII', 'PHI', 'NON_SENSITIVE'
    COMMENT = 'Privacy classification for PII/PHI protection';

-- Domain Tags
CREATE TAG IF NOT EXISTS HH_DEV.TAGS.DATA_DOMAIN
    ALLOWED_VALUES 'CLINICAL', 'WORKFORCE', 'FINANCIAL', 'OPERATIONAL', 'RESIDENT'
    COMMENT = 'Business domain ownership';

-- Grant tag privileges
GRANT APPLY ON TAG HH_DEV.TAGS.CLASSIFICATION TO ROLE DATA_ENGINEER_ROLE;
GRANT APPLY ON TAG HH_DEV.TAGS.PRIVACY_CATEGORY TO ROLE DATA_ENGINEER_ROLE;
GRANT APPLY ON TAG HH_DEV.TAGS.DATA_DOMAIN TO ROLE DATA_ENGINEER_ROLE;

-- Dropped these SCHEMAS
USE ROLE ACCOUNTADMIN;
DROP SCHEMA HH_DEV.GOLD_CLINICAL;
DROP SCHEMA HH_DEV.GOLD_WORKFORCE;
DROP SCHEMA HH_DEV.GOLD_FINANCIAL;
DROP SCHEMA HH_DEV.GOLD_OPERATIONAL;

-- Mahtab and Neil EXECUTED ABOVE on 11 Nov 2025 - 1:20 pm
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Phase 7: Create Sample Tables (Example)
-- Step 10: Create Bronze Layer Example
USE ROLE DATA_ENGINEER_ROLE;
-- 
USE DATABASE HH_DEV;
USE SCHEMA BRONZE_DB;
USE WAREHOUSE DEV_WH;

-- Example Bronze table for eCase residents
CREATE TABLE IF NOT EXISTS ECASE_RESIDENTS_RAW (
    SOURCE_SYSTEM VARCHAR(50),
    SOURCE_ID VARCHAR(100),
    RAW_PAYLOAD VARIANT,  -- JSON payload
    _INGESTION_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _LOAD_DATE DATE DEFAULT CURRENT_DATE()
)
CLUSTER BY (_LOAD_DATE)
COMMENT = 'Raw eCase resident data - append-only';

-- Apply tags
ALTER TABLE ECASE_RESIDENTS_RAW 
    SET TAG HH_DEV.TAGS.CLASSIFICATION = 'CONFIDENTIAL',
        HH_DEV.TAGS.DATA_DOMAIN = 'RESIDENT';