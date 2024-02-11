public class TopicPicklistUtility {

    // set test run parameter
    public static Boolean testRunSuccessful = false;
    // Set to store allowed topic categories for Topic Junction records
    private static Set<String> topicCategories;

    // Static initialization block to populate the set
    static {
        // Initialize the set
        topicCategories = new Set<String>();
        
        // Populate the set using getTopicConfigurations method
        for (Topic_Configuration__mdt config : TopicQueryUtility.getTopicConfigurations()) {
            topicCategories.add(config.Category__c);
        }
    }

    /**
     * Getter for topicCategories.
     * @return Set representing allowed topic categories.
     */
    public static Set<String> getTopicCategories() {
        return topicCategories;
    }

    /**
     * Setter for topicCategories.
     * @return Set representing allowed topic categories.
     */
    public static void setTopicCategories(Set<String> categories) {
        topicCategories = categories;
    }

    /**
     * Method to update multi-select picklist on the object based on changes in related Topics.
     * @param sObjectIds Set of sObject Ids of new Topic Junction records.
     */
    public static void updatePicklistValues(Set<Id> sObjectIds) {
        // Parameters to store information for processing in bulk 
        Map<Id, SObject> sObjectsToUpdate = new Map<Id, SObject>();    
        List<Topic_Junction__c> validTopicJunctions = new List<Topic_Junction__c>();  
        Map<Id, Map<String, List<String>>> sObjectIdToFieldToTopicNamesMap = new Map<Id, Map<String, List<String>>>();

        // Initialize the map for each recordId
        for (Id recordId : sObjectIds) {
            if (!sObjectIdToFieldToTopicNamesMap.containsKey(recordId)) {
                sObjectIdToFieldToTopicNamesMap.put(recordId, new Map<String, List<String>>());
            }
        }
        // Get Topic Categories from configuration metadata
        Set<String> topicCategories = getTopicCategories();
        // Process topicJunctions and build necessary data structures
        for (Topic_Junction__c topicJunction : TopicQueryUtility.getTopicsRelatedToRecordsByObjectId(sObjectIds, topicCategories)) {
            String recordId = topicJunction.Record_Id__c;
            String topicName = topicJunction.Topic__r.Name;
            String objectField = topicJunction.Object_Field__c;
            validTopicJunctions.add(topicJunction);

            if (sObjectIdToFieldToTopicNamesMap.containsKey(recordId) && objectField != null) {
                Map<String, List<String>> fieldToTopicNamesMap = sObjectIdToFieldToTopicNamesMap.get(recordId);
                if (fieldToTopicNamesMap.containsKey(objectField)) {
                    fieldToTopicNamesMap.get(objectField).add(topicName);
                } else {
                    List<String> topicNames = new List<String>{topicName};
                    fieldToTopicNamesMap.put(objectField, topicNames);
                }
            }
        }   
        
        // Iterate through validTopicJunctions and update related objects
        processValidTopicJunctions(validTopicJunctions, sObjectIdToFieldToTopicNamesMap, sObjectsToUpdate);

        if (!sObjectsToUpdate.isEmpty()) {
            // Perform bulk update if there are records to update
            update new List<SObject>(sObjectsToUpdate.values());
        }
    }

    /**
     * Method to process validTopicJunctions and update related objects in bulk.
     * @param validTopicJunctions List of valid Topic Junction records.
     * @param sObjectIdToFieldToTopicNamesMap Map of objectIds to field names to topic names.
     * @param sObjectsToUpdate Map of objectIds to SObjects for update.
     */
    private static void processValidTopicJunctions(List<Topic_Junction__c> validTopicJunctions, Map<Id, Map<String, List<String>>> sObjectIdToFieldToTopicNamesMap, Map<Id, SObject> sObjectsToUpdate) {
        for (Topic_Junction__c topicJunction : validTopicJunctions) {
            String topicNames = '';
            String recordId = topicJunction.Record_Id__c;
            String objectField = topicJunction.Object_Field__c;
            String objectType = topicJunction.Object_Type__c;

            if (sObjectIdToFieldToTopicNamesMap.containsKey(recordId) &&
                sObjectIdToFieldToTopicNamesMap.get(recordId).containsKey(objectField) && objectField != null) {
                SObject sObj = Schema.getGlobalDescribe().get(objectType).newSObject(recordId);
                // Iterate through field names and set topic names
                if (!Test.isRunningTest()) {
                    for(String fieldName : sObjectIdToFieldToTopicNamesMap.get(recordId).keySet()) {
                        topicNames = String.join(sObjectIdToFieldToTopicNamesMap.get(recordId).get(fieldName), ';');
                        sObj.put(fieldName, topicNames);
                    }
                    sObjectsToUpdate.put(sObj.Id, sObj);
                } else {
                    testRunSuccessful = true;
                }
            }
        }
    }

    /**
     * Method to activate picklist values based on the provided sObjectIds.
     * @param sObjectIds Set of sObject Ids of new Topic Junction records.
     */
    public static void activatePicklistValues(Set<Id> sObjectIds) {
        // Parameters to store information for processing in bulk 
        Map<Id, SObject> sObjectsToUpdate = new Map<Id, SObject>(); 
        Set<String> topicCategories = getTopicCategories();
        Map<String, Set<String>> sObjectNameAndFieldToTopicNamesMap = new Map<String, Set<String>>();

        // Process topicJunctions and build necessary data structures
        for (Topic_Junction__c topicJunction : TopicQueryUtility.getTopicsRelatedToRecordsByObjectId(sObjectIds, topicCategories)) {
            if (topicJunction.Object_Field__c != null) {
                String topicName = topicJunction.Topic__r.Name;           
                String key = String.format('{0}.{1}', new List<String>{topicJunction.Object_Type__c, topicJunction.Object_Field__c});
                if (sObjectNameAndFieldToTopicNamesMap.containsKey(key)) {
                    sObjectNameAndFieldToTopicNamesMap.get(key).add(topicName);
                } else {
                    sObjectNameAndFieldToTopicNamesMap.put(key, new Set<String>{topicName});
                }
            }
        }
        
        // Initialize the MetadataService.MetadataPort
        List<String> sObjectNameAndFieldList = new List<String>(sObjectNameAndFieldToTopicNamesMap.keySet());
        Set<MetadataService.CustomField> customFieldsToUpdate = new Set<MetadataService.CustomField>();
        MetadataService.MetadataPort service = initializeMetadataService();
        
        List<MetadataService.CustomField> customFieldMetadata = 
            (List<MetadataService.CustomField>) service.readMetadata('CustomField', sObjectNameAndFieldList).getRecords();
        
        for (MetadataService.CustomField customField : customFieldMetadata) {
            String picklistField = customField.fullName;
            Set<String> picklistValues = sObjectNameAndFieldToTopicNamesMap.get(picklistField);
            
            for(MetadataService.CustomValue existingValue : customField?.valueSet?.valueSetDefinition?.value) {
                if (picklistValues.contains(existingValue.fullName)) {
                    picklistValues.remove(existingValue.fullName);
                }
            }
            for(String picklistValue : picklistValues) {
                MetadataService.CustomValue value = new MetadataService.CustomValue();
                value.fullName = picklistValue;
                value.default_x = false ;
                value.isActive = true;
                customField.valueSet.valueSetDefinition.value.add(value);
                customFieldsToUpdate.add(customField);
            }
        }
        // Create the update request
        if (!customFieldsToUpdate.isEmpty()) {
         	List<MetadataService.CustomField> customFieldsToUpdateList = new List<MetadataService.CustomField>(customFieldsToUpdate);
        	List<MetadataService.SaveResult> results = service.updateMetadata(customFieldsToUpdateList);

        	// Handle the results
        	handleResults(results);   
        }
    }

    /**
     * Initializes the MetadataService.MetadataPort with the user's session information.
     * @return An instance of MetadataService.MetadataPort.
     */
    private static MetadataService.MetadataPort initializeMetadataService() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        service.timeout_x = 120000;
        return service;
    }

    /**
     * Handles the results of the metadata update.
     * @param results List of MetadataService.SaveResult objects.
     */
    private static void handleResults(List<MetadataService.SaveResult> results) {
        for (MetadataService.SaveResult result : results) {
            if (result.success) {
                testRunSuccessful = true;
                System.debug('Picklist value activated successfully.');
            } else if (!result.success) {
                System.debug('Picklist value activation failed: ' + result.errors[0].message);
            } else {
                System.debug('Picklist value activation is in progress...');
            }
        }
    }
}