-- HH_DEV
USE WAREHOUSE DEV_WH;
USE DATABASE HH_TEST;
USE SCHEMA BRONZE_DB;


CREATE OR REPLACE DYNAMIC TABLE SILVER_DB.ECASE_RWRB_CONFORMED
TARGET_LAG = '5 minutes'
WAREHOUSE = DEV_WH
AS
WITH BedHistory_All AS (
    SELECT 
        ResID,
        CASE 
            WHEN CurrentBedID <> 0 THEN CurrentBedID
            WHEN CurrentBedID = 0 AND PrevBedID <> 0 THEN PrevBedID
            ELSE NULL
        END AS BedID,
        ROW_NUMBER() OVER (PARTITION BY ResID ORDER BY ID DESC) AS RowIndex
    FROM BRONZE_DB.ECASE_BEDHISTORY_RAW
    WHERE (CurrentBedID <> 0 OR PrevBedID <> 0)
),

ResidentBed AS (
    SELECT
        rf.ID AS ResidentID,
        rf.Customer_Code AS ResidentCode,
        rf.FacilityCode,
        CASE 
            WHEN rf.CurrentBedID <> 0 THEN rf.CurrentBedID
            ELSE bh.BedID
        END AS BedID
    FROM BRONZE_DB.ECASE_RESIDENT_FAC_RAW AS rf
    LEFT JOIN BedHistory_All AS bh ON rf.ID = bh.ResID
    WHERE 
        (rf.ResidentTypeID NOT IN (2, 3) OR rf.IsRespite = 1)
        AND (bh.RowIndex IS NULL OR bh.RowIndex = 1)
)

SELECT
    rb.ResidentID,
    rb.ResidentCode,
    w.State,
    CASE WHEN w.BedID IS NOT NULL THEN w.FacilityID ELSE f.ID END AS FacilityID,
    CASE WHEN w.BedID IS NOT NULL THEN w.FacilityCode ELSE f.FacilityCode END AS FacilityCode,
    CASE WHEN w.BedID IS NOT NULL THEN w.FacilityName ELSE f.FacilityName END AS FacilityName,
    
    w.WingID,
    w.WingCode,
    COALESCE(w.WingDescription, 'Unknown') AS Wing,
    w.SortOrder,

    w.RoomID,
    w.RoomCode,
    COALESCE(w.RoomDescription, 'Unknown') AS Room,

    w.BedID,
    w.BedCode,
    COALESCE(w.BedDescription, 'Unknown') AS Bed

FROM ResidentBed AS rb
LEFT JOIN SILVER_DB.ECASE_WRB_CONFORMED AS w ON rb.BedID = w.BedID
LEFT JOIN BRONZE_DB.ECASE_FACILITY_RAW AS f ON rb.FacilityCode = f.FacilityCode;
