public class Utility {

    Public static List<String> getPicklistValueSet(String SobjectApiName, String FieldApiName){
        //String objectName = 'Contact';
        //String fieldName ='LeadSource';
        List<String> fieldpicklist = new List<String>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(SobjectApiName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(FieldApiName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
            fieldpicklist.add(pickListVal.getValue());
        }   
        return fieldpicklist;
    }

    public static List<String> getPicklistValues(String objectApiName, String fieldApiName, String recordTypeId) {
        List<String> picklistValues = new List<String>();

        // Get the SObjectDescribeResult for the object
        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectApiName).getDescribe();
        System.debug('objectDescribe =====> ' + objectDescribe);

        // Get the record type info for the object
        Map<String, Schema.RecordTypeInfo> recordTypeInfo = objectDescribe.getRecordTypeInfosByName();
        Schema.RecordTypeInfo rtInfo = recordTypeInfo.get(recordTypeId);

        // Get the field describe result
        Schema.DescribeFieldResult fieldDescribe = objectDescribe.fields.getMap().get(fieldApiName).getDescribe();
        System.debug('objectDescribe.fields.getMap() ===> ' + objectDescribe.fields.getMap());
        System.debug('objectDescribe.fields.getMap().get(fieldApiName) ===> ' + objectDescribe.fields.getMap().get(fieldApiName));
        System.debug('objectDescribe.fields.getMap().get(fieldApiName).getDescribe() ===> ' + objectDescribe.fields.getMap().get(fieldApiName).getDescribe());

        // Retrieve the picklist values for the specified record type
        List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
        for (Schema.PicklistEntry entry : picklistEntries) {
            picklistValues.add(entry.getValue());
        }

        return picklistValues;
    }



    Public static string getpartnerAPIStaticResponse(){

        String returneddummyresponse =  '[\n'+
'    {\n'+
'        "entity_id": "5159401346177020",\n'+
'        "name": "STARAGRI FINANCE LIMITED",\n'+
'        "cin": "U65999MH1995PLC267097",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5219841010116227",\n'+
'        "name": "SSTECH",\n'+
'        "cin": "12345678",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5226836669675671",\n'+
'        "name": "01XARXA TECHNOLOGIES PRIVATE LIMITED ",\n'+
'        "cin": "U72900KA2019PTC124383",\n'+
'        "email": "xman@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5169167028370524",\n'+
'        "name": "ASDFG DESIGN INDIA PRIVATE LIMITED",\n'+
'        "cin": "U36999DL2018PTC337368",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5178286159165674",\n'+
'        "name": "APPYTUNES PRIVATE LIMITED",\n'+
'        "cin": "U72900KA2012PTC062027",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5274991473552915",\n'+
'        "name": "NORTHERN ARC CAPITAL LIMITED",\n'+
'        "cin": "U67120RJ1996PLC011406",\n'+
'        "email": "srividhya.r@northernarc.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5164514614341599",\n'+
'        "name": "21ST CENTURY CONSTRUCTIONS LIMITED",\n'+
'        "cin": "U74999DL1985PLC123961",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5149632704391446",\n'+
'        "name": "A-1 BOOK MANUFACTURING PRIVATE LIMITED",\n'+
'        "cin": "U22700MH1984PTC034602",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5271833549394175",\n'+
'        "name": "CONSOLIDATED ENERGY CONSULTANTS LIMITED",\n'+
'        "cin": "U74210MP1990PLC005688",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5294856060521504",\n'+
'        "name": "STEELMEN DISTRIBUTORS LIMITED",\n'+
'        "cin": "U51102MP1997PLC012050",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5181512912880353",\n'+
'        "name": "3D CORPORATE SERVICES PRIVATE LIMITED",\n'+
'        "cin": "U74120MH2012PTC227347",\n'+
'        "email": "prt@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5299958003554663",\n'+
'        "name": "SHUBAM CREATION PRIVATE LIMITED",\n'+
'        "cin": "U17291MH2005PTC153507",\n'+
'        "email": null,\n'+
'        "phone": "9757827364"\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5155068329232026",\n'+
'        "name": "01SYS INNOVATIVE SOLUTIONS PRIVATELIMITED",\n'+
'        "cin": "U72200KL2013PTC033087",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5102518696889897",\n'+
'        "name": "1000 OVERSEAS FRANCHISE PRIVATE LIMITED",\n'+
'        "cin": "U74999DL2014PTC263332",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5133219705712919",\n'+
'        "name": "1PAY MOBILEWARE PRIVATE LIMITED",\n'+
'        "cin": "U74999MH2019PTC320148",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5196140392959401",\n'+
'        "name": "ECOZEN SOLUTIONS PRIVATE LIMITED",\n'+
'        "cin": "U93090MH2010PTC209218",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5224251014328548",\n'+
'        "name": "ECUBE EVENTS PRIVATE LIMITED",\n'+
'        "cin": "U74900DL2011PTC219004",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5104982693755888",\n'+
'        "name": "100KEYS CONSTRUCTION PRIVATE LIMITED",\n'+
'        "cin": "U45309DL2018PTC330857",\n'+
'        "email": "ankur2bca@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5158737531341104",\n'+
'        "name": "AASHAN SPORTS ENTERTAINMENT PRIVATE LIMITED",\n'+
'        "cin": "U92490PN2018PTC178220",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5120774167616536",\n'+
'        "name": "007 UNIVERSE RESORTS & SPA PRIVATELIMITED",\n'+
'        "cin": "U93000MH2014PTC253334",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5291875378294914",\n'+
'        "name": "0.5BN FINHEALTH PRIVATE LIMITED",\n'+
'        "cin": "U65990KA2019PTC120216",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5232185814962547",\n'+
'        "name": "08 CONSULTINGS PRIVATE LIMITED",\n'+
'        "cin": "U74900DL2013PTC261046",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5282359113772059",\n'+
'        "name": "0ASANT INDUSTRIES PRIVATE LIMITED",\n'+
'        "cin": "U65910GJ1949PTC000630",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5274318623101779",\n'+
'        "name": "0TH ROOT SOFTWARE RESEARCH PRIVATELIMITED",\n'+
'        "cin": "U73100TN2013PTC090830",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5206952819407885",\n'+
'        "name": "0ILS INDIA LIMITED",\n'+
'        "cin": "U99999MH1945PTC004547",\n'+
'        "email": "er@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5274659066596433",\n'+
'        "name": "1000 OAKS PRIVATE LIMITED",\n'+
'        "cin": "U74999AP2013PTC091322",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5181512912880353",\n'+
'        "name": "3D CORPORATE SERVICES PRIVATE LIMITED",\n'+
'        "cin": "U74120MH2012PTC227347",\n'+
'        "email": "prt@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5147736155279388",\n'+
'        "name": "1000PROJECTS IT TECHNOLOGIES INDIAPRIVATE LIMITED",\n'+
'        "cin": "U72200TG2014PTC094907",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5199921752963368",\n'+
'        "name": "1000 TAXIS PRIVATE LIMITED",\n'+
'        "cin": "U60220AS2016PTC012366",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5226696984780661",\n'+
'        "name": "1000 TEMPERATURE PRIVATE LIMITED",\n'+
'        "cin": "U92490DL2012PTC245199",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5214873672694473",\n'+
'        "name": "100ACRES INFRA PRIVATE LIMITED",\n'+
'        "cin": "U70102MH2016PTC273636",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5230464423726695",\n'+
'        "name": "100 DAYS INSURANCE BROKERS PRIVATELIMITED",\n'+
'        "cin": "U74900PB2015PTC039779",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5245879745001115",\n'+
'        "name": "100 GEMS MARKETING PRIVATE LIMITED",\n'+
'        "cin": "U51502PB2015PTC039875",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5234457631293579",\n'+
'        "name": null,\n'+
'        "cin": null,\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5181568604165010",\n'+
'        "name": "AARON INSTITUTE OF HUMAN RESOURCESDEVELOPMENT PRIVATE LIMITED",\n'+
'        "cin": "U80211TN2013PTC093521",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5297965949606367",\n'+
'        "name": "EDU-TRYST PRIVATE LIMITED",\n'+
'        "cin": "U93098DL2018PTC330611",\n'+
'        "email": "educationbazar007@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5289797298164057",\n'+
'        "name": "LEXEKO CONSULTANCY SERVICES PRIVATELIMITED (OPC)",\n'+
'        "cin": "U74999KL2016OPC045893",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5182671201826662",\n'+
'        "name": "EMPIRIX SOFTWARE SOLUTIONS PRIVATELIMITED",\n'+
'        "cin": "U74900KA2016FTC085770",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5256356258805414",\n'+
'        "name": "DDB MUDRA PRIVATE LIMITED",\n'+
'        "cin": "U74300MH1980PTC022276",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5104874566782780",\n'+
'        "name": "HORIZON FINLEASE LIMITED",\n'+
'        "cin": "U65991MP1997PLC011532",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5152577375591371",\n'+
'        "name": "MESTRE MIND BEVY PRIVATE LIMITED",\n'+
'        "cin": "U74999TN2018PTC121284",\n'+
'        "email": "frozenbaecreams@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5107656470575971",\n'+
'        "name": "PUNET FOOTWEARS PRIVATE LIMITED",\n'+
'        "cin": "U19200DL2018PTC330578",\n'+
'        "email": "sachinking30@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5241047568277848",\n'+
'        "name": "TEQTO DEVELOPERS INDIA PRIVATE LIMITED",\n'+
'        "cin": "U45309UP2018PTC101799",\n'+
'        "email": "teqtodevelopers@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5262102384417213",\n'+
'        "name": "STOCK MARKET FAIR PRIVATE LIMITED",\n'+
'        "cin": "U74999DL2018PTC330558",\n'+
'        "email": "shreddermachine770@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5239440535664464",\n'+
'        "name": "ANAKSHA ENTERPRISES PRIVATE LIMITED",\n'+
'        "cin": "U70103KA2018PTC110939",\n'+
'        "email": "swaroopsuri@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5173497239984865",\n'+
'        "name": "DEVANSH BIO FERTILIZERS PRIVATE LIMITED",\n'+
'        "cin": "U51909MP2018PTC045227",\n'+
'        "email": "yadavnaresh462@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5147799362890998",\n'+
'        "name": "SHANKAR VITAL MOTOR COMPANY LIMITED",\n'+
'        "cin": "U34101KA1929PLC001215",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5284898408754859",\n'+
'        "name": "SINGAIAVS PRIVATE LIMITED",\n'+
'        "cin": "U45309PY2018PTC008259",\n'+
'        "email": "admin@singaiavs.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5224301738620833",\n'+
'        "name": "DHARMIK COAL PRIVATE LIMITED",\n'+
'        "cin": "U51909WB2018PTC225014",\n'+
'        "email": "dharmikcoalpl@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5240370645589806",\n'+
'        "name": "TOTAL DENTAL CARE PRIVATE LIMITED",\n'+
'        "cin": "U33112MH2010PTC209530",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5248527173280850",\n'+
'        "name": "WORLD COLOPROCTOLOGY (OPC) PRIVATELIMITED",\n'+
'        "cin": "U85310KA2016OPC094770",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5258083021571274",\n'+
'        "name": "IBNUS SOFT TECH PRIVATE LIMITED",\n'+
'        "cin": "U72900OR2018PTC028469",\n'+
'        "email": "rubu123@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5297618812181045",\n'+
'        "name": "MENTOR FINANCE COMPANY PRIVATE LIMITED",\n'+
'        "cin": "U22113MH1998PTC114592",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5282531700699559",\n'+
'        "name": "LAXDON E-COMMERCE PRIVATE LIMITED",\n'+
'        "cin": "U74999PN2018PTC175267",\n'+
'        "email": "TUSHAR_DADHE@YAHOO.COM",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5180031298688792",\n'+
'        "name": "TECHTREK INDIA LIMITED",\n'+
'        "cin": "L27100MH1983PLC029203",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5292188913570040",\n'+
'        "name": "ASIANS SMALL FINANCE PRIVATE LIMITED",\n'+
'        "cin": "U65999RJ2018PTC060438",\n'+
'        "email": "gaganrai2003@yahoo.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5168855405262082",\n'+
'        "name": "PARAMOUNT PRINTPACKAGING LIMITED",\n'+
'        "cin": "L22200MH2006PLC160735",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5234934503561405",\n'+
'        "name": "SALOM CORPORATE PRIVATE LIMITED",\n'+
'        "cin": "U74999HR2017PTC068107",\n'+
'        "email": "prithvu@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5262111215252039",\n'+
'        "name": "CREDILLA ",\n'+
'        "cin": "NCIN48486718333836518",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5286507982556189",\n'+
'        "name": "MALANI STONES PRIVATE LIMITED",\n'+
'        "cin": "U51909RJ2018PTC060473",\n'+
'        "email": "CA.ANIRUDH09@GMAIL.COM",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5182419582919081",\n'+
'        "name": "AKLUJ SHOPPING CENTER PRIVATE LIMITED",\n'+
'        "cin": "U74999PN2018PTC175259",\n'+
'        "email": "csumeshkadam@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5167957701476917",\n'+
'        "name": "VAYA FINSERV PRIVATE LIMITED",\n'+
'        "cin": "U67190TG2014PTC093562",\n'+
'        "email": "balaji.gupta@vayaindia.com",\n'+
'        "phone": "914047896999"\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5222955783284413",\n'+
'        "name": "PARAG FANS AND COOLING SYSTEMS LIMITED",\n'+
'        "cin": "L51102MP1991PLC006760",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5290071100052230",\n'+
'        "name": "EDDY INFOTECH (OPC) PRIVATE LIMITED",\n'+
'        "cin": "U72200BR2018OPC037423",\n'+
'        "email": "apanacompliances@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5196232082868723",\n'+
'        "name": "NACRE LAND DEVELOPERS PRIVATE LIMITED(OPC)",\n'+
'        "cin": "U45200MP2014OPC032804",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5194870010754411",\n'+
'        "name": "MIDDLE KERALA KURI COMPANY LIMITED",\n'+
'        "cin": "U65992KL2002PLC015760",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5221214580983032",\n'+
'        "name": "PENINSULAR SOFTWARES LIMITED",\n'+
'        "cin": "U72200KL1994PLC007739",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5257225445599165",\n'+
'        "name": "DESIGN AUTO SYSTEMS LTD.",\n'+
'        "cin": "U03410MP1987PLC003941",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5104773654583585",\n'+
'        "name": "MANGROVE IMPEX PRIVATE LIMITED",\n'+
'        "cin": "U74999DL2018PTC330605",\n'+
'        "email": "Sharma56rahul@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5217493543495616",\n'+
'        "name": "KINFRA EXPORT PROMOTION INDUSTRIAL PARKS LTD",\n'+
'        "cin": "U72200KL1994PLC008287",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5265681381863106",\n'+
'        "name": "ARCELOR MITTAL CEMENT LIMITED",\n'+
'        "cin": "U26940MP2012PLC028938",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5231501470795624",\n'+
'        "name": "WHITEMONK INTERACTIVE PRIVATE LIMITED",\n'+
'        "cin": "U72900AP2018PTC107806",\n'+
'        "email": "itzkinnu@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5230358100502433",\n'+
'        "name": "ENTOMO TECHNOLOGIES INDIA PRIVATELIMITED",\n'+
'        "cin": "U72501KL2016FTC046021",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5244124379143463",\n'+
'        "name": "TARANG BUSINESS PROMOTERS ANDCONSULTANTS LIMITED",\n'+
'        "cin": "U74140KL2005PLC018237",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5119734952380404",\n'+
'        "name": "IGOLEM AUTOMATION SOLUTIONS PRIVATE LIMITED",\n'+
'        "cin": "U74994DL2018PTC330560",\n'+
'        "email": "GOELJAINANDASSOCIATES@GMAIL.COM",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5205594917706678",\n'+
'        "name": "HYGIENE CLEAN CARE PRIVATE LIMITED",\n'+
'        "cin": "U24297DL2018PTC330586",\n'+
'        "email": "csamritsingh@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5298268108366261",\n'+
'        "name": "MANOJIT PLANTATION LIMITED",\n'+
'        "cin": "U36101MP1992PLC007330",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5137280310727588",\n'+
'        "name": "GAJANAN FINSEC LIMITED",\n'+
'        "cin": "U67120MP1997PLC012189",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5295988177746787",\n'+
'        "name": "PARTSBIGBOSS LIMITED",\n'+
'        "cin": "U35990DL2018PLC330619",\n'+
'        "email": "partsbiggboss@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5192000896857033",\n'+
'        "name": "MALABAR KURI COMPANY LIMITED",\n'+
'        "cin": "U65992KL1947PLC001533",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5168716358851037",\n'+
'        "name": "MADHURI FINVEST LIMITED",\n'+
'        "cin": "U65991MP1996PLC011287",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5221337144146466",\n'+
'        "name": "M POWER MICRO FINANCE PRIVATE LIMITED",\n'+
'        "cin": "U65999MH2009PTC197149",\n'+
'        "email": null,\n'+
'        "phone": "9757827364"\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5241893429434653",\n'+
'        "name": "ELECTRONICA FINANCE LIMITED",\n'+
'        "cin": "U65910PN1990PLC057017",\n'+
'        "email": "electronica@gmail.com",\n'+
'        "phone": "9757827364"\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5255024537623577",\n'+
'        "name": "MIMOZA ENTERPRISES FINANCE PRIVATELIMITED",\n'+
'        "cin": "U15676DL1995PTC189943",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5202970208246590",\n'+
'        "name": "ARIS CAPITAL PRIVATE LIMITED",\n'+
'        "cin": "U65910WB1995PTC068566",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5183344414177875",\n'+
'        "name": "AWG RESORTS AND HOTEL PRIVATE LIMITED",\n'+
'        "cin": "U74999UP2018PTC101798",\n'+
'        "email": "walinxt@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5274084748695580",\n'+
'        "name": "ANMANANDI INFOTECH PRIVATE LIMITED",\n'+
'        "cin": "U72900RJ2018PTC060468",\n'+
'        "email": "ASK@JAINTAXSOLUTIONS.COM",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5280568481407014",\n'+
'        "name": "SKYGEIER SOLUTIONS PRIVATE LIMITED",\n'+
'        "cin": "U74997DL2018PTC330608",\n'+
'        "email": "yspatil2@rediffmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5200064479684977",\n'+
'        "name": "PEARLTRACK NUTRITIOUS FOODS LIMITED",\n'+
'        "cin": "U15400MP2013PLC030741",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5123891746830210",\n'+
'        "name": "A.D.V. PHARMA INDIA LIMITED",\n'+
'        "cin": "U24232MP2011PLC025241",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5268803283967725",\n'+
'        "name": "INDUS MULTIVENTURES LIMITED",\n'+
'        "cin": "U45201MP2007PLC019511",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5243989908656741",\n'+
'        "name": "OMKARAM PESTICIDES & SEEDS PRIVATE LIMITED",\n'+
'        "cin": "U01100RJ2018PTC060476",\n'+
'        "email": "yogeshbansal04@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5273685311865644",\n'+
'        "name": "CERTO TECHNOLOGIES (OPC) PRIVATE LIMITED",\n'+
'        "cin": "U74999KL2016OPC045525",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5189908463138984",\n'+
'        "name": "NAGESHWARAM HEALTHCARE PRIVATE LIMITED",\n'+
'        "cin": "U85190RJ2018PTC060467",\n'+
'        "email": "dhootbrotherschuru@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5294971272767201",\n'+
'        "name": "EMINENCE INDIA LIMITED",\n'+
'        "cin": "U74900MP2008PLC020701",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5225455759726166",\n'+
'        "name": "ANNAPURNA MICROFINANCE PRIVATE LIMITED",\n'+
'        "cin": "U52234OR1986PTC015931",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5258667335360368",\n'+
'        "name": "XLNT JOBCRAFT HR SOLUTIONS PRIVATE LIMITED",\n'+
'        "cin": "U93090TG2018PTC122821",\n'+
'        "email": "Prime_kajol@yahoo.co.in",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5161712965273832",\n'+
'        "name": "AZACUS EDUTECH PRIVATE LIMITED",\n'+
'        "cin": "U80903MH2018PTC306219",\n'+
'        "email": "hemant.ajay.pandey@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5116179977701093",\n'+
'        "name": "NAK MACHINERY & TOOLS PRIVATE LIMITED",\n'+
'        "cin": "U74999BR2018PTC037419",\n'+
'        "email": "imabhishek1992@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5237449871848021",\n'+
'        "name": "ESSKAY FINCORP LTD",\n'+
'        "cin": "NCIN10792990537046862",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5210107255637991",\n'+
'        "name": "ATIMODA PERFUMERY PRODUCTS PRIVATE LIMITED",\n'+
'        "cin": "U24303KA2018PTC110935",\n'+
'        "email": "MOHAN@SILICONEDUCATION.IN",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5112481833412477",\n'+
'        "name": "LAYANA TOURS PRIVATE LIMITED",\n'+
'        "cin": "U74999WB2018PTC225034",\n'+
'        "email": "dipankar357@yahoo.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5153699811616717",\n'+
'        "name": "LAKHIYA ENTERPRISES PRIVATE LIMITED",\n'+
'        "cin": "U74999GJ2018PTC101190",\n'+
'        "email": "ravindra.rrbpandcompany@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5296514981569629",\n'+
'        "name": "VAVI FARMERS PRODUCER COMPANY LIMITED",\n'+
'        "cin": "U01100TZ2017PTC028488",\n'+
'        "email": "tj@gmal.com",\n'+
'        "phone": "8804578955"\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5220473930393567",\n'+
'        "name": "TEST AUTOMATION INVESTOR PVT LTD",\n'+
'        "cin": "NCIN02871809932069268",\n'+
'        "email": null,\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5127874235731971",\n'+
'        "name": "ECOFRIEND NATURE POWER PRIVATE LIMITED",\n'+
'        "cin": "U74999KA2017PTC100670",\n'+
'        "email": "prithl@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5295810279500808",\n'+
'        "name": "TECHNOCIA INFRA PRIVATE LIMITED",\n'+
'        "cin": "U74999TN2018PTC121288",\n'+
'        "email": "bairagonirohitha@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5211175453609936",\n'+
'        "name": "DE ROYALE DESTINY PRIVATE LIMITED",\n'+
'        "cin": "U74999KA2018PTC110933",\n'+
'        "email": "info@deroyaledestiny.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5142215484180303",\n'+
'        "name": "PLVK POWER ENGINEERS PRIVATE LIMITED",\n'+
'        "cin": "U74999DL2018PTC330610",\n'+
'        "email": "PLVK_POWER@YAHOO.IN",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5230943701920285",\n'+
'        "name": "PREMIER NATURAL SURFACES PRIVATE LIMITED",\n'+
'        "cin": "U14298RJ2018PTC060475",\n'+
'        "email": "ghanshyammenaria@gmail.com",\n'+
'        "phone": null\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5268053205436782",\n'+
'        "name": "KOGTA FINANCIAL (INDIA) LTD",\n'+
'        "cin": "U67120RJ1996PLC011409",\n'+
'        "email": "varun@kogta.in",\n'+
'        "phone": "1412389025"\n'+
'    },\n'+
'    {\n'+
'        "entity_id": "5268053205436782",\n'+
'        "name": "KOGTA FINANCIAL (INDIA) LTD",\n'+
'        "cin": "U67120RJ1996PLC011409",\n'+
'        "email": "varun@kogta.in",\n'+
'        "phone": "1412389025"\n'+
'    }\n'+
']';
return returneddummyresponse;
    }

}