<!--- Modal window template. --->

<!--- TODO:
Clear default layout.
Allow ability to include a header or not.
Change body of window, as needed.
Allow ability to include footer buttons, or not, and customize, as needed.
Destroy window upon closure or submittal.
--->

<!--- <cfdump var="#variables#"> --->
<div class="modal-header">
	<button type="button" class="close" data-dismiss="modal" aria-hidden="true">x</button>
	<h3 id="myModalHeader"></h3>
</div>
<div id="myModalBody" class="modal-body">
	<p>Search form goes here.</p>
</div>
<div class="modal-footer">
	<button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
	<!--- <button class="btn btn-primary">Save changes</button> --->
</div>