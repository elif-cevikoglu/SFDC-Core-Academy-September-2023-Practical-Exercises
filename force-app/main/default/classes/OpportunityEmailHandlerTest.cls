/**
* @author Elif Çevikoğlu
* @date October 15, 2023
* @description Tests OpportunityEmailHandler.
*/
@IsTest
private class OpportunityEmailHandlerTest {

    @IsTest
    private static void testOpportunityEmailHandler() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'elif-cevikoglu@outlook.com', AccountId = testAccount.Id, Primary_Contact__c = true);
        insert testContact;
        Contact testContact2 = new Contact(FirstName = 'Test', LastName = 'Contact2', Email = 'test2@test.com', AccountId = testAccount.Id, Primary_Contact__c = false);
        insert testContact2;
        
        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Closed Won', CloseDate = Date.today(), Amount = 1000, AccountId = testAccount.Id);
        insert testOpportunity;
        
        Test.startTest();
        OpportunityEmailHandler batch = new OpportunityEmailHandler();
        Database.executeBatch(batch);
        Test.stopTest();
    }
}
