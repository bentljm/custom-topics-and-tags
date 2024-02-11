public with sharing class TopicPermissionsUtility {

    /**
     * Method to check CRUD permission for the running user on the specified object.
     * @param objectApiName The API name of the object.
     * @return Map of permission and whether the running user has permission.
     */
    public static Map<String, Boolean> getCrudPermissions(String objectApiName) {
        // Create map to store CRUD permissions
        Map<String, Boolean> crudPermissionsMap = new Map<String, Boolean>();

        // Check CRUD permission from profile
        getCrudPermissionsFromProfile(objectApiName, crudPermissionsMap);

        // Check CRUD permission from permission sets
        getCrudPermissionsFromPermissionSets(objectApiName, crudPermissionsMap);

        // Return permissions map 
        return crudPermissionsMap;
    }

    /**
     * Method to check CRUD permission for the running user on the specified object from the profile.
     * @param objectApiName The API name of the object.
     * @return Boolean indicating whether the running user has CRUD permission from the profile.
     */
    private static void getCrudPermissionsFromProfile(String objectApiName, Map<String, Boolean> crudPermissionsMap) {
        // Get the running user's profile id
        Id profileId = UserInfo.getProfileId();

        // Check CRUD permissions in the profile
        checkObjectPermissions(objectApiName, profileId, crudPermissionsMap);
    }

    /**
     * Method to get ObjectPermissions for a specified object and profile Id.
     * @param objectApiName The API name of the object.
     * @param profileId The Id of the Profile.
     */
    private static void checkObjectPermissions(String objectApiName, Id profileId, Map<String, Boolean> crudPermissionsMap) {
        List<ObjectPermissions> objectPermissions = new List<ObjectPermissions>();
        try {
            // Query ObjectPermissions for the specified object and profile Id
            objectPermissions = [
                SELECT Id, PermissionsRead, PermissionsCreate, PermissionsEdit, PermissionsDelete
                FROM ObjectPermissions
                WHERE Parent.ProfileId = :profileId
                AND SObjectType = :objectApiName
                LIMIT 1
            ];
            // set CRUD permissions in the permission map

            if (!objectPermissions.isEmpty()) {
                ObjectPermissions permission = objectPermissions[0];
                setCrudPermissionsMap(permission, crudPermissionsMap);
            }
        } catch (Exception e) {
            // Handle exception (e.g., log or rethrow)
            throw new TopicPermissionsUtilityException('TopicPermissionsUtility: Failed to get ObjectPermissions from profile: ' + e.getMessage());
        }
    }

    /**
     * Method to check CRUD permission for the running user on the specified object from permission sets.
     * @param objectApiName The API name of the object.
     */
    private static void getCrudPermissionsFromPermissionSets(String objectApiName, Map<String, Boolean> crudPermissionsMap) {
        try {
            // Get the running user's permission set assignments
            List<PermissionSetAssignment> permissionSetAssignments = [
                SELECT PermissionSetId
                FROM PermissionSetAssignment
                WHERE AssigneeId = :UserInfo.getUserId()
            ];

            // Get the set of PermissionSet Ids
            Set<Id> permissionSetIds = new Set<Id>();
            for (PermissionSetAssignment permissionSetAssignment : permissionSetAssignments) {
                permissionSetIds.add(permissionSetAssignment.PermissionSetId);
            }

            // Query PermissionSet records outside of the loop
            List<ObjectPermissions> objectPermissions = getPermissionSets(objectApiName, permissionSetIds);

            // Loop through permission sets to check CRUD permissions
            for (ObjectPermissions objectPermission : objectPermissions) {
                // set CRUD permissions in the permission map
                setCrudPermissionsMap(objectPermission, crudPermissionsMap);
            }
        } catch (Exception e) {
            // Handle exception (e.g., log or rethrow)
            throw new TopicPermissionsUtilityException('TopicPermissionsUtility: Failed to get CRUD permission from permission sets: ' + e.getMessage());
        }
    }

    /**
     * Method to get PermissionSet records by their Ids.
     * @param objectApiName Object API Name to check permission
     * @param permissionSetIds Set of PermissionSet Ids.
     * @return List of PermissionSet records.
     */
    private static List<ObjectPermissions> getPermissionSets(String objectApiName, Set<Id> permissionSetIds) {
        try {
            return [
                SELECT Id, PermissionsRead, PermissionsCreate, PermissionsEdit, PermissionsDelete
                FROM ObjectPermissions
                WHERE ParentId IN :permissionSetIds
                AND SObjectType = :objectApiName
                LIMIT 1
            ];
        } catch (Exception e) {
            // Handle exception (e.g., log or rethrow)
            throw new TopicPermissionsUtilityException('TopicPermissionsUtility: Failed to get PermissionSets: ' + e.getMessage());
        }
    }


    /**
     * Method to check CRUD permissions in a profile or permission set.
     * @param profileOrPermissionSet The Profile or PermissionSet object to check.
     */
    private static void setCrudPermissionsMap(SObject profileOrPermissionSet, Map<String, Boolean> crudPermissionsMap) {
        // Check if the specified object is readable, writable, and deletable in the profile or permission set
        for (String permission : TopicConstants.ALL_PERMISSIONS) {
            if (!crudPermissionsMap.containsKey(permission) || 
                (crudPermissionsMap.containsKey(permission) && crudPermissionsMap.get(permission) != true)) {
                crudPermissionsMap.put(permission, (Boolean)profileOrPermissionSet.get(permission));
            }
        }
    }

    // Custom exception class
    public class TopicPermissionsUtilityException extends Exception {}
}