public class tessTravelerProfileController {

  public List<tessCostCenter__c> availableCostCenters {get;set;}
  public String searchString {get;set;}
  public String searchInput {get;set;}
  public User chatterUser {get;set;}
  public boolean modalBox {get;set;}
  public tessTraveler__c travelerProfile {set;get;}
  public String costCenterName {get;set;}
  public String mensajeDeError {set;get;}
  public tessForeignVisa__c foreignVisa {set;get;}
  public List<tessForeignVisa__c> foreignVisaList {set;get;}
  public tessFrequentTravelerInfo__c freqTravelerInfo {set;get;}
  public List<tessFrequentTravelerInfo__c> freqTravelerList {get;set;}
  public String freqTravelerNumber {get;set;}
  public String freqTravelerId {get;set;}
  public String foreignVisaNumber {get;set;}
  public String country {get;set;}
  public String foreignVisaId {get;set;}
  public Date foreignVisaExpiresOn {get;set;}
  public List<SelectOption> accountSelectOptions {get;set;}
  public List<SelectOption> accountTypeSelectOptions {get;set;}
  public String accountSelection {get;set;}
  public String accountTypeSelection {get;set;}
  public tessTravelerProfileController()
  {

    if(availableCostCenters!=null)
    {
      if(availableCostCenters.size()!=0)
      {
        modalBox=true;
      }
    }
    getAccountType();
    getBusiness();
  }

  public PageReference validateSession()
  {
    Cookie sessionId =  ApexPages.currentPage().getCookies().get('tokenSF');

    if(sessionId==null )
    {
      system.debug(ApexPages.currentPage().getHeaders().get('Host'));
      system.debug('Null session');
      return InvalidSession();

    }
    List<tessTravelerSession__c> sessionList = new List<tessTravelerSession__c>();
    sessionList = [SELECT Id, sSessionId__c,mdTraveler__c FROM tessTravelerSession__c WHERE sSessionId__c=:sessionId.getValue()];
    if(sessionList.size()==0 )
    {
      system.debug('Session not found');
      return InvalidSession();

    }
    sessionList[0].dtExpiresOn__c = DateTime.now().addHours(2);
    Cookie cookToken = new Cookie('tokenSF',sessionId.getValue(),null,2*60*60,false);
    ApexPages.currentPage().setCookies(new Cookie[]{cookToken});

    travelerProfile = [SELECT Id, Name, lkupAssociatedUser_del__c, bEmailTracking__c, pklAirline__c, dPassportExpiresOn__c, dForeignVISAExpiresOn__c,
    dAmericanVISAExpiresOn__c, pklHotel__c, sFrequentCustomerNumber__c, sPassportNumber__c, sAirlineTravelerNumber__c,
    sAmericanVISANumber__c,sForeignVISANumber__c
    FROM tessTraveler__c WHERE id =:sessionList[0].mdTraveler__c];
    foreignVisaList = [SELECT id,name,pklCountry__c,dExpiresOn__c  FROM tessForeignVisa__c WHERE mdTraveler__c=:travelerProfile.id order by pklCountry__c];
    freqTravelerList = [SELECT Id, name, f_sRecordTypeName__c, mdTraveler__c, lkupBusiness__c,lkupBusiness__r.name FROM tessFrequentTravelerInfo__c WHERE mdTraveler__c=:travelerProfile.id order by mdTraveler__r.name];
    system.debug('Traveler SOQL');
    system.debug(travelerProfile);
    chatterUser = [SELECT Id, Alias, Title, MobilePhone FROM User WHERE Id =:travelerProfile.lkupAssociatedUser_del__c];
    // costCenterName = travelerProfile.lkupCostCenter__r.Name;
    update sessionList;
    return null;
  }

  public PageReference InvalidSession()
  {
    return new PageReference('/Login?returnTo=/TravelerProfile');
  }

  public void searchCostCenters()

  {
    availableCostCenters = [SELECT Id, Name FROM tessCostCenter__c WHERE Name LIKE :'%'+searchInput+'%' ORDER BY Name LIMIT 5 ];
    modalBox=true;
  }

  public PageReference save()
  {
    system.debug(travelerProfile);
    PageReference pageRef = new PageReference('/TravelerProfile');
    pageRef.setRedirect(true);
    try{
      update travelerProfile;

      pageRef.getParameters().put('result','success');

      return pageRef;
    }
    catch (Exception e)
    {


      pageRef.getParameters().put('result','error');
      pageRef.getParameters().put('msg',e.getMessage());
      return pageRef;
    }

  }

  public PageReference addVisa()
  {
    foreignVisa = new tessForeignVisa__c();
    foreignVisa.name = foreignVisaNumber;
    foreignVisa.mdTraveler__c = travelerProfile.id;
    foreignVisa.pklCountry__c = country;
    foreignVisa.dExpiresOn__c = foreignVisaExpiresOn;
    system.debug('Expira');
    System.debug(country);
    system.debug(foreignVisaExpiresOn);
    if(foreignVisa.name!=''&& foreignVisa.name!=null)
    insert foreignVisa;
    foreignVisaList = [Select id,name,pklCountry__c,dExpiresOn__c  from tessForeignVisa__c WHere mdTraveler__c=:travelerProfile.id order by pklCountry__c];
    return null;
  }
  public PageReference deleteVisa()
  {

    delete [Select id FROM tessForeignVisa__c WHERE id=:foreignVisaId LIMIT 1];
    foreignVisaList = [Select id,name,pklCountry__c,dExpiresOn__c  from tessForeignVisa__c WHere mdTraveler__c=:travelerProfile.id order by pklCountry__c];
    return null;
  }

  public PageReference addFrequentTravelerData()
  {
    system.debug(accountSelection);
    system.debug(accountTypeSelection);
    freqTravelerInfo = new tessFrequentTravelerInfo__c();
    freqTravelerInfo.name = freqTravelerNumber;
    freqTravelerInfo.mdTraveler__c = travelerProfile.id;
    freqTravelerInfo.lkupBusiness__c = accountSelection;
    insert freqTravelerInfo;
    freqTravelerList = [SELECT Id, name, f_sRecordTypeName__c, mdTraveler__c, lkupBusiness__c,lkupBusiness__r.name FROM tessFrequentTravelerInfo__c WHERE mdTraveler__c=:travelerProfile.id order by mdTraveler__r.name];
    return null;
  }

  public PageReference deleteFrequentTravelerData()
  {
    //freqTravelerId
    delete [Select id FROM tessFrequentTravelerInfo__c WHERE id=:freqTravelerId LIMIT 1];
    freqTravelerList = [SELECT Id, name, f_sRecordTypeName__c, mdTraveler__c, lkupBusiness__c,lkupBusiness__r.name FROM tessFrequentTravelerInfo__c WHERE mdTraveler__c=:travelerProfile.id order by mdTraveler__r.name];
    return null;
  }

  public List<SelectOption> getAccountType()
  {
    List<SelectOption> options = new List<SelectOption>();
    List<RecordType> accountTypeList = [SELECT Id,Name,SObjectType FROM RecordType WHERE SObjectType='Account'];
    String typeName;
    if(accountTypeList!=null)
    {
      options.add(new SelectOption('','Seleccione'));
      for(RecordType myAccountType : accountTypeList)
      {
        typeName = myAccountType.name;
        if(typeName!='Cuenta')
        options.add(new SelectOption(typeName,typeName));
      }

    }
    accountTypeSelectOptions = options;
    return options;
  }
  public PageReference getBusinessReload()
  {
    system.debug(accountTypeSelection);

    getBusiness();
    return null;
  }
  public List<SelectOption> getBusiness()
  {
    system.debug('Account Type: '+accountTypeSelection);
    List<SelectOption> options = new List<SelectOption>();
    List<Account> accountList = [SELECT Id,Name FROM Account WHERE f_sRecordTypeName__c=:accountTypeSelection AND f_sRecordTypeName__c != ''];
    system.debug(accountList);
    if(accountList!=null)
    {
      for(Account myAccount : accountList)
      {
        options.add(new SelectOption(myAccount.id,myAccount.name));
      }
    }
    accountSelectOptions = options;
    return options;
  }
}