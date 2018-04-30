--------------------------------------------------------
--  File created - Tuesday-April-17-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body IOBY3B_PKG
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PENDING"."IOBY3B_PKG" 
IS
procedure CREATE_ACCOUNT_PP (
  p_account_id      OUT INTEGER,
  p_email           IN VARCHAR,   -- must not be NULL
  p_password        IN VARCHAR,   -- must not be NULL
  p_location_name   IN VARCHAR,   -- must not be NULL
  p_account_type    IN VARCHAR,   -- should have value of 'Group or organization' or 'Individual'
  p_first_name      IN VARCHAR,
  p_last_name       IN VARCHAR
)
IS
BEGIN
    DECLARE
        null_input_exists       EXCEPTION;
        incorrect_type          EXCEPTION;
        account_exists          EXCEPTION;
        invalid_format          EXCEPTION;
        countItems              INT;
        not_null_msg            VARCHAR2(100) := NULL;
        myaccounttype            VARCHAR2(20) := NULL;
                
    BEGIN
        /* Validate the input data*/
       
        IF p_email IS NULL THEN 
            SELECT not_null_msg || chr(10) || '  Email ' INTO not_null_msg FROM dual;
        END IF;
        IF p_password IS NULL THEN 
            SELECT not_null_msg || chr(10) ||  '  Password ' INTO not_null_msg FROM dual;
        END IF;
        IF p_location_name IS NULL THEN 
            SELECT not_null_msg || chr(10) || '  Location Name ' INTO not_null_msg FROM dual;
        END IF;
        /*Need to sanitize the account type casing since there is a check constraint on the field*/
        myaccounttype := p_account_type;
        IF myaccounttype IS NULL THEN
            RAISE incorrect_type;
        ELSIF UPPER(myaccounttype) = 'GROUP OR ORGANIZATION' THEN
            myaccounttype := 'Group or organization';
        ELSIF  UPPER(myaccounttype) = 'INDIVIDUAL' THEN
            myaccounttype := 'Individual';
        ELSE
           RAISE incorrect_type; 
        END IF;
            
        IF NOT not_null_msg IS NULL THEN
            RAISE null_input_exists;
        END IF; 
        IF NOT regexp_like(p_email, '[A-Z0-9._%-]+@[A-Z0-9._%-]+\.[A-Z]{2,4}', 'i') THEN
            RAISE invalid_format;
        END IF;    
        SELECT COUNT(*) INTO countItems FROM I_ACCOUNT WHERE UPPER(ACCOUNT_EMAIL) = UPPER(p_email);
        
        IF countItems > 0 THEN
            RAISE account_exists;
        END IF;  
        
        
        INSERT INTO I_ACCOUNT 
            (ACCOUNT_ID, ACCOUNT_EMAIL, ACCOUNT_PASSWORD, ACCOUNT_LOCATION_NAME, ACCOUNT_TYPE, ACCOUNT_FIRST_NAME, ACCOUNT_LAST_NAME)
        SELECT MAX(ACCOUNT_ID) + 1 MyAccountID, p_email, p_password, p_location_name, myaccounttype, p_first_name, p_last_name
        FROM I_ACCOUNT;   
        
        SELECT MAX(ACCOUNT_ID) INTO p_account_id FROM I_ACCOUNT WHERE UPPER(ACCOUNT_EMAIL) = UPPER(p_email);
        
        DBMS_OUTPUT.PUT_LINE('An account has been created with the given info. The account id is: ' || p_account_id);
  
        COMMIT;

    EXCEPTION
        WHEN null_input_exists THEN
            DBMS_OUTPUT.PUT_LINE('Missing Input Data.'); 
            DBMS_OUTPUT.PUT_LINE('Please make sure to provide input for the following fields: ' || not_null_msg);
            ROLLBACK;
        WHEN incorrect_type THEN
            DBMS_OUTPUT.PUT_LINE('Incorrect Account Type Defined.'); 
            DBMS_OUTPUT.PUT_LINE('Account Type should have value of ''Group or organization'' or ''Individual''');
            ROLLBACK;
        WHEN account_exists THEN
            DBMS_OUTPUT.PUT_LINE('Account already exists.');
            DBMS_OUTPUT.PUT_LINE('An existing account has been found for the email address provided. Please use a different email.');
            ROLLBACK;
        WHEN invalid_format THEN
            DBMS_OUTPUT.PUT_LINE('Email Address not valid.');
            DBMS_OUTPUT.PUT_LINE('The format of the email address is not valid. Please use a different email.'); 
            ROLLBACK;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('An Error occurred');
            DBMS_OUTPUT.PUT_LINE('The error number: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('The error message: ' || SQLERRM);
            ROLLBACK;   
    END;
END CREATE_ACCOUNT_PP; 

procedure CREATE_PROJECT_PP (
p_project_id        OUT INTEGER,
p_title             IN  VARCHAR,
p_goal              IN  NUMBER,        -- The goal should be >= zero
p_deadline          IN  DATE,
p_creation_date     IN  DATE,
p_description       IN  CLOB,
p_subtitle          IN  VARCHAR,
p_street_1          IN  VARCHAR,
p_street_2          IN  VARCHAR,
p_city              IN  VARCHAR,
P_state             IN  VARCHAR,
p_postal_code       IN  CHAR,
p_postal_extension  IN  CHAR,
p_steps_to_take     IN  CLOB,
p_motivation        IN  CLOB,
p_volunteer_need    IN  VARCHAR,  
p_project_status    IN  VARCHAR,  
p_account_id        IN  INTEGER   
)
IS
BEGIN
    DECLARE
        null_input_exists       EXCEPTION;
        invalid_status          EXCEPTION;
        invalid_deadline        EXCEPTION;
        invalid_volunteer       EXCEPTION;
        invalid_account         EXCEPTION;
        invalid_goal            EXCEPTION;
        invalid_description     EXCEPTION;
        countItems              INT;
        not_null_msg            VARCHAR2(500) := NULL;
        myprojectstatus         VARCHAR2(20) := NULL;
        myprojectvolunteer      VARCHAR2(20) := NULL;
        CurrentDate             DATE := SYSDATE;
    BEGIN    
    IF p_title IS NULL THEN
        SELECT not_null_msg || chr(10) || '  Title ' INTO not_null_msg FROM dual;
    END IF;    
    IF p_goal < 0 THEN
        RAISE invalid_goal;
    END IF;    
    IF p_goal IS NULL THEN
        SELECT not_null_msg || chr(10) ||  '  Goal ' INTO not_null_msg FROM dual;
    END IF;    
    IF p_deadline IS NULL THEN
        SELECT not_null_msg || chr(10) || '  Deadline ' INTO not_null_msg FROM dual;
    END IF;    
    IF p_description IS NULL THEN
        SELECT not_null_msg || chr(10) || ' Description ' INTO not_null_msg FROM dual; 
    END IF;    
    IF p_city IS NULL THEN
        SELECT not_null_msg || chr(10) || ' City  ' INTO not_null_msg FROM dual;
    END IF;    
    IF p_subtitle IS NULL THEN
        SELECT not_null_msg || chr(10) || ' Subtitle ' INTO not_null_msg FROM dual;
    END IF;
    IF p_street_1 IS NULL THEN
        SELECT not_null_msg || chr(10) || ' Street ' INTO not_null_msg FROM dual;
    END IF;    
    IF p_state IS NULL THEN
        SELECT not_null_msg || chr(10) || ' State ' INTO not_null_msg FROM dual;
    END IF;
    IF p_postal_code IS NULL THEN
        SELECT not_null_msg || chr(10) || ' Postal Code ' INTO not_null_msg FROM dual;
    END IF;
    IF myprojectstatus IS NULL THEN
        SELECT not_null_msg || chr(10) || ' Project Status ' INTO not_null_msg FROM dual;
    END IF;
    
    IF p_deadline <= p_creation_date
    THEN
      RAISE invalid_deadline;
    END IF;
    
    IF p_description IS NULL THEN
      RAISE invalid_description;
    END IF;
    
    myprojectvolunteer := p_volunteer_need;
    IF myprojectvolunteer IS NULL THEN
      RAISE invalid_volunteer;
    ELSIF UPPER(myprojectvolunteer) = 'YES' THEN
      myprojectvolunteer := 'yes';
    ELSIF UPPER(myprojectvolunteer) = 'NO' THEN
      myprojectvolunteer := 'no';
    ELSE
      RAISE invalid_volunteer; 
    END IF;        
             
    myprojectstatus := p_project_status;
    IF myprojectstatus IS NULL THEN
      myprojectstatus := 'Submitted';
    ELSIF UPPER(myprojectstatus) = 'UNDERWAY' THEN
      myprojectstatus := 'Underway';
    ELSIF UPPER(myprojectstatus) = 'OPEN' THEN
      myprojectstatus := 'Open';
    ELSIF UPPER(myprojectstatus) = 'CLOSED' THEN
      myprojectstatus := 'Closed';
    ELSIF UPPER(myprojectstatus) = 'COMPLETE' THEN
      myprojectstatus := 'Complete';
    ELSIF UPPER(myprojectstatus) = 'SUBMITTED' THEN
      myprojectstatus := 'Submitted';
    ELSE
      RAISE invalid_status; 
    END IF; 
        
    SELECT COUNT(*) INTO countItems FROM I_ACCOUNT WHERE account_id = p_account_id;       
    IF countItems < 1 THEN
      RAISE invalid_account;
    END IF;  

    INSERT INTO I_PROJECT 
      (PROJECT_ID,PROJECT_TITLE,PROJECT_GOAL,PROJECT_DEADLINE,PROJECT_CREATION_DATE,PROJECT_DESCRIPTION, 
      PROJECT_SUBTITLE,PROJECT_STREET_1,PROJECT_STREET_2,PROJECT_CITY,PROJECT_STATE,PROJECT_POSTAL_CODE,
      PROJECT_POSTAL_EXTENSION,PROJECT_STEPS_TO_TAKE, PROJECT_MOTIVATION, PROJECT_VOLUNTEER_NEED,PROJECT_STATUS,ACCOUNT_ID)
      SELECT MAX(PROJECT_ID) + 1, p_title, p_goal, p_deadline, NVL(p_creation_date, currentdate), p_description, p_subtitle, p_street_1, p_street_2, 
      p_city, p_state, p_postal_code, p_postal_extension, p_steps_to_take, p_motivation, myprojectvolunteer, myprojectstatus, p_account_id
      FROM I_PROJECT;

    COMMIT;

    EXCEPTION

    WHEN null_input_exists THEN
        DBMS_OUTPUT.PUT_LINE('Missing Input Data.'); 
        DBMS_OUTPUT.PUT_LINE('Please make sure to provide input for the following fields: ' || not_null_msg);
        ROLLBACK;
    WHEN invalid_description THEN
        DBMS_OUTPUT.PUT_LINE('Invalid description, please put '' in front and back of the text input.');
        ROLLBACK;
    WHEN invalid_goal THEN
        DBMS_OUTPUT.PUT_LINE('Invalid goal, please specify a goal larger than zero.'); 
        ROLLBACK;
    WHEN invalid_deadline THEN
        DBMS_OUTPUT.PUT_LINE('Invalid deadline, please set deadline to a larger value than the project creation date.');
        ROLLBACK;
    WHEN invalid_status THEN
        DBMS_OUTPUT.PUT_LINE('Invalid status, accepted input is Open, Underway, Closed and Submitted.');
        ROLLBACK;
    WHEN invalid_volunteer THEN
        DBMS_OUTPUT.PUT_LINE('Invalid volunteer, accepted input is yes and no.');  
        ROLLBACK;
    WHEN invalid_account THEN
        DBMS_OUTPUT.PUT_LINE('Invalid account, please specify a correct accound ID.'); 
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An Error occurred');
        DBMS_OUTPUT.PUT_LINE('The error number: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('The error message: ' || SQLERRM);
        ROLLBACK;
    END;
END CREATE_PROJECT_PP;

procedure CREATE_GIVING_LEVEL_PP (
p_projectID             IN INTEGER,
p_givingLevelAmt        IN NUMBER,         
p_givingDescription     IN VARCHAR     
)
IS 
BEGIN
    
    DECLARE
    null_input_exists   EXCEPTION;
	  invalid_input       EXCEPTION;
    invalid_amount      EXCEPTION;
    entry_exists        EXCEPTION;
    countItems          INT;
    not_null_msg        VARCHAR2(100) := NULL;
    mygivinglevel       VARCHAR2(100) := NULL;
  

BEGIN
  
  IF p_givingLevelAmt IS NULL THEN
        	SELECT not_null_msg || chr(10) || '  Giving Level Amount ' INTO not_null_msg FROM dual;
    	END IF;
	IF p_givingDescription IS NULL THEN
        	SELECT not_null_msg || chr(10) || '  Giving Description ' INTO not_null_msg FROM dual;
    	END IF;
  IF NOT not_null_msg IS NULL THEN
          RAISE null_input_exists;
      END IF;  
	
SELECT COUNT(*) INTO countItems FROM 
            I_PROJECT WHERE PROJECT_ID = p_projectID;
            IF countItems < 1 THEN
            RAISE invalid_input;
END IF;

IF p_givingLevelAmt <= 0 THEN
RAISE invalid_amount;

END IF;

SELECT COUNT(*) INTO countItems 
FROM I_GIVING_LEVEL 
WHERE GIVING_LEVEL_AMOUNT = p_givingLevelAmt AND PROJECT_ID = p_projectID;
IF countItems > 0 THEN
	UPDATE I_GIVING_LEVEL 
	SET GIVING_LEVEL_DESCRIPTION = p_givingDescription
  WHERE GIVING_LEVEL_AMOUNT = project_id;
  
  

ELSE
Insert into I_GIVING_LEVEL (PROJECT_ID,GIVING_LEVEL_AMOUNT,GIVING_LEVEL_DESCRIPTION)
VALUES(p_projectID, p_givingLevelAmt, p_givingDescription);

END IF;

        COMMIT;
      
EXCEPTION
        
        WHEN null_input_exists THEN
        	DBMS_OUTPUT.PUT_LINE('Missing Input Data.');
        	DBMS_OUTPUT.PUT_LINE('Please make sure to provide input for the following fields: ' || not_null_msg);
            ROLLBACK;
        WHEN invalid_input THEN 
          DBMS_OUTPUT.PUT_LINE('Project ID provided cannot be found.');
          ROLLBACK;
        WHEN invalid_amount THEN
          DBMS_OUTPUT.PUT_LINE('Invalid amount, must be greater than zero');
          ROLLBACK;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('An Error occurred');
            DBMS_OUTPUT.PUT_LINE('The error number: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('The error message: ' || SQLERRM);
            ROLLBACK;
    END;
END CREATE_GIVING_LEVEL_PP;

procedure ADD_BUDGET_ITEM_PP (
p_projectID             IN INTEGER,
p_description           IN VARCHAR,   
p_budgetAmt             IN NUMBER
)
IS 
BEGIN
  DECLARE
        invalid_input          EXCEPTION;
        description_exists    EXCEPTION;
        not_null_msg        VARCHAR2(100) := NULL;
        countItems              INT;
        null_input_exists       EXCEPTION;

BEGIN
	IF p_description IS NULL THEN
        	SELECT not_null_msg || chr(10) || '  Budget Description ' INTO not_null_msg FROM dual;
    	END IF;
  IF p_projectID IS NULL THEN
          SELECT not_null_msg || chr(10) || '  Project ID ' INTO not_null_msg FROM dual;
          END IF;
	
  IF NOT not_null_msg IS NULL THEN
            RAISE null_input_exists;
        END IF; 
  
SELECT COUNT(*) INTO countItems FROM 
            I_PROJECT WHERE PROJECT_ID = p_projectID;
            
            IF countItems < 1 THEN
            RAISE invalid_input;
END IF;



SELECT COUNT(*) INTO countItems FROM 
	I_BUDGET WHERE BUDGET_LINE_ITEM_DESCRIPTION = p_description;
	IF countItems > 0 THEN
	RAISE description_exists;
  END IF;

Insert into I_BUDGET (PROJECT_ID,BUDGET_LINE_ITEM_DESCRIPTION,BUDGET_LINE_ITEM_AMOUNT) 
VALUES (P_PROJECTID, P_DESCRIPTION, P_BUDGETAMT);


COMMIT;


      
EXCEPTION
    WHEN null_input_exists THEN
        DBMS_OUTPUT.PUT_LINE('Missing Input Data.');
        DBMS_OUTPUT.PUT_LINE('Please make sure to provide input for the following fields: ' || not_null_msg);
        ROLLBACK;
    WHEN invalid_input THEN 
        DBMS_OUTPUT.PUT_LINE
        ('Project ID provided cannot be found.');
        ROLLBACK;
WHEN description_exists THEN
            DBMS_OUTPUT.PUT_LINE('Description exists');
            ROLLBACK;
WHEN OTHERS THEN
	DBMS_OUTPUT.PUT_LINE('An Error occurred');
	DBMS_OUTPUT.PUT_LINE('The error number: ' || SQLCODE);
	DBMS_OUTPUT.PUT_LINE('The error message: ' || SQLERRM);
	ROLLBACK;
  END;
END ADD_BUDGET_ITEM_PP;

procedure ADD_WEBSITE_PP (
    p_accountEmail          IN VARCHAR,
    p_websiteOrder          IN INTEGER,  
    p_websiteTitle          IN VARCHAR,
    p_websiteURL            IN VARCHAR
)
IS
BEGIN
    DECLARE
        url_exists              EXCEPTION;
        no_account_exists       EXCEPTION;
        null_input_exists       EXCEPTION;

        not_null_msg            VARCHAR2(100) := NULL;
        accountId               INT;
        maxWebsiteOrder         INT;
        websiteOrder            INT;
        countItems              INT;
    BEGIN
        IF p_accountEmail IS NULL THEN 
            SELECT not_null_msg || chr(10) || '  Email ' INTO not_null_msg FROM dual;
        END IF;
        IF p_websiteURL IS NULL THEN 
            SELECT not_null_msg || chr(10) ||  '  URL ' INTO not_null_msg FROM dual;
        END IF;
        IF p_websiteTitle IS NULL THEN 
            SELECT not_null_msg || chr(10) || '  Description ' INTO not_null_msg FROM dual;
        END IF;
        IF NOT not_null_msg IS NULL THEN
            RAISE null_input_exists;
        END IF;
        
        SELECT Account_ID INTO accountId FROM I_ACCOUNT WHERE UPPER(ACCOUNT_EMAIL) = UPPER(p_accountEmail);
        IF accountId IS NULL THEN
            RAISE no_account_exists;
        END IF; 
        
        IF p_websiteOrder IS NULL OR p_websiteOrder < 1 THEN
            websiteOrder := -1;
        ELSE
            websiteOrder := p_websiteOrder;
        END IF;
        
        SELECT count(*) into countItems
        FROM I_WEBSITE 
        WHERE ACCOUNT_ID = accountId AND WEBSITE_URL = p_websiteURL;
        IF countItems > 0 THEN
            RAISE url_exists;
        END IF;
        
        SELECT count(*) into countItems
        FROM I_WEBSITE 
        WHERE ACCOUNT_ID = accountId;
        
        IF countItems > 0 THEN
            SELECT MAX(WEBSITE_ORDER) into maxWebsiteOrder 
            FROM I_WEBSITE 
            WHERE ACCOUNT_ID = accountId;
            
            IF websiteOrder > 0 AND maxWebsiteOrder >= websiteOrder THEN
                UPDATE I_WEBSITE
                SET WEBSITE_ORDER = WEBSITE_ORDER + 1
                WHERE ACCOUNT_ID = accountId AND WEBSITE_ORDER >=  websiteOrder;
                --websiteOrder := websiteOrder;
            ELSE
                websiteOrder := maxWebsiteOrder + 1;
            END IF;
        ELSE
            websiteOrder := 1;
        END IF;
        
        INSERT INTO I_WEBSITE 
            (ACCOUNT_ID, WEBSITE_ORDER, WEBSITE_TITLE, WEBSITE_URL)
            VALUES (accountId, websiteOrder, p_websiteTitle, p_websiteURL);
        DBMS_OUTPUT.PUT_LINE('A website has been added for account id: ' || accountId);        

        COMMIT;
        
    EXCEPTION
        WHEN null_input_exists THEN
            DBMS_OUTPUT.PUT_LINE('Missing Input Data.');
            DBMS_OUTPUT.PUT_LINE('Please make sure to provide input for the following fields: ' || not_null_msg);
            ROLLBACK;        
        WHEN no_account_exists THEN
            DBMS_OUTPUT.PUT_LINE('Account does not exist.');
            DBMS_OUTPUT.PUT_LINE('No account has been found for the email address provided. Please use a different email.');
            ROLLBACK;
        WHEN url_exists THEN
            DBMS_OUTPUT.PUT_LINE('Website already exists.');
            DBMS_OUTPUT.PUT_LINE('The provided website already exists for this account. Please use add a different url.');
            ROLLBACK;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('An Error occurred');
            DBMS_OUTPUT.PUT_LINE('The error number: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('The error message: ' || SQLERRM);
            ROLLBACK;    
    END;
END ADD_WEBSITE_PP;


procedure ADD_FOCUSAREA_PP (
p_project_ID            IN INTEGER,
p_focusArea             IN VARCHAR
)
IS 
BEGIN
DECLARE
        invalid_input       EXCEPTION;
        entry_exists        EXCEPTION;
        countItems          INT;
    BEGIN

        SELECT COUNT(*) INTO countItems FROM (
            SELECT 1 FROM I_PROJECT WHERE PROJECT_ID = p_project_ID
            UNION ALL
            SELECT 1 FROM I_FOCUS_AREA WHERE FOCUS_AREA_NAME = p_focusArea
            ) InputIsValid;
        IF countItems < 2 THEN
            RAISE invalid_input;
        ELSE 
            SELECT COUNT(*) INTO countItems 
            FROM I_PROJ_FOCUSAREA 
            WHERE FOCUS_AREA_NAME = p_focusArea AND PROJECT_ID = p_project_ID;

            IF countItems > 0 THEN
                RAISE entry_exists;
            ELSE
                INSERT INTO I_PROJ_FOCUSAREA 
                    (FOCUS_AREA_NAME, PROJECT_ID) 
                VALUES (p_focusArea, p_project_ID); 
            END IF;
        END IF;
        COMMIT;

    EXCEPTION
        WHEN invalid_input THEN 
            DBMS_OUTPUT.PUT_LINE('Project ID or Focus Area provided cannot be found.');
            DBMS_OUTPUT.PUT_LINE('Please use a Project ID and Focus Area that exists.');
            ROLLBACK;
        WHEN entry_exists THEN
            DBMS_OUTPUT.PUT_LINE('Project ID and Focus Area provided already exist.');
            DBMS_OUTPUT.PUT_LINE('Please add a new combination.');
            ROLLBACK;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('An Error occurred');
            DBMS_OUTPUT.PUT_LINE('The error number: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('The error message: ' || SQLERRM);
            ROLLBACK;
    END;
END ADD_FOCUSAREA_PP;

procedure ADD_PROJTYPE_PP (
p_project_ID            IN INTEGER,
p_projType              IN VARCHAR
)
IS
BEGIN
DECLARE
        invalid_input       EXCEPTION;
        entry_exists        EXCEPTION;
        countItems          INT;
    BEGIN
 
        SELECT COUNT(*) INTO countItems FROM (
            SELECT 1 FROM I_PROJECT WHERE PROJECT_ID = p_project_ID
            UNION ALL
            SELECT 1 FROM I_PROJECT_TYPE WHERE PROJECT_TYPE_NAME = p_projType
            ) InputIsValid;
        IF countItems < 2 THEN
            RAISE invalid_input;
        ELSE
            SELECT COUNT(*) INTO countItems
            FROM I_PROJ_PROJTYPE
            WHERE PROJECT_TYPE_NAME = p_projType AND PROJECT_ID = p_project_ID;
 
            IF countItems > 0 THEN
                RAISE entry_exists;
            ELSE
                INSERT INTO I_PROJ_PROJTYPE  
                    (PROJECT_TYPE_NAME, PROJECT_ID)
                VALUES (p_projType, p_project_ID);
            END IF;
        END IF;
        COMMIT;
 
    EXCEPTION
        WHEN invalid_input THEN
            DBMS_OUTPUT.PUT_LINE('Project ID or Project Type provided cannot be found.');
            DBMS_OUTPUT.PUT_LINE('Please use a Project Type and Focus Area that exists.');
        WHEN entry_exists THEN
            DBMS_OUTPUT.PUT_LINE('Project ID and Project Type provided already exist.');
            DBMS_OUTPUT.PUT_LINE('Please add a new combination.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('An Error occurred');
            DBMS_OUTPUT.PUT_LINE('The error number: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('The error message: ' || SQLERRM);
            ROLLBACK;
    END;
END ADD_PROJTYPE_PP;

procedure CREATE_ACCOUNT_PP (
  p_account_id      OUT INTEGER,
  p_email           IN VARCHAR,   
  p_password        IN VARCHAR,   
  p_location_name   IN VARCHAR,   
  p_account_type    IN VARCHAR,   -- should have value of 'Group or organization' or 'Individual'
  p_first_name      IN VARCHAR,   -- must not be NULL
  p_last_name       IN VARCHAR,   -- must not be NULL
  p_street          IN VARCHAR,   -- must not be NULL
  p_additional      IN VARCHAR,
  p_city            IN VARCHAR,   -- must not be NULL
  p_stateprovince   IN VARCHAR,   
  p_postalCode      IN CHAR,      -- nust not be NULL
  p_heardAbout      IN VARCHAR,   -- nust not be NULL
  p_heardAboutdetail IN VARCHAR
)
IS 
BEGIN
    DECLARE
        null_input_exists       EXCEPTION;
        incorrect_type          EXCEPTION;
        invalid_format          EXCEPTION;
        invalid_heardAbout      EXCEPTION;

        countItems              INT;
        not_null_msg            VARCHAR2(200) := NULL;
        myaccounttype           VARCHAR2(20) := NULL;
        myHeardAbout            VARCHAR(100) := NULL;
                
    BEGIN
        /* Validate the input data*/
        IF p_email IS NULL THEN 
            SELECT not_null_msg || chr(10) || '  Email ' INTO not_null_msg FROM dual;
        END IF;
        IF p_password IS NULL THEN 
            SELECT not_null_msg || chr(10) ||  '  Password ' INTO not_null_msg FROM dual;
        END IF;
        IF p_location_name IS NULL THEN 
            SELECT not_null_msg || chr(10) || '  Location Name ' INTO not_null_msg FROM dual;
        END IF;
        IF p_account_type IS NULL THEN 
            SELECT not_null_msg || chr(10) || '  Account Type ' INTO not_null_msg FROM dual;
        END IF;
        IF p_first_name IS NULL THEN 
            SELECT not_null_msg || chr(10) || '  First Name ' INTO not_null_msg FROM dual;
        END IF;
        IF p_last_name IS NULL THEN 
            SELECT not_null_msg || chr(10) || '  Last Name ' INTO not_null_msg FROM dual;
        END IF;
        IF p_street IS NULL THEN 
            SELECT not_null_msg || chr(10) || '  Street ' INTO not_null_msg FROM dual;
        END IF;
        IF p_city IS NULL THEN 
            SELECT not_null_msg || chr(10) || '  City ' INTO not_null_msg FROM dual;
        END IF;
        IF p_postalCode IS NULL THEN 
            SELECT not_null_msg || chr(10) || '  Postal Code ' INTO not_null_msg FROM dual;
        END IF;
        IF p_heardAbout IS NULL THEN 
            SELECT not_null_msg || chr(10) || '  Heard About ' INTO not_null_msg FROM dual;
        END IF;
        
        IF NOT not_null_msg IS NULL THEN
            RAISE null_input_exists;
        END IF; 

        /*Need to sanitize the account type and Heard About casing since there is a check constraint on the field*/
        myaccounttype := p_account_type;
        IF UPPER(myaccounttype) = 'GROUP OR ORGANIZATION' THEN
            myaccounttype := 'Group or organization';
        ELSIF  UPPER(myaccounttype) = 'INDIVIDUAL' THEN
            myaccounttype := 'Individual';
        ELSE
           RAISE incorrect_type; 
        END IF;
        myHeardAbout :=
                CASE LOWER(p_heardAbout)
                    WHEN 'another organization''s newsletter' THEN  'another organization''s newsletter'
                    WHEN 'by attending an ioby event' THEN 'another organization''s newsletter'
                    WHEN 'from a friend' THEN 'from a friend'
                    WHEN 'ioby email' THEN 'ioby email'
                    WHEN 'other' THEN 'other'
                    WHEN 'social media' THEN 'social media'
                    WHEN 'someone I know has used ioby' THEN 'someone I know has used ioby'
                    WHEN 'web search' THEN 'web search'
                    ELSE ''
                END;
        
        IF myHeardAbout = '' THEN
            RAISE invalid_format;
        END IF;
        
            
        IF NOT regexp_like(p_email, '[A-Z0-9._%-]+@[A-Z0-9._%-]+\.[A-Z]{2,4}', 'i') THEN
            RAISE invalid_format;
        END IF;    
        SELECT COUNT(*) INTO countItems FROM I_ACCOUNT WHERE UPPER(ACCOUNT_EMAIL) = UPPER(p_email);
        IF countItems > 0 THEN
            UPDATE I_ACCOUNT
            SET ACCOUNT_PASSWORD = p_password
                , ACCOUNT_LOCATION_NAME = p_location_name
                , ACCOUNT_TYPE = myaccounttype
                , ACCOUNT_FIRST_NAME = p_first_name
                , ACCOUNT_LAST_NAME = p_last_name
                , ACCOUNT_STREET = p_street
                , ACCOUNT_ADDITIONAL = p_additional
                , ACCOUNT_CITY = p_city
                , ACCOUNT_STATE_PROVINCE = p_stateprovince
                , ACCOUNT_POSTAL_CODE = SUBSTR(p_postalCode,1,5)
                , ACCOUNT_HEARD_ABOUT = myHeardAbout
                , ACCOUNT_HEARD_ABOUT_DETAIL = p_heardAboutdetail
            WHERE UPPER(ACCOUNT_EMAIL) = UPPER(p_email);
           
            SELECT MAX(ACCOUNT_ID) INTO p_account_id FROM I_ACCOUNT WHERE UPPER(ACCOUNT_EMAIL) = UPPER(p_email);
            
            DBMS_OUTPUT.PUT_LINE('An account has been updated with the given info. The account id is: ' || p_account_id);
        ELSE
            INSERT INTO I_ACCOUNT 
                (ACCOUNT_ID, ACCOUNT_EMAIL, ACCOUNT_PASSWORD, ACCOUNT_LOCATION_NAME, ACCOUNT_TYPE, ACCOUNT_FIRST_NAME
                 , ACCOUNT_LAST_NAME, ACCOUNT_STREET, ACCOUNT_ADDITIONAL, ACCOUNT_CITY, ACCOUNT_STATE_PROVINCE
                 , ACCOUNT_POSTAL_CODE, ACCOUNT_HEARD_ABOUT, ACCOUNT_HEARD_ABOUT_DETAIL)
            SELECT MAX(ACCOUNT_ID) + 1 MyAccountID, p_email, p_password, p_location_name, myaccounttype, p_first_name
                 , p_last_name, p_street, p_additional, p_city, p_stateprovince
                 , SUBSTR(p_postalCode,1,5) MyPostalCode, myHeardAbout, p_heardAboutdetail
            FROM I_ACCOUNT;   
            
            SELECT MAX(ACCOUNT_ID) INTO p_account_id FROM I_ACCOUNT WHERE UPPER(ACCOUNT_EMAIL) = UPPER(p_email);
            
            DBMS_OUTPUT.PUT_LINE('An account has been created with the given info. The account id is: ' || p_account_id);
        END IF;  
  
        COMMIT;

    EXCEPTION
        WHEN null_input_exists THEN
            DBMS_OUTPUT.PUT_LINE('Missing Input Data.'); 
            DBMS_OUTPUT.PUT_LINE('Please make sure to provide input for the following fields: ' || not_null_msg);
            ROLLBACK;
        WHEN incorrect_type THEN
            DBMS_OUTPUT.PUT_LINE('Incorrect Account Type Defined.'); 
            DBMS_OUTPUT.PUT_LINE('Account Type should have value of ''Group or organization'' or ''Individual''');
            ROLLBACK;
        WHEN invalid_heardAbout THEN
            DBMS_OUTPUT.PUT_LINE('Incorrect Heard About provided.'); 
            DBMS_OUTPUT.PUT_LINE('Please pick one of the following valid options:');
            DBMS_OUTPUT.PUT_LINE('another organization''s newsletter, by attending an ioby event, from a friend, ioby email, ');
            DBMS_OUTPUT.PUT_LINE('other, social media, someone I know has used ioby, web search ');
            ROLLBACK;
        WHEN invalid_format THEN
            DBMS_OUTPUT.PUT_LINE('Email Address not valid.');
            DBMS_OUTPUT.PUT_LINE('The format of the email address is not valid. Please use a different email.'); 
            ROLLBACK;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('An Error occurred');
            DBMS_OUTPUT.PUT_LINE('The error number: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('The error message: ' || SQLERRM);
            ROLLBACK;   
    END;
END CREATE_ACCOUNT_PP; 

procedure ADD_DONATION_PP (
  p_projectID       IN INTEGER,
  p_accountEmail    IN VARCHAR,
  p_amount          IN NUMBER     -- must not be NULL; must be > 0
)
IS 
BEGIN
    DECLARE
    null_input_exists       EXCEPTION;
    invalid_amount          EXCEPTION;
    invalid_account         EXCEPTION;
    invalid_project         EXCEPTION;
    repeat_project          EXCEPTION;
    
    myAccountID             INT;
    myOrderNum              INT;
    countItems              INT;
    not_null_msg            VARCHAR2(100) := NULL;
    
    BEGIN
        --Start TABLE ALTER
        --Since the donation cart lacks an accountId, we will create a new I_CART table.
        SELECT count(*) Into countItems 
        FROM ALL_TAB_COLS
        WHERE UPPER(table_name) = 'I_CART' and UPPER(column_name) = 'ACCOUNT_ID';
        IF countItems < 1 THEN
            EXECUTE IMMEDIATE '  CREATE TABLE I_CART 
                                   (DONATION_DETAIL_AMOUNT NUMBER(7,2), 
                                    ACCOUNT_ID NUMBER(*,0),
                                    PROJECT_ID NUMBER(*,0)
                                   )';
        END IF;
        --END TABLE ALTER 
        
         /* Validate the input data*/
        IF p_accountEmail IS NULL THEN 
            SELECT not_null_msg || chr(10) || '  Email ' INTO not_null_msg FROM dual;
        END IF;
        IF p_amount IS NULL THEN 
            SELECT not_null_msg || chr(10) ||  '  Amount ' INTO not_null_msg FROM dual;
        END IF;
        IF p_projectID IS NULL THEN 
            SELECT not_null_msg || chr(10) ||  '  Project_ID ' INTO not_null_msg FROM dual;
        END IF;
        IF NOT not_null_msg IS NULL THEN
            RAISE null_input_exists;
        END IF; 
        IF p_amount <= 0 THEN
            RAISE invalid_amount;
        END IF;
        
        SELECT COUNT(*) INTO countItems FROM I_ACCOUNT WHERE UPPER(ACCOUNT_EMAIL) = UPPER(p_accountEmail);
        IF countItems < 1 THEN 
            RAISE invalid_account;
        END IF;
        SELECT Account_ID INTO myAccountID FROM I_ACCOUNT WHERE UPPER(ACCOUNT_EMAIL) = UPPER(p_accountEmail);       

        SELECT COUNT(*) INTO countItems FROM I_PROJECT WHERE project_id = p_projectID;
        IF countItems < 1 THEN 
            RAISE invalid_project;
        END IF;
        
        SELECT COUNT(*) INTO countItems FROM I_CART WHERE ACCOUNT_ID = myAccountID AND project_id = p_projectID;
        IF countItems > 0 THEN 
            RAISE repeat_project;
        END IF;
        
        INSERT INTO I_CART
        (DONATION_DETAIL_AMOUNT, PROJECT_ID, ACCOUNT_ID)
        SELECT p_amount, p_projectID, myAccountID 
        FROM dual;        
        
        DBMS_OUTPUT.PUT_LINE('Inserted a cart entry for Account/Project: ' || myAccountID || '/' || p_projectID);
              
        COMMIT;

    EXCEPTION
        WHEN null_input_exists THEN
            DBMS_OUTPUT.PUT_LINE('Missing Input Data.'); 
            DBMS_OUTPUT.PUT_LINE('Please make sure to provide input for the following fields: ' || not_null_msg);
            ROLLBACK;
        WHEN invalid_amount THEN
            DBMS_OUTPUT.PUT_LINE('Invalid amount.');
            DBMS_OUTPUT.PUT_LINE('Please make sure to provide an amount with a value greater than 0.');
            ROLLBACK;
        WHEN invalid_account THEN
            DBMS_OUTPUT.PUT_LINE('Invalid account.');
            DBMS_OUTPUT.PUT_LINE('Account email that was provided (' || p_accountEmail || ') cannot be found. Please use an email that exists.');
            ROLLBACK;
        WHEN invalid_project THEN
            DBMS_OUTPUT.PUT_LINE('Invalid project.');
            DBMS_OUTPUT.PUT_LINE('Project Id that was provided (' || p_projectID || ') cannot be found. Please use a project Id that exists.'); 
            ROLLBACK;
        WHEN repeat_project THEN
            DBMS_OUTPUT.PUT_LINE('Invalid project.');
            DBMS_OUTPUT.PUT_LINE('Project Id that was provided (' || p_projectID || ') is already in the donation cart. Please use a new project Id.'); 
            ROLLBACK;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('An Error occurred');
            DBMS_OUTPUT.PUT_LINE('The error number: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('The error message: ' || SQLERRM);
            ROLLBACK;
    END;
END ADD_DONATION_PP;


procedure UPDATE_DONATION_PP (
  p_projectID       IN INTEGER,
  p_accountEmail    IN VARCHAR,
  p_amount          IN NUMBER     -- must not be NULL; must be > 0
)
IS 
BEGIN
    DECLARE
    null_input_exists       EXCEPTION;
    invalid_amount          EXCEPTION;
    invalid_account         EXCEPTION;
    invalid_project         EXCEPTION;
    invalid_donation        EXCEPTION;
    
    myAccountID             INT;
    myOrderNum              INT;
    countItems              INT;
    not_null_msg            VARCHAR2(100) := NULL;
    
    BEGIN
         /* Validate the input data*/
        IF p_accountEmail IS NULL THEN 
            SELECT not_null_msg || chr(10) || '  Email ' INTO not_null_msg FROM dual;
        END IF;
        IF p_amount IS NULL THEN 
            SELECT not_null_msg || chr(10) ||  '  Amount ' INTO not_null_msg FROM dual;
        END IF;
        IF p_projectID IS NULL THEN 
            SELECT not_null_msg || chr(10) ||  '  Project_ID ' INTO not_null_msg FROM dual;
        END IF;
        IF NOT not_null_msg IS NULL THEN
            RAISE null_input_exists;
        END IF; 
        IF p_amount <= 0 THEN
            RAISE invalid_amount;
        END IF;
        SELECT COUNT(*) INTO countItems FROM I_PROJECT WHERE project_id = p_projectID;
        IF countItems < 1 THEN 
            RAISE invalid_project;
        END IF;
        
        --Check I_ACCOUNT to make sure email is valid
        SELECT COUNT(*) INTO countItems FROM I_ACCOUNT WHERE UPPER(ACCOUNT_EMAIL) = UPPER(p_accountEmail);
        IF countItems < 1 THEN 
            RAISE invalid_account;
        END IF;
        SELECT Account_ID INTO myAccountID FROM I_ACCOUNT WHERE UPPER(ACCOUNT_EMAIL) = UPPER(p_accountEmail);       
        --
        
        SELECT COUNT(*) INTO countItems FROM I_CART WHERE ACCOUNT_ID = myAccountID AND PROJECT_ID = p_projectID;
        IF countItems < 1  THEN
            RAISE invalid_donation;
        END IF;
        
        UPDATE I_CART
        SET DONATION_DETAIL_AMOUNT = p_amount
        WHERE ACCOUNT_ID = myAccountID AND PROJECT_ID = p_projectID; 
        
        DBMS_OUTPUT.PUT_LINE('Updated the amount for Account/Project: ' || myAccountID || '/' || p_projectID);
        
        COMMIT;
        
    EXCEPTION
        WHEN null_input_exists THEN
            DBMS_OUTPUT.PUT_LINE('Missing Input Data.'); 
            DBMS_OUTPUT.PUT_LINE('Please make sure to provide input for the following fields: ' || not_null_msg);
            ROLLBACK;
        WHEN invalid_amount THEN
            DBMS_OUTPUT.PUT_LINE('Invalid amount.');
            DBMS_OUTPUT.PUT_LINE('Please make sure to provide an amount with a value greater than 0.');
            ROLLBACK;
        WHEN invalid_account THEN
            DBMS_OUTPUT.PUT_LINE('Invalid account.');
            DBMS_OUTPUT.PUT_LINE('Account email that was provided (' || p_accountEmail || ') cannot be found. Please use an email that exists.');
            ROLLBACK;
        WHEN invalid_project THEN
            DBMS_OUTPUT.PUT_LINE('Invalid project.');
            DBMS_OUTPUT.PUT_LINE('Project Id that was provided (' || p_projectID || ') cannot be found. Please use a project Id that exists.'); 
            ROLLBACK;
        WHEN invalid_donation THEN
            DBMS_OUTPUT.PUT_LINE('Invalid donation.');
            DBMS_OUTPUT.PUT_LINE('The donation identified to update cannot be found. Please use different information.'); 
            ROLLBACK;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('An Error occurred');
            DBMS_OUTPUT.PUT_LINE('The error number: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('The error message: ' || SQLERRM);
            ROLLBACK;
    END;
END UPDATE_DONATION_PP;


procedure VIEW_CART_PP (
  p_accountEmail    IN VARCHAR
)
IS 
BEGIN
    DECLARE
        null_input_exists       EXCEPTION;
        invalid_account         EXCEPTION;
        
        cartTotal               NUMBER := 0;
        countItems              INT;
        not_null_msg            VARCHAR2(100) := NULL;
     
    BEGIN
        /* Validate the input data*/
        IF p_accountEmail IS NULL THEN 
            SELECT not_null_msg || chr(10) || '  Email ' INTO not_null_msg FROM dual;
        END IF;
        
        IF NOT not_null_msg IS NULL THEN
            RAISE null_input_exists;
        END IF; 
        
        SELECT COUNT(*) INTO countItems FROM I_ACCOUNT WHERE UPPER(ACCOUNT_EMAIL) = UPPER(p_accountEmail);
        IF countItems < 1 THEN 
            RAISE invalid_account;
        END IF;
        
        DBMS_OUTPUT.PUT_LINE(RPAD('Project',50) || LPAD('Total',30));
        
        BEGIN
            FOR donation_rec IN (
                SELECT MyPROJECT, DONATION_DETAIL_AMOUNT MyTotal
                FROM I_CART
                INNER JOIN I_ACCOUNT ON I_ACCOUNT.ACCOUNT_ID = I_CART.ACCOUNT_ID
                OUTER APPLY (
                    SELECT PROJECT_TITLE MyPROJECT
                    FROM I_PROJECT
                    WHERE I_PROJECT.PROJECT_ID = I_CART.PROJECT_ID
                )
                WHERE UPPER(ACCOUNT_EMAIL) = UPPER(p_accountEmail) 
            )
            LOOP
                cartTotal := cartTotal + donation_rec.MyTotal;
                DBMS_OUTPUT.PUT_LINE( RPAD(donation_rec.myproject,50) || LPAD(donation_rec.MyTotal,30));
            END LOOP;
        END;
        
        DBMS_OUTPUT.PUT_LINE( RPAD('Order Total',50) || LPAD(cartTotal,30));
                
        COMMIT;
    EXCEPTION
        WHEN null_input_exists THEN
            DBMS_OUTPUT.PUT_LINE('Missing Input Data.'); 
            DBMS_OUTPUT.PUT_LINE('Please make sure to provide input for the following fields: ' || not_null_msg);
            ROLLBACK;
       WHEN invalid_account THEN
            DBMS_OUTPUT.PUT_LINE('Account Email not found.');
            DBMS_OUTPUT.PUT_LINE('Please make sure to provide an email for an existing account.');
            DBMS_OUTPUT.PUT_LINE(' Email (' || p_accountEmail || ') cannot be found.');
            ROLLBACK;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('An Error occurred');
            DBMS_OUTPUT.PUT_LINE('The error number: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('The error message: ' || SQLERRM);
            ROLLBACK;      
    END;
    
END VIEW_CART_PP;

procedure CHECKOUT_PP (
  p_accountEmail    IN VARCHAR,      -- Must not be NULL
  p_date            IN DATE,         -- If NULL, use CURRENT_DATE
  p_anonymous       IN VARCHAR,      -- default value is 'yes'.  
  p_displayName     IN VARCHAR,    
  p_giveEmail       IN VARCHAR,      -- default value is 'no'
  p_billingFirstName IN VARCHAR,
  p_billingLastName IN VARCHAR,      -- must not be NULL
  p_billingAddress  IN VARCHAR,      -- must not be NULL
  p_billingState    IN VARCHAR,      -- must not be NULL
  p_zipcode         IN VARCHAR,      -- must not be NULL
  p_country         IN VARCHAR,      -- must not be NULL
  p_creditCard      IN VARCHAR,      -- must not be NULL
  p_expMonth        IN NUMBER,       -- must not be NULL
  p_expYear         IN NUMBER,       -- must be > 2015
  p_secCode         IN NUMBER,       -- must not be NULL
  p_orderNumber    OUT NUMBER
)
IS
BEGIN

DECLARE
        null_input_exists       EXCEPTION;
        incorrect_type          EXCEPTION;
        no_cart                 EXCEPTION;
        invalid_account         EXCEPTION;
        invalid_cardData        EXCEPTION;

        countItems              INT;
        myProjectID             INT;
        myOrderNum              INT;
        myAccountID             NUMBER;
        user_anonymous          VARCHAR2(100) := NULL;
        giving_mail             VARCHAR2(100) := NULL;
        not_null_msg            VARCHAR2(200) := NULL;
        myDate                  DATE := SYSDATE;
        myCard                  VARCHAR2(20) := NULL;
               
    BEGIN
        /* Validate the input data*/
        IF p_accountEmail IS NULL THEN 
            SELECT not_null_msg || chr(10) || '  Email ' INTO not_null_msg FROM dual;
        END IF;
        IF  p_billingLastName IS NULL THEN 
            SELECT not_null_msg || chr(10) ||  '  Billing Last Name ' INTO not_null_msg FROM dual;
        END IF;
        IF p_billingAddress IS NULL THEN 
            SELECT not_null_msg || chr(10) || '  Billing Address ' INTO not_null_msg FROM dual;
        END IF;
        IF p_billingState IS NULL THEN 
            SELECT not_null_msg || chr(10) ||  '  Billing State ' INTO not_null_msg FROM dual;
        END IF;
        IF p_zipcode IS NULL THEN 
            SELECT not_null_msg || chr(10) ||  '  Zipcode ' INTO not_null_msg FROM dual;
        END IF;
        IF p_country IS NULL THEN 
            SELECT not_null_msg || chr(10) ||  '  Country ' INTO not_null_msg FROM dual;
        END IF;
        IF p_creditCard IS NULL THEN 
            SELECT not_null_msg || chr(10) ||  '  Credit Card ' INTO not_null_msg FROM dual;
        END IF;
        IF p_expMonth IS NULL THEN 
            SELECT not_null_msg || chr(10) ||  '  Expiry Month ' INTO not_null_msg FROM dual;
        END IF;
        IF p_expYear IS NULL THEN 
            SELECT not_null_msg || chr(10) ||  '  Expiry Year ' INTO not_null_msg FROM dual;
        END IF;
        IF p_secCode IS NULL THEN 
            SELECT not_null_msg || chr(10) ||  '  Security Code ' INTO not_null_msg FROM dual;
        END IF;
       
        IF NOT not_null_msg IS NULL THEN
            RAISE null_input_exists;
        END IF; 
        
        SELECT COUNT(*) INTO countItems FROM I_ACCOUNT WHERE UPPER(ACCOUNT_EMAIL) = UPPER(p_accountEmail);
        IF countItems < 1 THEN 
            RAISE invalid_account;
        END IF;
        SELECT Account_ID INTO myAccountID FROM I_ACCOUNT WHERE UPPER(ACCOUNT_EMAIL) = UPPER(p_accountEmail); 
        
        myDate := p_date;
        IF myDate IS NULL THEN
            SELECT CURRENT_DATE INTO myDate FROM dual;
        END IF;
        
        user_anonymous := p_anonymous;
        IF user_anonymous IS NULL THEN
            user_anonymous := 'yes';
        ELSIF UPPER(user_anonymous) = 'YES' THEN
            user_anonymous := 'yes';
        ELSIF UPPER(user_anonymous) = 'NO' THEN
            user_anonymous := 'no';
        ELSE
            RAISE incorrect_type; 
        END IF;
        
        giving_mail := p_giveEmail;
        IF giving_mail IS NULL THEN
            giving_mail := 'no';
        ELSIF UPPER(giving_mail) = 'NO' THEN
            giving_mail := 'no';
        ELSIF UPPER(giving_mail) = 'YES' THEN
            giving_mail := 'yes';
        ELSE
            RAISE incorrect_type; 
        END IF;
        
        IF (NOT p_expMonth BETWEEN 1 AND 12) OR (NOT p_expYear BETWEEN 2000 AND 2050) THEN
            RAISE invalid_cardData;
        END IF;
        
        SELECT COUNT(*) INTO countItems FROM I_CART WHERE ACCOUNT_ID = myAccountID;
        IF countItems < 1  THEN
            RAISE no_cart;
        END IF;
        
        SELECT MAX(donation_order_number) + 1 INTO myOrderNum FROM I_DONATION WHERE ACCOUNT_ID = myAccountID; 
        
        INSERT INTO I_DONATION
        (DONATION_ORDER_NUMBER, DONATION_DATE, DONATION_ANONYMOUS, DONATION_DISPLAY_NAME, DONATION_GIVE_EMAIL, DONATION_TOTAL, ACCOUNT_ID)
        SELECT myOrderNum, myDate, user_anonymous, p_displayName, giving_mail, SUM(DONATION_DETAIL_AMOUNT) MyTotal, myAccountID
        FROM I_CART
        WHERE ACCOUNT_ID = myAccountID;
        
        INSERT INTO I_BILLING 
                (BILLING_FIRST_NAME, BILLING_COUNTRY, BILLING_LAST_NAME, BILLING_ADDRESS_1
                , BILLING_STATE, BILLING_ZIPCODE, BILLING_CARD_NUMBER, BILLING_CARD_EXP_MONTH
                , BILLING_CARD_EXP_YEAR, BILLING_CARD_SECURITY_CODE, DONATION_ORDER_NUMBER)
        VALUES (p_billingFirstName, p_country, p_billingLastName,p_billingAddress
                , p_billingState,p_zipcode, SUBSTR(p_creditCard,0,16),p_expMonth
                , p_expYear, p_secCode, myOrderNum); 
        
        BEGIN
            FOR donation_rec IN (
                SELECT DONATION_DETAIL_AMOUNT, PROJECT_ID
                FROM I_CART
                WHERE ACCOUNT_ID = myAccountID
            )
            LOOP
                INSERT INTO I_DONATION_DETAIL
                (DONATION_DETAIL_AMOUNT, DONATION_ORDER_NUMBER, PROJECT_ID, DONATION_DETAIL_ID)
                SELECT donation_rec.DONATION_DETAIL_AMOUNT,  myOrderNum, donation_rec.PROJECT_ID
                        , MAX (DONATION_DETAIL_ID) + 1 
                FROM I_DONATION_DETAIL;           
            END LOOP;
        END;
        
        p_orderNumber := myOrderNum;
        DBMS_OUTPUT.PUT_LINE('Completed checkout for Order # : ' || myOrderNum);
          
        COMMIT;

        DELETE FROM I_CART WHERE ACCOUNT_ID = myAccountId;
        
        DBMS_OUTPUT.PUT_LINE('Cleared donation cart for Account Id : ' || myAccountId);
        COMMIT;
        
        EXCEPTION
        WHEN null_input_exists THEN
            DBMS_OUTPUT.PUT_LINE('Missing Input Data.'); 
            DBMS_OUTPUT.PUT_LINE('Please make sure to provide input for the following fields: ' || not_null_msg);
            ROLLBACK;
        WHEN incorrect_type THEN
            DBMS_OUTPUT.PUT_LINE('Incorrect Type Defined.'); 
            DBMS_OUTPUT.PUT_LINE('Provided selection for yes/no option on anonymous/show email is incorrect.');
            ROLLBACK;
        WHEN invalid_cardData THEN
            DBMS_OUTPUT.PUT_LINE('Incorrect Card Data.'); 
            DBMS_OUTPUT.PUT_LINE('The credit card information that has been provided is not valid. Please use a different credit card.');
            ROLLBACK;
        WHEN no_cart THEN
            DBMS_OUTPUT.PUT_LINE('Donation Cart Not Found.');
            DBMS_OUTPUT.PUT_LINE('A cart does not exist for the provided email. Please check the Cart to make sure there are donations.');
            ROLLBACK;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('An Error occurred');
            DBMS_OUTPUT.PUT_LINE('The error number: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('The error message: ' || SQLERRM);
            ROLLBACK;   
    END;
END CHECKOUT_PP;

function CALC_PERCENT_OF_GOAL_PF (
  p_projectID       IN Integer
) RETURN NUMBER
IS BEGIN
    DECLARE
        invalid_input          EXCEPTION;
        
        myProjectID            INT := NULL;
        goalPercent            INT;
    BEGIN
        SELECT PROJECT_ID INTO myProjectID 
        FROM I_PROJECT
        WHERE PROJECT_ID =  p_projectID;
        
        IF myProjectID IS NULL OR myProjectID < 1 THEN
            RAISE invalid_input;
        END IF;
        
        SELECT ROUND(CurAmount/PROJECT_GOAL * 100) INTO goalPercent
        FROM I_PROJECT
        OUTER APPLY (
            SELECT SUM(DONATION_DETAIl_AMOUNT) CurAmount 
            FROM I_DONATION_DETAIL 
            WHERE I_DONATION_DETAIL.PROJECT_ID =  I_PROJECT.PROJECT_ID 
        ) CurrentAmount
        WHERE PROJECT_ID =  myProjectID;
        
        DBMS_OUTPUT.PUT_LINE('Percent of goal reached is: ' || goalPercent || '%');
        
        RETURN goalPercent;
    EXCEPTION
        WHEN invalid_input THEN
            DBMS_OUTPUT.PUT_LINE('Missing project number');
            DBMS_OUTPUT.PUT_LINE('Project number (' || p_projectID || ') not found. Please provide a valid project number.');
            RETURN -1;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('An Error occurred');
            DBMS_OUTPUT.PUT_LINE('The error number: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('The error message: ' || SQLERRM);
            RETURN -42;   
    END;
END CALC_PERCENT_OF_GOAL_PF;


procedure STATUS_UNDERWAY_PP
IS
BEGIN
    DECLARE
        countItems            INT := 0;
    BEGIN
        BEGIN
            FOR project_rec IN (
                SELECT PROJECT_ID, CurrentAmount, PROJECT_TITLE
                FROM I_PROJECT
                OUTER APPLY (
                    SELECT SUM(DONATION_DETAIL_AMOUNT) CurrentAmount
                    FROM I_DONATION_DETAIL
                    WHERE I_DONATION_DETAIL.PROJECT_ID = I_PROJECT.PROJECT_ID
                ) MyProgress
                WHERE PROJECT_STATUS = 'Open' AND CurrentAmount >= PROJECT_GOAL
            )
            LOOP
               UPDATE I_PROJECT
               SET PROJECT_STATUS = 'Underway'
               WHERE PROJECT_ID = project_rec.PROJECT_ID;
               DBMS_OUTPUT.PUT_LINE('Project ' || project_rec.PROJECT_TITLE || ' has reached its funding goal. Status updated to Underway');
               countItems := countItems + 1;
            END LOOP;
        END;
        
        IF countItems < 1 THEN
            DBMS_OUTPUT.PUT_LINE('No open projects found that have met their funding goal.');
        END IF;
           
    COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('An Error occurred');
            DBMS_OUTPUT.PUT_LINE('The error number: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('The error message: ' || SQLERRM);
            ROLLBACK;
    END;        
END STATUS_UNDERWAY_PP;

END ioby3b_pkg;
