-- HH_DEV
USE WAREHOUSE DEV_WH;
USE DATABASE HH_DEV;
USE SCHEMA BRONZE_DB;

CREATE OR REPLACE DYNAMIC TABLE SILVER_DB.ECASE_RAC_DT_ASSESSMENT_AKPS_CONFORMED
TARGET_LAG = '5 minutes'
WAREHOUSE = DEV_WH
AS
WITH AllInactiveAssessmentCT AS (
    SELECT DISTINCT 
        AssessmentID AS AsmtID
    FROM BRONZE_DB.ECASE_ASSESSMENT_FORM_RAW
    WHERE CPStatus = -1
      AND AssessmentID NOT IN (
            SELECT DISTINCT AssessmentID 
            FROM BRONZE_DB.ECASE_ASSESSMENT_FORM_RAW
            WHERE CPStatus IN (0, 1)
        )
),

LatestFormAsmtCT AS (
    SELECT 
        FormID,
        MAX(ID) AS MaxAsmtFormID
    FROM BRONZE_DB.ECASE_ASSESSMENT_FORM_RAW
    GROUP BY FormID
),

assesment_data AS (
    SELECT DISTINCT
        S.AssessmentID,
        S.ID AS FormID,
        CASE
            WHEN aia.AsmtID IS NOT NULL OR S.CPStatus = -1 THEN 'Inactive'
            WHEN S.CPStatus = 1 THEN 'Published'
            WHEN S.CPStatus = 0 THEN 'Under Review'
            WHEN S.CPStatus IS NULL THEN 'Not Published'
        END AS AssessmentStatus,
        CAST(A.ChangeDateTime AS DATE) AS CreatedDate,
        CASE WHEN lfa.MaxAsmtFormID IS NOT NULL THEN 'Yes' ELSE 'No' END AS isLatest
    FROM BRONZE_DB.ECASE_ASSESSMENT_RAW A
    LEFT JOIN BRONZE_DB.ECASE_ASSESSMENT_FORM_RAW S 
        ON S.AssessmentID = A.ID
    LEFT JOIN AllInactiveAssessmentCT aia
        ON A.ID = aia.AsmtID
    LEFT JOIN LatestFormAsmtCT lfa
        ON S.FormID = lfa.FormID
       AND S.ID = lfa.MaxAsmtFormID
),

LatestCarePlanElement AS (
    SELECT
        a.ResID,
        rf.Customer_Code,
        f.Name,
        cpus.AssessmentFormID,
        cpus.SelectionValue,
        fe.ElementName
    FROM BRONZE_DB.ECASE_CPUSERSELECTION_RAW cpus
    JOIN BRONZE_DB.ECASE_ASSESSMENT_FORM_RAW af
        ON af.ID = cpus.AssessmentFormID
    JOIN BRONZE_DB.ECASE_FORM_RAW f
        ON f.ID = af.FormID
    JOIN BRONZE_DB.ECASE_ASSESSMENT_RAW a
        ON a.ID = af.AssessmentID
    JOIN BRONZE_DB.ECASE_RESIDENT_FAC_RAW rf
        ON rf.ID = a.ResID
    JOIN BRONZE_DB.ECASE_FORMELEMENTS_RAW fe
        ON fe.ID = cpus.FormElementsID
    JOIN BRONZE_DB.ECASE_CPTITLE_RAW cpt
        ON cpt.ID = fe.CPTitleID
)

SELECT
    L.ResID,
    L.Customer_Code,
    L.Name,
    L.AssessmentFormID,
    A.AssessmentID,
    A.AssessmentStatus,
    A.CreatedDate,
    A.isLatest,
    L.SelectionValue AS AKPS_finalScore
FROM LatestCarePlanElement L
LEFT JOIN assesment_data A
    ON L.AssessmentFormID = A.FormID
WHERE L.Name = 'Australia – modified Karnofsky Performance Status (AKPS)'
  AND L.ElementName = 'AKPS_finalScore'
  AND A.AssessmentStatus IS NOT NULL;

