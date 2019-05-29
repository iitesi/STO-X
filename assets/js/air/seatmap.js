var seatMapModalTemplate = `
    <div class="modal fade" id="seatMapModal" tabindex="-1" role="dialog" aria-labelledby="seatMapModalTitle" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content" style="width:500px;">
                <div class="modal-header">
                    <h5 class="modal-title" id="seatMapModalTitle" style="font-size:17px;font-weight:bold;"></h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                </div>
                <div class="modal-footer">
                    <!--
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary">Save changes</button>
                    -->
                </div>
            </div>
        </div>
    </div>
`;

var legendTemplate = `
    <table class="seatMapLegend" align="center">
        <tr>
            <td><span class="preferentialBox"/>&nbsp Preferred</td>
            <td><span class="availableBox"/>&nbsp Available</td>
            <td><span class="unavailableBox"/>&nbsp Unavailable</td>
            <td><span class="wingBox">W</span>&nbsp Wing Row</td>
        <tr>
    </table>
`;

var SeatMap = function(){

    var data = {};

    var config = {
        DoSelectionActions: false,
        IsFullPlaneRequest: true,
        KrakenSeatMapUrl: '',
        ApplicationId: '',
        SecretKey: '',
        StmUserToken: '',
        TargetBranch: '',
        AccountId: 0,
        UserId: 0
    };

    var maxTries = 3;
    var currTries = 0;

    return {

        get: function(){

            var requestData = data;
            
            $('.modal-body').html('<i class="fa fa-spinner fa-spin"></i><span>Loading Seat Map ...</span>');
            $('.modal-title').text('Seat Map for ' + requestData.Flights[0].CarrierCode + ' ' + requestData.Flights[0].FlightNumber + ' ' + requestData.Flights[0].OriginAirportCode + '-' + requestData.Flights[0].DestinationAirportCode);

            var seatMapRequest = {
                TargetBranch: config.TargetBranch,
                Legs: [],
                Identity: {
                    TravelerName: 'John Doe', // doesn't matter
                    TravelerAccountId: config.AccountId,
                    BookingTravelerId: config.UserId,
                    BookingTravelerDepartmentId: 0,
                    IsGuestTraveler: false,
                    GuestTravelerDepartmentId: null
                }
            }

            for (var i=0; i < requestData.Flights.length; i++) {
                var leg = {
                    Group: requestData.Group,
                    FlightNumber: requestData.Flights[i].FlightNumber,
                    BookingCode: requestData.Flights[i].BookingCode,
                    Equipment: requestData.Flights[i].Equipment,
                    Carrier: requestData.Flights[i].CarrierCode,
                    DepartureDateTime: requestData.Flights[i].DepartureTimeGMT,
                    ArrivalDateTime: requestData.Flights[i].ArrivalTimeGMT,
                    Destination: {
                        Code: requestData.Flights[i].DestinationAirportCode
                    },
                    Origin: {
                        Code: requestData.Flights[i].OriginAirportCode
                    }
                };
                seatMapRequest.Legs.push(leg);
            }

            $.ajax({
                url: config.KrakenSeatMapUrl,
                method: 'POST',
                headers: {
                    'ApplicationId': config.ApplicationId,
                    'SecretKey': config.SecretKey,
                    'stm-user-token': config.StmUserToken,
                    'Content-Type':'application/json'
                },
                dataType: 'json',
                contentType: 'application/json',
                data: JSON.stringify(seatMapRequest),
                success: function(result){
                    var hasRows = result.SeatMaps[0].Rows.length;
                    if (!hasRows && currTries < maxTries) {
                        currTries++;
                        SeatMap.get();
                    } else {
                        if (!hasRows) {
                            var body = $('<p class="notFound">Sorry, no seat map available for this flight.</p>');
                        } else {
                            var body = SeatMap.draw(result);
                        }
                        $('.modal-body').html(body.prop('outerHTML'));
                    }
                },
                statusCode: {
                    401: function() {
                        window.location.href = '/booking/index.cfm?action=main.login&sessionTimeOut'
                    }
                }
            });
        },

        draw: function(result){

            var maps = result.SeatMaps;

            var legend = $.parseHTML(legendTemplate);
            var tabs = $('<ul class="nav nav-tabs"></ul>');
            var content = $('<div class="tab-content"></div>');

            for (m = 0; m < maps.length; m++) {
                
                var map = maps[m];

                var seatmap = $('<div class="seatmap"></div>');
                var nosecone = $('<div class="nosecone"></div>');
                var tailsection = $('<div class="tailsection"></div>');
                var plane = $('<div class="plane"></div>');
                var cabin = $('<div class="cabin"></div>');

                var lastCabinClass = '';

                for (var r = 0; r < map.Rows.length; r++) {

                    if (map.Rows[r].CabinClass === null || typeof map.Rows[r].CabinClass === 'undefined') {
                        map.Rows[r].CabinClass = data.Flights[0].BookingCode;
                    }

                    if (map.Rows[r].CabinClass != lastCabinClass) {

                        var lastCabinClass = map.Rows[map.Rows.length-1].CabinClass;
                        var cabinClassHeader = '';

                        // TODO: Move this chunk of logic into Kraken
                        if (config.IsFullPlaneRequest && (lastCabinClass === 'F' || lastCabinClass === 'J')) {
                            cabinClassHeader = 'Main Cabin';
                        } else if ((map.Rows[r].CabinClass === 'F' || map.Rows[r].CabinClass === 'I') 
                            || (map.Rows[r].CabinClass === 'C' && map.CarrierCode === 'DL')) {
                            cabinClassHeader = 'First Class';
                        } else if (map.Rows[r].CabinClass === 'J' && map.CarrierCode === 'B6') {
                            cabinClassHeader = 'jetBlue MINT';
                        } else if (map.Rows[r].CabinClass === 'C' || map.Rows[r].CabinClass === 'J') {
                            cabinClassHeader = 'Business Class';
                        } else if (map.Rows[r].CabinClass === 'W' && map.CarrierCode === 'DL') {
                            cabinClassHeader = 'Delta Comfort';
                        } else {
                            cabinClassHeader = 'Main Cabin';
                        }

                        cabinClass = $('<div class="cabinClass" alt="Class Code: '+map.Rows[r].CabinClass+'" title="Class Code: '+map.Rows[r].CabinClass+'">'+cabinClassHeader+'</div>');
                        cabin.append(cabinClass);

                        var seatColumns = [];
                        for (var s = 0; s < map.Rows[r].Seats.length; s++) {
                            seatColumns.push(map.Rows[r].Seats[s].SeatColumn);
                        }

                        var cabinClassColumns = $('<div class="cabinClassColumns"></div>');
                        for (var s = 0; s < map.Rows[r].Seats.length; s++) {
                            if (map.Rows[r].Seats[s].SeatColumn === '') {
                                cabinClassColumns.append($('<div class="cabinClassSeat"></div>'));
                            } else {
                                cabinClassColumns.append($('<div class="cabinClassColumn">'+map.Rows[r].Seats[s].SeatColumn+'</div>'));
                            }
                        }
                        cabin.append(cabinClassColumns);
                    }

                    var row = $('<div class="cabinClassRow"></div>');
                    var seats =  map.Rows[r].Seats;
                    var seatType = '';
                    var seatChars = '';

                    for (var s = 0; s < seats.length; s++) {

                        var seatData = seats[s];

                        if (seatData.SeatType === 2 && seatData.IsAvailable) {
                            seatType = 'preferential';
                        } else if (seatData.IsAvailable) {
                            seatType = 'available';
                        } else {
                            seatType = 'unavailable';
                        }

                        if (map.Rows[r].IsWingRow && seatData.IsWindow && seatData.SeatColumn === seatColumns[0]) {
                            seatChars = ' W';
                        } else if (map.Rows[r].IsWingRow && seatData.IsWindow && seatData.SeatColumn === seatColumns[seatColumns.length-1]) {
                            seatChars = ' W';
                        } else {
                            seatChars = '&nbsp;';
                        }

                        if (seatData.SeatType === 0) {
                            var seat = $('<div class="cabinClassSeat galley">'+map.Rows[r].RowNumber.toString()+'</div>');
                        } else {
                            var clickAction = '';
                            if (config.DoSelectionActions && seatType != 'unavailable') {
                                clickAction = "SeatMap.setSeat('"+map.FlightNumber+"','"+map.OriginAirportCode+"','"+seatData.SeatCode+"','"+seatData.SeatType+"');";
                            }
                            var seat = $('<div class="cabinClassSeat"></div>');
                            var button = $('<button class="'+seatType+'" onclick="'+clickAction+'">'+seatChars+'</button>');
                            seat.append(button);
                        }

                        row.append(seat);
                    }

                    lastCabinClass = map.Rows[r].CabinClass;

                    cabin.append(row);
                }

                plane.append(cabin);
                seatmap.append(plane);
                seatmap.prepend(nosecone);
                seatmap.append(tailsection);

                if (m == 0) {
                    var activeTab = ' class="active"';
                    var activePane = ' in active';
                } else {
                    var activeTab = '';
                    var activePane = '';
                }

                var tab = $('<li'+activeTab+'><a data-toggle="tab" href="#menu'+m+'">'+map.CarrierCode+map.FlightNumber+'</a></li>');
                var pane = $('<div class="tab-pane fade'+activePane+'" id="menu'+m+'"></div>');

                tabs.append(tab);
                pane.append(seatmap);
                content.append(pane);
            }

            var container = $('<div></div>');
            container.append(legend);
            container.append(tabs);
            container.append(content);

            return container;
        },

        setSeat: function(flightNumber, originAirportCode, seatCode, seatType){
            $('#link_seatId_'+flightNumber+'_'+originAirportCode).text(seatCode);
            $('#seatId_'+flightNumber+'_'+originAirportCode).val(seatCode+':'+seatType);
            $('.close',$('#seatMapModal')).click();
        },

        setData: function(_data){
            if (!Array.isArray(_data.Flights)) {
                _data = {
                    Flights: [_data]
                };
            }
            data = _data;
        },

        getData: function(){
            return data;
        },

        getConfig: function(){
            return config;
        },

        init: function(_config){
            config = _config;
            $(document).ready(function() {
                document.body.insertAdjacentHTML('beforeend',seatMapModalTemplate);
                $('.seatMapOpener').click(function () {
                    currTries = 0;
                    SeatMap.setData($(this).data('id'));
                    SeatMap.get();
                });
            });
        }
    }

}();