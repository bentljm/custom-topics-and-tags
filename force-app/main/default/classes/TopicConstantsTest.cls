@isTest
private class TopicConstantsTest {

    @isTest
    private static void testConstants() {
        // Test Trigger Type constants
        System.assertEquals('Create', TopicConstants.OPERATION_CREATE);
        System.assertEquals('Read', TopicConstants.OPERATION_READ);
        System.assertEquals('Edit', TopicConstants.OPERATION_UPDATE);
        System.assertEquals('Delete', TopicConstants.OPERATION_DELETE);

        // Test CRUD Permissions constants
        System.assertEquals('PermissionsCreate', TopicConstants.PERMISSION_CREATE);
        System.assertEquals('PermissionsRead', TopicConstants.PERMISSION_READ);
        System.assertEquals('PermissionsEdit', TopicConstants.PERMISSION_UPDATE);
        System.assertEquals('PermissionsDelete', TopicConstants.PERMISSION_DELETE);
        System.assertEquals(
            new List<String>{'PermissionsCreate', 'PermissionsRead', 'PermissionsEdit', 'PermissionsDelete'},
            TopicConstants.ALL_PERMISSIONS
        );

        // Test Topic Configuration Custom Metadata Type constant
        System.assertEquals('innovations_hub__Topic_Configuration__mdt', TopicConstants.TOPIC_CONFIG_METADATA_TYPE);

        // Test Topic Configuration Fields constants
        System.assertEquals('Label', TopicConstants.TOPIC_CONFIG_LABEL_FIELD);
        System.assertEquals('Category__c', TopicConstants.TOPIC_CONFIG_CATEGORY_FIELD);
        System.assertEquals('Object_Visibility_Custom__c', TopicConstants.TOPIC_CONFIG_OBJECT_VISIBILITY_FIELD);
        System.assertEquals('Object_Field__c', TopicConstants.TOPIC_CONFIG_OBJECT_FIELD_FIELD);
        System.assertEquals('Icon_Name__c', TopicConstants.TOPIC_CONFIG_ICON_NAME_FIELD);

        // Test Topic Object constant
        System.assertEquals('innovations_hub__Topic__c', TopicConstants.TOPIC_OBJECT);

        // Test Topic Fields constants
        System.assertEquals('Id', TopicConstants.TOPIC_ID_FIELD);
        System.assertEquals('Name', TopicConstants.TOPIC_NAME_FIELD);
        System.assertEquals('Category__c', TopicConstants.TOPIC_CATEGORY_FIELD);
        System.assertEquals('Object_Visibility__c', TopicConstants.TOPIC_OBJECT_VISIBILITY_FIELD);
        System.assertEquals('Start_Date__c', TopicConstants.TOPIC_START_DATE_FIELD);
        System.assertEquals('End_Date__c', TopicConstants.TOPIC_END_DATE_FIELD);
        System.assertEquals('Active__c', TopicConstants.TOPIC_ACTIVE_FIELD);

        // Test Topic Junction Object constant
        System.assertEquals('innovations_hub__Topic_Junction__c', TopicConstants.TOPIC_JUNCTION_OBJECT);

        // Test Topic Junction Fields constants
        System.assertEquals('Id', TopicConstants.TOPIC_JUNCTION_ID_FIELD);
        System.assertEquals('Name', TopicConstants.TOPIC_JUNCTION_NAME_FIELD);
        System.assertEquals('Topic__c', TopicConstants.TOPIC_JUNCTION_TOPIC_ID_FIELD);
        System.assertEquals('Record_Id__c', TopicConstants.TOPIC_JUNCTION_RECORD_ID_FIELD);
        System.assertEquals('Record_Name__c', TopicConstants.TOPIC_JUNCTION_RECORD_NAME_FIELD);
        System.assertEquals('Object_Type__c', TopicConstants.TOPIC_JUNCTION_OBJECT_TYPE_FIELD);
        System.assertEquals('Object_Field__c', TopicConstants.TOPIC_JUNCTION_OBJECT_FIELD_FIELD);
        System.assertEquals('Topic_Junction_Id__c', TopicConstants.TOPIC_JUNCTION_JUNCTION_ID_FIELD);
        System.assertEquals('Topic_Junction_Name__c', TopicConstants.TOPIC_JUNCTION_JUNCTION_NAME_FIELD);
    }
}