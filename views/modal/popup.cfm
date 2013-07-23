<!--- Modal window for popup windows

* Called from badges: details, seats, bags, email
* No title
* Close button
* bigModal class sets a wider width than default bootstrap modal
 --->

<div id="popupModal" class="bigModal modal hide fade" tabindex="-1" role="dialog" aria-labelledby="popupModalLabel" aria-hidden="true">
	<div class="modal-header">
		<button type="button" class="close" data-dismiss="modal"><i class="icon-remove"></i></button>
		<h3 id="popupModalHeader"></h3>
	</div>
	<div id="popupModalBody" class="modal-body">
		<!--- populated via js --->
		<i class="icon-spinner icon-spin"></i> One moment, we are retrieving your flight details...
	</div>
</div>