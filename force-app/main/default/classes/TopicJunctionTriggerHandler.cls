public without sharing class TopicJunctionTriggerHandler implements TriggerHandler {
    private boolean triggerIsExecuting;
    private integer triggerSize;
    public TopicJunctionHelper helper;
    public TopicJunctionTriggerHandler(boolean triggerIsExecuting, integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
        this.helper = new TopicJunctionHelper();
    }
    public void beforeInsert(List<Topic_Junction__c> newTopicJunctions) {
        helper.checkIfUserHasPermission(newTopicJunctions, TopicConstants.PERMISSION_CREATE);
        helper.updateTopicJunctions(newTopicJunctions, null);
    }
    public void beforeUpdate(List<Topic_Junction__c> oldTopicJunctions, List<Topic_Junction__c> newTopicJunctions, Map<ID, SObject> oldTopicJunctionsMap, Map<ID, SObject> newTopicJunctionsMap) {
        helper.checkIfUserHasPermission(newTopicJunctions, TopicConstants.PERMISSION_UPDATE);
        helper.updateTopicJunctions(newTopicJunctions, oldTopicJunctionsMap);
    }
    public void beforeDelete(List<Topic_Junction__c> oldTopicJunctions, Map<ID, SObject> oldTopicJunctionsMap) {
        helper.checkIfUserHasPermission(oldTopicJunctions, TopicConstants.PERMISSION_DELETE);
    }
    public void afterInsert(List<Topic_Junction__c> newTopicJunctions, Map<ID, SObject> newTopicJunctionsMap) {
        helper.updatePicklistValues(newTopicJunctions);
        helper.activatePicklistValues(newTopicJunctions);
    }
    public void afterUpdate(List<Topic_Junction__c> oldTopicJunctions, List<Topic_Junction__c> newTopicJunctions, Map<ID, SObject> oldTopicJunctionsMap, Map<ID, SObject> newTopicJunctionsMap) {
        helper.updatePicklistValues(newTopicJunctions);
    }
    public void afterDelete(List<Topic_Junction__c> oldTopicJunctions, Map<ID, SObject> oldTopicJunctionsMap) {
        helper.updatePicklistValues(oldTopicJunctions);
    }
    public void afterUndelete(List<Topic_Junction__c> newTopicJunctions, Map<ID, SObject> newTopicJunctionsMap) {
    }
}