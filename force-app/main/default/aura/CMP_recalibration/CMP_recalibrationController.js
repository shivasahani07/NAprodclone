({
    doInit: function(component, event, helper) {
          debugger;
        component.find('lwc_recalibration').checkStatusOnLoad ();
    },
    calllwcstatucClosedMethod : function(component, event, helper) {
        debugger;

        var lwcComponent = component.find("lwc_recalibration");
        if (lwcComponent) {
            lwcComponent.finalvalidation();

        } else {
            console.error("LWC component not found.");
        }
    },
    
    handleLWCLaunched: function(component, event, helper) {
        debugger;
        var Isclose = event.getParam('Isclose');
        var Index = event.getParam('Index');
        var compEvent=component.getEvent("compEvent");
        compEvent.setParams({
            "isclosed_comp_index" : Index,
            "isclosed" : Isclose
        });
        compEvent.fire();
    }
})