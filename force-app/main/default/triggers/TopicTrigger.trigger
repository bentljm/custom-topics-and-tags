trigger TopicTrigger on Topic__c (before insert, before update, before delete) {
    if (!TriggerControl.skipTrigger) {
        TriggerHandler handler = new innovations_hub.TopicTriggerHandler(Trigger.isExecuting, Trigger.size);
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                handler.beforeInsert(Trigger.new);
            } 
            when BEFORE_UPDATE {
                handler.beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when BEFORE_DELETE {
                handler.beforeDelete(Trigger.old, Trigger.oldMap);
            }
        }      
    }
}