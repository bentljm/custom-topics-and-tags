@isTest
private class TopicPermissionsUtilityTest {

    @TestSetup
    private static void setup() {
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
            PermissionsDelete = false
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
        // Run as the test user
        User testUser = [SELECT Id FROM User WHERE Username = 'testuser@example.com.topic' LIMIT 1];
        System.runAs(testUser) {
            // Retrieve crudPermissionsMap for Test User
            Map<String, Boolean> crudPermissionsMap = TopicPermissionsUtility.getCrudPermissions('innovations_hub__Topic__c');
            // Assert that CRUD permissions are retrieved from the profile
            System.assertEquals(false, crudPermissionsMap.get(TopicConstants.PERMISSION_CREATE));
            System.assertEquals(true, crudPermissionsMap.get(TopicConstants.PERMISSION_READ));
            System.assertEquals(true, crudPermissionsMap.get(TopicConstants.PERMISSION_UPDATE));
            System.assertEquals(false, crudPermissionsMap.get(TopicConstants.PERMISSION_DELETE));
        }
    }

    @isTest
    private static void testGetCrudPermissionsException() {
        Test.startTest();
        try {
            // Simulate an exception when querying ObjectPermissions
            Test.setMock(HttpCalloutMock.class, new ObjectPermissionsMock());
            TopicPermissionsUtility.getCrudPermissions('Account');
        } catch (TopicPermissionsUtility.TopicPermissionsUtilityException e) {
            // Verify that the exception is caught
            System.assertEquals('TopicPermissionsUtility: Failed to get ObjectPermissions from profile: Mock response', e.getMessage());
        }
        Test.stopTest();
    }

    // Mock class for ObjectPermissions query
    private class ObjectPermissionsMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Return a mock response to simulate an exception
            HttpResponse res = new HttpResponse();
            res.setBody('Mock response');
            res.setStatusCode(500);
            return res;
        }
    }
}