component accessors="true"{
			
	property name="bundles";
	property name="results";
	property name="utility";
			
	/**
	* Constructor
	* @bundles.hint The path, list of paths or array of paths of the spec bundle CFCs to run and test
	*/
	TestRunner function init( any bundles=[] ){
		
		// init util
		variables.utility = new coldbox.system.core.util.Util();
		
		// inflate bundles to array
		inflateBundles( arguments.bundles );
		
		// startup results
		variables.results = "";
		
		return this;
	}
	
	/**
	* Run the bundles setup in this Runner.
	*/
	TestResult function run(any bundles){
		// if bundles passed, inflate those as the target
		if( structKeyExists( arguments, "bundles" ) ){ inflateBundles( arguments.bundles ); }
		
		// create results object
		var results = new TestResult( arrayLen( variables.bundles ) );
		
		// iterate and run the test bundles
		for( var thisBundlePath in variables.bundles ){
			testBundle( thisBundlePath, results );
		}
		
		// mark end of testing bundles
		results.end();
		
		return results;
	}
	
	
	/************************************** PRIVATE *********************************************/
	
	private function getBundle(required bundlePath){
		var bundle		= new "#arguments.bundlePath#"();
		var familyPath 	= "coldbox.system.testing.BaseSpec";
		
		// check if base spec assigned
		if( isInstanceOf( bundle, familyPath ) ){
			return bundle;
		}
		
		// Else virtualize it
		var baseObject 			= new coldbox.system.testing.BaseSpec();
		var excludedProperties 	= "";
		
		// Mix it up baby
		variables.utility.getMixerUtil().start( bundle );
		
		// Mix in methods
		for( var key in baseObject ){
			// If target has overriden method, then don't override it with mixin, simulated inheritance
			if( NOT structKeyExists( bundle, key ) AND NOT listFindNoCase( excludedProperties, key ) ){
				bundle.injectMixin( key, baseObject[ key ] );
			}
		}

		// Mix in virtual super class just in case we need it
		bundle.$super = baseObject;
		
		return bundle;
	}
	
	private TestRunner function testBundle(
		required string bundlePath, 
		required TestResult testResults){
		
		// create new target bundle and get its metadata
		var target 		= getBundle( arguments.bundlePath );
		var targetMD 	= getMetadata( target );
		
		// setup bundle name
		var bundleName = ( structKeyExists( targetMD, "displayName" ) ? targetMD.displayname : arguments.bundlePath );
		
		// get test target specs to test for this bundle
		var testSpecs = getTestMethods( target );
		var testSpecsCount = arrayLen( testSpecs );
		
		// record global stats
		arguments.testResults.incrementSpecs( count=testSpecsCount );
		
		// Start stats for this spec bundle
		var bundleStats = arguments.testResults.startBundleStats( bundlePath=arguments.bundlePath, 
																  name=bundleName, 
																  specCount=testSpecsCount );

		// execute beforeAll(), beforeTests()
		if( structKeyExists( target, "beforeAll" ) ){ target.beforeAll(); }
		if( structKeyExists( target, "beforeTests" ) ){ target.beforeTests(); }
		
		// iterate and test specs in this bundle
		for( var thisMethod in testSpecs ){
			testSpec( target, thisMethod, arguments.testResults, bundleStats );
		}
		
		// execute afterAll(), afterTests()
		if( structKeyExists( target, "afterAll" ) ){ target.afterAll(); }
		if( structKeyExists( target, "afterTests" ) ){ target.afterTests(); }
		
		// end the bundle stats time count
		bundleStats.endTime = getTickCount();
		
		return this;
	}
	
	private function testSpec(
		required target,
		required method,
		required testResults, 
		required bundleStats){
			
		try{
			// init spec tests
			var specStats = arguments.testResults.startSpecStats( arguments.method, arguments.bundleStats );
			
			// execute beforeEach(), setup()
			if( structKeyExists( arguments.target, "beforeEach" ) ){ arguments.target.beforeEach(); }
			if( structKeyExists( arguments.target, "setup" ) ){ arguments.target.setup(); }
			
			// Execute Test Method
			evaluate( "arguments.target.#arguments.method#()" );
			
			// execute afterEach(), teardown()
			if( structKeyExists( arguments.target, "afterEach" ) ){ arguments.target.afterEach(); }
			if( structKeyExists( arguments.target, "teardown" ) ){ arguments.target.teardown(); }
			
			// store end time and stats
			specStats.endTime 	= getTickCount();
			specStats.status 	= "Passed";
			arguments.testResults.incrementSpecStatus(type="pass");
			arguments.bundleStats.totalPass++;
		}
		catch("TestBox.AssertionFailed" e){
			// increment failures
			specStats.status = "Failed";
			arguments.bundleStats.totalFail++;
			arguments.testResults.incrementSpecStatus(type="fail");
		}
		catch(any e){
			// increment errors
			specStats.error 	= e;
			specStats.status 	= "Error";
			arguments.bundleStats.totalError++;
			arguments.testResults.incrementSpecStatus(type="error");
		}
		
		return this;
	}
	
	private array function getTestMethods(required any target){
		var methodNames = [];
		
		for( var thisMethod in structKeyArray( arguments.target ) ) {
			// only valid test names are allowed, those that ^test
			if( isTestMethodName( thisMethod ) ) {
				arrayAppend( methodNames, thisMethod );
			}
		}
		
		// TODO: add spec descriptions

		return methodNames;
	}
	
	private boolean function isTestMethodName( required string methodName ) {
		// All test methods must start with the term, "test". 
		return( !! reFindNoCase( "^test", methodName ) );
	}

	
	private function inflateBundles(required any bundles){
		variables.bundles = ( isSimpleValue( arguments.bundles ) ? listToArray( arguments.bundles ) : arguments.bundles );
	}
	
}