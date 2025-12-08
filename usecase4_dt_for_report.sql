USE DATABASE HH_DEV;

CREATE OR REPLACE DYNAMIC TABLE GOLD_DB.RAC_VW_POWERBI_CLINICAL
TARGET_LAG = '15 minutes'
WAREHOUSE = DEV_WH
AS
WITH StartEnd AS (
    SELECT 
        TO_DATE('2025-11-03') AS StartDate,
        CURRENT_DATE()        AS EndDate
),

Calendar AS (
    SELECT StartDate AS IncidentDate
    FROM StartEnd
    UNION ALL
    SELECT DATEADD(day, 1, IncidentDate)
    FROM Calendar, StartEnd
    WHERE DATEADD(day, 1, IncidentDate) <= (SELECT EndDate FROM StartEnd)
),

distinct_incclass AS (
    SELECT 'Infection' AS IncClassPrimary
    UNION ALL
    SELECT 'SIRS \\ ' || LongDesc
    FROM GOLD_DB.DIM_ASSAULT_TYPES
    UNION ALL
    SELECT 'Wounds \\ ' || LongDesc
    FROM GOLD_DB.DIM_WOUND_TYPES
    UNION ALL
    SELECT 'Incidents \\ ' || LongDesc
    FROM GOLD_DB.DIM_INCIDENT_TYPES
    WHERE LongDesc NOT IN (
        'Fall/Slip/Trip', 'Other', 'Infection Control', 'Incontinence Associated Dermatitis',
        'Wound / Skin Trauma', 'Pressure Injury', 'Suicidal Ideation', 
        'SIRS Affected Care Recipient', 'Privacy Breach', 'Missed Scheduled Visit / Service',
        'Behaviour', 'Potential SIRS Incident'
    )
    UNION ALL
    SELECT 'MedIncidents \\ ' || LongDesc
    FROM GOLD_DB.DIM_MEDINCIDENT_TYPES
),

distinct_sites AS (
    SELECT 'Ingle Farm' AS Site
),

RiskStrat AS (
    SELECT column1 AS RiskStrat
    FROM VALUES
        ('SAC 1 - Extreme'),
        ('SAC 2 - High'),
        ('SAC 3 - Moderate'),
        ('SAC 4 - Low')
),

AllDateInclass AS (
    SELECT
        c.IncidentDate,
        d.IncClassPrimary,
        s.Site,
        r.RiskStrat
    FROM Calendar c
    CROSS JOIN distinct_incclass d
    CROSS JOIN distinct_sites s
    CROSS JOIN RiskStrat r
),

DATA1 AS (
    SELECT
        Status,
        BaseID,
        Program,
        IncidentDate,
        IncidentTime,
        IncClassPrimary,
        InfType,
        IFF(Site = 'Lealholme (Port Pirie)', 'Port Pirie', Site) AS Site,
        Incident_Location,
        IncidentCount,
        IFF(RiskStrat = 1, 'SAC 1 - Extreme',
        IFF(RiskStrat = 2, 'SAC 2 - High',
        IFF(RiskStrat = 3, 'SAC 3 - Moderate',
        IFF(RiskStrat = 4, 'SAC 4 - Low', NULL)))) AS RiskStrat,
        SIRSIncType,
        SIRSVicPerp,
        Firstname,
        Surname,
        ResidentID,
        Description,
        Detail,
        SIRSIncCat,
        SIRSDegreeHarm
    FROM GOLD_DB.RAC_VW_POWERBI_CLINICAL
)

SELECT
    cte.BaseID,
    'Residential' AS Program,
    a.IncidentDate,
    cte.IncidentTime,
    a.IncClassPrimary,
    cte.InfType,
    a.Site,
    cte.Incident_Location,
    COALESCE(cte.IncidentCount, 0) AS IncidentCount,
    a.RiskStrat,
    cte.SIRSIncType,
    cte.SIRSVicPerp,
    cte.Firstname,
    cte.Surname,
    ct.AccountNum         AS MedicalRecordNo,
    cte.ResidentID        AS eCase_ResidentID,
    cte.Description,
    cte.Detail,
    cte.SIRSIncCat,
    cte.SIRSDEgreeHarm
FROM AllDateInclass a
LEFT JOIN DATA1 cte
    ON  cte.IncidentDate    = a.IncidentDate
    AND cte.IncClassPrimary = a.IncClassPrimary
    AND cte.Site            = a.Site
    AND cte.RiskStrat       = a.RiskStrat
LEFT JOIN GOLD_DB.DIM_CUSTTABLE ct
    ON cte.ResidentID = ct.HHAC_ECASERESIDENTID
ORDER BY
    a.IncidentDate,
    a.IncClassPrimary;


SELECT SYSTEM$SHOW_OAUTH_CLIENT_SECRETS('WORKATO_OAUTH');