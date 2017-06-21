public class tessTravelDetail {

    public List<tessTravelerSession__c> sessionList {set;get;}
    public String tokenValue {set;get;}
    public tessTraveler__c travelerProfile {set;get;}
    public User chatterUser {get;set;}
    public tessTravel__c travelDetail {set;get;}
    public Id travelId {get;set;}
    public List<tessExpense__c> expenses {get;set;}

public PageReference initializeController() {
	if(validateSession()) {
        travelId = ApexPages.currentPage().getParameters().get('Id');
        sessionList[0].dtExpiresOn__c = DateTime.now().addHours(2);
        update sessionList[0];
        Cookie cookToken = new Cookie('tokenSF', tokenValue, null, 2*60*60, false);
        ApexPages.currentPage().setCookies(new Cookie[] {cookToken});
        travelerProfile = [SELECT Id, Name, lkupAssociatedUser_del__c FROM tessTraveler__c WHERE Id =:sessionList[0].mdTraveler__c];
        chatterUser = [SELECT Id, Alias, Title, MobilePhone FROM User WHERE Id =: travelerProfile.lkupAssociatedUser_del__c];

        travelDetail = [SELECT name, sDescription__c, startingPoint__c, arrival__c, dDateOfDeparture__c, dDateOfReturn__c, objective__c,
        				pklTypeOfTravel__c, travelStatus__c, bAdvancePaymentRequest__c
        				FROM tessTravel__c WHERE mdTraveler__c =: travelerProfile.Id AND id =: travelId LIMIT 1];
        expenses = [SELECT id, Name,sMoreDetails__c, cAmount__c FROM tessExpense__c WHERE mdTravel__c =:travelId];

      return null;
    } else {
    	return InvalidSession();
    }
}

public Boolean validateSession() {
        Cookie sessionId = ApexPages.currentPage().getCookies().get('tokenSF');
        if(sessionId == null) {
            system.debug(ApexPages.currentPage().getHeaders().get('Host'));
            system.debug('Null session');
            return false;
        }
        sessionList = new List<tessTravelerSession__c>();
        sessionList = [SELECT Id, sSessionId__c, mdTraveler__c FROM tessTravelerSession__c WHERE sSessionId__c=:sessionId.getValue()];
        if(sessionList.size() == 0) {
            system.debug('Session not found');
            return false;
        }
        tokenValue = sessionId.getValue();
        return true;
    }

public PageReference InvalidSession() {
        return new PageReference('/Login?returnTo=/TravelDetail');
    }

public PageReference travelDetailPage() {
    return null;
    }
}