<cfcomponent name="BookingDetail" extends="com.shortstravel.AbstractEntity" accessors="true">

	<cfproperty name="airBillingAddress" />
	<cfproperty name="airBillingCity" />
	<cfproperty name="airBillingName" />
	<cfproperty name="airBillingState" />
	<cfproperty name="airBillingZip" />
	<cfproperty name="airCCExpiration" />
	<cfproperty name="airCCMonth" />
	<cfproperty name="airCCNumber" />
	<cfproperty name="airCCYear" />
	<cfproperty name="airFOPID" />
	<cfproperty name="airReasonCode" />
	<cfproperty name="airSaveCard" />
	<cfproperty name="airSaveName" />
	<cfproperty name="carFF" />
	<cfproperty name="carFOPID" />
	<cfproperty name="carReasonCode" />
	<cfproperty name="createProfile" />
	<cfproperty name="hotelBillingName" />
	<cfproperty name="hotelCCExpiration" />
	<cfproperty name="hotelCCMonth" />
	<cfproperty name="hotelCCNumber" />
	<cfproperty name="hotelCCYear" />
	<cfproperty name="hotelFF" />
	<cfproperty name="hotelFOPID" />
	<cfproperty name="hotelReasonCode" />
	<cfproperty name="hotelSaveCard" />
	<cfproperty name="hotelSaveName" />
	<cfproperty name="lostSavings" />
	<cfproperty name="password" />
	<cfproperty name="saveChanges" />
	<cfproperty name="specialRequests" />
	<cfproperty name="serviceRequests" />
	<cfproperty name="sort1" />
	<cfproperty name="sort2" />
	<cfproperty name="sort3" />
	<cfproperty name="sort4" />
	<cfproperty name="udid111" />
	<cfproperty name="udid112" />
	<cfproperty name="udid113" />
	<cfproperty name="username" />

	<cffunction name="init" returntype="any" access="remote" output="false">

		<cfset setAirBillingAddress( '' )>
		<cfset setAirBillingCity( '' )>
		<cfset setAirBillingName( '' )>
		<cfset setAirBillingCity( '' )>
		<cfset setAirBillingName( '' )>
		<cfset setAirBillingState( '' )>
		<cfset setAirBillingZip( '' )>
		<cfset setAirCCExpiration( '' )>
		<cfset setAirCCMonth( '' )>
		<cfset setAirCCNumber( '' )>
		<cfset setAirCCYear( '' )>
		<cfset setAirFOPID( '' )>
		<cfset setAirReasonCode( '' )>
		<cfset setAirSaveCard( false )>
		<cfset setAirSaveName( '' )>
		<cfset setCarFF( '' )>
		<cfset setCarFOPID( '' )>
		<cfset setCarReasonCode( '' )>
		<cfset setCreateProfile( false )>
		<cfset setHotelBillingName( '' )>
		<cfset setHotelCCExpiration( '' )>
		<cfset setHotelCCMonth( '' )>
		<cfset setHotelCCNumber( '' )>
		<cfset setHotelCCYear( '' )>
		<cfset setHotelFF( '' )>
		<cfset setHotelFOPID( '' )>
		<cfset setHotelReasonCode( '' )>
		<cfset setHotelSaveCard( false )>
		<cfset setHotelSaveName( '' )>
		<cfset setLostSavings( '' )>
		<cfset setPassword( '' )>
		<cfset setSaveChanges( false )>
		<cfset setSpecialRequests( '' )>
		<cfset setServiceRequests( '' )>
		<cfset setSort1( '' )>
		<cfset setSort2( '' )>
		<cfset setSort3( '' )>
		<cfset setSort4( '' )>
		<cfset setUDID111( '' )>
		<cfset setUDID112( '' )>
		<cfset setUDID113( '' )>
		<cfset setUsername( '' )>

		<cfreturn this />
	</cffunction>

</cfcomponent>