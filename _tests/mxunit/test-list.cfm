<cfscript>
    testsDir = expandPath('/booking/_tests');
    componentPath = 'booking._tests';

    suite = createObject('mxunit.framework.TestSuite');
    files = createObject('mxunit.runner.DirectoryTestSuite').getTests(directory=testsDir, componentPath=componentPath);

    for (i = 1; i <= arrayLen(files); i++){
        suite.addAll(files[i]);
    }

    tests = suite.suites();

    for (t in tests){
        tests[t] = tests[t].methods;
    }
</cfscript>
<cfsetting showdebugoutput="false" />
<cfcontent reset="true" type="application/json; charset=UTF-8" /><cfoutput>#serializeJson(tests)#</cfoutput><cfabort/>