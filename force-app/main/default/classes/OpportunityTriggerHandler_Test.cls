@isTest
private class OpportunityTriggerHandler_Test {

    @TestSetup
    static void createData(){
        List<Opportunity> newOpps = new List<Opportunity>();
        for (Integer i=0; i<3; i++){
            Opportunity opp = new Opportunity(
                Name      = 'Test ' + i,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30)
            );
            newOpps.add(opp);
        }
        insert newOpps;
    }

    @isTest
    static void checkTasks(){
        // Query tasks for assertion
        List<Task> tasks = [SELECT Id FROM Task];
        Assert.areEqual(12, tasks.size());
    }
    
}