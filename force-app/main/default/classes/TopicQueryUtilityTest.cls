@isTest
private class TopicQueryUtilityTest {

    @TestSetup
    private static void setup() {
        // Create test records for Topic__c
        List<Topic__c> topics = new List<Topic__c>();
        topics.add(new Topic__c(Name = 'TestTopic1', Category__c = 'Category1', Object_Visibility__c = 'Account'));
        topics.add(new Topic__c(Name = 'TestTopic1', Category__c = 'Category2', Object_Visibility__c = 'Account'));
        topics.add(new Topic__c(Name = 'TestTopic2', Category__c = 'Category3', Object_Visibility__c = 'Account'));
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
        topicJunctions.add(new Topic_Junction__c(
            Topic__c = topics[2].Id,
            Record_Id__c = accounts[0].Id,
            Object_Field__c = 'Field1',
            Topic_Junction_Id__c = 'TestAccount1Id-Account-TestTopic3Id',
            Topic_Junction_Name__c = 'TestAccount1-TestTopic3'));
        insert topicJunctions;
    }

    @isTest
    static void testGetTopicConfigurations() {
        // Test the getTopicConfigurations method
        Test.startTest();
        List<Topic_Configuration__mdt> topicConfigurations = TopicQueryUtility.getTopicConfigurations();
        Test.stopTest();

        // Add your assertions here
        System.assertNotEquals(null, topicConfigurations, 'Topic configurations should not be null.');
    }

    @isTest
    static void testGetTopicConfigurationsByCategory() {
        // Test the getTopicConfigurationsByCategory method
        Test.startTest();
        List<Topic_Configuration__mdt> topicConfigurations = TopicQueryUtility.getTopicConfigurationsByCategory('Account', 'Category1,Category2');
        Test.stopTest();

        // Add your assertions here
        System.assertEquals(new List<Topic_Configuration__mdt>(), topicConfigurations, 'Topic configurations should not null.');
    }

    @isTest
    static void testGetTopicsByIds() {
        Set<Id> topicIds = new Map<Id, Topic__c>([SELECT Id FROM Topic__c WHERE Name LIKE 'TestTopic%']).keySet();
        // Test the getTopicsByIds method
        Test.startTest();
        List<Topic__c> topics = TopicQueryUtility.getTopicsByIds(new List<Id>(topicIds));
        Test.stopTest();

        // Add your assertions here
        System.assertNotEquals(null, topics, 'Topics should not be null.');
        System.assertEquals(3, topics.size(), '3 Topics should be found.');
    }

    @isTest
    static void testGetTopicsByName() {
        Set<Id> topicIds = new Map<Id, Topic__c>([SELECT Id FROM Topic__c WHERE Name = 'TestTopic1' AND Category__c = 'Category1']).keySet();
        // Test the getTopicsByName method
        Test.startTest();
        List<Topic__c> topics = TopicQueryUtility.getTopicsByName(topicIds, new Set<String>{'TestTopic1', 'TestTopic2'});
        Test.stopTest();

        // Add your assertions here
        System.assertNotEquals(null, topics, 'Topics should not be null.');
        System.assertEquals(2, topics.size(), '2 Topics should be found.');
    }

    @isTest
    static void testGetTopicsRelatedToRecord() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'TestAccount1' LIMIT 1];
        // Test the getTopicsRelatedToRecord method
        Test.startTest();
        List<Topic_Junction__c> topicsRelatedToRecord = TopicQueryUtility.getTopicsRelatedToRecord(testAccount.Id, 'Account', 'Category1,Category2');
        Test.stopTest();

        // Add your assertions here
        System.assertNotEquals(null, topicsRelatedToRecord, 'Topics related to record should not be null.');
    }

    @isTest
    static void testGetTopicsRelatedToRecordsByObjectId() {
        Set<Id> accountIds = new Map<Id, Account>([SELECT Id FROM Account WHERE Name LIKE 'TestAccount%']).keySet();
        // Test the getTopicsRelatedToRecordsByObjectId method
        Test.startTest();
        List<Topic_Junction__c> topicsRelatedToRecord = TopicQueryUtility.getTopicsRelatedToRecordsByObjectId(accountIds, new Set<String>{'Category1', 'Category2'});
        Test.stopTest();

        // Add your assertions here
        System.assertNotEquals(null, topicsRelatedToRecord, 'Topics related to records by object Id should not be null.');
    }

    @isTest
    static void testGetAggregatedTopics() {
        // Test the getAggregatedTopics method
        Test.startTest();
        List<AggregateResult> aggregateResults = TopicQueryUtility.getAggregatedTopics('Category1,Category2');
        Test.stopTest();

        // Add your assertions here
        System.assertNotEquals(null, aggregateResults, 'Aggregate results should not be null.');
    }
}