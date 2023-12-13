/**
 * @author      Justus van den Berg (jfwberg@gmail.com)
 * @date        October 2023 
 * @copyright   (c) 2023 Justus van den Berg
 * @license     MIT (See LICENSE file in the project root)
 * @description Class for testing the SalesforceAuthProvider Methods
 */
@IsTest
private with sharing class SalesforceAuthProviderTest{
    
    /** **************************************************************************************************** **
     **                                        PRIVATE TEST CONSTANTS                                        **
     ** **************************************************************************************************** **/
     // User for the running the tests
    private static final User FIRST_USER  = utl.Tst.createRunAsUser(utl.Tst.MINIMUM_ACCESS_PROFILE, 'Lightweight_Salesforce_Auth_Provider');
    private static final User SECOND_USER = utl.Tst.createRunAsUser(utl.Tst.MINIMUM_ACCESS_PROFILE, 'Lightweight_Salesforce_Auth_Provider');

    
    /** **************************************************************************************************** **
     **                                      PRIVATE TEST DATA VARIABLES                                     **
     ** **************************************************************************************************** **/    
    // Variables for holding test data
    private static String                 authProviderName = 'myAuthProvider';
    private static SalesforceAuthProvider authProvider;
    private static Map<String,String>     authProviderConfig; 

    /**
     * @description Method to Override the user config and enable "per user" mode
     */
    static void setPerUserConfiguration(){
        // Update Config
        getAuthProviderConfig().put(SalesforceAuthProvider.ENABLE_PER_USER_MODE_FIELD_NAME, 'true');
        getAuthProviderConfig().put(SalesforceAuthProvider.ENABLE_LOGIN_LOGGING_FIELD_NAME, 'true');
        getAuthProviderConfig().put(SalesforceAuthProvider.ENABLE_ERROR_LOGGING_FIELD_NAME, 'true');
        
        // Setup the response from the callable action
        utl.Clbl.setActionResponse('updateMappingLoginDetails', null);
        utl.Clbl.setActionResponse('checkUserMappingExists',    true);
        utl.Clbl.setActionResponse('insertLoginHistoryRecord',  null);
        utl.Clbl.setActionResponse('insertLog',                 null);
    }


    /**
     * @description Method to get auth user data
     */
    static Auth.UserData getAuthUserData(){
        return new Auth.UserData(
            UserInfo.getUserId(),
            UserInfo.getFirstName(),
            UserInfo.getLastName(), 
            UserInfo.getFirstName() + ' ' + UserInfo.getLastName(),
            UserInfo.getUserEmail(),
            'link',             
            UserInfo.getUserName(),
            null,               // Locale
            null,               // Provider
            null,               // Site login
            null                // Attribute map
        );
    }


    /** **************************************************************************************************** **
     **                                             TEST METHODS                                             **
     ** **************************************************************************************************** **/
    /**
     * @description Method to test the initiate function
     */
    @IsTest
    static void testInitiate(){
        
        // Test the method
        Test.startTest();
        PageReference pageReference = getAuthProvider().initiate(getAuthProviderConfig(),'TestState');
        Test.stopTest();
        
        // Assert test results
        Assert.areEqual(
            pageReference.getUrl(),
            URL.getOrgDomainUrl().toExternalForm() + '/services/authcallback/TestAuthProvider?state=TestState',
            'Unexpected callback URL'
        );
    }

    /**
     * @description Method to test the handleCallback() function
     */
    @IsTest
    static void testHandleCallback(){

        // Value to assert
        Auth.AuthProviderTokenResponse tokenResponse;

        // Setup callable action 
        utl.Clbl.setActionResponse('insertLoginHistoryRecord',  null);
        
        // Setup the mock response
        utl.Mck.setResponse(200, JSON.serializePretty(new Map<String,String>{
            'access_token' => 'access_token_value',
            'token_type'   => 'Bearer',
            'expires_in'   => '1682439225'
        }));

        // Run the test
        Test.startTest();
        System.runAs(FIRST_USER){
            tokenResponse = getTokenResponse();
        }
        Test.stopTest();

        // Assert test results
        Assert.areEqual('access_token_value', tokenResponse.oauthToken, 'Unexpected oauthToken value');
        Assert.areEqual('TestState',          tokenResponse.state     , 'Unexpected state value');
    }


    /**
     * @description Method to test the handleCallback() function
     */
    @IsTest
    static void testHandleCallbackAsUser(){

        // Variables to assert
        String fuLoggedInUserId;
        String suLoggedInUserId;

        Auth.AuthProviderTokenResponse fuTokenResponse;
        Auth.AuthProviderTokenResponse suTokenResponse;
        
        // Set per user config
        setPerUserConfiguration();
       
        // Setup the mock response
        utl.Mck.setResponse(200, JSON.serializePretty(new Map<String,String>{
            'access_token' => 'access_token_value',
            'token_type'   => 'Bearer',
            'expires_in'   => '1682439225'
        }));

        // Run the test
        Test.startTest();
        System.runAs(FIRST_USER){
            // Test specific responses
            utl.Clbl.setActionResponse('getSubjectFromUserMapping',       'FIRST_USER');
            utl.Clbl.setActionResponse('getAuthUserDataFromCookieHeader', getAuthUserData());

            // Execute logic
            fuTokenResponse = getTokenResponse();

            // Set the logged in user for checking
            fuLoggedInUserId = getAuthProvider().loggedInUserId;
        }

        System.runAs(SECOND_USER){
            // Test specific responses
            utl.Clbl.setActionResponse('getSubjectFromUserMapping',       'SECOND_USER');
            utl.Clbl.setActionResponse('getAuthUserDataFromCookieHeader', getAuthUserData());

            // Execute logic
            suTokenResponse = getTokenResponse();

            // Set the logged in user for checking
            suLoggedInUserId = getAuthProvider().loggedInUserId;
        }
        Test.stopTest();


        // Assert test results
        Assert.areEqual('access_token_value', fuTokenResponse.oauthToken, 'Unexpected oauthToken value');
        Assert.areEqual('TestState',          fuTokenResponse.state     , 'Unexpected state value');

        // Assert test results
        Assert.areEqual('access_token_value', suTokenResponse.oauthToken, 'Unexpected oauthToken value');
        Assert.areEqual('TestState',          suTokenResponse.state     , 'Unexpected state value');
    }


    /**
     * @description Method to test the refresh() function
     */
    @IsTest
    static void testRefresh(){

         // Setup the mock response
         utl.Mck.setResponse(200, JSON.serializePretty(new Map<String,String>{
            'access_token' => 'access_token_value',
            'token_type'   => 'Bearer',
            'expires_in'   => '1682439225'
        }));
        
        // Setup the response from the callable action 
        utl.Clbl.setActionResponse('insertLoginHistoryRecord', null);

        // Test the method
        Test.startTest();
        Auth.OAuthRefreshResult refreshResult = getAuthProvider().refresh(getAuthProviderConfig(),'[REFRESH_TOKEN]');
        Test.stopTest();

        // Assert test results
        Assert.areEqual('[REFRESH_TOKEN]',      refreshResult.refreshToken, 'Unexpected refreshToken value');
        Assert.areEqual('access_token_value',   refreshResult.accessToken,  'Unexpected accessToken value');
    }


    /**
     * @description Method to test the refresh() function in user mode
     */
    @IsTest
    static void testRefreshAsUser(){

        // Variables to assert
        String fuLoggedInUserId;
        String suLoggedInUserId;

        Auth.OAuthRefreshResult fuRefreshResult;
        Auth.OAuthRefreshResult suRefreshResult;
        
        // Set per user config
        setPerUserConfiguration();

        // Setup the mock response to return a token
        utl.Mck.setResponse(200, JSON.serializePretty(new Map<String,String>{
            'access_token' => 'access_token_value',
            'token_type'   => 'Bearer',
            'expires_in'   => '1682439225'
        }));
 
        // Run the test
        Test.startTest();
        System.runAs(FIRST_USER){
            // Test specific responses
            utl.Clbl.setActionResponse('getSubjectFromUserMapping',       'FIRST_USER');
            utl.Clbl.setActionResponse('getAuthUserDataFromCookieHeader', getAuthUserData());

            // Execute logic
            fuRefreshResult = getAuthProvider().refresh(getAuthProviderConfig(), FIRST_USER.Id);

            // Set the logged in user for checking
            fuLoggedInUserId = getAuthProvider().loggedInUserId;
        }

        System.runAs(SECOND_USER){
            // Test specific responses
            utl.Clbl.setActionResponse('getSubjectFromUserMapping',       'SECOND_USER');
            utl.Clbl.setActionResponse('getAuthUserDataFromCookieHeader', getAuthUserData());

            // Execute logic
            suRefreshResult = getAuthProvider().refresh(getAuthProviderConfig(), SECOND_USER.Id);

            // Set the logged in user for checking
            suLoggedInUserId = getAuthProvider().loggedInUserId;
        }
        Test.stopTest();

        // Assert test results for the first user
        Assert.areEqual(FIRST_USER.Id,        fuLoggedInUserId,             'Unexpected logged in user');
        Assert.areEqual(FIRST_USER.Id,        fuRefreshResult.refreshToken, 'Unexpected refreshToken value');
        Assert.areEqual('access_token_value', fuRefreshResult.accessToken,  'Unexpected accessToken value');

        // Assert test results for the second user
        Assert.areEqual(SECOND_USER.Id,       suLoggedInUserId,             'Unexpected logged in user');
        Assert.areEqual(SECOND_USER.Id,       suRefreshResult.refreshToken, 'Unexpected refreshToken value');
        Assert.areEqual('access_token_value', suRefreshResult.accessToken,  'Unexpected accessToken value');
    }


    /**
     * @description Method to test the getUserInfo() function
     */
    @IsTest
    static void testGetUserInfo(){
        
        // Setup the response from the callable action 
        utl.Clbl.setActionResponse('insertLoginHistoryRecord', null);

        // Setup the mock response
        utl.Mck.setResponse(200, JSON.serializePretty(new Map<String,String>{
            'access_token' => 'access_token_value',
            'token_type'   => 'Bearer',
            'expires_in'   => '1682439225'
        }));

        // Test the method
        Test.startTest();
        Auth.UserData userData = getAuthProvider().getUserInfo(
            getAuthProviderConfig(),
            getTokenResponse()
        );
        Test.stopTest();

        // Assert test results
        Assert.areEqual(UserInfo.getUserEmail(),  userData.email, 'Unexpected email value');
    }


    /**
     * @description Method to test the getCustomMetadataType() function
     */
    @IsTest
    static void testGetCustomMetadataType(){
        // Assert test results
        Assert.areEqual(
            String.valueOf(SalesforceAuthProvider__mdt.getSObjectType()),
            getAuthProvider().getCustomMetadataType(),
            'Unexpected custom metadata value'
        );
    }


    /**
     * @description Method to test the exceptions thrown in case there is no package installed
     */
    @IsTest
    static void testHandleException(){
    
        // Override the user config and enable error logging to "test" the callable methods
        getAuthProviderConfig().put(SalesforceAuthProvider.ENABLE_ERROR_LOGGING_FIELD_NAME, 'true');
 
        // Setup the response from the callable action 
        utl.Clbl.setActionResponse('insertLog', null);
        utl.Clbl.setActionResponse('insertLoginHistoryRecord', null);

        try{
            SalesforceAuthProvider sap = new SalesforceAuthProvider();
            // Try to handle the exception
            sap.handleException(
                new SalesforceAuthProvider.GenericException('Message'),
                getAuthProviderConfig()
            );

            // This method will fail the test as it should not be reached
            utl.Tst.assertExceptionHasBeenThrow();

        }catch(Exception e){
            
            // Assert the exception works as expected
            utl.Tst.assertExceptionMessage(
                SalesforceAuthProvider.GENERIC_EXCEPTION_MSG,
                String.valueOf(SalesforceAuthProvider.GenericException.class),
                'Message',
                e
            ); 
        }
        
    }


    /** **************************************************************************************************** **
     **                                      PRIVATE TEST DATA METHODS                                       **
     ** **************************************************************************************************** **/
    /**
     * @description Method that return a mock token response
     * @return      Mock token reponse
     */
    private static Auth.AuthProviderTokenResponse getTokenResponse(){
        return getAuthProvider().handleCallback(
            getAuthProviderConfig(),
            new Auth.AuthProviderCallbackState(
                null,
                null,
                new Map<String,String>{
                    'code' => 'NoCodeRequiredButMandatory',
                    'state'=> 'TestState'
                }
            )
        );
    }


    /**
     * @description Method to create a Auth Provider (SalesforceAuthProvider) class instance that is
     *              used for testing
     * @return      Class representing the Auth Provider
     */
    private static SalesforceAuthProvider getAuthProvider(){
        if(authProvider == null){
            authProvider = new SalesforceAuthProvider();
        }
        return authProvider;
    }


    /**
     * @description Method to generate the Auth Provider Config data that is used for testing
     * @return      The auth provider configuration data map
     */
    private static Map<String,String> getAuthProviderConfig(){
        if(authProviderConfig == null){
            authProviderConfig=  new Map<String,String>{
                SalesforceAuthProvider.MY_DOMAIN_FIELD_NAME            => 'https://localhost/oauth/token',
                SalesforceAuthProvider.IS_SANDBOX_FIELD_NAME           => 'true',
                SalesforceAuthProvider.INTEG_USERNAME_FIELD_NAME       => '[SUBJECT]',
                SalesforceAuthProvider.CONNECTED_APP_ID_FIELD_NAME     => '[ISSUER]',
                SalesforceAuthProvider.AUTH_PROVIDER_NAME_FIELD_NAME   => 'TestAuthProvider',
                SalesforceAuthProvider.JWS_SIGNING_CERT_FIELD_NAME     => 'certName',
                SalesforceAuthProvider.ENABLE_PER_USER_MODE_FIELD_NAME => 'false',
                SalesforceAuthProvider.ENABLE_ERROR_LOGGING_FIELD_NAME => 'false',
                SalesforceAuthProvider.ENABLE_LOGIN_LOGGING_FIELD_NAME => 'false',
                SalesforceAuthProvider.ENABLE_LOGIN_HISTORY_FIELD_NAME => 'true'
            };
        }
        return authProviderConfig;
    }
}