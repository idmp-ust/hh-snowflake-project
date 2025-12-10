-- HH_DEV
USE WAREHOUSE DEV_WH;
USE DATABASE HH_DEV;
USE SCHEMA BRONZE_DB;

-- BRONZE_DB
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_ASSAULT_TYPES_RAW;                                //8         (8)
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_BEDHISTORY_RAW;                                   //239       (239)
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_BEDS_RAW;                                         //973       (973)
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_COMPULSORY_IMPACTASSESSMENT_TYPES_RAW;            //7         (7)
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_COMPULSORY_INCIDENTPRIORITY_RAW;                  //2         (2)
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_COMPULSORY_REPORTING_TRAN_RAW;                    //0         (0)
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_FACILITY_RAW;                                     //13        (13)
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_FORMELEMENTS_RAW;                                 //4219      (4219)
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_FORM_RAW;                                         //64        (64)
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_INCIDENT_SUBTYPES_RAW;                            //36        (36)
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_INCIDENT_TRAN_RAW;                                //123       (123)
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_INCIDENT_TYPES_RAW;                               //28        (28)
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_INFECTIONS_TRAN_RAW;                              //0         (20) 48 ?????
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_INFECTION_TYPES_RAW;                              //12        (12)
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_LOCATION_RAW;                                     //16        (16)
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_MEDINCIDENT_TRAN_RAW;                             //1         (6)  21  ?????
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_MEDINCIDENT_TYPE_RAW;                             //20        (20)
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_RESIDENT_FAC_RAW;                                 //313       (826) 1260 ?????
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_RESIDENT_TYPE_RAW;                                //7         (7)
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_RISKMATRIX_TYPE_RAW;                              //25        (25)
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_ROOMS_RAW;                                        //960       (960)
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_WINGS_RAW;                                        //57        (57)
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_WOUNDS_TRAN_RAW;                                  //21        (116) 183 ?????
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_WOUND_TYPES_RAW;                                  //31        (31)
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_ASSESSMENT_FORM_RAW;                              //2045      (6965) 7447 ?????
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_ASSESSMENT_RAW;                                   //1621      (5499) 5846 ?????
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_CPTITLE_RAW;                                      //776       (776)
SELECT COUNT(*) FROM  BRONZE_DB.ECASE_CPUSERSELECTION_RAW;                              //51167     (619423) ?????



-- SILVER_DB
SELECT COUNT(*) FROM  SILVER_DB.ECASE_RAC_DT_ASSESSMENT_AFM_CONFORMED;                  //90
SELECT COUNT(*) FROM  SILVER_DB.ECASE_RAC_DT_ASSESSMENT_AKPS_CONFORMED;                 //90
SELECT COUNT(*) FROM  SILVER_DB.ECASE_RAC_DT_ASSESSMENT_BRADEN_CONFORMED;               //90
SELECT COUNT(*) FROM  SILVER_DB.ECASE_RAC_DT_ASSESSMENT_BRUA_CONFORMED;                 //90
SELECT COUNT(*) FROM  SILVER_DB.ECASE_RAC_DT_ASSESSMENT_DEMMI_CONFORMED;                //98
SELECT COUNT(*) FROM  SILVER_DB.ECASE_RAC_DT_ASSESSMENT_ROCKWOOD_CONFORMED;             //88
SELECT COUNT(*) FROM  SILVER_DB.ECASE_RAC_DT_ASSESSMENT_COMPOUNDING_FACTORS_CONFORMED;  //91
SELECT COUNT(*) FROM  SILVER_DB.ECASE_RAC_DT_ASSESSMENT_RUG_CONFORMED;                  //91
SELECT COUNT(*) FROM  SILVER_DB.ECASE_RAC_DT_POWERBI_CLINICAL_CONFORMED;                //90
SELECT COUNT(*) FROM  SILVER_DB.ECASE_WRB_CONFORMED;                                    //973       (973)
SELECT COUNT(*) FROM  SILVER_DB.ECASE_RWRB_CONFORMED;                                   //217       (197)



-- GOLD_DB
SELECT COUNT(*) FROM  GOLD_DB.DIM_CUSTTABLE;                                            //61762     
SELECT COUNT(*) FROM  GOLD_DB.DIM_ECL_ACMRESIDENTREVIEW;                                //20446     

SELECT COUNT(*) FROM  GOLD_DB.DIM_RAC_DT_ECASE_CLINICAL_DATA;                           //11880     (14977)
SELECT COUNT(*) FROM  GOLD_DB.DIM_RAC_DT_ECASE_AN_ACC_DATA;                             //218       (211)






