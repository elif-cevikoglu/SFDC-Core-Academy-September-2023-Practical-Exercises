@IsTest
private class PrimaryContactPageHandlerTest {
    @IsTest 
    private static void testSavePopup() {
        Account acct = new Account(Name='TestAccount');
        insert acct;

        List<Contact> cons = new List<Contact>{new Contact(LastName='Test Contact 1', AccountId=acct.Id, Primary_Contact__c = false),
                                            new Contact(LastName='Test Contact 2', AccountId=acct.Id, Primary_Contact__c = true)};
        insert cons;

        PageReference pageRef = Page.PrimaryContactPage;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController acctStandardController = new ApexPages.StandardController(acct);
        PrimaryContactPageHandler acctHandler = new PrimaryContactPageHandler(acctStandardController);

        Test.startTest();
        acctHandler.newPrimaryContId = cons[0].Id;
        acctHandler.cancelPopUp();
        acctHandler.showPopUp();
        acctHandler.savePopup();

        acctHandler.contNameInput = 'Test Contact';
        acctHandler.handleNameInput();
        Test.stopTest();

        Contact primaryCont = [SELECT Id, Primary_Contact__c FROM Contact WHERE Id = :cons[0].id];
        System.assertEquals(true, primaryCont.Primary_Contact__c);
        System.assertEquals(2, acctHandler.contactsList.size());
        System.assertEquals(true, acctHandler.prevDisabled);
        System.assertEquals(true, acctHandler.nextDisabled);
    }

    @IsTest
    private static void testPagination() {
        Account acct = new Account(Name='TestAccount');
        insert acct;

        List<Contact> cons = new List<Contact>{new Contact(LastName='Test Contact 1', AccountId=acct.Id, Primary_Contact__c = false),
                                            new Contact(LastName='Test Contact 2', AccountId=acct.Id, Primary_Contact__c = true)};
        insert cons;
        
        PageReference pageRef = Page.PrimaryContactPage;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController acctStandardController = new ApexPages.StandardController(acct);
        PrimaryContactPageHandler acctHandler = new PrimaryContactPageHandler(acctStandardController);

        acctHandler.lastPage();
        acctHandler.firstPage();
        acctHandler.nextPage();
        acctHandler.prevPage();
    }
}