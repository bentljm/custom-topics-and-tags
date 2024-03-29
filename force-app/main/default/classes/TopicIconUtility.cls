public with sharing class TopicIconUtility {

    // Map to store Topic_Configuration__mdt records based on object type and category
    private static Map<String, Topic_Configuration__mdt> objectTypeAndCategoryToConfigurationMap;

    // Static initialization block to populate the maps
    static {
        // Initialize the maps
        objectTypeAndCategoryToConfigurationMap = new Map<String, Topic_Configuration__mdt>();

        // Populate the configuration map using getTopicConfigurations method
        List<Topic_Configuration__mdt> allTopicConfigurations = TopicQueryUtility.getTopicConfigurations();
        for (Topic_Configuration__mdt config : allTopicConfigurations) {
            String key = config.Object_Visibility_dep__c + config.Category__c;
            objectTypeAndCategoryToConfigurationMap.put(key, config);
        }
    }

    /**
     * Getter for objectTypeAndCategoryToConfigurationMap.
     * @return Map representing the configuration map.
     */
    public static Map<String, Topic_Configuration__mdt> getObjectTypeAndCategoryToConfigurationMap() {
        return objectTypeAndCategoryToConfigurationMap;
    }

    /**
     * Method to get the SObject icon based on recordId and topicCategory.
     * @param recordId The Id of the record.
     * @param topicCategory The category of the topic.
     * @return String representing the SObject icon name.
     */
    public static String getSObjectIcon(Id recordId, String objectApiName, String topicCategory) {
        String recordIdPrefix = getRecordIdPrefix(recordId);
        // Record is a custom Topic__c object
        return getTopicIcon(objectApiName, topicCategory);
    }

    /**
     * Method to get the recordId prefix.
     * @param recordId The Id of the record.
     * @return String representing the recordId prefix.
     */
    private static String getRecordIdPrefix(Id recordId) {
        return String.valueOf(recordId)?.substring(0, 3);
    }

    /**
     * Method to get the SObject icon for custom Topic__c objects based on the topic category.
     * @param topicCategory The category of the topic.
     * @return String representing the SObject icon name.
     */
    private static String getTopicIcon(String objectApiName, String topicCategory) {
        // Query Topic_Configuration__mdt to get the icon name based on the topic category
        String objectCategoryKey = objectApiName + topicCategory;
        Topic_Configuration__mdt topicConfig = getObjectTypeAndCategoryToConfigurationMap().get(objectCategoryKey);

        // Check if a valid configuration is retrieved
        if (topicConfig != null && !String.isBlank(topicConfig.Icon_Name__c)) {
            return topicConfig.Icon_Name__c;
        } else {
            // Default to a generic icon if no specific match is found
            return getDefaultIcon();
        }
    }

    /**
     * Method to get the default SObject icon.
     * @return String representing the default SObject icon name.
     */
    private static String getDefaultIcon() {
        // Default to a generic icon if no specific match is found
        return 'utility:all';
    }

    public class TopicIconUtilityException extends Exception {}

}