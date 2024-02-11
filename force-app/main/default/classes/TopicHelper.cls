public with sharing class TopicHelper {

    /**
     * Method to check if the user has create access for the specified SObjects.
     * @param sObjects List of SObjects to check create access.
     * @throws TopicHelperException if the user does not have create access.
     */
    public void checkIfUserHasPermission(List<SObject> sObjects, String permission) {
        // Call getCrudPermissions from TopicPermissionsUtility for Topic object
        Map<String, Boolean> crudPermissionsMap = TopicPermissionsUtility.getCrudPermissions(TopicConstants.TOPIC_OBJECT);
        
        // Add error if User does not have permission
        for (SObject sObj : sObjects) {
            if (crudPermissionsMap != null && crudPermissionsMap.containsKey(permission) && !crudPermissionsMap.get(permission)) {
                // Add error if the user does not have create access
                sObj.addError('Sorry, you do not have permission to take this action. Please contact your Administrator', false);
            }
        }
    }

    /**
     * Method to check if there are duplicate topics or date overlap in the given list.
     * @param newTopics List of new topics to check for duplicates or date overlap.
     * @throws TopicHelperException if duplicate topics or date overlap are found.
     */
    public void checkIfTopicIsDuplicate(List<Topic__c> newTopics) {
        // Sets to store unique Ids and Names of new topics
        Set<Id> topicIds = new Set<Id>();
        Set<String> topicNames = new Set<String>();

        // Extract Ids and Names from new topics and add to sets
        for (Topic__c newTopic : newTopics) {
            topicIds.add(newTopic.Id);
            topicNames.add(newTopic.Name);
        }

        // Map to store existing topics using the topic key (Name + Category)
        Map<String, List<Topic__c>> existingTopicMap = new Map<String, List<Topic__c>>();

        // Get existing topics from TopicQueryUtility based on Ids and Names
        List<Topic__c> existingTopicsList = TopicQueryUtility.getTopicsByName(topicIds, topicNames);

        // Populate the map using the topic key (Name + Category)
        for (Topic__c existingTopic : existingTopicsList) {
            String topicKey = generateTopicKey(existingTopic);

            // If the map already contains the key, add the existing topic to the list
            if (existingTopicMap.containsKey(topicKey)) {
                existingTopicMap.get(topicKey).add(existingTopic);
            } else {
                // If the map doesn't contain the key, create a new list with the existing topic
                existingTopicMap.put(topicKey, new List<Topic__c>{existingTopic});
            }
        }

        // Check for duplicate topics or date overlap in new topics
        for (Topic__c newTopic : newTopics) {
            String topicKey = generateTopicKey(newTopic);

            if (existingTopicMap.containsKey(topicKey)) {
                List<Topic__c> existingTopics = existingTopicMap.get(topicKey);
                for (Topic__c existingTopic : existingTopics) {
                    if (isTopicDuplicate(existingTopic, newTopic)) {
                        newTopic.addError('Duplicate topic found or dates overlap with existing topics.');
                    }
                }
            }
        }
    }

    /**
     * Method to get the Topic key
     * @param newTopic The new topic to check for date overlap.
     * @return String representing Topic key
     */
    private String generateTopicKey(Topic__c newTopic) {
        return newTopic.Name + newTopic.Category__c;
    }
    
    /**
     * Method to check if the new topic has date overlap with existing topics.
     * @param newTopic The new topic to check for date overlap.
     * @return Boolean indicating whether there is date overlap.
     */
    private Boolean isTopicDuplicate(Topic__c existingTopic, Topic__c newTopic) {
        if ((existingTopic.Start_Date__c == null && existingTopic.End_Date__c == null) ||
            (newTopic.Start_Date__c == null && newTopic.End_Date__c == null) ||
            (newTopic.Start_Date__c != null && newTopic.Start_Date__c <= existingTopic.End_Date__c && 
            newTopic.End_Date__c != null && newTopic.End_Date__c >= existingTopic.Start_Date__c)) {
            return true; // Duplicate Topic
        }
        return false; // No duplicate
    }

    /**
     * @AuraEnabled method to retrieve user permissions on Topic object
     * @return Map of user permissions
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Boolean> getCrudPermissions() {
        // Call getCrudPermissions from TopicPermissionsUtility for Topic object
        return TopicPermissionsUtility.getCrudPermissions(TopicConstants.TOPIC_OBJECT);
    }

    /**
     * @AuraEnabled method to retrieve Topic Configurations by object API name and category.
     * @param objectApiName The API name of the object.
     * @param category The category of the topic configuration.
     * @return List of Topic_Configuration__mdt records.
     */
    @AuraEnabled(cacheable=true)
    public static List<Topic_Configuration__mdt> getTopicConfigurations(String objectApiName, String topicCategories) {
        // Call the existing method from TopicQueryUtility
        return TopicQueryUtility.getTopicConfigurationsByCategory(objectApiName, topicCategories);
    }

    /**
     * @AuraEnabled method to retrieve data for a given recordId and objectApiName.
     * @param recordId The Id of the record to retrieve data for.
     * @param objectApiName The API name of the object.
     * @return Map<String, Object> representing the record data.
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, SObject> getRecordData(Id recordId, String objectApiName) {
        // List to store Record Data
        Map<String, SObject> recordData = new Map<String, SObject>();
        try {
            // Determine the most appropriate field for Name based on object describe information
            String nameField = getNameField(objectApiName);
            
            // Use dynamic SOQL to query record data
            String queryString = String.format('{0} {1} {2} {3} {4}', 
                new List<String>{'SELECT', nameField, 'FROM', objectApiName, 'WHERE Id = :recordId WITH USER_MODE LIMIT 1'}
            ); 

            // Execute the dynamic SOQL query
            List<SObject> records = Database.query(queryString);
            if (!records.isEmpty()) {
                recordData.put(nameField, records[0]);
            }
            return recordData;
        } catch (Exception e) {
            // Handle exception (e.g., log or rethrow)
            throw new TopicHelperException('TopicHelper: Failed to get record data: ' + e.getMessage());
        }
    }

    /**
     * Method to get the most appropriate field for the record's name based on object describe information.
     * @param objectApiName The API name of the object.
     * @return String representing the name field for the object.
     */
    public static String getNameField(String objectApiName) {
        // Get the SObject describe information
        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(objectApiName).getDescribe();

        // Check if the object has a standard 'Name' field
        if (describeResult.fields.getMap().containsKey('Name')) {
            return 'Name';
        }

        // Iterate through all fields to find the first suitable text-like field
        for (SObjectField field : describeResult.fields.getMap().values()) {
            if(field.getDescribe().getLabel().containsIgnoreCase('Name')) {
                return field.getDescribe().getName(); 
            }
        }

        // Iterate through all fields to find the first suitable text-like field
        for (SObjectField field : describeResult.fields.getMap().values()) {
            if (isTextLikeField(field.getDescribe().getType())) {
                return field.getDescribe().getName();
            }
        }

        // If no suitable field is found, default to the first field in the describe result
        return describeResult.fields.getMap().values().iterator().next().getDescribe().getName();
    }


    /**
     * Method to check if field is Accessible on Object
     * @param objectApiName The API Name of the Object
     * @param fieldName The API Name of the Field
     * @return Boolean representing if field is accessible
     */
    public static Boolean isAccessible(String objectApiName, String fieldName) {
        SObjectType schemaType = Schema.getGlobalDescribe().get(objectApiName);
        Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();
        DescribeFieldResult fieldDescribe = fields.get(fieldName).getDescribe();
        return fieldDescribe.isAccessible();
    }

    /**
     * Method to check if the field type is text-like.
     * @param fieldType The display type of the field.
     * @return Boolean indicating whether the field type is text-like.
     */
    private static Boolean isTextLikeField(Schema.DisplayType fieldType) {
        return fieldType == Schema.DisplayType.STRING;
    }

    /**
     * @AuraEnabled method to retrieve recently used topics based on topic category.
     * Calls the buildAggQuery method passing in topicCategories to get aggregated results.
     * @param topicCategories Comma-separated string of topic categories.
     * @return JSON string representing a list of recently used topics.
     */
    @AuraEnabled(cacheable=true)
    public static String getTopicsRecentlyUsed(String objectApiName, String topicCategories) {
        // List to store recently used topics
        List<Topic> recentlyUsedTopics = new List<Topic>();
        // Call the buildAggQuery method to get aggregate results
        List<AggregateResult> aggResults = TopicQueryUtility.getAggregatedTopics(topicCategories);

        // Iterate over AggregateResults and build Topic objects
        for (AggregateResult aggResult : aggResults) {
            // Extract data from AggregateResult
            Id topicId = (String) aggResult.get('topic');
            String topicName = (String) aggResult.get('name');
            String topicCategory = (String) aggResult.get('category');
            String topicObjectType = objectApiName;

            // Build Topic object and set Id, name, and category
            SObject topicObject = Schema.getGlobalDescribe().get(TopicConstants.TOPIC_OBJECT).newSObject();
            topicObject.put('Id', topicId);
            topicObject.put('Name', topicName);
            topicObject.put('Category__c', topicCategory);
            
            // Add the Topic object to the list
            recentlyUsedTopics.add(constructTopic(topicObject, topicId, topicObjectType, topicCategory));
        }
        // Return the list of recently used topics
        return JSON.serialize(recentlyUsedTopics);
    }

    /**
     * @AuraEnabled method to get topics related to object record.
     * @param wrapper The TopicWrapperUtility containing information for retrieval.
     * @return List of Topic records associated with the specified record.
     */
    @AuraEnabled(cacheable=true)
    public static String getTopicsRelatedToRecord(TopicWrapperUtility wrapper) {
        // List to store Topic objects
        List<Topic> topics = new List<Topic>();
        // Check if the wrapper is valid for retrieval
        if (wrapper != null && wrapper.isRetrieveValid()) {
            // Call the utility method to get topics associated with the record
            List<Topic_Junction__c> topicJunctions = TopicQueryUtility.getTopicsRelatedToRecord(wrapper.recordId, wrapper.objectApiName, wrapper.topicCategories);
            // Iterate through Topic_Junction__c records and construct Topic objects
            for (Topic_Junction__c topicJunction : topicJunctions) {
                topics.add(constructTopic(topicJunction, topicJunction.Topic__c, topicJunction.Object_Type__c, topicJunction.Topic__r.Category__c));
            }
        }
        // Return the list of topics associated to record
        return JSON.serialize(topics);
    }

    /**
     * @AuraEnabled method to retrieve topics based on user-entered search value.
     * Accepts a TopicWrapperUtility and then constructs Topic records from search results.
     * @param wrapper TopicWrapperUtility instance.
     * @return List of Topic objects matching the search criteria.
     */
    @AuraEnabled(cacheable=true)
    public static String getTopicsOnSearch(TopicWrapperUtility wrapper) {
        // List to store Topic objects
        List<Topic> searchResults = new List<Topic>();
        // Check if the search criteria is valid
        if (wrapper != null && wrapper.isSearchValid()) {
            // Call the performSearchAndBuildTopicList method to construct Topic records from search results
            searchResults = performSearchAndBuildTopicList(wrapper);
        }
        // Return the list of Topic objects to the Lightning Web Component
        return JSON.serialize(searchResults);
    }

    /**
     * Builds the list of Topics based on provided wrapper
     * @param searchValue User-entered search value.
     * @return List of Topic records matching the search criteria.
     */
    private static List<Topic> performSearchAndBuildTopicList(TopicWrapperUtility wrapper) {
        // List to store Topic records
        List<Topic> topics = new List<Topic>();
        // Call a method to build a SOSL query for topics matching the search value
        List<SObject> searchResults = performSearch(wrapper);
        // Iterate over the search results and construct Topic records
        for (SObject sObj : searchResults) {
            String topicId = (String) sObj.get(TopicConstants.TOPIC_ID_FIELD);
            String topicCategory = (String) sObj.get(TopicConstants.TOPIC_CATEGORY_FIELD);
            // construct Topic
            topics.add(constructTopic(sObj, topicId, wrapper.objectApiName, topicCategory));
        }
        return topics;
    }

    /**
     * Extracts search term, query limit, object API name, and categories to build an SOSL query.
     * Returns a JSON string representing a list of Topic records matching the search criteria.
     * @param wrapper TopicWrapperUtility containing search term, query limit, objectApiName, and topicCategories.
     * @return JSON string representing a list of Topic records matching the search criteria.
     */
    public static List<SObject> performSearch(TopicWrapperUtility wrapper) {
        try {
            // Clean search term, get query limit, object API name, and categories from the wrapper
            String searchTerm = cleanSearchTerm(wrapper.searchTerm);
            String objectApiName = wrapper.objectApiName;
            List<String> categories = wrapper.topicCategories.split(',');

            // Build SOSL query
            String soslQuery = 
                'FIND {' + searchTerm + '} ' +
                'IN NAME FIELDS RETURNING Topic__c (Id, Name, Category__c ' +
                'WHERE Name != null ' +
                'AND Active__c = true ' +
                'AND Category__c IN :categories ' +
                'AND Object_Visibility__c INCLUDES (\''+objectApiName+'\')) ' +
                'WITH USER_MODE ' +
                'LIMIT 25';

            // // Perform SOSL search
            List<List<SObject>> searchResults = search.query(soslQuery);
            return searchResults[0];
        } catch (Exception e) {
            // Handle exception (e.g., log or rethrow)
            throw new TopicHelperException('TopicHelper: Failed to perform search: ' + e.getMessage());
        }
    }

    /**
     * Method to clean the search term and remove non-SOSL-friendly characters.
     * @param searchTerm The original search term.
     * @return Cleaned search term suitable for SOSL.
     */
    private static String cleanSearchTerm(String searchTerm) {
        // Remove non-SOSL-friendly characters from the search term
        return searchTerm.replaceAll('[?&|!{}\\[\\]()^~*:\\\\"\'+-]', '\\\\$0');
    }

    /**
     * Method to construct a Topic record from an SObject.
     * Assumes the existence of a constructor or method to create a Topic from an SObject.
     * @param sObj SObject representing a record.
     * @param sObjId Id of the SObject record.
     * @param sObjType Type of the SObject (e.g., 'Account', 'Contact').
     * @param sObjCategory Category information related to the SObject.
     * @return Topic record constructed from the SObject.
     */
    @TestVisible
    private static Topic constructTopic(SObject sObj, String sObjId, String sObjType, String sObjCategory) {
        // Assuming you have a method or constructor to create a Topic from an SObject
        return new Topic(
            sObj,
            generateRecordPageUrl(sObjId),
            TopicIconUtility.getSObjectIcon(sObjId, sObjType, sObjCategory));
    }

    /**
     * Method to generate Lightning Record Page URL for a given record Id.
     * @param recordId The Id of the record for which to generate the URL.
     * @return String representing the Lightning Record Page URL.
     */
    public static String generateRecordPageUrl(String recordId) {
        // Construct the PageReference for the Lightning Record Page
        PageReference recordPage = new PageReference('/lightning/r/' + recordId + '/view');
            
        // Generate the URL
        String recordPageUrl = recordPage.getUrl();
        
        return recordPageUrl;
    }

    public with sharing class Topic {

        public SObject sObj { get; set; }
        public String href { get; set; }
        public String iconName { get; set; }
    
        /**
         * Constructor to initialize Topic properties.
         * @param sObj The SObject associated with the topic.
         * @param href The hyperlink associated with the topic.
         * @param iconName The name of the icon associated with the topic.
         */
        public Topic(SObject sObj, String href, String iconName) {
            this.sObj = sObj;
            this.href = href;
            this.iconName = iconName;
        }
    }
    
    public class TopicHelperException extends Exception {}
}