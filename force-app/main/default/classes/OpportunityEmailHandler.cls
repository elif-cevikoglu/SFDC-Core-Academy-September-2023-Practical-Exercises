/**
* @author Elif Çevikoğlu
* @date October 15, 2023
* @description OpportunityEmailHandler batch class for summarizing opportunity amounts and handling emails.
*/

public class OpportunityEmailHandler implements Database.Batchable<sObject> {
    /*******************************************************************************************************
    * @description Gets all accounts with their suitable contacts and opportunities.
    * @param Database.BatchableContext bc
    * @return Database.getQueryLocator
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name, ' +
                                        '(SELECT Id, Email, AccountId FROM Contacts ' +
                                            'WHERE Primary_Contact__c = true AND Email != null), ' +
                                        '(SELECT Amount, StageName FROM Opportunities ' +
                                            'WHERE CreatedDate = THIS_MONTH OR LastModifiedDate = THIS_MONTH) ' +
                                        'FROM Account');
    }

    /*******************************************************************************************************
    * @description Summarizes opportunities and sends emails to their primary contacts.
    * @param Database.BatchableContext bc
    * @param List<Account> scope
    * @return void
    */
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        Map<Id, Map<String, Integer>> summaryMap = new Map<Id, Map<String, Integer>>();
        List<Messaging.SingleEmailMessage> mailsList = new List<Messaging.SingleEmailMessage>();
    
        // Loop over accounts
        for (Account acct : scope) {
            summaryMap.put(acct.Id, new Map<String, Integer>{'Closed Won' => 0, 
                                                            'Closed Lost' => 0, 
                                                            'Open' => 0});

            // Calculate summaries
            for (Opportunity oppt : acct.Opportunities) {
                String stageName = oppt.StageName;
                Integer amount = Integer.valueOf(oppt.Amount);
                
                if (stageName == 'Closed Won' || stageName == 'Closed Lost') {
                    summaryMap.get(acct.Id).put(stageName, summaryMap.get(acct.Id).get(stageName) + amount);
                } else {
                    summaryMap.get(acct.Id).put('Open', summaryMap.get(acct.Id).get('Open') + amount);
                }
            }

            // Create emails
            for (Contact cont : acct.Contacts) {
                Messaging.SingleEmailMessage emailObj = new Messaging.SingleEmailMessage();
                Map<String, Integer> accountResults = summaryMap.get(cont.AccountId);
    
                List<String> toAddresses = new List<String>{cont.Email};
                emailObj.setWhatId(acct.Id);
                emailObj.setToAddresses(toAddresses);
                emailObj.setSubject('Summary of This Month');
    
                String body = '<p>Here are the summaries of opportunity amounts for ' + acct.Name + '</p><br/><br/>';
                for (String stageName : accountResults.keySet()) {
                    Integer summary = accountResults.get(stageName);
                    String summaryStr = (summary != 0) ? String.valueOf(summary) : '0';
                    body += '<p>' + acct.Name + ' ' + stageName + ' ' + summaryStr + '</p><br/>';
                }
    
                emailObj.setHtmlBody(body);
                mailsList.add(emailObj);
            }
        }
    
        // Send emails
        if (!mailsList.isEmpty()) {
            Messaging.sendEmail(mailsList);
        }
    }

    public void finish(Database.BatchableContext bc) {}
}