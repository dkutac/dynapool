Class DPS.Test.Service.FileService Extends Ens.BusinessService
{

Parameter ADAPTER = "EnsLib.File.InboundAdapter";

Property StorageOperation As %String;

Parameter SETTINGS = "StorageOperation";

Method OnProcessInput(pInput As %Stream.Object, Output pOutput As %RegisteredObject) As %Status
{
	#dim tSC as %Status=$$$OK
	#dim e as %Exception.AbstractException
	try {
		while pInput.AtEnd=0 {
			set tInput=##class(DPS.Test.Request.Data).%New()
			set tInput.Name=pInput.ReadLine()
		
			$$$THROWONERROR(tSC,..SendRequestAsync(..StorageOperation,tInput))		
		}
	} catch (e) {
		set tSC=e.AsStatus()
	}
	return tSC
}

/// This method is called when Portal is drawing the production diagram
/// pArray contains the config names the scanner found.
/// Users can remove or add new names
ClassMethod OnGetConnections(Output pArray As %String, pItem As Ens.Config.Item)
{
	Do ##super(.pArray,pItem)
	If pItem.GetModifiedSetting("StorageOperation",.tValue) {
		Set pArray(tValue)=""
	}	
	Quit
}

}
