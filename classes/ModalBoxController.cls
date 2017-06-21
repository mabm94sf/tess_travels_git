global class ModalBoxController {
    public List<tessTravelerSession__c> sessionList {get;set;}
    public String tokenValue {get;set;}
	public id travelerId {get;set;}

	public String travelDescription {get;set;}
	public String startingPoint {get;set;}
	public String arrival {get;set;}
	public Date dDateOfDeparture {get;set;}
	public Date dDateOfReturn {get;set;}
	public boolean isCost {get;set;}
	public boolean buyTransportation {get;set;}
	public boolean buyLodging {get;set;}
	public String travelPurpose {get;set;}
	public String typeOfTravel {get;set;}

	public PageReference saveTravel() {
		if(validateSession()) {
			sessionList[0].dtExpiresOn__c = DateTime.now().addHours(2);
	        update sessionList[0];
	        Cookie cookToken = new Cookie('tokenSF', tokenValue, null, 2*60*60, false);
	        ApexPages.currentPage().setCookies(new Cookie[] {cookToken});
	        travelerId = sessionList[0].mdTraveler__c;

			tessTravel__c tt = new tessTravel__c(sDescription__c = travelDescription, startingPoint__c = startingPoint,
				arrival__c = arrival, dDateOfDeparture__c = dDateOfDeparture, dDateOfReturn__c = dDateOfReturn,
				pklTypeOfTravel__c = typeOfTravel, objective__c = travelPurpose, bBuyTransportation__c = buyTransportation,
				bBuyLodging__c = buyLodging, bIsCost__c = isCost,
				travelStatus__c = 'forAuthorizing', mdTraveler__c = travelerId);
			insert tt;
		}
			return new PageReference('/MainTravel');
	}

    public PageReference saveDraft() {
        if(validateSession()) {
            sessionList[0].dtExpiresOn__c = DateTime.now().addHours(2);
            update sessionList[0];
            Cookie cookToken = new Cookie('tokenSF', tokenValue, null, 2*60*60, false);
            ApexPages.currentPage().setCookies(new Cookie[] {cookToken});
            travelerId = sessionList[0].mdTraveler__c;

            tessTravel__c tt = new tessTravel__c(sDescription__c = travelDescription, startingPoint__c = startingPoint,
                arrival__c = arrival, dDateOfDeparture__c = dDateOfDeparture, dDateOfReturn__c = dDateOfReturn,
                pklTypeOfTravel__c = typeOfTravel, objective__c = travelPurpose, bBuyTransportation__c = buyTransportation,
                bBuyLodging__c = buyLodging, bIsCost__c = isCost,
                travelStatus__c = 'draft', mdTraveler__c = travelerId);
            insert tt;
        }
            return new PageReference('/MainTravel');
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

 	//PickList de objetivo del viaje
	public List<SelectOption> getPurposeOptions() {
    	List<SelectOption> purposeOptions = new List<SelectOption>();
        purposeOptions.add(new SelectOption('',''));
        purposeOptions.add(new SelectOption('training','Capacitación'));
		purposeOptions.add(new SelectOption('compusolucionesConvention','Convención CompuSoluciones'));
    	purposeOptions.add(new SelectOption('supplierConvention','Convención Proveedores'));
        purposeOptions.add(new SelectOption('thirdLevelInterview','Entrevista de tercer nivel'));
    	purposeOptions.add(new SelectOption('360TeamEvaluation','Evaluación 360° Equipo de trabajo'));
    	purposeOptions.add(new SelectOption('meetingWithSupplier','Junta con proveedor'));
    	purposeOptions.add(new SelectOption('meetingWithSupervisor','Junta con supervisor'));
        purposeOptions.add(new SelectOption('customerVisit','Visita a clientes'));
    	purposeOptions.add(new SelectOption('other','Otro'));
    	return purposeOptions;
    }
    //PickList de tipo de viaje
	public List<SelectOption> getTypeOptions() {
    	List<SelectOption> typeOptions = new List<SelectOption>();
        typeOptions.add(new SelectOption('',''));
        typeOptions.add(new SelectOption('national','Nacional'));
		typeOptions.add(new SelectOption('international','Internacional'));
    	return typeOptions;
    }

}