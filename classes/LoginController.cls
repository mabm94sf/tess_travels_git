global class LoginController {

	global String userName {get;set;}
  global String userPassword {get;set;}
	private User usuario {get;set;}
	private String message;
	private String thisPage;
	private String returnTo;
	private String homePage;

	public LoginController()
	{
		thisPage = '/viajes/Login';
		message = '';
		returnTo = System.currentPageReference().getParameters().get('returnTo');
		homePage = '/viajes/TravelerProfile';
	}

	public HttpResponse requestLogin(String uName, String pass)
	{
		HttpRequest req = new HttpRequest();
    req.setEndpoint('https://login.salesforce.com/services/oauth2/token');
    req.setMethod('POST');
    String clientSecret =  '6709882249618173996';
    String clientId = '3MVG9CEn_O3jvv0xTdCXt2Mz2SZaeUizf2U4vAWiKntXhrC8tGFQfd2JDVaH9ldb.4tG40epJE_wtJzvwYIMx';
    String token = '';
    String fullPass= pass+token;
    String reqbody = 'grant_type=password&client_id='+clientId+'&client_secret='+clientSecret+'&username='+uName+'&password='+fullPass;
    req.setBody(reqBody);

    Http http = new Http();
    HttpResponse res = http.send(req);
    System.debug(res.getBody());
		return res;
	}

	public Boolean tryLogin()
  {
    Boolean successfulLogin = false;
    HttpResponse res = requestLogin(userName, userPassword);

    OAuth2 authInfo = (OAuth2)JSON.deserialize(res.getBody(), OAuth2.class);
    if(authInfo.access_token!=null)
    {
      usuario = [Select Id,alias,username,name, (SELECT Id, Name FROM Viajeros_del__r LIMIT 1) from user where username=:username];
      Cookie cookToken = new Cookie('tokenSF',authInfo.access_token,null,2*60*60,false);
      ApexPages.currentPage().setCookies(new Cookie[]{cookToken});
			if(usuario.Viajeros_del__r.size() != 0) {
				tessTravelerSession__c tSession = new tessTravelerSession__c(sSessionId__c = authInfo.access_token, mdTraveler__c = usuario.Viajeros_del__r[0].Id, dtExpiresOn__c = DateTime.now().addHours(2));
				insert tSession;
				successfulLogin = true;
			} else {
				message = 'Su usuario no tiene viajeros relacionados';
			}
    } else {
			message = 'usuario o contraseña incorrectos';
		}

    return successfulLogin;
  }

	public PageReference logUserIn()
  {
    if( tryLogin() ) {
			if(returnTo == null) {
				return new PageReference(homePage);
			}
			return new PageReference(returnTo);
    }
    return new PageReference('/Exception?message='+message+'&returnTo='+thisPage);
  }

	public class OAuth2
	{
    public String id{get;set;}
    public String issued_at{get;set;}
    public String instance_url{get;set;}
    public String signature{get;set;}
    public String access_token{get;set;}
  }
}