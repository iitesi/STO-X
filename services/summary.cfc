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
			<cfif qAgentSine.AccountID EQ ''>
				<cfset feeType = 'ODOM'>
			<cfelse>
				<cfset feeType = 'DOM'>
			</cfif>

			<cfset local.cities = {}>
			<cfset local.segmentCount = 0>
			<cfloop collection="#arguments.Air.Groups#" item="local.group" index="local.groupIndex">
				<cfloop collection="#group.Segments#" item="local.segment" index="local.segmentIndex">
					<cfset cities[segment.Origin] = ''>
					<cfset cities[segment.Destination] = ''>
					<cfset segmentCount++>
				</cfloop>
			</cfloop>

			<cfquery name="local.qSearch" datasource="#getBookingDSN()#">
				SELECT Country_Code
				FROM lu_Geography
				WHERE Location_Code IN (<cfqueryparam value="#structKeyList(cities)#" cfsqltype="cf_sql_varchar" list="true">)
					AND Location_Type = <cfqueryparam value="125" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfloop query="qSearch">
				<cfif qSearch.Country_Code NEQ 'US'>
					<cfif qAgentSine.AccountID EQ ''>
						<cfset feeType = 'OINTL'>
					<cfelse>
						<cfset feeType = 'INTL'>
					</cfif>
				</cfif>
			</cfloop>

			<cfif (feeType EQ 'OINTL' OR feeType EQ 'INTL')
				AND (ArrayLen(arguments.Air.Carriers) GT 1
				OR arguments.Filter.getAirType() EQ 'MD'
				OR segmentCount GT 6)>
					<cfif qAgentSine.AccountID EQ ''>
						<cfset feeType = 'OINTLRD'>
					<cfelse>
						<cfset feeType = 'INTLRD'>
					</cfif>
			</cfif>
		<cfelse>
			<cfif qAgentSine.AccountID EQ ''>
				<cfset feeType = 'OAUX'>
			<cfelse>
				<cfset feeType = 'MAUX'>
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

		<cfif qAgentSine.AccountID EQ ''>
			<cfset auxFeeType = 'OAUX'>
		<cfelse>
			<cfset auxFeeType = 'MAUX'>
		</cfif>

		<cfif feeType NEQ auxFeeType>
			<cfquery name="local.qSpecificAuxFee" datasource="Corporate_Production">
				SELECT IsNull(Fee_Amount, 0) AS Fee_Amount
				FROM Account_Fees
				WHERE Acct_ID = <cfqueryparam value="#arguments.AcctID#" cfsqltype="cf_sql_integer">
					AND Fee_Type = <cfqueryparam value="#auxFeeType#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfset fees.auxFee = (qSpecificAuxFee.Fee_Amount NEQ '' ? qSpecificAuxFee.Fee_Amount : 0)>
		<cfelse>
			<cfset fees.auxFee = (qSpecificFee.Fee_Amount NEQ '' ? qSpecificFee.Fee_Amount : 0)>
		</cfif>

		<cfset fees.requestFee = (qRequest.Fee_Amount NEQ '' ? qRequest.Fee_Amount : 0)>
		<cfset fees.fee = (qSpecificFee.Fee_Amount NEQ '' ? qSpecificFee.Fee_Amount : 0)>
		<cfset fees.complex = (feeType NEQ 'OINTLRD' AND feeType NEQ 'INTLRD' ? false : true)>
		<cfset fees.agent = qAgentSine.AccountID>
		<cfset fees.airFee = (qSpecificFee.Fee_Amount NEQ '' ? qSpecificFee.Fee_Amount : 0)>
		<cfset fees.airFeeType = feeType>
		<cfset fees.auxFeeType = auxFeeType>

		<cfreturn fees />
	</cffunction>

	<cffunction name="error" output="false">
		<cfargument name="Traveler" required="true">
		<cfargument name="Air" required="false" default="">
		<cfargument name="Hotel" required="false" default="">
		<cfargument name="Vehicle" required="false" default="">
		<cfargument name="Policy" required="false" default="">
		<cfargument name="acctID" required="false" default="">
		<cfargument name="searchID" required="false" default="">
		<cfargument name="password" required="false" default="">
		<cfargument name="passwordConfirm" required="false" default="">

		<cfset local.error = {}>

		<cfif arguments.Traveler.getFirstName() EQ ''>
			<cfset error.fullname = ''>
		</cfif>
		<cfif (arguments.Traveler.getNoMiddleName() EQ 0 AND arguments.Traveler.getMiddleName() EQ '')
		OR (arguments.Traveler.getNoMiddleName() EQ 1 AND arguments.Traveler.getMiddleName() NEQ '')>
			<cfset error.fullname = ''>
		</cfif>
		<cfif arguments.Traveler.getLastName() EQ ''>
			<cfset error.fullname = ''>
		</cfif>
		<cfif arguments.Traveler.getPhoneNumber() EQ ''>
			<cfset error.phoneNumber = ''>
		</cfif>
		<cfif arguments.Traveler.getWirelessPhone() EQ ''>
			<cfset error.wirelessPhone = ''>
		</cfif>
		<cfif NOT IsValid('Email', arguments.Traveler.getEmail())>
			<cfset error.email = ''>
		</cfif>
		<cfloop list="#replace(replace(arguments.Traveler.getCCEmails(), ',', ';', 'ALL'), ' ', '', 'ALL')#" delimiters=";" index="local.email">
			<cfif NOT isValid('Email', email)>
				<cfset error.ccEmails = ''>
			</cfif>
		</cfloop>
		<cfif NOT isDate(arguments.Traveler.getBirthdate())>
			<cfset error.birthdate = ''>
		</cfif>
		<cfif arguments.Traveler.getGender() EQ ''>
			<cfset error.gender = ''>
		</cfif>

		<!--- If a guest traveler has checked the checkbox to create a new profile --->
		<cfif arguments.Traveler.getBookingDetail().getCreateProfile() EQ 1 AND arguments.Traveler.getUserID() EQ 0>
			<!--- Perform a password check --->
			<cfif arguments.password EQ ''>
				<cfset error.password = '' />
			<cfelse>
				<cfset passedTest = true />
				<!--- If less than 8 characters --->
				<cfif len(trim(arguments.password)) LT 8>
					<cfset passedTest = false />
				<cfelse>
					<cfset counter = 0 />
					<!--- If contains at least one uppercase letter --->
					<cfif REFind("[[:upper:]]", trim(arguments.password))>
						<cfset counter++ />
					</cfif>
					<!--- If contains at least one lowercase letter --->
					<cfif REFind("[[:lower:]]", trim(arguments.password))>
						<cfset counter++ />
					</cfif>
					<!--- If contains at least one number --->
					<cfif REFind("[[:digit:]]", trim(arguments.password))>
						<cfset counter++ />
					</cfif>
					<!--- If contains at least one special character --->
					<cfif REFind("[[:punct:]]", trim(arguments.password))>
						<cfset counter++ />
					</cfif>
				</cfif>
				<cfif NOT passedTest OR counter LT 3>
					<cfset error.password = '' />					
				</cfif>
			</cfif>
			<cfif (arguments.passwordConfirm EQ '') OR (arguments.passwordConfirm NEQ arguments.password)>
				<cfset error.passwordConfirm = '' />
			</cfif>
		</cfif>
		<cfif NOT arguments.Traveler.getBookingDetail().getAirNeeded()
			AND NOT arguments.Traveler.getBookingDetail().getHotelNeeded()
			AND NOT arguments.Traveler.getBookingDetail().getCarNeeded()>
			<cfset error.travelServices = ''>
		</cfif>

		<cfloop array="#arguments.Traveler.getOrgUnit()#" index="local.ouIndex" item="local.OU">
			<cfset local.field = OU.getOUType() & OU.getOUPosition()>
			<cfif OU.getOURequired() EQ 1
				AND len(trim( OU.getValueReport() )) EQ 0>
				<cfset error[field] = '' />	
			</cfif>
			<cfif OU.getOUFreeform() EQ 1
				AND OU.getOUPattern() NEQ ''
				AND len(trim( OU.getValueReport() )) GT 0>
				<cfset local.patternCharacter = ''>
				<cfset local.stringCharacter = ''>
				<cfloop from="1" to="#len(OU.getOUPattern())#" index="local.character">
					<cfset patternCharacter = mid(OU.getOUPattern(), character, 1)>
					<cfset stringCharacter = mid(OU.getValueReport(), character, 1)>
					<cfif (isNumeric(patternCharacter) AND NOT isNumeric(stringCharacter))
						OR (patternCharacter EQ 'A' AND REFind("[A-Za-z]", stringCharacter, 1) NEQ 1)
						OR (patternCharacter EQ 'x' AND REFind("[^A-Za-z|^0-9]", stringCharacter, 1) EQ 1)
						OR (REFind("[^A-Za-z|^0-9]", patternCharacter, 1) EQ 1 AND patternCharacter NEQ stringCharacter)>
						<cfset error[field] = '' />	
						<cfbreak>
					</cfif>
				</cfloop>
				<cfif len(trim( OU.getValueReport() )) GT 0
					AND (len(trim( OU.getValueReport() )) GT OU.getOUMax()
					OR len(trim( OU.getValueReport() )) LT OU.getOUMin())>
					<cfset error[field] = '' />
				</cfif>
			</cfif>
		</cfloop>

		<cfif arguments.Traveler.getBookingDetail().getAirNeeded()>

			<cfif arguments.Traveler.getBookingDetail().getAirFOPID() EQ 0>
				<cfif Len(arguments.Traveler.getBookingDetail().getAirCCNumber()) LT 15
					OR NOT isNumeric(arguments.Traveler.getBookingDetail().getAirCCNumber())>
					<cfset error.airCCNumber = ''>
				</cfif>
				<cfif arguments.Traveler.getBookingDetail().getAirCCMonth() EQ ''
					OR arguments.Traveler.getBookingDetail().getAirCCYear() EQ ''>
					<cfset error.airCCExpiration = ''>
				<cfelse>
					<cfset local.airCCExpiration = createDate(arguments.Traveler.getBookingDetail().getAirCCYear(), arguments.Traveler.getBookingDetail().getAirCCMonth(), 1)>
					<cfset airCCExpiration = createDate(year(airCCExpiration), month(airCCExpiration), daysInMonth(airCCExpiration))>
					<cfif airCCExpiration LTE now()>
						<cfset error.airCCExpiration = ''>
					</cfif>
				</cfif>
				<cfif arguments.Traveler.getBookingDetail().getAirCCCVV() EQ ''
					OR NOT isNumeric(arguments.Traveler.getBookingDetail().getAirCCCVV())>
					<cfset error.airCCCVV = ''>
				</cfif>
				<cfif arguments.Traveler.getBookingDetail().getAirBillingName() EQ ''>
					<cfset error.airBillingName = ''>
				</cfif>
				<cfif arguments.Traveler.getBookingDetail().getAirBillingAddress() EQ ''>
					<cfset error.airBillingAddress = ''>
				</cfif>
				<cfif arguments.Traveler.getBookingDetail().getAirBillingCity() EQ ''>
					<cfset error.airBillingCity = ''>
				</cfif>
				<cfif arguments.Traveler.getBookingDetail().getAirBillingState() EQ ''
					OR arguments.Traveler.getBookingDetail().getAirBillingZip() EQ ''>
					<cfset error.airBillingState = ''>
				</cfif>
			</cfif>

			<!--- To Do: Pass variables in --->
			<cfset local.lowestFareTripID = session.searches[arguments.searchid].stLowFareDetails.aSortFare[1] />
			<cfset local.lowestFare = session.searches[arguments.searchid].stTrips[lowestFareTripID].Total />
			<!--- To Do: Pass variables in --->
			
			<cfset local.inPolicy = (ArrayLen(arguments.Air.aPolicies) GT 0 ? false : true)>
			<!--- <cfif structKeyExists(arguments, 'hotelNotBooked')
				AND arguments.hotelNotBooked EQ ''>
				<cfset error.hotelNotBooked = ''>
			</cfif> --->
			<cfif NOT inPolicy
				AND arguments.Policy.Policy_AirReasonCode EQ 1>
				<cfif arguments.Traveler.getBookingDetail().getAirReasonCode() EQ ''>
					<cfset error.airReasonCode = ''>
				</cfif>
			</cfif>
			<cfif arguments.Air.Total GT lowestFare
				AND (inPolicy OR arguments.Policy.Policy_AirReasonCode EQ 0)
				AND arguments.Policy.Policy_AirLostSavings EQ 1>
				<cfif arguments.Traveler.getBookingDetail().getLostSavings() EQ ''>
					<cfset error.lostSavings = ''>
				</cfif>
			</cfif>
			<cfif arguments.acctID EQ 235>
				<cfif arguments.Traveler.getBookingDetail().getUDID113() EQ ''>
					<cfset error.udid113 = ''>
				</cfif>
			</cfif>
			
		</cfif>

		<cfif isObject(arguments.Hotel)
			AND arguments.Traveler.getBookingDetail().getHotelNeeded()>

			<cfif arguments.Traveler.getBookingDetail().getHotelFOPID() EQ 0>
				<cfif Len(arguments.Traveler.getBookingDetail().getHotelCCNumber()) LT 15>
					<cfset error.hotelCCNumber = ''>
				</cfif>
				<cfif arguments.Traveler.getBookingDetail().getHotelCCMonth() EQ ''
					OR arguments.Traveler.getBookingDetail().getHotelCCYear() EQ ''>
					<cfset error.hotelCCExpiration = ''>
				<cfelse>
					<cfset local.hotelCCExpiration = createDate(arguments.Traveler.getBookingDetail().getHotelCCYear(), arguments.Traveler.getBookingDetail().getHotelCCMonth(), 1)>
					<cfset hotelCCExpiration = createDate(year(hotelCCExpiration), month(hotelCCExpiration), daysInMonth(hotelCCExpiration))>
					<cfif hotelCCExpiration LTE now()>
						<cfset error.hotelCCExpiration = ''>
					</cfif>
				</cfif>
				<cfif arguments.Traveler.getBookingDetail().getHotelBillingName() EQ ''>
					<cfset error.hotelBillingName = ''>
				</cfif>
			</cfif>

			<cfif NOT arguments.Hotel.getRooms()[1].getIsInPolicy()
				AND arguments.Policy.Policy_HotelReasonCode>
				<cfif arguments.Traveler.getBookingDetail().getHotelReasonCode() EQ ''>
					<cfset error.hotelReasonCode = ''>
				</cfif>
			</cfif>

			<cfif arguments.acctID EQ 235>
				<cfif arguments.Traveler.getBookingDetail().getUDID112() EQ ''>
					<cfset error.udid112 = ''>
				</cfif>
			</cfif>

		</cfif>

		<cfif isObject(arguments.Vehicle)
			AND arguments.Traveler.getBookingDetail().getCarNeeded()>

			<cfif NOT arguments.Vehicle.getPolicy()
				AND arguments.Policy.Policy_CarReasonCode EQ 1>
				<cfif arguments.Traveler.getBookingDetail().getCarReasonCode() EQ ''>
					<cfset error.carReasonCode = ''>
				</cfif>
			</cfif>

			<cfif arguments.acctID EQ 235>
				<cfif arguments.Traveler.getBookingDetail().getUDID111() EQ ''>
					<cfset error.udid111 = ''>
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
		<cfset approval.approvalNeeded = false>
		<cfset approval.approvers = ''>

		<cfif arguments.Traveler.getBookingDetail().getAirNeeded()
			AND arguments.Policy.Policy_AirApproval EQ 1
			AND arguments.Traveler.getBookingDetail().getAirFOPID() DOES NOT CONTAIN 'fop_'>
			<cfset approval.approvalNeeded = true>
		</cfif>
		
		<cfif arguments.Traveler.getBookingDetail().getHotelNeeded()
			AND arguments.Policy.Policy_HotelApproval EQ 1
			AND arguments.Traveler.getBookingDetail().getHotelFOPID() DOES NOT CONTAIN 'fop_'>
			<cfset approval.approvalNeeded = true>
		</cfif>
		
		<cfif arguments.Traveler.getBookingDetail().getCarNeeded()
			AND arguments.Policy.Policy_CarApproval EQ 1
			AND arguments.Traveler.getBookingDetail().getCarFOPID() DOES NOT CONTAIN 'fop_'>
			<cfset approval.approvalNeeded = true>
			<!--- <cfif arguments.CarCC_Type EQ 1>Direct Bill car
				<cfset approval = 'Y'>
			</cfif> --->
		</cfif>

		<cfif approval.approvalNeeded>
			<cfset local.qTravelApprovers = ''>
			<cfif arguments.Filter.getAcctID() NEQ 350>
				<cfif arguments.Traveler.getAccountID() NEQ ''>
					<cfstoredproc procedure="sp_getAllTravelApprovers" datasource="Corporate_Production">
						<cfprocparam value="#arguments.Traveler.getAccountID()#" cfsqltype="cf_sql_varchar" />
						<cfprocresult name="qTravelApprovers" />
					</cfstoredproc>
				</cfif>
			<cfelseif arguments.Filter.getAcctID() EQ 350><!--- Dillard University --->
				<cfset local.sort2 = ''>
				<cfloop array="#arguments.Traveler.getOrgUnit()#" index="local.orgUnitIndex" item="local.OrgUnit">
					<cfif OrgUnit.getOUType() EQ 'Sort'
						AND OrgUnit.getOUPosition() EQ 2>
						<cfset sort2 = OrgUnit.getValueID()>
					</cfif>
				</cfloop>
				<cfif sort2 NEQ ''>
					<cfquery name="qTravelApprovers" datasource="Corporate_Production">
						SELECT Email
						FROM Approval_Users, Users
						WHERE Dept_ID = <cfqueryparam value="#sort2#" cfsqltype="cf_sql_varchar">
							AND Approval_Users.User_ID = Users.User_ID
					</cfquery>						
				</cfif>
			</cfif>
			<cfif isQuery("qTravelApprovers")>
				<cfset approval.approvers = replace(valueList(qTravelApprovers.Email), ',', ', ', 'ALL')>
			</cfif>
		</cfif>
		
		<cfreturn approval>
	</cffunction>
	
</cfcomponent>