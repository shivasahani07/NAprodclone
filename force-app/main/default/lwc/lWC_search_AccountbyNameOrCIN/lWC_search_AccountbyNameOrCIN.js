import { LightningElement, track, api } from 'lwc';
import createTaskForSearch from '@salesforce/apex/AccountController.createTaskForSearch';
import getAccountFromAudit from '@salesforce/apex/AccountController.getAccountFromAudit';
import updateAccount from '@salesforce/apex/AccountController.updateAccount';
import createTaskAfterSearch from '@salesforce/apex/AccountController.createTaskAfterSearch';
import createPartnerAPItask from '@salesforce/apex/AccountController.createPartnerAPItask';
import findAccount from '@salesforce/apex/AccountController.findAccount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import MY_CUSTOM_LABEL from '@salesforce/label/c.narcbaseurl';

export default class LWC_search_AccountbyNameOrCIN extends LightningElement {
    narcbaseurl = MY_CUSTOM_LABEL;
    @track searchKey = '';
    @track searchType = '';
    @track account;
    @track isLoading = false;
    @track isSearchButtonDisabled = true;
    @track showSearchButton = true;
    @track taskId;
    @track searchOptions = [
        { label: 'Name', value: 'Name' },
        { label: 'CIN No', value: 'CIN_No__c' }
    ];

    @track searchPerformed = false;
    @track searchKeyPlaceholder = 'Please select a search type';
    @track buttonLabel = 'Create';
    @track isSearchKeyDisabled = true;
    @track isButtonDisabled = true; 
    

    // Handlers and methods
    handleSearchKeyChange(event) {
        this.searchKey = event.target.value;

        // Enable the search button if there's any content in the search key
        this.isSearchButtonDisabled = !this.searchKey.trim().length;

        // Clear previous search results immediately when the search key changes
        if (this.searchPerformed || this.account) {
            this.account = null;
            this.searchPerformed = false;
            this.showSearchButton = true;
        }
    }





    handleSearchTypeChange(event) {
        this.searchType = event.detail.value;

        // Reset the component regardless of whether a search has been performed
        this.resetComponent();
        this.isSearchKeyDisabled = false;
        this.updatePlaceholder();

        // The search key is preserved and the button is enabled if there's a search key
        this.isSearchButtonDisabled = !this.searchKey;
    }

    updatePlaceholder() {
        switch (this.searchType) {
            case 'Name':
                this.searchKeyPlaceholder = 'Please enter Account Name';
                break;
            case 'CIN_No__c':
                this.searchKeyPlaceholder = 'Please enter CIN No';
                break;
            default:
                this.searchKeyPlaceholder = 'Please select a search type';
                break;
        }
    }

    handleSearch() {
        debugger;
        if (!this.searchKey) {
            this.showToast('Error', 'Please enter a search key.', 'error');
            return;
        }

        // Attempt to find an existing account first
        let searchField = this.searchType === 'Name' ? 'Name' : 'CIN_No__c';
        findAccount({ searchKey: this.searchKey, searchField: searchField })
            .then(account => {
                this.searchPerformed = true;
                if (account) {
                    // Account found, display it without creating a task
                    this.account = account;
                    //this.searchPerformed = true;
                    this.showSearchButton = false;
                    this.buttonLabel = 'Update'; // Change button label to 'Update'
                    this.showToast('Notification', '🚨 An Account with this information already exists.', 'warning');
                } else {
                    // Account not found, proceed with creating a task
                    this.isLoading = true;
                    this.showSearchButton = false;
                    let searchByString = this.searchType === 'Name' ? `companyName:${this.searchKey}` : `cin:${this.searchKey}`;

                    createTaskForSearch({ searchByString: searchByString, subject: 'Get Partner Callout - Nimbus' })
                        .then(taskId => {
                            this.taskId = taskId;
                            setTimeout(() => {
                                this.checkAuditAndRetrieveAccount();
                                this.buttonLabel = 'Create';
                            }, 10000);
                        })
                        .catch(error => {
                            this.isLoading = false;
                            this.showToast('Error', 'Failed to create task - ' + error.body.message, 'error');
                        });
                }
            })
            .catch(error => {
                this.showToast('Error', 'Error searching for account- ' + error.body.message, 'error');
            });
    }





    checkAuditAndRetrieveAccount() {
        debugger;
        getAccountFromAudit({ taskId: this.taskId })
            .then(result => {
                this.isLoading = false;
                if (result) {
                    this.account = result;
                    this.searchPerformed = false;
                    this.showSearchButton = false;
                    this.showToast('Success', 'Account retrieved successfully.', 'success');
                } else {
                    this.searchPerformed = true;
                    this.showSearchButton = true;
                    this.isSearchButtonDisabled = true;
                    this.showToast('Warning', 'Account not found.', 'warning');
                }
            })
            .catch(error => {
                this.isLoading = false;
                this.searchPerformed = true;
                this.showToast('Error', 'Account not found. Please try Again', 'error');
            });
    } 

    handleInputChange(event) {
        debugger;
        this.isButtonDisabled = false;
        const field = event.target.name;
        var tempAcc = {...this.account};
        if (field == 'Phone') {
            tempAcc.Phone = event.target.value;
        }
        else if(field == 'Short_Key__c'){
            tempAcc.Short_Key__c = event.target.value;
        }
        else if(field == 'Email_Id__c'){
            tempAcc.Email_Id__c = event.target.value;
        }
        this.account = {...tempAcc};
    }

    handleCreate() {
        debugger;
        this.isButtonDisabled = true;
        let accountId;

        if (!this.account.Short_Key__c || this.account.Short_Key__c.trim().length === 0) {
            this.showToast('Error', 'Short Key is required.', 'error');
            return;
        }

        updateAccount({
            accountId: this.account.Id,
            email: this.account.Email_Id__c,
            phone: this.account.Phone,
            apiKey: this.account.Short_Key__c
        })
            // .then(() => {
            //     return createPartnerAPItask({
            //         subject: 'Create Partner Callout - Nimbus',
            //         searchByString: null,
            //         whatId: this.account.Id
            //     });
            // })
            .then(() => {
                this.showToast('Success', 'Account updated and task created successfully'+':'+ this.account.Id  , 'success');
                //this.account = null; // Clear the account details
                this.searchPerformed = false;
                //this.showSearchButton = true;
                /*this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.account.Id,
                        objectApiName: 'Account',
                        actionName: 'view'
                    }
                });*/
                // https://northernarc--narcdevpro.sandbox.lightning.force.com/this.account.Id

                //window.open('https://northernarc--narcdevpro.sandbox.lightning.force.com/lightning/r/Account/'+this.account.Id+'/view','_blank');

                const toaEvent = new CustomEvent('getdata', {
                    bubbles: true,
                    composed: true,
                    detail: {
                        accountId: this.account.Id,
                    }
                });
                this.dispatchEvent(toaEvent);
            })
            .catch(error => {
                //this.showToast('Error', 'Error updating account: ' + error.body.message, 'error');
                this.isButtonDisabled = true;
                this.showSearchButton = true;
            });
    }

    handleCancel() {
        
        debugger;
        var redireclurl = narcbaseurl + 'lightning/o/Account/list?filterName=00BBl000000PDoTMAW';
        this.showToastcancel('Error', redireclurl, 'error');
    }

    createTask() {
        let subject = 'Get Partner Callout - Nimbus';
        // Assuming createTaskForSearch method is already in the controller
        createTaskAfterSearch({ subject: subject, whatId: this.account.Id })
            .then(() => {
                this.showToast('Success', 'Task created and Account updated successfully', 'success');
                // Actions to perform after task creation
            })
            .catch(error => {
                this.showToast('Error', 'Error creating task - ' + error.body.message, 'error');
            });
    }

    resetComponent() {
        // Logic to refresh the component
        this.account = null;
        this.searchKey = '';
        //this.searchType = '';
        this.showSearchButton = true;
        this.isSearchButtonDisabled = !this.searchKey;
        this.searchPerformed = false;
        this.updatePlaceholder();
        // Other resetting logic
    }


    showToast(title, message, variant) {
        debugger;
        // Dispatch a custom event for the toast
        const toastEvent = new CustomEvent('lwcCustomToastEvent', {
            bubbles: true,
            composed: true,
            detail: { title, message, variant }
        });
        this.dispatchEvent(toastEvent);
    }

    showToastcancel(title, message, variant){
        const toastEvent = new CustomEvent('canceldata', {
            bubbles: true,
            composed: true,
            detail: { title, message, variant }
        });
        this.dispatchEvent(toastEvent);

    }
}