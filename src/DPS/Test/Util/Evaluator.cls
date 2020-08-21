Class DPS.Test.Util.Evaluator [ Abstract ]
{

/// d ##class(DPS.Test.Util.Evaluator).Evaluate()
ClassMethod Evaluate()
{
	set tItemSnapshot=##class(Ens.X.PoolManager.Storage.Snapshot).%OpenId("DPS.Test.Production.Main||DPS.Test.Operation.Database.Store")
	set pNewPoolSize=tItemSnapshot.DefaultPoolSize
	// empirical formula: get integral of queue sizes over a period of time (n time instants) and see if it is 3x greates that integral
	// of the same # of time instants that preceeeded the current time set. id so, multiply pool size by 1.5
	// if integral of current time set is 3x less than previous period, decrease pool size by factor 1.5
	for i=-101:5:-1 {
		set j=i+5
		&sql(SELECT SUM(QueueSize) INTO :tI(1) FROM ENS_X_POOLMANAGER_STORAGE.HISTORY WHERE Sequence BETWEEN (:i+6) AND (:i+10))
		&sql(SELECT SUM(QueueSize) INTO :tI(0) FROM ENS_X_POOLMANAGER_STORAGE.HISTORY WHERE Sequence BETWEEN (:i) AND (:i+5))
		w !,i,":",tI(1),$c(9),tI(0)
		
		if 2*tI(0)<tI(1) set pNewPoolSize=pNewPoolSize+1
		if 2*tI(1)<tI(0) set pNewPoolSize=pNewPoolSize-1	
	
		// return output
		set:pNewPoolSize>tItemSnapshot.MaxPoolSize pNewPoolSize=tItemSnapshot.MaxPoolSize
		set:pNewPoolSize<tItemSnapshot.DefaultPoolSize pNewPoolSize=tItemSnapshot.DefaultPoolSize
		set tNeedResize=$select(tItemSnapshot.CurrentPoolSize=pNewPoolSize:0,1:1)
		w $c(9),pNewPoolSize
	}
}

/// d ##class(DPS.Test.Util.Evaluator).Enumerate()
ClassMethod Enumerate() As %Status
{
	#define LOGINFO(%var) 	w !,%var
	
	#dim tSC as %Status = $$$OK
	#dim e as %Exception.AbstractException
	#dim tSetting as Ens.Config.Setting
	try {
		$$$LOGINFO("Initializing Pool Manager Service")
		// current active production
		set tProductionName=##class(Ens.Director).GetActiveProductionName()
		// call Ens.Util.Statistics:EnumerateHostStatus query
		set tStatement=##class(%SQL.Statement).%New()
		$$$THROWONERROR(tSC,tStatement.%PrepareClassQuery("Ext.DynaPool.Util.Statistics","EnumerateHostStatus"))
		#dim tRS as %SQL.StatementResult = tStatement.%Execute()
		while tRS.%Next(.tSC) {
			$$$ThrowOnError(tSC)
			set tIID=tRS.%Get("ID")
			set tName=tRS.%Get("Name")
			if tIID="" continue

			// find whether component has adapter and allows dynamic pool resize
			set tItemObj=##class(Ens.Config.Item).%OpenId(tIID,,.tSC)
			if $isobject(tItemObj)=0 continue

			if 'tItemObj.Enabled continue
			if tItemObj.AdapterClassName()'="" {
				Set tSetting = tItemObj.FindSettingByName("AllowDynamicPoolResize", "Adapter")
				If $IsObject(tSetting)&&(tSetting.Value=1) {
					$$$LOGINFO("Item '"_tItemObj.Name_"' allows for Dynamic Pool Sizing, current pool size is "_tItemObj.PoolSize)
					
					// DK: TODO - we need to be able to detect dynamically when changing production item values
					
					// record values					
					if '##class(Ext.DynaPool.PoolManager.Storage.Snapshot).%ExistsId(tProductionName_"||"_tName) {
						set tSnapshot=##class(Ext.DynaPool.PoolManager.Storage.Snapshot).%New()
						set tSnapshot.ProductionName=tProductionName
						set tSnapshot.ProductionItemName=tRS.%Get("Name")
					} else {
						set tSnapshot=##class(Ext.DynaPool.PoolManager.Storage.Snapshot).%OpenId(tProductionName_"||"_tName)
					}
					// record values that eventually changed with productioon restart
					set tSnapshot.DefaultPoolSize=tItemObj.PoolSize
					set tSnapshot.CurrentPoolSize=tItemObj.PoolSize
					set tValue="" if tItemObj.GetSetting("MaximumPoolSize",.tValue) set tSnapshot.MaxPoolSize=tValue
					$$$THROWONERROR(tSC,tSnapshot.%Save())
				}
			}
		}
	} catch (e) {
		set tSC=e.AsStatus()
	}
	Quit tSC
}

}
