Class Ext.DynaPool.PoolManager.Storage.Snapshot Extends %Persistent
{

Property ProductionName As %String;

Property ProductionItemName As %String;

Property DefaultPoolSize As %Integer;

Property CurrentPoolSize As %Integer;

Property MaxPoolSize As %Integer;

/// must be at least 3 to allow for pool size change
Property MeasuresSinceLastPoolSizeChange As %Integer;

Index ROWID On (ProductionName, ProductionItemName) [ IdKey ];

Relationship Measurements As Ext.DynaPool.PoolManager.Storage.History [ Cardinality = children, Inverse = Snapshot ];

Storage Default
{
<Data name="SnapshotDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>DefaultPoolSize</Value>
</Value>
<Value name="3">
<Value>CurrentPoolSize</Value>
</Value>
<Value name="4">
<Value>MaxPoolSize</Value>
</Value>
<Value name="5">
<Value>MeasuresSinceLastPoolSizeChange</Value>
</Value>
</Data>
<DataLocation>^Ext.DynaPool.Pool7728.SnapshotD</DataLocation>
<DefaultData>SnapshotDefaultData</DefaultData>
<IdLocation>^Ext.DynaPool.Pool7728.SnapshotD</IdLocation>
<IndexLocation>^Ext.DynaPool.Pool7728.SnapshotI</IndexLocation>
<StreamLocation>^Ext.DynaPool.Pool7728.SnapshotS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
