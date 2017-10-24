<cfoutput>
	<div class="row">
		<div class="col-lg-offset-8 col-lg-2 col-sm-3 col-sm-offset-6 text-right">
			<input type="submit" name="trigger" id="travelerButton" class="btn" value="ADD A TRAVELER">
		</div>
		<br class="visible-xs">
		<div class="col-lg-2 col-sm-3 text-right">
			<input type="submit" name="trigger" id="purchaseButton" class="btn btn-primary" value="CONFIRM PURCHASE">
			<input type="hidden" name="trigger" id="triggerButton" value="" disabled>
		</div> <!-- /.col -->
	</div> <!-- /.row -->
</cfoutput>

<script type="text/javascript"> 
	$( document ).ready(function() {
 		$("#purchaseForm").submit(function () {
 			var emailList = $('#ccEmails').val(); 
 			var commaLength = emailList.split(',').length; 
 			var emailCount = []; 
 			for (i=0; i < commaLength; i++){ 
 				emailList = emailList.replace(",",";");
 			 }    
 			if (emailList.indexOf(';') !== -1) {
 			 	emailCount = emailList.split(';').length;
 			 }  
 			if (emailCount > 12) {
 				alert('Please limit the CC list to 12 email addresses.');
 			}
 		return false;
 		 });
 	});
</script>