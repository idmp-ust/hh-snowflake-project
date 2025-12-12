-- HH_DEV
USE WAREHOUSE DEV_WH;
USE DATABASE HH_TEST;
USE SCHEMA BRONZE_DB;

CREATE OR REPLACE DYNAMIC TABLE SILVER_DB.ECASE_WRB_CONFORMED
TARGET_LAG = '5 minutes'
WAREHOUSE = DEV_WH
AS
SELECT 
    f.ID                                  AS FacilityID,
    f.FacilityCode,
    f.FacilityName,
    f.State,
    f.IntegrationCode                     AS FacilityIntegrationCode,

    w.ID                                  AS WingID,
    w.WingCode,
    w.WingDescription,
    w.SortOrder,

    r.ID                                  AS RoomID,
    r.RoomCode,
    r.RoomDescription,
    r.IntegrationCode                     AS RoomIntegrationCode,

    -- Replace dbo.getText(RoomDescription,1)
    REGEXP_SUBSTR(r.RoomDescription, '^[A-Za-z]+')          AS RoomDesc,
    -- Replace dbo.getNumber(RoomDescription,1)
    REGEXP_SUBSTR(r.RoomDescription, '[0-9]+')              AS RoomNo,
    -- Replace dbo.getText(RoomDescription,0)
    REGEXP_REPLACE(r.RoomDescription, '[0-9]', '')          AS RoomNoCode,

    b.ID                                  AS BedID,
    b.BedCode,
    b.BedDescription,
    b.IntegrationCode                     AS BedIntegrationCode,

    REGEXP_SUBSTR(b.BedDescription, '^[A-Za-z]+')           AS BedDesc,
    REGEXP_SUBSTR(b.BedDescription, '[0-9]+')               AS BedNo,
    REGEXP_REPLACE(b.BedDescription, '[0-9]', '')           AS BedNoCode,

    b.IsOccupant                          AS IsOccupant,
    b.IsActive
FROM BRONZE_DB.ECASE_FACILITY_RAW  AS f
JOIN BRONZE_DB.ECASE_WINGS_RAW     AS w ON f.ID = w.FacilityID
JOIN BRONZE_DB.ECASE_ROOMS_RAW     AS r ON r.WingsID = w.ID
JOIN BRONZE_DB.ECASE_BEDS_RAW      AS b ON b.RoomsID = r.ID;
