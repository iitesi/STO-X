function HotelRoom(){

	this.apiSource = '';
	this.baseRate = 0;
	this.baseRateCurrency = '';
	this.corporateDiscountID = '';
	this.dailyRate = 0;
	this.dailyRateCurrency = '';
	this.depositRequired = false;
	this.description = '';
	this.isCorporateRate = false;
	this.isGovernmentRate = false;
	this.isInPolicy = true;
	this.outOfPolicyMessage = '';
	this.cancellationMessage = '';
	this.cancellationMessageLoaded = false;
	this.rateChange = '';
	this.ratePlanType = '';
	this.tax = 0;
	this.taxCurrency = '';
	this.totalForStay = 0;
	this.totalForStayCurrency = '';
	this.totalIncludesMessage = '';
	this.promo = '';
}

HotelRoom.prototype.populate = function( obj ){
    for(var propt in obj){
        this[propt] = obj[propt];
    }
}

HotelRoom.prototype.setInPolicy = function( policy, outOfPolicyVendor ){
	var inPolicy = true;
	var displayRoom = true;

	if( outOfPolicyVendor == true || (policy.POLICY_HOTELMAXRULE == '1' && this.dailyRate > policy.POLICY_HOTELMAXRATE)){
		inPolicy = false;
		if (policy.POLICY_HOTELMAXRULE == '1' && this.dailyRate > policy.POLICY_HOTELMAXRATE && policy.POLICY_HOTELMAXDISP == '1') {
			displayRoom = false;
		}
	}

	this.isInPolicy = inPolicy;
	this.displayRoom = displayRoom;
}

HotelRoom.prototype.setOutOfPolicyMessage = function( isInPolicy, outOfPolicyVendor ){
	var outOfPolicyMessage = "";

	if( outOfPolicyVendor == true ){
		outOfPolicyMessage = "Out of policy vendor"
	}
	else if( isInPolicy == false ){
		outOfPolicyMessage = "Maximum daily rate exceeded"
	}

	this.outOfPolicyMessage = outOfPolicyMessage;
}
