<cfcomponent output="false" accessors="true">
	<cfproperty name="TerminalEntry"/>
	<cfproperty name="UniversalAdapter"/>
	<cfproperty name="bookingDSN"/>
	<cfproperty name="virtualInvoiceDSN"/>

	<cffunction name="init" output="false">
		<cfargument name="TerminalEntry" requred="true" />
		<cfargument name="UniversalAdapter" requred="true" />
		<cfargument name="bookingDSN" requred="true" />
		<cfargument name="virtualInvoiceDSN" requred="true" />

		<cfset setTerminalEntry( arguments.TerminalEntry ) />
		<cfset setUniversalAdapter( arguments.UniversalAdapter ) />
		<cfset setBookingDSN( arguments.bookingDSN ) />
		<cfset setVirtualInvoiceDSN( arguments.virtualInvoiceDSN ) />

		<cfreturn this>
	</cffunction>

	<cffunction name="fileFinishing" output="false">
		<cfargument name="targetBranch" required="true">
		<cfargument name="hostToken" required="true">
		<cfargument name="pccBooking" required="true">
		<cfargument name="providerLocatorCode" required="true">
		<cfargument name="searchID" required="true">
		<cfargument name="airSelected">
		<cfargument name="hotelSelected">
		<cfargument name="vehicleSelected">
		<cfargument name="Traveler">
		<cfargument name="Filter">
		<cfargument name="lowestCarRate">
		<cfargument name="Air">
		<cfargument name="Hotel">
		<cfargument name="statmentInformation">
		<cfargument name="developer">
		<cfargument name="version">
		<cfargument name="Account">

		<cftry>
			<!--- Sleep for seconds before starting this process --->
			<cfset sleep(45000)>

			<!--- Contains .error=true/false and .message=[] --->
			<cfset local.responseMessage = TerminalEntry.blankResponseMessage()>

			<cfset local.count = 0>
			<cfset local.processFileFinishing = true>

			<!--- If HotelCreate did not return the cancellation policy in an associated remark --->
			<cfset local.addHotelCancellation = false />
			<cfif arguments.hotelSelected AND len(arguments.Hotel.getSellMessage())>
				<cfset local.addHotelCancellation = true />
			</cfif>

			<cfloop condition="count LT 2 AND processFileFinishing">
				<cfset count++>
				<!--- 
				Pull up the PNR within the terminal session so all commands below run for that PNR
				Command = *K65D84
				--->
				<cfset local.displayPNRResponse = TerminalEntry.displayPNR( targetBranch = arguments.targetBranch
																			, hostToken = arguments.hostToken
																			, pnr = arguments.providerLocatorCode
																			, searchID = arguments.searchID )>
				<cfif NOT arguments.airSelected>
					<!--- 
					Add form of payment to non air booked PNRs
					Command = F-CK
					--->
					<cfset TerminalEntry.addFOPCheckAuxSegments( targetBranch = arguments.targetBranch
																, hostToken = arguments.hostToken
																, searchID = arguments.searchID )>
				</cfif>

				<cfif NOT displayPNRResponse.error>
					<!---
					Read the PAR into the terminal session for the move
					Command = S*1M98/SHORTS-DOHMEN/CHRISTINE L05
					--->
					<cfset local.readPARResponse = TerminalEntry.readPAR( targetBranch = arguments.targetBranch
																		, hostToken = arguments.hostToken
																		, pcc = arguments.Traveler.getBAR()[1].PCC
																		, bar = arguments.Traveler.getBAR()[1].Name
																		, par = arguments.Traveler.getPAR()
																		, searchID = arguments.searchID)>
					
					<cfif NOT readPARResponse.error>
						<!---
						Move PAR and BAR
						Command = C:N:
						Command = MVP/
						Command = MVBT/1M98//SHORTS
						--->
						<!--- STM-2961: Remove C:N command and change MVP/ to MVP/|2-200 --->
						<!--- STM-3703: Change MVP/|2-200 to MVP/S/|2-200 --->
						<cfset local.moveBARPARResponse = TerminalEntry.moveBARPAR( targetBranch = arguments.targetBranch
																					, hostToken = arguments.hostToken
																					, pcc = arguments.Traveler.getBAR()[1].PCC
																					, bar = arguments.Traveler.getBAR()[1].Name
																					, par = arguments.Traveler.getPAR()
																					, searchID = arguments.searchID
																					, pnr = arguments.providerLocatorCode )>

						<cfif NOT moveBARPARResponse.error>
							<!---
							Add auto ticketing remarks
							Command = C:N:*SORT1 SORT2 SORT3 SORT4
							--->
							<!--- STM-2961: Remove entire addStatmentInfo function --->
							<!--- <cfset TerminalEntry.addStatmentInfo( targetBranch = arguments.targetBranch
																	, hostToken = arguments.hostToken
																	, statmentInformation = arguments.statmentInformation
																	, par = arguments.Traveler.getPAR()
																	, searchID = arguments.searchID
																	, Traveler = arguments.Traveler )> --->
							<!--- Short's Travel/Internal TMCs only --->
							<cfif NOT arguments.Account.tmc.getIsExternal()>
								<!---
								Add auto ticketing remarks
								Command = T-OS-SO/1M98/OK TO TKT
								--->
								<cfset TerminalEntry.addAutoTicketRemark( targetBranch = arguments.targetBranch
																		, hostToken = arguments.hostToken
																		, bookingPCC = arguments.pccBooking
																		, searchID = arguments.searchID )>

								<!--- 
								Add ticketing date
								Command = T-U53-MM/DD/YYYY
								--->
								<cfset TerminalEntry.addTicketDate( targetBranch = arguments.targetBranch
																	, hostToken = arguments.hostToken
																	, searchID = arguments.searchID )>

								<cfif arguments.hotelSelected>
									<!---
									Add hotel reason code : no error response
									Command = T-H*DDMM/SV-HC
									Use reason code if traveler was required to select one
									Use "A" if not required
									--->
									<cfset TerminalEntry.addReasonCode( targetBranch = arguments.targetBranch
																		, hostToken = arguments.hostToken
																		, serviceType = 'H'
																		, startDate = arguments.Filter.getCheckInDate()
																		, reasonCode = len(arguments.Traveler.getBookingDetail().getHotelReasonCode()) ? arguments.Traveler.getBookingDetail().getHotelReasonCode() : 'A'
																		, searchID = arguments.searchID )>

								</cfif>
								<cfif arguments.vehicleSelected>
									<!---
									Add vehicle reason code : no error response
									Command = T-C*DDMM/SV-Cx
									Use reason code if traveler was required to select one
									Use "A" if not required
									--->
									<cfset TerminalEntry.addReasonCode( targetBranch = arguments.targetBranch
																		, hostToken = arguments.hostToken
																		, serviceType = 'C'
																		, startDate = arguments.Filter.getCarPickupDateTime()
																		, reasonCode = len(arguments.Traveler.getBookingDetail().getCarReasonCode()) ? arguments.Traveler.getBookingDetail().getCarReasonCode() : 'A'
																		, searchID = arguments.searchID )>

								</cfif>
							</cfif>

							<!--- 
							Add received by line into the PNR
							Command = R:CHRISTINE DOHMEN 319-231-8322
							--->
							<cfset TerminalEntry.addReceivedBy( targetBranch = arguments.targetBranch
																, hostToken = arguments.hostToken
																, userID = arguments.Filter.getUserID()
																, searchID = arguments.searchID )>

							<!---
							If Southwest, change KK segments to HK before queue
							Command = .IHK
							--->
							<!--- STM-2961: Move .IHK to after AirCreate and before File Finishing --->
							<!--- <cfif arguments.airSelected AND structKeyExists(arguments.Air, 'Carriers')>
								<cfloop array="#arguments.Air.Carriers#" index="local.carrierIndex" item="local.carrier">
									<cfif carrier IS 'WN'>
										<cfset TerminalEntry.confirmSegments( targetBranch = arguments.targetBranch
																				, hostToken = arguments.hostToken
																				, searchID = arguments.searchID )>
									</cfif>
								</cfloop>
							</cfif> --->

							<!---
							Verify stored fare
							Command = T:V or T:R
							--->
							<cfset local.runTV = true />
							<cfif arguments.airSelected AND structKeyExists(arguments.Air, 'Carriers')>
								<cfloop array="#arguments.Air.Carriers#" index="local.carrierIndex" item="local.carrier">
									<cfif carrier IS 'F9'>
										<cfset local.runTV = false />
									</cfif>
								</cfloop>
							</cfif>
							<!--- STM-5766: Use T:V for all airlines, except Frontier --->
							<cfif runTV>
								<cfset local.verifyStoredFareResponse = TerminalEntry.verifyStoredFare( targetBranch = arguments.targetBranch
																									, hostToken = arguments.hostToken
																									, searchID = arguments.searchID
																									, Air = arguments.Air
																									, airSelected = airSelected )>
							<!--- Add ATFQ for Frontier --->
							<cfelse>
								<cfset TerminalEntry.addATFQ( targetBranch = arguments.targetBranch
																, hostToken = arguments.hostToken
																, userID = arguments.Filter.getUserID()
																, searchID = arguments.searchID )>
								<cfset local.verifyStoredFareResponse = {} />
								<cfset verifyStoredFareResponse.error = false />
							</cfif>

							<cfset local.agentErrorQueue = false />
							<!--- STM-5329: Bypassing an "ERROR 2308 - NO STORED FARES EXIST" response for Frontier --->
							<!--- <cfif verifyStoredFareResponse.error AND carrier IS 'F9' AND findNoCase("NO STORED FARES EXIST", verifyStoredFareResponse.message)>
								<cfset local.agentErrorQueue = true />
							</cfif> --->

							<cfif NOT verifyStoredFareResponse.error OR agentErrorQueue>
								<cfif arguments.Filter.getAcctID() EQ 348 AND arguments.Traveler.getOrgUnit()[1].getValueID() NEQ 14046>
									<!--- 
									If NASCAR account but not NASCAR company (Value_ID = 14046), remove BARPAR accounting line.
									*PT to see the lines in the PNR, then move down to count more, 
									then remove the T-CA-43@021433 accounting line if found.
									Command = *PT
									Command = MD
									Command = C:1T-
									--->
									<cfset TerminalEntry.removeBARPARAccounting( targetBranch = arguments.targetBranch
																				, hostToken = arguments.hostToken
																				, searchID = arguments.searchID )>
								<cfelse>
									<!--- 
									Otherwise, remove duplicate accounting line. Only run if removeBARPARAccounting() has not been performed.
									*PT to see the lines in the PNR, then move down to count more, 
									then remove that line number if there were two accounting lines found.
									Command = *PT
									Command = MD
									Command = C:1T-
									--->
									<cfset TerminalEntry.removeDuplicateAccounting( targetBranch = arguments.targetBranch
																				, hostToken = arguments.hostToken
																				, searchID = arguments.searchID )>
								</cfif>

								<cfif arguments.Account.Acct_ID EQ 441>
									<!---
									Queue place for iJet
									--->
									<cfset local.queueRecordResponse = UniversalAdapter.queuePlace( targetBranch = arguments.targetBranch
																								, Filter = arguments.Filter
																								, pccBooking = '138V'
																								, providerLocatorCode = arguments.providerLocatorCode
																								, queue = 85 )>
								</cfif>
								<!---
								Determine appropriate queue
								Command = QEP/1M98/34*CSR+161C/99*CNM
								--->
								<cfset local.queueRecordResponse = TerminalEntry.queueRecord( targetBranch = arguments.targetBranch
																							, hostToken = arguments.hostToken
																							, bookingPCC = arguments.pccBooking
																							, searchID = arguments.searchID
																							, agentError = agentErrorQueue
																							, approvalNeeded = arguments.Traveler.getBookingDetail().getApprovalNeeded()
																							, specialRequests = arguments.Traveler.getBookingDetail().getSpecialRequests()
																							, seatAssignmentNeeded = arguments.Traveler.getBookingDetail().getSeatAssignmentNeeded()
																							, developer = arguments.developer
																							, specialCarReservation = arguments.Traveler.getBookingDetail().getSpecialCarReservation()
																							, unusedTickets = (arguments.Traveler.getBookingDetail().getUnusedTickets() EQ '' ? false : true )
																							, similarTripSelected = arguments.Traveler.getBookingDetail().getSimilarTripSelected()
																							, Air = arguments.Air
																							, airSelected = airSelected
																							, Account = arguments.Account )>

								<cfset responseMessage = queueRecordResponse>

								<!--- Let the process start over again --->
								<cfif queueRecordResponse.simultaneous>
									<cfset processFileFinishing = true>
								<!--- Throw purchase error --->
								<cfelseif queueRecordResponse.error>
									<cfset processFileFinishing = false>
								<!--- The whole process completed successfully --->
								<cfelse>
									<cfset processFileFinishing = false>
								</cfif>

								<cfif airSelected OR addHotelCancellation>
									<cfset local.urModSimultaneous = UniversalAdapter.addTSA( targetBranch = arguments.targetBranch
																	, Traveler = arguments.Traveler
																	, Air = arguments.Air
																	, Hotel = arguments.Hotel
																	, Filter = arguments.Filter
																	, version = arguments.version )>
									<!--- If a simultaneous change occurred, run UniversalRecordModifyReq again --->
									<cfif urModSimultaneous>
										<cfset UniversalAdapter.addTSA( targetBranch = arguments.targetBranch
																	, Traveler = arguments.Traveler
																	, Air = arguments.Air
																	, Hotel = arguments.Hotel
																	, Filter = arguments.Filter
																	, version = arguments.version )>
									</cfif>
								</cfif>
								
								<cfif NOT processFileFinishing>
									<!--- Sign out of terminal entry session --->
									<cfset TerminalEntry.closeSession( targetBranch = arguments.targetBranch
																		, hostToken = arguments.hostToken
																		, searchID = arguments.searchID )>
								</cfif>
					
							<cfelse>
								<cfset responseMessage = verifyStoredFareResponse>
							</cfif><!--- verifyStoredFareResponse.error = true --->
						
						<cfelse>
							<cfset responseMessage = moveBARPARResponse>
						</cfif><!--- moveBARPARResponse.error = true --->

					<cfelse>
						<cfset responseMessage = readPARResponse>
					</cfif><!--- readPARResponse.error = true --->
				
				<cfelse>
					<cfset responseMessage = displayPNRResponse>
				</cfif><!--- displayPNRResponse.error = true --->
			</cfloop>

		<cfcatch>
			<cfset local.acctID = arguments.Filter.getAcctID()>
			<cfset local.userID = arguments.Filter.getUserID()>
			<cfset local.username = arguments.Filter.getUsername()>
			<cfset local.department = arguments.Filter.getDepartment()>
			<cfset local.searchID = arguments.Filter.getSearchID()>

			<cfset local.errorException = structNew('linked')>
			<cfset local.errorException = { acctID = local.acctID
											, userID = local.userID
											, username = local.username
											, department = local.department
											, searchID = local.searchID
											, exception = cfcatch
										} >

			<cfset application.fw.factory.getBean('BugLogService').notifyService( message = cfcatch.message
																				, exception = local.errorException
																				, severityCode = 'Error' ) />
		</cfcatch>
		</cftry>

		<cfreturn responseMessage>
	</cffunction>

	<cffunction name="databaseInvoices" output="false">
		<cfargument name="Traveler" required="true">
		<cfargument name="itinerary" required="true">
		<cfargument name="Filter" required="true">
		<cfargument name="Account" required="true">

		<cfset local.hotelSource = "" />
		<cfset local.passiveLocatorCode = "" />
		<cfset local.passiveSegmentRef = "" />
		<cfset local.providerReservationInfoRef = "" />
		<!--- If a hotel room was purchased --->
		<cfif arguments.Traveler.getBookingDetail().getHotelNeeded() AND structKeyExists(arguments.itinerary, 'Hotel')>
			<!--- If it was a Priceline hotel room --->
			<cfif len(arguments.itinerary.Hotel.getPPNTripID())>
				<cfset local.hotelSource = "Priceline" />
				<cfset local.passiveLocatorCode = arguments.itinerary.Hotel.getPassiveLocatorCode() />
				<cfset local.passiveSegmentRef = arguments.itinerary.Hotel.getPassiveSegmentRef() />
				<cfset local.providerReservationInfoRef = arguments.itinerary.Hotel.getProviderReservationInfoRef() />
			<!--- If it was a Travelport hotel room --->
			<cfelse>
				<cfset local.hotelSource = "Travelport" />
			</cfif>
		</cfif>

		<cfset local.updateInvoice = false />
		<cfif arguments.Traveler.getBookingDetail().getSimilarTripSelected()>
			<!--- Only STO/FindIt reservations are stored in the booking.Invoices table --->
			<cfquery name="getInvoice" datasource="#getBookingDSN()#">
				SELECT invoiceID
				FROM Invoices
				WHERE recloc = <cfqueryparam value="#arguments.Traveler.getBookingDetail().getReservationCode()#" cfsqltype="cf_sql_varchar" />
					AND userID = <cfqueryparam value="#arguments.Filter.getUserID()#" cfsqltype="cf_sql_integer" />
			</cfquery>

			<cfif getInvoice.recordCount>
				<cfset local.updateInvoice = true />
			</cfif>
		</cfif>

		<cfif updateInvoice>
			<cfquery datasource="#getBookingDSN()#">
				UPDATE Invoices
				SET   recloc = <cfqueryparam value="#arguments.Traveler.getBookingDetail().getReservationCode()#" cfsqltype="cf_sql_varchar" >
					, urRecloc = <cfqueryparam value="#arguments.Traveler.getBookingDetail().getUniversalLocatorCode()#" cfsqltype="cf_sql_varchar" >
					, firstName = <cfqueryparam value="#arguments.Traveler.getFirstName()#" cfsqltype="cf_sql_varchar" >
					, lastName = <cfqueryparam value="#arguments.Traveler.getLastName()#" cfsqltype="cf_sql_varchar" >
					<cfif arguments.Traveler.getBookingDetail().getAirNeeded()>
						, air = <cfqueryparam value="#arguments.Traveler.getBookingDetail().getAirNeeded()#" cfsqltype="cf_sql_integer" >
						, airSelection = <cfqueryparam value="#(structKeyExists(arguments.itinerary, 'Air') ? serializeJSON(arguments.itinerary.Air) : '')#" cfsqltype="cf_sql_longvarchar" >
					</cfif>
					<cfif arguments.Traveler.getBookingDetail().getCarNeeded()>
						, car = <cfqueryparam value="#arguments.Traveler.getBookingDetail().getCarNeeded()#" cfsqltype="cf_sql_integer" >
						, carSelection = <cfqueryparam value="#(structKeyExists(arguments.itinerary, 'Vehicle') ? serializeJSON(arguments.itinerary.Vehicle) : '')#" cfsqltype="cf_sql_longvarchar" >
					</cfif>
					<cfif arguments.Traveler.getBookingDetail().getHotelNeeded()>
						, hotel = <cfqueryparam value="#arguments.Traveler.getBookingDetail().getHotelNeeded()#" cfsqltype="cf_sql_integer" >
						, hotelSelection = <cfqueryparam value="#(structKeyExists(arguments.itinerary, 'Hotel') ? serializeJSON(arguments.itinerary.Hotel) : '')#" cfsqltype="cf_sql_longvarchar" >
					</cfif>
					, valueID = <cfqueryparam value="#arguments.Filter.getValueID()#" cfsqltype="cf_sql_integer" >
					, policyID = <cfqueryparam value="#arguments.Filter.getPolicyID()#" cfsqltype="cf_sql_integer" >
					, profileID = <cfqueryparam value="#arguments.Filter.getProfileID()#" cfsqltype="cf_sql_integer" >
					, filter = <cfqueryparam value="#serializeJSON(arguments.Filter)#" cfsqltype="cf_sql_longvarchar" >
					, traveler = <cfqueryparam value="#REReplace(serializeJSON(arguments.Traveler), '\b\d{13,16}\b', '****************', 'ALL')#" cfsqltype="cf_sql_longvarchar" >
					, bookingDetail = <cfqueryparam value="#REReplace(serializeJSON(arguments.Traveler.getBookingDetail()), '\b\d{13,16}\b', '****************', 'ALL')#" cfsqltype="cf_sql_longvarchar" >
					, unusedTickets = <cfqueryparam value="#left(arguments.Traveler.getBookingDetail().getUnusedTickets(), 50)#" cfsqltype="cf_sql_varchar" >
					, hotelSource = <cfqueryparam value="#local.hotelSource#" cfsqltype="cf_sql_varchar" >
					, targetBranch = <cfqueryparam value="#arguments.Account.sBranch#" cfsqltype="cf_sql_varchar" >
					, passiveRecloc = <cfqueryparam value="#local.passiveLocatorCode#" cfsqltype="cf_sql_varchar" >
					, passiveSegmentRef = <cfqueryparam value="#local.passiveSegmentRef#" cfsqltype="cf_sql_varchar" >
					, providerReservationInfoRef = <cfqueryparam value="#local.providerReservationInfoRef#" cfsqltype="cf_sql_varchar" >
					, active = <cfqueryparam value="1" cfsqltype="cf_sql_bit" >
				WHERE invoiceID = <cfqueryparam value="#getInvoice.invoiceID#" cfsqltype="cf_sql_integer" >
			</cfquery>

			<cfset arguments.Traveler.getBookingDetail().setInvoiceID(getInvoice.invoiceID) />
		<cfelse>
			<cfquery datasource="#getBookingDSN()#" result="local.invoice">
				INSERT INTO Invoices (
					  searchID
					, recloc
					, urRecloc
					, firstName
					, lastName
					, air
					, airSelection
					, car
					, carSelection
					, hotel
					, hotelSelection
					, userID
					, valueID
					, policyID
					, profileID
					, filter
					, traveler
					, bookingDetail
					, unusedTickets
					, hotelSource
					, targetBranch
					, passiveRecloc
					, passiveSegmentRef
					, providerReservationInfoRef
				)
				VALUES (
					  <cfqueryparam value="#arguments.Filter.getSearchID()#" cfsqltype="cf_sql_integer" >
					, <cfqueryparam value="#arguments.Traveler.getBookingDetail().getReservationCode()#" cfsqltype="cf_sql_varchar" >
					, <cfqueryparam value="#arguments.Traveler.getBookingDetail().getUniversalLocatorCode()#" cfsqltype="cf_sql_varchar" >
					, <cfqueryparam value="#arguments.Traveler.getFirstName()#" cfsqltype="cf_sql_varchar" >
					, <cfqueryparam value="#arguments.Traveler.getLastName()#" cfsqltype="cf_sql_varchar" >
					, <cfqueryparam value="#arguments.Traveler.getBookingDetail().getAirNeeded()#" cfsqltype="cf_sql_integer" >
					, <cfqueryparam value="#(structKeyExists(arguments.itinerary, 'Air') ? serializeJSON(arguments.itinerary.Air) : '')#" cfsqltype="cf_sql_longvarchar" >
					, <cfqueryparam value="#arguments.Traveler.getBookingDetail().getCarNeeded()#" cfsqltype="cf_sql_integer" >
					, <cfqueryparam value="#(structKeyExists(arguments.itinerary, 'Vehicle') ? serializeJSON(arguments.itinerary.Vehicle) : '')#" cfsqltype="cf_sql_longvarchar" >
					, <cfqueryparam value="#arguments.Traveler.getBookingDetail().getHotelNeeded()#" cfsqltype="cf_sql_integer" >
					, <cfqueryparam value="#(structKeyExists(arguments.itinerary, 'Hotel') ? serializeJSON(arguments.itinerary.Hotel) : '')#" cfsqltype="cf_sql_longvarchar" >
					, <cfqueryparam value="#arguments.Filter.getUserID()#" cfsqltype="cf_sql_integer" >
					, <cfqueryparam value="#arguments.Filter.getValueID()#" cfsqltype="cf_sql_integer" >
					, <cfqueryparam value="#arguments.Filter.getPolicyID()#" cfsqltype="cf_sql_integer" >
					, <cfqueryparam value="#arguments.Filter.getProfileID()#" cfsqltype="cf_sql_integer" >
					, <cfqueryparam value="#serializeJSON(arguments.Filter)#" cfsqltype="cf_sql_longvarchar" >
					, <cfqueryparam value="#REReplace(serializeJSON(arguments.Traveler), '\b\d{13,16}\b', '****************', 'ALL')#" cfsqltype="cf_sql_longvarchar" >
					, <cfqueryparam value="#REReplace(serializeJSON(arguments.Traveler.getBookingDetail()), '\b\d{13,16}\b', '****************', 'ALL')#" cfsqltype="cf_sql_longvarchar" >
					, <cfqueryparam value="#left(arguments.Traveler.getBookingDetail().getUnusedTickets(), 50)#" cfsqltype="cf_sql_varchar" >
					, <cfqueryparam value="#local.hotelSource#" cfsqltype="cf_sql_varchar" >
					, <cfqueryparam value="#arguments.Account.sBranch#" cfsqltype="cf_sql_varchar" >
					, <cfqueryparam value="#local.passiveLocatorCode#" cfsqltype="cf_sql_varchar" >
					, <cfqueryparam value="#local.passiveSegmentRef#" cfsqltype="cf_sql_varchar" >
					, <cfqueryparam value="#local.providerReservationInfoRef#" cfsqltype="cf_sql_varchar" >
				)
			</cfquery>

			<cfset arguments.Traveler.getBookingDetail().setInvoiceID(local.invoice.IDENTITYCOL) />
		</cfif>

		<cfreturn />
	</cffunction>

	<cffunction name="retrieveInvoice" output="false">
		<cfargument name="invoiceID" type="numeric" required="false" />
		<cfargument name="searchID" type="numeric" required="false" />

		<cfquery name="getInvoice" datasource="#getBookingDSN()#">
			SELECT searchID
				 , recloc
				 , urRecloc
				 , firstName
				 , lastName
				 , air
				 , car
				 , hotelSelection
				 , userID
				 , profileID
				 , valueID
				 , policyID
				 , filter
				 , traveler
				 , bookingDetail
				 , hotelSource
				 , targetBranch
				 , passiveRecloc
				 , passiveSegmentRef
				 , providerReservationInfoRef
			FROM Invoices
			<cfif len(arguments.invoiceID)>
				WHERE invoiceID = <cfqueryparam value="#arguments.invoiceID#" cfsqltype="cf_sql_integer" />
			<cfelse>
				WHERE searchID = <cfqueryparam value="#arguments.searchID#" cfsqltype="cf_sql_integer" />
			</cfif>
		</cfquery>

		<cfreturn getInvoice />
	</cffunction>

	<cffunction name="cancelInvoice" output="false">
		<cfargument name="searchID" required="true">
		<cfargument name="urRecloc" required="true">

		<cfquery datasource="#getBookingDSN()#">
			UPDATE Invoices
			SET active = <cfqueryparam value="0" cfsqltype="cf_sql_integer" >
			WHERE searchID = <cfqueryparam value="#arguments.searchID#" cfsqltype="cf_sql_integer" >
				AND urRecloc = <cfqueryparam value="#arguments.urRecloc#" cfsqltype="cf_sql_varchar" >
		</cfquery>

		<cfreturn />
	</cffunction>

	<cffunction name="regenerateVI" output="false">
		<cfargument name="recLoc" required="true">

		<cfquery name="getVI" datasource="#getVirtualInvoiceDSN()#">
			SELECT TOP 1 ID, AccountNumber, ID_GUID, BranchNumber
			FROM InvoiceArchive
			WHERE RecordLocator = <cfqueryparam value="#arguments.recLoc#" cfsqltype="cf_sql_varchar" />
			ORDER BY VI_Timestamp DESC
		</cfquery>

		<cfif getVI.recordCount>
			<cfset timestamp = DateAdd('d', -1, Now()) />

			<cfquery datasource="#getVirtualInvoiceDSN()#">
				INSERT INTO RUN_VI (
					  RLoc
					, AccountID
					, Time_Stamp
					, Archive_ID
					, BranchID
				)
				VALUES (
					  <cfqueryparam value="#arguments.recLoc#" cfsqltype="cf_sql_varchar" />
					, <cfqueryparam value="#getVI.AccountNumber#" cfsqltype="cf_sql_varchar" />
					, <cfqueryparam value="#timestamp#" cfsqltype="cf_sql_timestamp" />
					, <cfqueryparam value="#getVI.ID_GUID#" cfsqltype="cf_sql_varchar" />
					, <cfqueryparam value="#getVI.BranchNumber#" cfsqltype="cf_sql_varchar" />
				)
			</cfquery>
		</cfif>

		<cfreturn />
	</cffunction>

	<cffunction name="getErrorMessage" output="false">
		<cfargument name="errorMessage">

		<cfset local.message = 'WE ARE UNABLE TO CONFIRM YOUR RESERVATION. PLEASE CONTACT US TO COMPLETE YOUR PURCHASE.'>
		<cfif isArray(arguments.errorMessage)
			AND NOT arrayIsEmpty(arguments.errorMessage)>

			<cfloop array="#arguments.errorMessage#" index="local.errorIndex" item="local.error">

				<cfquery name="local.getMessage" datasource="#getBookingDSN()#">
					SELECT message
					FROM errorMessages
					WHERE '#local.error#' LIKE '%' + error + '%'
				</cfquery>

				<cfif local.getMessage.recordCount>
					<cfset local.message = local.getMessage.message>
					<cfbreak>
				</cfif>
			</cfloop>

		</cfif>

		<cfreturn local.message/>
	</cffunction>

</cfcomponent>