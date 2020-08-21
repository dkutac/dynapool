/// injects dynamic pool resize features to adapters
Class Ext.DynaPool.PoolManager.Adapter [ System = 4 ]
{

Property AllowDynamicPoolResize As %Boolean [ InitialExpression = 0 ];

Property MaximumPoolSize As %Integer;

Parameter SETTINGS = "AllowDynamicPoolResize:Pool,MaximumPoolSize:Pool";

}
