@isTest
private class TriggerControlTest {

    @isTest
    private static void testSkipTrigger() {
        // Ensure skipTrigger is initially set to false
        System.assertEquals(false, TriggerControl.skipTrigger, 'skipTrigger should be false initially.');

        // Set skipTrigger to true in a test context
        Test.startTest();
        TriggerControl.skipTrigger = true;
        Test.stopTest();

        // Verify that skipTrigger is now true within the test context
        System.assertEquals(true, TriggerControl.skipTrigger, 'skipTrigger should be true within the test context.');
    }

    @isTest
    private static void testSkipTriggerOutsideTestContext() {
        // Ensure skipTrigger is still false outside the test context
        System.assertEquals(false, TriggerControl.skipTrigger, 'skipTrigger should be false outside the test context.');
    }
}