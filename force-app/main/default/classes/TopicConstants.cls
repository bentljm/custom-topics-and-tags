public class TopicConstants {

    // Trigger Type
    public static final String OPERATION_CREATE = 'Create';
    public static final String OPERATION_READ = 'Read';
    public static final String OPERATION_UPDATE = 'Edit';
    public static final String OPERATION_DELETE = 'Delete';

    // CRUD Permissions
    public static final String PERMISSION_CREATE = 'PermissionsCreate';
    public static final String PERMISSION_READ = 'PermissionsRead';
    public static final String PERMISSION_UPDATE = 'PermissionsEdit';
    public static final String PERMISSION_DELETE = 'PermissionsDelete';
    public static final List<String> ALL_PERMISSIONS = new List<String>{
        PERMISSION_CREATE,
        PERMISSION_READ,
        PERMISSION_UPDATE,
        PERMISSION_DELETE
    };

    // Topic Configuration Custom Metadata Type
    public static final String TOPIC_CONFIG_METADATA_TYPE = 'innovations_hub__Topic_Configuration__mdt';

    // Topic Configuration Fields
    public static final String TOPIC_CONFIG_LABEL_FIELD = 'Label';
    public static final String TOPIC_CONFIG_CATEGORY_FIELD = 'Category__c';
    public static final String TOPIC_CONFIG_OBJECT_VISIBILITY_FIELD = 'Object_Access__c';
    public static final String TOPIC_CONFIG_OBJECT_FIELD_FIELD = 'Object_Field__c';
    public static final String TOPIC_CONFIG_ICON_NAME_FIELD = 'Icon_Name__c';

    // Topic Object
    public static final String TOPIC_OBJECT = 'innovations_hub__Topic__c';

    // Topic Fields
    public static final String TOPIC_ID_FIELD = 'Id';
    public static final String TOPIC_NAME_FIELD = 'Name';
    public static final String TOPIC_CATEGORY_FIELD = 'Category__c';
    public static final String TOPIC_OBJECT_VISIBILITY_FIELD = 'Object_Visibility__c';
    public static final String TOPIC_START_DATE_FIELD = 'Start_Date__c';
    public static final String TOPIC_END_DATE_FIELD = 'End_Date__c';
    public static final String TOPIC_ACTIVE_FIELD = 'Active__c';

    // Topic Junction Object
    public static final String TOPIC_JUNCTION_OBJECT = 'innovations_hub__Topic_Junction__c';

    // Topic Junction Fields
    public static final String TOPIC_JUNCTION_ID_FIELD = 'Id';
    public static final String TOPIC_JUNCTION_NAME_FIELD = 'Name';
    public static final String TOPIC_JUNCTION_TOPIC_ID_FIELD = 'Topic__c';
    public static final String TOPIC_JUNCTION_RECORD_ID_FIELD = 'Record_Id__c';
    public static final String TOPIC_JUNCTION_RECORD_NAME_FIELD = 'Record_Name__c';
    public static final String TOPIC_JUNCTION_OBJECT_TYPE_FIELD = 'Object_Type__c';
    public static final String TOPIC_JUNCTION_OBJECT_FIELD_FIELD = 'Object_Field__c';
    public static final String TOPIC_JUNCTION_JUNCTION_ID_FIELD = 'Topic_Junction_Id__c';
    public static final String TOPIC_JUNCTION_JUNCTION_NAME_FIELD = 'Topic_Junction_Name__c';

}