/**
 * @description : Clase para el componente Five9, filtra por la cuenta actual.
 * @author Bluetech
 * @group InLearning
 * @last modified on  : 23-02-2025
 * @last modified by  : Ricardo
 * Modifications Log:
 * Ver   Date         Author          Modification
 * 1.0   23-02-2025   Ricardo Diaz    Creación de la clase 
 */

 public with sharing class IL_TaskController {
    @AuraEnabled(cacheable=true)
    public static List<Task> getTaskData(Id recordId) {
        // 1. Obtener los contactos relacionados a la cuenta
        List<Id> contactIds = new List<Id>();
        for (Contact c : [SELECT Id FROM Contact WHERE AccountId = :recordId]) {
            contactIds.add(c.Id);
        }

        // 2. Obtener todas las tareas relacionadas a la cuenta o a sus contactos
        List<Task> tasks;
        if (contactIds.isEmpty()) {
            tasks = [SELECT Id, Subject, CallDisposition, CallDurationInSeconds, CallType, 
                            Five9__Five9TaskType__c, Owner.Name, ActivityDate, WhatId, WhoId, AccountId
                     FROM Task
                     WHERE (WhatId = :recordId)
                     ORDER BY ActivityDate DESC NULLS FIRST
                     LIMIT 500];
        } else {
            tasks = [SELECT Id, Subject, CallDisposition, CallDurationInSeconds, CallType, 
                            Five9__Five9TaskType__c, Owner.Name, ActivityDate, WhatId, WhoId, AccountId
                     FROM Task
                     WHERE (WhatId = :recordId OR WhoId IN :contactIds)
                     ORDER BY ActivityDate DESC NULLS FIRST
                     LIMIT 500];
        }

        System.debug('📢 TOTAL DE TAREAS ENCONTRADAS: ' + tasks.size());
        return tasks;
    }
}
