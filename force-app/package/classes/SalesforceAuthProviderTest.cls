/**
 * @author      Justus van den Berg (jfwberg@gmail.com)
 * @date        October 2023 
 * @copyright   (c) 2023 Justus van den Berg
 * @license     MIT (See LICENSE file in the project root)
 * @description Class for testing the SalesforceAuthProvider Methods
 */
@IsTest
private with sharing class SalesforceAuthProviderTest {
    
    /** **************************************************************************************************** **
     **                                      PRIVATE TEST DATA VARIABLE                                      **
     ** **************************************************************************************************** **/
    // Variables for holding test data
    private static SalesforceAuthProvider authProvider;
    private static Map<String,String> authProviderConfig; 


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
        
        // Run once so it is initialized
        getAuthProviderConfig();

        // Create a Mock User Data object
        Auth.UserData aud = new Auth.UserData(
            'IntegrationUserId',// User Id
            'Integration',      // First Name
            'User',             // Last Name
            'Integration User', // Full Name
            'integration.user@example.com.invalid', // Email Address
            'link',             // Link
            null,               // Username
            null,               // Locale
            null,               // Provider
            null,               // Site login
            null                // Attribute map
        );

        // Override the user config and enable per user mode to "test" the callable methods
        authProviderConfig.put(SalesforceAuthProvider.ENABLE_PER_USER_MODE_FIELD_NAME, 'true');
        authProviderConfig.put(SalesforceAuthProvider.ENABLE_LOGIN_LOGGING_FIELD_NAME, 'true');

        // Setup the response from the callable action
        utl.Clbl.setActionResponse('updateMappingLoginDetails', null);
        utl.Clbl.setActionResponse('checkUserMappingExists', true);
        utl.Clbl.setActionResponse('getSubjectFromUserMapping', 'federationId');
        utl.Clbl.setActionResponse('getAuthUserDataFromCookieHeader', aud);
        utl.Clbl.setActionResponse('insertLoginHistoryRecord', null);
        

        // Setup the mock response
        utl.Mck.setResponse(200, JSON.serializePretty(new Map<String,String>{
            'access_token' => 'access_token_value',
            'token_type'   => 'Bearer',
            'expires_in'   => '1682439225'
        }));

        // Test the method
        Test.startTest();
        Auth.AuthProviderTokenResponse tokenResponse = getTokenResponse();
        Test.stopTest();

        // Assert test results
        Assert.areEqual('access_token_value', tokenResponse.oauthToken, 'Unexpected oauthToken value');
        Assert.areEqual('TestState',          tokenResponse.state     , 'Unexpected state value');
    }


    /**
     * @description Method to test the refresh() function
     */
    @IsTest
    static void testRefresh(){

        // Setup a mock response for the web service call
        utl.Mck.setResponse('{}');
        
        // Setup the response from the callable action 
        utl.Clbl.setActionResponse('insertLoginHistoryRecord', null);

        // Test the method
        Test.startTest();
        Auth.OAuthRefreshResult refreshResult = getAuthProvider().refresh(getAuthProviderConfig(),'[REFRESH_TOKEN]');
        Test.stopTest();

        // Assert test results
        Assert.areEqual('[REFRESH_TOKEN]', refreshResult.refreshToken, 'Unexpected accessToken value');
        Assert.areEqual(null,              refreshResult.accessToken,  'Unexpected accessToken value');
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
        Assert.areEqual('integration.user@example.com.invalid',    userData.email, 'Unexpected email value');
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
        
        // Run once so it is initialized
        getAuthProviderConfig();

        // Override the user config and enable error logging to "test" the callable methods
        authProviderConfig.put(SalesforceAuthProvider.ENABLE_ERROR_LOGGING_FIELD_NAME, 'true');
 
        // Setup the response from the callable action 
        utl.Clbl.setActionResponse('insertLog', null);
        utl.Clbl.setActionResponse('insertLoginHistoryRecord', null);

        try{
            
            // Try to handle the exception
            SalesforceAuthProvider.handleException(
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