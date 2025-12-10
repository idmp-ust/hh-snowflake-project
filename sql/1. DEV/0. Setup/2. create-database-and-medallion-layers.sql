DROP DATABASE HH_TEST;

SET v_wh = 'DEV_WH';
SET v_db = 'HH_DEV';
SET v_bronze = 'BRONZE_DB';
SET v_silver = 'SILVER_DB';
SET v_gold = 'GOLD_DB';

-- SELECT $v_wh, $v_db, $v_bronze;

USE WAREHOUSE IDENTIFIER($v_wh);

-- Create Database
CREATE DATABASE IF NOT EXISTS HH_TEST
    DATA_RETENTION_TIME_IN_DAYS = 1
    COMMENT = 'Testing environment with masked data';

SET v_sql = 'CREATE DATABASE IF NOT EXISTS ' || $v_db ||
            ' DATA_RETENTION_TIME_IN_DAYS = 1 COMMENT = ''Testing environment with masked data'' ';

EXECUTE IMMEDIATE $v_sql;


-- Bronze Layer Schemas
SET v_bronze_sql = 
      'CREATE SCHEMA IF NOT EXISTS ' || $v_bronze || 
      ' COMMENT = ''Raw data ingestion layer - append-only, full history'' ';

EXECUTE IMMEDIATE $v_bronze_sql;

-- Silver Layer Schemas
SET v_silver_sql =
      'CREATE SCHEMA IF NOT EXISTS ' || $v_silver || 
      ' COMMENT = ''Cleansed, validated, conformed data with SCD Type 2'' ';

EXECUTE IMMEDIATE $v_silver_sql;

-- Gold Layer Schemas by Domain
SET v_gold_sql =
      'CREATE SCHEMA IF NOT EXISTS ' || $v_gold || 
      ' COMMENT = ''Business-ready dimensional models - star schema'' ';

EXECUTE IMMEDIATE $v_gold_sql;

