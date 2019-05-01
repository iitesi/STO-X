<cfcomponent output="false" accessors="true" extends="com.shortstravel.AbstractService">

	<cffunction name="init" access="public" output="false" returntype="any" hint="I initialize this component" >

		<cfreturn this />
	</cffunction>

	<cffunction name="checkPolicy" output="false" hint="I check the policy.">
		<cfargument name="Itinerary" required="true">
		<cfargument name="Solutions" required="true">
		<cfargument name="LowestFare" required="true">
		<cfargument name="Account" required="true">
		<cfargument name="Policy" required="true">

		<cfset var Itinerary = arguments.Itinerary>
		<cfset var Solutions = arguments.Solutions>
		<cfset var LowestFare = arguments.LowestFare>
		<cfset var Account = arguments.Account>
		<cfset var Policy = arguments.Policy>
		<cfset var IsBookable = true>
		<cfset var OutOfPolicy = false>
		<cfset var OutOfPolicyReason = []>
		<cfset var FlightIsBookable = true>
		<cfset var FlightOutOfPolicy = false>
		<cfset var FlightOutOfPolicyReason = []>

		<cfloop collection="#Itinerary#" index="local.GroupIndex" item="local.GroupItem">
			<cfloop collection="#GroupItem.Flights#" index="local.FlightIndex" item="local.FlightItem">
				<cfif FlightItem.OutOfPolicy>
					<cfset FlightOutOfPolicy = true>
					<cfset arrayAppend(FlightOutOfPolicyReason, FlightItem.OutOfPolicyReason)>
					<cfif NOT FlightItem.IsBookable>
						<cfset FlightIsBookable = false>
					</cfif>
				</cfif>
			</cfloop>
		</cfloop>

		<cfloop collection="#Solutions#" index="local.SolutionIndex" item="local.SolutionItem">

			<cfif IsStruct(SolutionItem)>

				<cfset IsBookable = FlightIsBookable>
				<cfset OutOfPolicy = FlightOutOfPolicy>
				<cfset OutOfPolicyReason = FlightOutOfPolicyReason>

				<!--- Low fare --->
				<cfif Policy.Policy_AirLowRule EQ 1
					AND isNumeric(Policy.Policy_AirLowPad)
					AND SolutionItem.TotalPrice GT (LowestFare + Policy.Policy_AirLowPad)>
					
					<cfset OutOfPolicy = true>
					<cfset arrayAppend(OutOfPolicyReason, 'Not the lowest fare')>
					<cfif Policy.Policy_AirLowDisp EQ 1>
						<cfset IsBookable = false>
					</cfif>

				</cfif>

				<!--- Max fare --->
				<cfif Policy.Policy_AirMaxRule EQ 1
					AND isNumeric(Policy.Policy_AirMaxTotal)
					AND SolutionItem.TotalPrice GT Policy.Policy_AirMaxTotal>

					<cfset OutOfPolicy = true>
					<cfset arrayAppend(OutOfPolicyReason, 'Fare greater than #DollarFormat(Policy.Policy_AirMaxTotal)#')>
					<cfif Policy.Policy_AirMaxDisp EQ 1>
						<cfset IsBookable = false>
					</cfif>

				</cfif>

				<!--- Non refundable / Refundable --->
				<cfif Policy.Policy_AirRefRule EQ 1
					AND Policy.Policy_AirNonRefRule EQ 0
					AND NOT SolutionItem.Refundable>

					<cfset OutOfPolicy = true>
					<cfset arrayAppend(OutOfPolicyReason, 'Hide non refundable fares')>

				<cfelseif Policy.Policy_AirNonRefRule EQ 1
					AND Policy.Policy_AirRefRule EQ 0
					AND SolutionItem.Refundable>

					<cfset OutOfPolicy = true>
					<cfset arrayAppend(OutOfPolicyReason, 'Hide refundable fares')>

				</cfif>

				<!--- Dohmen --->
				<!--- Remove first refundable fares --->
				<!--- <cfif SolutionItem.CabinClass EQ 'First'
					AND SolutionItem.Refundable 
					AND ((useUpPolicy AND (!Policy.Policy_AirRefRule OR !Policy.Policy_AirFirstClass))
						OR !useUpPolicy)>

					<cfset OutOfPolicy = true>
					<cfset arrayAppend(OutOfPolicyReason, 'Hide UP fares')>
					<cfset IsBookable = false>

				</cfif>

				<!--- Remove cabin classes --->
				<cfif SolutionItem.CabinClass EQ "First" AND !val(Policy.Policy_AirFirstClass)>

					<cfset OutOfPolicy = true>
					<cfset arrayAppend(OutOfPolicyReason, 'Cannot book first class')>
					<cfset IsBookable = false>

				<cfelseif SolutionItem.CabinClass EQ "Business" AND !val(Policy.Policy_AirBusinessClass)>

					<cfset OutOfPolicy = true>
					<cfset arrayAppend(OutOfPolicyReason, 'Cannot book business class')>
					<cfset IsBookable = false>

				</cfif> --->

				<cfset Solutions[SolutionIndex].OutOfPolicy = OutOfPolicy>
				<cfset Solutions[SolutionIndex].OutOfPolicyReason = listToArray(listRemoveDuplicates(arrayToList(OutOfPolicyReason)))>
				<cfset Solutions[SolutionIndex].IsBookable = IsBookable>

			</cfif>

		</cfloop>

		<cfreturn Solutions />
	</cffunction>

	<cffunction name="removeDuplicates" output="false" hint="I check the policy.">
		<cfargument name="Solutions" required="true">

		<cfset var Solutions = arguments.Solutions>
		<cfset var NewSolutions = []>
		<cfset var FareIds = ''>
		<cfset var FareId = ''>
		<cfset var Remove = ''>

		<cfloop collection="#Solutions#" index="local.SolutionIndex" item="local.SolutionItem">

			<cfif IsStruct(SolutionItem)>

				<cfset FareId = ''>
				<cfloop collection="#SolutionItem.Flights#" index="local.FlightIndex" item="local.FlightItem">
					<cfset FareId = listAppend(FareId, FlightItem.BookingCode&.&FlightItem.FareBasis, '-')>
				</cfloop>

				<cfif NOT listFind(FareIds, FareId)>

					<cfset FareIds = listAppend(FareIds, FareId)>
				
				<cfelse>

					<cfset Remove = listAppend(Remove, SolutionIndex)>

				</cfif>

			</cfif>

		</cfloop>

		<cfloop collection="#Solutions#" index="local.SolutionIndex" item="local.SolutionItem">

			<cfif NOT listFind(Remove, SolutionIndex)>
				<cfset arrayAppend(NewSolutions, SolutionItem)>
			</cfif>

		</cfloop>

		<cfreturn NewSolutions />
	</cffunction>

</cfcomponent>
