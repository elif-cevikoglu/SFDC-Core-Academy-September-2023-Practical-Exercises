/**
* @author Elif Çevikoğlu
* @date October 15, 2023
* @description Schedules OpportunityEmailHandler.
*/

public class OpportunityEmailScheduler implements Schedulable {
    public static Map<String, Map<String, String>> CONFIG = new Map<String, Map<String, String>>{
        'day' => new Map<String, String>{'NAME' => 'Schedule Opportunity Daily', 'CRON' => '0 0 10 * * ? *'},
        'week' => new Map<String, String>{'NAME' => 'Schedule Opportunity Weekly', 'CRON' => '0 0 13 ? * FRI *'},
        'month' => new Map<String, String>{'NAME' => 'Schedule Opportunity Monthly', 'CRON' => '0 0 18 ? * FRIL *'},
        'default' => new Map<String, String>{'NAME' => 'Schedule Opportunity Monthly (Default)', 'CRON' => '0 0 18 ? * FRIL *'}
    };

    public static String scheduleOpportunityEmail(String onceA) {
        if (CONFIG.keySet().contains(onceA)) {
            return System.schedule(CONFIG.get(onceA).get('NAME'), CONFIG.get(onceA).get('CRON'), new OpportunityEmailScheduler());
        } else {
            return System.schedule(CONFIG.get('default').get('NAME'), CONFIG.get('default').get('CRON'), new OpportunityEmailScheduler());
        }
    }

    public void execute(SchedulableContext sc) {
        Id batchId = Database.executeBatch(new OpportunityEmailHandler());
    }
}
