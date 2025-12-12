-- HH_DEV
USE WAREHOUSE DEV_WH;
USE DATABASE HH_TEST;
USE SCHEMA BRONZE_DB;

-- SELECT COUNT(*) FROM GOLD_DB.DIM_RAC_DT_ECASE_CLINICAL_DATA;
-- DROP TABLE GOLD_DB.DIM_RAC_DT_ECASE_CLINICAL_DATA;

CREATE OR REPLACE DYNAMIC TABLE GOLD_DB.DIM_RAC_DT_ECASE_CLINICAL_DATA
    TARGET_LAG = '5 minutes'
    WAREHOUSE = DEV_WH
AS
/* ----------------------------------------------------------
   1. SITE START DATES
----------------------------------------------------------- */
WITH SiteStartDates AS (
    SELECT 'Ingle Farm' AS Site, TO_DATE('2025-11-03') AS StartDate
    UNION ALL 
    SELECT 'Port Pirie', TO_DATE('2025-11-17')
),

/* ----------------------------------------------------------
   2. INCIDENT CLASS LIST
----------------------------------------------------------- */
distinct_incclass AS (
    SELECT 'Infection' AS IncClassPrimary
    UNION ALL SELECT 'SIRS \\ ' || LongDesc FROM BRONZE_DB.ECASE_ASSAULT_TYPES_RAW
    UNION ALL SELECT 'Wounds \\ ' || LongDesc FROM BRONZE_DB.ECASE_WOUND_TYPES_RAW
    UNION ALL SELECT 'Incidents \\ ' || LongDesc FROM BRONZE_DB.ECASE_INCIDENT_TYPES_RAW
    UNION ALL SELECT 'MedIncidents \\ ' || LongDesc FROM BRONZE_DB.ECASE_MEDINCIDENT_TYPE_RAW
),

/* ----------------------------------------------------------
   3. RECURSIVE DATE RANGE (FIXED)
----------------------------------------------------------- */
RECURSIVE_CTE AS (
    SELECT Site, StartDate AS IncidentDate
    FROM SiteStartDates

    UNION ALL

    SELECT 
        r.Site,
        DATEADD(day, 1, r.IncidentDate)
    FROM RECURSIVE_CTE r
    WHERE DATEADD(day, 1, r.IncidentDate) <= CURRENT_DATE()
),

Calendar AS (
    SELECT * FROM RECURSIVE_CTE
),

/* ----------------------------------------------------------
   4. RISK STRAT MAPPING
----------------------------------------------------------- */
RiskStrat AS (
    SELECT 'SAC 1 - Extreme' AS RiskStrat
    UNION ALL SELECT 'SAC 2 - High'
    UNION ALL SELECT 'SAC 3 - Moderate'
    UNION ALL SELECT 'SAC 4 - Low'
    UNION ALL SELECT 'Undefined'
),

/* ----------------------------------------------------------
   5. FULL DATE × CLASS × RISK CROSS JOIN
----------------------------------------------------------- */
AllDateInclass AS (
    SELECT 
        c.IncidentDate,
        d.IncClassPrimary,
        c.Site,
        r.RiskStrat
    FROM Calendar c
    CROSS JOIN distinct_incclass d
    CROSS JOIN RiskStrat r
),

/* ----------------------------------------------------------
   6. CLINICAL CONFORMED DATA
----------------------------------------------------------- */
DATA1 AS (
    SELECT 
        Status,
        BaseID,
        Program,
        IncidentDate,
        IncidentTime,
        IncClassPrimary,
        InfType,
        CASE 
            WHEN Site = 'Lealholme (Port Pirie)' THEN 'Port Pirie'
            ELSE Site
        END AS Site,
        Incident_Location,
        IncidentCount,
        CASE 
            WHEN RiskStrat = '1' THEN 'SAC 1 - Extreme'
            WHEN RiskStrat = '2' THEN 'SAC 2 - High'
            WHEN RiskStrat = '3' THEN 'SAC 3 - Moderate'
            WHEN RiskStrat = '4' THEN 'SAC 4 - Low'
            ELSE 'Undefined'
        END AS RiskStrat,
        SIRSIncType,
        SIRSVicPerp,
        Firstname,
        Surname,
        ResidentID,
        Description,
        Detail,
        SIRSIncCat,
        SIRSDegreeHarm,
        ResidentType,
        ResidentStatus
    FROM SILVER_DB.ECASE_RAC_DT_POWERBI_CLINICAL_CONFORMED
),

/* ----------------------------------------------------------
   7. PROCURA MAPPING (VALIDATE KEY EXISTS)
----------------------------------------------------------- */
procura_data AS (
    SELECT 
        AccountNum,
        TRY_TO_NUMBER(HHAC_ECASERESIDENTID) AS ResidentID_Key
    FROM GOLD_DB.DIM_CUSTTABLE
    WHERE HHAC_ECASERESIDENTID IS NOT NULL 
          AND HHAC_ECASERESIDENTID <> ''
)

/* ----------------------------------------------------------
   8. FINAL OUTPUT (POWER BI FRIENDLY)
----------------------------------------------------------- */
SELECT
    c.Status             AS "Status",
    c.BaseID             AS "BaseID",
    'Residential'        AS "Program",
    a.IncidentDate       AS "IncidentDate",
    c.IncidentTime       AS "IncidentTime",
    a.IncClassPrimary    AS "IncClassPrimary",
    c.InfType            AS "InfType",
    a.Site               AS "Site",
    c.Incident_Location  AS "Incident_Location",
    COALESCE(c.IncidentCount, 0) AS "IncidentCount",
    a.RiskStrat          AS "RiskStrat",
    c.SIRSIncType        AS "SIRSIncType",
    c.SIRSVicPerp        AS "SIRSVicPerp",
    c.Firstname          AS "Firstname",
    c.Surname            AS "Surname",
    ct.AccountNum        AS "MedicalRecordNo",
    c.ResidentID         AS "eCase_ResidentID",
    c.Description        AS "Description",
    c.Detail             AS "Detail",
    c.SIRSIncCat         AS "SIRSIncCat",
    c.SIRSDegreeHarm     AS "SIRSDegreeHarm"
FROM AllDateInclass a
LEFT JOIN DATA1 c
    ON c.IncidentDate    = a.IncidentDate
   AND c.IncClassPrimary = a.IncClassPrimary
   AND c.Site            = a.Site
   AND c.RiskStrat       = a.RiskStrat
LEFT JOIN procura_data ct
    ON c.ResidentID = ct.ResidentID_Key;
