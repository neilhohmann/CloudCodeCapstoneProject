trigger OpportunityTrigger on Opportunity (after insert){

    OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
    handler.run();
}