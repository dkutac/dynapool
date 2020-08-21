/// callback to evaluate pool size for given configuration item
Class Ext.DynaPool.PoolManager.Evaluator [ Abstract ]
{

/// this method needs to be implemented by users
ClassMethod GetNewPoolSize(pItemName As %String, pItemSnapshot As Ext.DynaPool.PoolManager.Storage.Snapshot) As %Integer
{
	// empirical formula: get integral of queue sizes over a period of time (n time instants) and see if it is 2x greates that integral
	// of the same # of time instants that preceeeded the current time set. id so, multiply by 2
	// if integral of current time set is 2x less than previous period, divide by 2
	set tNewPoolSize=pItemSnapshot.CurrentPoolSize
	
	&sql(SELECT SUM(QueueSize) INTO :tI(1) FROM Ext_DynaPool_POOLMANAGER_STORAGE.HISTORY WHERE (ItemName = :pItemName) AND (Sequence BETWEEN -5 AND -1))
	&sql(SELECT SUM(QueueSize) INTO :tI(0) FROM Ext_DynaPool_POOLMANAGER_STORAGE.HISTORY WHERE (ItemName = :pItemName) AND (Sequence BETWEEN -10 AND -6))

	// ++ play with pool size
	//if 2*tI(0)<tI(1) set pNewPoolSize=tItemSnapshot.CurrentPoolSize*2
	//if 2*tI(1)<tI(0) set pNewPoolSize=tItemSnapshot.CurrentPoolSize\2
	
	if tI(1)>(5*2000) set tNewPoolSize=pItemSnapshot.CurrentPoolSize*2
	if tI(1)<100 set tNewPoolSize=pItemSnapshot.DefaultPoolSize
	// -- finished playing
	return tNewPoolSize
}

}
