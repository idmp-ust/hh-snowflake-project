USE DATABASE HH_DEV;


CREATE OR REPLACE DYNAMIC TABLE GOLD_DB.RAC_VW_Assessment_DEMMI
TARGET_LAG = '15 minutes'
WAREHOUSE = DEV_WH
AS

WITH AllInactiveAssessmentCT AS (
    SELECT DISTINCT AssessmentID AS AsmtID
    FROM GOLD_DB.DIM_ASSESSMENTFORM
    WHERE CPStatus = -1
      AND AssessmentID NOT IN (
            SELECT DISTINCT AssessmentID
            FROM GOLD_DB.DIM_ASSESSMENTFORM
            WHERE CPStatus IN (0, 1)
      )
),

LatestFormAsmtCT AS (
    SELECT FormID, MAX(ID) AS MaxAsmtFormID
    FROM GOLD_DB.DIM_ASSESSMENTFORM
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
        CASE WHEN lfa.MaxAsmtFormID IS NOT NULL THEN 'Yes' ELSE 'No' END AS IsLatest
    FROM GOLD_DB.DIM_ASSESSMENT A
    LEFT JOIN GOLD_DB.DIM_ASSESSMENTFORM S
        ON S.AssessmentID = A.ID
    LEFT JOIN AllInactiveAssessmentCT aia
        ON A.ID = aia.AsmtID
    LEFT JOIN LatestFormAsmtCT lfa
        ON S.FormID = lfa.FormID AND S.ID = lfa.MaxAsmtFormID
),

LatestCarePlanElement AS (
    SELECT 
        a.ResID,
        rf.Customer_Code,
        f.Name,
        cpus.AssessmentFormID,
        cpus.SelectionValue,
        fe.ElementName
    FROM GOLD_DB.DIM_CPUUSERSELECTION cpus
    JOIN GOLD_DB.DIM_ASSESSMENTFORM af
        ON af.ID = cpus.AssessmentFormID
    JOIN GOLD_DB.DIM_FORM f
        ON f.ID = af.FormID
    JOIN GOLD_DB.DIM_ASSESSMENT a
        ON a.ID = af.AssessmentID
    JOIN GOLD_DB.DIM_RESIDENTFAC rf
        ON rf.ID = a.ResID
    JOIN GOLD_DB.DIM_FORMELEMENTS fe
        ON fe.ID = cpus.FormElementsID
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
        A.IsLatest,

        CASE 
            WHEN ElementName = 'DeMorton_DEMMI_ScoreText' 
            THEN SPLIT_PART(SelectionValue, '/', 1)
        END AS DeMorton_DEMMI_Score,

        CASE 
            WHEN ElementName = 'DeMorton_RAWScore_text' 
            THEN SPLIT_PART(SelectionValue, '/', 1)
        END AS DeMorton_RAW_Score

    FROM LatestCarePlanElement L
    LEFT JOIN assesment_data A
        ON L.AssessmentFormID = A.FormID
    WHERE L.Name IN ('De Morton Mobility Index (DEMMI) - Modified')
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
    IsLatest,
    MAX(DeMorton_DEMMI_Score) AS DeMorton_DEMMI_Score,
    MAX(DeMorton_RAW_Score)  AS DeMorton_RAW_Score
FROM assess_data
GROUP BY 
    ResID,
    Customer_Code,
    Name,
    AssessmentFormID,
    AssessmentID,
    AssessmentStatus,
    CreatedDate,
    IsLatest;


SELECT * FROM GOLD_DB.DIM_ASSESSMENT;