-- HH_DEV
USE WAREHOUSE DEV_WH;
USE DATABASE HH_DEV;
USE SCHEMA BRONZE_DB;

CREATE OR REPLACE DYNAMIC TABLE SILVER_DB.ECASE_RAC_DT_ASSESSMENT_AFM_CONFORMED
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

        /* Functional Measure Final Score */
        CASE WHEN ElementName = 'FunctionalMeasure_FinalScore' 
             THEN SelectionValue 
        END AS FunctionalMeasure_FinalScore,

        /* AFM – Locomotion Comprehension */
        CASE 
            WHEN ElementName = 'FM_Locomotion_Table_Comp_1' THEN SelectionValue + 1 
        END AS Locomotion_Comprehension,

        /* AFM – Locomotion Expression */
        CASE 
            WHEN ElementName = 'FM_Locomotion_Table_Exp_1' THEN SelectionValue + 1
        END AS Locomotion_Expression,

        /* AFM – Locomotion Walk/Wheelchair */
        CASE 
            WHEN ElementName = 'FM_Locomotion_Table_WW_1' THEN SelectionValue + 1
        END AS Locomotion_Walk_Wheelchair,

        CASE 
            WHEN ElementName = 'FM_Locomotion_Table_TotalScore' THEN SelectionValue
        END AS Locomotion_TotalScore,

        /* Social Cognitive — Memory */
        CASE
            WHEN ElementName = 'FM_SocialCog_Table_Memory_1' THEN SelectionValue + 1
        END AS SocialCog_Memory,

        /* Social Cognitive — Problem Solving */
        CASE
            WHEN ElementName = 'FM_SocialCog_Table_Problem_1' THEN SelectionValue + 1
        END AS SocialCog_Problem,

        /* Social Cognitive — Social Interaction */
        CASE
            WHEN ElementName = 'FM_SocialCog_Table_SocialInt_1' THEN SelectionValue + 1
        END AS SocialCog_SocialInt,

        /* SocialCog Total Score */
        CASE
            WHEN ElementName = 'FM_SocialCog_Table_TotalScore' THEN SelectionValue
        END AS SocialCog_TotalScore

    FROM LatestCarePlanElement L
    LEFT JOIN assesment_data A
        ON L.AssessmentFormID = A.FormID
    WHERE L.Name = 'Australian Functional Measure (AFM)'
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

    MAX(FunctionalMeasure_FinalScore) AS FunctionalMeasure_FinalScore,

    MAX(Locomotion_Comprehension) AS Locomotion_Comprehension,
    MAX(Locomotion_Expression) AS Locomotion_Expression,
    MAX(Locomotion_Walk_Wheelchair) AS Locomotion_Walk_Wheelchair,
    MAX(Locomotion_TotalScore) AS Locomotion_TotalScore,

    MAX(SocialCog_Memory) AS SocialCog_Memory,
    MAX(SocialCog_Problem) AS SocialCog_Problem,
    MAX(SocialCog_SocialInt) AS SocialCog_SocialInt,
    MAX(SocialCog_TotalScore) AS SocialCog_TotalScore,

    /* AFM Combined Score */
    (
        MAX(SocialCog_Memory)
      + MAX(SocialCog_Problem)
      + MAX(SocialCog_SocialInt)
      + MAX(Locomotion_Comprehension)
      + MAX(Locomotion_Expression)
    ) AS Score1

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
