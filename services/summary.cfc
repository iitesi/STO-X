<cfcomponent output="false" accessors="true">

	<cfproperty name="BookingDSN" />
	<cfproperty name="CorporateProductionDSN" />

	<cffunction name="init" returntype="any" access="public" output="false">
		<cfargument name="BookingDSN" type="any" required="true"/>
		<cfargument name="CorporateProductionDSN" type="any" required="true"/>

		<cfset setBookingDSN( arguments.BookingDSN ) />
		<cfset setCorporateProductionDSN( arguments.CorporateProductionDSN ) />

		<cfreturn this />
	</cffunction>

	<cffunction name="getTraveler" returntype="any" access="public" output="false">
		<cfargument name="searchID" required="true" type="numeric">
		<cfargument name="travelerNumber" required="true" type="numeric">

		<cfreturn session.searches[arguments.searchID].travelers[arguments.travelerNumber] />
	</cffunction>

	<cffunction name="getOutOfPolicy" output="false">
		<cfargument name="acctID" required="true" type="numeric">
		<cfargument name="tmcID" required="false" type="numeric" default="1">

		<cfquery name="local.qOutOfPolicy" datasource="Corporate_Production" cachedwithin="#CreateTimeSpan(30,0,0,0)#">
			SELECT FareSavingsCode
				, Description
			FROM FareSavingsCode
			WHERE STO = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
				AND FareSavingsCodeID NOT IN (35,114)
				<!--- Short's/Internal TMC --->
				<cfif listFind('1,2', arguments.tmcID)>
					AND TMCID = <cfqueryparam value="1" cfsqltype="cf_sql_integer" />
					<!--- NASCAR --->
					<cfif arguments.acctID EQ 348>
						AND Acct_ID = <cfqueryparam value="#arguments.acctID#" cfsqltype="cf_sql_integer" />
					<cfelse>
						AND Acct_ID IS NULL
					</cfif>
				<!--- External TMC --->
				<cfelse>
					AND TMCID = <cfqueryparam value="#arguments.tmcID#" cfsqltype="cf_sql_integer" />
				</cfif>
			ORDER BY FareSavingsCode
		</cfquery>

		<cfreturn qOutOfPolicy>
	</cffunction>

	<cffunction name="getStates" output="false">

		<cfquery name="local.qStates" datasource="#getBookingDSN()#" cachedwithin="#CreateTimeSpan(30,0,0,0)#">
			SELECT State_Code
				, State_Name
			FROM LU_States
			WHERE State_Country = 'United States'
			ORDER BY State_Code
		</cfquery>

		<cfreturn qStates>
	</cffunction>

	<cffunction name="getLSUAccountID" output="false">
		<cfargument name="Traveler">

		<cfset local.accountID = arguments.Traveler.getAccountID()>
		<cfif arguments.Traveler.getBookingDetail().getAirFOPID() CONTAINS 'bta_'>
			<cfquery name="local.qAccountID" datasource="#getCorporateProductionDSN()#">
				SELECT AccountID
				FROM BTAs
					, OU_BTAs
					, OU_Values
				WHERE BTAs.BTA_ID = OU_BTAs.BTA_ID
					AND OU_BTAs.Value_ID = OU_Values.Value_ID
					AND OU_BTAs.BTA_ID = <cfqueryparam value="#replace(arguments.Traveler.getBookingDetail().getAirFOPID(), 'bta_', '')#" cfsqltype="cf_sql_integer">
					AND BTAs.Acct_ID = <cfqueryparam value="255" cfsqltype="cf_sql_integer">
			</cfquery>
			<cfif qAccountID.AccountID NEQ ''>
				<cfset accountID = qAccountID.AccountID>
			</cfif>
		</cfif>

		<cfreturn accountID>
	</cffunction>

	<cffunction name="getTXExceptionCodes" output="false">

		<cfquery name="local.qTXExceptionCodes" datasource="Corporate_Production" cachedwithin="#CreateTimeSpan(30,0,0,0)#">
			SELECT FareSavingsCode
				, Description
			FROM FareSavingsCode
			WHERE Acct_ID = <cfqueryparam value="235" cfsqltype="cf_sql_integer">
				AND STO = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
			ORDER BY FareSavingsCode
		</cfquery>

		<cfreturn qTXExceptionCodes>
	</cffunction>

	<cffunction name="determineFees" access="public" output="false">
		<cfargument name="acctID" type="numeric" required="true">
		<cfargument name="userID" type="numeric" required="true">
		<cfargument name="Filter" type="any" required="true">
		<cfargument name="Air" required="false" default="">

		<cfset local.fees = {}>
		<cfset local.feeType = ''>
		<cfset local.fees.complex = false>

		<!--- Determine if an agent is booking for the traveler --->
		<cfquery name="local.qAgentSine" datasource="Corporate_Production" cachedwithin="#createTimeSpan(1,0,0,0)#">
			SELECT AccountID
			FROM Payroll_Users
			WHERE User_ID = <cfqueryparam value="#arguments.userID#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfif isStruct(arguments.Air)>
			<cfif local.qAgentSine.AccountID EQ ''>
				<cfset local.feeType = 'ONLINE'>
			<cfelse>
				<cfset local.feeType = 'DOM'>
			</cfif>

			<cfset local.cities = {}>
			<cfset local.segmentCount = 0>
			<cfloop collection="#arguments.Air.Groups#" item="local.group" index="local.groupIndex">
				<cfloop collection="#group.Segments#" item="local.segment" index="local.segmentIndex">
					<cfset local.cities[local.segment.Origin] = ''>
					<cfset local.cities[local.segment.Destination] = ''>
					<cfset local.segmentCount++>
				</cfloop>
			</cfloop>

			<cfquery name="local.qSearch" datasource="#getBookingDSN()#">
				SELECT Country_Code
				FROM lu_Geography
				WHERE Location_Code IN (<cfqueryparam value="#structKeyList(cities)#" cfsqltype="cf_sql_varchar" list="true">)
					AND Location_Type = <cfqueryparam value="125" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfset local.intl = false>
			<cfloop query="local.qSearch">
				<cfif local.qSearch.Country_Code NEQ 'US'>
					<cfset local.intl = true>
					<cfif local.qAgentSine.AccountID NEQ ''>
						<cfset local.feeType = 'INTL'>
					</cfif>
				</cfif>
			</cfloop>

			<cfif (local.feeType EQ 'INTL' OR local.intl)
				AND (ArrayLen(arguments.Air.Carriers) GT 1
				OR arguments.Filter.getAirType() EQ 'MD'
				OR local.segmentCount GT 6)>
					<cfset local.fees.complex = true>
					<cfif local.qAgentSine.AccountID NEQ ''>
						<cfset local.feeType = 'INTLRD'>
					</cfif>
			</cfif>
		<cfelse>
			<cfif local.qAgentSine.AccountID EQ ''>
				<cfset local.feeType = 'OAUX'>
			<cfelse>
				<cfset local.feeType = 'MAUX'>
			</cfif>
		</cfif>

		<cfquery name="local.qRequest" datasource="Corporate_Production">
			SELECT IsNull(Fee_Amount, 0) AS Fee_Amount
			FROM Account_Fees
			WHERE Acct_ID = <cfqueryparam value="#arguments.AcctID#" cfsqltype="cf_sql_integer">
				AND Fee_Type = <cfqueryparam value="ORQST" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfquery name="local.qSpecificFee" datasource="Corporate_Production">
			SELECT IsNull(Fee_Amount, 0) AS Fee_Amount
			FROM Account_Fees
			WHERE Acct_ID = <cfqueryparam value="#arguments.AcctID#" cfsqltype="cf_sql_integer">
				AND Fee_Type = <cfqueryparam value="#feeType#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfif local.qAgentSine.AccountID EQ ''>
			<cfset local.auxFeeType = 'OAUX'>
		<cfelse>
			<cfset local.auxFeeType = 'MAUX'>
		</cfif>

		<cfif local.feeType NEQ local.auxFeeType>
			<cfquery name="local.qSpecificAuxFee" datasource="Corporate_Production">
				SELECT IsNull(Fee_Amount, 0) AS Fee_Amount
				FROM Account_Fees
				WHERE Acct_ID = <cfqueryparam value="#arguments.AcctID#" cfsqltype="cf_sql_integer">
					AND Fee_Type = <cfqueryparam value="#auxFeeType#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfset local.fees.auxFee = (local.qSpecificAuxFee.Fee_Amount NEQ '' ? local.qSpecificAuxFee.Fee_Amount : 0)>
		<cfelse>
			<cfset local.fees.auxFee = (local.qSpecificFee.Fee_Amount NEQ '' ? local.qSpecificFee.Fee_Amount : 0)>
		</cfif>

		<cfset local.fees.requestFee = (local.qRequest.Fee_Amount NEQ '' ? local.qRequest.Fee_Amount : 0)>
		<cfset local.fees.fee = (local.qSpecificFee.Fee_Amount NEQ '' ? local.qSpecificFee.Fee_Amount : 0)>
		<!--- <cfset local.fees.complex = (local.feeType NEQ 'OINTLRD' AND local.feeType NEQ 'INTLRD' ? false : true)> --->
		<cfset local.fees.agent = local.qAgentSine.AccountID>
		<cfset local.fees.airFee = (local.qSpecificFee.Fee_Amount NEQ '' ? local.qSpecificFee.Fee_Amount : 0)>
		<cfset local.fees.airFeeType = local.feeType>
		<cfset local.fees.auxFeeType = local.auxFeeType>

		<cfreturn local.fees />
	</cffunction>

	<cffunction name="error" output="false">
		<cfargument name="Traveler" required="true">
		<cfargument name="Air" required="false" default="">
		<cfargument name="Hotel" required="false" default="">
		<cfargument name="Vehicle" required="false" default="">
		<cfargument name="Policy" required="false" default="">
		<cfargument name="Filter" required="false" default="">
		<cfargument name="acctID" required="false" default="">
		<cfargument name="searchID" required="false" default="">
		<cfargument name="password" required="false" default="">
		<cfargument name="passwordConfirm" required="false" default="">
		<cfargument name="action" required="false" default="">

		<cfset local.error = {}>

		<!--- Profile-related form fields --->
		<cfif arguments.Traveler.getFirstName() EQ ''>
			<cfset local.error.fullname = ''>
		</cfif>
		<cfif (arguments.Traveler.getNoMiddleName() EQ 0 AND arguments.Traveler.getMiddleName() EQ '')
		OR (arguments.Traveler.getNoMiddleName() EQ 1 AND arguments.Traveler.getMiddleName() NEQ '')>
			<cfset local.error.fullname = ''>
		</cfif>
		<cfif arguments.Traveler.getLastName() EQ ''>
			<cfset local.error.fullname = ''>
		</cfif>
		<cfif arguments.Traveler.getPhoneNumber() EQ ''>
			<cfset local.error.phoneNumber = ''>
		</cfif>
		<cfif arguments.Traveler.getWirelessPhone() EQ ''>
			<cfset local.error.wirelessPhone = ''>
		</cfif>
		<cfif NOT IsValid('Email', arguments.Traveler.getEmail())>
			<cfset local.error.email = ''>
		</cfif>
		<cfloop list="#replace(replace(arguments.Traveler.getCCEmails(), ',', ';', 'ALL'), ' ', '', 'ALL')#" delimiters=";" index="local.email">
			<cfif NOT isValid('Email', email)>
				<cfset local.error.ccEmails = ''>
			</cfif>
		</cfloop>
		<cfif NOT isDate(arguments.Traveler.getBirthdate())>
			<cfset local.error.birthdate = ''>
		</cfif>
		<cfif arguments.Traveler.getGender() EQ ''>
			<cfset local.error.gender = ''>
		</cfif>

		<!--- If a guest traveler has checked the checkbox to create a new profile --->
		<cfif arguments.Traveler.getBookingDetail().getCreateProfile() EQ 1 AND arguments.Traveler.getUserID() EQ 0>
			<!--- Perform a password check --->
			<cfif arguments.password EQ ''>
				<cfset local.error.password = '' />
			<cfelse>
				<cfset local.passedTest = true />
				<!--- If less than 8 characters --->
				<cfif len(trim(arguments.password)) LT 8>
					<cfset local.passedTest = false />
				<cfelse>
					<cfset local.counter = 0 />
					<!--- If contains at least one uppercase letter --->
					<cfif REFind("[[:upper:]]", trim(arguments.password))>
						<cfset local.counter++ />
					</cfif>
					<!--- If contains at least one lowercase letter --->
					<cfif REFind("[[:lower:]]", trim(arguments.password))>
						<cfset local.counter++ />
					</cfif>
					<!--- If contains at least one number --->
					<cfif REFind("[[:digit:]]", trim(arguments.password))>
						<cfset local.counter++ />
					</cfif>
					<!--- If contains at least one special character --->
					<cfif REFind("[[:punct:]]", trim(arguments.password))>
						<cfset local.counter++ />
					</cfif>
				</cfif>
				<cfif NOT local.passedTest OR local.counter LT 3>
					<cfset local.error.password = '' />
				</cfif>
			</cfif>
			<cfif (arguments.passwordConfirm EQ '') OR (arguments.passwordConfirm NEQ arguments.password)>
				<cfset local.error.passwordConfirm = '' />
			</cfif>
		</cfif>

		<cfloop array="#arguments.Traveler.getOrgUnit()#" index="local.ouIndex" item="local.OU">
			<cfset local.field = local.OU.getOUType() & local.OU.getOUPosition()>
			<cfif local.OU.getOURequired() EQ 1
				AND ((local.OU.getOUFreeform() EQ 1 AND len(trim( local.OU.getValueReport() )) EQ 0)
					OR (local.OU.getOUFreeform() NEQ 1 AND (len(trim( local.OU.getValueID() )) EQ 0 OR local.OU.getValueID() EQ 0 OR local.OU.getValueID() EQ -1)))>
				<cfset local.error[field] = '' />
			</cfif>
			<cfif local.OU.getOUFreeform() EQ 1
				AND local.OU.getOUPattern() NEQ ''
				AND len(trim( local.OU.getValueReport() )) GT 0>
				<cfset local.patternCharacter = ''>
				<cfset local.stringCharacter = ''>

				<cfloop from="1" to="#len(local.OU.getOUPattern())#" index="local.character">
					<cfset local.patternCharacter = mid(local.OU.getOUPattern(), local.character, 1)>
					<cfset local.stringCharacter = mid(local.OU.getValueReport(), local.character, 1)>
					<cfif (isNumeric(local.patternCharacter) AND NOT isNumeric(local.stringCharacter))
						OR (local.patternCharacter EQ 'A' AND REFind("[A-Za-z]", local.stringCharacter, 1) NEQ 1)
						OR (local.patternCharacter EQ 'x' AND REFind("[^a-zA-Z0-9\s]", local.stringCharacter, 1) EQ 1)
						OR (REFind("[^A-Za-z|^0-9]", local.patternCharacter, 1) EQ 1 AND local.patternCharacter NEQ local.stringCharacter)>
						<cfset local.error[field] = '' />
						<cfbreak>
					</cfif>
				</cfloop>
				<cfif len(trim( local.OU.getValueReport() )) GT 0
					AND (len(trim( local.OU.getValueReport() )) GT local.OU.getOUMax()
					OR len(trim( local.OU.getValueReport() )) LT local.OU.getOUMin())>
					<cfset local.error[field] = '' />
				</cfif>
			</cfif>
		</cfloop>

		<!--- Form fields not needed for profile creation --->
		<cfif arguments.action NEQ "CREATE PROFILE">
			<cfif NOT arguments.Traveler.getBookingDetail().getAirNeeded()
				AND NOT arguments.Traveler.getBookingDetail().getHotelNeeded()
				AND NOT arguments.Traveler.getBookingDetail().getCarNeeded()>
				<cfset local.error.travelServices = ''>
			</cfif>

			<cfif arguments.Traveler.getBookingDetail().getAirNeeded()>
				<!--- For LSU (acctID 255) --->
				<cfif arguments.Traveler.getBookingDetail().getAirFOPID() EQ 'bta_0' AND arguments.Traveler.getBookingDetail().getNewAirCC() NEQ 1>
					<!--- Exclude SOLA (acctID 254) ghost payment/central bill cards --->
					<cfif arguments.acctID NEQ 254>
						<cfset local.error.airFOPID = ''>
					</cfif>
				<cfelseif arguments.Traveler.getBookingDetail().getAirFOPID() EQ 0 OR arguments.Traveler.getBookingDetail().getNewAirCC() EQ 1>
					<!--- Removing isNumeric logic now that new credit card numbers are masked --->
					<!--- <cfif Len(arguments.Traveler.getBookingDetail().getAirCCNumber()) LT 15
						OR NOT isNumeric(arguments.Traveler.getBookingDetail().getAirCCNumber())> --->
					<cfset local.airCCError = false />
					<cfif Len(arguments.Traveler.getBookingDetail().getAirCCNumber()) LT 15>
						<cfset local.airCCError = true />
					</cfif>
					<cfif arguments.Traveler.getBookingDetail().getAirCCMonth() EQ ''
						OR arguments.Traveler.getBookingDetail().getAirCCYear() EQ ''>
						<cfset local.airCCError = true />
					<cfelse>
						<cfset local.airCCExpiration = createDate(arguments.Traveler.getBookingDetail().getAirCCYear(), arguments.Traveler.getBookingDetail().getAirCCMonth(), 1)>
						<cfset local.airCCExpiration = createDate(year(local.airCCExpiration), month(local.airCCExpiration), daysInMonth(local.airCCExpiration))>
						<cfif local.airCCExpiration LTE now()>
							<cfset local.airCCError = true />
						</cfif>
					</cfif>
					<cfif arguments.Traveler.getBookingDetail().getAirCCCVV() EQ ''
						OR NOT isNumeric(arguments.Traveler.getBookingDetail().getAirCCCVV())>
						<cfset local.airCCError = true />
					</cfif>
					<cfif arguments.Traveler.getBookingDetail().getAirBillingName() EQ ''>
						<cfset local.airCCError = true />
					</cfif>
					<cfif arguments.Traveler.getBookingDetail().getAirBillingAddress() EQ ''>
						<cfset local.airCCError = true />
					</cfif>
					<cfif arguments.Traveler.getBookingDetail().getAirBillingCity() EQ ''>
						<cfset local.airCCError = true />
					</cfif>
					<cfif arguments.Traveler.getBookingDetail().getAirBillingState() EQ ''
						OR arguments.Traveler.getBookingDetail().getAirBillingZip() EQ ''>
						<cfset local.airCCError = true />
					</cfif>
					<cfif airCCError>
						<cfset local.error.airFOPID = '' />
					</cfif>
				</cfif>

				<!--- To Do: Pass variables in --->
				<cfset local.lowestFareTripID = session.searches[arguments.searchid].stLowFareDetails.aSortFare[1] />
				<cfset local.lowestFare = session.searches[arguments.searchid].stTrips[lowestFareTripID].Total />
				<!--- To Do: Pass variables in --->

				<cfset local.inPolicy = (ArrayLen(arguments.Air.aPolicies) GT 0 ? false : true)>
				<cfif arguments.Policy.Policy_HotelNotBooking EQ 1
					AND arguments.Traveler.getBookingDetail().getHotelNeeded() EQ 0
					AND arguments.Traveler.getBookingDetail().getHotelNotBooked() EQ ''
					AND arguments.Filter.getAirType() EQ 'RT'>
					<cfset local.error.hotelNotBooked = ''>
				</cfif>
				<cfif NOT inPolicy
					AND arguments.Policy.Policy_AirReasonCode EQ 1>
					<cfif arguments.Traveler.getBookingDetail().getAirReasonCode() EQ ''>
						<cfset local.error.airReasonCode = ''>
					</cfif>
				</cfif>
				<cfif arguments.Air.Total GT lowestFare
					AND (inPolicy OR arguments.Policy.Policy_AirReasonCode EQ 0)
					AND arguments.Policy.Policy_AirLostSavings EQ 1>
					<cfif arguments.Traveler.getBookingDetail().getLostSavings() EQ ''>
						<cfset local.error.lostSavings = ''>
					</cfif>
				</cfif>
				<cfif arguments.acctID EQ 235>
					<cfif arguments.Traveler.getBookingDetail().getUDID113() EQ ''>
						<cfset local.error.udid113 = ''>
					</cfif>
				</cfif>

			</cfif>

			<cfif isObject(arguments.Hotel)
				AND arguments.Traveler.getBookingDetail().getHotelNeeded()>

				<cfif arguments.Traveler.getBookingDetail().getHotelFOPID() EQ 0 OR arguments.Traveler.getBookingDetail().getNewHotelCC() EQ 1>
					<cfset local.hotelCCError = false />
					<cfif Len(arguments.Traveler.getBookingDetail().getHotelCCNumber()) LT 15>
						<cfset local.hotelCCError = true />
					</cfif>
					<cfif arguments.Traveler.getBookingDetail().getHotelCCMonth() EQ ''
						OR arguments.Traveler.getBookingDetail().getHotelCCYear() EQ ''>
						<cfset local.hotelCCError = true />
					<cfelse>
						<cfset local.hotelCCExpiration = createDate(arguments.Traveler.getBookingDetail().getHotelCCYear(), arguments.Traveler.getBookingDetail().getHotelCCMonth(), 1)>
						<cfset local.hotelCCExpiration = createDate(year(local.hotelCCExpiration), month(local.hotelCCExpiration), daysInMonth(local.hotelCCExpiration))>
						<cfif local.hotelCCExpiration LTE now()>
							<cfset local.hotelCCError = true />
						</cfif>
					</cfif>
					<cfif arguments.Traveler.getBookingDetail().getHotelBillingName() EQ ''>
						<cfset local.hotelCCError = true />
					</cfif>
					<cfif hotelCCError>
						<cfset local.error.hotelFOPID = '' />
					</cfif>
				</cfif>

				<cfif NOT arguments.Hotel.getRooms()[1].getIsInPolicy()
					AND arguments.Policy.Policy_HotelReasonCode>
					<cfif arguments.Traveler.getBookingDetail().getHotelReasonCode() EQ ''>
						<cfset local.error.hotelReasonCode = ''>
					</cfif>
				</cfif>

				<cfif arguments.acctID EQ 235>
					<cfif arguments.Traveler.getBookingDetail().getUDID112() EQ ''>
						<cfset local.error.udid112 = ''>
					</cfif>
				</cfif>

			</cfif>

			<cfif isObject(arguments.Vehicle)
				AND arguments.Traveler.getBookingDetail().getCarNeeded()>

				<cfif NOT arguments.Vehicle.getPolicy()
					AND arguments.Policy.Policy_CarReasonCode EQ 1>
					<cfif arguments.Traveler.getBookingDetail().getCarReasonCode() EQ ''>
						<cfset local.error.carReasonCode = ''>
					</cfif>
				</cfif>

				<cfif arguments.acctID EQ 235>
					<cfif arguments.Traveler.getBookingDetail().getUDID111() EQ ''>
						<cfset local.error.udid111 = ''>
					</cfif>
				</cfif>

			</cfif>
		</cfif>

		<cfreturn error/>
	</cffunction>

	<cffunction name="determineApproval" output="false">
		<cfargument name="Policy" required="true">
		<cfargument name="Filter" required="true">
		<cfargument name="Traveler" required="true">

		<cfset local.approval = {}>
		<cfset local.approval.approvalNeeded = false>
		<cfset local.approval.approvers = ''>

		<cfif arguments.Traveler.getBookingDetail().getAirNeeded()
			AND arguments.Policy.Policy_AirApproval EQ 1
			AND (arguments.Traveler.getBookingDetail().getAirFOPID() DOES NOT CONTAIN 'fop_'
			AND arguments.Traveler.getBookingDetail().getAirFOPID() NEQ 0
			AND arguments.Traveler.getBookingDetail().getNewAirCC() NEQ 1)>
			<cfset local.approval.approvalNeeded = true>
		</cfif>

		<cfif arguments.Traveler.getBookingDetail().getHotelNeeded()
			AND arguments.Policy.Policy_HotelApproval EQ 1
			AND (arguments.Traveler.getBookingDetail().getHotelFOPID() DOES NOT CONTAIN 'fop_'
			AND arguments.Traveler.getBookingDetail().getHotelFOPID() NEQ 0
			AND arguments.Traveler.getBookingDetail().getNewHotelCC() NEQ 1)>
			<cfset local.approval.approvalNeeded = true>
		</cfif>

		<cfif arguments.Traveler.getBookingDetail().getCarNeeded()
			AND arguments.Policy.Policy_CarApproval EQ 1
			AND (arguments.Traveler.getBookingDetail().getCarFOPID() DOES NOT CONTAIN 'fop_'
			AND arguments.Traveler.getBookingDetail().getCarFOPID() NEQ 0)>
			<cfset local.approval.approvalNeeded = true>
			<!--- <cfif arguments.CarCC_Type EQ 1>Direct Bill car
				<cfset local.approval = 'Y'>
			</cfif> --->
		</cfif>

		<cfif local.approval.approvalNeeded>
			<cfset local.qTravelApprovers = ''>
			<cfif arguments.Filter.getAcctID() NEQ 350>
				<cfif arguments.Traveler.getAccountID() NEQ ''>
					<cfstoredproc procedure="sp_getAllTravelApprovers" datasource="Corporate_Production">
						<cfprocparam value="#arguments.Traveler.getAccountID()#" cfsqltype="cf_sql_varchar" />
						<cfprocresult name="local.qTravelApprovers" />
					</cfstoredproc>
				</cfif>
			<cfelseif arguments.Filter.getAcctID() EQ 350><!--- Dillard University --->
				<cfset local.sort2 = ''>
				<cfloop array="#arguments.Traveler.getOrgUnit()#" index="local.orgUnitIndex" item="local.OrgUnit">
					<cfif local.OrgUnit.getOUType() EQ 'Sort'
						AND local.OrgUnit.getOUPosition() EQ 2>
						<cfset local.sort2 = local.OrgUnit.getValueID()>
					</cfif>
				</cfloop>
				<cfif local.sort2 NEQ ''>
					<cfquery name="local.qTravelApprovers" datasource="Corporate_Production">
						SELECT Email
						FROM Approval_Users, Users
						WHERE Dept_ID = <cfqueryparam value="#local.sort2#" cfsqltype="cf_sql_varchar">
							AND Approval_Users.User_ID = Users.User_ID
					</cfquery>
				</cfif>
			</cfif>
			<cfif isQuery("local.qTravelApprovers")>
				<cfset local.approval.approvers = replace(valueList(local.qTravelApprovers.Email), ',', ', ', 'ALL')>
			</cfif>
		</cfif>

		<cfreturn local.approval>
	</cffunction>

	<cffunction name="updateTraveler" output="false">
        <cfargument name="datetimestamp" required="true" />
        <cfargument name="token" required="true" />
        <cfargument name="acctID" required="true" />
        <cfargument name="userID" required="true" />
        <cfargument name="searchID" required="true" />
        <cfargument name="ccData" required="true" />

        <!--- Tried using urlEncodedFormat in the URL string, but had too many complications --->
		<!--- <cfset local.unencryptedCCData = decrypt(toString(toBinary(urlDecode(arguments.ccData))), getEncryptionKey()) /> --->

		<cfset local.encryptedCCData = toString(toBinary(arguments.ccData)) />

		<cfif cgi.http_host EQ "r.local">
			<cfset local.secureURL = "http://" & cgi.http_host />
		<cfelse>
			<cfset local.secureURL = "https://europa.shortstravel.com" />
		</cfif>

		<!--- Send the encrypted credit card data back over to the DMZ to decrypt the data --->
		<cfhttp url="#local.secureURL#/secure-sto/index.cfm?action=summary.decryptData" method="post" result="local.response">
			<cfhttpparam type="formfield" name="datetimestamp" value="#arguments.datetimestamp#" />
			<cfhttpparam type="formfield" name="token" value="#arguments.token#" />
			<cfhttpparam type="formfield" name="acctID" value="#arguments.acctID#" />
			<cfhttpparam type="formfield" name="userID" value="#arguments.userID#" />
			<cfhttpparam type="formfield" name="searchID" value="#arguments.searchID#" />
			<cfhttpparam type="formfield" name="cardData" value="#local.encryptedCCData#" />
		</cfhttp>

		<cfif isJSON(local.response.filecontent)>
			<cfset local.unencryptedCCData = deserializeJSON(local.response.filecontent) />
			<cfset local.newCC = 1 />
			<cfif unencryptedCCData.cardType IS 'AX'>
				<cfset local.cardNumber = '***********#unencryptedCCData.cardNumberRight4#' />
			<cfelseif len(unencryptedCCData.cardType)>
				<cfset local.cardNumber = '************#unencryptedCCData.cardNumberRight4#' />
			<cfelse>
				<!--- If a card has been removed --->
				<cfset local.cardNumber = '' />
				<cfset local.newCC = 0 />
			</cfif>

			<cfif unencryptedCCData.paymentType IS 'air'>
				<cfset session.searches[arguments.searchID].Travelers[unencryptedCCData.travelerNumber].getBookingDetail().setNewAirCC( local.newCC ) />
				<cfset session.searches[arguments.searchID].Travelers[unencryptedCCData.travelerNumber].getBookingDetail().setAirFOPID( unencryptedCCData.pciID ) />
				<cfset session.searches[arguments.searchID].Travelers[unencryptedCCData.travelerNumber].getBookingDetail().setAirCCName( unencryptedCCData.cardName ) />
				<cfset session.searches[arguments.searchID].Travelers[unencryptedCCData.travelerNumber].getBookingDetail().setAirCCType( unencryptedCCData.cardType ) />
				<cfset session.searches[arguments.searchID].Travelers[unencryptedCCData.travelerNumber].getBookingDetail().setAirCCNumber( local.cardNumber ) />
				<cfset session.searches[arguments.searchID].Travelers[unencryptedCCData.travelerNumber].getBookingDetail().setAirCCNumberRight4( unencryptedCCData.cardNumberRight4 ) />
				<cfset session.searches[arguments.searchID].Travelers[unencryptedCCData.travelerNumber].getBookingDetail().setAirCCExpiration( unencryptedCCData.ccExpiration ) />
				<cfset session.searches[arguments.searchID].Travelers[unencryptedCCData.travelerNumber].getBookingDetail().setAirCCMonth( unencryptedCCData.ccMonth ) />
				<cfset session.searches[arguments.searchID].Travelers[unencryptedCCData.travelerNumber].getBookingDetail().setAirCCYear( unencryptedCCData.ccYear ) />
				<cfset session.searches[arguments.searchID].Travelers[unencryptedCCData.travelerNumber].getBookingDetail().setAirCCCVV( unencryptedCCData.ccCVV ) />
				<cfset session.searches[arguments.searchID].Travelers[unencryptedCCData.travelerNumber].getBookingDetail().setAirBillingName( unencryptedCCData.billingName ) />
				<cfset session.searches[arguments.searchID].Travelers[unencryptedCCData.travelerNumber].getBookingDetail().setAirBillingAddress( unencryptedCCData.billingAddress ) />
				<cfset session.searches[arguments.searchID].Travelers[unencryptedCCData.travelerNumber].getBookingDetail().setAirBillingCity( unencryptedCCData.billingCity ) />
				<cfset session.searches[arguments.searchID].Travelers[unencryptedCCData.travelerNumber].getBookingDetail().setAirBillingState( unencryptedCCData.billingState ) />
				<cfset session.searches[arguments.searchID].Travelers[unencryptedCCData.travelerNumber].getBookingDetail().setAirBillingZip( unencryptedCCData.billingZip ) />
			<cfelseif unencryptedCCData.paymentType IS 'hotel'>
				<cfset session.searches[arguments.searchID].Travelers[unencryptedCCData.travelerNumber].getBookingDetail().setNewHotelCC( local.newCC ) />
				<cfset session.searches[arguments.searchID].Travelers[unencryptedCCData.travelerNumber].getBookingDetail().setHotelFOPID( unencryptedCCData.pciID ) />
				<cfset session.searches[arguments.searchID].Travelers[unencryptedCCData.travelerNumber].getBookingDetail().setHotelCCName( unencryptedCCData.cardName ) />
				<cfset session.searches[arguments.searchID].Travelers[unencryptedCCData.travelerNumber].getBookingDetail().setHotelCCType( unencryptedCCData.cardType ) />
				<cfset session.searches[arguments.searchID].Travelers[unencryptedCCData.travelerNumber].getBookingDetail().setHotelCCNumber( local.cardNumber ) />
				<cfset session.searches[arguments.searchID].Travelers[unencryptedCCData.travelerNumber].getBookingDetail().setHotelCCNumberRight4( unencryptedCCData.cardNumberRight4 ) />
				<cfset session.searches[arguments.searchID].Travelers[unencryptedCCData.travelerNumber].getBookingDetail().setHotelCCExpiration( unencryptedCCData.ccExpiration ) />
				<cfset session.searches[arguments.searchID].Travelers[unencryptedCCData.travelerNumber].getBookingDetail().setHotelCCMonth( unencryptedCCData.ccMonth ) />
				<cfset session.searches[arguments.searchID].Travelers[unencryptedCCData.travelerNumber].getBookingDetail().setHotelCCYear( unencryptedCCData.ccYear ) />
				<cfset session.searches[arguments.searchID].Travelers[unencryptedCCData.travelerNumber].getBookingDetail().setHotelBillingName( unencryptedCCData.billingName ) />
			</cfif>
		<cfelse>
			<cfdump var="#local.response#" label="local.response">
			<cfdump var="#arguments#" label="arguments" abort>
		</cfif>

		<cfreturn />
	</cffunction>

</cfcomponent>