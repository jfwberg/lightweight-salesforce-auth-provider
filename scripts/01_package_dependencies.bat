REM --------------------------------------------------------
REM MANGED DEPENDENCIES (PICK EITHER MANAGED OR UNLOCKED)  -
REM --------------------------------------------------------
rem Lightweight - Apex Unit Test Util v2@2.3.0-2
sf package install -p "04tP30000007oePIAQ" -w 30

rem Lightweight - REST Util@0.10.0-1
sf package install -p "04tP30000007sN3IAI" -w 30

REM ----------------- OPTIONAL BUT ADVICED -----------------
rem Lightweight - Auth Provider Util v2@0.7.0-1
sf package install -p "04tP3000000DZxdIAG" -w 30


REM --------------------------------------------------------
REM UNLOCKED DEPENDENCIES (PICK EITHER MANAGED OR UNLOCKED)-
REM --------------------------------------------------------
rem Lightweight - Apex Unit Test Util v2 (Unlocked)@2.3.0-2
sf package install -p "04tP30000007og1IAA" -w 30

rem Lightweight - REST Util (Unlocked)@0.10.0-1
sf package install -p "04tP30000007sQHIAY" -w 30

REM ----------------- OPTIONAL BUT ADVICED -----------------
rem Lightweight - Auth Provider Util v2 (Unlocked)@0.7.0-1
sf package install -p "04tP3000000Da0rIAC" -w 30


REM --------------------------------------------------------
REM                  ASSIGN PERMISSION SETS                -
REM --------------------------------------------------------
sf org assign permset --name "Lightweight_Apex_Unit_Test_Util_v2"
sf org assign permset --name "Lightweight_REST_Util"
sf org assign permset --name "Lightweight_Auth_Provider_Util_Admin"
sf org assign permset --name "Lightweight_Salesforce_Auth_Provider"
