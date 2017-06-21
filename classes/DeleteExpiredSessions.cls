global class DeleteExpiredSessions implements Schedulable {
	global void execute(SchedulableContext sc) {
		List<tessTravelerSession__c> expiredSessions = [SELECT Id FROM tessTravelerSession__c WHERE dtExpiresOn__c <= :System.now() ];
		if(expiredSessions.size() > 0){
			delete expiredSessions;
		}
	}
}