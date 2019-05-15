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
    <table id="seatMapLegend" align="center">
        <tr>
            <td><span class="preferentialBox"/>&nbsp Preferred</td>
            <td><span class="availableBox"/>&nbsp Available</td>
            <td><span class="unavailableBox"/>&nbsp Unavailable</td>
            <td><span class="wingBox">W</span>&nbsp Wing Row</td>
        <tr>
    </table>
`;

var SeatMap = {

    data: {},

    config: {
        KrakenBaseUrl: '',
        ApplicationId: '',
        SecretKey: '',
        StmUserToken: '',
        TargetBranch: '',
        AccountId: 0,
        UserId: 0
    },

    get: function(){

        var data = SeatMap.data;
        
        $('.modal-body').html('<i class="fa fa-spinner fa-spin"></i><span>Loading Seat Map ...</span>');
        $('.modal-title').text('Seat Map for ' + data.SegmentRoute + ' ' + data.FLIGHTNUMBERS);

        var seatMapRequest = {
            TargetBranch: SeatMap.config.TargetBranch,
            Legs: [],
            Identity: {
                TravelerName: 'John Doe', // doesn't matter
                TravelerAccountId: SeatMap.config.AccountId,
                BookingTravelerId: SeatMap.config.UserId,
                BookingTravelerDepartmentId: 0,
                IsGuestTraveler: false,
                GuestTravelerDepartmentId: null
            }
        }

        for (var i=0; i < data.Flights.length; i++) {
            var leg = {
                Group: data.Group,
                FlightNumber: data.Flights[i].FlightNumber,
                BookingCode: data.Flights[i].BookingCode,
                Equipment: data.Flights[i].Equipment,
                Carrier: data.Flights[i].CarrierCode,
                DepartureDateTime: data.Flights[i].DEPARTURETIMEGMT,
                ArrivalDateTime: data.Flights[i].ARRIVALTIMEGMT,
                Destination: {
                    Code: data.Flights[i].DestinationAirportCode
                },
                Origin: {
                    Code: data.Flights[i].OriginAirportCode
                }
            };
            seatMapRequest.Legs.push(leg);
        }

        $.ajax({
            url: SeatMap.config.KrakenBaseUrl+'api/FlightSearchByTrip/SeatMap/Plane/',
            method: 'POST',
            headers: {
                'ApplicationId': SeatMap.config.ApplicationId,
                'SecretKey': SeatMap.config.SecretKey,
                'stm-user-token': SeatMap.config.StmUserToken,
                'Content-Type':'application/json'
            },
            dataType: 'json',
            contentType: 'application/json',
            data: JSON.stringify(seatMapRequest),
            success: function(result){
                var body = SeatMap.draw(result);
                $('.modal-body').html(body.prop('outerHTML'));
            },
            statusCode: {
                401: function() {
                    window.location.href = '/booking/?index=main.login'
                }
            }
        });
    },

    draw: function(data){

        var legend = $.parseHTML(legendTemplate);
        var tabs = $('<ul class="nav nav-tabs"></ul>');
        var content = $('<div class="tab-content"></div>');

        maps = data.SeatMaps;

        for (m = 0; m < maps.length; m++) {
               
            var map = maps[m];

            var seatmap = $('<div id="seatmap"></div>');
            var nosecone = $('<div id="nosecone"></div>');
            var tailsection = $('<div id="tailsection"></div>');
            var plane = $('<div id="plane"></div>');
            var cabin = $('<div id="cabin"></div>');

            var lastCabinClass = '';

            for (var r = 0; r < map.Rows.length; r++) {

                if (map.Rows[r].CabinClass != lastCabinClass) {

                    // gettin hacky widdit til i can fix this in kraken
                    var lastCabinClass = map.Rows[map.Rows.length-1].CabinClass;
                    if (lastCabinClass === 'F' || lastCabinClass === 'J') {
                        var cabinClassHeader = 'Main Cabin';
                    } else if (map.Rows[r].CabinClass === 'F' || (map.Rows[r].CabinClass === 'C' && map.CarrierCode === 'DL')) {
                        var cabinClassHeader = 'First Class';
                    } else if (map.Rows[r].CabinClass === 'J' && map.CarrierCode === 'B6') {
                        var cabinClassHeader = 'jetBlue MINT';
                    } else if (map.Rows[r].CabinClass === 'C' || map.Rows[r].CabinClass === 'J') {
                        var cabinClassHeader = 'Business Class';
                    } else if (map.Rows[r].CabinClass === 'W' && map.CarrierCode === 'DL') {
                        var cabinClassHeader = 'Delta Comfort';
                    } else {
                        var cabinClassHeader = 'Main Cabin';
                    }

                    cabinClass = $('<div class="cabinClass" alt="Class Code: '+map.Rows[r].CabinClass+'" title="Class Code: '+map.Rows[r].CabinClass+'">'+cabinClassHeader+'</div>');
                    cabin.append(cabinClass);

                    SeatColumns = [];
                    for (var s = 0; s < map.Rows[r].Seats.length; s++) {
                        SeatColumns.push(map.Rows[r].Seats[s].SeatColumn);
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

                    if (map.Rows[r].IsWingRow && seatData.IsWindow && seatData.SeatColumn === SeatColumns[0]) {
                        seatChars = ' W';
                    } else if (map.Rows[r].IsWingRow && seatData.IsWindow && seatData.SeatColumn === SeatColumns[SeatColumns.length-1]) {
                        seatChars = ' W';
                    } else {
                        seatChars = '&nbsp;';
                    }

                    if (seatData.SeatType === 0) {
                        var seat = $('<div class="cabinClassSeat galley">'+map.Rows[r].RowNumber.toString()+'</div>');
                    } else {
                        var seat = $('<div class="cabinClassSeat"></div>');
                        var button = $('<button class="'+seatType+'">'+seatChars+'</button>');
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

            if (m === 0) {
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

    init: function(){
        $(document).ready(function() {
            document.body.insertAdjacentHTML('beforeend',seatMapModalTemplate);
            $('.seatMapOpener').click(function () {
                SeatMap.data = $(this).data('id');
                SeatMap.get();
            });
        });
    }
};

SeatMap.init();