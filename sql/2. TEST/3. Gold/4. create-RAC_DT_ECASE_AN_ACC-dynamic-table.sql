-- HH_DEV
USE WAREHOUSE DEV_WH;
USE DATABASE HH_TEST;
USE SCHEMA BRONZE_DB;

-- SELECT * FROM GOLD_DB.DIM_RAC_DT_ECASE_AN_ACC_DATA;

CREATE OR REPLACE DYNAMIC TABLE GOLD_DB.DIM_RAC_DT_ECASE_AN_ACC_DATA
    TARGET_LAG = '5 MINUTES'
    WAREHOUSE = DEV_WH
AS
WITH incident_data AS (
    SELECT
        r.Customer_Code,
        COUNT(*) AS occ
    FROM BRONZE_DB.ECASE_INCIDENT_TRAN_RAW I
    LEFT JOIN BRONZE_DB.ECASE_INCIDENT_TYPES_RAW T 
        ON I.IncidentTypeID = T.ID
    LEFT JOIN BRONZE_DB.ECASE_RESIDENT_FAC_RAW r 
        ON I.ResidentID = r.ID
    WHERE T.LongDesc IN ('Fall')
      AND (I.Status = 0 OR I.Status IS NULL)
      AND TO_DATE(I.DateOfIncident) >= DATEADD(month, -12, CURRENT_DATE())
    GROUP BY r.Customer_Code
),

anacc AS (
    SELECT 
        CASE 
            WHEN TRY_TO_NUMBER(HHAC_ECASERESIDENTID) IS NULL THEN '999999'
            ELSE HHAC_ECASERESIDENTID
        END AS HHAC_ECASERESIDENTID,
        r.CUSTACCOUNT,
        RCSCATEGORYCODE,
        ROW_NUMBER() OVER (
            PARTITION BY CUSTACCOUNT 
            ORDER BY REVIEWDATE DESC, RCSCATEGORYCODE ASC
        ) AS rn
    FROM GOLD_DB.DIM_CUSTTABLE c
    LEFT JOIN GOLD_DB.DIM_ECL_ACMRESIDENTREVIEW r
        ON c.ACCOUNTNUM = r.CUSTACCOUNT
    WHERE RCSCATEGORYCODE LIKE 'CLASS%'
      AND c.HHAC_ECASERESIDENTID != ''
),

final_data AS (
    SELECT
        rw.FacilityCode AS "ECL_ACMFACILITYID",
        rw.Bed AS "ECL_ACMACCOMMODATIONID",
        r.ID AS "eCase_ResidentID",
        rr.CUSTACCOUNT AS "ACCOUNTNUM",
        CONCAT(r.Salutation, ' ', r.FirstName, ' ', r.LastName) AS "NAME",
        CASE WHEN r.IsRespite = 1 THEN 'RESP' ELSE 'PERM' END AS "ECL_ACMRESIDENTTYPEID",

        rr.RCSCATEGORYCODE AS "Official_AN_ACC_Category",
        dm.DeMorton_RAW_Score AS "DEMMI_Score",
        (
            SocialCog_Memory +
            SocialCog_Problem +
            SocialCog_SocialInt +
            Locomotion_Comprehension +
            Locomotion_Expression
        ) AS "AM_FIM_Score",

        rug.RugItem_FinalScore AS "RUG_ADL_Score",
        rk.Fraility_Score AS "Domain_1_24_Rockwood_Frailty_Scale",
        br.BRADEN_FinalScoreValue AS "BRADEN_Score",
        AKPS_finalScore AS "CF_AKPS",

        CASE 
            WHEN cf."Do I have any compounding factors?" = 'Yes' THEN 1
            WHEN cf."Do I have any compounding factors?" = 'No'  THEN 0
            ELSE NULL
        END AS "CF_Status_Resp",

        CASE 
            WHEN i.occ IS NULL OR i.occ = 0 THEN 0
            WHEN i.occ = 1 THEN 1
            WHEN i.occ > 1 THEN 2
            ELSE NULL
        END AS "Frailty",

        brua.BRUA_FinalScoreValue AS "CF_BRUA",
        cf."Do I have any compounding factors?" AS "CF_Status",

        CASE 
            WHEN cf."Do I have any compounding factors?" = 'Yes' THEN 0
            WHEN cf."Do I have any compounding factors?" = 'No'  THEN 1
            ELSE NULL
        END AS "CF_Status_No",

        CASE 
            WHEN cf."Do I have any compounding factors?" = 'Yes' THEN 1
            WHEN cf."Do I have any compounding factors?" = 'No'  THEN 0
            ELSE NULL
        END AS "CF_Status_Yes"

    FROM BRONZE_DB.ECASE_RESIDENT_FAC_RAW r
    LEFT JOIN SILVER_DB.ECASE_RAC_DT_ASSESSMENT_AFM_CONFORMED afm
        ON r.ID = afm.ResID AND afm.AssessmentStatus = 'Not Published'
    LEFT JOIN SILVER_DB.ECASE_RAC_DT_ASSESSMENT_AKPS_CONFORMED akps
        ON r.ID = akps.ResID AND akps.AssessmentStatus = 'Not Published'
    LEFT JOIN SILVER_DB.ECASE_RAC_DT_ASSESSMENT_DEMMI_CONFORMED dm
        ON r.ID = dm.ResID AND dm.AssessmentStatus = 'Not Published'
    LEFT JOIN SILVER_DB.ECASE_RAC_DT_ASSESSMENT_ROCKWOOD_CONFORMED rk
        ON r.ID = rk.ResID AND rk.AssessmentStatus = 'Not Published'
    LEFT JOIN SILVER_DB.ECASE_RAC_DT_ASSESSMENT_RUG_CONFORMED rug
        ON r.ID = rug.ResID AND rug.AssessmentStatus = 'Not Published'
    LEFT JOIN SILVER_DB.ECASE_RAC_DT_ASSESSMENT_BRADEN_CONFORMED br
        ON r.ID = br.ResID AND br.AssessmentStatus = 'Not Published'
    LEFT JOIN SILVER_DB.ECASE_RAC_DT_ASSESSMENT_COMPOUNDING_FACTORS_CONFORMED cf
        ON r.ID = cf.ResID AND cf.AssessmentStatus = 'Not Published'
    LEFT JOIN SILVER_DB.ECASE_RAC_DT_ASSESSMENT_BRUA_CONFORMED brua
        ON r.ID = brua.ResID AND brua.AssessmentStatus = 'Not Published'
    LEFT JOIN incident_data i 
        ON r.Customer_Code = i.Customer_Code
    LEFT JOIN SILVER_DB.ECASE_RWRB_CONFORMED rw 
        ON r.ID = rw.ResidentID
    LEFT JOIN (SELECT * FROM anacc WHERE rn = 1) rr
        ON r.ID = rr.HHAC_ECASERESIDENTID
)

SELECT *
FROM final_data
WHERE ECL_ACMFACILITYID IN ('RCIFAC','RCLEHS');

