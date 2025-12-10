-- HH_DEV
USE WAREHOUSE DEV_WH;
USE DATABASE HH_DEV;
USE SCHEMA BRONZE_DB;


-- ECASE_ASSESSMENT_RAW
CREATE OR REPLACE TABLE ECASE_ASSESSMENT_RAW (
    ID              NUMBER(10,0)        AUTOINCREMENT,
    ResID           NUMBER(10,0)        NOT NULL,
    AssessmentDate  TIMESTAMP_NTZ       NOT NULL,
    ChangeUser      VARCHAR(50),
    ChangeDateTime  TIMESTAMP_NTZ       NOT NULL,
    ModifiedDate    TIMESTAMP_NTZ       NOT NULL,
    ModifiedUser    VARCHAR(50),

    CONSTRAINT PK_ECASE_ASSESSMENT_RAW PRIMARY KEY (ID)
);



-- ECASE_ASSESSMENT_FORM_RAW
CREATE OR REPLACE TABLE ECASE_ASSESSMENT_FORM_RAW (
    ID                      NUMBER(10,0)      AUTOINCREMENT,
    AssessmentID            NUMBER(10,0)      NOT NULL,
    FormID                  NUMBER(10,0)      NOT NULL,
    CPGoalID                NUMBER(10,0),
    OtherGoal               VARCHAR,          -- varchar(-1)
    OtherStrategy           VARCHAR,          -- varchar(-1)
    CPPublishDateTime       TIMESTAMP_NTZ,
    CPStatus                NUMBER(10,0),
    ChangeUser              VARCHAR(50),
    ChangeDateTime          TIMESTAMP_NTZ     NOT NULL,
    ModifiedDate            TIMESTAMP_NTZ     NOT NULL,
    ModifiedUser            VARCHAR(50),
    ModifiedDateGoal        TIMESTAMP_NTZ,
    ModifiedUserGoal        VARCHAR(50),
    ModifiedDateStrategy    TIMESTAMP_NTZ,
    ModifiedUserStrategy    VARCHAR(50),
    Publisher               VARCHAR(50),

    CONSTRAINT PK_ECASE_ASSESSMENT_FORM_RAW PRIMARY KEY (ID)
);


-- ECASE_CPTITLE_RAW
CREATE OR REPLACE TABLE ECASE_CPTITLE_RAW (
    ID               NUMBER(10,0)      AUTOINCREMENT,
    FormID           NUMBER(10,0)      NOT NULL DEFAULT 0,
    Type             VARCHAR(1)        NOT NULL DEFAULT '',
    SortOrder        NUMBER(10,0),
    Code             VARCHAR(40),
    Text             VARCHAR(500)      NOT NULL DEFAULT '',
    HelpLevel        VARCHAR(1),
    isSummmaryCP     BOOLEAN,
    isCP             BOOLEAN,
    isDL             BOOLEAN,
    isLinkedToFE     BOOLEAN,
    ChangeUser       VARCHAR(50),
    ChangeDateTime   TIMESTAMP_NTZ,
    ModifiedDate     TIMESTAMP_NTZ     NOT NULL DEFAULT TO_TIMESTAMP_NTZ('1900-01-01 00:00:00.000'),
    ModifiedUser     VARCHAR(50),

    CONSTRAINT PK_ECASE_CPTITLE_RAW PRIMARY KEY (ID)
);



-- ECASE_CPUSERSELECTION_RAW
CREATE OR REPLACE TABLE ECASE_CPUSERSELECTION_RAW (
    ID                 NUMBER(10,0)      AUTOINCREMENT,
    AssessmentFormID   NUMBER(10,0)      NOT NULL,
    FormElementsID     NUMBER(10,0)      NOT NULL,
    SelectionValue     VARCHAR,          -- unlimited length (varchar(-1))
    ChangeUser         VARCHAR(50)       NOT NULL,
    ChangeDateTime     TIMESTAMP_NTZ     NOT NULL,
    ModifiedDate       TIMESTAMP_NTZ     NOT NULL,
    ModifiedUser       VARCHAR(50),

    CONSTRAINT PK_ECASE_CPUSERSELECTION_RAW PRIMARY KEY (ID)
);



-- ECASE_FORM_RAW
CREATE OR REPLACE TABLE ECASE_FORM_RAW (
    ID               NUMBER(10,0)        AUTOINCREMENT,
    Name             VARCHAR(60)         NOT NULL,
    TemplateName     VARCHAR(20),
    Type             VARCHAR(20)         NOT NULL,
    ParentID         VARCHAR(50),
    Status           BOOLEAN             NOT NULL,
    InterimCarePlan  BOOLEAN             NOT NULL,
    PublishedDate    TIMESTAMP_NTZ,
    IsCarePlan       NUMBER(3,0)         NOT NULL,
    ShowAlert        BOOLEAN             NOT NULL,
    ChangeUser       VARCHAR(50)         NOT NULL,
    ChangeDateTime   TIMESTAMP_NTZ       NOT NULL,
    ModifiedUser     VARCHAR(50)         NOT NULL,
    ModifiedDate     TIMESTAMP_NTZ       NOT NULL,

    CONSTRAINT PK_ECASE_FORM_RAW PRIMARY KEY (ID)
);


-- ECASE_FORMELEMENTS_RAW
CREATE OR REPLACE TABLE ECASE_FORMELEMENTS_RAW (
    ID                   NUMBER(10,0)      AUTOINCREMENT,
    SortOrder            NUMBER(10,0),
    ElementName          VARCHAR(50),
    Text                 VARCHAR,          -- unlimited
    ParentID             NUMBER(10,0),
    ElementTypeID        NUMBER(10,0),
    CPTitleID            NUMBER(10,0),
    DependencyValue      VARCHAR(20),
    Attributes           VARCHAR,          -- unlimited
    Text2                VARCHAR,          -- unlimited
    IsArchived           BOOLEAN           NOT NULL,
    IsUsedForMapping     BOOLEAN           NOT NULL,
    IsDLElement          BOOLEAN,
    isUsingFEOptions     BOOLEAN           NOT NULL,
    ShowHideSectionID    NUMBER(10,0),
    ChangeUser           VARCHAR(50),
    ChangeDateTime       TIMESTAMP_NTZ,
    ModifiedDate         TIMESTAMP_NTZ     NOT NULL,
    ModifiedUser         VARCHAR(50),

    CONSTRAINT PK_ECASE_FORMELEMENTS_RAW PRIMARY KEY (ID)
);

