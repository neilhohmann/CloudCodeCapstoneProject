@isTest
private class OpportunityTriggerHandler_Test {

    @TestSetup
    static void createData(){

        // Create Test Accounts
        List<Account> newAccts = new List<Account>();
        for (Integer i=0; i<3; i++){
            Account acc = new Account(Name = 'Test Account ' + i);
            newAccts.add(acc);
        }
        insert newAccts;
        System.debug('newAccts: ' + newAccts);


        // Create Test Opps
        List<Opportunity> newOpps = new List<Opportunity>();
        for(Account acc : newAccts){
            Opportunity opp = new Opportunity(
                Name              = 'Test ',
                AccountId         = acc.Id,
                Position_Title__c = 'Salesforce Developer',
                StageName         = 'Prepare Resume',
                CloseDate         = Date.today().addDays(14)
            );
            System.debug('opp: ' + opp);
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

    @isTest
    static void checkOppNames(){
        String oppName;
        // Query Opps to check names
        List<Opportunity> opps = [SELECT Id, Name, Account.Name, Position_Title__c FROM Opportunity];
        for(Opportunity opp : opps){
            oppName = opp.Account.Name + ' ' + opp.Position_Title__c;
            Assert.areEqual(oppName, opp.Name);
        }
    }
}