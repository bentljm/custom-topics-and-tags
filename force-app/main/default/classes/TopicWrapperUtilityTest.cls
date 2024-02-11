@isTest
private class TopicWrapperUtilityTest {

    @isTest
    private static void testRetrieveValid() {
        // Test valid parameters for record retrieval
        TopicWrapperUtility wrapper = new TopicWrapperUtility();
        wrapper.recordId = '001XXXXXXXXXXXXAAA';
        wrapper.objectApiName = 'Account';
        wrapper.objectField = 'TestField';
        wrapper.topicCategories = 'Category1,Category2';

        System.assertEquals(true, wrapper.isRetrieveValid(), 'Record retrieval parameters should be valid.');
    }

    @isTest
    private static void testInvalidRetrieveWithoutRecordId() {
        // Test invalid parameters for record retrieval without recordId
        TopicWrapperUtility wrapper = new TopicWrapperUtility();
        wrapper.objectApiName = 'Account';
        wrapper.objectField = 'TestField';
        wrapper.topicCategories = 'Category1,Category2';

        System.assertEquals(false, wrapper.isRetrieveValid(), 'Record retrieval parameters should be invalid without recordId.');
    }

    @isTest
    private static void testInvalidRetrieveWithoutObjectApiName() {
        // Test invalid parameters for record retrieval without objectApiName
        TopicWrapperUtility wrapper = new TopicWrapperUtility();
        wrapper.recordId = '001XXXXXXXXXXXXAAA';
        wrapper.topicCategories = 'Category1,Category2';

        System.assertEquals(false, wrapper.isRetrieveValid(), 'Record retrieval parameters should be invalid without objectApiName.');
    }

    @isTest
    private static void testInvalidRetrieveWithoutTopicCategories() {
        // Test invalid parameters for record retrieval without topicCategories
        TopicWrapperUtility wrapper = new TopicWrapperUtility();
        wrapper.recordId = '001XXXXXXXXXXXXAAA';
        wrapper.objectApiName = 'Account';
        wrapper.objectField = 'TestField';

        System.assertEquals(false, wrapper.isRetrieveValid(), 'Record retrieval parameters should be invalid without topicCategories.');
    }

    @isTest
    private static void testSearchValid() {
        // Test valid parameters for record search
        TopicWrapperUtility wrapper = new TopicWrapperUtility();
        wrapper.recordId = '001XXXXXXXXXXXXAAA';
        wrapper.objectApiName = 'Account';
        wrapper.objectField = 'TestField';
        wrapper.topicCategories = 'Category1,Category2';
        wrapper.searchTerm = 'Test';

        System.assertEquals(true, wrapper.isSearchValid(), 'Record search parameters should be valid.');
    }

    @isTest
    private static void testInvalidSearchWithoutRecordId() {
        // Test invalid parameters for record search without recordId
        TopicWrapperUtility wrapper = new TopicWrapperUtility();
        wrapper.objectApiName = 'Account';
        wrapper.objectField = 'TestField';
        wrapper.topicCategories = 'Category1,Category2';
        wrapper.searchTerm = 'Test';

        System.assertEquals(false, wrapper.isSearchValid(), 'Record search parameters should be invalid without recordId.');
    }

    @isTest
    private static void testInvalidSearchWithoutObjectApiName() {
        // Test invalid parameters for record search without objectApiName
        TopicWrapperUtility wrapper = new TopicWrapperUtility();
        wrapper.recordId = '001XXXXXXXXXXXXAAA';
        wrapper.topicCategories = 'Category1,Category2';
        wrapper.searchTerm = 'Test';

        System.assertEquals(false, wrapper.isSearchValid(), 'Record search parameters should be invalid without objectApiName.');
    }

    @isTest
    private static void testInvalidSearchWithoutTopicCategories() {
        // Test invalid parameters for record search without topicCategories
        TopicWrapperUtility wrapper = new TopicWrapperUtility();
        wrapper.recordId = '001XXXXXXXXXXXXAAA';
        wrapper.objectApiName = 'Account';
        wrapper.objectField = 'TestField';
        wrapper.searchTerm = 'Test';

        System.assertEquals(false, wrapper.isSearchValid(), 'Record search parameters should be invalid without topicCategories.');
    }

    @isTest
    private static void testInvalidSearchWithoutSearchTerm() {
        // Test invalid parameters for record search without searchTerm
        TopicWrapperUtility wrapper = new TopicWrapperUtility();
        wrapper.recordId = '001XXXXXXXXXXXXAAA';
        wrapper.objectApiName = 'Account';
        wrapper.objectField = 'TestField';
        wrapper.topicCategories = 'Category1,Category2';

        System.assertEquals(false, wrapper.isSearchValid(), 'Record search parameters should be invalid without searchTerm.');
    }

    @isTest
    private static void testInvalidSearchWithShortSearchTerm() {
        // Test invalid parameters for record search with a short searchTerm
        TopicWrapperUtility wrapper = new TopicWrapperUtility();
        wrapper.recordId = '001XXXXXXXXXXXXAAA';
        wrapper.objectApiName = 'Account';
        wrapper.objectField = 'TestField';
        wrapper.topicCategories = 'Category1,Category2';
        wrapper.searchTerm = 'T';

        System.assertEquals(false, wrapper.isSearchValid(), 'Record search parameters should be invalid with a short searchTerm.');
    }
}