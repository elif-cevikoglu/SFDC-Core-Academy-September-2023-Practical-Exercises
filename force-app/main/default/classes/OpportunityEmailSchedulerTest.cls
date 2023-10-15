/**
* @author Elif Çevikoğlu
* @date October 15, 2023
* @description Tests OpportunityEmailScheduler.
*/
  @IsTest
  private class OpportunityEmailSchedulerTest {
    public static Map<String, Map<String, String>> CONFIG = new Map<String, Map<String, String>>{
        'day' => new Map<String, String>{'NAME' => 'Schedule Opportunity Daily', 'CRON' => '0 0 10 * * ? *'},
        'week' => new Map<String, String>{'NAME' => 'Schedule Opportunity Weekly', 'CRON' => '0 0 13 ? * FRI *'},
        'month' => new Map<String, String>{'NAME' => 'Schedule Opportunity Monthly', 'CRON' => '0 0 18 ? * FRIL *'},
        'default' => new Map<String, String>{'NAME' => 'Schedule Opportunity Monthly', 'CRON' => '0 0 18 ? * FRIL *'}
    };

    @IsTest 
    private static void testOpportunityEmailScheduler() {
        List<AsyncApexJob> startList = [SELECT Id FROM AsyncApexJob];
        
        System.assertEquals(0, startList.size());

        Test.startTest();
        List<String> idsList = new List<String>();
        String dayId = OpportunityEmailScheduler.scheduleOpportunityEmail('day');
        String weekId = OpportunityEmailScheduler.scheduleOpportunityEmail('week');
        String monthId = OpportunityEmailScheduler.scheduleOpportunityEmail('month');
        String defaultId = OpportunityEmailScheduler.scheduleOpportunityEmail('none');
        idsList.add(dayId);
        idsList.add(weekId);
        idsList.add(monthId);
        idsList.add(defaultId);
        Test.stopTest();

        List<CronTrigger> afterList = [SELECT Id, CronExpression FROM CronTrigger WHERE Id IN :idsList];

        if (afterList.size() > 0) {
            System.assertEquals(CONFIG.get('day').get('CRON'), afterList[0].CronExpression);
            System.assertEquals(CONFIG.get('week').get('CRON'), afterList[1].CronExpression);
            System.assertEquals(CONFIG.get('month').get('CRON'), afterList[2].CronExpression);
            System.assertEquals(CONFIG.get('default').get('CRON'), afterList[3].CronExpression);
        }
      }
  }