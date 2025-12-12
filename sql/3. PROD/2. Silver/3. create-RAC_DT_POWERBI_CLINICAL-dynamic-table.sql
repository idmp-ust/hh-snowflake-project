-- HH_DEV
USE WAREHOUSE DEV_WH;
USE DATABASE HH_DEV;
USE SCHEMA BRONZE_DB;


CREATE OR REPLACE DYNAMIC TABLE SILVER_DB.ECASE_RAC_DT_POWERBI_CLINICAL_CONFORMED
TARGET_LAG = '5 minutes'
WAREHOUSE = DEV_WH
AS
WITH resident AS (
    SELECT DISTINCT
        R.ID AS ResidentID,
        CASE
            WHEN R.Inactive = 0 THEN 'Active'
            WHEN R.Inactive = -1 THEN 'Inactive'
            ELSE 'NonResident'
        END AS ResidentStatus,
        R.FirstName,
        R.LastName,
        rt.TypeName AS ResidentType,
        rw.FacilityName,
        rw.Wing,
        rw.Room,
        rw.Bed,
        rw.BedID
    FROM BRONZE_DB.ECASE_RESIDENT_FAC_RAW AS R
    LEFT JOIN SILVER_DB.ECASE_RWRB_CONFORMED AS rw 
        ON R.ID = rw.ResidentID
    LEFT JOIN BRONZE_DB.ECASE_RESIDENT_TYPE_RAW AS rt 
        ON R.ResidentTypeID = rt.ID
),

DATA1 AS (

    /* ------------------ INFECTIONS ------------------ */
    SELECT
        CASE 
            WHEN I.Status = 0 OR I.Status IS NULL THEN 'Open'
            WHEN I.Status = 1 THEN 'Closed'
            ELSE 'Unknown'
        END AS Status,
        'INFECTION_' || I.ID AS BaseID,
        'Residential' AS Program,
        TO_DATE(I.CommencementDate) AS IncidentDate,
        TO_TIMESTAMP_NTZ('1900-01-01 12:00:00') AS IncidentTime,
        'Infection' AS IncClassPrimary,
        CASE 
            WHEN LongDesc = 'Ear Infection' THEN 'Ear'
            WHEN LongDesc = 'Eye Infection' THEN 'Eye'
            WHEN LongDesc = 'Gastrointestinal Infection' THEN 'Gastrointestinal'
            WHEN LongDesc = 'Oral Infection' THEN 'Oral'
            WHEN LongDesc = 'Multi Resistant Organism (eg. MRSA, VRE, ESBL, MSSA, C.difficile, MRGN)' THEN LongDesc
            WHEN LongDesc = 'Respiratory Tract Infection' THEN 'Respiratory Tract'
            WHEN LongDesc = 'Septicaemia Blood Infection' THEN 'Septicaemia Blood'
            WHEN LongDesc = 'Skin Infection' THEN 'Skin'
            WHEN LongDesc = 'Urinary Tract Infection' THEN 'Urinary Tract'
            WHEN LongDesc = 'Wound Infection' THEN 'Wound'
            WHEN LongDesc = 'Nose / Sinus Infection' THEN 'Nose / Sinus'
            ELSE NULL
        END AS InfType,
        r.FacilityName AS Site,
        r.Wing AS Incident_Location,
        1 AS IncidentCount,
        mt.SACNo AS RiskStrat,
        '' AS SIRSIncType,
        '' AS SIRSVicPerp,
        r.FirstName,
        r.LastName AS Surname,
        r.ResidentID,
        I.InfectionLocation AS Description,
        I.IncidentNotes AS Detail,
        '' AS SIRSIncCat,
        '' AS SIRSDegreeHarm,
        r.ResidentType,
        r.ResidentStatus
    FROM BRONZE_DB.ECASE_INFECTIONS_TRAN_RAW I
    LEFT JOIN BRONZE_DB.ECASE_INFECTION_TYPES_RAW T ON I.InfectionTypeID = T.ID
    LEFT JOIN resident r ON I.ResidentID = r.ResidentID
    LEFT JOIN BRONZE_DB.ECASE_RISKMATRIX_TYPE_RAW mt ON I.MatrixID = mt.ID

    UNION ALL

    /* ------------------ COMPULSORY REPORTING ------------------ */
    SELECT
        CASE WHEN C.Status = 1 THEN 'Closed' ELSE 'Open' END AS Status,
        'COM_' || C.ID AS BaseID,
        'Residential' AS Program,
        TO_DATE(NotificationDateTime) AS IncidentDate,
        CAST(NotificationDateTime AS TIMESTAMP_NTZ) AS IncidentTime,
        'SIRS \\ ' || T.LongDesc AS IncClassPrimary,
        '' AS InfType,
        r.FacilityName AS Site,
        r.Wing AS Incident_Location,
        1 AS IncidentCount,
        NULL AS RiskStrat,
        CASE 
            WHEN P.Description = 'P1' THEN 'Priority 1'
            WHEN P.Description = 'P2' THEN 'Priority 2'
            ELSE NULL
        END AS SIRSIncType,
        S.LongDesc AS SIRSVicPerp,
        r.FirstName,
        r.LastName AS Surname,
        r.ResidentID,
        C.AssaultDescription AS Description,
        C.AssaultDescription AS Detail,
        T.LongDesc AS SIRSIncCat,
        CIAT.Description AS SIRSDegreeHarm,
        r.ResidentType,
        r.ResidentStatus
    FROM BRONZE_DB.ECASE_COMPULSORY_REPORTING_TRAN_RAW C
    LEFT JOIN BRONZE_DB.ECASE_COMPULSORY_INCIDENTPRIORITY_RAW P ON C.IncidentPriorityID = P.ID
    LEFT JOIN BRONZE_DB.ECASE_INCIDENT_SUBTYPES_RAW S ON C.IncidentSubtypeID = S.ID
    LEFT JOIN BRONZE_DB.ECASE_ASSAULT_TYPES_RAW T ON C.AssaultTypesID = T.ID
    LEFT JOIN BRONZE_DB.ECASE_COMPULSORY_IMPACTASSESSMENT_TYPES_RAW CIAT ON CIAT.ID = C.ImpactAssessmentID
    LEFT JOIN resident r ON C.ResidentID = r.ResidentID

    UNION ALL

    /* ------------------ WOUNDS ------------------ */
    SELECT
        CASE WHEN I.Status = 0 OR I.Status IS NULL THEN 'Open'
             WHEN I.Status = 1 THEN 'Closed'
             ELSE 'Unknown'
        END AS Status,
        'WOUND_' || I.ID AS BaseID,
        'Residential' AS Program,
        TO_DATE(I.WoundDateTime) AS IncidentDate,
        CAST(I.WoundDateTime AS TIMESTAMP_NTZ) AS IncidentTime,
        'Wounds \\ ' || T.LongDesc AS IncClassPrimary,
        '' AS InfType,
        r.FacilityName AS Site,
        r.Wing AS Incident_Location,
        1 AS IncidentCount,
        NULL AS RiskStrat,
        '' AS SIRSIncType,
        '' AS SIRSVicPerp,
        r.FirstName,
        r.LastName AS Surname,
        r.ResidentID,
        I.LocationOnBody AS Description,
        T.LongDesc AS Detail,
        '' AS SIRSIncCat,
        '' AS SIRSDegreeHarm,
        r.ResidentType,
        r.ResidentStatus
    FROM BRONZE_DB.ECASE_WOUNDS_TRAN_RAW I
    LEFT JOIN BRONZE_DB.ECASE_WOUND_TYPES_RAW T ON I.WoundTypesID = T.ID
    LEFT JOIN resident r ON I.ResidentID = r.ResidentID

    UNION ALL

    /* ------------------ INCIDENTS (excluding some categories) ------------------ */
    SELECT
        CASE WHEN I.Status = 0 OR I.Status IS NULL THEN 'Open'
             WHEN I.Status = 1 THEN 'Closed'
             ELSE 'Unknown'
        END AS Status,
        'INCIDENT_' || I.ID AS BaseID,
        'Residential' AS Program,
        TO_DATE(I.DateOfIncident) AS IncidentDate,
        I.TimeOfIncident AS IncidentTime,
        'Incidents \\ ' || T.LongDesc AS IncClassPrimary,
        '' AS InfType,
        r.FacilityName AS Site,
        r.Wing AS Incident_Location,
        1 AS IncidentCount,
        mt.SACNo AS RiskStrat,
        '' AS SIRSIncType,
        '' AS SIRSVicPerp,
        r.FirstName,
        r.LastName AS Surname,
        r.ResidentID,
        IST.LongDesc AS Description,
        I.IncidentNotes AS Detail,
        '' AS SIRSIncCat,
        '' AS SIRSDegreeHarm,
        r.ResidentType,
        r.ResidentStatus
    FROM BRONZE_DB.ECASE_INCIDENT_TRAN_RAW I
    LEFT JOIN BRONZE_DB.ECASE_INCIDENT_TYPES_RAW T ON I.IncidentTypeID = T.ID
    LEFT JOIN BRONZE_DB.ECASE_INCIDENT_SUBTYPES_RAW IST ON I.IncidentSubTypeID = IST.ID
    LEFT JOIN BRONZE_DB.ECASE_LOCATION_RAW L ON L.ID = I.LocationID
    LEFT JOIN BRONZE_DB.ECASE_RISKMATRIX_TYPE_RAW mt ON I.MatrixID = mt.ID
    LEFT JOIN resident r ON I.ResidentID = r.ResidentID
    WHERE T.LongDesc NOT IN (
        'Fall/Slip/Trip','Other','Infection Control','Incontinence Associated Dermatitis',
        'Wound / Skin Trauma','Pressure Injury','Suicidal Ideation','SIRS Affected Care Recipient',
        'Privacy Breach','Missed Scheduled Visit / Service','Behaviour','Potential SIRS Incident','Injury'
    )

    UNION ALL

    /* ------------------ MEDICATION INCIDENTS ------------------ */
    SELECT
        CASE WHEN I.Status = 0 OR I.Status IS NULL THEN 'Open'
             WHEN I.Status = 1 THEN 'Closed'
             ELSE 'Unknown'
        END AS Status,
        'MEDINCIDENT_' || I.ID AS BaseID,
        'Residential' AS Program,
        TO_DATE(I.DateOfIncident) AS IncidentDate,
        CAST(I.TimeOfIncident AS TIMESTAMP_NTZ) AS IncidentTime,
        'MedIncidents \\ ' || T.LongDesc AS IncClassPrimary,
        '' AS InfType,
        r.FacilityName AS Site,
        r.Wing AS Incident_Location,
        1 AS IncidentCount,
        mt.SACNo AS RiskStrat,
        '' AS SIRSIncType,
        '' AS SIRSVicPerp,
        r.FirstName,
        r.LastName AS Surname,
        r.ResidentID,
        I.BriefDescription AS Description,
        I.IncidentNotes AS Detail,
        '' AS SIRSIncCat,
        '' AS SIRSDegreeHarm,
        r.ResidentType,
        r.ResidentStatus
    FROM BRONZE_DB.ECASE_MEDINCIDENT_TRAN_RAW I
    LEFT JOIN BRONZE_DB.ECASE_MEDINCIDENT_TYPE_RAW T ON I.MedIncidentTypeID = T.ID
    LEFT JOIN BRONZE_DB.ECASE_RISKMATRIX_TYPE_RAW mt ON I.MatrixID = mt.ID
    LEFT JOIN resident r ON I.ResidentID = r.ResidentID
)

SELECT
    *
FROM DATA1;

