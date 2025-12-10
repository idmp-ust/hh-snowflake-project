-- HH_DEV
USE WAREHOUSE DEV_WH;
USE DATABASE HH_TEST;
USE SCHEMA BRONZE_DB;


-- ECASE_ASSAULT_TYPES_RAW
CREATE OR REPLACE TABLE ECASE_ASSAULT_TYPES_RAW (
    ID                 INT             AUTOINCREMENT,
    ShortDesc          VARCHAR(20)     NOT NULL,
    LongDesc           VARCHAR(100)    NOT NULL,
    HasLinkedSubtype   BOOLEAN         NOT NULL,
    LinkedSubtype      TINYINT         NOT NULL,
    IsArchived         BOOLEAN         NOT NULL,
    ChangeUser         VARCHAR(50),
    ChangeDateTime     TIMESTAMP_NTZ   NOT NULL,
    ModifiedDate       TIMESTAMP_NTZ   NOT NULL,
    ModifiedUser       VARCHAR(50),

    CONSTRAINT PK_ECASE_ASSAULT_TYPES_RAW PRIMARY KEY (ID)
);


-- ECASE_BEDHISTORY_RAW
CREATE OR REPLACE TABLE ECASE_BEDHISTORY_RAW (
    ID               INT             AUTOINCREMENT,
    ResID            INT             NOT NULL,
    occupiedDate     TIMESTAMP_NTZ   NOT NULL,
    CurrentBedID     INT             NOT NULL,
    PrevBedID        INT,
    ModifiedDate     TIMESTAMP_NTZ,
    ModifiedUser     VARCHAR(50),
    ChangeDatetime   TIMESTAMP_NTZ,
    ChangeUser       VARCHAR(50),

    CONSTRAINT PK_ECASE_BEDHISTORY_RAW PRIMARY KEY (ID)
);



-- ECASE_BEDS_RAW
CREATE OR REPLACE TABLE ECASE_BEDS_RAW (
    ID                INT             AUTOINCREMENT,
    BedCode           VARCHAR(8)      NOT NULL,
    BedDescription    VARCHAR(100),
    RoomsID           INT             NOT NULL,
    BedTypeID         INT,
    Classification    CHAR(1),
    IsOccupant        BOOLEAN         NOT NULL,
    IntegrationCode   VARCHAR(20),
    IsActive          BOOLEAN         NOT NULL,
    ChangeUser        VARCHAR(50),
    ChangeDateTime    TIMESTAMP_NTZ   NOT NULL,
    ModifiedDate      TIMESTAMP_NTZ   NOT NULL,
    ModifiedUser      VARCHAR(50),

    CONSTRAINT PK_ECASE_BEDS_RAW PRIMARY KEY (ID)
);



-- ECASE_COMPULSORY_IMPACTASSESSMENT_TYPES_RAW
CREATE OR REPLACE TABLE ECASE_COMPULSORY_IMPACTASSESSMENT_TYPES_RAW (
    ID                INT             AUTOINCREMENT,
    Description       VARCHAR(500)    NOT NULL,
    IsArchived        BOOLEAN         NOT NULL,
    CreateUser        VARCHAR(50)     NOT NULL,
    CreateDateTime    TIMESTAMP_NTZ   NOT NULL,
    ModifiedUser      VARCHAR(50)     NOT NULL,
    ModifiedDateTime  TIMESTAMP_NTZ   NOT NULL,

    CONSTRAINT PK_ECASE_COMPULSORY_IMPACTASSESSMENT_TYPES_RAW PRIMARY KEY (ID)
);


-- ECASE_COMPULSORY_INCIDENTPRIORITY_RAW
CREATE OR REPLACE TABLE ECASE_COMPULSORY_INCIDENTPRIORITY_RAW (
    ID                 INT             AUTOINCREMENT,
    Description        VARCHAR(500)    NOT NULL,
    IsArchived         BOOLEAN         NOT NULL,
    CreateUser         VARCHAR(50)     NOT NULL,
    CreateDateTime     TIMESTAMP_NTZ   NOT NULL,
    ModifiedUser       VARCHAR(50)     NOT NULL,
    ModifiedDateTime   TIMESTAMP_NTZ   NOT NULL,

    CONSTRAINT PK_ECASE_COMPULSORY_INCIDENTPRIORITY_RAW PRIMARY KEY (ID)
);



-- ECASE_COMPULSORY_REPORTING_TRAN_RAW
CREATE OR REPLACE TABLE ECASE_COMPULSORY_REPORTING_TRAN_RAW (

    ID                                   INT               AUTOINCREMENT,
    ResidentID                           INT               NOT NULL,
    NotificationDateTime                 TIMESTAMP_NTZ     NOT NULL,
    AssaultTypesID                       INT               NOT NULL,
    AssaultDescription                   VARCHAR,
    IncidentSubtypeID                    INT,
    ReportingPersonID                    INT,
    AllegedPerpetratorType               INT,
    AllegedPerpetratorStaffID            INT,
    VictimType                           INT,
    VictimStaffID                        INT,
    ReportingPerson                      VARCHAR(30),
    LocationID                           INT,
    AllegedPerpetratorID                 INT,
    AllegedPerpetrator                   VARCHAR,
    OffenderCognitiveImpairmentID        INT,
    VictimID                             INT,
    VictimName                           VARCHAR,
    VictimCognitiveImpairmentID          INT,
    PoliceNotificationDateTime           TIMESTAMP_NTZ,
    NotificationRecord                   VARCHAR,
    CISNotificationDateTime              TIMESTAMP_NTZ,
    ReasonForNotNotifying                VARCHAR,
    ActionsOrResolutions                 VARCHAR,
    ResolutionDate                       TIMESTAMP_NTZ,
    RegistryCompletionPerson             VARCHAR(30),
    InjuryID                             INT,
    PoliceNotificationName               VARCHAR(200),
    PoliceNotificationStation            VARCHAR(200),
    CISNotificationName                  VARCHAR(200),
    Status                               INT,
    PoliceReferenceNum                   VARCHAR(20),
    PoliceNotified                       BOOLEAN,
    ComplaintsSchemeNotified             BOOLEAN,
    Substantiated                        BOOLEAN,
    Comments                             VARCHAR,
    IsDeleted                            BOOLEAN           NOT NULL,
    DeletedBy                            VARCHAR(50),
    DeleteDateTime                       TIMESTAMP_NTZ,
    FromSyncedID                         INT               NOT NULL,
    IncidentPriorityID                   INT,
    ImpactAssessmentID                   INT,
    SuspectedPreviously                  INT,
    ActionToMinimizeRisk                 VARCHAR,
    PoliceArrestedOrCharged              INT,
    IncidentReportedOneDay               BOOLEAN,
    IncidentReportedFiveDays             BOOLEAN,
    IncidentReportedThirtyDays           BOOLEAN,
    IncidentReportedEightFourDays        BOOLEAN,
    IncidentNotes                        VARCHAR,
    FurtherInformationRequired           BOOLEAN,
    CommissionNotificationNotes           VARCHAR,
    StandardRiskTypeID                   INT,
    ChangeUser                           VARCHAR(50)       NOT NULL,
    ChangeDateTime                       TIMESTAMP_NTZ     NOT NULL,
    ModifiedDate                         TIMESTAMP_NTZ     NOT NULL,
    ModifiedUser                         VARCHAR(50)       NOT NULL,

    CONSTRAINT PK_ECASE_COMPULSORY_REPORTING_TRAN_RAW PRIMARY KEY (ID)
);



-- ECASE_FACILITY_RAW
CREATE OR REPLACE TABLE ECASE_FACILITY_RAW (
    ID                           INT              AUTOINCREMENT,
    FacilityCode                 VARCHAR(20)      NOT NULL,
    FacilityType                 VARCHAR(20),
    FacilityName                 VARCHAR(255),
    Address1                     VARCHAR(255),
    Address2                     VARCHAR(255),
    Address3                     VARCHAR(255),
    city                         VARCHAR(100),
    state                        VARCHAR(20),
    postcode                     VARCHAR(10),
    Phone                        VARCHAR(25),
    Fax                          VARCHAR(25),
    Email                        VARCHAR(255),
    caretype                     INT,
    EntityID                     INT,
    SVC_Classification_type      VARCHAR(10),
    PayrollTaxType               VARCHAR(1),
    PayrollTaxPortion            VARCHAR(10),
    MeetRequirements             TINYINT          NOT NULL,
    B2b                          VARCHAR(5),
    SVC_config                   TINYINT,
    HasCare                      VARCHAR(5),
    T1LocationCode               VARCHAR(80),
    T1FacilityID                 VARCHAR(80),
    MedicationDataProvider       VARCHAR(50),
    CostCentre                   VARCHAR(5),
    LegalEntity                  VARCHAR(4),
    IntegrationCode              VARCHAR(20),
    IntegrationType              VARCHAR(20),
    MedicationServiceURL         VARCHAR(200),
    ORCAIntegration              VARCHAR(5),
    ClientSideFacValue           VARCHAR(30),
    ChangeUser                   VARCHAR(50),
    ChangeDateTime               TIMESTAMP_NTZ,
    ModifiedUser                 VARCHAR(50),
    ModifiedDate                 TIMESTAMP_NTZ,
    ServiceId                    VARCHAR(10),
    ServiceNapsId                INT,
    OrganisationRA               NUMBER,
    PRODAPemPath                 VARCHAR(200),
    HPIONum                      VARCHAR(16),
    LastSuccessfulHPIORefreshDt  TIMESTAMP_NTZ,
    Classification               VARCHAR(50),
    ClassificationText           VARCHAR(50),
    ClassificationFundingBasis   VARCHAR(50),
    ClassificationStartDate      TIMESTAMP_NTZ,
    ClassificationEndDate        TIMESTAMP_NTZ,
    AustralianBusinessNumber      BIGINT,
    OrganisationType             INT,
    OrganisationServiceType      VARCHAR(50),

    CONSTRAINT PK_ECASE_FACILITY_RAW PRIMARY KEY (ID)
);



-- ECASE_INCIDENT_SUBTYPES_RAW
CREATE OR REPLACE TABLE ECASE_INCIDENT_SUBTYPES_RAW (
    ID               INT             AUTOINCREMENT,
    ShortDesc        VARCHAR(20)     NOT NULL,
    LongDesc         VARCHAR(100)    NOT NULL,
    IsActive         BOOLEAN         NOT NULL,
    ChangeUser       VARCHAR(50),
    ChangeDateTime   TIMESTAMP_NTZ,
    ModifiedDate     TIMESTAMP_NTZ   NOT NULL,
    ModifiedUser     VARCHAR(50),

    CONSTRAINT PK_ECASE_INCIDENT_SUBTYPES_RAW PRIMARY KEY (ID)
);



-- ECASE_INCIDENT_TRAN_RAW
CREATE OR REPLACE TABLE ECASE_INCIDENT_TRAN_RAW (

    ID                          INT              AUTOINCREMENT,
    ResidentID                  INT              NOT NULL,
    DateOfIncident              TIMESTAMP_NTZ    NOT NULL,
    TimeOfIncident              TIMESTAMP_NTZ,
    DateLastSeen                TIMESTAMP_NTZ,
    TimeLastSeen                TIMESTAMP_NTZ,
    IsDementia                  CHAR(1),
    IsDementiaReadOnly          BOOLEAN,
    Unit                        CHAR(3),
    IncidentTypeID              INT              NOT NULL,
    IncidentSubTypeID           INT,
    TypeOther                   VARCHAR(500),
    LocationID                  INT              NOT NULL,
    LocOther                    VARCHAR(500),
    InjuryOther                 VARCHAR(500),
    ContOther                   VARCHAR(500),
    ActionOther                 VARCHAR(500),
    AssessOther                 VARCHAR(500),
    RiskOther                   VARCHAR(500),
    MedicalOther                VARCHAR(500),
    FallsOnlyOther              VARCHAR,
    IsWitnessed                 CHAR(1),
    WitnessedBy                 VARCHAR(100),
    Status                      INT,
    NextOfKinName               VARCHAR(100),
    NextOfKinDatetime           TIMESTAMP_NTZ,
    SeniorManagementName        VARCHAR(100),
    SeniorManagementDatetime    TIMESTAMP_NTZ,
    SeniorManagementPosition    VARCHAR(100),
    CoronerName                 VARCHAR(100),
    CoronerDatetime             TIMESTAMP_NTZ,
    CoronerNotifiedBy           VARCHAR(100),
    MatrixID                    INT,
    IncidentNotes               VARCHAR,
    InjuryInformationID         INT              NOT NULL,
    FallsOnlyID                 INT,
    ResidentOutcome             VARCHAR(20),
    ResidentOutcomeOther        VARCHAR(50),
    FallFrom                    VARCHAR(20),
    ResidentCompany             VARCHAR(20),
    ActionsID                   INT,
    ContributingFactorsID       INT,
    FromSyncedID                INT              NOT NULL,
    StandardRiskTypeID          INT,
    ChangeUser                  VARCHAR(50),
    ChangeDate                  TIMESTAMP_NTZ    NOT NULL,
    ModifiedDate                TIMESTAMP_NTZ    NOT NULL,
    ModifiedUser                VARCHAR(50),

    CONSTRAINT PK_ECASE_INCIDENT_TRAN_RAW PRIMARY KEY (ID)
);



-- ECASE_INCIDENT_TYPES_RAW
CREATE OR REPLACE TABLE ECASE_INCIDENT_TYPES_RAW (
    ID                   INT             AUTOINCREMENT,
    ShortDesc            VARCHAR(100)    NOT NULL,
    LongDesc             VARCHAR(100)    NOT NULL,
    IsActivateFallsOnly  BOOLEAN         NOT NULL,
    HasLinkedSubtype     BOOLEAN         NOT NULL,
    LinkedSubtype        TINYINT         NOT NULL,
    IsArchived           BOOLEAN         NOT NULL,
    ChangeUser           VARCHAR(50),
    ChangeDateTime       TIMESTAMP_NTZ   NOT NULL,
    ModifiedDate         TIMESTAMP_NTZ   NOT NULL,
    ModifiedUser         VARCHAR(50),

    CONSTRAINT PK_ECASE_INCIDENT_TYPES_RAW PRIMARY KEY (ID)
);



-- ECASE_INFECTIONS_TRAN_RAW
CREATE OR REPLACE TABLE ECASE_INFECTIONS_TRAN_RAW (
    ID                           INT              AUTOINCREMENT,
    ResidentID                   INT              NOT NULL,
    CommencementDate             TIMESTAMP_NTZ,
    OnAdmission                  INT              NOT NULL,
    InfectionTypeID              INT              NOT NULL,
    SymptomCodes                 VARCHAR(20),
    TestTypeID                   INT              NOT NULL,
    TestOther                    VARCHAR(50),
    OrganismsIdentified          VARCHAR(20),
    OrganismsTestRequestDate     TIMESTAMP_NTZ,
    OrganismsDate                TIMESTAMP_NTZ,
    AntiBioticsStartDay          TIMESTAMP_NTZ,
    AntiBioticsEndDay            TIMESTAMP_NTZ,
    DateInfectionResolved        TIMESTAMP_NTZ,
    InterventionOther            VARCHAR(500),
    TypeOther                    VARCHAR(50),
    Status                       INT,
    Version                      INT,
    MRSALocation                 VARCHAR,       -- unlimited text
    InfectionLocation            VARCHAR,       -- unlimited text
    IncidentNotes                VARCHAR,       -- unlimited text
    FromSyncedID                 INT             NOT NULL,
    InfectionMedicationID        INT,
    InfectionMedicationOtherID   INT,
    MatrixID                     INT,
    isCatheter                   BOOLEAN,
    StandardRiskTypeID           INT,
    ChangeUser                   VARCHAR(50),
    ChangeDateTime               TIMESTAMP_NTZ   NOT NULL,
    ModifiedDate                 TIMESTAMP_NTZ   NOT NULL,
    ModifiedUser                 VARCHAR(50),

    CONSTRAINT PK_ECASE_INFECTIONS_TRAN_RAW PRIMARY KEY (ID)
);



-- ECASE_INFECTION_TYPES_RAW
CREATE OR REPLACE TABLE ECASE_INFECTION_TYPES_RAW (
    ID              INT             AUTOINCREMENT,
    ShortDesc       VARCHAR(20),
    LongDesc        VARCHAR(100)    NOT NULL,
    InUse           BOOLEAN,
    IsArchived      BOOLEAN         NOT NULL,
    ChangeUser      VARCHAR(50),
    ChangeDateTime  TIMESTAMP_NTZ   NOT NULL,
    ModifiedDate    TIMESTAMP_NTZ   NOT NULL,
    ModifiedUser    VARCHAR(50),

    CONSTRAINT PK_ECASE_INFECTION_TYPES_RAW PRIMARY KEY (ID)
);



-- ECASE_LOCATION_RAW
CREATE OR REPLACE TABLE ECASE_LOCATION_RAW (
    ID               INT             AUTOINCREMENT,
    ShortDesc        VARCHAR(20),
    LongDesc         VARCHAR(100)    NOT NULL,
    IsArchived       BOOLEAN         NOT NULL,
    ChangeUser       VARCHAR(50),
    ChangeDateTime   TIMESTAMP_NTZ   NOT NULL,
    ModifiedDate     TIMESTAMP_NTZ   NOT NULL,
    ModifiedUser     VARCHAR(50),

    CONSTRAINT PK_ECASE_LOCATION_RAW PRIMARY KEY (ID)
);



-- ECASE_MEDINCIDENT_TRAN_RAW
CREATE OR REPLACE TABLE ECASE_MEDINCIDENT_TRAN_RAW (
    ID                       INT             AUTOINCREMENT,
    ResidentID               INT             NOT NULL,
    DateOfIncident           TIMESTAMP_NTZ   NOT NULL,
    TimeOfIncident           TIMESTAMP_NTZ,
    MedIncidentTypeID        INT             NOT NULL,
    LocationID               INT,
    IncidentSubtypeID        INT,
    OtherDetails             VARCHAR(100),
    IncidentNotes            VARCHAR,        -- unlimited text (-1)
    BriefDescription         VARCHAR,        -- unlimited text (-1)
    DateIssueClosed          TIMESTAMP_NTZ,
    IsWitnessed              CHAR(1),
    WitnessedBy              VARCHAR(100),
    Status                   INT,
    FromSyncedID             INT             NOT NULL,
    MatrixID                 INT,
    ResidentOutcome          VARCHAR(20),
    ResidentOutcomeOther     VARCHAR(50),
    StandardRiskTypeID       INT,
    ChangeUser               VARCHAR(50),
    ChangeDate               TIMESTAMP_NTZ   NOT NULL,
    ModifiedDate             TIMESTAMP_NTZ   NOT NULL,
    ModifiedUser             VARCHAR(50),

    CONSTRAINT PK_ECASE_MEDINCIDENT_TRAN_RAW PRIMARY KEY (ID)
);



-- ECASE_MEDINCIDENT_TYPE_RAW
CREATE OR REPLACE TABLE ECASE_MEDINCIDENT_TYPE_RAW (
    ID                 INT             AUTOINCREMENT,
    ShortDesc          VARCHAR(20)     NOT NULL,
    LongDesc           VARCHAR(100)    NOT NULL,
    HasLinkedSubtype   BOOLEAN         NOT NULL,
    LinkedSubtype      TINYINT         NOT NULL,
    IsArchived         BOOLEAN         NOT NULL,
    ChangeUser         VARCHAR(50),
    ChangeDateTime     TIMESTAMP_NTZ   NOT NULL,
    ModifiedDate       TIMESTAMP_NTZ   NOT NULL,
    ModifiedUser       VARCHAR(50),

    CONSTRAINT PK_ECASE_MEDINCIDENT_TYPE_RAW PRIMARY KEY (ID)
);



-- ECASE_RESIDENT_TYPE_RAW
CREATE OR REPLACE TABLE ECASE_RESIDENT_TYPE_RAW (
    ID                       INT             AUTOINCREMENT,
    TypeName                 VARCHAR(50)     NOT NULL,
    TypeCode                 VARCHAR(1)      NOT NULL,
    SortOrder                INT,
    ResidentParentTypeId     INT             NOT NULL,
    ChangeUser               VARCHAR(50),
    ChangeDateTime           TIMESTAMP_NTZ,
    ModifiedDate             TIMESTAMP_NTZ   NOT NULL,
    ModifiedUser             VARCHAR(50),

    CONSTRAINT PK_ECASE_RESIDENT_TYPE_RAW PRIMARY KEY (ID)
);



-- ECASE_RISKMATRIX_TYPE_RAW
CREATE OR REPLACE TABLE ECASE_RISKMATRIX_TYPE_RAW (
    ID                       INT             AUTOINCREMENT,
    ConsequenceText          VARCHAR(250),
    LikelihoodText           VARCHAR(250),
    SACNo                    INT             NOT NULL,
    Colour                   VARCHAR(50),
    CreationUser             VARCHAR(50)     NOT NULL,
    ChangeDateTime           TIMESTAMP_NTZ   NOT NULL,
    ModificationDatetime     TIMESTAMP_NTZ,
    ModificationUser         VARCHAR(50),

    CONSTRAINT PK_ECASE_RISKMATRIX_TYPE_RAW PRIMARY KEY (ID)
);



-- ECASE_ROOMS_RAW
CREATE OR REPLACE TABLE ECASE_ROOMS_RAW (
    ID                INT             AUTOINCREMENT,
    RoomCode          VARCHAR(8),
    RoomDescription   VARCHAR(50),
    WingsID           INT             NOT NULL,
    RoomTypeID        INT             NOT NULL,
    IntegrationCode   VARCHAR(20),
    IsRemoved         BOOLEAN         NOT NULL,
    ChangeUser        VARCHAR(50),
    ChangeDateTime    TIMESTAMP_NTZ   NOT NULL,
    ModifiedDate      TIMESTAMP_NTZ   NOT NULL,
    ModifiedUser      VARCHAR(50),

    CONSTRAINT PK_ECASE_ROOMS_RAW PRIMARY KEY (ID)
);



-- ECASE_WINGS_RAW
CREATE OR REPLACE TABLE ECASE_WINGS_RAW (
    ID                INT             AUTOINCREMENT,
    WingCode          VARCHAR(20)     NOT NULL,
    WingDescription   VARCHAR(50),
    FacilityID        INT             NOT NULL,
    ChangeUser        VARCHAR(50),
    ChangeDateTime    TIMESTAMP_NTZ   NOT NULL,
    ModifiedDate      TIMESTAMP_NTZ   NOT NULL,
    ModifiedUser      VARCHAR(50),
    SortOrder         INT             NOT NULL,

    CONSTRAINT PK_ECASE_WINGS_RAW PRIMARY KEY (ID)
);



-- ECASE_WOUNDS_TRAN_RAW
CREATE OR REPLACE TABLE ECASE_WOUNDS_TRAN_RAW (
    ID                      INT             AUTOINCREMENT,
    ResidentID              INT             NOT NULL,
    WoundDateTime           TIMESTAMP_NTZ   NOT NULL,
    Comments                STRING,
    SkinRiskAssessment      INT,
    SkinRiskDesc            STRING,
    IncidentFormCompleted   INT,
    LocationOnBody          VARCHAR(50),
    WoundTypesID            INT,
    TypeOther               STRING,
    OnAdmission             INT,
    CauseTypesID            INT,
    CoMorOther              STRING,
    WoundHealedDate         TIMESTAMP_NTZ,
    Status                  INT,
    IsDeleted               TINYINT         NOT NULL,
    LocationDescription     STRING,
    Narrative               VARCHAR(50),
    IncidentNotes           STRING,
    ChangeUser              VARCHAR(50),
    ChangeDateTime          TIMESTAMP_NTZ   NOT NULL,
    ModifiedDate            TIMESTAMP_NTZ   NOT NULL,
    ModifiedUser            VARCHAR(50),

    CONSTRAINT PK_ECASE_WOUNDS_TRAN_RAW PRIMARY KEY (ID)
);



-- ECASE_WOUND_TYPES_RAW
CREATE OR REPLACE TABLE ECASE_WOUND_TYPES_RAW (
    ID              NUMBER(10,0)        AUTOINCREMENT,
    ShortDesc       VARCHAR(20)         NOT NULL,
    LongDesc        VARCHAR(200)        NOT NULL,
    Active          NUMBER(10,0)        NOT NULL,
    WBT             BOOLEAN             NOT NULL,
    IsNQIP          BOOLEAN             NOT NULL,
    NQIPReports     NUMBER(10,0),
    SortOrder       NUMBER(10,0),
    ChangeUser      VARCHAR(50)         NOT NULL,
    ChangeDateTime  TIMESTAMP_NTZ       NOT NULL,
    ModifiedDate    TIMESTAMP_NTZ       NOT NULL,
    ModifiedUser    VARCHAR(50)         NOT NULL,
    Other           VARCHAR(20),

    CONSTRAINT PK_ECASE_WOUND_TYPES_RAW PRIMARY KEY (ID)
);



-- ECASE_RESIDENT_FAC_RAW
CREATE OR REPLACE TABLE ECASE_RESIDENT_FAC_RAW (
    ID INT AUTOINCREMENT PRIMARY KEY,

    Per_ID VARCHAR(32) NOT NULL DEFAULT '',
    Group_ID VARCHAR(32),
    Org_ID VARCHAR(32),
    PriceClass_ID VARCHAR(32),
    Customer_Code VARCHAR(8) NOT NULL DEFAULT '',
    BondCustomer_Code VARCHAR(8),
    TrustCustomer_Code VARCHAR(20),
    LastName VARCHAR(40),
    FirstName VARCHAR(40),
    PreferredName VARCHAR(60),
    Salutation VARCHAR(30),
    Title VARCHAR(20),
    Gender SMALLINT,
    DateOfBirth TIMESTAMP_NTZ,
    CityOfBirth VARCHAR(30),
    CountryOfBirth VARCHAR(30),
    MaritalStatus INT,
    Religion VARCHAR(99),
    Address1 VARCHAR(35),
    Address2 VARCHAR(35),
    Address3 VARCHAR(35),
    City VARCHAR(20),
    State VARCHAR(20),
    Region INT,
    Zip VARCHAR(10),
    Country VARCHAR(20),
    BillingAddress1 VARCHAR(35),
    BillingAddress2 VARCHAR(35),
    BillingAddress3 VARCHAR(35),
    BillingCity VARCHAR(20),
    BillingState VARCHAR(20),
    BillingZip VARCHAR(10),
    BillingCountry VARCHAR(20),
    PreviousPostcode VARCHAR(10),
    EmailAddress VARCHAR(80),
    PriPhone VARCHAR(20),
    AltPhone VARCHAR(20),
    FaxPhone VARCHAR(20),
    CellPhone VARCHAR(20),
    Status VARCHAR(20),
    InActive SMALLINT NOT NULL DEFAULT 0,
    PensionType VARCHAR(2) NOT NULL DEFAULT '',
    PensionNum VARCHAR(30),
    MedicareNum VARCHAR(30),
    MedicareExpDate TIMESTAMP_NTZ,
    HealthFund VARCHAR(50),
    HealthFundNum VARCHAR(30),
    HealthFundExpDate VARCHAR(10),
    MedicalCondition VARCHAR,
    DateofApplication TIMESTAMP_NTZ,
    AgreementType VARCHAR(20),
    AccomPrefMinPrice NUMBER(18,2),
    AccomPrefMaxPrice NUMBER(18,2),
    AccomPrefEntryDate TIMESTAMP_NTZ,
    ReceiptNum VARCHAR(10),
    ReceiptAmount NUMBER(18,2),
    ReceiptDate TIMESTAMP_NTZ,
    FuneralNotes VARCHAR,
    Comments VARCHAR(255),
    Alert VARCHAR(255),
    Role VARCHAR(30),
    ChargeExempt INT,
    Restrictions VARCHAR,
    PersonalHistory VARCHAR,
    DepartmentID VARCHAR(50),
    OnElectRoll INT,
    MobilityCode VARCHAR(50),
    CulturalBackground VARCHAR(50),
    BehaviouralNotes VARCHAR(200),
    IsACATAssessment INT,
    DVARefNo VARCHAR(50),
    TotalAssetsVal NUMBER(18,2),
    IsConcessional SMALLINT,
    IsAssisted SMALLINT,
    IsBond SMALLINT NOT NULL DEFAULT 0,
    CurrentRoomEntryDate TIMESTAMP_NTZ,
    PmtMethodAccommodation VARCHAR(20),
    CurrentUnitEntryDate TIMESTAMP_NTZ,
    InterpreterReq INT,
    RespiteDaysTaken VARCHAR(10),
    RespiteDate TIMESTAMP_NTZ,
    RSChangeDate TIMESTAMP_NTZ,
    RSArriveDate TIMESTAMP_NTZ,
    RSSiteID VARCHAR(10),
    RespiteDaysReq VARCHAR(10),
    PreRCSCategory INT,
    PreRCSDate TIMESTAMP_NTZ,
    IsReturnedMail INT,
    FundComments VARCHAR,
    IsPrimaryContact INT,
    LoanCustomer_Code VARCHAR(8),
    IsConfused SMALLINT,
    CurrentLivingAccomType VARCHAR(30),
    CurrentLivingPerson VARCHAR(20),
    HasCoResidentCarer SMALLINT,
    CaresForPerson VARCHAR(20),
    IsFinanciallyDisadvantaged INT,
    HasSeniorsCard SMALLINT,
    HasHealthCareCard SMALLINT,
    HasTransportSubsidy SMALLINT,
    HasDisabilityParking SMALLINT,
    HasPersonalAlarm SMALLINT,
    Ethnicity VARCHAR(20),
    HasDementia INT,
    DVACardColour VARCHAR(20),
    HasNonResidentCarer SMALLINT,
    AboriginalTSIStatus NUMBER(3,0),
    PrefLanguage VARCHAR(30),
    GeographicArea VARCHAR(20),
    ConcessionCardNum VARCHAR(30),
    CommCustomer_Code VARCHAR(9),
    IsCommCareResident INT,
    IsResCareResident INT,
    AreaPrefStartDate TIMESTAMP_NTZ,
    HACCID VARCHAR(20),
    CreditMgr VARCHAR(50),
    CollContactPer_ID VARCHAR(32),
    DoCollect INT,
    NotCollectReason VARCHAR(30),
    BirthDateEst INT,
    missingSLKField INT,
    SecondName VARCHAR(30),
    CentreLinkNum VARCHAR(10),
    IsNonClassified SMALLINT,
    AccomEntryDate TIMESTAMP_NTZ,
    FacilityCode VARCHAR(20),
    RCSScore FLOAT,
    RCSCategory INT,
    RCSAsAtDate TIMESTAMP_NTZ,
    RCSExpiryDate TIMESTAMP_NTZ,
    LastACFIAppraisal TIMESTAMP_NTZ,
    ADLCatCut FLOAT,
    BehCatCut FLOAT,
    CHCCatCut NUMBER(3,0),
    FundingValue NUMBER(18,2),
    DiagnosisRequiredBy TIMESTAMP_NTZ,
    AppraisalDueDate TIMESTAMP_NTZ,
    ActualACFIFunding NUMBER(18,2),
    FollowUpDate TIMESTAMP_NTZ,
    IsActioning BOOLEAN,
    POAName VARCHAR(40),
    POAAddress1 VARCHAR(40),
    POAAddress2 VARCHAR(40),
    POAState VARCHAR(3),
    POAPCode VARCHAR(4),
    POAPhoneM VARCHAR(15),
    POAPhoneW VARCHAR(15),
    POAPhoneH VARCHAR(15),
    POAEmail VARCHAR(40),
    BillingContact VARCHAR(40),
    BillingPhone VARCHAR(15),
    BillingEmail VARCHAR(40),
    IsContract SMALLINT,
    IsExtraService SMALLINT,
    IsTransitional SMALLINT,
    IsFallsRisk SMALLINT,
    MedPractitionerName VARCHAR(40),
    MedPractitionerAddress1 VARCHAR(40),
    MedPractitionerAddress2 VARCHAR(40),
    MedPractitionerState VARCHAR(3),
    MedPractitionerPCode VARCHAR(4),
    MedPractitionerPhoneM VARCHAR(15),
    MedPractitionerPhoneW VARCHAR(15),
    MedPractitionerPhoneH VARCHAR(15),
    MedPractitionerEmail VARCHAR(40),
    NOK1Name VARCHAR(40),
    NOK1Address1 VARCHAR(40),
    NOK1Address2 VARCHAR(40),
    NOK1State VARCHAR(3),
    NOK1PCode VARCHAR(4),
    NOK1PhoneM VARCHAR(15),
    NOK1PhoneW VARCHAR(15),
    NOK1PhoneH VARCHAR(15),
    NOK1Email VARCHAR(40),
    NOK2Name VARCHAR(40),
    NOK2Address1 VARCHAR(40),
    NOK2Address2 VARCHAR(40),
    NOK2State VARCHAR(3),
    NOK2PCode VARCHAR(4),
    NOK2PhoneM VARCHAR(15),
    NOK2PhoneW VARCHAR(15),
    NOK2PhoneH VARCHAR(15),
    NOK2Email VARCHAR(40),
    IsAmbulanceCover SMALLINT,
    LevelofCover VARCHAR(15),
    PensionExpDate TIMESTAMP_NTZ,
    AcatCareStatus VARCHAR(1),
    IsInfectiousDisease SMALLINT,
    IsAbsconder SMALLINT,
    MobilityStatus SMALLINT,
    HealthCareCardNum VARCHAR(30),
    ClinicalRelationShip1 VARCHAR(30),
    ClinicalRelationShip2 VARCHAR(30),
    BillingPhoneH VARCHAR(20),
    BillingPhoneW VARCHAR(20),
    ACFIDocCommDate TIMESTAMP_NTZ,
    EPAName VARCHAR(30),
    EPAAddress1 VARCHAR(35),
    EPAAddress2 VARCHAR(35),
    EPAState VARCHAR(20),
    EPAPCode VARCHAR(10),
    EPAPhoneW VARCHAR(20),
    EPAPhoneH VARCHAR(20),
    EPAPhoneM VARCHAR(20),
    EPAEmail VARCHAR(80),
    IsRespite SMALLINT,
    IsPalliativeCare BOOLEAN,
    RoomAndBed VARCHAR(20),
    ACATApprovalDate TIMESTAMP_NTZ,
    FundingLiability VARCHAR(8),
    ClientID VARCHAR(20),
    EPC SMALLINT,
    CMA SMALLINT,
    CurrentBedID INT,
    AttachmentID INT NOT NULL DEFAULT 0,
    IsPreRacsBond NUMBER(3,0),
    ExtraServiceAmount NUMBER(18,2),
    EquipmentForTransfer VARCHAR(50),
    ModeOfMobility VARCHAR(50),
    OtherMobility VARCHAR(500),
    DailyCareFee NUMBER(18,2),
    IsDailyCharge INT,
    BondAmount NUMBER(18,2),
    ResidentTypeID INT NOT NULL DEFAULT 0,
    photo VARCHAR,
    IncomeSupportBfEntry NUMBER(3,0),
    AdvanceHealthDirective INT,
    FirstAdmissionDate TIMESTAMP_NTZ,
    InitialACATCareStatus INT,
    RespiteCareStatus INT,
    DailyCareType INT,
    RespiteCareLevel INT,
    PackageID INT,
    PersonalAlarmType INT,
    NoBirthdayCelebration INT,
    ILUVillageID INT,
    ILUcode VARCHAR(30),
    ServiceClassCode VARCHAR(2),
    Nationalityid INT,
    PeriodType VARCHAR(15),
    NextPaymentDate TIMESTAMP_NTZ,
    DepositAmount NUMBER(18,2) NOT NULL DEFAULT 0,
    PeriodicAmount NUMBER(18,2) NOT NULL DEFAULT 0,
    BondonAdmission NUMBER(18,2) NOT NULL DEFAULT 0,
    ExtraServiceType VARCHAR(7),
    DeductfromBond NUMBER(3,0),
    DisQis VARCHAR(9),
    ProbateCitationDate TIMESTAMP_NTZ,
    DailyCareFeeDisc FLOAT,
    DailyCareFeeEffectiveDate TIMESTAMP_NTZ,
    RespectingPatientChoices NUMBER(3,0),
    MedicalHistory VARCHAR,
    OtherTransfer VARCHAR(500),
    MedicareIRN VARCHAR(10),
    PrevBondAmount NUMBER(18,2),
    NumberOfRetention INT,
    RetentionValueDeducted NUMBER(18,2),
    BondType NUMBER(3,0),
    LumpsumAmount NUMBER(18,2),
    PeriodicAmountContract NUMBER(18,2),
    RetentionRatePerMonth NUMBER(18,2),
    RetentionRatePerDay NUMBER(18,2),
    InterestRate NUMBER(18,2),
    FeeReduction NUMBER(18,2),
    BondDueDate TIMESTAMP_NTZ,
    ExitNotificationDate TIMESTAMP_NTZ,
    DeductFrom VARCHAR(1),
    AccomChargeAmount NUMBER(18,2),
    AddDate TIMESTAMP_NTZ,
    AddUser VARCHAR(20),
    ClientIDOld VARCHAR(20),
    FromSyncProfilePicPath VARCHAR(200),
    IsResidentSmoker SMALLINT,
    ChartBarcode VARCHAR(50),
    CurrentANACCClass VARCHAR(50),
    CurrentANACCCStatusText VARCHAR(255),
    IsEnrolledVote BOOLEAN,
    CheckGallery BOOLEAN,
    IHINumber VARCHAR(16),
    LastSuccessfulIHIRefreshDt TIMESTAMP_NTZ,
    LastSyncDateTime TIMESTAMP_NTZ,
    ChangeDate TIMESTAMP_NTZ,
    ChangeUser VARCHAR(50),
    ModifiedDate TIMESTAMP_NTZ NOT NULL DEFAULT TO_TIMESTAMP_NTZ('1900-01-01 00:00:00.000'),
    ModifiedUser VARCHAR(50)
);
