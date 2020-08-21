Class DPS.Test.Operation.Database.Store Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

Method StoreData(pRequest As DPS.Test.Request.Data, Output pResponse As DPS.Test.Response.Data) As %Status
{
	#dim tSC as %Status=$$$OK
	#dim e as %Exception.AbstractException
	try {
		set pResponse=##class(DPS.Test.Response.Data).%New()
		// insert new record into target database
		set tSQL="INSERT INTO DPS_Test.Data (FullName) VALUES (?)"
		$$$THROWONERROR(tSC,..Adapter.ExecuteUpdate(.tRowsAffected,tSQL,pRequest.Name))				
		set pResponse.SQLCODE=..Adapter.%Connection.sqlcode
	} catch (e) {
		set tSC=e.AsStatus()
	}
	return tSC
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="DPS.Test.Request.Data"> 
		<Method>StoreData</Method>
	</MapItem>
</MapItems>
}

}
