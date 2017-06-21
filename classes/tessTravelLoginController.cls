global class tessTravelLoginController {

  global string user {get;set;}
  global string userPassword {get;set;}
  global string error {get;set;}
  global User usuario {get;set;}
  global List<Account> accounts {get;set;}
  global string storedUser {get;set;}
  global boolean logged {get;set;}

  public tessTravelLoginController()
  {
    logged=false;
    storedUser='';
    Cookie initToken =  ApexPages.currentPage().getCookies().get('tokenSF');
    //tessTravellerSession__c session = [SELECT Id, Name FROM tessTravellerSession__c WHERE Name = :initToken.getValue() LIMIT 1];
    //System.debug(session);
    // if(session!=null)
    // {
    //   storedUser=ApexPages.currentPage().getCookies().get('userSF').getValue();
    //   logged=true;
    // }

  }
  public PageReference tryLogout()
  {
    Cookie logoutCookieToken =  new Cookie('tokenSF','',null,0,false);
    Cookie logoutCookieUser =  new Cookie('userSF','',null,0,false);
    ApexPages.currentPage().setCookies(new Cookie[]{logoutCookieToken,logoutCookieUser});
    logged=false;
    storedUser='';
    usuario=null;
    accounts=null;
    return new PageReference('https://www.google.com');
  }

  public Boolean tryLogin()
  {
    Boolean successfulLogin = false;
    HttpRequest req = new HttpRequest();
    req.setEndpoint('https://login.salesforce.com/services/oauth2/token');
    req.setMethod('POST');

    // Specify the required user name and password to access the endpoint
    // As well as the header and header information

    String username = user;
    String password = userPassword;
    String clientSecret =  '6709882249618173996';
    String clientId = '3MVG9CEn_O3jvv0xTdCXt2Mz2SZaeUizf2U4vAWiKntXhrC8tGFQfd2JDVaH9ldb.4tG40epJE_wtJzvwYIMx';
    String token = '';

    string fullPass= password+token;
    String reqbody = 'grant_type=password&client_id='+clientId+'&client_secret='+clientSecret+'&username='+username+'&password='+fullPass;


    req.setBody(reqBody);

    // Create a new http object to send the request object
    // A response object is generated as a result of the request

    Http http = new Http();
    HTTPResponse res = http.send(req);
    System.debug(res.getBody());

    OAuth2 authInfo = (OAuth2)JSON.deserialize(res.getBody(), OAuth2.class);
    if(authInfo.access_token!=null)
    {
      system.debug('User: ' + username);

      usuario = [Select Id,alias,username,name from user where username=:username];
      error='ÉXITO!!!!';
      accounts=[SELECT Id,Name FROM Account LIMIT 6];
      Cookie cookToken = ApexPages.currentPage().getCookies().get('tokenSF');
      Cookie cookUser;
      if (cookToken==null)
      {
        cookToken = new Cookie('tokenSF',userPassword,null,-1,false);
        cookUser = new Cookie('userSF',usuario.userName,null,-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{cookToken,cookUser});
        storedUser=username;
        logged=true;
      }
      successfulLogin = true;
    }

    return successfulLogin;
  }

  public PageReference logUserIn()
  {
    if( tryLogin() ) {
      return new PageReference('https://google.com');
    } else {
      return new PageReference('/Exception');
    }
  }

  public Boolean checkSession(String token)
  {
    return true;
  }

  public User getUsuario()
  {
    return usuario;
  }

  public class OAuth2{
    public String id{get;set;}
    public String issued_at{get;set;}
    public String instance_url{get;set;}
    public String signature{get;set;}
    public String access_token{get;set;}
  }
}