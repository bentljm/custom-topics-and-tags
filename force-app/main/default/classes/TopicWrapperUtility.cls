public with sharing class TopicWrapperUtility {

    // Variables
    @AuraEnabled public String recordId { get; set; }
    @AuraEnabled public String objectApiName { get; set; }
    @AuraEnabled public String objectField { get; set; }
    @AuraEnabled public String topicCategories { get; set; }
    @AuraEnabled public String searchTerm { get; set; }

    /**
     * Method to check if the parameters for record retrieval are valid.
     * @return Boolean indicating whether the parameters are valid.
     */
    public Boolean isRetrieveValid() {
        // Check if recordId, objectApiName, and topicCategories are not null
        return recordId != null && objectApiName != null && topicCategories != null;
    }

    /**
     * Method to check if the parameters for record search are valid.
     * @return Boolean indicating whether the parameters are valid.
     */
    public Boolean isSearchValid() {
        // Check if recordId, objectApiName, searchTerm are not null and searchTerm length is greater than 1
        return recordId != null && objectApiName != null && topicCategories != null && searchTerm != null && searchTerm.length() > 1;
    }
}