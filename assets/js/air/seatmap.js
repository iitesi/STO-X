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

    get: function() {

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
            url: 'http://krakenqa.shortstravel.int/api/FlightSearchByTrip/SeatMap/',
            method: 'POST',
            headers: {
                'ApplicationId':'c95e0bb9-ab96-448e-bece-aa4ab0af25af',
                'SecretKey':'aI0IvR75y226ca+qRz9dPAs7pMZGXoEhaDZc8VhXp6k=',
                'stm-user-token':'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6ImdrZXJuZW4iLCJuYW1laWQiOiIzNzYzODMiLCJBY2NvdW50SWQiOiIxIiwiRGVwYXJ0bWVudElkIjoiMTM1MTQiLCJuYmYiOjE1NTc1NjIyNjUsImV4cCI6MTU1NzU2NDA2NSwiaWF0IjoxNTU3NTYyMjY1LCJpc3MiOiJLcmFrZW4iLCJhdWQiOiJTVE9WRSJ9.pm0O_O335aBmbrG24wbAfWYtJmqmdhch0DV6nqrPoIg',
                'Content-Type':'application/json'
            },
            dataType: 'json',
            contentType: 'application/json',
            data: JSON.stringify(seatMapRequest),
            success: function(result){
                var modal = $('#seatMapMapModal');
                $('.modal-body',modal).html("result");
            }
        });
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