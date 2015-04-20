function HotelRoom(){

	this.dailyRate = 0;
	this.dailyRateCurrency = '';
	this.description = '';
	this.depositRequired = false;
	this.isCorporateRate = false;
	this.isGovernmentRate = false;
	this.rateChange = '';
	this.totalForStay = 0;
	this.totalForStayCurrency = '';
	this.totalIncludesMessage = '';
	this.isInPolicy = true;
	this.outOfPolicyMessage = '';
	this.ratePlanType = '';
	this.baseRate = 0;
	this.baseRateCurrency = '';
	this.tax = 0;
	this.taxCurrency = '';
	this.corporateDiscountID = '';
}

HotelRoom.prototype.populate = function( obj ){
    for(var propt in obj){
        this[propt] = obj[propt];
    }
}

HotelRoom.prototype.setInPolicy = function( policy, outOfPolicyVendor ){
	var inPolicy = true;

	if( outOfPolicyVendor == true || (policy.POLICY_HOTELMAXRULE == '1' && this.dailyRate > policy.POLICY_HOTELMAXRATE)){
		inPolicy = false;
	}

	this.isInPolicy = inPolicy;
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