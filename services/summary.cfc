<cfcomponent output="false" accessors="true">

	<cfproperty name="BookingDSN" />

	<cffunction name="init" returntype="any" access="public" output="false">
		<cfargument name="BookingDSN" type="any" required="true"/>

		<cfset setBookingDSN( arguments.BookingDSN ) />

		<cfreturn this />
	</cffunction>

	<cffunction name="getTraveler" returntype="any" access="public" output="false">
		<cfargument name="searchID" required="true" type="numeric">
		<cfargument name="travelerNumber" required="true" type="numeric">

		<cfreturn session.searches[arguments.searchID].travelers[arguments.travelerNumber] />
	</cffunction>

	<cffunction name="getOutOfPolicy" output="false">
		<cfargument name="acctID" required="true" type="numeric">

		<cfquery name="local.qOutOfPolicy" datasource="Corporate_Production" cachedwithin="#CreateTimeSpan(30,0,0,0)#">
			SELECT FareSavingsCode
				, Description
			FROM FareSavingsCode
			WHERE STO = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
				AND FareSavingsCodeID NOT IN (35)
				<cfif arguments.acctID NEQ 348>
					AND Acct_ID IS NULL
				<cfelse>
					AND Acct_ID = <cfqueryparam value="348" cfsqltype="cf_sql_integer">
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

			<cfloop query="local.qSearch">
				<cfif local.qSearch.Country_Code NEQ 'US'>
					<cfif local.qAgentSine.AccountID EQ ''>
						<cfset local.feeType = 'OINTL'>
					<cfelse>
						<cfset local.feeType = 'INTL'>
					</cfif>
				</cfif>
			</cfloop>

			<cfif (local.feeType EQ 'OINTL' OR local.feeType EQ 'INTL')
				AND (ArrayLen(arguments.Air.Carriers) GT 1
				OR arguments.Filter.getAirType() EQ 'MD'
				OR local.segmentCount GT 6)>
					<cfif local.qAgentSine.AccountID EQ ''>
						<cfset local.feeType = 'OINTLRD'>
					<cfelse>
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
		<cfset local.fees.complex = (local.feeType NEQ 'OINTLRD' AND local.feeType NEQ 'INTLRD' ? false : true)>
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

		<cfset local.error = {}>

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
		<cfif NOT arguments.Traveler.getBookingDetail().getAirNeeded()
			AND NOT arguments.Traveler.getBookingDetail().getHotelNeeded()
			AND NOT arguments.Traveler.getBookingDetail().getCarNeeded()>
			<cfset local.error.travelServices = ''>
		</cfif>

		<cfloop array="#arguments.Traveler.getOrgUnit()#" index="local.ouIndex" item="local.OU">
			<cfset local.field = local.OU.getOUType() & local.OU.getOUPosition()>
			<cfif local.OU.getOURequired() EQ 1
				AND len(trim( local.OU.getValueReport() )) EQ 0>
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
						OR (local.patternCharacter EQ 'x' AND REFind("[^A-Za-z|^0-9]", local.stringCharacter, 1) EQ 1)
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

		<cfif arguments.Traveler.getBookingDetail().getAirNeeded()>

			<cfif arguments.Traveler.getBookingDetail().getAirFOPID() EQ 0>
				<cfif Len(arguments.Traveler.getBookingDetail().getAirCCNumber()) LT 15
					OR NOT isNumeric(arguments.Traveler.getBookingDetail().getAirCCNumber())>
					<cfset local.error.airCCNumber = ''>
				</cfif>
				<cfif arguments.Traveler.getBookingDetail().getAirCCMonth() EQ ''
					OR arguments.Traveler.getBookingDetail().getAirCCYear() EQ ''>
					<cfset local.error.airCCExpiration = ''>
				<cfelse>
					<cfset local.airCCExpiration = createDate(arguments.Traveler.getBookingDetail().getAirCCYear(), arguments.Traveler.getBookingDetail().getAirCCMonth(), 1)>
					<cfset local.airCCExpiration = createDate(year(local.airCCExpiration), month(local.airCCExpiration), daysInMonth(local.airCCExpiration))>
					<cfif local.airCCExpiration LTE now()>
						<cfset local.error.airCCExpiration = ''>
					</cfif>
				</cfif>
				<cfif arguments.Traveler.getBookingDetail().getAirCCCVV() EQ ''
					OR NOT isNumeric(arguments.Traveler.getBookingDetail().getAirCCCVV())>
					<cfset local.error.airCCCVV = ''>
				</cfif>
				<cfif arguments.Traveler.getBookingDetail().getAirBillingName() EQ ''>
					<cfset local.error.airBillingName = ''>
				</cfif>
				<cfif arguments.Traveler.getBookingDetail().getAirBillingAddress() EQ ''>
					<cfset local.error.airBillingAddress = ''>
				</cfif>
				<cfif arguments.Traveler.getBookingDetail().getAirBillingCity() EQ ''>
					<cfset local.error.airBillingCity = ''>
				</cfif>
				<cfif arguments.Traveler.getBookingDetail().getAirBillingState() EQ ''
					OR arguments.Traveler.getBookingDetail().getAirBillingZip() EQ ''>
					<cfset local.error.airBillingState = ''>
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

			<cfif arguments.Traveler.getBookingDetail().getHotelFOPID() EQ 0>
				<cfif Len(arguments.Traveler.getBookingDetail().getHotelCCNumber()) LT 15>
					<cfset local.error.hotelCCNumber = ''>
				</cfif>
				<cfif arguments.Traveler.getBookingDetail().getHotelCCMonth() EQ ''
					OR arguments.Traveler.getBookingDetail().getHotelCCYear() EQ ''>
					<cfset local.error.hotelCCExpiration = ''>
				<cfelse>
					<cfset local.hotelCCExpiration = createDate(arguments.Traveler.getBookingDetail().getHotelCCYear(), arguments.Traveler.getBookingDetail().getHotelCCMonth(), 1)>
					<cfset local.hotelCCExpiration = createDate(year(local.hotelCCExpiration), month(local.hotelCCExpiration), daysInMonth(local.hotelCCExpiration))>
					<cfif local.hotelCCExpiration LTE now()>
						<cfset local.error.hotelCCExpiration = ''>
					</cfif>
				</cfif>
				<cfif arguments.Traveler.getBookingDetail().getHotelBillingName() EQ ''>
					<cfset local.error.hotelBillingName = ''>
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
			AND arguments.Traveler.getBookingDetail().getAirFOPID() DOES NOT CONTAIN 'fop_'>
			<cfset local.approval.approvalNeeded = true>
		</cfif>

		<cfif arguments.Traveler.getBookingDetail().getHotelNeeded()
			AND arguments.Policy.Policy_HotelApproval EQ 1
			AND arguments.Traveler.getBookingDetail().getHotelFOPID() DOES NOT CONTAIN 'fop_'>
			<cfset local.approval.approvalNeeded = true>
		</cfif>

		<cfif arguments.Traveler.getBookingDetail().getCarNeeded()
			AND arguments.Policy.Policy_CarApproval EQ 1
			AND arguments.Traveler.getBookingDetail().getCarFOPID() DOES NOT CONTAIN 'fop_'>
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

</cfcomponent>