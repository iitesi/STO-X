<!--- Modal window for popup windows

* Called from badges: details, seats, bags, email
* No title
* Close button
* bigModal class sets a wider width than default bootstrap modal
 --->

<div id="popupModal" class="bigModal modal hide fade" tabindex="-1" role="dialog" aria-labelledby="popupModalLabel" aria-hidden="true">
	<div class="modal-header">
		<button class="btn pull-right" data-dismiss="modal" aria-hidden="true">Close</button>
		<h3><i class="icon-plane"></i> FLIGHT DETAILS</h3>
	</div>
	<div id="popupModalBody" class="modal-body">
		<!--- populated via js --->
		<i class="icon-spinner icon-spin"></i> One moment, we are fetching your flight details...
	</div>
</div>