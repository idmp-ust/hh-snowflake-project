-- HH_DEV
USE WAREHOUSE DEV_WH;
USE DATABASE HH_DEV;
USE SCHEMA BRONZE_DB;

-- drop table GOLD_DB.DIM_RAC_DT_ECASE_CLINICAL_DATA;
-- select * from GOLD_DB.DIM_RAC_DT_ECASE_CLINICAL_DATA;

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
    UNION ALL
    SELECT 'SIRS \\ ' || LongDesc FROM BRONZE_DB.ECASE_ASSAULT_TYPES_RAW
    UNION ALL
    SELECT 'Wounds \\ ' || LongDesc FROM BRONZE_DB.ECASE_WOUND_TYPES_RAW
    UNION ALL
    SELECT 'Incidents \\ ' || LongDesc FROM BRONZE_DB.ECASE_INCIDENT_TYPES_RAW
    UNION ALL
    SELECT 'MedIncidents \\ ' || LongDesc FROM BRONZE_DB.ECASE_MEDINCIDENT_TYPE_RAW
),

/* Recursive calendar per site */
Calendar AS (
    WITH RECURSIVE c AS (
        SELECT 
            Site,
            StartDate AS IncidentDate
        FROM SiteStartDates

        UNION ALL

        SELECT 
            c.Site,
            DATEADD(day, 1, c.IncidentDate)
        FROM c
        JOIN SiteStartDates s 
            ON c.Site = s.Site
        WHERE DATEADD(day, 1, c.IncidentDate) <= CURRENT_DATE()
    )
    SELECT * FROM c
),

RiskStrat AS (
    SELECT 'SAC 1 - Extreme' AS RiskStrat
    UNION ALL SELECT 'SAC 2 - High'
    UNION ALL SELECT 'SAC 3 - Moderate'
    UNION ALL SELECT 'SAC 4 - Low'
    UNION ALL SELECT 'Undefined'
),

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

/* eCase clinical data (from your conformed dynamic table / view) */
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
        residentStatus
    FROM SILVER_DB.ECASE_RAC_DT_POWERBI_CLINICAL_CONFORMED
),

/* Procura / CUSTTABLE mapping */
procura_data AS (
    SELECT 
        AccountNum,
        CASE 
            WHEN TRY_TO_NUMBER(HHAC_ECASERESIDENTID) IS NULL THEN '999999'
            ELSE HHAC_ECASERESIDENTID
        END AS HHAC_ECASERESIDENTID
    FROM GOLD_DB.DIM_CUSTTABLE      -- <== change to your actual Procura CUSTTABLE table
    WHERE HHAC_ECASERESIDENTID <> ''
)

/* Final output – quoted aliases preserve exact case */
SELECT
    c.Status            AS "Status",
    c.BaseID            AS "BaseID",
    'Residential'       AS "Program",
    a.IncidentDate      AS "IncidentDate",
    c.IncidentTime      AS "IncidentTime",
    a.IncClassPrimary   AS "IncClassPrimary",
    c.InfType           AS "InfType",
    a.Site              AS "Site",
    c.Incident_Location AS "Incident_Location",
    COALESCE(c.IncidentCount, 0) AS "IncidentCount",
    a.RiskStrat         AS "RiskStrat",
    c.SIRSIncType       AS "SIRSIncType",
    c.SIRSVicPerp       AS "SIRSVicPerp",
    c.Firstname         AS "Firstname",
    c.Surname           AS "Surname",
    ct.AccountNum       AS "MedicalRecordNo",
    c.ResidentID        AS "eCase_ResidentID",
    c.Description       AS "Description",
    c.Detail            AS "Detail",
    c.SIRSIncCat        AS "SIRSIncCat",
    c.SIRSDegreeHarm    AS "SIRSDEgreeHarm",  -- keeping your original final name
    CURRENT_TIMESTAMP() AS "LOADED_AT"
FROM AllDateInclass a
LEFT JOIN DATA1 c
    ON c.IncidentDate    = a.IncidentDate
   AND c.IncClassPrimary = a.IncClassPrimary
   AND c.Site            = a.Site
   AND c.RiskStrat       = a.RiskStrat
LEFT JOIN procura_data ct
    ON c.ResidentID = ct.HHAC_ECASERESIDENTID;



