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

        // Create new opp name -- Account Name + Position title (eg, Google Salesforce Developer)
        // Grab each AccountId from opps in Trigger.new (newOppList) - use for Map below
        Set<Id> acctIdSet = new Map<Id,AggregateResult>([SELECT Id, AccountId FROM Opportunity WHERE Id IN :newOppList GROUP BY AccountId]).keySet();
        System.debug(acctIdSet);
        // Set<Id> acctIdSet = new Set<Id>(); 
        // for(Opportunity opp : newOppList){
        //     acctIdSet.add(opp.AccountId);
        // }
        Map<Id,Account> acctMap = new Map<Id,Account>([SELECT Id, Name FROM Account WHERE Id IN :acctIdSet]);
        for(Opportunity opp : newOppList){
            opp.Name = acctMap.get(opp.AccountId).Name + ' ' + opp.Position_Title__c;
            System.debug(opp.Name);
        }
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

}