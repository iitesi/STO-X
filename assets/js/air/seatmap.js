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

        // table rows
        var rows = [];

        // temp sshrink to 1 map
        seatMap = data.SeatMaps[0];

        // airplane container
        var seatmap = $('<div id="seatmap"></div>');
        var plane = $('<div id="plane"></div>');
        var cabin = $('<div id="cabin"></div>');

        // main table structure
        var table = $('<table></table>');

            // wingrow in the right
            var wingRowRight = $('<tr class="wingRowRight"></tr>');
            for (var i=0; i < 10; i++) {
                var wingCol = $('<td></td>');
                wingRowRight.append(wingCol);
            }
            table.append(wingRowRight);

            // reverse for display
            seatMap.ColumnHeaders.reverse();
            
            // fill in the seats by column (A,B,D, ,E,F,G) etc
            for (var c = 0; c < seatMap.ColumnHeaders.length; c++) {
                var row = $('<tr></tr>');
                if (seatMap.ColumnHeaders[c] === '') {
                    row.append($('<td class="colHeaderGalley">'+seatMap.ColumnHeaders[c]+'</td>'));
                } else {
                    row.append($('<td class="colHeader">'+seatMap.ColumnHeaders[c]+'</td>'));
                }
                for (var r = 0; r < 20; r++) {
                    for (var s = 0; s < seatMap.Rows[r].Seats.length; s++) {
                        var seatData = seatMap.Rows[r].Seats[s];
                        if (seatData.SeatColumn === seatMap.ColumnHeaders[c]) {
                            if (seatData.SeatColumn === '') {
                                var seat = $('<td class="noSeatGalley"></td>');
                            } else {
                                var seat = $('<td class="seatAvailable" title="'+seatData.SeatCode+'" alt="'+seatData.SeatCode+'"></td>');
                            }
                            row.append(seat);
                        }
                    }
                }
                rows.push(row);
            }
            table.append(rows);

            // wingrow in the left
            var wingRowLeft = $('<tr class="wingRowLeft"></tr>');
            for (var i=0; i < 10; i++) {
                var wingCol = $('<td></td>');
                wingRowLeft.append(wingCol);
            }
            table.append(wingRowRight);

            // assemble it all
            cabin.append(table);
            plane.append(cabin);
            plane.append($('<div style="clear: both;"></div>'));
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