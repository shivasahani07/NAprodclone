import { LightningElement, wire, api } from 'lwc';
import CreateAddRecalibrationtask from "@salesforce/apex/Lwc_addrecalibrationcontroller.CreateAddRecalibrationtask";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Lwc_addrecalibration extends NavigationMixin(LightningElement) {
    Wrapperdata;
    @api recordId;
    error;
    

    connectedCallback() {
        // This doesn't work
        setTimeout(() => {
            // Your code here
            this.createrecalibrationTaskrec();
        }, 5000);
        
      }


      createrecalibrationTaskrec(){
        debugger;

        CreateAddRecalibrationtask({ accId: this.recordId })
        .then((data) => {
        debugger;
        if (data) {
            debugger;
            this.Wrapperdata = data;
            if (this.Wrapperdata.OppRec != null && this.Wrapperdata.Oppstatus == 'Existing NuScore PS Opportunity') {
                var errorMsg = 'Payment Schedule Opportunity is still Open, please close that first!';
                this.showToastMessage('error', errorMsg, 'Error!');
                window.alert('Payment Schedule Opportunity is still Open, please close that first!');
                this.navigateToRecord(this.Wrapperdata.OppRec.Id);
            }
            else if(this.Wrapperdata.OppRec != null && this.Wrapperdata.Oppstatus == 'New NuScore Recalibration Opportunity'){
                this.navigateToRecord(this.Wrapperdata.OppRec.Id);
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.taskrecord = undefined;
        }

        })
        .catch((error) => {
            this.error = error;
            this.contacts = undefined;
          });
    }  

    /*@wire(CreateAddRecalibrationtask, { accId: '$recordId' })
    wiredRecordtask({ error, data }) {
        if (data) {
            debugger;
            this.Wrapperdata = data;
            if (this.Wrapperdata.OppRec != null && this.Wrapperdata.Oppstatus == 'Existing NuScore PS Opportunity') {
                var errorMsg = 'Payment Schedule Opportunity is still Open, please close that first!';
                this.showToastMessage('error', errorMsg, 'Error!');
                window.alert('Payment Schedule Opportunity is still Open, please close that first!');
                this.navigateToRecord(this.Wrapperdata.OppRec.Id);
            }
            else if(this.Wrapperdata.OppRec != null && this.Wrapperdata.Oppstatus == 'New NuScore Recalibration Opportunity'){
                this.navigateToRecord(this.Wrapperdata.OppRec.Id);
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.taskrecord = undefined;
        }
    }*/
    showToastMessage(variant, message, title) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    navigateToRecord(AccrecordId) {
        debugger;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: AccrecordId,
                actionName: 'view'
            }
        });
    }


}