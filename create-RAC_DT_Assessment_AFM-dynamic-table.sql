-- HH_DEV
USE WAREHOUSE DEV_WH;
USE DATABASE HH_DEV;
USE SCHEMA BRONZE_DB;

SELECT * FROM GOLD_DB.DIM_RAC_DT_ECASE_CLINICAL_DATA;

CREATE OR REPLACE DYNAMIC TABLE GOLD_DB.DIM_RAC_DT_ECASE_CLINICAL_DATA
TARGET_LAG = '5 minutes'
WAREHOUSE = DEV_WH
AS
WITH SiteStartDates AS (
    SELECT 'Ingle Farm' AS Site, TO_DATE('2025-11-03') AS StartDate
    UNION ALL
    SELECT 'Port Pirie', TO_DATE('2025-11-17')
),

distinct_incclass AS (
    SELECT 'Infection' AS IncClassPrimary
    UNION ALL SELECT 'SIRS \\ ' || LongDesc FROM BRONZE_DB.ECASE_ASSAULT_TYPES_RAW
    UNION ALL SELECT 'Wounds \\ ' || LongDesc FROM BRONZE_DB.ECASE_WOUND_TYPES_RAW
    UNION ALL SELECT 'Incidents \\ ' || LongDesc FROM BRONZE_DB.ECASE_INCIDENT_TYPES_RAW
    UNION ALL SELECT 'MedIncidents \\ ' || LongDesc FROM BRONZE_DB.ECASE_MEDINCIDENT_TYPE_RAW
),

/* Snowflake replacement for recursive calendar */
Calendar AS (
    SELECT 
        s.Site,
        DATEADD('day', seq4(), s.StartDate) AS IncidentDate
    FROM SiteStartDates s
    JOIN TABLE(GENERATOR(ROWCOUNT => 2000)) g
    WHERE DATEADD('day', seq4(), s.StartDate) <= CURRENT_DATE()
),

RiskStrat AS (
    SELECT 'SAC 1 - Extreme' AS RiskStrat
    UNION ALL SELECT 'SAC 2 - High'
    UNION ALL SELECT 'SAC 3 - Moderate'
    UNION ALL SELECT 'SAC 4 - Low'
    UNION ALL SELECT 'Undefined'
),

AllDateInclass AS (
    SELECT c.IncidentDate, d.IncClassPrimary, c.Site, r.RiskStrat
    FROM Calendar c
    CROSS JOIN distinct_incclass d
    CROSS JOIN RiskStrat r
),

DATA1 AS (
    SELECT
        Status, BaseID, Program, IncidentDate, IncidentTime,
        IncClassPrimary, InfType,
        CASE WHEN Site = 'Lealholme (Port Pirie)' THEN 'Port Pirie' ELSE Site END AS Site,
        Incident_Location, IncidentCount,
        CASE 
            WHEN RiskStrat = '1' THEN 'SAC 1 - Extreme'
            WHEN RiskStrat = '2' THEN 'SAC 2 - High'
            WHEN RiskStrat = '3' THEN 'SAC 3 - Moderate'
            WHEN RiskStrat = '4' THEN 'SAC 4 - Low'
            ELSE 'Undefined'
        END AS RiskStrat,
        SIRSIncType, SIRSVicPerp, FirstName, Surname, ResidentID,
        Description, Detail, SIRSIncCat, SIRSDegreeHarm,
        ResidentType, ResidentStatus
    FROM SILVER_DB.ECASE_RAC_DT_POWERBI_CLINICAL_CONFORMED
),

procura_data AS (
    SELECT 
        AccountNum,
        CASE 
            /* TRY_TO_NUMBER() = Snowflake safe version of ISNUMERIC() */
            WHEN TRY_TO_NUMBER(HHAC_ECASERESIDENTID) IS NULL THEN '999999'
            ELSE HHAC_ECASERESIDENTID
        END AS HHAC_ECASERESIDENTID
    FROM GOLD_DB.DIM_CUSTTABLE
    WHERE HHAC_ECASERESIDENTID <> ''
)

SELECT 
    c.Status,
    c.BaseID,
    'Residential' AS Program,
    a.IncidentDate,
    c.IncidentTime,
    a.IncClassPrimary,
    c.InfType,
    a.Site,
    c.Incident_Location,
    COALESCE(c.IncidentCount, 0) AS IncidentCount,
    a.RiskStrat,
    c.SIRSIncType,
    c.SIRSVicPerp,
    c.FirstName,
    c.Surname,
    ct.AccountNum AS MedicalRecordNo,
    c.ResidentID AS eCase_ResidentID,
    c.Description,
    c.Detail,
    c.SIRSIncCat,
    c.SIRSDegreeHarm,
    CURRENT_TIMESTAMP() AS LOADED_AT
FROM AllDateInclass a
LEFT JOIN DATA1 c
    ON c.IncidentDate = a.IncidentDate
   AND c.IncClassPrimary = a.IncClassPrimary
   AND c.Site = a.Site
   AND c.RiskStrat = a.RiskStrat
LEFT JOIN procura_data ct
    ON c.ResidentID = ct.HHAC_ECASERESIDENTID;

