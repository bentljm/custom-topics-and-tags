@isTest
private class TopicHelperTest {

    @TestSetup
    private static void setup() {
        // Create test records for Topic__c
        List<Topic__c> topics = new List<Topic__c>();
        topics.add(new Topic__c(Name = 'TestTopic1', Category__c = 'Category1', Object_Visibility__c = 'Account'));
        topics.add(new Topic__c(Name = 'TestTopic2', Category__c = 'Category2', Object_Visibility__c = 'Account'));
        topics.add(new Topic__c(Name = 'TestTopic3', Category__c = 'Category3', Object_Visibility__c = 'Account'));
        topics.add(new Topic__c(Name = 'TestTopic4', Category__c = 'Category4', Object_Visibility__c = 'Account'));
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

    private static void createPermissions() {
        // Create test user
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Alias = 'tuser',
            Username = 'testuser@example.com.topic',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert testUser;

        // Create test records for PermissionSet
        List<PermissionSet> permissionSets = new List<PermissionSet>();
        permissionSets.add(new PermissionSet(Name = 'TestPermissionSet', Label = 'TestPermissionSet'));
        insert permissionSets;

        // Create test records for ObjectPermissions
        List<ObjectPermissions> objectPermissions = new List<ObjectPermissions>();
        objectPermissions.add(new ObjectPermissions(
            SObjectType = 'innovations_hub__Topic__c',
            ParentId = permissionSets[0].Id,
            PermissionsCreate = false,
            PermissionsRead = true,
            PermissionsEdit = true,
            PermissionsDelete = true
        ));
        insert objectPermissions;

        // Create test records for PermissionSetAssignment
        List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
        permissionSetAssignments.add(new PermissionSetAssignment(
            AssigneeId = testUser.Id,
            PermissionSetId = permissionSets[0].Id
        ));
        insert permissionSetAssignments;
    }

    @isTest
    private static void testGetCrudPermissions() {
        createPermissions();
        // Run as the test user
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@example.com.topic' LIMIT 1];
        System.runAs(testUser) {
            // Retrieve crudPermissionsMap for Test User
            Map<String, Boolean> crudPermissionsMap = TopicHelper.getCrudPermissions();
            // Assert that CRUD permissions are retrieved from the profile
            System.assertEquals(false, crudPermissionsMap.get(TopicConstants.PERMISSION_CREATE));
            System.assertEquals(true, crudPermissionsMap.get(TopicConstants.PERMISSION_READ));
            System.assertEquals(true, crudPermissionsMap.get(TopicConstants.PERMISSION_UPDATE));
            System.assertEquals(true, crudPermissionsMap.get(TopicConstants.PERMISSION_DELETE));
        }
    }

    @isTest
    private static void testCheckIfUserHasPermissionToCreate() {
        createPermissions();
        // Run as the test user
        List<Topic__c> topics = [SELECT Id FROM Topic__c WHERE Name LIKE 'TestTopic%'];
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@example.com.topic' LIMIT 1];
        System.runAs(testUser) {
            // Ensure that the method adds errors for users without the required permission
            Test.startTest();
            TopicHelper topicHelper = new TopicHelper();
            topicHelper.checkIfUserHasPermission(topics, TopicConstants.PERMISSION_CREATE);
            Test.stopTest();
            // Assert that records have errors
            for (SObject sObj : topics) {
                System.assert(sObj.hasErrors(), 'User does not have permission to create Topics');
            }
        }
    }

    @isTest
    private static void testCheckIfUserHasPermissionToDelete() {
        // Test the checkIfUserHasPermissions method
        List<Topic__c> topics = [SELECT Id FROM Topic__c WHERE Name = 'TestTopic4'];
        // Ensure that the method adds errors for users without the required permission
        Test.startTest();
        delete topics;
        Test.stopTest();
        // Assert that records have errors
        for (SObject sObj : topics) {
            System.assert(!sObj.hasErrors(), 'User has permission to delete Topics');
        }
    }

    @isTest
    private static void testCheckIfTopicIsDuplicate() {
        // Test the checkIfTopicIsDuplicate method
        List<Topic__c> newTopics = new List<Topic__c>();
        newTopics.add(new Topic__c(Name = 'TestTopic1', Category__c = 'Category1', Object_Visibility__c = 'Account'));

        // Ensure that the method adds errors for duplicate topics or date overlap
        Test.startTest();
        TopicHelper topicHelper = new TopicHelper();
        topicHelper.checkIfTopicIsDuplicate(newTopics);
        Test.stopTest();

        for (Topic__c newTopic : newTopics) {
            System.assert(newTopic.hasErrors(), 'Error not added for duplicate topic or date overlap');
        }
    }

    @isTest
    static void testGetTopicConfigurations() {
        // Test the getTopicConfigurations method
        Test.startTest();
        List<Topic_Configuration__mdt> topicConfigurations = TopicHelper.getTopicConfigurations('Account', 'Category1,Category2,Category3');
        Test.stopTest();

        // Add your assertions here
        System.assertNotEquals(null, topicConfigurations, 'Topic configurations should not be null.');
    }

    @isTest
    static void testGetRecordData() {
        // Test the getTopicConfigurations method
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'TestAccount1' LIMIT 1];
        Test.startTest();
        Map<String, SObject> recordData = TopicHelper.getRecordData(testAccount.Id, 'Account');
        Test.stopTest();

        // Add your assertions here
        System.assertNotEquals(null, recordData, 'Map should not be null.');
        System.assertEquals(true, recordData.keySet()?.contains('Name'), 'Map should contain Name as key.');
        System.assertEquals('TestAccount1', recordData.get('Name')?.get('Name'), 'Name should be TestAccount1.');
    }

    @isTest
    static void tetGetTopicsRecentlyUsed () {
        // Test the getAggregatedTopics method
        Test.startTest();
        String topicsRecentlyUsedStr = TopicHelper.getTopicsRecentlyUsed('Account', 'Category1,Category2,Category3');
        Test.stopTest();

        // Add your assertions here
        List<TopicHelper.Topic> topicsRecentlyUsed = (List<TopicHelper.Topic>)JSON.deserialize(topicsRecentlyUsedStr, List<TopicHelper.Topic>.class);
        System.assertNotEquals(null, topicsRecentlyUsed, 'Topics Recently Used should not be null.');
    }

    @isTest
    private static void testGetTopicsRelatedToRecord() {
        // Insert necessary test data, including wrapper with valid search term and criteria
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'TestAccount1' LIMIT 1];
        TopicWrapperUtility wrapper = new TopicWrapperUtility();
        wrapper.recordId = testAccount.Id;
        wrapper.objectApiName = 'Account';
        wrapper.topicCategories = 'Category1,Category2';

        // Test the getTopicsRelatedToRecord method
        Test.startTest();
        String topicsRelatedToRecordStr = TopicHelper.getTopicsRelatedToRecord(wrapper);
        Test.stopTest();

        // Parse the JSON result
        List<TopicHelper.Topic> topicsRelatedToRecord = (List<TopicHelper.Topic>)JSON.deserialize(topicsRelatedToRecordStr, List<TopicHelper.Topic>.class);
        System.assertNotEquals(null, topicsRelatedToRecord, 'Topics related to record should not be null.');
    }

    @isTest
    private static void testPerformSearch() {
        // Insert necessary test data, including wrapper with valid search term and criteria
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'TestAccount1' LIMIT 1];
        TopicWrapperUtility wrapper = new TopicWrapperUtility();
        wrapper.recordId = testAccount.Id;
        wrapper.objectApiName = 'Account';
        wrapper.topicCategories = 'Category1,Category2,Category3';
        wrapper.searchTerm = 'TestTopic1';

        // Ensure that the method returns expected search results
        Test.startTest();
        String searchResultsStr = TopicHelper.getTopicsOnSearch(wrapper);
        Test.stopTest();

        // Parse the JSON result
        List<TopicHelper.Topic> searchResults = (List<TopicHelper.Topic>)JSON.deserialize(searchResultsStr, List<TopicHelper.Topic>.class);
        System.assertNotEquals(null, searchResults, 'Topics returned from search should not be null.');
    }

    @isTest
    static void testConstructTopic() {
        // Create a test SObject
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'TestAccount1' LIMIT 1];

        // Call the constructTopic method
        TopicHelper.Topic testTopic = TopicHelper.constructTopic(
            testAccount, 
            testAccount.Id, 
            'Account', 
            'Category1'
        );

        // Assert that the constructed Topic object is not null
        System.assertNotEquals(null, testTopic, 'Topic object should not be null');
        System.assertEquals(testAccount, testTopic.sObj, 'SObject property should be set correctly');
        // Assert that href is correct
        String expectedHref = TopicHelper.generateRecordPageUrl(testAccount.Id);
        System.assertEquals(expectedHref, testTopic.href, 'Href property should be set correctly');
    }
}