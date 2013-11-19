<cfcomponent name="BookingDetail" extends="com.shortstravel.AbstractEntity" accessors="true">

	<cfproperty name="agent" />
	<cfproperty name="approvalNeeded" />
	<cfproperty name="approvers" />
	<cfproperty name="airNeeded" />
	<cfproperty name="airBillingAddress" />
	<cfproperty name="airBillingCity" />
	<cfproperty name="airBillingName" />
	<cfproperty name="airBillingState" />
	<cfproperty name="airBillingZip" />
	<cfproperty name="airCCExpiration" />
	<cfproperty name="airCCMonth" />
	<cfproperty name="airCCNumber" />
	<cfproperty name="airCCYear" />
	<cfproperty name="airCCCVV" />
	<cfproperty name="airConfirmation" />
	<cfproperty name="airFeeType" />
	<cfproperty name="airFOPID" />
	<cfproperty name="airLowestFare" />
	<cfproperty name="airLowestPublicFare" />
	<cfproperty name="airReasonCode" />
	<cfproperty name="airRefundableFare" />
	<cfproperty name="auxFeeType" />
	<cfproperty name="bookingFee" />
	<cfproperty name="carNeeded" />
	<cfproperty name="carConfirmation" />
	<cfproperty name="carFF" />
	<cfproperty name="carFOPID" />
	<cfproperty name="carReasonCode" />
	<cfproperty name="copyAirCC" />
	<cfproperty name="createProfile" />
	<cfproperty name="hotelNeeded" />
	<cfproperty name="hotelNotBooked" />
	<cfproperty name="hotelBillingName" />
	<cfproperty name="hotelCCExpiration" />
	<cfproperty name="hotelCCMonth" />
	<cfproperty name="hotelCCNumber" />
	<cfproperty name="hotelCCYear" />
	<cfproperty name="hotelConfirmation" />
	<cfproperty name="hotelFF" />
	<cfproperty name="hotelFOPID" />
	<cfproperty name="hotelReasonCode" />
	<cfproperty name="lostSavings" />
	<cfproperty name="nameChange" />
	<cfproperty name="newAirCC" />
	<cfproperty name="newHotelCC" />
	<cfproperty name="password" />
	<cfproperty name="preTrip" />
	<cfproperty name="reservationCode" />
	<cfproperty name="saveProfile" />
	<cfproperty name="specialRequests" />
	<cfproperty name="specialNeeds" />
	<cfproperty name="seats" />
	<cfproperty name="sort1" />
	<cfproperty name="sort2" />
	<cfproperty name="sort3" />
	<cfproperty name="sort4" />
	<cfproperty name="udid111" />
	<cfproperty name="udid112" />
	<cfproperty name="udid113" />
	<cfproperty name="universalLocatorCode" />
	<cfproperty name="username" />
	<cfproperty name="version" />

	<cffunction name="init" returntype="any" access="remote" output="false">

		<cfset setAgent( '' )>
		<cfset setApprovalNeeded( false )>
		<cfset setApprovers( '' )>
		<cfset setAirNeeded( false )>
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
		<cfset setAirCCCVV( '' )>
		<cfset setAirConfirmation( '' )>
		<cfset setAirFeeType( '' )>
		<cfset setAirFOPID( '' )>
		<cfset setAirLowestFare( 0 )>
		<cfset setAirLowestPublicFare( 0 )>
		<cfset setAirReasonCode( '' )>
		<cfset setAirRefundableFare( 0 )>
		<cfset setAuxFeeType( '' )>
		<cfset setBookingFee( 0 )>
		<cfset setCarNeeded( false )>
		<cfset setCarConfirmation( '' )>
		<cfset setCarFF( '' )>
		<cfset setCarFOPID( '' )>
		<cfset setCarReasonCode( '' )>
		<cfset setCopyAirCC( false )>
		<cfset setCreateProfile( false )>
		<cfset setHotelNeeded( false )>
		<cfset setHotelNotBooked( '' )>
		<cfset setHotelBillingName( '' )>
		<cfset setHotelCCExpiration( '' )>
		<cfset setHotelCCMonth( '' )>
		<cfset setHotelCCNumber( '' )>
		<cfset setHotelCCYear( '' )>
		<cfset setHotelConfirmation( '' )>
		<cfset setHotelFF( '' )>
		<cfset setHotelFOPID( '' )>
		<cfset setHotelReasonCode( '' )>
		<cfset setLostSavings( '' )>
		<cfset setNameChange( false )>
		<cfset setNewAirCC( 0 )>
		<cfset setNewHotelCC( 0 )>
		<cfset setPassword( '' )>
		<cfset setPreTrip( false )>
		<cfset setReservationCode( '' )>
		<cfset setSaveProfile( false )>
		<cfset setSeats( [] )>
		<cfset setSpecialRequests( '' )>
		<cfset setSpecialNeeds( '' )>
		<cfset setSort1( '' )>
		<cfset setSort2( '' )>
		<cfset setSort3( '' )>
		<cfset setSort4( '' )>
		<cfset setUDID111( '' )>
		<cfset setUDID112( '' )>
		<cfset setUDID113( '' )>
		<cfset setUniversalLocatorCode( '' )>
		<cfset setUsername( '' )>
		<cfset setVersion( 0 )>

		<cfreturn this />
	</cffunction>

</cfcomponent>