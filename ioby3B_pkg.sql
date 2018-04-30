--------------------------------------------------------
--  File created - Tuesday-April-17-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package IOBY3B_PKG
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "PENDING"."IOBY3B_PKG" 
IS
procedure CREATE_ACCOUNT_PP (
  p_account_id      OUT INTEGER,
  p_email           IN VARCHAR,   -- must not be NULL
  p_password        IN VARCHAR,   -- must not be NULL
  p_location_name   IN VARCHAR,   -- must not be NULL
  p_account_type    IN VARCHAR,   -- should have value of 'Group or organization' or 'Individual'
  p_first_name      IN VARCHAR,
  p_last_name       IN VARCHAR
);
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
);
procedure   CREATE_GIVING_LEVEL_PP (
p_projectID             IN INTEGER,
p_givingLevelAmt        IN NUMBER,         
p_givingDescription     IN VARCHAR     
);
procedure ADD_BUDGET_ITEM_PP (
p_projectID             IN INTEGER,
p_description           IN VARCHAR,   
p_budgetAmt             IN NUMBER
);
procedure ADD_WEBSITE_PP (
p_accountEmail          IN VARCHAR,
p_websiteOrder          IN INTEGER,  
p_websiteTitle          IN VARCHAR,
p_websiteURL            IN VARCHAR
);
procedure ADD_FOCUSAREA_PP (
p_project_ID            IN INTEGER,
p_focusArea             IN VARCHAR
);
procedure ADD_PROJTYPE_PP (
p_project_ID            IN INTEGER,
p_projType              IN VARCHAR
);
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
);
procedure ADD_DONATION_PP (
  p_projectID       IN INTEGER,
  p_accountEmail    IN VARCHAR,
  p_amount          IN NUMBER     -- must not be NULL; must be > 0
);
procedure UPDATE_DONATION_PP (
  p_projectID       IN INTEGER,
  p_accountEmail    IN VARCHAR,
  p_amount          IN NUMBER     -- must not be NULL; must be > 0
);
procedure VIEW_CART_PP (
  p_accountEmail    IN VARCHAR
);
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
);
function CALC_PERCENT_OF_GOAL_PF (
  p_projectID       IN Integer
) RETURN NUMBER;
procedure STATUS_UNDERWAY_PP;
end ioby3b_pkg;
