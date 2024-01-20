public with sharing class OpportunityTriggerHandler extends TriggerHandler {
    private List<Opportunity> newOppList;
    private List<Opportunity> oldOppList;
    private Map<Id,Opportunity> newOppMap;
    private Map<Id,Opportunity> oldOppMap;

    public OpportunityTriggerHandler(){
        this.newOppList = (List<Opportunity>) Trigger.new;
        this.oldOppList = (List<Opportunity>) Trigger.old;
        this.newOppMap  = (Map<Id,Opportunity>) Trigger.newMap;
        this.oldOppMap  = (Map<Id,Opportunity>) Trigger.oldMap;
    }

    public override void beforeInsert(){
        updateOppName();
    }

    public override void afterInsert(){
        // METHOD: Create a new Task for newly inserted Opportunities
        List<Task> tasksToInsert = new List<Task>();
        for (Opportunity opp : newOppList){
            // Create task to update CV
            Task tsk1 = new Task(
                Subject      = 'Update Resume',
                Description  = 'Update resume to meet listing position description and skillset.',
                WhatId       = opp.Id,
                OwnerId      = opp.OwnerId,
                ActivityDate = Date.today()
                );
            tasksToInsert.add(tsk1);

            // Create task to write cover letter
            Task tsk2 = new Task(
                Subject      = 'Write Cover Letter',
                Description  = 'Write cover letter adapted to company, job listing, and skillset.',
                WhatId       = opp.Id,
                OwnerId      = opp.OwnerId,
                ActivityDate = Date.today().addDays(1)
                );
            tasksToInsert.add(tsk2);

            //Create task to find hiring manager name
            Task tsk3 = new Task(
                Subject      = 'Search LinkedIn for Hiring Manager',
                Description  = 'Find hiring manager\'s name on LinkedIn for cover letter. Reach out to state you are applying for position.',
                WhatId       = opp.Id,
                OwnerId      = opp.OwnerId,
                ActivityDate = Date.today()
                );
            tasksToInsert.add(tsk3);

            //Create task to submit application
            Task tsk4 = new Task(
                Subject      = 'Submit Application',
                WhatId       = opp.Id,
                OwnerId      = opp.OwnerId,
                ActivityDate = Date.today().addDays(1)
                );
            tasksToInsert.add(tsk4);
        }
        insert tasksToInsert;
    }

    private void updateOppName(){
        // Create account map only for acounts related to new/updated opps -- this will be used to update opp names
        Map<Id,Account> acctMap = new Map<Id,Account>([SELECT Id, Name FROM Account WHERE Id IN :getAcctIdsFromOpps()]);
        createDefaultOppName(acctMap);
    }

    private Set<Id> getAcctIdsFromOpps(){
        // Grab each AccountId from opps in Trigger.new (newOppList)
        Set<Id> acctIdSet = new Set<Id>(); 
        for(Opportunity opp : this.newOppList){
            acctIdSet.add(opp.AccountId);
        }
        return acctIdSet;
    }

    private void createDefaultOppName(Map<id,Account> acctMap){
        String createDate = Date.today().format();
        for(Opportunity opp : this.newOppList){
            opp.Name = acctMap.get(opp.AccountId).Name + ' ' + opp.Position_Title__c + ' ' + createDate;
        }
    }
}