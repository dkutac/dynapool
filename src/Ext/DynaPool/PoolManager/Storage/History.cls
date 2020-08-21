Class Ext.DynaPool.PoolManager.Storage.History Extends %Persistent
{

Property QueueSize As %Integer;

Property PoolSize As %Integer;

Property TimeInstant As %TimeStamp;

Property CPUPercentage As %Float;

Property MemoryPercentage As %Float;

Property Sequence As %Integer;

Property ItemName As %String [ Calculated, SqlComputeCode = { s snap={snapshot}
 &sql(select productionitemname into :name from Ext_DynaPool_poolmanager_storage.snapshot where id = :snap)
 s {*} = name
}, SqlComputed ];

Relationship Snapshot As Ext.DynaPool.PoolManager.Storage.Snapshot [ Cardinality = parent, Inverse = Measurements ];

/// If the <var>DSTIME</var> parameter is set to AUTO then the most recent filing operation in the current DSTIME value 
/// for each object will be recorded in a global, ^OBJ.DSTIME: 
/// <br>
/// 	^OBJ.DSTIME(<var>ExtentName</var>,<var>DSTIME</var>,<var>objectID</var>) = <var>filing operation</var> 
/// <br>
/// For DSTIME=AUTO the DSTIME value is recorded in ^OBJ.DSTIME and is set by the consumer of DSTIME data.
/// <br>
/// Refer to %DeepSee documentation for more information on how DSTIME is used by %DeepSee. 
/// <br>
/// The filing operations are:
/// <table>
/// <tr><th align="left">Code</th><th align="left">Operation</th>
/// <tr><td>0</td><td align="center">Update</td></tr>
/// <tr><td>1</td><td align="center">Insert</td></tr>
/// <tr><td>2</td><td align="center">Delete</td></tr>
/// </table>
/// <br>
/// If the <var>DSTIME</var> parameter is set to MANUAL then the user is responsible for journaling object filing operations.
Parameter DSTIME As STRING [ Constraint = ",AUTO,MANUAL", Flags = ENUM ] = "AUTO";

/// DSINTERVAL is the number of seconds between one DSTIME value and the next. The DSTIME value for DSINTERVAL > 0 is computed from $ZTIMESTAMP
/// and is the number of seconds from day 0, time 0 to the nearest interval, rounded down. Using an interval has the effect of grouping
/// all DSTIME entries for the class in some number of seconds.
Parameter DSINTERVAL As INTEGER = 10;

Storage Default
{
<Data name="HistoryDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>QueueSize</Value>
</Value>
<Value name="3">
<Value>PoolSize</Value>
</Value>
<Value name="4">
<Value>TimeInstant</Value>
</Value>
<Value name="5">
<Value>CPUPercentage</Value>
</Value>
<Value name="6">
<Value>MemoryPercentage</Value>
</Value>
<Value name="7">
<Value>Sequence</Value>
</Value>
</Data>
<DataLocation>{%%PARENT}("Measurements")</DataLocation>
<DefaultData>HistoryDefaultData</DefaultData>
<IdLocation>^Ext.DynaPool.Pool7728.SnapshotC("Measurements")</IdLocation>
<IndexLocation>^Ext.DynaPool.PoolM7728.HistoryI</IndexLocation>
<StreamLocation>^Ext.DynaPool.PoolM7728.HistoryS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
