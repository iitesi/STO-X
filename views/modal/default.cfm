<!--- Modal window template. --->

<!--- TODO:
Clear default layout.
Allow ability to include a header or not.
Change body of window, as needed.
Allow ability to include footer buttons, or not, and customize, as needed.
Destroy window upon closure or submittal.
--->

<div id="myModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	<div class="modal-dialog" role="document">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal"><i class="icon-remove"></i></button>
				<h3 id="myModalHeader">DETAILS</h3>
			</div>
			<div id="myModalBody" class="modal-body">
				<p>Search form goes here.</p>
			</div>
			<div class="modal-footer">
				<button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
			</div>
		</div>
	</div>
</div>