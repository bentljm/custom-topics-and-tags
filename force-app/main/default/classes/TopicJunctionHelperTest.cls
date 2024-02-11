@isTest
private class TopicJunctionHelperTest {

    @TestSetup
    private static void setup() {
        // Create test records for Topic__c
        List<Topic__c> topics = new List<Topic__c>();
        topics.add(new Topic__c(Name = 'TestTopic1', Category__c = 'Category1', Object_Visibility__c = 'Account'));
        insert topics;
    
        // Create test records for Accounts
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'TestAccount1'));
        accounts.add(new Account(Name = 'TestAccount2'));
        insert accounts;
    
        // Create test records for Topic_Junction__c and associate them with accounts
        List<Topic_Junction__c> topicJunctions = new List<Topic_Junction__c>();
        topicJunctions.add(new Topic_Junction__c(
            Topic__c = topics[0].Id,
            Record_Id__c = accounts[0].Id,
            Object_Field__c = 'Field1',
            Topic_Junction_Id__c = 'TestAccount1Id-Account-TestTopic1Id',
            Topic_Junction_Name__c = 'TestAccount1-TestTopic1'));
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
        objectPermissions.add(new ObjectPermissions(
            SObjectType = 'innovations_hub__Topic_Junction__c',
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
    private static void testCheckIfUserHasPermissionToCreate() {
        createPermissions();
        // Run as the test user
        List<Topic_Junction__c> topicJunctions = [SELECT Id, Record_Id__c, Object_Field__c FROM Topic_Junction__c];
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@example.com.topic' LIMIT 1];
        System.runAs(testUser) {
            // Ensure that the method adds errors for users without the required permission
            Test.startTest();
            TopicJunctionHelper topicJunctionHelper = new TopicJunctionHelper();
            topicJunctionHelper.checkIfUserHasPermission(topicJunctions, TopicConstants.PERMISSION_CREATE);
            Test.stopTest();
            // Assert that records have errors
            for (SObject sObj : topicJunctions) {
                System.assert(sObj.hasErrors(), 'User does not have permission to create Topic Junctions');
            }
        }
    }

    @isTest
    private static void testCheckIfUserHasPermissionToDelete() {
        createPermissions();
        // Run as the test user
        List<Topic_Junction__c> topicJunctions = [SELECT Id, Record_Id__c, Object_Field__c FROM Topic_Junction__c LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@example.com.topic' LIMIT 1];
        System.runAs(testUser) {
            // Ensure that the method adds errors for users without the required permission
            Test.startTest();
            delete topicJunctions;
            Test.stopTest();
            // Assert that records have errors
            for (SObject sObj : topicJunctions) {
                System.assert(!sObj.hasErrors(), 'User has permission to delete Topic Junctions');
            }
        }
    }

    @isTest
    static void testUpdateTopicJunctions() {
        // Test the updateTopicJunctions method
        Account testAccount2 = [SELECT Id FROM Account WHERE Name = 'TestAccount2' LIMIT 1];
        List<Topic_Junction__c> newTopicJunctions = [SELECT Id, Topic__c, Record_Id__c, Record_Name__c, Topic_Junction_Id__c, Topic_Junction_Name__c
                                                     FROM Topic_Junction__c
                                                     WHERE Topic_Junction_Name__c = 'TestAccount1-TestTopic1' LIMIT 1];
        newTopicJunctions[0].Record_Id__c = testAccount2.Id;
        newTopicJunctions[0].Record_Name__c = 'TestAccount2';
        
        // Ensure that the method updates Topic Junction records as expected
        Test.startTest();
        TopicJunctionHelper topicJunctionHelper = new TopicJunctionHelper();
        topicJunctionHelper.updateTopicJunctions(newTopicJunctions, new Map<Id, SObject>());
        update newTopicJunctions;
        Test.stopTest();

        // Add assertions based on your specific requirements
        newTopicJunctions = [SELECT Id, Topic__c, Record_Id__c, Topic_Junction_Name__c
                             FROM Topic_Junction__c
                             WHERE Id = :newTopicJunctions[0].Id LIMIT 1];
        System.assertEquals('TestAccount2-TestTopic1', newTopicJunctions[0].Topic_Junction_Name__c, 'Topic Junction Name should be updated');                             
    }

    @isTest
    static void testUpdatePicklistValues() {
        // Test the updatePicklistValues method
        List<Topic_Junction__c> topicJunctions = [SELECT Id, Record_Id__c, Object_Field__c FROM Topic_Junction__c];

        // Ensure that the method correctly calls the future method
        Test.startTest();
        TopicJunctionHelper topicJunctionHelper = new TopicJunctionHelper();
        topicJunctionHelper.updatePicklistValues(topicJunctions);
        Test.stopTest();

        // Verify the results
        System.assertEquals(true, topicJunctionHelper.testRunSuccessful, 'Test Run was successful');
    }

    @isTest
    static void testActivatePicklistValues() {
        // Test the activatePicklistValues method
        List<Topic_Junction__c> topicJunctions = [SELECT Id, Record_Id__c, Object_Field__c FROM Topic_Junction__c];

        // Ensure that the method correctly calls the future method
        Test.startTest();
        TopicJunctionHelper topicJunctionHelper = new TopicJunctionHelper();
        topicJunctionHelper.activatePicklistValues(topicJunctions);
        Test.stopTest();

        // Verify the results
        System.assertEquals(true, topicJunctionHelper.testRunSuccessful, 'Test Run was successful');
    }

    @isTest
    static void testGetValidSObjectIds() {
        // Test the getValidSObjectIds method
        List<Topic_Junction__c> topicJunctions = [SELECT Id, Record_Id__c, Object_Field__c FROM Topic_Junction__c];

        // Ensure that the method returns valid sObjectIds
        Set<Id> validSObjectIds = new TopicJunctionHelper().getValidSObjectIds(topicJunctions);
        System.assertEquals(1, validSObjectIds.size(), 'Should return 1 valid sObjectIds');
    }

}