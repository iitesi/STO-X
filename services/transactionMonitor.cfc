component accessors="true"{

	property name="monitorAgent";
	property name="loggingAgent";
	property name="transactionLogFile";
	property name="enableTransactionMonitoring";
	property name="enableTransactionLogging";

	public transactionMonitor function init(
		required monitorAgent,
		required loggingAgent,
		required transactionLogFile,
		required enableTransactionMonitoring,
		required enableTransactionLogging
	) {
		setEnableTransactionMonitoring(arguments.enableTransactionMonitoring);
		setEnableTransactionLogging(arguments.enableTransactionLogging);
		if(getEnableTransactionMonitoring())
			setMonitorAgent(arguments.monitorAgent);
		if(getEnableTransactionLogging()){
			setLoggingAgent(arguments.loggingAgent);
			setTransactionLogFile(arguments.transactionLogFile);
		}
		return this;
	}

	public void function sendTransaction(required string transactionName){
		if(getEnableTransactionMonitoring())
			getMonitorAgent().sendTransaction(argumentCollection=arguments);
		if(getEnableTransactionLogging())
			getLoggingAgent().log(file=getTransactionLogFile(),text=arguments.transactionName);
	}

	public void function sendCustomDataPoint(required string key, required string value){
		if(getEnableTransactionMonitoring())
			getMonitorAgent().sendTransactionDataPoint(argumentCollection=arguments);
		if(getEnableTransactionLogging())
			getLoggingAgent().log(file=getTransactionLogFile(),text="#arguments.key#:#arguments.value#");
	}
}
