/**
* @author Elif Çevikoğlu
* @date October 11, 2023
* @description Test class for ContactTrigger trigger, ContactTriggerHelper class, and UpdatePrimaryContactPhone class.
*/
@IsTest
private class ContactTriggerTest {
    @IsTest 
    private static void TestInsertUpdateSuccess() {
        Account acct = new Account(Name = 'TestAccount');
        insert acct;

        List<Contact> conts = new List<Contact>();
        Contact primaryCont;
        for (Integer i = 1; i < 201; i++) {
            if (i != 200) {
                conts.add(new Contact(LastName = 'TestContact'+i, Primary_Contact__c = false, AccountId = acct.Id));
            } else {
                primaryCont = new Contact(LastName = 'TestContact'+i, Primary_Contact__c = true, Phone = '123', AccountId = acct.Id);
            }
        }
        insert conts;

        Test.startTest();
        insert primaryCont;
        Test.stopTest();

        List<Contact> secondaryContList = [SELECT Primary_Contact_Phone__c FROM Contact WHERE Primary_Contact__c = false AND Id IN :conts];
        for (Contact secondaryCont : secondaryContList) {
            System.assertEquals('123', secondaryCont.Primary_Contact_Phone__c);
        }
    }

    @IsTest 
    private static void TestInsertUpdateErrorNoAccount() {
        Contact primaryCont = new Contact(LastName = 'TestContact', Primary_Contact__c = true, Phone = '123');

        Test.startTest();
        Database.SaveResult res = Database.insert(primaryCont, false);
        Test.stopTest();

        System.assert(!res.isSuccess());
        System.assertEquals('You need to select an account for primary contact.', res.getErrors()[0].getMessage());
    }

    @IsTest 
    private static void TestInsertUpdateError() {
        Account acct = new Account(Name = 'TestAccount');
        insert acct;

        List<Contact> conts = new List<Contact>();
        List<Contact> primaryConts = new List<Contact>();
        for (Integer i = 1; i < 201; i++) {
            if (i < 199) {
                conts.add(new Contact(LastName = 'TestContact'+i, Primary_Contact__c = false, AccountId = acct.Id));
            } else if (i == 199) {
                primaryConts.add(new Contact(LastName = 'TestContact'+i, Primary_Contact__c = true, Phone = '123', AccountId = acct.Id));
            } else if (i == 200) {
                primaryConts.add(new Contact(LastName = 'TestContact'+i, Primary_Contact__c = true, Phone = '123', AccountId = acct.Id));
            }
        }
        insert conts;

        Test.startTest();
        List<Database.SaveResult> res = Database.insert(primaryConts, false);
        Test.stopTest();

        for (Database.SaveResult sr : res) {
            if (!sr.isSuccess()) {
                System.assertEquals('An account can have only one primary contact.', sr.getErrors()[0].getMessage());
            }
        }
    }

    @IsTest 
    private static void TestInsertUpdateErrorExisting() {
        Account acct = new Account(Name = 'TestAccount');
        insert acct;

        List<Contact> conts = new List<Contact>();
        List<Contact> primaryConts = new List<Contact>();
        for (Integer i = 1; i < 201; i++) {
            if (i < 199) {
                conts.add(new Contact(LastName = 'TestContact'+i, Primary_Contact__c = false, AccountId = acct.Id));
            } else if (i == 199) {
                conts.add(new Contact(LastName = 'TestContact'+i, Primary_Contact__c = true, Phone = '123', AccountId = acct.Id));
            } else if (i == 200) {
                primaryConts.add(new Contact(LastName = 'TestContact'+i, Primary_Contact__c = true, Phone = '123', AccountId = acct.Id));
            }
        }
        insert conts;

        Test.startTest();
        List<Database.SaveResult> res = Database.insert(primaryConts, false);
        Test.stopTest();

        for (Database.SaveResult sr : res) {
            if (!sr.isSuccess()) {
                System.assertEquals('Account has an existing primary contact.', sr.getErrors()[0].getMessage());
            }
        }
    }

    @IsTest 
    private static void TestUpdateUpdateSuccess() {
        Account acct = new Account(Name = 'TestAccount');
        insert acct;

        List<Contact> conts = new List<Contact>();
        Contact primaryCont;
        for (Integer i = 1; i < 201; i++) {
            conts.add(new Contact(LastName = 'TestContact'+i, Primary_Contact__c = false, AccountId = acct.Id));
        }
        insert conts;

        Test.startTest();
        conts[0].Phone = '123';
        conts[0].Primary_Contact__c = True;
        update conts[0];
        Test.stopTest();

        List<Contact> secondaryContList = [SELECT Primary_Contact_Phone__c FROM Contact WHERE Primary_Contact__c = false AND Id IN :conts];
        for (Contact secondaryCont : secondaryContList) {
            System.assertEquals('123', secondaryCont.Primary_Contact_Phone__c);
        }
    }

    @IsTest 
    private static void TestInsertRemove() {
        Account acct = new Account(Name = 'TestAccount');
        insert acct;

        List<Contact> conts = new List<Contact>();
        Contact primaryCont;
        for (Integer i = 1; i < 201; i++) {
            if (i != 200) {
                conts.add(new Contact(LastName = 'TestContact'+i, Primary_Contact__c = false, Primary_Contact_Phone__c = '123', AccountId = acct.Id));
            } else {
                primaryCont = new Contact(LastName = 'TestContact'+i, Primary_Contact__c = true, Phone = '123', AccountId = acct.Id);
            }
        }
        insert conts;
        
        Test.startTest();
        insert primaryCont;
        List<Contact> contsBefore = [SELECT Primary_Contact_Phone__c FROM Contact WHERE Primary_Contact__c = false AND Id IN :conts];
        for (Contact contBefore : contsBefore) {
            System.assertEquals('123', contBefore.Primary_Contact_Phone__c);
        }
        primaryCont.Primary_Contact__c = false;
        update primaryCont;
        Test.stopTest();

        List<Contact> contsAfter = [SELECT Primary_Contact_Phone__c FROM Contact WHERE Primary_Contact__c = false AND Id IN :conts];

        for (Contact contAfter : contsAfter) {
            System.assertEquals(null, contAfter.Primary_Contact_Phone__c);
        }
    }
}