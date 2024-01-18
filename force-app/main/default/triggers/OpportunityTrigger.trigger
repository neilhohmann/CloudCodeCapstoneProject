trigger OpportunityTrigger on Opportunity (before insert, after insert){

    OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
    handler.run();
}