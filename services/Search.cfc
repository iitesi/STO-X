<cfcomponent output="false">
	
<!--- addSearchRecord --->
	<cffunction name="addSearchRecord" output="false">
		<cfset local.stinsertdata = Structnew() >
		<cfset local.stinsertdata = {Username = "",
				Portal_URL = "",
				Policy_ID = 0,
				Acct_ID = 0,
				User_ID = 0,
				Department = "",
				Profile_ID = 0,
				Value_ID = 0,
				Air = 0,
				Car = 0,
				Hotel = 0,
				Bookit = 0,
				Depart_TimeType = "A",
				Depart_DateTime = "",
				Depart_City = "",
				Arrival_TimeType = "D",
				Arrival_DateTime = "",
				Arrival_City = "",
				Air_Heading = "",
				Car_Heading = "",
				Hotel_Heading = "",
				Search_Type = "Fare",
				Air_Type = "RT",
				Hotel_Radius = 5,
				Hotel_Search = "",
				Hotel_Airport = "",
				Hotel_Landmark = "",
				Hotel_Address = "",
				Hotel_City = "",
				Hotel_State = "",
				Hotel_Zip = "",
				Hotel_Long = 0,
				Hotel_Lat = 0,
				Geography_ID = 0,
				Office_ID = 0,
				Travelers = 1,
				Server_Name = "",
				Primary_Acct = 0,
				Access_Timestamp = Now(),
				View_State = "",
				IP_Address = "",
				Search_Refundable = 0,
				Cloning_ID = 0,
				Reference = "",
				Heading = "",
				Rooms = 0,
				Search_Type_Original = "",
				Current_Session = "",
				Redirector = "",
				Passthrough = 0,
				Size = "",
				Title = "",
				HeaderColor = "",
				BodyColor = "",
				Hotel_Country = "",
				International = 0,
				HotelAddOn = 0,
				Airlines = "",
				ClassOfService = "Y",
				CheckIn_Date = "",
				CheckOut_Date = "",
				Air_ID1 = 0,
				Air_ID2 = 0,
				Air_ID3 = 0,
				Air_ID4 = 0,
				Hotel_Viewed = 0,
				Hotel_Location = "",
				Car_Viewed = 0,
				Car_PickupLocation = "",
				Car_PickupDateTime = "",
				Car_DropoffLocation = "",
				Car_DropoffDateTime = "",
				Cars = 0} >
		
		<cfset local.stinsertdata.User_ID = form.User_ID>
		<cfif form.for EQ "guest">
			<cfset local.stinsertdata.Department = form.dept >
				</cfif>
				
		<cfswitch expression="#Searchtype#">
			<cfcase value="caronly">
				<cfset local.stinsertdata.Car = 1>
				<cfset local.stinsertdata.Car_PickupLocation = GetToken(GetToken(form.car_pickuploc, 2, '('), 1, ')')>
				<cfset local.stinsertdata.Car_PickupDateTime = CreateODBCDateTime(form.car_pickupdate + form.car_pickuptime)>
				<cfif (form.car_droploc EQ "drop-off airport") OR (form.car_droploc EQ "drop-off city") >
					<cfset local.stinsertdata.Car_DropoffLocation = local.stinsertdata.Car_PickupLocation>
				<cfelse>
					<cfset local.stinsertdata.Car_DropoffLocation = GetToken(GetToken(form.car_droploc, 2, '('), 1, ')')>
				</cfif>
				<cfset local.stinsertdata.Car_DropoffDateTime = CreateODBCDateTime(form.car_dropdate + form.car_droptime)>
				<cfset local.stinsertdata.Cars = form.cars>
			</cfcase>
			<cfcase value="hotelonly">
				<cfset local.stinsertdata.Hotel = 1>
				<cfset local.stinsertdata.Hotel_Radius = form.hotel_radius>
				<cfset local.stinsertdata.Hotel_Location = form.hotel_location>
				<cfset local.stinsertdata.CheckIn_Date = CreateODBCDateTime(form.hotel_indate)>
				<cfset local.stinsertdata.CheckOut_Date = CreateODBCDateTime(form.hotel_outdate)>
				<cfset local.stinsertdata.Rooms = form.hotel_rooms>
			</cfcase>
			<cfcase value="flightonly">
				<cfset local.stinsertdata.Air = 1>
				<cfset local.stinsertdata.Depart_City = GetToken(GetToken(form.flight_fromlocation, 2, '('), 1, ')')>
				<cfset local.stinsertdata.Depart_TimeType = form.flight_departaol>
				<cfset local.stinsertdata.Depart_DateTime = CreateODBCDateTime(form.flight_departdate + form.flight_departtime)>
				<cfset local.stinsertdata.Arrival_City = GetToken(GetToken(form.flight_tolocation, 2, '('), 1, ')')>
				<cfif (form.flight_returndate EQ "optional for one-way") >
					<cfset local.stinsertdata.Air_Type = "OW">
				<cfelse>
					<cfset local.stinsertdata.Air_Type = "RT">
					<cfset local.stinsertdata.Arrival_TimeType = form.flight_returnaol>
					<cfset local.stinsertdata.Arrival_DateTime = CreateODBCDateTime(form.flight_returndate + form.flight_returntime)>
				</cfif>
				<cfset local.stinsertdata.ClassOfService = form.flight_cabin>
				<cfset local.stinsertdata.Airlines = form.flight_airline>
			</cfcase>
			<cfcase value="flightcar">
				<cfset local.stinsertdata.Air = 1>
				<cfset local.stinsertdata.Depart_City = GetToken(GetToken(form.flightcar_fromlocation, 2, '('), 1, ')')>
				<cfset local.stinsertdata.Depart_TimeType = form.flightcar_departaol>
				<cfset local.stinsertdata.Depart_DateTime = CreateODBCDateTime(form.flightcar_departdate + form.flightcar_departtime)>
				<cfset local.stinsertdata.Arrival_City = GetToken(GetToken(form.flightcar_tolocation, 2, '('), 1, ')')>
				<cfset local.stinsertdata.Air_Type = "RT">
				<cfset local.stinsertdata.Arrival_TimeType = form.flightcar_returnaol>
				<cfset local.stinsertdata.Arrival_DateTime = CreateODBCDateTime(form.flightcar_returndate + form.flightcar_returntime)>
				<cfset local.stinsertdata.ClassOfService = form.flightcar_cabin>
				<cfset local.stinsertdata.Airlines = form.flightcar_airline>
				<cfset local.stinsertdata.Car = 1>
				<cfset local.stinsertdata.Car_PickupLocation = GetToken(GetToken(form.flightcar_pickuploc, 2, '('), 1, ')')>
				<cfset local.stinsertdata.Car_PickupDateTime = local.stinsertdata.Depart_DateTime>
				<cfset local.stinsertdata.Car_DropoffLocation = local.stinsertdata.Car_PickupLocation>
				<cfset local.stinsertdata.Car_DropoffDateTime = local.stinsertdata.Arrival_DateTime>
				<cfset local.stinsertdata.Cars = form.flightcar_cars>
			</cfcase>
			<cfcase value="flighthotel">
				<cfset local.stinsertdata.Air = 1>
				<cfset local.stinsertdata.Depart_City = GetToken(GetToken(form.flighthotel_fromlocation, 2, '('), 1, ')')>
				<cfset local.stinsertdata.Depart_TimeType = form.flighthotel_departaol>
				<cfset local.stinsertdata.Depart_DateTime = CreateODBCDateTime(form.flighthotel_departdate + form.flighthotel_departtime)>
				<cfset local.stinsertdata.Arrival_City = GetToken(GetToken(form.flighthotel_tolocation, 2, '('), 1, ')')>
				<cfset local.stinsertdata.Air_Type = "RT">
				<cfset local.stinsertdata.Arrival_TimeType = form.flighthotel_returnaol>
				<cfset local.stinsertdata.Arrival_DateTime = CreateODBCDateTime(form.flighthotel_returndate + form.flighthotel_returntime)>
				<cfset local.stinsertdata.ClassOfService = form.flighthotel_cabin>
				<cfset local.stinsertdata.Airlines = form.flighthotel_airline>
				<cfset local.stinsertdata.Hotel = 1>
				<cfset local.stinsertdata.Hotel_Radius = form.flighthotel_radius>
				<cfset local.stinsertdata.Hotel_Location = form.flighthotel_location>
				<cfset local.stinsertdata.CheckIn_Date = CreateODBCDateTime(form.flighthotel_departdate)>
				<cfset local.stinsertdata.CheckOut_Date = CreateODBCDateTime(form.flighthotel_returndate)>
				<cfset local.stinsertdata.Rooms = form.flighthotel_rooms>
			</cfcase>
			<cfcase value="hotelcar">
				<cfset local.stinsertdata.Hotel = 1>
				<cfset local.stinsertdata.Hotel_Radius = form.hotelcar_radius>
				<cfset local.stinsertdata.Hotel_Location = form.hotelcar_hotellocation>
				<cfset local.stinsertdata.CheckIn_Date = CreateODBCDateTime(form.hotelcar_indate)>
				<cfset local.stinsertdata.CheckOut_Date = CreateODBCDateTime(form.hotelcar_outdate)>
				<cfset local.stinsertdata.Rooms = form.hotelcar_rooms>
				<cfset local.stinsertdata.Car = 1>
				<cfset local.stinsertdata.Car_PickupLocation = GetToken(GetToken(form.hotelcar_carpickup, 2, '('), 1, ')')>
				<cfset local.stinsertdata.Car_PickupDateTime = CreateODBCDateTime(form.hotelcar_indate + form.hotelcar_intime)>
				<cfif (form.hotelcar_cardrop EQ "drop-off airport") OR (form.hotelcar_cardrop EQ "drop-off city") >
					<cfset local.stinsertdata.Car_DropoffLocation = local.stinsertdata.Car_PickupLocation>
				<cfelse>
					<cfset local.stinsertdata.Car_DropoffLocation = GetToken(GetToken(form.hotelcar_cardrop, 2, '('), 1, ')')>
				</cfif>
				<cfset local.stinsertdata.Car_DropoffDateTime = CreateODBCDateTime(form.hotelcar_outdate + form.hotelcar_outtime)>
				<cfset local.stinsertdata.Cars = form.hotelcar_cars>
			</cfcase>
			<cfcase value="flighthotelcar">
				<cfset local.stinsertdata.Air = 1>
				<cfset local.stinsertdata.Depart_City = GetToken(GetToken(form.flighthotelcar_fromlocation, 2, '('), 1, ')')>
				<cfset local.stinsertdata.Depart_TimeType = form.flighthotelcar_departaol>
				<cfset local.stinsertdata.Depart_DateTime = CreateODBCDateTime(form.flighthotelcar_departdate + form.flighthotelcar_departtime)>
				<cfset local.stinsertdata.Arrival_City = GetToken(GetToken(form.flighthotelcar_tolocation, 2, '('), 1, ')')>
				<cfset local.stinsertdata.Air_Type = "RT">
				<cfset local.stinsertdata.Arrival_TimeType = form.flighthotelcar_returnaol>
				<cfset local.stinsertdata.Arrival_DateTime = CreateODBCDateTime(form.flighthotelcar_returndate + form.flighthotelcar_returntime)>
				<cfset local.stinsertdata.ClassOfService = form.flighthotelcar_cabin>
				<cfset local.stinsertdata.Airlines = form.flighthotelcar_airline>
				<cfset local.stinsertdata.Hotel = 1>
				<cfset local.stinsertdata.Hotel_Radius = form.flighthotelcar_radius>
				<cfset local.stinsertdata.Hotel_Location = form.flighthotelcar_location>
				<cfset local.stinsertdata.CheckIn_Date = CreateODBCDateTime(form.flighthotelcar_departdate)>
				<cfset local.stinsertdata.CheckOut_Date = CreateODBCDateTime(form.flighthotelcar_returndate)>
				<cfset local.stinsertdata.Rooms = form.flighthotelcar_rooms>
				<cfset local.stinsertdata.Car = 1>
				<cfset local.stinsertdata.Car_PickupLocation = GetToken(GetToken(form.flighthotelcar_pickuploc, 2, '('), 1, ')')>
				<cfset local.stinsertdata.Car_PickupDateTime = local.stinsertdata.Depart_DateTime>
				<cfset local.stinsertdata.Car_DropoffLocation = local.stinsertdata.Car_PickupLocation>
				<cfset local.stinsertdata.Car_DropoffDateTime = local.stinsertdata.Arrival_DateTime>
				<cfset local.stinsertdata.Cars = form.flighthotelcar_cars>
			</cfcase>
		</cfswitch>		
		<cfquery datasource="book">
			INSERT INTO newSearches
           (Username
           ,Portal_URL
           ,Policy_ID
           ,Acct_ID
           ,User_ID
           ,Department
           ,Profile_ID
           ,Value_ID
           ,Air
           ,Car
           ,Hotel
           ,BookIt
           ,Depart_TimeType
           ,Depart_DateTime
           ,Depart_City
           ,Arrival_TimeType
           ,Arrival_DateTime
           ,Arrival_City
           ,Air_Heading
           ,Car_Heading
           ,Hotel_Heading
           ,Search_Type
           ,Air_Type
           ,Hotel_Radius
           ,Hotel_Search
           ,Hotel_Airport
           ,Hotel_Landmark
           ,Hotel_Address
           ,Hotel_City
           ,Hotel_State
           ,Hotel_Zip
           ,Hotel_Long
           ,Hotel_Lat
           ,Geography_ID
           ,Office_ID
           ,Travelers
           ,Server_Name
           ,Primary_Acct
           ,Access_Timestamp
           ,View_State
           ,IP_Address
           ,Search_Refundable
           ,Cloning_ID
           ,Reference
           ,Heading
           ,Rooms
           ,Search_Type_Original
           ,Current_Session
           ,Redirector
           ,Passthrough
           ,Size
           ,Title
           ,HeaderColor
           ,BodyColor
           ,Hotel_Country
           ,International
           ,HotelAddOn
           ,Airlines
           ,ClassOfService
           ,CheckIn_Date
           ,CheckOut_Date
           ,Air_ID1
           ,Air_ID2
           ,Air_ID3
           ,Air_ID4
           ,Hotel_Viewed
           ,Car_Viewed
           ,Hotel_Location
           ,Car_PickupLocation
           ,Car_PickupDateTime
           ,Car_DropoffLocation
           ,Car_DropoffDateTime
           ,Cars)
     VALUES
           (<cfqueryparam value="#local.stinsertdata.Username#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Portal_URL#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Policy_ID#"  cfsqltype="cf_sql_integer">,
           <cfqueryparam value="#local.stinsertdata.Acct_ID#"  cfsqltype="cf_sql_integer">,
           <cfqueryparam value="#local.stinsertdata.User_ID#"  cfsqltype="cf_sql_integer">,
           <cfqueryparam value="#local.stinsertdata.Department#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Profile_ID#"  cfsqltype="cf_sql_integer">,
           <cfqueryparam value="#local.stinsertdata.Value_ID#"  cfsqltype="cf_sql_integer">,
           <cfqueryparam value="#local.stinsertdata.Air#"  cfsqltype="cf_sql_integer">,
           <cfqueryparam value="#local.stinsertdata.Car#"  cfsqltype="cf_sql_integer">,
           <cfqueryparam value="#local.stinsertdata.Hotel#"  cfsqltype="cf_sql_integer">,
           <cfqueryparam value="#local.stinsertdata.BookIt#"  cfsqltype="cf_sql_integer">,
           <cfqueryparam value="#local.stinsertdata.Depart_TimeType#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Depart_DateTime#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Depart_City#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Arrival_TimeType#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Arrival_DateTime#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Arrival_City#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Air_Heading#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Car_Heading#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Hotel_Heading#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Search_Type#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Air_Type#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Hotel_Radius#"  cfsqltype="cf_sql_integer">,
           <cfqueryparam value="#local.stinsertdata.Hotel_Search#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Hotel_Airport#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Hotel_Landmark#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Hotel_Address#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Hotel_City#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Hotel_State#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Hotel_Zip#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Hotel_Long#"  cfsqltype="cf_sql_float">,
           <cfqueryparam value="#local.stinsertdata.Hotel_Lat#"  cfsqltype="cf_sql_float">,
           <cfqueryparam value="#local.stinsertdata.Geography_ID#"  cfsqltype="cf_sql_integer">,
           <cfqueryparam value="#local.stinsertdata.Office_ID#"  cfsqltype="cf_sql_integer">,
           <cfqueryparam value="#local.stinsertdata.Travelers#"  cfsqltype="cf_sql_integer">,
           <cfqueryparam value="#local.stinsertdata.Server_Name#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Primary_Acct#"  cfsqltype="cf_sql_integer">,
           <cfqueryparam value="#local.stinsertdata.Access_Timestamp#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.View_State#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.IP_Address#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Search_Refundable#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Cloning_ID#"  cfsqltype="cf_sql_integer">,
           <cfqueryparam value="#local.stinsertdata.Reference#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Heading#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Rooms#"  cfsqltype="cf_sql_integer">,
           <cfqueryparam value="#local.stinsertdata.Search_Type_Original#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Current_Session#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Redirector#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Passthrough#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Size#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Title#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.HeaderColor#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.BodyColor#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Hotel_Country#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.International#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.HotelAddOn#"  cfsqltype="cf_sql_integer">,
           <cfqueryparam value="#local.stinsertdata.Airlines#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.ClassOfService#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.CheckIn_Date#"  cfsqltype="cf_sql_datetime">,
           <cfqueryparam value="#local.stinsertdata.CheckOut_Date#"  cfsqltype="cf_sql_datetime">,
           <cfqueryparam value="#local.stinsertdata.Air_ID1#"  cfsqltype="cf_sql_integer">,
           <cfqueryparam value="#local.stinsertdata.Air_ID2#"  cfsqltype="cf_sql_integer">,
           <cfqueryparam value="#local.stinsertdata.Air_ID3#"  cfsqltype="cf_sql_integer">,
           <cfqueryparam value="#local.stinsertdata.Air_ID4#"  cfsqltype="cf_sql_integer">,
           <cfqueryparam value="#local.stinsertdata.Hotel_Viewed#"  cfsqltype="cf_sql_integer">,
           <cfqueryparam value="#local.stinsertdata.Car_Viewed#"  cfsqltype="cf_sql_integer">,
           <cfqueryparam value="#local.stinsertdata.Hotel_Location#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Car_PickupLocation#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Car_PickupDateTime#"  cfsqltype="cf_sql_datetime">,
           <cfqueryparam value="#local.stinsertdata.Car_DropoffLocation#"  cfsqltype="cf_sql_varchar">,
           <cfqueryparam value="#local.stinsertdata.Car_DropoffDateTime#"  cfsqltype="cf_sql_datetime">,
           <cfqueryparam value="#local.stinsertdata.Cars#"  cfsqltype="cf_sql_integer">)
		</cfquery>
	</cffunction>
	
</cfcomponent>
