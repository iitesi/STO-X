var seatMapModalTemplate = `
    <div class="modal fade" id="seatMapMapModal" tabindex="-1" role="dialog" aria-labelledby="seatMapMapModalTitle" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content" style="width:600px;">
                <div class="modal-header">
                    <h5 class="modal-title" id="seatMapMapModalTitle" style="font-size:17px;font-weight:bold;"></h5>
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
        
        $('.modal-body').text('Loading Seat Map ...');
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
            }
        });
    },

    draw: function(data){

        var tabs = $('<ul class="nav nav-tabs"></ul>');
        var content = $('<div class="tab-content"></div>');

        maps = data.SeatMaps;

        for (m = 0; m < maps.length; m++) {
               
            var map = maps[m];

            var seatmap = $('<div id="seatmap"></div>');
            var plane = $('<div id="plane"></div>');
            var cabin = $('<div id="cabin"></div>');

            var lastCabinClass = '';

            for (var r = 0; r < map.Rows.length; r++) {

                if (map.Rows[r].CabinClass != lastCabinClass) {

                    if (map.Rows[r].CabinClass === 'F' || (map.Rows[r].CabinClass === 'C' && map.CarrierCode === 'DL')) {
                        var cabinClassHeader = 'First Class';
                    } else if (map.Rows[r].CabinClass === 'J' && map.CarrierCode === 'B6') {
                        var cabinClassHeader = 'JetBlue MINT';
                    } else if (map.Rows[r].CabinClass === 'C' || map.Rows[r].CabinClass === 'J') {
                        var cabinClassHeader = 'Business Class';
                    } else if (map.Rows[r].CabinClass === 'W' && map.CarrierCode === 'DL') {
                        var cabinClassHeader = 'Delta Comfort';
                    } else {
                        var cabinClassHeader = 'Main Cabin';
                    }

                    cabinClass = $('<div class="cabinClass">'+cabinClassHeader+'</div>');
                    cabin.append(cabinClass);

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

                for (var s = 0; s < seats.length; s++) {

                    var seatData = seats[s];

                    if (seatData.SeatType === 2 && seatData.IsAvailable) {
                        seatType = 'preferential';
                    } else if (seatData.IsAvailable) {
                        seatType = 'available';
                    } else {
                        seatType = 'unavailable';
                    }

                    if (map.Rows[r].CabinClass === 'F') {
                        seatType += ' first';
                    } else if (map.Rows[r].CabinClass === 'C' || map.Rows[r].CabinClass === 'J') {
                        seatType += ' business';
                    }

                    if (seatData.SeatType === 0) {
                        var seat = $('<div class="cabinClassSeat galley">'+map.Rows[r].RowNumber.toString()+'</div>');
                    } else {
                        var seat = $('<div class="cabinClassSeat"></div>');
                        var button = $('<button class="'+seatType+'">'+seatData.SeatCode+'</button>');
                        seat.append(button);
                    }

                    row.append(seat);
                }

                lastCabinClass = map.Rows[r].CabinClass;
                cabin.append(row);
            }

            plane.append(cabin);
            seatmap.append(plane);

            if (m === 0) {
                var active = ' class="active"';
            } else {
                var active = '';
            }

            var tab = $('<li'+active+'><a data-toggle="tab" href="#'+map.CarrierCode+map.FlightNumber+'">'+map.CarrierCode+map.FlightNumber+'</a></li>');
            var pane = $('<div class="tab-pane fade in active" id="'+map.CarrierCode+map.FlightNumber+'"></div>');

            tabs.append(tab);
            pane.append(seatmap);
            content.append(pane);
        }

        var container = $('<div></div>');
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