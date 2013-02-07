<!--- <cfdump var="#session.searches[rc.SearchID]#"> --->
<!--- <cfset structDelete(session.searches,231413) /> --->
<cfsetting showdebugoutput="false" />
<!--- <cfdump var="#session.searches[SearchID]['STHOTELS']#" abort> --->
<!--- <cfinvoke component="services.hotelrooms" method="getRooms" SearchID="231413" nHotelCode="15550" returnvariable="hotel">
<cfdump var="#hotel#" abort> --->

<!--- <cfinvoke component="services.hotelphotos" method="doHotelPhotoGallery" SearchID="231413" nHotelCode="72779" sHotelChain="CZ" returnvariable="test">
<cfdump var="#test#" abort> --->


<cfoutput>
  <div class="container">
    <div class="portfolio-items filterable">
      <div class="item ten columns">
        #View('hotel/filter')#

        <a href="#buildURL('hotel.skip?SearchID=#rc.SearchID#')#">Continue without hotel</a>
        <span id="hotelcount" style="float:right;"></span>

        <div id="hotelcountwrapper">
          <div id="page_navigation"></div>
        </div>

        <div id="infoBox" style="visibility:hidden; position:absolute; top:0px; left:0px; width:260px; z-index:10000; font-family:Arial; font-size:10px">
          <div id="infoboxText" style="background-color:White; border-style:solid; border-width:medium; border-color:DarkOrange; min-height:100px; position:absolute; top:0px; left:23px; width:240px; ">
            <b id="infoboxTitle" style="position:absolute; top:10px; left:10px; width:220px;"></b>
            <img src="assets/img/close.png" alt="close" onclick="closeInfoBox()" style="position:absolute;top:10px; right:10px;" />
            <a id="infoboxDescription" style="position:absolute; top:30px; left:10px; width:220px; color:##000000;"></a>
          </div>
        </div>

        <form method="post" action="#buildURL('hotel.search')#&SearchID=#rc.SearchID#" id="hotelForm">
          <input type="hidden" name="bSelect" value="1">
          <input type="hidden" name="SearchID" value="#rc.SearchID#">
          <input type="hidden" name="sHotel" id="sHotel" value="">
          <input type="hidden" name="sRoomDescription" id="sRoomDescription" value="">
          <input type="hidden" id="current_page" value="0" />
        </form>

        <!--- <br clear="both"> --->

        <div class="hotel" height="100%">
        	<cfset tripcount = 0 />
        	<cfset stsorthotels  = session.searches[rc.SearchID].stSortHotels />
        	<cfset stHotelChains = session.searches[rc.SearchID].stHotelChains />
        	<cfset stHotels      = session.searches[rc.SearchID].stHotels />

        	<cfloop array="#stSortHotels#" index="sHotel">

        		<cfset stHotel = stHotels[sHotel] />
        		<cfset tripcount++ />
        		<cfset PropertyID = sHotel />
        		<cfset HotelChain = stHotel.HotelChain />
        		<cfset HotelAddress = '' /><!--- Set a default address, the original ddress returned is garbage --->
        		<cfif stHotel.RoomsReturned><!--- We have the real address --->
        			<cfset HotelAddress = structKeyExists(stHotel,'Property') ? stHotel['Property']['Address1'] : '' />
        			<cfset HotelAddress&= structKeyExists(stHotel,'Property') AND Len(Trim(stHotel['Property']['Address2'])) ? ', '&stHotel['Property']['Address2'] : '' />
        		</cfif>

            <div id="#sHotel#" style="min-height:100px;">

              <cfset RoomRatePlanType = '' />
              <cfif structKeyExists(stHotel,'Rooms')>
                <cfloop list="#StructKeyList(stHotel.Rooms,'|')#" index="OneRoom" delimiters="|">
                  <cfif Len(Trim(stHotel.Rooms[OneRoom].RoomRatePlanType))>
                    <cfset RoomRatePlanType = stHotel.Rooms[OneRoom].RoomRatePlanType />
                    <cfbreak />
                  </cfif>
                </cfloop>
              </cfif>

              <table width="500px">
              <tr>
                <td width="135px">
                  <div id="hotelimage#sHotel#" class="listcell">
                    <cfset Signature_Image = StructKeyExists(stHotels[sHotel],'HOTELINFORMATION') AND StructKeyExists(stHotels[sHotel]['HOTELINFORMATION'],'SIGNATURE_IMAGE') ? stHotels[sHotel]['HOTELINFORMATION']['SIGNATURE_IMAGE'] : 'assets/img/MissingHotel.png' />
                    <!--- <img width="125px" src="#Signature_Image#" /> --->image
                  </div>
                </td>
                <td valign="top" width="365px">
                  <table width="365px">
                  <tr>
                    <td><div id="number#sHotel#" style="float:left;">#tripcount#</div> - #HotelChain# #stHotel.HotelInformation.Name#<font color="##FFFFFF"> #sHotel#</font></td>
                  </tr>
                  <tr>
                    <td><div id="address#sHotel#">#HotelAddress#</div></td>
                  </tr>
                  <cfif NOT stHotel.RoomsReturned OR (StructKeyExists(stHotel,'LowRate') AND stHotel.LowRate NEQ 'Sold Out')>
                    <tr id="DetailLinks#sHotel#">
                      <td>
                        <a onClick="showDetails(#rc.SearchID#,'#sHotel#','#HotelChain#','#RoomRatePlanType#');return false;" class="button"><button type="button" class="textButton">Details</button>|</a>
                        <a onClick="showRates(#rc.SearchID#,'#sHotel#');return false;" class="button"><button type="button" class="textButton">Rooms</button>|</a>
                        <a onClick="showAmenities(#rc.SearchID#,'#sHotel#');return false;" class="button"><button type="button" class="textButton">Amenities</button>|</a>
                        <a onClick="showPhotos(#rc.SearchID#,'#sHotel#','#HotelChain#');return false;" class="button"><button type="button" class="textButton">Photos</button>|</a>
                      </td>
                    </tr>
                  </cfif>
                  </table>
                </td>
                <td class="fares" align="center" id="checkrates2#sHotel#">

                <cfif NOT stHotel.RoomsReturned>
                  <script type="text/javascript">
                  hotelPrice(#rc.SearchID#, '#sHotel#', '#HotelChain#');
                  </script>
                  <img src="assets/img/ajax-loader.gif" />
                <cfelse>
                  <cfset RateText = StructKeyExists(stHotel,'LowRate') ? stHotel.LowRate NEQ 'Sold Out' ? DollarFormat(stHotel.LowRate) : stHotel.LowRate : 'Rates not found' />
                  #RateText#
                  <cfif RateText NEQ 'Sold Out'>
                    <div id="seerooms#sHotel#" class="button-wrapper">
                      <a onClick="showRates(#rc.SearchID#,'#sHotel#');return false;" class="button"><span>See Rooms</span></a>
                    </div>
                    <div id="hiderooms#sHotel#" class="button-wrapper hide">
                      <a onClick="hideRates('#sHotel#');return false;" class="button"><span>Hide Rooms</span></a>
                    </div>
                  </cfif>
                </cfif>
                <!--- <cfinvoke component="services.hotelrooms" method="getRooms" nearchID="#rc.SearchID#" nHotelCode="#sHotel#" returnvariable="hotel">
                <cfdump var="#hotel#" abort> --->
                <!--- <a href="http://localhost:8888/booking/services/hotelprice.cfc?method=doHotelPrice&SearchID=#rc.SearchID#&nHotelCode=#sHotel#&sHotelChain=#HotelChain#" target="_blank">Link</a><br> --->
                </td>
              </tr>
              <tr>
                <td colspan="3" id="checkrates#sHotel#"></td>
              </tr>
              </table>
            </div>
          </cfloop>
        </div>
      </div>
      <div class="item eight columns web-design">
        #View('hotel/map')#
      </div>
    </div>
  </div>
</cfoutput>

<script src="http://ecn.dev.virtualearth.net/mapcontrol/mapcontrol.ashx?v=7.0&mkt=en-us" charset="UTF-8" type="text/javascript"></script>
<script type="text/javascript">
var hotelchains = [<cfoutput><cfset nCount = 0><cfloop array="#stHotelChains#" index="sTrip"><cfset nCount++>'#sTrip#'<cfif ArrayLen(stHotelChains) NEQ nCount>,</cfif></cfloop></cfoutput>];

var map = "";
var pins = new Object;
var totalproperties = <cfoutput>#ArrayLen(session['searches'][rc.SearchID]['stsorthotels'])#</cfoutput>;
var searchid = <cfoutput>#rc.SearchID#</cfoutput>;

function loadMap(lat, long, centerimg) {

  var center = new Microsoft.Maps.Location(lat,long);
  var mapOptions = {credentials: "AkxLdyqDdWIqkOGtLKxCG-I_Z5xEdOAEaOfy9A9wnzgXtvtPnncYjFQe6pjmpCJA", center: center, mapTypeId: Microsoft.Maps.MapTypeId.road, enableSearchLogo: false, zoom: 12}
  var map = new Microsoft.Maps.Map(document.getElementById("mapDiv"), mapOptions);
  map.entities.push(new Microsoft.Maps.Pushpin(center, {icon: centerimg, zIndex:-51}));

  var orderedpropertyids = "<cfoutput>#ArrayToList(session.searches[rc.SearchID]['stSortHotels'])#</cfoutput>";
  orderedpropertyids = orderedpropertyids.split(',');
  var hotelresults = <cfoutput>#serialize(session.searches[rc.SearchID].stHotels)#</cfoutput>;

  for (loopcnt = 0; loopcnt < orderedpropertyids.length; loopcnt++) {
    var propertyid = orderedpropertyids[loopcnt];
    var property = hotelresults[propertyid]['HOTELINFORMATION'];
    var propertylat = property['LATITUDE'];
    var propertylong = property['LONGITUDE'];
    var propertyname = property['Name'];
    var propertyaddress = property['HotelAddress'];
    pins[propertyid] = new Microsoft.Maps.Pushpin(new Microsoft.Maps.Location(propertylat,propertylong), {text:loopcnt, visible:true});
    pins[propertyid].title = propertyname;
    pins[propertyid].description = propertyaddress;
    Microsoft.Maps.Events.addHandler(pins[propertyid], 'click', displayHotelInfo);
    map.entities.push(pins[propertyid]);
  }
  //Microsoft.Maps.Events.addHandler(map, 'click', changeLatLongCenter); lets you re-search                                     
  return false;
}

$(document).ready(function() {
  //$("##Hotel_Airport").autocomplete({ source: airports, minLength: 3 });
  //$("##Hotel_Landmark").autocomplete({ source: landmarks, minLength: 3 });
  //overall search hotel latitude and longitude
  loadMap(<cfoutput>#session.searches[rc.SearchID].Hotel_Lat#,#session.searches[rc.SearchID].Hotel_Long#,"assets/img/center.png"</cfoutput>);
  //hotelstructure();
  filterhotel();
});

function displayHotelInfo(e) {
  if (e.targetType == "pushpin") {
    var infoboxTitle = $('#infoboxTitle')[0];
    infoboxTitle.innerHTML = e.target.title;
    var infoboxDescription = $('#infoboxDescription')[0];
    infoboxDescription.innerHTML = e.target.description;
    var infobox2 = $('#infoBox')[0];
    infobox2.style.visibility = "visible";
    document.getElementById('mapDiv').appendChild(infobox2);
  }
  return false;
}

function closeInfoBox() {
  var infobox2 = $('#infoBox')[0];
  infobox2.style.visibility = "hidden";
  return false;
}

function changeLatLongCenter(e) {
  if (e.targetType == "map") {
    var zoom = map.getZoom();
    var infoboxvisibility = document.getElementById('infoBox').style.visibility;
    closeInfoBox();
    if (zoom >= 12 && infoboxvisibility == 'hidden') {
      $("#dialog").dialog({
        buttons: { "Yes": function() {
        var point = new Microsoft.Maps.Point(e.getX(), e.getY());
        var loc = e.target.tryPixelToLocation(point);
        $( "#latlong" ).val(loc['latitude']+','+loc['longitude']);
        $( "#changelatlong" ).submit();
        $(this).dialog("close");
        },
      'No': function() {
        $(this).dialog("close");
        }
      }
      });
    }
  }
  return false;
}

function filterhotel() {
  // pages & sortng
  var start_from = $( "#current_page" ).val() * 20;
  var end_on = start_from + 20;
  var matchcriteriacount = 0;

  <cfoutput>
  var hotelresults = #serializeJSON(session.searches[rc.SearchID].HotelInformationQuery,true)#;
  var orderedpropertyids = "#ArrayToList(session.searches[rc.SearchID]['stSortHotels'])#";
  </cfoutput>
  orderedpropertyids = orderedpropertyids.split(',');

  for (var t = 0; t < orderedpropertyids.length; t++) {
    // start the loop with 7 because property_id, signature_image, lat, long, chain_code, policy, lowrate, SOLDOUT are 0-7
    for (var i = 7; i < hotelresults.COLUMNS.length; i++) {
      var ColumnName = hotelresults.COLUMNS[i];
      var propertymatch = 1;
      if ($("#" + ColumnName + ":checked").val() != undefined) {
        if (hotelresults.DATA[ColumnName][t] == 0) {// if the value is checked and it's not active for this property mark propertymatch as 0
          propertymatch = 0;
          break;
        }
      }
    }

    // check chain code match
    var chaincode = hotelresults.DATA['CHAIN_CODE'][t];
    if (propertymatch == 1) {
      if ($("#HotelChain" + chaincode + ":checked").val() == undefined) {
        propertymatch = 0;
      }
    }

    // check Policy
    var Policy = $( "input:checkbox[name=Policy]:checked" ).val();
    var PolicyValue = hotelresults.DATA['POLICY'][t];
    if (propertymatch == 1 && Policy == 'on' && PolicyValue != '1') {
      propertymatch = 0;
    }

    // check Sold Out
    /*
    var SoldOut = $( "input:checkbox[name=SoldOut]:checked" ).val();
    var SoldOutValue = hotelresults.DATA['LOWRATE'][t];
    console.log(SoldOutValue);
    if (propertymatch == 1 && SoldOut == 'on' && SoldOutValue != '1') {
      propertymatch = 0;
    }
    */    

    var propertyid = hotelresults.DATA['PROPERTY_ID'][t];
    if (propertymatch == 1) {
      $("#" + propertyid ).show('fade');
      pins[propertyid].setOptions({visible: true});
      matchcriteriacount++;
      if (matchcriteriacount >= start_from && matchcriteriacount < end_on) {
        $("#"+propertyid ).show('fade');
        $("#number"+propertyid).html(matchcriteriacount);
        pins[propertyid].setOptions({visible:true, text:'' + matchcriteriacount + '', zIndex:1000});
      }
      else {
        $("#" + propertyid ).hide('fade');
        pins[propertyid].setOptions({visible: false});
      }
    }
    else {
      $("#" + propertyid ).hide('fade');
      pins[propertyid].setOptions({visible: false});
    }
  }

  writePages(matchcriteriacount);
  if (matchcriteriacount != totalproperties) {
    $( "#hotelcount" ).html(matchcriteriacount + ' of ' + totalproperties + ' total properties');
  }
  else {
    $( "#hotelcount" ).html(totalproperties +' total properties');
  }
  return false;
}
</script>