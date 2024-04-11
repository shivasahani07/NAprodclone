import { LightningElement, api } from 'lwc';
import getTaskRelatedDetailsForRecal from '@salesforce/apex/paymentscheduleController.getTaskRelatedDetailsForRecal';
import Submitpaymentschedule from '@salesforce/apex/paymentscheduleController.Submitpaymentschedule';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'


export default class Lwc_recalibration extends LightningElement {

    @api recId;
    @api IsEdit;
    @api Index;
    @api Isclose;

    accountName;
    paymentschedule ={
                        reccalprice: true,
                        newrecalprice:false,
                        disableremark: false,
                    };
    PsrecId;


    checkStatusOnLoad(){
        debugger;
    }

    connectedCallback() {
        // This doesn't work
        this.gettaskrelatedDetailsinJs();
      }

    gettaskrelatedDetailsinJs(){
        debugger;

        getTaskRelatedDetailsForRecal({ taskId: this.recId })
        .then((data) => {
        debugger;

            if (data.taskOppdetails != null) {
                this.accountName = data.taskOppdetails.Account.Name;
                this.paymentschedule.Opportunity__c = data.taskOppdetails.Id;
            }
            if (data.paymentrecordwithchild != null && data.paymentrecordwithchild != undefined) {
                if (this.IsEdit) {
                    this.paymentschedule = {
                        ...data.paymentrecordwithchild[0],
                        reccalprice: true,
                        disableremark: false,
                        newrecalprice:false,
                        New_Recalibration_Price__c : data.paymentrecordwithchild[0].New_Recalibration_Price__c != (null || undefined)  ? data.paymentrecordwithchild[0].New_Recalibration_Price__c: data.paymentrecordwithchild[0].Model_Recalibration_Price__c
                    };
                    
                }
                else {
                    this.paymentschedule = {
                        ...data.paymentrecordwithchild[0],
                        reccalprice: true,
                        disableremark: true,
                        newrecalprice:true,
                        New_Recalibration_Price__c : data.paymentrecordwithchild[0].New_Recalibration_Price__c != (null || undefined)  ? data.paymentrecordwithchild[0].New_Recalibration_Price__c: data.paymentrecordwithchild[0].Model_Recalibration_Price__c
                    };
                }
                
            }
            this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
        this.contacts = undefined;
      });

    }

    psfieldChangeHandler(event){ //
        var temppaymentschedule = {};
        if (this.paymentschedule != undefined && this.paymentschedule != null) {
            temppaymentschedule = { ... this.paymentschedule };
        }
        if (event.target.name == 'remark') {
            temppaymentschedule.Comment__c = event.target.value;
        }
        if (event.target.name == 'nrp') {
            temppaymentschedule.New_Recalibration_Price__c = event.target.value;
        }
        this.paymentschedule = {...temppaymentschedule};
    }

    SubmitpsRecord(event) {
        debugger;
        this.isSpinner = true;
        var temppaymentschedule = {...this.paymentschedule,  'Task_Id__c': ''};
        temppaymentschedule.Task_Id__c = this.recId;
        Submitpaymentschedule({ PsRecord: temppaymentschedule })
            .then(result => {
                debugger;
                this.PsrecId = result.Id;
                this.isSpinner = false;
                if (result) {
                    this.sendMessageToParent();
                }

            })
            .catch(error => {

                this.processErrorMessage(error);
                this.isSpinner = false;
            });
    }    

    @api
    finalvalidation() {
        debugger;
        var errorMsg;
        this.SubmitpsRecord();
    }

    showToastMessage(variant, message, title) {
        // this.dispatchEvent(
        //     new ShowToastEvent({
        //         title: title,
        //         message: message,
        //         variant: variant
        //     })
        // );
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }


    sendMessageToParent() {

        const event = new CustomEvent('lwceventrecalibration', {
            detail: {
                Isclose: true,
                Index: this.Index
            }
        });
        this.dispatchEvent(event);
    }


    processErrorMessage(message) {
        debugger;
        let errorMsg = '';
        if (message) {
            if (message.body) {
                if (Array.isArray(message.body.pageErrors)) {
                    errorMsg =message.body.pageErrors[0].message;
                    //errorMsg = message.body.map(e => e.message).join(', ');
                } else if (typeof message.body.message === 'string') {
                    errorMsg = message.body.message;
                }
            }
            else {
                errorMsg = message;
            }
        }
        this.showToastMessage('error', errorMsg, 'Error!');
    }
}