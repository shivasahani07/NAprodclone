import { LightningElement, api, wire, track } from 'lwc';
import getTaskRelatedDetails from '@salesforce/apex/paymentscheduleController.getTaskRelatedDetails';
import Submitpaymentschedule from '@salesforce/apex/paymentscheduleController.Submitpaymentschedule';
import SubmitPriceStructure from '@salesforce/apex/paymentscheduleController.SubmitPriceStructure';
import { getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import OPPORTUNITY_OBJECT from "@salesforce/schema/Opportunity";

import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
export default class Lwc_paymentschedule extends LightningElement {

    @api recId;
    @api IsEdit;
    @api Index;
    @api Isclose;


    accountName;
    Costpricetype;
    cptoptions = [];
    billfrequencylist = [];
    psresetFreqlist = [];
    PsTypeList = [];
    paymentschedule = {
        disableMBP: false,
        disableMRP: false,
        disableVSD: false,
        disableVED: false,
        disableFP: false,
        disableBF: true,
        disableCP: false,
        disableFper: false,
        disableCper: false,
        mandFper: false,
        mandCper: false,
        task_Id__c : this.recId
    };
    @track PriceStructLIst = [];
    ShowPsTable;
    diablePriceStructure = false;
    globalpstypelist = [];
    isSpinner = false;
    @api OpprecordTypeId;
    BillFreqforPriceStructureValidation = [];
    @track actualBillFreqForPSValidate = [];

    connectedCallback() {
        // This doesn't work
        this.gettaskrelatedDetailsinJs();
      }

    gettaskrelatedDetailsinJs(){
        debugger;

        getTaskRelatedDetails({ taskId: this.recId })
        .then((data) => {
        debugger;

            var tempBillFreq = [];
            var tempBillFreqforPriceStructureValidation = [];
            if (data.picklistMap.Billing_Frequency != null) {
                for (var i = 0; i < data.picklistMap.Billing_Frequency.length; i++) {
                    tempBillFreq.push({ label: data.picklistMap.Billing_Frequency[i], value: data.picklistMap.Billing_Frequency[i] });
                    tempBillFreqforPriceStructureValidation.push({ value: data.picklistMap.Billing_Frequency[i], id: i + 1 });
                }
                this.billfrequencylist = tempBillFreq;
                this.BillFreqforPriceStructureValidation = tempBillFreqforPriceStructureValidation;
            }

            var tempPstype = [];

            if (data.picklistMap.Price_Structure_Type != null) {
                for (var i = 0; i < data.picklistMap.Price_Structure_Type.length; i++) {
                    tempPstype.push({ label: data.picklistMap.Price_Structure_Type[i], value: data.picklistMap.Price_Structure_Type[i] });
                }
                this.PsTypeList = tempPstype;
                this.globalpstypelist = tempPstype;
            }
            if (data.taskOppdetails != null) {
                this.accountName = data.taskOppdetails.Account.Name;
                this.disableAccName = true;
                this.paymentschedule.Opportunity__c = data.taskOppdetails.Id;
            }
            if (data.paymentrecordwithchild != null && data.paymentrecordwithchild != undefined) {
                if (this.IsEdit) {
                    this.paymentschedule = {
                        ...data.paymentrecordwithchild[0],
                        disableMBP: false,
                        disableMRP: false,
                        disableVSD: false,
                        disableVED: false,
                        disableFP: false,
                        disableBF: false,
                        disableCP: false,
                        disableFper: false,
                        disableCper: false,
                        mandFper: false,
                        mandCper: false
                    };
                    
                }
                else {
                    this.paymentschedule = {
                        ...data.paymentrecordwithchild[0],
                        disableMBP: true,
                        disableMRP: true,
                        disableVSD: true,
                        disableVED: true,
                        disableFP: true,
                        disableBF: true,
                        disableCP: true,
                        disableFper: true,
                        disableCper: true,
                        mandFper: false,
                        mandCper: false
                    };
                }
                
                if (data.paymentrecordwithchild[0].Billing_Frequency__c != null && data.paymentrecordwithchild[0].Billing_Frequency__c != undefined) {
                    this.handleResetFrequency(data.paymentrecordwithchild[0].Billing_Frequency__c);
                }
                if (data.paymentrecordwithchild[0].Price_Structures__r != undefined && data.paymentrecordwithchild[0].Price_Structures__r.length > 0) {
                    this.handleShowExistingPriceStructureData(data.paymentrecordwithchild[0].Price_Structures__r);
                }
                else {
                    this.handleAddRow();
                }
            }
            

            this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
        this.contacts = undefined;
      });

    }

    psfieldChangeHandler(event) {
        debugger;
        var temppaymentschedule = {};
        if (this.paymentschedule != undefined && this.paymentschedule != null) {
            temppaymentschedule = { ... this.paymentschedule };
        }
        if (event.target.name == 'MBP') {
            temppaymentschedule.Model_Build_Price__c = parseInt(event.target.value);
        }
        else if (event.target.name == 'MRP') {
            temppaymentschedule.Model_Recalibration_Price__c = parseInt(event.target.value);
        }
        else if (event.target.name == 'floorper') {
            temppaymentschedule.Floor_Period__c = event.target.value;
        }
        else if (event.target.name == 'ceilper') {
            temppaymentschedule.Ceiling_Period__c = event.target.value;
        }

        else if (event.target.name == 'vsd') {
            temppaymentschedule.validity_start_Date__c = event.target.value;
            if (temppaymentschedule.validity_start_Date__c != null && temppaymentschedule.validity_start_Date__c != undefined) {
                temppaymentschedule.disableVED = false;
            }
            else {
                temppaymentschedule.disableVED = true;
            }

        }
        else if (event.target.name == 'ved') {
            var showmessage = this.compareDates(this.paymentschedule.validity_start_Date__c, event.target.value);
            if (showmessage) {
                this.showToastMessage('error', 'Validity End Date cannot be Smaller than Validity Start Date', 'Error!');
                temppaymentschedule.validity_End_Date__c = '';
                //window.alert('Validity End Date cannot be Smaller than Validity Start Date');
            }
            else {
                temppaymentschedule.validity_End_Date__c = event.target.value;
                if (temppaymentschedule.validity_End_Date__c != null && temppaymentschedule.validity_End_Date__c != undefined) {
                    temppaymentschedule.disableBF = false;
                }
                else {
                    temppaymentschedule.disableBF = true;
                }
            }
        }
        else if (event.target.name == 'floorprice') {
            temppaymentschedule.Floor_Price__c = parseInt(event.target.value);
            if (temppaymentschedule.Floor_Price__c != null && temppaymentschedule.Floor_Price__c != undefined && !isNaN(temppaymentschedule.Floor_Price__c)) {
                temppaymentschedule.mandFper = true;
                temppaymentschedule.Floor_Period__c = temppaymentschedule.Billing_Frequency__c;
            }
            else {
                temppaymentschedule.mandFper = false;
                temppaymentschedule.Floor_Period__c = '';
            }
        }
        else if (event.target.name == 'ceilingprice') {
            temppaymentschedule.Ceiling_Price__c = parseInt(event.target.value);
            if (temppaymentschedule.Ceiling_Price__c != null && temppaymentschedule.Ceiling_Price__c != undefined && !isNaN(temppaymentschedule.Ceiling_Price__c)) {
                temppaymentschedule.mandCper = true;
                temppaymentschedule.Ceiling_Period__c = temppaymentschedule.Billing_Frequency__c;
            }
            else {
                temppaymentschedule.mandCper = false;
                temppaymentschedule.Ceiling_Period__c = '';
            }
        }
        else if (event.target.name == 'billfreq') {
            temppaymentschedule.Billing_Frequency__c = event.target.value;
            this.ShowPsTable = true;
            this.handleResetFrequency(event.target.value);
        }
        else if (event.target.name == 'billingpred') {

            var diffindays = this.calculateDateDifference(this.paymentschedule.validity_start_Date__c, this.paymentschedule.validity_End_Date__c);
            if (parseInt(event.target.value) > diffindays) {
                this.showToastMessage('error', 'Billing Frequency Cannot be greater than differnce of validity Dates!', 'Error!');
                temppaymentschedule.Billing_Period__c = '';
                window.alert('Billing Frequency Cannot be greater than differnce of validity Dates!');
            }
            else {
                temppaymentschedule.Billing_Period__c = event.target.value;
            }

        }
        this.paymentschedule = { ...temppaymentschedule };
    }

    calculateDateDifference(startDate, endDate) {
        if (startDate && endDate) {
            const startDateObj = new Date(startDate);
            const endDateObj = new Date(endDate);

            // Calculate the difference in milliseconds
            const dateDifferenceInMs = endDateObj - startDateObj;

            // Calculate the difference in days
            const dateDifferenceInDays = dateDifferenceInMs / (1000 * 60 * 60 * 24);

            return dateDifferenceInDays;
        } else {
            this.resultMessage = 'Please enter both start and end dates.';
        }
    }

    compareDates(startDate, endDate) {
        debugger
        if (startDate && endDate) {
            const date1Obj = new Date(startDate);
            const date2Obj = new Date(endDate);
            var msg = false;
            if (date1Obj < date2Obj) {
                //this.comparisonResult = 'Date 1 is earlier than Date 2.';
            } else if (date1Obj > date2Obj) {
                msg = true;
            } else {
                //this.comparisonResult = 'Date 1 is equal to Date 2.';
            }
            return msg;
        } else {
            return msg = false;
            //this.comparisonResult = 'Please enter both dates.';
        }
    }
    SubmitpsRecord(event) {
        this.isSpinner = true;
        var temppaymentschedule = {...this.paymentschedule};
        delete temppaymentschedule.disableBF;
        delete temppaymentschedule.disableCP;
        delete temppaymentschedule.disableCper;
        delete temppaymentschedule.disableFP;
        delete temppaymentschedule.disableFper;
        delete temppaymentschedule.disableMBP;
        delete temppaymentschedule.disableMRP;
        delete temppaymentschedule.disableVED;
        delete temppaymentschedule.disableVSD;
        delete temppaymentschedule.mandCper;
        delete temppaymentschedule.mandFper;
        temppaymentschedule.task_Id__c = this.recId
        debugger;
        Submitpaymentschedule({ PsRecord: temppaymentschedule })
            .then(result => {
                debugger;
                this.PsrecId = result.Id;
                this.ShowPsTable = true;
                this.isSpinner = false;
                if (result) {
                    this.SubmitpsResetFreqRecord(this.PriceStructLIst);
                }

            })
            .catch(error => {

                this.processErrorMessage(error);
                this.isSpinner = false;
            });
    }

    pstablefieldChangeHandler(event) {
        debugger;
        const index = event.currentTarget.dataset.rowindex;
        //const property = event.target.label.toLowerCase();
        var TempPriceStructLIst = [...this.PriceStructLIst];

        if (event.target.name == 'pstype') {
            TempPriceStructLIst[index].Price_Structure_Type__c = event.target.value;
            TempPriceStructLIst[index].disablepstype = true;
            this.handlePSType(event.target.value);
            if (event.target.value == 'Flat' || event.target.value == 'Fixed') {
                TempPriceStructLIst[index].disablestartval = true;
                TempPriceStructLIst[index].disableendval = true;
                TempPriceStructLIst[index].Start_Value__c = parseInt('1');
                TempPriceStructLIst[index].End_Value__c = parseInt('NA');
                TempPriceStructLIst[index].showRemoveSlabRowBtn = false;
                TempPriceStructLIst[index].showRemoveRowBtn = true;
                TempPriceStructLIst[index].shownumbervalue = false;
                TempPriceStructLIst[index].showtextvalue = true;
                TempPriceStructLIst[index].disablePsResetFreq = true;
                //TempPriceStructLIst[index].Price_Structure_Reset_Frequency__c = this.paymentschedule.Billing_Frequency__c;

            }
            if (event.target.value == 'Slab') {
                TempPriceStructLIst[index].disablestartval = true;
                TempPriceStructLIst[index].disableendval = false;
                TempPriceStructLIst[index].Start_Value__c = parseInt('1');
                TempPriceStructLIst[index].showaddSlabRowBtn = true;
                TempPriceStructLIst[index].showAddSlabBtn = true;
                TempPriceStructLIst[index].showRemoveSlabRowBtn = true;
                TempPriceStructLIst[index].showRemoveRowBtn = false;
                TempPriceStructLIst[index].shownumbervalue = true;
                TempPriceStructLIst[index].showtextvalue = false;
            }

        }
        else if (event.target.name == 'psresetfreq') {
            TempPriceStructLIst[index].Price_Structure_Reset_Frequency__c = event.target.value;
        }
        else if (event.target.name == 'psrate') {
            TempPriceStructLIst[index].Rate__c = event.target.value;
        }
        else if (event.target.name == 'psStarteVal') {
            TempPriceStructLIst[index].Start_Value__c = parseInt(event.target.value);
        }
        else if (event.target.name == 'psEndVal') {
            TempPriceStructLIst[index].End_Value__c = parseInt(event.target.value);
            this.handleKeyUpAddSlabRow(parseInt(event.target.value), event.currentTarget.dataset.rowindex);
        }

    }

    handleResetFrequency(selectedResetFreq) {
        debugger;
        var tempBillFreqforPriceStructureValidate = [];
        const foundItem = this.BillFreqforPriceStructureValidation.find(item => item.value === selectedResetFreq);
        for (var i = 0; i < parseInt(foundItem.id); i++) {
            tempBillFreqforPriceStructureValidate.push(this.billfrequencylist[i]);
        }
        this.actualBillFreqForPSValidate = [...tempBillFreqforPriceStructureValidate];

        if (this.PsTypeList.length > 0) {
            this.handleAllPriceStructureDetails();
        }
    }

    handleAllPriceStructureDetails() {

        var tempPriceStructLIst = JSON.parse(JSON.stringify(this.PriceStructLIst));
        for (let i = 0; i < tempPriceStructLIst.length; i++) {
            tempPriceStructLIst[i].Price_Structure_Reset_Frequency__c = '';
            tempPriceStructLIst[i].PriceStructureResetFreqList = this.actualBillFreqForPSValidate;
        }

        this.PriceStructLIst = [...tempPriceStructLIst];

    }

    @track disableaddbtn = false;

    handleShowExistingPriceStructureData(tempPriceStructLIst) {
        debugger;

        this.PriceStructLIst = tempPriceStructLIst.map(item => {
            if (this.IsEdit) {
                if (item.Price_Structure_Type__c == 'Fixed' || item.Price_Structure_Type__c == 'Flat') {
                    return {
                        ...item,
                        showpstype: true,
                        showpsresetFeq: true,
                        disablepstype: true,
                        disablePsResetFreq: true,
                        disableRate: false,
                        disablestartval: true,
                        showtextvalue: true,
                        disableendval: true,
                        showRemoveRowBtn: true,
                        disableRemoveSlabbtn: false,
                        disableRemovebtn: false,
                        PriceStructureTypelist: this.globalpstypelist,
                        PriceStructureResetFreqList: this.actualBillFreqForPSValidate,
                        cssClass: 'slds-hint-parent'

                    }
                }
                else if (item.Price_Structure_Type__c == 'Slab') {
                    return {
                        ...item,
                        showpstype: true,
                        showpsresetFeq: true,
                        disablepstype: true,
                        disablePsResetFreq: false,
                        disableRate: false,
                        disablestartval: true,
                        shownumbervalue: true,
                        disableendval: false,
                        showRemoveRowBtn: true,
                        disableRemoveSlabbtn: false,
                        disableRemovebtn: false,
                        PriceStructureTypelist: this.globalpstypelist,
                        PriceStructureResetFreqList: this.actualBillFreqForPSValidate,
                        cssClass: 'slds-hint-parent'
                    }
                }

            }
            else if (this.IsEdit == false) {
                if (item.Price_Structure_Type__c == 'Fixed' || item.Price_Structure_Type__c == 'Flat') {
                    return {
                        ...item,
                        showpstype: true,
                        showpsresetFeq: true,
                        disablepstype: true,
                        disablePsResetFreq: true,
                        disableRate: true,
                        disablestartval: true,
                        showtextvalue: true,
                        disableendval: true,
                        showRemoveRowBtn: true,
                        disableRemoveSlabbtn: true,
                        disableRemovebtn: true,
                        PriceStructureTypelist: this.globalpstypelist,
                        PriceStructureResetFreqList: this.actualBillFreqForPSValidate,
                        cssClass: 'slds-hint-parent'
                    }
                }
                else if (item.Price_Structure_Type__c == 'Slab') {
                    return {
                        ...item,
                        showpstype: true,
                        showpsresetFeq: true,
                        disablepstype: true,
                        disablePsResetFreq: true,
                        disableRate: true,
                        disablestartval: true,
                        shownumbervalue: true,
                        disableendval: true,
                        showRemoveRowBtn: true,
                        disableRemoveSlabbtn: true,
                        disableRemovebtn: true,
                        PriceStructureTypelist: this.globalpstypelist,
                        PriceStructureResetFreqList: this.actualBillFreqForPSValidate,
                        cssClass: 'slds-hint-parent'
                    }
                }

            }

        });
        if (this.IsEdit == false) {
            this.disableaddbtn = true;
            
        }

        if (this.PriceStructLIst.length > 0) {
            this.ShowPsTable = true;
        }
    }

    handlePSType() {
        debugger;
        var temppstypelist = [...this.globalpstypelist];
        for (var i = 0; i < this.PriceStructLIst.length; i++) {
            if ((JSON.stringify(temppstypelist)).includes(this.PriceStructLIst[i].Price_Structure_Type__c)) {
                temppstypelist = temppstypelist.filter(item => item.value == this.PriceStructLIst[i].Price_Structure_Type__c);
            }
        }

        this.PriceStructureTypelist = [];
        this.PriceStructureTypelist.push(temppstypelist);
    }

    handleAddRow() {
        debugger;
        var tempPsTypeList = [];

        var tempPriceStructLIst = [];
        this.handlePSType();
        if (this.PriceStructLIst.length > 0) {
            tempPriceStructLIst = [...this.PriceStructLIst];
        }

        if (this.PriceStructLIst.length == 0) {
            let objRow = {
                Payment_Schedule__c: this.PsrecId,
                Price_Structure_Type__c: '',
                Price_Structure_Reset_Frequency__c: '',
                Rate__c: '',
                Start_Value__c: '',
                End_Value__c: '',
                PriceStructureTypelist: this.PsTypeList,//newtempPsTypeList != null ? newtempPsTypeList : this.PsTypeList
                PriceStructureResetFreqList: this.actualBillFreqForPSValidate,
                disablepstype: false,
                disablePsResetFreq: false,
                disablestartval: true,
                disableendval: true,
                showpsresetFeq: true,
                showpstype: true,
                showaddSlabRowBtn: false,
                showRemoveRowBtn: true,
                shownumbervalue: false,
                showtextvalue: true,
                disableRemoveSlabbtn: false,
                disableRemovebtn: false,
                cssClass: 'slds-hint-parent'

            }
            if (this.PriceStructLIst != undefined) {
                if (this.PriceStructLIst.length > 0) {
                    if ((this.PriceStructLIst[this.PriceStructLIst.length - 1].Price_Structure_Type__c == '' || this.PriceStructLIst[this.PriceStructLIst.length - 1].Price_Structure_Type__c == null || this.PriceStructLIst[this.PriceStructLIst.length - 1].Price_Structure_Type__c == undefined) && (this.PriceStructLIst[this.PriceStructLIst.length - 1].End_Value__c == null || this.PriceStructLIst[this.PriceStructLIst.length - 1].End_Value__c == undefined || this.PriceStructLIst[this.PriceStructLIst.length - 1].End_Value__c == '')) {
                        this.showToastMessage('Error', 'Please provide Previous Slab End value', 'Error!');
                        window.alert('Please Previous Slab End value');
                        return;
                    }
                    else {
                        tempPriceStructLIst.push(objRow);
                    }
                }
                else {
                    tempPriceStructLIst.push(objRow);
                }
            }
            else {
                tempPriceStructLIst.push(objRow);
            }

            this.PriceStructLIst = [...tempPriceStructLIst];
            if (this.PriceStructLIst.length == 1) {
                this.disableaddbtn = true;
            }
        }
    }

    handleKeyUpAddSlabRow(slabendValue, currentIndex) {
        debugger;

        var tempPriceStructithIndex = this.PriceStructLIst[parseInt(currentIndex) + 1];
        debugger;
        if ((slabendValue != null && tempPriceStructithIndex == undefined) || (slabendValue != null && tempPriceStructithIndex != undefined && tempPriceStructithIndex.Price_Structure_Type__c !== 'Slab')) {
            if (slabendValue > this.PriceStructLIst[parseInt(currentIndex)].Start_Value__c) {
                let objRow = {
                    Payment_Schedule__c: this.PsrecId,
                    Price_Structure_Type__c: 'Slab',
                    Price_Structure_Reset_Frequency__c: '',
                    Rate__c: '',
                    Start_Value__c: '',
                    End_Value__c: '',
                    PriceStructureTypelist: this.PsTypeList,
                    PriceStructureResetFreqList: this.actualBillFreqForPSValidate,
                    disablepstype: false,
                    disablePsResetFreq: false,
                    disablestartval: true,
                    disableendval: false,
                    showpsresetFeq: false,
                    showpstype: false,
                    showaddSlabRowBtn: false,
                    showRemoveSlabRowBtn: false,
                    showRemoveRowBtn: true,
                    shownumbervalue: true,
                    showtextvalue: false,
                    disableRemoveSlabbtn: false,
                    disableRemovebtn: false,
                    cssClass: 'slds-hint-parent'
                }
                //var currentIndex = event.currentTarget.dataset.rowindex;
                var indexToAdd = parseInt(currentIndex);
                this.addRowAtIndex(indexToAdd, objRow);

            }
            else if (slabendValue < this.PriceStructLIst[parseInt(currentIndex)].Start_Value__c) {
                this.handleAutoRemoveRow(currentIndex);
            }


        }
        else if (isNaN(slabendValue) && tempPriceStructithIndex != undefined) {
            this.handleAutoRemoveRow(currentIndex);
        }
        else if (slabendValue != null && tempPriceStructithIndex != undefined && tempPriceStructithIndex.Price_Structure_Type__c === 'Slab') {
            this.PriceStructLIst[parseInt(currentIndex) + 1].Start_Value__c = slabendValue + 1;
            if (slabendValue < this.PriceStructLIst[parseInt(currentIndex)].Start_Value__c) {
                this.handleAutoRemoveRow(currentIndex);
            }
        }
    }

    handleAutoRemoveRow(currentIndex) {
        var tempPriceStructLIst = JSON.parse(JSON.stringify(this.PriceStructLIst));
        tempPriceStructLIst = tempPriceStructLIst.filter((item, index) => index !== parseInt(currentIndex) + 1);
        this.PriceStructLIst = [...tempPriceStructLIst];
    }

    addRowAtIndex(index, objRow) {
        var tempPriceStructLIst = [...this.PriceStructLIst];

        if (this.PriceStructLIst.length > 0) {
            if (this.PriceStructLIst[index].Price_Structure_Type__c == 'Slab') {
                objRow.showpsresetFeq = false;
                objRow.showpstype = false;
                objRow.Start_Value__c = this.PriceStructLIst[index].End_Value__c + 1;
                objRow.Price_Structure_Type__c = this.PriceStructLIst[index].Price_Structure_Type__c;
                objRow.Price_Structure_Reset_Frequency__c = this.PriceStructLIst[index].Price_Structure_Reset_Frequency__c;
                objRow.disableendval = this.PriceStructLIst[index].disableendval;
                tempPriceStructLIst[index].showAddSlabBtn = false;
            }

        }
        if (this.PriceStructLIst.length > 0) {
            if (this.PriceStructLIst[index].Price_Structure_Type__c != '' && this.PriceStructLIst[index].Price_Structure_Type__c != null && this.PriceStructLIst[index].Price_Structure_Type__c != undefined) {
                if (this.PriceStructLIst[index].Price_Structure_Type__c == 'Slab' && (this.PriceStructLIst[index].End_Value__c == null || this.PriceStructLIst[index].End_Value__c == undefined || this.PriceStructLIst[index].End_Value__c == '')) {
                    this.showToastMessage('Error', 'Please provide Previous Slab End value', 'Error!');
                    window.alert('Please Previous Slab End value');
                    return;
                }
                else if (this.PriceStructLIst[index].Price_Structure_Type__c == 'Slab') {
                    tempPriceStructLIst.splice(index + 1, 0, objRow);
                }
            }
            else {
                this.showToastMessage('Error', 'Please Previous Price structure Type!', 'Error!');
                window.alert('Please Previous Price structure Type!');
            }

        }
        this.PriceStructLIst = [...tempPriceStructLIst];
    }

    handleRemoveRow(event) {
        debugger;

        const index = parseInt(event.currentTarget.dataset.rowindex, 10);
        this.PriceStructLIst = this.PriceStructLIst.filter((row, i) => i !== index);
        var NewtempPriceStructLIst = [];
        var tempPriceStructLIst = JSON.parse(JSON.stringify(this.PriceStructLIst));
        //var tempPriceStructLIst = [...this.PriceStructLIst];
        for (var i = 0; i < tempPriceStructLIst.length; i++) {
            if (tempPriceStructLIst[i].Price_Structure_Type__c == 'Slab') {
                if (tempPriceStructLIst[i - 1] != undefined && tempPriceStructLIst[i - 1].Price_Structure_Type__c == 'Slab') {
                    tempPriceStructLIst[i].Start_Value__c = tempPriceStructLIst[i - 1].End_Value__c + 1;
                    //tempPriceStructLIst[i].End_Value__c = null;
                    tempPriceStructLIst[i].disableendval = false;
                    tempPriceStructLIst[i].showpstype = false;
                    tempPriceStructLIst[i].showpsresetFeq = false;
                    NewtempPriceStructLIst.push(tempPriceStructLIst[i]);
                }
                else {
                    NewtempPriceStructLIst.push(tempPriceStructLIst[i]);
                }
            } else {
                NewtempPriceStructLIst.push(tempPriceStructLIst[i]);
            }
        }
        this.PriceStructLIst = NewtempPriceStructLIst;
        if(this.PriceStructLIst.length == 0){
            this.disableaddbtn = false;
        }
    }

    handleSlabRemoveRow(event) {
        var tempPriceStructLIst = JSON.parse(JSON.stringify(this.PriceStructLIst));
        var NewtempPriceStructLIst = [];
        for (var i = 0; i < tempPriceStructLIst.length; i++) {
            if (tempPriceStructLIst[i].Price_Structure_Type__c != 'Slab') {
                NewtempPriceStructLIst.push(tempPriceStructLIst[i]);
            }
        }
        this.PriceStructLIst = [...NewtempPriceStructLIst];
        if(this.PriceStructLIst.length == 0){
            this.disableaddbtn = false;
        }
    }

    showToastMessage(variant, message, title) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    processErrorMessage(message) {
        debugger;
        let errorMsg = '';
        if (message) {
            if (message.body) {
                if (Array.isArray(message.body)) {
                    errorMsg = message.body.map(e => e.message).join(', ');
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

    disablesubmitPriceStructurebtn = false;
    SubmitpsResetFreqRecord(pricestructure_list_array) {
        debugger;
        this.disablesubmitPriceStructurebtn = true;
        let newtempPriceStructListforapex = [];
        const actualtemppriceStructure = JSON.parse(JSON.stringify(this.PriceStructLIst)); //[...pricestructure_list_array];
        for (let i = 0; i < actualtemppriceStructure.length; i++) {
            let tempPriceStrucrec = actualtemppriceStructure[i];
            delete tempPriceStrucrec.PriceStructureTypelist;
            delete tempPriceStrucrec.PriceStructureResetFreqList;
            delete tempPriceStrucrec.disablepstype;
            delete tempPriceStrucrec.disablePsResetFreq;
            delete tempPriceStrucrec.disablestartval;
            delete tempPriceStrucrec.disableendval;
            delete tempPriceStrucrec.showpsresetFeq;
            delete tempPriceStrucrec.showpstype;
            delete tempPriceStrucrec.showpsresetFeq;
            delete tempPriceStrucrec.shownumbervalue;
            delete tempPriceStrucrec.showtextvalue;
            delete tempPriceStrucrec.showRemoveRowBtn;
            delete tempPriceStrucrec.showRemoveSlabRowBtn;
            delete tempPriceStrucrec.showaddSlabRowBtn;

            if (tempPriceStrucrec.Payment_Schedule__c == undefined || tempPriceStrucrec.Payment_Schedule__c == null) {
                tempPriceStrucrec.Payment_Schedule__c = this.PsrecId;
            }
            if (isNaN(tempPriceStrucrec.End_Value__c)) {
                //delete tempPriceStrucrec[i].End_Value__c;
                tempPriceStrucrec.End_Value__c = null;
            }
            if (tempPriceStrucrec.disableRate != null) {
                delete tempPriceStrucrec.disableRate;
            }
            if (tempPriceStrucrec.showAddSlabBtn != null && tempPriceStrucrec.showAddSlabBtn != undefined) {
                delete tempPriceStrucrec.showAddSlabBtn;
            }


            newtempPriceStructListforapex.push(tempPriceStrucrec)

        }
        this.isSpinner = true;


        SubmitPriceStructure({ PSRecord: newtempPriceStructListforapex })
            .then(result => {
                debugger;
                this.PsrecId = result;
                this.diablePSFields = true;
                this.ShowPsTable = true;
                this.isSpinner = false;
                this.sendMessageToParent();
            })
            .catch(error => {
                console.error('Error calling Apex method: ', error);
                this.processErrorMessage(error);
                this.isSpinner = false;
            });

    }

    @api
    finalvalidation() {
        // =========================== Recall all the validation of all the previous method in this LWC ==========
        // ===================== set IsClose = true which need to be send to Parent ============================
        /* if parent task close status = true or Null/undefined, then call the final submit method.*/
        debugger;
        var errorMsg = '';
        if (this.paymentschedule.validity_End_Date__c == null || this.paymentschedule.validity_End_Date__c == undefined || this.paymentschedule.validity_start_Date__c == null || this.paymentschedule.validity_start_Date__c == undefined) {
            errorMsg = 'Either Validity start date or End Date is Null. Please fill the value'
            this.showToastMessage('error', errorMsg, 'Error!');
            return;
        }
        if (this.compareDates(this.paymentschedule.validity_start_Date__c, this.paymentschedule.validity_End_Date__c)) {
            errorMsg = 'Either Validity start date cannot be greater than End Date!'
            this.showToastMessage('error', errorMsg, 'Error!');
            return;
        }
        if (this.paymentschedule.Floor_Price__c != null && (this.paymentschedule.Floor_Period__c == null || this.paymentschedule.Floor_Period__c == '' || this.paymentschedule.Floor_Period__c == undefined)) {
            errorMsg = 'If Floor Price is not null, then Floor period cannot be Null';
            this.showToastMessage('error', errorMsg, 'Error!');
            return;
        }
        if (this.paymentschedule.Ceiling_Price__c != null && (this.paymentschedule.Ceiling_Period__c == null || this.paymentschedule.Ceiling_Period__c == '' || this.paymentschedule.Ceiling_Period__c == undefined)) {
            errorMsg = 'If Celing Price is not null, then Celing period cannot be Null';
            this.showToastMessage('error', errorMsg, 'Error!');
            return;
        }       

        if (this.PriceStructLIst.length == 0) {
            errorMsg = 'Price Structure List cannot be null'
            this.showToastMessage('error', errorMsg, 'Error!');
            return;
        }
        var addcolorIndexList = [];
        if (this.PriceStructLIst.length > 0) {
            var j = 0;
            for (let i = 0; i < this.PriceStructLIst.length; i++) {

                if ((this.PriceStructLIst[i].Start_Value__c == '' || this.PriceStructLIst[i].Start_Value__c == null || this.PriceStructLIst[i].Start_Value__c == undefined || this.PriceStructLIst[i].End_Value__c == '' || isNaN(this.PriceStructLIst[i].End_Value__c) || this.PriceStructLIst[i].End_Value__c == null || this.PriceStructLIst[i].End_Value__c == undefined) && this.PriceStructLIst[i].Price_Structure_Type__c == 'Slab' && j != this.PriceStructLIst.length-1) {
                    errorMsg = 'Start Value or End Value cannot be null in Price Structure List'
                    this.showToastMessage('error', errorMsg, 'Error!');
                    addcolorIndexList.push(i);
                    return;
                }
                if ((this.PriceStructLIst[i].Start_Value__c != null && this.PriceStructLIst[i].Start_Value__c != undefined && this.PriceStructLIst[i].End_Value__c != null && this.PriceStructLIst[i].End_Value__c != undefined) && this.PriceStructLIst[i].Start_Value__c > this.PriceStructLIst[i].End_Value__c ) {
                    if (this.PriceStructLIst[i].Price_Structure_Type__c == 'Slab' && j != this.PriceStructLIst.length-1) {
                        
                    }
                    else if(this.PriceStructLIst[i].Price_Structure_Type__c == 'Fixed' || this.PriceStructLIst[i].Price_Structure_Type__c == 'Flat' ){
                        errorMsg = 'End Value should be greater than Start Value in Price Structure List'
                        this.showToastMessage('error', errorMsg, 'Error!');
                        addcolorIndexList.push(i);
                    }
                    
                    
                }
                if (this.PriceStructLIst[i].Rate__c == null || this.PriceStructLIst[i].Rate__c == undefined || this.PriceStructLIst[i].Rate__c == '') {
                    errorMsg = 'Price Structure List Rate cannot be null'
                    this.showToastMessage('error', errorMsg, 'Error!');
                    addcolorIndexList.push(i);
                }
                j++;
            }
            
        }
        if (addcolorIndexList.length > 0) {
            this.addColortoPriceStructLIst(addcolorIndexList);
            return;
        }

        this.SubmitpsRecord();

    }

    addColortoPriceStructLIst(indexlist) {
        debugger;
        if (indexlist.length > 0) {
            this.PriceStructLIst.forEach((currentItem, index) => {
                if (currentItem) {
                    if (indexlist.includes(index)) {
                        currentItem.cssClass = 'trclass';
                        //pendingApproval.push(currentItem);
                    }
                    else {
                        currentItem.cssClass = 'slds-hint-parent';
                    }
                }
            });
        }
    }

    sendMessageToParent() {

        const event = new CustomEvent('lwceventpaymentschedule', {
            detail: {
                Isclose: true,
                Index: this.Index
            }
        });
        this.dispatchEvent(event);
    }
}