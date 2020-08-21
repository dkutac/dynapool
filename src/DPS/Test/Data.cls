Class DPS.Test.Data Extends %Persistent
{

Property FullName As %String;

Storage Default
{
<Data name="DataDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>FullName</Value>
</Value>
</Data>
<DataLocation>^DPS.Test.DataD</DataLocation>
<DefaultData>DataDefaultData</DefaultData>
<IdLocation>^DPS.Test.DataD</IdLocation>
<IndexLocation>^DPS.Test.DataI</IndexLocation>
<StreamLocation>^DPS.Test.DataS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
