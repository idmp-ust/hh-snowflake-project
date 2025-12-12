-- HH_DEV
USE WAREHOUSE DEV_WH;
USE DATABASE HH_TEST;
USE SCHEMA BRONZE_DB;

CREATE OR REPLACE DYNAMIC TABLE SILVER_DB.ECASE_RAC_DT_ASSESSMENT_ROCKWOOD_CONFORMED
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
        fe.ElementName,
        REPLACE(fe.Text, '<br />', '') AS Text
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
),

assess_data AS (
    SELECT
        L.ResID,
        L.Customer_Code,
        L.Name,
        L.AssessmentFormID,
        A.AssessmentID,
        A.AssessmentStatus,
        A.CreatedDate,
        A.isLatest,

        CASE 
            WHEN ElementName IN (
                'FrailtyScore_vFitSelect','FrailtyScore_FitSelect',
                'FrailtyScore_MWellSelect','FrailtyScore_VeryMildFraSelect',
                'FrailtyScore_MildFraSelect','FrailtyScore_ModerateFraSelect',
                'FrailtyScore_SevereFraSelect','FrailtyScore_VerySevFraSelect',
                'FrailtyScore_terILLSelect'
            )
            AND SelectionValue = '1'
            THEN Text
        END AS Fraility,

        CASE
            WHEN ElementName = 'FrailtyScore_vFitSelect'        AND SelectionValue = '1' THEN 1
            WHEN ElementName = 'FrailtyScore_FitSelect'         AND SelectionValue = '1' THEN 2
            WHEN ElementName = 'FrailtyScore_MWellSelect'       AND SelectionValue = '1' THEN 3
            WHEN ElementName = 'FrailtyScore_VeryMildFraSelect' AND SelectionValue = '1' THEN 4
            WHEN ElementName = 'FrailtyScore_MildFraSelect'     AND SelectionValue = '1' THEN 5
            WHEN ElementName = 'FrailtyScore_ModerateFraSelect' AND SelectionValue = '1' THEN 6
            WHEN ElementName = 'FrailtyScore_SevereFraSelect'   AND SelectionValue = '1' THEN 7
            WHEN ElementName = 'FrailtyScore_VerySevFraSelect'  AND SelectionValue = '1' THEN 8
            WHEN ElementName = 'FrailtyScore_terILLSelect'      AND SelectionValue = '1' THEN 9
        END AS Fraility_Score

    FROM LatestCarePlanElement L
    LEFT JOIN assesment_data A
        ON L.AssessmentFormID = A.FormID
    WHERE L.Name = 'Rockwood Frailty Scale'
      AND A.AssessmentStatus IS NOT NULL
)

SELECT
    ResID,
    Customer_Code,
    Name,
    AssessmentFormID,
    AssessmentID,
    AssessmentStatus,
    CreatedDate,
    isLatest,

    MAX(Fraility)        AS Fraility,
    MAX(Fraility_Score)  AS Fraility_Score

FROM assess_data
GROUP BY
    ResID,
    Customer_Code,
    Name,
    AssessmentFormID,
    AssessmentID,
    AssessmentStatus,
    CreatedDate,
    isLatest;
