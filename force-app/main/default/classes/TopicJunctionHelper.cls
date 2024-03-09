public with sharing class TopicJunctionHelper {

    // set test run parameter
    public Boolean testRunSuccessful = false;

    /**
     * Method to check if the user has access to create Topic Junction records.
     * Calls getCrudPermissions from TopicPermissionsUtility.
     * @param newSObjects List of new Topic Junction records.
     * @param permission Type of permission required for User to take action.
     */
    public void checkIfUserHasPermission(List<SObject> newSObjects, String permission) {
        // Call getCrudPermissions from TopicPermissionsUtility for Topic Junction object
        Map<String, Boolean> crudPermissionsMap = TopicPermissionsUtility.getCrudPermissions(TopicConstants.TOPIC_JUNCTION_OBJECT);

        // Add error if User does not have permission
        for (SObject sObj : newSObjects) {
            if (crudPermissionsMap != null && crudPermissionsMap.containsKey(permission) && !crudPermissionsMap.get(permission)) {
                sObj.addError('Sorry, you do not have permission to take this action. Please contact your Administrator', false);
            }
        }
    }

    /**
     * Method to update Topic Junction records based on changes in related Topics.
     * Takes newTopicJunctions and oldTopicJunctionsMap, gets related Topic Ids and Names,
     * iterates over the list of newTopics, and updates Topic Junction Name and Id if applicable.
     * @param newTopicJunctions List of new Topic Junction records.
     * @param oldTopicJunctionsMap Map of old Topic Junction records.
     */
    public void updateTopicJunctions(List<Topic_Junction__c> newTopicJunctions, Map<Id, SObject> oldTopicJunctionsMap) {
        // Get Topic Ids
        List<Id> topicIds = new List<Id>();
        for (Topic_Junction__c topicJunction : newTopicJunctions) {
            topicIds.add(topicJunction.Topic__c);
        }
        // Get related Topic Ids and Names
        Map<Id, Topic__c> topicIdToTopicMap = new Map<Id, Topic__c>(TopicQueryUtility.getTopicsByIds(topicIds));

        // Iterate over the list of newTopicJunctions
        for (Topic_Junction__c newTopicJunction : newTopicJunctions) {
            // Check if Record_Id__c and Topic__c fields are not null and have changed
            if (newTopicJunction.Record_Id__c != null && newTopicJunction.Topic__c != null &&
                (oldTopicJunctionsMap != null && 
                 (newTopicJunction.Record_Id__c != oldTopicJunctionsMap.get(newTopicJunction.Id)?.get('Record_Id__c') ||
                  newTopicJunction.Topic__c != oldTopicJunctionsMap.get(newTopicJunction.Id)?.get('Topic__c')))) {

                // Get parameters to set fields
                Id recordId = newTopicJunction.Record_Id__c;
                String topicId = newTopicJunction.Topic__c;
                String recordName = newTopicJunction.Record_Name__c;
                String topicName = topicIdToTopicMap.get(newTopicJunction.Topic__c)?.Name;
                String objectType = recordId.getSObjectType().getDescribe().getName();

                // Populate Topic Junction Name and Topic Junction Id based on related Topic
                newTopicJunction.Topic_Junction_Name__c = String.format('{0}-{1}', new List<String>{recordName, topicName});
                newTopicJunction.Topic_Junction_Id__c = String.format('{0}-{1}-{2}', new List<String>{recordId, objectType, topicId});
            }
        }
    }
    
    /**
     * Method to update multi-select picklists on the object based on changes in Topic Junctions.
     * @param topicJunctions List of Topic Junction records.
     */
    public void updatePicklistValues(List<Topic_Junction__c> topicJunctions) {
        // Get valid sObjects fpr processing in bulk
        Set<Topic_Junction__c> sObjects = getValidSObjects(topicJunctions);
        // call future method to add values to picklist fields
        if (!sObjects.isEmpty() && !Test.isRunningTest()) {
            TopicPicklistUtility.updatePicklistValues(sObjects);
        } else {
            testRunSuccessful = true;
        }
    }
    
    /**
     * Method to activate multi-select picklist values on the object based on changes in Topic Junctions.
     * @param topicJunctions List of Topic Junction records.
     */
    public void activatePicklistValues(List<Topic_Junction__c> topicJunctions) {
        // Get valid sObjectIds fpr processing in bulk
        Set<Id> sObjectIds = getValidSObjectIds(topicJunctions);
        // call future method to activate picklist values
        if (!sObjectIds.isEmpty() && !Test.isRunningTest()) {
            activatePicklistValues(sObjectIds);
        } else {
            testRunSuccessful = true;
        }
    }

    /**
     * Method to activate multi-select picklist values on the object based on changes in Topic Junctions.
     * @param sObjectIds Set of sObject Ids of new Topic Junction records.
     */
    @future(callout=true)
    private static void activatePicklistValues(Set<Id> sObjectIds) {
        TopicPicklistUtility.activatePicklistValues(sObjectIds);
    }

    /**
     * Method to get list of Tag_Junctions from valid Topic Junction records
     * @param topicJunctions List of Topic Junction records.
     */
    public Set<Topic_Junction__c> getValidSObjects(List<Topic_Junction__c> topicJunctions) {
        // Parameters to store information for processing in bulk
        Set<Topic_Junction__c> sObjects = new Set<Topic_Junction__c>();
        // Process topicJunctions and build necessary data structures
        for (Topic_Junction__c topicJunction : topicJunctions) {
            if (topicJunction.Object_Field__c != null) {
                sObjects.add(topicJunction);
            }
        }
        return sObjects;
    }
    
    /**
     * Method to get list of sObjectIds from valid Topic Junction records
     * @param topicJunctions List of Topic Junction records.
     */
    public Set<Id> getValidSObjectIds(List<Topic_Junction__c> topicJunctions) {
        // Parameters to store information for processing in bulk
        Set<Id> sObjectIds = new Set<Id>();
        // Process topicJunctions and build necessary data structures
        for (Topic_Junction__c topicJunction : topicJunctions) {
            if (topicJunction.Object_Field__c != null) {
                sObjectIds.add(topicJunction.Record_Id__c);
            }
        }
        return sObjectIds;
    }

    public class TopicJunctionHelperException extends Exception {}
}