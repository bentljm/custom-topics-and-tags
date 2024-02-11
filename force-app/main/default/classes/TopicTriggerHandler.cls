public without sharing class TopicTriggerHandler implements TriggerHandler {
    private boolean triggerIsExecuting;
    private integer triggerSize;
    public TopicHelper helper; 
    public TopicTriggerHandler(boolean triggerIsExecuting, integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
        this.helper = new TopicHelper();
    }
    public void beforeInsert(List<Topic__c> newTopics) {
        helper.checkIfUserHasPermission(newTopics, TopicConstants.PERMISSION_CREATE);
        helper.checkIfTopicIsDuplicate(newTopics);
    }
    public void beforeUpdate(List<Topic__c> oldTopics, List<Topic__c> newTopics, Map<ID, SObject> oldTopicsMap, Map<ID, SObject> newTopicsMap) {
        helper.checkIfUserHasPermission(newTopics, TopicConstants.PERMISSION_UPDATE);
        helper.checkIfTopicIsDuplicate(newTopics);
    }
    public void beforeDelete(List<Topic__c> oldTopics, Map<ID, SObject> oldTopicsMap) {
        helper.checkIfUserHasPermission(oldTopics, TopicConstants.PERMISSION_DELETE);
    }
    public void afterInsert(List<Topic__c> newTopics, Map<ID, SObject> newTopicsMap) {
    }
    public void afterUpdate(List<Topic__c> oldTopics, List<Topic__c> newTopics, Map<ID, SObject> oldTopicsMap, Map<ID, SObject> newTopicsMap) {
    }
    public void afterDelete(List<Topic__c> oldTopics, Map<ID, SObject> oldTopicsMap) {
    }
    public void afterUndelete(List<Topic__c> newTopics, Map<ID, SObject> newTopicsMap) {
    }
}