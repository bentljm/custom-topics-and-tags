public with sharing class TopicQueryUtility {

    /**
     * Method to retrieve all Topic Configurations from Topic_Configuration__mdt.
     * @return List of Topic_Configuration__mdt records.
     */
    public static List<Topic_Configuration__mdt> getTopicConfigurations() {
        List<Topic_Configuration__mdt> topicConfigurations = new List<Topic_Configuration__mdt>();
        try {
            topicConfigurations = [
                SELECT Label, Category__c, Object_Visibility__c, Object_Field__c, Icon_Name__c, Pill_Color__c, Pill_Style__c
                FROM Topic_Configuration__mdt
            ];
        } catch (Exception e) {
            // Handle exception (e.g., log or rethrow)
            throw new TopicQueryUtilityException('TopicQueryUtility: Failed to get Topic Configurations: ' + e.getMessage());
        }
        return topicConfigurations;
    }

    /**
     * Method to retrieve Topic Configurations from Topic_Configuration__mdt based on category and objectApiName.
     * @param objectApiName The API name of the object.
     * @param topicCategories List of topic categories to filter by.
     * @return List of Topic_Configuration__mdt records.
     */
    public static List<Topic_Configuration__mdt> getTopicConfigurationsByCategory(String objectApiName, String topicCategories) {
        List<Topic_Configuration__mdt> topicConfigurations = new List<Topic_Configuration__mdt>();
        // Split the input string into a list of category names
        List<String> categories = topicCategories.split(',');
        try {
            topicConfigurations = [
                SELECT Label, Category__c, Object_Visibility__c, Object_Field__c, Icon_Name__c, Pill_Color__c, Pill_Style__c
                FROM Topic_Configuration__mdt
                WHERE Category__c IN :categories 
                AND Object_Visibility__c = :objectApiName
            ];
        } catch (Exception e) {
            // Handle exception (e.g., log or rethrow)
            throw new TopicQueryUtilityException('TopicQueryUtility: Failed to get Topic Configurations by Category: ' + e.getMessage());
        }
        return topicConfigurations;
    }

    /**
     * Method to retrieve topics by their Ids.
     * @param topicIds List of topic Ids to retrieve.
     * @return List of Topic records.
     */
    public static List<Topic__c> getTopicsByIds(List<Id> topicIds) {
        List<Topic__c> topics = new List<Topic__c>();
        try {
            topics = [
                SELECT Id, Name, Category__c, Start_Date__c, End_Date__c
                FROM Topic__c
                WHERE Id IN :topicIds
            ];
        } catch (Exception e) {
            // Handle exception (e.g., log or rethrow)
            throw new TopicQueryUtilityException('TopicQueryUtility: Failed to get Topics by Id: ' + e.getMessage());
        }
        return topics;
    }

    /**
     * Method to retrieve topics by their names excluding certain Ids.
     * @param topicIdsToExclude List of topic Ids to exclude.
     * @param topicNames List of topic names to retrieve.
     * @return List of Topic records.
     */
    public static List<Topic__c> getTopicsByName(Set<Id> topicIdsToExclude, Set<String> topicNames) {
        List<Topic__c> topics = new List<Topic__c>();
        try {
            topics = [
                SELECT Id, Name, Category__c, Start_Date__c, End_Date__c
                FROM Topic__c
                WHERE Id NOT IN :topicIdsToExclude 
                AND Name IN :topicNames];
        } catch (Exception e) {
            // Handle exception (e.g., log or rethrow)
            throw new TopicQueryUtilityException('TopicQueryUtility: Failed to get Topics by Name: ' + e.getMessage());
        }
        return topics;
    }

    /**
     * Method to retrieve topics related to a record based on recordId, objectApiName, and topicCategories.
     * @param recordId The Id of the record.
     * @param objectApiName The API name of the object.
     * @param topicCategories List of topic categories to filter by.
     * @return List of Topic_Junction__c records.
     */
    public static List<Topic_Junction__c> getTopicsRelatedToRecord(Id recordId, String objectApiName, String topicCategories) {
        List<String> categories = topicCategories.split(',');
        String uniqueIdentifier = addWildcard(recordId, objectApiName);
        List<Topic_Junction__c> topicsRelatedToRecord = new List<Topic_Junction__c>();
        try {
            topicsRelatedToRecord = [
                SELECT Id, Name, Topic_Junction_Id__c, Record_Id__c, Record_Name__c, Object_Type__c, Object_Field__c,
                    Topic__c, Topic__r.Name, Topic__r.Active__c, Topic__r.Category__c
                FROM Topic_Junction__c
                WHERE Topic__r.Category__c IN :categories
                    AND Topic_Junction_Id__c LIKE :uniqueIdentifier
                ORDER BY Topic__r.Category__c, Topic__r.Name];
        } catch (Exception e) {
            // Handle exception (e.g., log or rethrow)
            throw new TopicQueryUtilityException('TopicQueryUtility: Failed to get Topics Related to Records: ' + e.getMessage());
        }
        return topicsRelatedToRecord;
    }

    /**
     * Method to add a wildcard to the recordId and objectApiName using String.format.
     * @param recordId The record Id to which the wildcard will be added.
     * @param objectApiName The object API name to which the wildcard will be added.
     * @return String with added wildcard if applicable.
     */
    private static String addWildcard(Id recordId, String objectApiName) {
        return String.format('{0}-{1}{2}', new List<String>{recordId, objectApiName, '%'});
    }

    /**
     * Method to retrieve topics related to a record based on recordIds, objectApiName, and topicCategories.
     * @param recordIds Set of record Ids
     * @param topicCategories Set of topic categories to filter by.
     * @return List of Topic_Junction__c records.
     */
    public static List<Topic_Junction__c> getTopicsRelatedToRecordsByObjectId(Set<Id> recordIds, Set<String> topicCategories) {
        List<Topic_Junction__c> topicsRelatedToRecord = new List<Topic_Junction__c>();
        try {
            topicsRelatedToRecord = [
                SELECT Id, Name, Topic_Junction_Id__c, Record_Id__c, Record_Name__c, Object_Type__c, Object_Field__c,
                    Topic__c, Topic__r.Name, Topic__r.Active__c, Topic__r.Category__c
                FROM Topic_Junction__c
                WHERE Record_Id__c IN :recordIds
                    AND Topic__r.Category__c IN :topicCategories
                ORDER BY Name DESC];
        } catch (Exception e) {
            // Handle exception (e.g., log or rethrow)
            throw new TopicQueryUtilityException('TopicQueryUtility: Failed to get Topics Related to Records by Object Id: ' + e.getMessage());
        }
        return topicsRelatedToRecord;
    }

    /**
     * Method to build an aggregate query for recently used topics.
     * @param topicCategories Comma-separated string of topic categories.
     * @return List of AggregateResult representing the SOQL aggregate query results.
     */
    public static List<AggregateResult> getAggregatedTopics(String topicCategories) {
        List<AggregateResult> aggregateResults = new List<AggregateResult>();

        // Split the comma-separated categories string into a list
        List<String> categories = topicCategories.split(',');

        // Get the running user's Id
        Id runningUserId = UserInfo.getUserId();

        // Build the SOQL aggregate query
        try {
            aggregateResults = [
                SELECT Topic__c topic, Topic__r.Name name, COUNT(Id), Topic__r.Category__c category
                FROM Topic_Junction__c
                WHERE Topic__r.Active__c = true
                    AND CreatedById = :runningUserId
                    AND Topic__r.Category__c IN :categories
                GROUP BY Topic__c, Topic__r.Name, Topic__r.Category__c
                HAVING COUNT(Id) > 0
                ORDER BY Topic__r.Category__c
                LIMIT 20
            ];
        } catch (Exception e) {
            // Handle exception (e.g., log or rethrow)
            throw new TopicQueryUtilityException('TopicQueryUtility: Failed to get aggregate count of Topics Related to Records: ' + e.getMessage());
        }
        return aggregateResults;
    }

    public class TopicQueryUtilityException extends Exception {}
}