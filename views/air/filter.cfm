<div id="filterbar">
	<!---
	<div id="sortbar">
		<div class="filterheader">Sort By</h2>
		<input type="radio" id="price" name="sort" /><label for="price">Price</label>
		<input type="radio" id="duration" name="sort" checked="checked" /><label for="duration">Duration</label>
		<input type="radio" id="departure" name="sort" /><label for="departure">Departure</label>
		<input type="radio" id="arrival" name="sort" /><label for="arrival">Arrival</label>
		<input type="radio" id="bagfees" name="sort" /><label for="bagfees">Bag Fees</label>
	</div>
	--->
	<div class="filterheader">Filter By</h2>
	<input type="checkbox" id="Airlines"> <label for="Airlines">Airlines</label>
	<input type="checkbox" id="Class"> <label for="Class">Class</label>
	<input type="checkbox" id="Fares"> <label for="Fares">Fares</label>
	<input type="checkbox" id="NonStops" name="NonStops" value="1" onChange="filterAir();"> <label for="NonStops">Non Stops</label>
	<input type="checkbox" id="Policy" value="1" onChange="filterAir();"> <label for="Policy">In Policy</label>
	<input type="checkbox" id="Time"> <label for="Time">Time</label>
</div>