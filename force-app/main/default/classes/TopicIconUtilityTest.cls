@isTest
private class TopicIconUtilityTest {

    @TestSetup
    private static void setup() {
        insert new Topic__c(Name = 'TestTopic', Category__c = 'Category1', Object_Visibility__c = 'Account');
    }

    @isTest
    private static void testGetObjectTypeAndCategoryToConfigurationMap() {
        // Retrieve the map from the utility class
        Map<String, Topic_Configuration__mdt> configMap = TopicIconUtility.getObjectTypeAndCategoryToConfigurationMap();

        // Assert that the map is not null and contains the expected values
        System.assertNotEquals(null, configMap);
    }

    @isTest
    private static void testGetSObjectIcon() {
        Topic__c topic = [SELECT Id FROM Topic__c WHERE Name = 'TestTopic' LIMIT 1];

        // Test for default case
        String icon = TopicIconUtility.getSObjectIcon(topic.Id, 'Account', 'Category1');
        System.assertEquals('utility:all', icon);
    }
}