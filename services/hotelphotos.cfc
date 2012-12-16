<cfcomponent output="false">
		
<!--- doHotelPhotoGallery --->
	<cffunction name="doHotelPhotoGallery" output="false" access="remote" returnformat="json" returntype="array">
		<cfargument name="nSearchID" 		required="true">
		<cfargument name="nHotelCode"		required="true">
		<cfargument name="sHotelChain"	required="true">
		<cfargument name="sAPIAuth" 		required="false"	default="#application.sAPIAuth#">
		<cfargument name="stAccount" 		required="false"	default="#application.stAccounts[session.Acct_ID]#">
		
		<cfset local.stTrip = session.searches[arguments.nSearchID] />
		<cfset local.sMessage = prepareSoapHeader(arguments.stAccount, arguments.nSearchID, arguments.sHotelChain, arguments.nHotelCode) />
		<cfset local.sResponse = callAPI('HotelService', sMessage, arguments.sAPIAuth, arguments.nSearchID, arguments.nHotelCode) />
		<cfset local.stResponse = formatResponse(sResponse) />
		<cfset local.stHotels = parseHotelPhotos(stResponse,arguments.nHotelCode,arguments.nSearchID) />

		<cfset session.searches[arguments.nSearchID].stHotels = stHotels />
		
		<cfreturn stHotels />
	</cffunction>
		
<!--- prepareSoapHeader --->
	<cffunction name="prepareSoapHeader" returntype="string" output="false">
		<cfargument name="stAccount" 		required="true">
		<cfargument name="nSearchID" 		required="true">
		<cfargument name="sHotelChain" 	required="true">
		<cfargument name="nHotelCode" 	required="true">

		<cfsavecontent variable="local.message">
			<cfoutput>
				<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
					<soapenv:Header/>
					<soapenv:Body>
					<hot:HotelMediaLinksReq TargetBranch="P7003155" xmlns:hot="http://www.travelport.com/schema/hotel_v17_0" xmlns:com="http://www.travelport.com/schema/common_v15_0" 
					SecureLinks="true" SizeCode="T" RichMedia="false" Gallery="false">
						<com:BillingPointOfSaleInfo OriginApplication="UAPI"/>
						<hot:HotelProperty HotelChain="#arguments.sHotelChain#" HotelCode="#arguments.nHotelCode#"/>
					</hot:HotelMediaLinksReq>
					</soapenv:Body>
				</soapenv:Envelope>
			</cfoutput>
		</cfsavecontent>

		<cfreturn message />
	</cffunction>
	
<!--- callAPI --->
	<cffunction name="callAPI" returntype="string" output="true">
		<cfargument name="sService"		required="true">
		<cfargument name="sMessage"		required="true">
		<cfargument name="sAPIAuth"		required="true">
		<cfargument name="nSearchID"	required="true">
		<cfargument name="nHotelCode"	required="true">
		
		<cfset local.bSessionStorage = true /><!--- Testing setting (true - testing, false - live) --->

		<cfif NOT bSessionStorage OR (NOT StructKeyExists(session.searches[nSearchID]['STHOTELS'][nHotelCode], 'stHotelPhotos') AND NOT StructKeyExists(session.searches[nSearchID]['STHOTELS'][nHotelCode], 'aHotelPhotos'))>
			<cfhttp method="post" url="https://americas.copy-webservices.travelport.com/B2BGateway/connect/uAPI/#arguments.sService#">
				<cfhttpparam type="header" name="Authorization" value="Basic #arguments.sAPIAuth#" />
				<cfhttpparam type="header" name="Content-Type" value="text/xml;charset=UTF-8" />
				<cfhttpparam type="header" name="Accept" value="gzip,deflate" />
				<cfhttpparam type="header" name="Cache-Control" value="no-cache" />
				<cfhttpparam type="header" name="Pragma" value="no-cache" />
				<cfhttpparam type="header" name="SOAPAction" value="" />
				<cfhttpparam type="body" name="message" value="#Trim(arguments.sMessage)#" />
			</cfhttp>
			<cfset session.searches[nSearchID]['STHOTELS'][nHotelCode].stHotelPhotos = cfhttp.filecontent />
		<cfelse>
			<cfset cfhttp.filecontent = session.searches[nSearchID]['STHOTELS'][nHotelCode].stHotelPhotos />
		</cfif>

		<cfreturn cfhttp.filecontent />
	</cffunction>
	
<!--- formatResponse --->
	<cffunction name="formatResponse" returntype="array" output="false">
		<cfargument name="stResponse"	required="true">
		
		<cfset local.stResponse = XMLParse(arguments.stResponse)>
		
		<cfreturn stResponse.XMLRoot.XMLChildren[1].XMLChildren[1].XMLChildren[1].XMLChildren />
	</cffunction>
	
<!--- parseHotelPhotos --->
	<cffunction name="parseHotelPhotos" returntype="struct" output="false">
		<cfargument name="stResponse"	required="true">		
		<cfargument name="nHotelCode"	required="true">		
		<cfargument name="nSearchID"	required="true">			
		
		<cfset local.stHotels = session.searches[nSearchID].stHotels />
		<cfset local.nHotelCode = arguments.nHotelCode />
		<cfset local.aHotelPhotos = [] />

		<cfloop array="#arguments.stResponse#" index="local.stHotelPhoto">
			<cfif stHotelPhoto.XMLName EQ 'common_v15_0:MediaItem'>
				<cfset HotelPhoto = stHotelPhoto.XMLAttributes.url />
				<cfset ArrayAppend(aHotelPhotos, HotelPhoto) />				
			</cfif>			
		</cfloop>
		
		<!--- Update the struct so we know we've received photos and we don't pull them again later --->
		<cfset stHotels[nHotelCode]['aHotelPhotos'] = aHotelPhotos />

		<cfreturn stHotels />
	</cffunction>	
	
<!--- HotelInformation --->
	<cffunction name="HotelInformation" access="public" output="false" returntype="query">
		<cfargument name="stHotels">
		<cfargument name="Search_ID">
		
		<cfset local.stHotels = arguments.stHotels />
		<cfset local.PropertyIDs = [] />
		<cfloop list="#StructKeyList(arguments.stHotels)#" index="sHotel">
			<cfset ArrayAppend(PropertyIDs,sHotel)>
		</cfloop>
		<cfset PropertyIDs = arrayToList(PropertyIDs,"','") />

		<cfquery name="local.HotelInformation" datasource="Book">
		SELECT Property_ID, Signature_Image, Lat, Long
		FROM lu_hotels
		WHERE Property_ID in ('#PreserveSingleQuotes(PropertyIDs)#')
		</cfquery>

		<cfloop query="HotelInformation">
			<!--- Create the an array of important information for the hotel --->
			<cfset stHotels[NumberFormat(HotelInformation.Property_ID,'00000')]['HOTELINFORMATION']= {
				Signature_Image : HotelInformation.Signature_Image,
				latitude : HotelInformation.Lat,
				longitude : HotelInformation.Long
				} />

		</cfloop>

		<cfset session.searches[arguments.Search_ID].stHotels = stHotels />

		<cfreturn HotelInformation />
	</cffunction>

</cfcomponent>