public class tessMainTravelController {
    public tessTraveler__c travelerProfile {set;get;}
    public User chatterUser {get;set;}
    public tessTravel__c travel {set;get;}
    public List<tessTravelerSession__c> sessionList {get;set;}
    public String tokenValue {get;set;}
    //Status del viaje
    public List<tessTravel__c> travelListForAuthorizing {set;get;}
    public List<tessTravel__c> travelListAuthorized {set;get;}
    public List<tessTravel__c> travelListRejected {set;get;}
    public List<tessTravel__c> travelListCancelled {set;get;}
    public List<tessTravel__c> travelListForReimbursement {set;get;}
    public List<tessTravel__c> travelListRefundRejected {set;get;}
    public List<tessTravel__c> travelListRefunded {set;get;}
    public List<tessTravel__c> travelListConcluded {set;get;}
    public List<tessTravel__c> travelListAll {set;get;}

    public PageReference initializeController() {
      if(validateSession()) {
        sessionList[0].dtExpiresOn__c = DateTime.now().addHours(2);
        update sessionList[0];
        Cookie cookToken = new Cookie('tokenSF', tokenValue, null, 2*60*60, false);
        ApexPages.currentPage().setCookies(new Cookie[] {cookToken});
        travelerProfile = [SELECT Id, Name, lkupAssociatedUser_del__c FROM tessTraveler__c WHERE Id =:sessionList[0].mdTraveler__c];
        chatterUser = [SELECT Id, Alias, Title, MobilePhone FROM User WHERE Id =: travelerProfile.lkupAssociatedUser_del__c];

        travelListForAuthorizing = [SELECT id, name, startingPoint__c, arrival__c, dDateOfDeparture__c, dDateOfReturn__c FROM tessTravel__c WHERE mdTraveler__c =: travelerProfile.Id AND travelStatus__c = 'forAuthorizing' ORDER BY name];
        travelListAuthorized = [SELECT id, name, startingPoint__c, arrival__c, dDateOfDeparture__c, dDateOfReturn__c FROM tessTravel__c WHERE mdTraveler__c =: travelerProfile.Id AND travelStatus__c = 'authorized' ORDER BY name];
        travelListRejected = [SELECT id, name, startingPoint__c, arrival__c, dDateOfDeparture__c, dDateOfReturn__c FROM tessTravel__c WHERE mdTraveler__c =: travelerProfile.Id AND travelStatus__c = 'rejected' ORDER BY name];
        travelListCancelled = [SELECT id, name, startingPoint__c, arrival__c, dDateOfDeparture__c, dDateOfReturn__c FROM tessTravel__c WHERE mdTraveler__c =: travelerProfile.Id AND travelStatus__c = 'cancelled' ORDER BY name];
        travelListForReimbursement = [SELECT id, name, startingPoint__c, arrival__c, dDateOfDeparture__c, dDateOfReturn__c FROM tessTravel__c WHERE mdTraveler__c =: travelerProfile.Id AND travelStatus__c = 'forReimbursement' ORDER BY name];
        travelListRefundRejected = [SELECT id, name, startingPoint__c, arrival__c, dDateOfDeparture__c, dDateOfReturn__c FROM tessTravel__c WHERE mdTraveler__c =: travelerProfile.Id AND travelStatus__c = 'refundRejected' ORDER BY name];
        travelListRefunded = [SELECT id, name, startingPoint__c, arrival__c, dDateOfDeparture__c, dDateOfReturn__c FROM tessTravel__c WHERE mdTraveler__c =: travelerProfile.Id AND travelStatus__c = 'refunded' ORDER BY name];
        travelListConcluded = [SELECT id, name, startingPoint__c, arrival__c, dDateOfDeparture__c, dDateOfReturn__c FROM tessTravel__c WHERE mdTraveler__c =: travelerProfile.Id AND travelStatus__c = 'concluded' ORDER BY name];
        travelListAll = [SELECT id, name, travelStatus__c, startingPoint__c, arrival__c, dDateOfDeparture__c, dDateOfReturn__c FROM tessTravel__c WHERE mdTraveler__c =: travelerProfile.Id ORDER BY name];

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
        return new PageReference('/Login?returnTo=/MainTravel');
    }

}