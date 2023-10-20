/**
* @author Elif Çevikoğlu
* @date October 11, 2023
* @description Helper class for ContactTrigger trigger.
*/
public class ContactTriggerHelper {
    
    /*******************************************************************************************************
    * @description filters contacts in before insert trigger.
    * @param List<Contact> contList
    * @return List<Contact>
    */
    public List<Contact> getContactsBeforeInsert(List<Contact> contList) {
        List<Contact> resContList = new List<Contact>();

        for (Contact cont : contList) {
            if (cont.Primary_Contact__c == true) {
                if (cont.AccountId != null) {
                    resContList.add(cont);
                } else {
                    cont.addError('You need to select an account for primary contact.');
                }
            }
        }

        return resContList;
    }

    /*******************************************************************************************************
    * @description filters contacts in before update trigger.
    * @param List<Contact> newContList
    * @param Map<Id, Contact> oldContMap
    * @return Map<String, List<Contact>>
    */
    public Map<String, List<Contact>> getContactsBeforeUpdate(List<Contact> newContList, Map<Id, Contact> oldContMap) {
        Map<String, List<Contact>> resMap = new Map<String, List<Contact>>();
        List<Contact> contListToRemove = new List<Contact>();
        List<Contact> contListToUpdate = new List<Contact>();

        for (Contact cont : newContList) {
            if (oldContMap.get(cont.Id).Primary_Contact__c == true && cont.Primary_Contact__c == false) {
                contListToRemove.add(cont);
            }

            if (oldContMap.get(cont.Id).Primary_Contact__c == false && cont.Primary_Contact__c == true) {
                if (cont.AccountId != null) {
                    contListToUpdate.add(cont);
                } else {
                    cont.addError('You need to select an account for primary contact.');
                }
            }
        }
        resMap.put('contListToRemove', contListToRemove);
        resMap.put('contListToUpdate', contListToUpdate);

        return resMap;
    }

    /*******************************************************************************************************
    * @description gets AccountIds With Existing Primary Contact.
    * @param List<Contact> contList
    * @return Set<Id>
    */
    private Set<Id> getAccountIdsWithExistingPrimaryContact(List<Contact> contList) {
        Set<Id> acctIds = new Set<Id>();
        for (Contact contAccountId : contList) {
            acctIds.add(contAccountId.AccountId);
        }

        Set<Id> acctsWithPrimary = new Set<Id>();
        for (Contact cont : [SELECT AccountId FROM Contact WHERE Primary_Contact__c = true AND AccountId IN :acctIds]) {
            acctsWithPrimary.add(cont.AccountId);
        }

        return acctsWithPrimary;
    }

    /*******************************************************************************************************
    * @description gets Cont Map To Remove Primary Contact Phone from.
    * @param List<Contact> contListToBeRemoved
    * @param Map<Id, Contact> oldContMap
    * @return Map<Id, Contact>
    */
    public Map<Id, Contact> getContMapToRemove(List<Contact> contListToBeRemoved, Map<Id, Contact> oldContMap) {
        Map<Id, Contact> contMapToRemove = new Map<Id, Contact>();

        for (Contact oldPrimaryCont : contListToBeRemoved) {
            if (oldPrimaryCont.AccountId != null) {
              contMapToRemove.put(oldPrimaryCont.AccountId, oldPrimaryCont);
            } else {
              contMapToRemove.put(oldContMap.get(oldPrimaryCont.Id).AccountId, oldPrimaryCont);
            }
        }

        return contMapToRemove;
    }

    /*******************************************************************************************************
    * @description gets Cont Map To Update Primary Contact Phone.
    * @param List<Contact> contListToBeUpdated
    * @return Map<Id, Contact>
    */
    public Map<Id, Contact> getContMapToUpdate(List<Contact> contListToBeUpdated) {
        Set<Id> acctsWithPrimary = getAccountIdsWithExistingPrimaryContact(contListToBeUpdated);

        Map<Id, Contact> contMapToUpdate = new Map<Id, Contact>();

        for (Contact cont : contListToBeUpdated) {
            if (acctsWithPrimary.contains(cont.AccountId)) {
              cont.addError('Account has an existing primary contact.');
            } else {
              if (contMapToUpdate.containsKey(cont.AccountId)) {
                cont.addError('An account can have only one primary contact.');
              } else {
                contMapToUpdate.put(cont.AccountId, cont);
              }
            }
          }

        return contMapToUpdate;
    }
}
