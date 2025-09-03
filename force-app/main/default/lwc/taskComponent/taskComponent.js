import { LightningElement, wire, api } from 'lwc';
import getTaskData from '@salesforce/apex/IL_TaskController.getTaskData';
import { NavigationMixin } from 'lightning/navigation';

export default class TaskComponent extends NavigationMixin(LightningElement) {
    @api recordId;
    tasks = [];
    error;

    connectedCallback() {
        console.log('📢 recordId FORZADO:', this.recordId);
    }

    @wire(getTaskData, { recordId: '$recordId' })
    wiredTasks({ error, data }) {
        if (data) {
            console.log('📢 Datos obtenidos:', JSON.stringify(data));
            this.tasks = [...data];
            this.tasks = data.map(task => ({
                ...task,
                CallDurationInMinutes: (task.CallDurationInSeconds / 60).toFixed(2),
                FormattedDate: task.Subject.replace('Call ', '').replace('-05', '') 
            }));
            this.error = undefined;
        } else if (error) {
            console.error('🚨 Error:', JSON.stringify(error));
            this.error = error;
            this.tasks = [];
        }
    }

    handleViewTask(event) {
        const taskId = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: taskId,
                actionName: 'view'
            }
        });
    }
}
