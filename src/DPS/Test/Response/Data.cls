Class DPS.Test.Response.Data Extends Ens.Response
{

/// record ID
Property RID As %String;

/// SQLCODE
Property SQLCODE As %Integer;

Storage Default
{
<Data name="DataDefaultData">
<Subscript>"Data"</Subscript>
<Value name="1">
<Value>RID</Value>
</Value>
<Value name="2">
<Value>SQLCODE</Value>
</Value>
</Data>
<DefaultData>DataDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
