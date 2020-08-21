/// 
Class Ext.DynaPool.PoolManager.Cubes.QueueHistory Extends %DeepSee.CubeDefinition [ DependsOn = Ext.DynaPool.PoolManager.Storage.History, ProcedureBlock ]
{

/// Cube definition from Architect.
XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube xmlns="http://www.intersystems.com/deepsee" name="QueueHistory" displayName="Queue History" disabled="false" abstract="false" sourceClass="Ext.DynaPool.PoolManager.Storage.History" namedFactNums="true" countMeasureName="%COUNT" bucketSize="8" bitmapChunkInMemory="false" precompute="0" disableListingGroups="false" enableSqlRestrict="false">
  <dimension name="TimeInstant" displayName="Time Instant" disabled="false" hasAll="false" allCaption="All TimeInstant" allDisplayName="TimeInstant" sourceProperty="TimeInstant" type="time" calendar="gregorian" iKnowType="entity" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="Hour" disabled="false" timeFunction="HourNumber" list="false" useDisplayValue="true" useAsFilter="true" hidden="false" factNumber="2">
      </level>
      <level name="Minute" disabled="false" timeFunction="MinuteNumber" list="false" useDisplayValue="true" useAsFilter="true" hidden="false" factNumber="3">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="ItemName" displayName="Item Name" disabled="false" hasAll="false" allCaption="All ItemName" allDisplayName="ItemName" type="data" calendar="gregorian" iKnowType="entity" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="ItemName" disabled="false" sourceProperty="ItemName" list="false" useDisplayValue="true" useAsFilter="true" hidden="false" factNumber="4">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="Sequence" disabled="false" hasAll="false" allCaption="All Sequence" allDisplayName="Sequence" type="data" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="Sequence" disabled="false" sourceProperty="Sequence" list="false" useDisplayValue="true" sort="asc numeric" useAsFilter="true" hidden="false" factNumber="5">
      </level>
    </hierarchy>
  </dimension>
  <measure name="PoolSize" disabled="false" sourceProperty="PoolSize" aggregate="MAX" type="number" hidden="false" searchable="false" factNumber="1">
  </measure>
  <measure name="QueueSize" disabled="false" sourceProperty="QueueSize" aggregate="MAX" type="number" hidden="false" searchable="false" factNumber="2">
  </measure>
</cube>
}

Parameter DOMAIN;

}
