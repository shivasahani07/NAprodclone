/* eslint-disable no-empty */
/* eslint-disable no-debugger */
import {
    LightningElement,
    api,
    wire,
    track
} from "lwc";
import getRelatedContactAccount from "@salesforce/apex/PayableDetailsController.getRelatedContactAccount";
import verifyExistingRecord from "@salesforce/apex/PayableDetailsController.verifyExistingRecord";
import upsertSObject from "@salesforce/apex/PayableDetailsController.uppesertSobject";
import dynamicRecordDeletion from "@salesforce/apex/DynamicRecordDeletion.deleteRecords";
import createTask from "@salesforce/apex/PayableDetailsController.createTask";
import getIFSCDetails from "@salesforce/apex/IFSCService.getIFSCDetails";
import Financial_Entity_Disburse_Amount_Validation from '@salesforce/label/c.Financial_Entity_Disburse_Amount_Validation';
import {
    refreshApex
} from '@salesforce/apex';
import createAccountContactDetailsOnBehalofPayeeNumber from "@salesforce/apex/PayableDetailsController.createAccountContactDetailsOnBehalofPayeeNumber";
import {
    ShowToastEvent
} from "lightning/platformShowToastEvent";

export default class Lwc_financial_handler extends LightningElement {
    @api financialAccoundId;
    @api recordType;
    @api currentPayeId;
    @api taskId = "00TBl000002NKWSMA4";
    @track payeeList = [];
    @track payeeAcdetailsList = [];
    @track EntityTypePicklist;
    @track payMentverificationTypePicklist;
    @track accountTypePicklist;
    @track isShowPayeeComp = false;
    @track isShowPayeeACdetailComp;
    @track relatedContacts = [];
    @track relatedAccount = [];
    @track relatedFianancialEntity = [];
    @track relatedFianancialEntityAccountDetails = [];
    @track relatedFinancialMap;
    @track disabledAddRow = false;
    @track AddNewPayeeRowDisable = false;
    @track accountListExistsByphoneORemail = [];
    @track contactListExistsByphoneORemail = [];
    @track isBlockAllOtherEdit = false;
    @track ifscDetails;
    @track isShowIfsc;
    @track lastIFSCveirfiedIndex;
    @track wrapperresult;
    @track isDisabledSubmitButton = true;
    @track isShowMODTCOMP = false;
    @api currentBankDetailsRecordId;
    @track currentTobeUpdateBankdetailsId;
    @track currentTobeUpdateBankdetailsindex
    @track currentTobeUpdateBankdetailsValue;
    @track loaded = false;
    @track isShowConfirmationComp = false;
    @api confirmationVariant = 'success'
    @track isResponsePositive = false;
    @api isTaskOwnerLogin;

    connectedCallback() {
        this.configureObjectType();
    }

    @wire(getRelatedContactAccount, {
        financialAccountId: "$financialAccoundId"
    })
    wiredData(result) {
        this.wrapperresult = result;
        debugger;
        if (result.data) {
            this.prepareData(result.data);
            console.log("Data", result.data);
        } else if (result.error) {
            console.error("Error:", result.error);
        }
    }

    refreshData() {
        debugger;
        return refreshApex(this.wrapperresult);
    }

    hardRefresh() {
        window.location.reload;
    }

    prepareData(data) {
        debugger;
        // Mapping entity types
        this.isDisabledSubmitButton = false;
        this.EntityTypePicklist = data.entityTypesValue.map((value) => ({
            label: value,
            value
        }));

        // Mapping payment verification types
        this.payMentverificationTypePicklist = data.verificationTypesValue.map(
            (value) => ({
                label: value,
                value
            })
        );

        this.accountTypePicklist=data.accountTypePicklist.map(
          (value) => ({
                label: value,
                value
            })
        );

        // Mapping related financial entities to a map for easy access
        this.relatedFinancialMap = data.relatedFinancialEntity.map((value) => ({
            label: value.Name,
            value: value.Id
        }));
        this.relatedFianancialEntity = data.relatedFinancialEntity;

        // Mapping existing payee list
        this.payeeList = this.prepareFinancialEntityData(
            data.relatedFinancialEntity
        );
        // Mapping existing payee AC details list
        this.payeeAcdetailsList = this.prepareFinancialEntityACData(
            data.EntityACDetailsList
        );
    }

    prepareFinancialEntityData(relatedFinancialEntity) {
        debugger;
        let newExixtingPayee = relatedFinancialEntity.map((entity, i) => {
            const account = entity.Account_Name__r || {};
            return {
                id: entity.Id,
                index: i,
                email: account.Email_Id__c || null,
                name: entity.Name,
                phone: account.Phone || null,
                typePiclist: this.EntityTypePicklist,
                type: entity.Entity_Type__c,
                Task_ID__c: entity.Task_ID__c,
                disbursedAmount: entity.Amount_Disbursed__c,
                toBeDisbursedAmount: entity.Amount_To_Be_Disbursed__c,
                isEditable: false,
                isEditableDisabled:true,
                isDisabledDeleteButton: true,
                isEditbleButtonOn: entity.Task_ID__c !== this.taskId,
                Account_Name__c:account.Id,
                isShowEditableButton:true,
                isShowEditableButtonDisabled:entity.Task_ID__c !== this.taskId
                
            };
        });
        this.AddNewPayeeRowDisable = false;
        return newExixtingPayee;
    }

    prepareFinancialEntityACData(EntityACDetailsList) {
        debugger;
        let newExixtingPayeeAC = EntityACDetailsList.map((detail, i) => {
            const account = detail.Financial_Entity__r || {};
            const isPhysicallyVerificationRequired =
                detail.Verification_Status__c === "Failed" ||!detail.Bank_Account_Number__c;
            const isShowViewDocument = detail.Verification_Status__c == "Verified";
            const isSendableForPennyDropVerification =
                detail.Verification_Status__c === "New" && detail.Bank_Account_Number__c;
            return {
                id: detail.Id,
                index: i,
                // name: detail.Name,
                // payeeName: account.Name,
                bankNumber: detail.Bank_Account_Number__c,
                branchName: detail.Branch_Name__c,
                IFSC: detail.IFSC_Code__c,
                selectedPayeeId: account.Id,
                bankName: detail.Bank_Name__c,
                Verification_Status__c: detail.Verification_Status__c,
                newPayeeIdPicList: this.relatedFinancialMap,
                verificationTypePiclist: this.payMentverificationTypePicklist,
                verificationType: detail.Digitally_Verification_Method__c,
                Task_ID__c: detail.Task_ID__c,
                isEditable: detail.Task_ID__c === this.taskId,
                isEditableDisabled: true,
                isDisabledAccountVerifyType:detail.Task_ID__c === this.taskId,
                isEditbleButtonOn: detail.Task_ID__c !== this.taskId,
                isDisabledVerifyButton: true,
                isPhysicallyVerificationRequired: false,
                isShowPhycalyVerifyButton: false,
                bankAccountName: detail.Name,
                isDisabledDeleteButton: true,
                isPhysicallyVerificationRequiredDisabled: !isPhysicallyVerificationRequired,
                isSendableForPennyDropVerification: isSendableForPennyDropVerification,
                isDisabledPayeeNameEdit: account.Id !== undefined,
                isShowUpdateGreenButton: false,
                isPayeeNameChanged: false,
                isRedRow: 'green',
                isDocumentUploaded: false,
                Physically_verified__c: detail.Physically_verified__c,
                Bank_AccountTypePicklist:this.accountTypePicklist,
                Bank_Account_Type__c:detail.Bank_Account_Type__c,
            };
        });
        this.disabledAddRow = false;
        return newExixtingPayeeAC;
    }

    configureObjectType() {
        debugger;
        if (this.recordType == "newpayee") {
            this.isShowPayeeComp = true;
        } else if (this.recordType == "newacdetails") {
            this.isShowPayeeACdetailComp = true;
        }
    }

    editPayeeButton(event){
        debugger
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        this.enabledEditingPayee(currentIndex);

    }
   

    handleInputChange(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        const minPhoneLength = 10;
        const minEmailLength = 5;

        if (eventName == "type") {
            this.selectTypeChangeHandler(event);
        } else if (eventName == "phone") {
            if (inputValue.length >= minPhoneLength) {
                this.selectEmailChangeHandler(event);
            }
        } else if (eventName == "email") {
            if (inputValue.length >= minEmailLength) {
                this.selectEmailChangeHandler(event);
            }
        } else if (eventName == "name") {
            this.selectNameChangehandler(event);
        } else if (eventName == "Amount_to_be_disbursed") {
            this.ToBedisbursedAmountChangeHandler(event);
        } else if (eventName == "disbursed_Amount") {
            this.disbursedAmountChangeHandler(event);
        } else {}
    }

    selectNameChangehandler(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        this.payeeList[parseInt(currentIndex)].name = inputValue;
    }

    selectEmailChangeHandler(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        if (this.checkCompoLevelDuplicaton(inputValue, this.payeeList, eventName)) {
            this.verifyExistingRecordFromBackend(inputValue, currentIndex);
            if (eventName == "email") {
                this.payeeList[parseInt(currentIndex)].email = inputValue;
            } else if (eventName == "phone") {
                this.payeeList[parseInt(currentIndex)].phone = inputValue;
            }
        } else {}
    }
    payMentverificationTypePicklistm(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        this.payeeAcdetailsList[parseInt(currentIndex)].verificationType =inputValue;
        
    }

    checkCompoLevelDuplicaton(currentValue, dataList, field) {
        debugger;
        for (let i = 0; i < dataList.length; i++) {
            if (dataList[i][field] == currentValue) {
                this.showToast("Duplicate value found", "details missing", "error");
                // alert("Duplicate value found");
                return false; // Duplicate found, so return false
            }
        }
        return true; // No duplicates found, return true
    }

    handleDeleteAction(event) {
        debugger;
        let recordIdsTobeDeleted = [];
        let currentIndex = event.target.dataset.index;
        let recordId = event.target.dataset.id;
        this.DeletePayeeRow(currentIndex);
        if (recordId) {
            recordIdsTobeDeleted.push(recordId);
            this.dynamicallyRecordsDeletion(recordIdsTobeDeleted);
        }
        this.AddNewPayeeRowDisable = false;
    }

    DeletePayeeRow(index) {
        debugger;
        let parseIndex = parseInt(index);
        this.payeeList.splice(parseIndex, 1);

        this.payeeList = [...this.payeeList]; // Ensure reactivity
    }

    // new methods for custom comp

    AddNewPayeeRow() {
        debugger;
        let tempPayeeObjectList = [];
        let index = this.payeeList.length;
        let tempPayeeObject = {
            index: index,
            email: "",
            phone: "",
            name: "",
            typePiclist: this.EntityTypePicklist,
            type: "",
            isEditable: true,
            isEditableDisabled: false,
            disbursedAmount: 0,
            toBeDisbursedAmount: "",
            isDisabledDeleteButton: false,
            Financial_Account__c: this.financialAccoundId,
            Task_ID__c: this.taskId,
            Account_Name__c:'',
        };
        tempPayeeObjectList = [...this.payeeList, tempPayeeObject];
        this.payeeList = tempPayeeObjectList;
        this.AddNewPayeeRowDisable = true;
    }

    AddNewPayeeRowAcDet() {
        debugger;
        let temppayeeAcdetailObjectList = [];
        let index = this.payeeAcdetailsList.length;
        let temppayeeAcdetailObject = {
            index: index,
            isEditable: true,
            isEditableDisabled: true,
            // name: "",
            // payeeName: "",
            bankNumber: "",
            branchName: "",
            bankName: "",
            IFSC: "",
            Verification_Status__c: "New",
            selectedPayeeId: "",
            newPayeeIdPicList: this.relatedFinancialMap,
            verificationTypePiclist: this.payMentverificationTypePicklist,
            verificationType: "",
            isPhysicallyVerificationRequiredDisabled: false,
            Task_ID__c: this.taskId,
            isDisabledDeleteButton: false,
            Financial_Account__c: this.financialAccoundId,
            isPhysicallyVerificationRequiredDisabled: true,
            isDisabledVerifyButton: true,
            isDisabledPayeeNameEdit: true,
            isShowUpdateGreenButton: true,
            isDisabledAccountVerifyType:true,
            isRedRow: 'green',
            Bank_AccountTypePicklist:this.accountTypePicklist,
            Bank_Account_Type__c:'',
            bankAccountName:'',
        };
        temppayeeAcdetailObjectList = [
            ...this.payeeAcdetailsList,
            temppayeeAcdetailObject
        ];
        this.payeeAcdetailsList = temppayeeAcdetailObjectList;
        this.disabledAddRow = true;
        // this.isBlockAllOtherEdit = true;
        this.blockAllOthersRowsforBackDetails(index);
    }

    handleDeleteActionACDetailsRow(event) {
        debugger;
        let recordIdsTobeDeleted = [];
        let currentIndex = event.target.dataset.index;
        let recordId = event.target.dataset.id;
        this.DeletePayeeRowACDetails(currentIndex);
        if (recordId) {
            recordIdsTobeDeleted.push(recordId);
            this.dynamicallyRecordsDeletion(recordIdsTobeDeleted);
        }
        this.disabledAddRow = false;
    }

    DeletePayeeRowACDetails(index) {
        debugger;
        let parseIndex = parseInt(index);
        this.payeeAcdetailsList.splice(parseIndex, 1);
        this.payeeAcdetailsList = [...this.payeeAcdetailsList];
    }

    verifyExistingRecordFromBackend(emailORphone, recordIndex) {
        debugger;
        let checkedRecordIndex = recordIndex;
        verifyExistingRecord({
                emailORphone: emailORphone
            })
            .then((response) => {
                if (response)
                    this.accountListExistsByphoneORemail = response.existingAccount;
                this.contactListExistsByphoneORemail = response.existingContact;
                if (
                    this.accountListExistsByphoneORemail ||
                    this.contactListExistsByphoneORemail
                ) {
                    console.log('response.existingAccount--->', response.existingAccount);
                    console.log('response.existingContact--->', response.existingContact);
                    this.showToast("Scuccess", "already exists please check", "success");
                    this.payeeList[parseInt(checkedRecordIndex)].name = response.existingAccount[0].Name;
                    this.payeeList[parseInt(checkedRecordIndex)].phone = response.existingAccount[0].Phone;
                    this.payeeList[parseInt(checkedRecordIndex)].email = response.existingAccount[0].Email_Id__c;
                    this.payeeList[parseInt(checkedRecordIndex)].Account_Name__c = response.existingAccount[0].Id;

                } else {}
            })
            .catch((error) => {
                this.showToast(
                    "something went wrong",
                    "Error Please try again latter",
                    "error"
                );
            });
    }

    showToast(titel, message, variant) {
        const event = new ShowToastEvent({
            title: titel,
            message: message,
            variant: variant,
            mode: "dismissable"
        });
        this.dispatchEvent(event);
    }

    handleChangePayeeRecordPicker(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        this.payeeAcdetailsList[parseInt(currentIndex)].payeeName = selectedRecord;
    }

    handleInputChangeACdetails(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let eventName = event.target.name;
        let itemValue = event.target.value;
        if (eventName == "bankNumber") {
            this.selectAcbankNumberHandler(event);
        } else if (eventName == "selectPayee") {
            this.selectAcPayeeNameHandler(event);
        } else if (eventName == "bankName") {
            this.selectAcbankNameHandler(event);
        } else if (eventName == "IFSC") {
            this.selectAcIFSCHandler(event);
        } else if (eventName == "branchName") {
            this.selectAcbranchNameHandler(event);
        } else if (eventName == "verificationType") {
            this.selectAcverificationTypeHandler(event);
        } else if (eventName == "isVerifiedPhysically") {
            this.showPhysicalVerifyButton(event);
        } else if (eventName == "selectPayeeEdit") {
            this.selectAcPayeeNameHandlerEditable(event);
        }else if(eventName=='backAccountType'){
            this.selectBackAccountTypeChangeHandler(event);
        }else if(eventName=='bankAccountName'){
            this.selectBackAccountNameChangeHandler(event);
        }
    }


    selectBackAccountNameChangeHandler(event){
      debugger;
      let currentIndex = event.target.dataset.index;
      let eventName = event.target.name;
      let inputValue = event.target.value;
      let isChecked = event.target.checked;
      this.payeeAcdetailsList[parseInt(currentIndex)].bankAccountName = inputValue;
      this.payeeAcdetailsList[parseInt(currentIndex)].Name = inputValue;

    }

    selectBackAccountTypeChangeHandler(event){
      debugger;
      let currentIndex = event.target.dataset.index;
      let eventName = event.target.name;
      let inputValue = event.target.value;
      let isChecked = event.target.checked;
      this.payeeAcdetailsList[parseInt(currentIndex)].Bank_Account_Type__c = inputValue;
      if(!this.payeeAcdetailsList[parseInt(currentIndex)].bankNumber){
          this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledAccountVerifyType =true;
      }else{
          this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledAccountVerifyType = false;
      }

    }

    showPhysicalVerifyButton(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let eventName = event.target.name;
        let inputValue = event.target.value;
        let isChecked = event.target.checked;
        if (isChecked) {
            this.payeeAcdetailsList[parseInt(currentIndex)].isShowPhycalyVerifyButton = true;
        } else {
            this.payeeAcdetailsList[parseInt(currentIndex)].isShowPhycalyVerifyButton = false;
        }
    }

    selectAcPayeeNameHandler(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let eventName = event.target.name;
        let inputValue = event.target.value;
        this.payeeAcdetailsList[parseInt(currentIndex)].selectedPayeeId = inputValue;
    }

    selectAcPayeeNameHandlerEditable(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let eventName = event.target.name;
        let inputValue = event.target.value;
        this.currentTobeUpdateBankdetailsId = event.target.dataset.id;
        this.currentTobeUpdateBankdetailsindex = currentIndex;
        this.currentTobeUpdateBankdetailsValue = inputValue;
        this.isShowConfirmationComp = true;
        // if(this.isResponsePositive){
        //   this.payeeAcdetailsList[parseInt(currentIndex)].isPayeeNameChanged = true;
        //   this.payeeAcdetailsList[parseInt(currentIndex)].selectedPayeeId = inputValue;
        //   this.submitForBankDetails(event);
        // }else{

        // }

    }

    selectAcbankNameHandler(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let eventName = event.target.name;
        let inputValue = event.target.value;
        this.payeeAcdetailsList[parseInt(currentIndex)].bankName = inputValue;
    }

    selectAcIFSCHandler(event) {
        debugger;
        const ifscRegex = /^[A-Z]{4}0[A-Z0-9]{6}$/; // Regex for IFSC code format
        let currentIndex = event.target.dataset.index;
        let eventName = event.target.name;
        let inputValue = event.target.value;
        const isValidIfsc = ifscRegex.test(inputValue);
        if (!isValidIfsc) {

        } else {

        }
        this.payeeAcdetailsList[parseInt(currentIndex)].IFSC = inputValue;
        if (inputValue.length > 10) {
            this.verifyIFSCCode(inputValue, currentIndex);
            this.reseteBankDetailsAsperIFSCcode(inputValue, currentIndex);
        }

    }

    reseteBankDetailsAsperIFSCcode(newIFSCcode, index) {
        debugger;
        if (!newIFSCcode == this.payeeAcdetailsList[parseInt(index)].IFSC) {
            this.payeeAcdetailsList[parseInt(index)].branchName = '';
            this.payeeAcdetailsList[parseInt(index)].bankName = '';
        }
    }



    selectAcbankNumberHandler(event) {
        debugger;
        let numericRegex = /^[0-9]*$/; // Regex for numeric values only
        let inputValue = event.target.value;
        let isValidInput = numericRegex.test(inputValue);
        let currentIndex = event.target.dataset.index;
        let eventName = event.target.name;
        if (!isValidInput) {
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledAccountVerifyType = false;
            event.target.setCustomValidity('Please enter valid account number'); // Set custom error message
        }
        if (
            this.checkCompoLevelDuplicaton(
                inputValue,
                this.payeeAcdetailsList,
                eventName
            )
        ) {
            this.payeeAcdetailsList[parseInt(currentIndex)].bankNumber = inputValue;
            this.payeeAcdetailsList[parseInt(currentIndex)].isPayeeNameChanged = true;
            this.currentTobeUpdateBankdetailsId = event.target.dataset.id;
            this.payeeAcdetailsList[parseInt(currentIndex)].isDisabledAccountVerifyType = false;
        } else {
            this.payeeAcdetailsList[parseInt(currentIndex)].bankNumber = 0;
        }
    }

    selectAcbranchNameHandler(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let eventName = event.target.name;
        let inputValue = event.target.value;
        this.payeeAcdetailsList[parseInt(currentIndex)].branchName = inputValue;
    }

    selectAcverificationTypeHandler(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let eventName = event.target.name;
        let inputValue = event.target.value;
        this.payeeAcdetailsList[parseInt(currentIndex)].verificationType =
            inputValue;
        // this.submitForBankDetails(event);
    }

    selectTypeChangeHandler(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        this.payeeList[parseInt(currentIndex)].type = inputValue;
    }

    disbursedAmountChangeHandler(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        if (!this.checkToBeDisbursedAmount()) {
            return; // Stop further processing if validation fails
        } else {
            this.payeeList[parseInt(currentIndex)].disbursed_Amount = inputValue;
        }
    }
    ToBedisbursedAmountChangeHandler(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        this.payeeList[parseInt(currentIndex)].toBeDisbursedAmount = inputValue;
        if (!this.checkToBeDisbursedAmount()) {
            return; // Stop further processing if validation fails
        } else {}
    }

    populateBankDetails() {
        debugger;
        this.payeeAcdetailsList[parseInt(this.lastIFSCveirfiedIndex)].branchName =
            this.ifscDetails.BRANCH;
        this.payeeAcdetailsList[parseInt(this.lastIFSCveirfiedIndex)].bankName =
            this.ifscDetails.BANK;
        this.isShowIfsc = false;
    }

    selectPayeeChangeHandler(event) {
        debugger;
    }

    approrovedSelectedBankDetails(event) {
        debugger;
        this.loaded = true;
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        let currentBankRcordid = event.target.dataset.id;
        this.VennyDropVerify(
            "Penny Drop - API Call Out",
            currentBankRcordid,
            this.taskId
        );
        setTimeout(() => {
            this.loaded = false;
        }, "10000");
    }

    findDuplicateBankNumbers(payeeAcdetailsList) {
        debugger;
        const uniqueBankNumbers = new Set();
        const duplicates = [];
        payeeAcdetailsList.forEach((payee) => {
            if (uniqueBankNumbers.has(payee.bankNumber)) {
                duplicates.push(payee.bankNumber);
            } else {
                uniqueBankNumbers.add(payee.bankNumber);
            }
        });

        if (duplicates.length > 0) {
            const duplicateValues = duplicates.join(", ");
            this.showToast(
                "Duplicate Bank Numbers Found",
                `Duplicate bank numbers found: ${duplicateValues}`,
                "error"
            );
            return false;
        }
        return true;
    }

    findDuplicates(payeeList) {
        debugger;
        const duplicates = [];
        const uniqueValues = new Set();

        payeeList.forEach((payee) => {
            if (uniqueValues.has(payee.email) || uniqueValues.has(payee.phone)) {
                duplicates.push(payee);
            } else {
                uniqueValues.add(payee.email);
                uniqueValues.add(payee.phone);
            }
        });

        return duplicates.length === 0;
    }

    submitForBankDetails(event) {
        debugger;
        if (this.findDuplicateBankNumbers(this.payeeAcdetailsList)) {
            if (!this.nullValueValidationForBankDetails(this.payeeAcdetailsList)) {
                this.upperMethodforBankDetails(
                    this.prepareDataforPayeeBankDetailsRecordsFORdatabase(
                        this.payeeAcdetailsList
                    )
                );
            } else {
                this.showToast("Please enter all details", "details missing", "error");
                return false;
                // alert('else zone bro please check your code something you messed in it 🦸🦸')
            }
        } else {}
    }

    nullValueValidationForBankDetails(payeeAcdetailsList) {
    debugger;
        for (const obj of payeeAcdetailsList) {
            for (const key in obj) {
                if (obj.id == undefined) {
                    for (const key in obj) {
                    if (key != "bankNumber") {
                        if (obj.hasOwnProperty(key) && (obj[key] === null || obj[key] === undefined || obj[key] === "")) {
                            return true; // If any key has no value, return true
                        }
                    }

                    }
                }
                if (obj.isShowPhycalyVerifyButton) {
                    if (obj.isDocumentUploaded) {

                    } else {
                    this.handleHighlightRow(obj.index);
                    this.showToast("Error", "Please upload Documents", "error");

                    }
                }

            }
        }
    return false; // If all properties have values, return false
    }


    submitForPayeeDetails(event) {
        debugger;
        if (!this.checkToBeDisbursedAmount()) {
            return; // Stop further processing if validation fails
        }
        this.InsertMethodforPayeeDetails(
            this.prepareDataforPayeeRecordsFORdatabase(this.payeeList)
        );
    }

    upperMethodforBankDetails(listToBeUpsert) {
        if (listToBeUpsert && listToBeUpsert.length > 0) {
            debugger;
            upsertSObject({
                    listTobeUppsert: listToBeUpsert
                })
                .then((response) => {
                    if (response == "Success") {
                        this.showToast("Success", "Records updated successfully", "success");
                        this.refreshData();
                        this.disabledAddRow = false;
                        this.hardRefresh();
                        this.isShowConfirmationComp = false;
                    } else if (response != "Success") {
                        this.showToast(
                            "Got some security issues",
                            response,
                            "error"
                        );
                    }

                })
                .catch((error) => {
                    this.showToast(
                        "Something went wrong",
                        "Error. Please try again later",
                        "error"
                    );
                });
        } else {
            this.showToast(
                "No records to update",
                "The list of records to be updated is empty",
                "warning"
            );
        }
    }

    prepareDataforPayeeRecordsFORdatabase(payeeList) {
        debugger;
        let AccountCOntactPayeewrapperList = [];
        for (let i = 0; i < payeeList.length; i++) {
            let payee = payeeList[i];
            if (!payee.id) {
                let Financial_Entity__c = {
                    Name: payee.name,
                    Entity_Type__c: payee.type,
                    Task_ID__c: payee.Task_ID__c,
                    Financial_Account__c: this.financialAccoundId,
                    Amount_To_Be_Disbursed__c: payee.toBeDisbursedAmount,
                    Account_Name__c:payee.Account_Name__c,
                };
                let AccountCOntactPayeewrapper = {
                    relatedFinancialEntity: Financial_Entity__c,
                    name: payee.name,
                    payeeEmail: payee.email,
                    payeePhone: payee.phone,
                    index: payee.index
                };
                AccountCOntactPayeewrapperList.push(AccountCOntactPayeewrapper);
            }else {
                let Financial_Entity__c = {
                    Id:payee.id,
                    Name: payee.name,
                    Entity_Type__c: payee.type,
                    Task_ID__c: payee.Task_ID__c,
                    Financial_Account__c: this.financialAccoundId,
                    Amount_To_Be_Disbursed__c: payee.toBeDisbursedAmount,
                    Account_Name__c:payee.Account_Name__c,
                };
                let AccountCOntactPayeewrapper = {
                    relatedFinancialEntity: Financial_Entity__c,
                    name: payee.name,
                    payeeEmail: payee.email,
                    payeePhone: payee.phone,
                    index: payee.index
                };
                AccountCOntactPayeewrapperList.push(AccountCOntactPayeewrapper);
            }
        }
        return AccountCOntactPayeewrapperList;
    }

    prepareDataforPayeeRecordsFORdatabaseForCurrentIndex(payeeList,currentIndex){
        debugger;
        let AccountCOntactPayeewrapperList = [];
        for (let i = 0; i < payeeList.length; i++) {
            let payee = payeeList[i];
            if(payee.index==currentIndex){
            if (!payee.id) {
                let Financial_Entity__c = {
                    Name: payee.name,
                    Entity_Type__c: payee.type,
                    Task_ID__c: payee.Task_ID__c,
                    Financial_Account__c: this.financialAccoundId,
                    Amount_To_Be_Disbursed__c: payee.toBeDisbursedAmount,
                    Account_Name__c:payee.Account_Name__c,
                };
                let AccountCOntactPayeewrapper = {
                    relatedFinancialEntity: Financial_Entity__c,
                    name: payee.name,
                    payeeEmail: payee.email,
                    payeePhone: payee.phone,
                    index: payee.index
                };
                AccountCOntactPayeewrapperList.push(AccountCOntactPayeewrapper);
            }else {
                let Financial_Entity__c = {
                    Id:payee.id,
                    Name: payee.name,
                    Entity_Type__c: payee.type,
                    Task_ID__c: payee.Task_ID__c,
                    Financial_Account__c: this.financialAccoundId,
                    Amount_To_Be_Disbursed__c: payee.toBeDisbursedAmount,
                    Account_Name__c:payee.Account_Name__c,
                };
                let AccountCOntactPayeewrapper = {
                    relatedFinancialEntity: Financial_Entity__c,
                    name: payee.name,
                    payeeEmail: payee.email,
                    payeePhone: payee.phone,
                    index: payee.index
                };
                AccountCOntactPayeewrapperList.push(AccountCOntactPayeewrapper);
            }
        }
       }
        return AccountCOntactPayeewrapperList;
    }

    prepareDataforPayeeBankDetailsRecordsFORdatabase(payeeAcdetailsList) {
        debugger;
        let newpayeeAcdetailsList = [];
        for (let i = 0; i < payeeAcdetailsList.length; i++) {
            if (payeeAcdetailsList[i].id==undefined) {
                let Financial_Entity_AC_Detail__c = {};
                Financial_Entity_AC_Detail__c.Financial_Entity__c =
                    payeeAcdetailsList[i].selectedPayeeId;
                    Financial_Entity_AC_Detail__c.Name =
                    payeeAcdetailsList[i].Name;
                Financial_Entity_AC_Detail__c.Bank_Account_Number__c =
                    payeeAcdetailsList[i].bankNumber;
                Financial_Entity_AC_Detail__c.Banking_Account_Name__c =
                    payeeAcdetailsList[i].bankAccountName;
                Financial_Entity_AC_Detail__c.Branch_Name__c =
                    payeeAcdetailsList[i].branchName;
                Financial_Entity_AC_Detail__c.IFSC_Code__c = payeeAcdetailsList[i].IFSC;
                // Financial_Entity_AC_Detail__c.Id = payeeAcdetailsList[i].Id;
                Financial_Entity_AC_Detail__c.Task_ID__c =
                    payeeAcdetailsList[i].Task_ID__c;
                Financial_Entity_AC_Detail__c.Financial_Account__c =
                    this.financialAccoundId;
                Financial_Entity_AC_Detail__c.Digitally_Verification_Method__c =
                    payeeAcdetailsList[i].verificationType;
                Financial_Entity_AC_Detail__c.Bank_Name__c =
                    payeeAcdetailsList[i].bankName;
                Financial_Entity_AC_Detail__c.Verification_Status__c = "New";
                 Financial_Entity_AC_Detail__c.Bank_Account_Type__c =payeeAcdetailsList[i].Bank_Account_Type__c;
                newpayeeAcdetailsList.push(Financial_Entity_AC_Detail__c);
            }
            
            if (payeeAcdetailsList[i].id == this.currentTobeUpdateBankdetailsId && payeeAcdetailsList[i].isPayeeNameChanged == true && this.currentTobeUpdateBankdetailsId !=undefined) {
                let Financial_Entity_AC_Detail__c = {};
                Financial_Entity_AC_Detail__c.Verification_Status__c = payeeAcdetailsList[i].Verification_Status__c;
                Financial_Entity_AC_Detail__c.Physically_verified__c = payeeAcdetailsList[i].Physically_verified__c;
                Financial_Entity_AC_Detail__c.Id = payeeAcdetailsList[i].id;
                Financial_Entity_AC_Detail__c.Banking_Account_Name__c =
                    payeeAcdetailsList[i].bankAccountName;
                    Financial_Entity_AC_Detail__c.Name =
                    payeeAcdetailsList[i].Name;
                Financial_Entity_AC_Detail__c.Financial_Entity__c =
                    payeeAcdetailsList[i].selectedPayeeId;
                Financial_Entity_AC_Detail__c.Bank_Account_Number__c =
                    payeeAcdetailsList[i].bankNumber;
                Financial_Entity_AC_Detail__c.Branch_Name__c =
                    payeeAcdetailsList[i].branchName;
                Financial_Entity_AC_Detail__c.IFSC_Code__c = payeeAcdetailsList[i].IFSC;
                // Financial_Entity_AC_Detail__c.Id = payeeAcdetailsList[i].Id;
                Financial_Entity_AC_Detail__c.Task_ID__c =
                    payeeAcdetailsList[i].Task_ID__c;
                Financial_Entity_AC_Detail__c.Financial_Account__c =
                    this.financialAccoundId;
                Financial_Entity_AC_Detail__c.Digitally_Verification_Method__c =
                    payeeAcdetailsList[i].verificationType;
                Financial_Entity_AC_Detail__c.Bank_Name__c =
                    payeeAcdetailsList[i].bankName;
                     Financial_Entity_AC_Detail__c.Bank_Account_Type__c =payeeAcdetailsList[i].Bank_Account_Type__c;
                newpayeeAcdetailsList.push(Financial_Entity_AC_Detail__c);
            }
        }
        return newpayeeAcdetailsList;
    }

    InsertMethodforPayeeDetails(listTobeUpsert) {
        debugger;
        if (listTobeUpsert.length > 0) {
            createAccountContactDetailsOnBehalofPayeeNumber({
                    wrapperData: listTobeUpsert
                })
                .then((response) => {
                    this.showToast("Success", "Records updated successfully", "success");
                    this.refreshData();
                    this.hardRefresh();
                    this.AddNewPayeeRowDisable = false;
                })
                .catch((error) => {
                    this.showToast(
                        "Error",
                        "Something went wrong. Please try again later.",
                        "error"
                    );
                });
        } else {
            this.showToast("Info", "No new records to update.", "info");
        }
    }

    verifyIFSCCode(ifscCode, index) {
        debugger;
        this.lastIFSCveirfiedIndex = index;
        getIFSCDetails({
                ifscCode: ifscCode
            })
            .then((response) => {
                this.ifscDetails = response;
                this.isShowIfsc = true;
                this.showToast("Success", "please check details", "success");
            })
            .catch((error) => {
                this.showToast("Error", "ifsc details not found", "error");
            });
    }

    // THIS METHOD WILL DELETE IN ANY SOBJECTS RECORD BY ITS ID list<ids>
    dynamicallyRecordsDeletion(recordsIds) {
        debugger;
        dynamicRecordDeletion({
                recordIds: recordsIds
            })
            .then((response) => {
                this.showToast("Success", "records deleted", "success");
                this.refreshData();
                this.hardRefresh();
            })
            .catch((error) => {
                this.showToast("Error", " getting error deletion", "error");
            });
    }

    closeModalIFSC(event) {
        debugger;
        this.isShowIfsc = false;
    }

    checkToBeDisbursedAmount() {
        debugger;

        for (let i = 0; i < this.payeeList.length; i++) {
            if (!this.payeeList[i].id) {
                if (
                    this.payeeList[i].type.includes(Financial_Entity_Disburse_Amount_Validation) &&
                    (this.payeeList[i].toBeDisbursedAmount == null ||
                        this.payeeList[i].toBeDisbursedAmount == undefined ||
                        this.payeeList[i].toBeDisbursedAmount == "" ||
                        parseInt(this.payeeList[i].toBeDisbursedAmount) == 0)
                ) {
                    this.showToast(
                        "Please enter a to be disbursed amount.",
                        "Can not be null:",
                        "error"
                    );
                    return false; // Return false if validation fails
                } else if (
                    this.payeeList[i].type == undefined ||
                    this.payeeList[i].name == undefined ||
                    this.payeeList[i].type == undefined ||
                    this.payeeList[i].email == undefined ||
                    this.payeeList[i].phone == undefined ||
                    this.payeeList[i].type == "" ||
                    this.payeeList[i].name == " " ||
                    this.payeeList[i].type == "" ||
                    this.payeeList[i].email == "" ||
                    this.payeeList[i].phone == ""
                ) {
                    this.showToast(
                        "Please enter all details",
                        "details missing",
                        "error"
                    );
                    return false;
                }
            }
        }
        return true; // Return true if all validations pass
    }



    handleHighlightRow(rowIndex) {
        debugger;
        this.payeeAcdetailsList[parseInt(rowIndex)].isRedRow = 'red-row';

    }

    physicallyVerifyBabkDetails(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        this.currentTobeUpdateBankdetailsindex = currentIndex;
        let currentBankRcordid = event.target.dataset.id;
        this.showToast("opening documents handler", "Please upload documents ", "success");
        this.isShowMODTCOMP = true;
        this.currentBankDetailsRecordId = currentBankRcordid;
    }


    physicallyViewBabkDetails(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        this.currentTobeUpdateBankdetailsindex = currentIndex;
        let currentBankRcordid = event.target.dataset.id;
        this.isShowMODTCOMP = true;
        this.currentBankDetailsRecordId = currentBankRcordid;
        this.isTaskOwnerLogin = false;
    }

    handleUpdateACDetailsRow(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        let currentBankRcordid = event.target.dataset.id;
        this.currentTobeUpdateBankdetailsId = currentBankRcordid;
        this.blockAllOthersRowsforBackDetails(currentIndex);
        this.payeeAcdetailsList[
            parseInt(currentIndex)
        ].isShowUpdateGreenButton = true;
    }

    isShowUpdateGreenButtonGreen(event) {
        debugger;
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        let currentBankRcordid = event.target.dataset.id;
        this.currentTobeUpdateBankdetailsId = currentBankRcordid;
        this.currentTobeUpdateBankdetailsindex = currentIndex;
        this.currentTobeUpdateBankdetailsValue = inputValue;
        this.payeeAcdetailsList[parseInt(currentIndex)].isShowUpdateGreenButton = false;
        this.payeeAcdetailsList[parseInt(currentIndex)].isPayeeNameChanged = true;
        this.isShowConfirmationComp = true;
        if (this.isResponsePositive) {
            this.submitForBankDetails(event);
        } else {

        }

    }


    blockAllOthersRowsforBackDetails(currentIndex) {
        debugger;
        for (let i = 0; i < this.payeeAcdetailsList.length; i++) {
            if (i === parseInt(currentIndex)) {
                if (this.payeeAcdetailsList[i].isEditableDisabled) {
                    this.payeeAcdetailsList[i].isEditableDisabled = false;
                    this.payeeAcdetailsList[i].isDisabledAccountVerifyType = false;
                    this.payeeAcdetailsList[i].isShowUpdateGreenButton = false;
                } else if (this.payeeAcdetailsList[i].isShowUpdateGreenButton) {
                    this.payeeAcdetailsList[i].isEditableDisabled = true;
                } else {
                    this.payeeAcdetailsList[i].isEditableDisabled = true;
                    this.payeeAcdetailsList[i].isDisabledAccountVerifyType = true;
                }
            } else {
                this.payeeAcdetailsList[i].isEditableDisabled = true;
                this.payeeAcdetailsList[i].isShowUpdateGreenButton = false;
                this.payeeAcdetailsList[i].isDisabledAccountVerifyType = true;
            }
        }
    }

    blockAllOthersRowsforPayeeDetails(currentIndex) {
        debugger;
        for (let i = 0; i < this.this.payeeList.length; i++) {
            if (i === parseInt(currentIndex)) {
                if (this.this.payeeList[i].isEditableDisabled) {
                    this.this.payeeList[i].isEditableDisabled = false;
                    this.this.payeeList[i].isShowUpdateGreenButton = false;
                } else if (this.this.payeeList[i].isShowUpdateGreenButton) {
                    this.this.payeeList[i].isEditableDisabled = true;
                } else {
                    this.this.payeeList[i].isEditableDisabled = true;
                }
            } else {
                this.this.payeeList[i].isEditableDisabled = true;
                this.this.payeeList[i].isShowUpdateGreenButton = false;
            }
        }
    }

    // subject ,sobjectrecordId,parentTaskId
    VennyDropVerify(subject, sObjectRecordId, parentTaskId) {
        debugger;
        createTask({
                subject: subject,
                backDetailsRecordId: sObjectRecordId,
                parentTaskId: parentTaskId
            })
            .then((response) => {
                console.log("VennyDropVerify response --->" + response);
                this.showToast("Success", "Verified successfully", "success");
                this.refreshData();
                // this.hardRefresh();
            })
            .catch((error) => {
                this.showToast("Error", " verification failed", "error");
            });
    }

    backTomodt(event) {
        debugger;
        this.isShowMODTCOMP = false;
    }

    handleConfirmationResponse(event) {
        debugger;
        this.isResponsePositive = event.detail.message;
        if (!event.detail.message) {
            this.isShowConfirmationComp = false
            this.payeeAcdetailsList[parseInt(this.currentTobeUpdateBankdetailsindex)].selectedPayeeId = '';
        } else {
            this.payeeAcdetailsList[parseInt(this.currentTobeUpdateBankdetailsindex)].isPayeeNameChanged = true;
            this.payeeAcdetailsList[parseInt(this.currentTobeUpdateBankdetailsindex)].selectedPayeeId = this.currentTobeUpdateBankdetailsValue;
            this.submitForBankDetails(event);
        }
    }

    //DOCUMENT HANDLER EVENT 
    callDocumentHandlerFinalSubmit() {
        debugger;
        let child = this.template.querySelector('c-lwc_-handledocuments');
        child.HandleSavefromAura();
        //this.isShowMODTCOMP = true;
    }

    closeMODT(event) {
        debugger;
        let index = event.detail.index;
        let recordId = event.detail.extendedsobjId;
        let isDocumentClosed = event.detail.child_isclosed;
        if (isDocumentClosed) {
            this.payeeAcdetailsList[parseInt(index)].isDocumentUploaded = true;
            this.payeeAcdetailsList[parseInt(index)].Verification_Status__c = 'Verified';
            this.currentTobeUpdateBankdetailsId = recordId;
            this.payeeAcdetailsList[parseInt(index)].isPayeeNameChanged = true;
            this.payeeAcdetailsList[parseInt(index)].Physically_verified__c = true;
            this.submitForBankDetails(event);

        } else {
            this.handleHighlightRow(index);
            this.payeeAcdetailsList[parseInt(index)].isDocumentUploaded = false;
        }
    }

    enabledEditingPayee(currentIndex){
        debugger;
        for (let i = 0; i < this.payeeList.length; i++) {
            if (i == parseInt(currentIndex)) {
                this.payeeList[i].isEditableDisabled = false;
                this.payeeList[i].isShowEditableButton = false;
            } else {
                this.payeeList[i].isEditableDisabled = true;
                this.payeeList[i].isShowEditableButton = true;
                
            }
        }
        
    }

    upatePayeeByRowUpdateButton(event){
        debugger
        let currentIndex = event.target.dataset.index;
        let inputValue = event.target.value;
        let eventName = event.target.name;
        this.InsertMethodforPayeeDetails(
        this.prepareDataforPayeeRecordsFORdatabaseForCurrentIndex(this.payeeList,currentIndex))
        this.disanabledEditingPayee(currentIndex);

    }

    disanabledEditingPayee(currentIndex){
        debugger
        for (let i = 0; i < this.payeeList.length; i++) {
            if (i == parseInt(currentIndex)) {
                this.payeeList[i].isEditableDisabled = true;
                this.payeeList[i].isShowEditableButton = true;
            } else {
                this.payeeList[i].isEditableDisabled = true;
                this.payeeList[i].isShowEditableButton = true;
                
            }
        }
    }

}