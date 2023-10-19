/**
* @author Elif Çevikoğlu
* @date October 11, 2023
* @description Visualforce extension for PrimaryContactPage.
*/
public class PrimaryContactPageHandler {
    public Account acct{get;set;}
    public List<Contact> contactsList{get {
        return [SELECT Id, Name, Title, Phone, Primary_Contact__c
                                    FROM Contact
                                    WHERE AccountId = :acct.Id
                                    AND Name LIKE :contName
                                    ORDER BY Primary_Contact__c DESC, Name
                                    LIMIT :limitInt
                                    OFFSET :offsetInt];
    } set;}

    public Integer limitInt{get;set;}
    public Integer offsetInt{get;set;}
    public Integer contactCount{get;set;}
    public Integer pageInt{get;set;}
    public List<SelectOption> paginationSizeOptions{get;set;}

    public Boolean prevDisabled{get {
        if (pageInt == 1) {
            return true;
        } else {
            return false;
        }
    } set;}

    public Boolean nextDisabled{get {
        Integer remaining = contactCount - limitInt * pageInt;
        if (remaining < limitInt) {
            return true;
        } else {
            return false;
        }
    } set;}
    
    public PrimaryContactPageHandler(ApexPages.StandardController sc) {
        this.acct = (Account)sc.getRecord();

        limitInt = 5;
        offsetInt = 0;
        pageInt = 1;
        paginationSizeOptions = new List<SelectOption>{new SelectOption('5','5'),
                                                        new SelectOption('10','10'),
                                                        new SelectOption('20','20')};
        contactCount = [SELECT Count() FROM Contact WHERE AccountId = :acct.Id AND Name LIKE :contName];
    }

    public PageReference nextPage() {
        pageInt += 1;
        offsetInt += limitInt;
        return null;
    }

    public PageReference prevPage() {
        pageInt -= 1;
        offsetInt -= limitInt;
        return null;
    }

    public PageReference firstPage() {
        pageInt = 1;
        offsetInt = 0;
        return null;
    }

    public PageReference lastPage() {
        pageInt = contactCount / limitInt;
        offsetInt = contactCount - Math.mod(contactCount, limitInt);
        return null;
    }

    public String contNameInput{get;set;}
    public String contName{get {
        if (contName == null) {
            contName = '%%';
        }
        return contName;
    } set;}

    public PageReference handleNameInput() {
        this.contName = '%' + contNameInput + '%';
        return null;
    }

    public Boolean showPopup{get;set;}
    public Boolean hasError{get;set;}
    public String popupTitle{get;set;}
    public String popupMessage{get;set;}

    public String newPrimaryContId{get;set;}
    public Contact newPrimaryCont{get;set;}

    public PageReference showPopUp() {
        newPrimaryCont = [SELECT Id, Name, Primary_Contact__c FROM Contact WHERE Id = :newPrimaryContId];
        popupTitle = 'Confirmation';
        popupMessage = 'Do you want to set '+newPrimaryCont.Name+' as primary contact?';
        showPopup = true;
        return null;
    }

    public PageReference savePopup() {
        try {
            Contact oldPrimaryCont = [SELECT Id, Name, LastName, Primary_Contact__c
                                        FROM Contact
                                        WHERE AccountId = :acct.Id
                                        AND Primary_Contact__c = true];
                    
            oldPrimaryCont.Primary_Contact__c = false;
            update oldPrimaryCont;
            newPrimaryCont.Primary_Contact__c = true;
            update newPrimaryCont;

            showPopup = false;
            hasError = false;
            return null;
        } catch(Exception e) {
            popupTitle = 'There was an error';
            popupMessage = 'Please contact your admin.';
            hasError = true;
            return null;
        }
    }

    public PageReference cancelPopup() {
        showPopup = false;
        hasError = false;
        return null;
    }
}