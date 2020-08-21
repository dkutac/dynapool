Class Ext.DynaPool.PoolManager.Service Extends Ens.ProductionMonitorService
{

Parameter ADAPTER = "Ens.InboundAdapter";

Parameter SETTINGS = "GenerateSuperSessionID:Additional,AlertGracePeriod:Alerting";

/// internal property - each cycle increases this value by one and onde it hits limit given by DSPUDATEFREQ, deepsee cube is synchronized
Property DeepSeeTimeElapsed As %Integer [ InitialExpression = 0, Internal ];

/// Frequency of DeepSee 'QueueHistory' cube updates (in seconds)
Parameter DSUPDATEFREQ As INTEGER = 20;

/// minimal duration of constant pool size, this ensures that pool size is not changed more frequently that necessary
Parameter MINDURATION As INTEGER = 10;

/// frequency of alerts (in seconds) when pool size constantly at MaximumPoolSize
Parameter ALERTFREQ As INTEGER = 60;

Property AlertTimeElapsed As %Integer [ Internal ];

/// Historic Values To Keep
Parameter HVTK As INTEGER = 100;

/// walk through the production and retrieve data for determining new pool sizes
Method OnProcessInput(pInput As %RegisteredObject, Output pOutput As %RegisteredObject) As %Status
{
	#dim tSC as %Status = $$$OK
	#dim e as %Exception.AbstractException
	try {		
		#dim tSetting as Ens.Config.Setting
		set tProd=##class(Ens.Config.Production).indexNameOpen(##class(Ens.Director).GetActiveProductionName())
		
		// delete old history entries
		set tCLS=..%ClassName(0)
		set tPar=-..#HVTK
		&sql(DELETE FROM EXT_DYNAPOOL_POOLMANAGER_STORAGE.HISTORY WHERE Sequence < :tPar)
		
		// call Ens.Util.Statistics:EnumerateHostStatus query
		set tStatement=##class(%SQL.Statement).%New()
		$$$THROWONERROR(tSC,tStatement.%PrepareClassQuery("Ext.DynaPool.Util.Statistics","EnumerateHostStatus"))
		#dim tRS as %SQL.StatementResult = tStatement.%Execute()
		while tRS.%Next(.tSC) {
			$$$ThrowOnError(tSC)
			// find whether component has adapter and allows dynamic pool resize
			set tItemId=tRS.%Get("ID"),tItemName=tRS.%Get("Name") if tItemId="" continue
			set tItemObj=##class(Ens.Config.Item).%OpenId(tItemId)
			if 'tItemObj.Enabled continue
			if tItemObj.AdapterClassName()'="" {
				/******************
				/   pool resize   /
				******************/
				Set tSetting = tItemObj.FindSettingByName("AllowDynamicPoolResize", "Adapter")
				If $IsObject(tSetting)&&(tSetting.Value=1) {
					// record values 	
					set tData=##class(Ext.DynaPool.PoolManager.Storage.History).%New()
					do tData.SnapshotSetObjectId(tProd.Name_"||"_tItemName)
					set tData.TimeInstant=$zdt($now(),3)
					set tData.QueueSize=+tRS.%Get("Queue")
					set tData.PoolSize=tItemObj.PoolSize
					
					// use typeperf and wmic commands to collect (Windows) server CPU / memory utilization
					// typeperf -sc 1 "\Processor Information(_Total)\% Processor Time"
					// wmic ComputerSystem get TotalPhysicalMemory
					// wmic OS get FreePhysicalMemory
					set tData.CPUPercentage=0
					set tData.MemoryPercentage=0
					
					$$$THROWONERROR(tSC,tData.%Save())
					// !!! VERY NASTY HACK!
					// update sequence numbers
					try {
						tstart
						set k="" for {
							set k=$o(^Ext.DynaPool.Pool7728.SnapshotD(tProd.Name,tItemName,"Measurements",k),1,data) q:k=""	
							set $li(^Ext.DynaPool.Pool7728.SnapshotD(tProd.Name,tItemName,"Measurements",k),7)=+$lg(data,7)-1
						}
						tcommit
					} catch(ie) {
						trollback 1	
						$$$LOGWARNING("Error encountered during pool manager history adjustments.")					
					}
					/// !!!! END OF HACK
					
					// find whether to change pool size and if so, do it. then invoke production item update
					if ..NeedPoolResize(tProd.Name,tItemObj,.tPoolSize) {
						set tOldPool=tItemObj.PoolSize
						set tItemObj.PoolSize=tPoolSize			// pool size is components's property (not adapter's)
						$$$THROWONERROR(tSC,tItemObj.%Save())
						$$$THROWONERROR(tSC,tProd.SaveToClass(tItemObj))

						$$$EnsProdSettingsSetModified(1)
						Set $$$EnsProdSettingsOref(tSetting) = 1
						$$$LOGWARNING("Item '"_tItemObj.Name_"' - old PoolSize ("_tOldPool_") changed to new ("_tItemObj.PoolSize_").")
					}					
				}
				/****************
				/     alerts    /
				****************/
				set ..AlertTimeElapsed=..AlertTimeElapsed+..Adapter.CallInterval 
				if ..AlertTimeElapsed>=..#ALERTFREQ {
					set ..AlertTimeElapsed=0
					set tSetting  = tItemObj.FindSettingByName("MaximumPoolSize", "Adapter")
					if $isobject(tSetting) {
						set tPar=..#ALERTFREQ
						&sql(SELECT SUM(PoolSize) INTO :tPS FROM EXT_DYNAPOOL_POOLMANAGER_STORAGE.HISTORY WHERE (ItemName = :tItemName) AND (Sequence BETWEEN -:tPar AND -1))
						if tPS=..#ALERTFREQ*tSetting.Value $$$LOGALERT("Item '"_tItemName_"' - pool size at maximum allowed value ("_tSetting.Value_") for "_..#ALERTFREQ_" seconds.")
					}
				}

			}
		}
		
		/*************************
		/   update production    /
		*************************/
		If $$$EnsProdSettingsModified {
			Do ##class(Ens.Config.Production).SetModified(tProd.Name)
			$$$THROWONERROR(tSC,##class(Ens.Director).UpdateProduction())
			$$$EnsProdSettingsSetModified(0)
		}
		
		/********************
		/   update deepsee  / 
		********************/
		// (every DSUPDATEFREQ seconds) - this is relatively small cube, update shall be fast
		set ..DeepSeeTimeElapsed=..DeepSeeTimeElapsed+..Adapter.CallInterval 
		if ..DeepSeeTimeElapsed>=..#DSUPDATEFREQ {
			set ..DeepSeeTimeElapsed=0
			// me must rebuild cube as we do not update records consistently due to THE HACK
			$$$THROWONERROR(tSC,##class(%DeepSee.Utils).%BuildCube("QueueHistory",,0))
		}
	} catch (e) {
		set tSC=e.AsStatus()	
	}
	Quit tSC
}

Method NeedPoolResize(pProductionName As %String, pItemObj As Ens.Config.Item, Output pNewPoolSize As %Integer) As %Boolean
{
	#dim tItemName=pItemObj.Name
	try {
		set tItemSnapshot=##class(Ext.DynaPool.PoolManager.Storage.Snapshot).%OpenId(pProductionName_"||"_tItemName,,.tSC)
		set tItemSnapshot.MeasuresSinceLastPoolSizeChange=tItemSnapshot.MeasuresSinceLastPoolSizeChange+1
		$$$THROWONERROR(tSC,tItemSnapshot.%Save())
	
	} catch (e) {
		$$$LOGERROR("ERROR: Snapshot data not found for item: "_tItemName)
		set tExit=1
	}
	if $d(tExit) return 0
	
	set pNewPoolSize=tItemSnapshot.CurrentPoolSize
	
	// do not allow pool size more often that every MINDURATION seconds
	if (..Adapter.CallInterval*tItemSnapshot.MeasuresSinceLastPoolSizeChange)<..#MINDURATION return 0
	
	/**********************************************************************
	* call user implemented callback function to determine new pool size  *
	**********************************************************************/
	set pNewPoolSize=##class(Ext.DynaPool.PoolManager.Evaluator).GetNewPoolSize(tItemName,tItemSnapshot)
	if pNewPoolSize>tItemSnapshot.MaxPoolSize set pNewPoolSize=tItemSnapshot.MaxPoolSize
	if pNewPoolSize<tItemSnapshot.DefaultPoolSize set pNewPoolSize=tItemSnapshot.DefaultPoolSize

	set tNeedResize=$select(pItemObj.PoolSize=pNewPoolSize:0,1:1)
	if tNeedResize {
		set tItemSnapshot.MeasuresSinceLastPoolSizeChange=0
		set tItemSnapshot.CurrentPoolSize=pNewPoolSize
		set tSC=tItemSnapshot.%Save()	// reset counter
	}
	return tNeedResize
}

/// This user callback method is called via initConfig() from %OnNew() or in the case of SOAP Services from OnPreSOAP()
Method OnInit() As %Status
{
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
			// find whether component has adapter and allows dynamic pool resize
			set tItemId=tRS.%Get("ID"),tItemName=tRS.%Get("Name") if tItemId="" continue
			
			set tItemObj=##class(Ens.Config.Item).%OpenId(tItemId)
			if 'tItemObj.Enabled continue
			if tItemObj.AdapterClassName()'="" {
				Set tSetting = tItemObj.FindSettingByName("AllowDynamicPoolResize", "Adapter")
				If $IsObject(tSetting)&&(tSetting.Value=1) {
					$$$LOGINFO("Item '"_tItemObj.Name_"' allows for Dynamic Pool Sizing, current pool size is "_tItemObj.PoolSize)
					// record values					
					if '##class(Ext.DynaPool.PoolManager.Storage.Snapshot).%ExistsId(tProductionName_"||"_tItemName) {
						set tSnapshot=##class(Ext.DynaPool.PoolManager.Storage.Snapshot).%New()
						set tSnapshot.ProductionName=tProductionName
						set tSnapshot.ProductionItemName=tItemName
					} else {
						set tSnapshot=##class(Ext.DynaPool.PoolManager.Storage.Snapshot).%OpenId(tProductionName_"||"_tItemName)
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
