var seatMapModalTemplate = `
    <div class="modal fade" id="seatMapMapModal" tabindex="-1" role="dialog" aria-labelledby="seatMapMapModalTitle" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content" style="width:600px;">
                <div class="modal-header">
                    <h5 class="modal-title" id="seatMapMapModalTitle" style="font-size:17px;font-weight:bold;">Seat Map</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    Loading Seat Map ...
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
        StmUserToken: ''
    },

    get: function(){

        $('.modal-body').text('Loading Seat Map ...');

        var data = SeatMap.data;

        var seatMapRequest = {
            TargetBranch: 'P1601405',
            Legs: [],
            Identity: {  
                TravelerName: 'John Doe',
                TravelerAccountId: 1,
                BookingTravelerId: 376383,
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
            url: 'http://krakenqa.shortstravel.int/api/FlightSearchByTrip/SeatMap/Plane/',
            method: 'POST',
            headers: {
                'ApplicationId':'c95e0bb9-ab96-448e-bece-aa4ab0af25af',
                'SecretKey':'aI0IvR75y226ca+qRz9dPAs7pMZGXoEhaDZc8VhXp6k=',
                'stm-user-token': SeatMap.config.StmUserToken,
                'Content-Type':'application/json'
            },
            dataType: 'json',
            contentType: 'application/json',
            data: JSON.stringify(seatMapRequest),
            success: function(result){
                console.log(result);
                var body = SeatMap.draw(result);
                $('.modal-body').html(body.prop('outerHTML'));
            }
        });
    },

    draw: function(data){

        // temp sshrink to 1 map
        map = data.SeatMaps[0];

        // airplane container
        var seatmap = $('<div id="seatmap"></div>');
        var plane = $('<div id="plane"></div>');
        var cabin = $('<div id="cabin"></div>');

        // main structure
        var lastCabinClass = '';

        for (var r = 0; r < map.Rows.length; r++) {

            var rowNumber = r+1;

            // separating and labeling the cabin class
            if (map.Rows[r].CabinClass != lastCabinClass) {
                cabinClass = $('<div class="cabinClass">'+map.Rows[r].CabinClass+'</div>');
                cabin.append(cabinClass);
                if (rowNumber > 1) rowNumber++;
            }

            // an actual row of seats on the plane
            var row = $('<div class="cabinClassRow"></div>');
            var seats =  map.Rows[r].Seats;
            var seatType = '';

            for (var s = 0; s < seats.length; s++) {

                var seatData = seats[s];

                if (seatData.IsAvailable) {
                    seatType = 'available';
                } else {
                    seatType = 'unavailable';
                }

                if (map.Rows[r].CabinClass === 'F') {
                    seatType += ' first';
                }

                if (seatData.SeatType === 0) {
                    var seat = $('<div class="cabinClassSeat galley">'+rowNumber.toString()+'</div>');
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

        // assemble it all
        plane.append(cabin);
        seatmap.append(plane);

        return seatmap;
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