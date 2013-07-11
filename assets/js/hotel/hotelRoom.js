function HotelRoom(){

	this.dailyRate = 0;
	this.dailyRateCurrency = '';
	this.description = '';
	this.isCorporateRate = false;
	this.isGovernmentRate = false;
	this.rateChange = '';
	this.totalForStay = 0;
	this.totalForStayCurrency = '';
	this.totalIncludesMessage = '';
	this.isInPolicy = true;
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

HotelRoom.prototype.setInPolicy = function( policy ){
	var inPolicy = true;

	if( policy.POLICY_HOTELMAXRULE == '1' ){
		if( this.dailyRate > policy.POLICY_HOTELMAXRATE ){
			inPolicy = false;
		}
	}

	this.isInPolicy = inPolicy;
}
