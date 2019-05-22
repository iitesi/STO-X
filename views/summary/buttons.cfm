<cfoutput>
	<div class="row payment-buttons">
		<div class="col-lg-offset-8 col-lg-2 col-sm-3 col-sm-offset-6 text-right np-sm">
			<button type="submit" name="trigger" id="travelerButton" class="btn btn-primary w100-sm" value="ADD A TRAVELER">
				ADD A TRAVELER
				<i class="mdi mdi-account-multiple-plus"></i>
			</button>
		</div>
		<br class="visible-xs">
		<div class="col-lg-2 col-sm-3 text-right np-sm">
			<input type="submit" name="trigger" id="purchaseButton" class="btn teal darken-4 w100-sm" value="CONFIRM PURCHASE">
			<input type="hidden" name="trigger" id="triggerButton" value="" disabled>
		</div> <!-- /.col -->
	</div> <!-- /.row -->
</cfoutput>