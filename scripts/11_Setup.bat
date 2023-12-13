REM --------------------------------------------------------
REM                   MANGED DEPENDENCIES                  -
REM --------------------------------------------------------
REM Lightweight - Apex Unit Test Util v2@2.3.0-2
sf package install -p "04tP30000007oePIAQ" -w 30

REM Lightweight - REST Util@0.10.0-1
sf package install -p "04tP30000007sN3IAI" -w 30

REM Lightweight - Auth Provider Util v2@0.10.0-1
sf package install -p "04tP3000000ET0XIAW" -w 30


REM --------------------------------------------------------
REM                      MAIN PACKAGE                      -
REM --------------------------------------------------------
REM Lightweight - Salesforce Auth Provider@0.2.0-1
sf package install -p "04tP3000000EardIAC" -w 30


REM --------------------------------------------------------
REM                  ASSIGN PERMISSION SETS                -
REM --------------------------------------------------------
sf org assign permset --name "Lightweight_Apex_Unit_Test_Util_v2"
sf org assign permset --name "Lightweight_REST_Util"
sf org assign permset --name "Lightweight_Auth_Provider_Util"
sf org assign permset --name "Lightweight_Salesforce_Auth_Provider"