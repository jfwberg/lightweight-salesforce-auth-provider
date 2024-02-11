System.debug(new utl.Rst('Test')
			 .setEndpoint('/services/oauth2/userinfo')
			 //.setEndpoint('/services/data/v60.0/query?q=SELECT+Id,Data__c+FROM+CSHare__c')
			 .call()
			 .getResponse()
			 .getBody()
			);