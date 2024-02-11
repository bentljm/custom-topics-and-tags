import { LightningElement, wire, track, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord, deleteRecord } from 'lightning/uiRecordApi';

// Import Apex methods
import getRecordData from '@salesforce/apex/TopicHelper.getRecordData';
import getCrudPermissions from '@salesforce/apex/TopicHelper.getCrudPermissions';
import getTopicConfigurations from '@salesforce/apex/TopicHelper.getTopicConfigurations';
import getTopicsRelatedToRecord from '@salesforce/apex/TopicHelper.getTopicsRelatedToRecord';
import getTopicsOnSearch from '@salesforce/apex/TopicHelper.getTopicsOnSearch';

// Import Schema
import TOPIC_JUNCTION from '@salesforce/schema/Topic_Junction__c';
import TOPIC_JUNCTION_TOPIC from '@salesforce/schema/Topic_Junction__c.Topic__c';
import TOPIC_JUNCTION_UNIQUE_ID from '@salesforce/schema/Topic_Junction__c.Topic_Junction_Id__c';
import TOPIC_JUNCTION_JUNCTION_NAME_FIELD from '@salesforce/schema/Topic_Junction__c.Topic_Junction_Name__c'
import TOPIC_JUNCTION_OBJECT_FIELD from '@salesforce/schema/Topic_Junction__c.Object_Field__c';
import TOPIC_JUNCTION_RECORD_NAME from '@salesforce/schema/Topic_Junction__c.Record_Name__c';
import TOPIC_JUNCTION_RECORD_ID from '@salesforce/schema/Topic_Junction__c.Record_Id__c';

export default class TopicCardComponent extends NavigationMixin(LightningElement) {
    // Get api properties
    @api cardTitle;
    @api cardIcon;
    @api cardHelpText;
    @api record;
    @api recordId;
    @api objectApiName;
    @api topicCategories;
    @api isLoaded = false;
    @api nullList = [undefined, null, ''];

    // Track component properties
    @track topicConfigurations;
    @track componentProps;
    @track componentSpinner = true;
    @track selectedTopicsWired;
    @track selectedTopics = [];

    // Track combo box properties
    @track categorySelected = 'All';
    @track categoryOptions = [{ label: 'All', value: 'All' }];

    // Track search properties
    @track searchProps;
    @track searchSpinner = false;
    @track searchedTopics = [];
    @track message;
    @track value;

    // Track permission properties
    @track createPermission;
    @track readPermission;

    get topicCount() {
        return this.selectedTopics.length;
    }
    get createNewTopic() {
        return this.createPermission && this.value?.length > 1 && 
        !this.searchedTopics?.find(topic => topic.sObj?.Name === this.value);
    }

    @wire(getRecordData, { recordId: '$recordId', objectApiName: '$objectApiName' })
    recordData

    @wire(getCrudPermissions, { objectApiName: '__Topic__c' })
    getCrudPermissions({ data, error }) {
        if (data) {
            this.setPermissions(data);
        } else if (error) {
            this.showToast('Error', 'error', 'Error getting Permissions: ' + this.getErrorMessage(error));
        }
    }

    @wire(getTopicConfigurations, { objectApiName: '$objectApiName', topicCategories: '$topicCategories' })
    getTopicConfigurations({ data, error }) {
        if (data) {
            this.setCategoryOptions(data);
            this.setTopicConfigurations(data);
            this.setComponentProps(); 
        } else if (error) {
            this.showToast('Error', 'error', 'Error getting Topic Configurations: ' + this.getErrorMessage(error));
        }
    }

    @wire(getTopicsRelatedToRecord, { wrapper: '$componentProps' })
    getTopicsRelatedToRecord(value) {
        this.selectedTopicsWired = value;
        const { data, error } = value;
        if (data) {
            this.setSelectedTopics(data);
        } else if (error) {
            this.showToast('Error', 'error', 'Error getting Topics: ' + this.getErrorMessage(error));
        }
    }

    @wire(getTopicsOnSearch, { wrapper: '$searchProps' })
    getTopicsOnSearch(value) { 
        this.message = '';
        const { data, error } = value;
        if (data && JSON.parse(data).length > 0) {
            this.searchedTopics = JSON.parse(data);
            this.showTopics();
            this.hideSearchSpinner();

        } else if (error) {
            this.showDropdown = false;
            this.searchedTopics = [];
            this.showToast('Error', 'error', 'Error searching for Topics: ' + this.getErrorMessage(error));
            this.hideSearchSpinner();
        } else {
            if (this.isLoaded) {
                this.showDropdown = true;
                this.searchedTopics = [];
                this.message = 'No Topics Found';
                this.hideSearchSpinner();
            } else {
                this.isLoaded = true;
                this.hideSearchSpinner();
            }
        }
    }

    connectedCallback() {
        this.hideComponentSpinner();
    }

    setPermissions(data) {
        this.createPermission = data['PermissionsCreate'];
        this.readPermission = data['PermissionsRead'];
    }

    setCategoryOptions(data) {
        const categoryOptionsFromConfig = data.map(config => ({ 
            label: config.Category__c, value: config.Category__c 
        }));
        this.categoryOptions = [...this.categoryOptions, ...categoryOptionsFromConfig];
    }

    setTopicConfigurations(data) {
        this.topicConfigurations = data.reduce((configurations, config) => {
            configurations[config.Category__c] = config; 
            return configurations;
        }, {});
    }

    setComponentProps() {
        this.componentProps = {
            recordId: this.recordId,
            objectApiName: this.objectApiName,
            topicCategories: this.topicCategories
        }
    }

    setSelectedTopics(data) {
        const allData = JSON.parse(data);
        this.selectedTopics = allData.reduce((result, row) => {
            console.log(JSON.stringify(row));
            row.sObj.Name = row.sObj.Topic__r.Name;
            row.class = this.getPillClass(row.sObj?.Topic__r?.Category__c);
            result.push({...row});
            return result;
        }, []);
    }

    getPillClass(category) {
        let pillClass = 'pill';
        if (this.topicConfigurations){
            const config = this.topicConfigurations[category];
            let colorClass = config.Pill_Color__c;
            let styleClass = config.Pill_Style__c;
            return `${pillClass} ${styleClass} ${colorClass}-${styleClass}`;
        } else {
            return pillClass;
        }
    }

    handleCategoryChange(event) {
        this.categorySelected = event.detail.value;
    }

    handleSearchTopics(event) {
        this.showSearchSpinner();
        if (event.target.value != '') {
            this.value = event.target.value;
            this.setSearchProps(event);
        } else {
            this.hideSearchSpinner();
            this.hideTopics();
        }
    }

    setSearchProps(event) {
        const topicCategories = this.categorySelected === 'All' ? this.topicCategories : this.categorySelected;
        this.searchProps = {
            searchTerm: this.value,
            recordId: this.recordId,
            objectApiName: this.objectApiName,
            topicCategories: topicCategories
        }
    }

    handleAddOrRemoveTopic(event) {
        event.preventDefault();
        this.showSearchSpinner();
        const topicId = event.currentTarget?.dataset?.key;
        const topicRec = this.searchedTopics.find(topic => topic.sObj.Id === topicId);
        topicRec.isSelected ? this.handleRemoveTopic(topicRec) : this.handleAddTopic(topicRec);
    }

    handleAddTopic(topicRec) {
        const fields = this.getFieldsForTopicJunction(topicRec.sObj);
        const recordInput = { apiName: TOPIC_JUNCTION.objectApiName, fields };
        this.createTopicJunction(recordInput);
    }

    handleRemoveTopic(topicRec) {
        const removedKey = `${topicRec.sObj.Name}${topicRec.sObj.Category__c}`;
        const removedTopic = this.selectedTopics.find(topic => {
            let key = `${topic.sObj.Name}${topic.sObj.Topic__r.Category__c}`
            return key === removedKey;
        });
        this.selectedTopics = this.selectedTopics.filter(topic => {
            let key = `${topic.sObj.Name}${topic.sObj.Topic__r.Category__c}`
            return key !== removedKey;
        });
        this.deleteTopicJunction(removedTopic.sObj.Id);
    }

    handleRemoveTopicPill(event) {
        event.preventDefault();
        this.showComponentSpinner();
        const dataset = event.currentTarget?.dataset;
        this.selectedTopics.splice(dataset.index, 1);
        this.deleteTopicJunction(dataset.key);
    }

    getFieldsForTopicJunction(topic) {
        const nameFieldToRecordMap = this.recordData?.data;
        const nameField = Object.keys(nameFieldToRecordMap)[0];
        const record = Object.values(nameFieldToRecordMap)[0];
        const objectField = this.topicConfigurations[topic.Category__c]?.Object_Field__c;
        const recordName = record != null && nameField != null ? record[nameField] : '';
        const topicJunctionId = `${this.recordId}-${this.objectApiName}-${topic.Id}`;
        const topicJunctionName = `${recordName}-${topic.Name}`;
        return {
            [TOPIC_JUNCTION_TOPIC.fieldApiName]: topic.Id,
            [TOPIC_JUNCTION_OBJECT_FIELD.fieldApiName]: objectField,
            [TOPIC_JUNCTION_RECORD_NAME.fieldApiName]: recordName,
            [TOPIC_JUNCTION_RECORD_ID.fieldApiName]: this.recordId,
            [TOPIC_JUNCTION_UNIQUE_ID.fieldApiName]: topicJunctionId,
            [TOPIC_JUNCTION_JUNCTION_NAME_FIELD.fieldApiName]: topicJunctionName,
        }
    }

    createTopicJunction(recordInput) {
        createRecord(recordInput)
            .then(response => {
                refreshApex(this.selectedTopicsWired);
                this.showToast('Success', 'success', 'Topic successfully added!');
                this.hideSearchSpinner();
                this.hideTopics();
            })
            .catch(error => {
                this.showToast('Error', 'error', 'Error adding Topic to record: ' + error);
                this.hideSearchSpinner();
                this.hideTopics();
            })
    }

    deleteTopicJunction(recordInput) {
        deleteRecord(recordInput)
            .then(response => {
                this.showToast('Success', 'success', 'Topic successfully removed!');
                this.hideComponentSpinner();
                this.hideTopics();
            })
            .catch(error => {
                this.showToast('Error', 'error', 'Error removing Topic from record: ' + error);
                this.hideComponentSpinner();
                this.hideTopics();
            })
    }

    handleCreateNewTopic(event) {
        const category = this.categorySelected !== 'All' ? this.categorySelected : '';
        this[NavigationMixin.Navigate]({
            "type": "standard__objectPage",
            "attributes": {
                "objectApiName": "Topic__c",
                "actionName": "new"
            },
            "state": {
                "defaultFieldValues": `Name=${this.value},Category__c=${category},Object_Visibility__c=${this.objectApiName}`
            }
        });
    }

    handleGoToTopics() {
        this[NavigationMixin.GenerateUrl]({
            "type": "standard__objectPage",
            "attributes": {
                "objectApiName": "Topic__c",
                "actionName": "list"
            },
            "state": {
                "filterName": "Recent"
            }
        }).then(url => window.open(url));
    }

    handleGoToTopic(event) {
        let topicId = event.currentTarget?.dataset?.key;
        const topicRec = this.selectedTopics.find(topic => topic.sObj.Id === topicId);
        window.open(topicRec.href);
    }

    showToast(title, variant, message) {
        const event = new ShowToastEvent({ title: title, variant: variant, message: message });
        this.dispatchEvent(event);
    }

    getErrorMessage(error) {
        let message;
        if (Array.isArray(error)) {
            message = error.map(error => error.message);
        } else if (typeof error === 'string') {
            message = error;
        } else {
            message = error.message || 'Unknown error';
        }
        return message;
    }

    showTopics() {
        this.checkSelected();
        this.showDropdown = true;
    }

    hideTopics() {
        this.checkSelected();
        this.showDropdown = false;
        this.value = '';
    }

    checkSelected() {
        const selectedValues = this.selectedTopics.map(topic => topic.sObj.Name);
        this.searchedTopics.forEach(topic => {
            topic.isSelected = selectedValues.includes(topic.sObj.Name);
        })
    }

    showComponentSpinner() {
        this.componentSpinner = true;
    }

    hideComponentSpinner() {
        this.componentSpinner = false;
    }

    showSearchSpinner() {
        this.searchSpinner = true;
    }

    hideSearchSpinner() {
        this.searchSpinner = false;
    }
}