/**
* @author Elif Çevikoğlu
* @date October 11, 2023
* @description Trigger for handling validating and updating Primary_Contact_Phone__c field of Contact.
* Uses ContactTriggerHelper and UpdatePrimaryContactPhone classes.
*/
trigger ContactTrigger on Contact (before insert, before update) {
  List<Contact> contListToBeRemoved = new List<Contact>();
  List<Contact> contListToBeUpdated = new List<Contact>();

  Map<Id, Contact> contMapToRemove = new Map<Id, Contact>();
  Map<Id, Contact> contMapToUpdate = new Map<Id, Contact>();

  ContactTriggerHelper helper = new ContactTriggerHelper();

  switch on Trigger.operationType {
    when BEFORE_INSERT {
      contListToBeUpdated = helper.getContactsBeforeInsert(Trigger.New);
    }
    
    when BEFORE_UPDATE {
      Map<String, List<Contact>> filteredUpdatedConts = helper.getContactsBeforeUpdate(Trigger.New, Trigger.oldMap);
      contListToBeRemoved = filteredUpdatedConts.get('contListToRemove');
      contListToBeUpdated = filteredUpdatedConts.get('contListToUpdate');
    }
  }

  if (contListToBeRemoved.size() > 0) {
    contMapToRemove = helper.getContMapToRemove(contListToBeRemoved, Trigger.oldMap);
  }

  if (contListToBeUpdated.size() > 0) {
    contMapToUpdate = helper.getContMapToUpdate(contListToBeUpdated);
  }

  if (contMapToRemove.size() > 0) {
    UpdatePrimaryContactPhone removeJob = new UpdatePrimaryContactPhone(contMapToRemove, true);
    System.enqueueJob(removeJob);
  }

  if (contMapToUpdate.size() > 0) {
    UpdatePrimaryContactPhone updateJob = new UpdatePrimaryContactPhone(contMapToUpdate, false);
    System.enqueueJob(updateJob);
  }
}