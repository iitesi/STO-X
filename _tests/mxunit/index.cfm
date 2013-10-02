<cfinvoke component="mxunit.runner.DirectoryTestSuite"
          method="run"
          directory="#expandPath('/booking/_tests/mxunit/')#"
          componentPath="booking._tests.mxunit"
          recurse="true"
          returnvariable="results" />

<cfoutput> #results.getResultsOutput('extjs')# </cfoutput>


