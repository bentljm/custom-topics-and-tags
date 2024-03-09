@isTest
private class TopicPicklistUtilityTest {

    @TestSetup
    private static void setup() {
        // Create test records for Topic__c
        List<Topic__c> topics = new List<Topic__c>();
        topics.add(new Topic__c(Name = 'TestTopic1', Category__c = 'Category1', Object_Visibility__c = 'Account'));
        topics.add(new Topic__c(Name = 'TestTopic2', Category__c = 'Category1', Object_Visibility__c = 'Account'));
        insert topics;
    
        // Create test records for Accounts
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'TestAccount1'));
        insert accounts;
    
        // Create test records for Topic_Junction__c and associate them with accounts
        List<Topic_Junction__c> topicJunctions = new List<Topic_Junction__c>();
        topicJunctions.add(new Topic_Junction__c(
            Topic__c = topics[0].Id,
            Record_Id__c = accounts[0].Id,
            Object_Field__c = 'Field1',
            Topic_Junction_Id__c = 'TestAccount1Id-Account-TestTopic1Id',
            Topic_Junction_Name__c = 'TestAccount1-TestTopic1'));
        topicJunctions.add(new Topic_Junction__c(
            Topic__c = topics[1].Id,
            Record_Id__c = accounts[0].Id,
            Object_Field__c = 'Field1',
            Topic_Junction_Id__c = 'TestAccount1Id-Account-TestTopic2Id',
            Topic_Junction_Name__c = 'TestAccount1-TestTopic2'));
        insert topicJunctions;
    }
    
    @isTest
    private static void testUpdatePicklistValues() {
        // Set topic categories
        TopicPicklistUtility.setTopicCategories(new Set<String>{'Category1'});
        // Retrieve test records
        Set<Topic_Junction__c> records = new Set<Topic_Junction__c>();
        List<Topic_Junction__c> topicJunctions = [SELECT Id, Record_Id__c, Object_Field__c FROM Topic_Junction__c];
        for (Topic_Junction__c topicJunction : topicJunctions) {
            records.add(topicJunction);
        }

        // Call the method under test
        Test.startTest();
        TopicPicklistUtility.updatePicklistValues(records);
        Test.stopTest();

        System.assertEquals(true, TopicPicklistUtility.testRunSuccessful, 'Test Run was successful');
    }

    @isTest
    private static void testActivatePicklistValues() {
        // Set Mock
        System.Test.setMock(WebServiceMock.class, new MockMetadataServiceCallout());
        // Set topic categories
        TopicPicklistUtility.setTopicCategories(new Set<String>{'Category1'});
        // Retrieve test records
        Set<Id> recordIds = new Set<Id>();
        List<Topic_Junction__c> topicJunctions = [SELECT Id, Record_Id__c FROM Topic_Junction__c];
        for (Topic_Junction__c topicJunction : topicJunctions) {
            recordIds.add(topicJunction.Record_Id__c);
        }

        // Call the method under test
        Test.startTest();
        TopicPicklistUtility.activatePicklistValues(recordIds);
        Test.stopTest();

        // Verify the results
        System.assertEquals(true, TopicPicklistUtility.testRunSuccessful, 'Test Run was successful');
    }

    public class MockMetadataServiceCallout implements WebServiceMock {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNamespace, String responseName, String responseType
        ) {
            // Set the fake response based on the callout type
            if (request instanceof MetadataService.readMetadata_element) {
                response.put('response_x', getReadResonse());
            } else if (request instanceof MetadataService.updateMetadata_element) {
                response.put('response_x', getUpdateResponse());
            }
        }
    }

    private static MetadataService.readCustomFieldResponse_element getReadResonse() {
        MetadataService.CustomField customField = new MetadataService.CustomField();
        customField.fullName = 'Account.Field1';
        customField.label = 'picklist';
        customField.type_x = 'Picklist';

        MetadataService.CustomValue customValue = new MetadataService.CustomValue();
        customValue.label = 'TestTopic1';
        customValue.fullName = 'TestTopic1';
        customValue.isActive = true;
        customValue.default_x = false;

        List<MetadataService.CustomValue> customValues = new List<MetadataService.CustomValue>();
        customValues.add(customValue);

        MetadataService.ValueSetValuesDefinition valueSetValuesDefinition = new MetadataService.ValueSetValuesDefinition();
        valueSetValuesDefinition.value = customValues;

        MetadataService.ValueSet valueSet = new MetadataService.ValueSet();
        valueSet.valueSetDefinition = valueSetValuesDefinition;
        customField.valueSet = valueSet;

        List<MetadataService.CustomField> customFields = new List<MetadataService.CustomField>();
        customFields.add(customField);

        MetadataService.ReadCustomFieldResult readResult = new MetadataService.ReadCustomFieldResult();
        readResult.records = customFields;

        MetadataService.readCustomFieldResponse_element readResponse = new MetadataService.readCustomFieldResponse_element();
        readResponse.result = readResult;

        return readResponse;
    }

    private static MetadataService.updateMetadataResponse_element getUpdateResponse() {
       List<MetadataService.Error> errors = new List<MetadataService.Error>();
    
       MetadataService.SaveResult saveResult = new MetadataService.SaveResult();
       saveResult.fullName = 'Account.Field1';
       saveResult.errors = errors;
       saveResult.success = true;

       MetadataService.updateMetadataResponse_element updateResponse = new MetadataService.updateMetadataResponse_element();
       updateResponse.result = new List<MetadataService.SaveResult>{saveResult};

       return updateResponse;
    }

}