/**
* @author Elif Çevikoğlu
* @date October 11, 2023
* @description Queueable class for ContactTrigger trigger. Updates Contact's Primary_Contact_Phone__c field.
*/
global class UpdatePrimaryContactPhone implements Queueable {
    private Map<Id, Contact> conMap;
    private Boolean removePrimaryContactPhone;

    public UpdatePrimaryContactPhone(Map<Id, Contact> contactsMap, Boolean removePrimaryContactPhone) {
        this.conMap = contactsMap;
        this.removePrimaryContactPhone = removePrimaryContactPhone;
    }
    
    public void execute(QueueableContext context) {
        List<Contact> contsToUpdate = [SELECT Primary_Contact_Phone__c, AccountId FROM Contact WHERE AccountId IN :conMap.keySet() AND Primary_Contact__c = false];

        if (contsToUpdate.size() > 0) {
            if (removePrimaryContactPhone) {
                for (Contact cont : contsToUpdate) {
                    cont.Primary_Contact_Phone__c = null;
                }

                Database.SaveResult[] results = Database.update(contsToUpdate, false);
            } else {
                for (Contact con : contsToUpdate) {
                    con.Primary_Contact_Phone__c = conMap.get(con.AccountId).Phone;
                }
        
                Database.SaveResult[] results = Database.update(contsToUpdate, false);
            }
        }
    }
}