Class DPS.Test.Production.Main Extends Ens.Production
{

/// Override this in your Production class to do setup before the Production starts
ClassMethod OnStart(pTimeStarted As %String) As %Status
{
	set tSC=##class(Ens.Util.Statistics).EnableStatsForProduction()
	Quit $$$OK
}

XData ProductionDefinition
{
<Production Name="DPS.Test.Production.Main" TestingEnabled="true" LogGeneralTraceEvents="true">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="Ens.ProductionMonitorService" Category="" ClassName="Ens.ProductionMonitorService" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="Dynamic Pool File Service" Category="" ClassName="DPS.Test.Service.FileService" PoolSize="3" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="ArchivePath">C:\WORK\Ensemble\Archive</Setting>
    <Setting Target="Adapter" Name="FilePath">C:\WORK\Ensemble\In</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.dyna</Setting>
    <Setting Target="Adapter" Name="Charset">cp1250</Setting>
    <Setting Target="Adapter" Name="ConfirmComplete">2</Setting>
    <Setting Target="Adapter" Name="AllowDynamicPoolResize">1</Setting>
    <Setting Target="Adapter" Name="MaximumPoolSize">6</Setting>
    <Setting Target="Adapter" Name="CallInterval">1</Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
    <Setting Target="Host" Name="StorageOperation">Store from Dynamic Service</Setting>
  </Item>
  <Item Name="Static Pool File Service" Category="" ClassName="DPS.Test.Service.FileService" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="ArchivePath">C:\WORK\Ensemble\Archive</Setting>
    <Setting Target="Adapter" Name="FilePath">C:\WORK\Ensemble\In</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.stat</Setting>
    <Setting Target="Adapter" Name="Charset">cp1250</Setting>
    <Setting Target="Adapter" Name="ConfirmComplete">2</Setting>
    <Setting Target="Adapter" Name="AllowDynamicPoolResize">0</Setting>
    <Setting Target="Adapter" Name="MaximumPoolSize"></Setting>
    <Setting Target="Adapter" Name="CallInterval">1</Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
    <Setting Target="Host" Name="StorageOperation">Store from Static Service</Setting>
  </Item>
  <Item Name="Pool Size Monitor" Category="" ClassName="Ext.DynaPool.PoolManager.Service" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
    <Setting Target="Adapter" Name="CallInterval">2</Setting>
  </Item>
  <Item Name="Store from Dynamic Service" Category="" ClassName="DPS.Test.Operation.Database.Store" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="DSN">DYNAPOOL</Setting>
    <Setting Target="Adapter" Name="Credentials">DYNAPOOL</Setting>
    <Setting Target="Adapter" Name="AllowDynamicPoolResize">1</Setting>
    <Setting Target="Adapter" Name="MaximumPoolSize">8</Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="Store from Static Service" Category="" ClassName="DPS.Test.Operation.Database.Store" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="DSN">DYNAPOOL</Setting>
    <Setting Target="Adapter" Name="Credentials">DYNAPOOL</Setting>
    <Setting Target="Adapter" Name="AllowDynamicPoolResize">0</Setting>
    <Setting Target="Adapter" Name="MaximumPoolSize">8</Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
  <Item Name="Ens.Activity.Operation.Local" Category="" ClassName="Ens.Activity.Operation.Local" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="RecordStatsInterval">5</Setting>
    <Setting Target="Host" Name="InactivityTimeout">0</Setting>
  </Item>
</Production>
}

}
