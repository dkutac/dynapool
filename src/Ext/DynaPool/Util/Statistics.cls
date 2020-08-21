Class Ext.DynaPool.Util.Statistics Extends Ens.Util.Statistics
{

/// Returns status for a set of hosts<br>
/// <var>ID</var> is the %ID of the host item.<br>
/// <var>Name</var> is the name of the host item.<br>
/// <var>Type</var> is the type (Service, Operation, etc.) of the host item.<br>
/// <var>Status</var> is last reported status for the item.<br>
/// <var>AdapterState</var> is connected status of jobs for this host.<br>
/// <var>LastActivity</var> is local time of last activity on this host.<br>
/// <var>ElapsedTime</var> is number of seconds from time of last activity on this host to now.<br>
/// <var>Queue</var> is the current number of items in the queue associated with this item.<br>
/// <var>Count</var> is the number of activities processed since it was started.<br>
Query EnumerateHostStatus() As %Query(ROWSPEC = "ID:%String,Name:%String,Type:%String,Status:%String,AdapterState:%String,LastActivity:%TimeStamp,ElapsedTime:%Integer,Queue:%Integer,Count:%Integer") [ SqlProc ]
{
}

ClassMethod EnumerateHostStatusFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status
{
	Set $ZT="Trap",tSC=$$$OK
	Do {
		Set Row="",AtEnd=0

		For  {
			Set qHandle = $$$OrderHostMonitor(qHandle)
			If qHandle'="Ens.MonitorService",qHandle'="Ens.Alarm",qHandle'="Ens.Alert" Quit
		}

		If (qHandle = "") {
			Set AtEnd = 1
		} Else {
			// get last slot
			Set tNow = $$$timeUTCH
			Set tDay = +tNow
			Set tSlot = ($P(tNow,",",2) \ 10)

			Set tEnabled=$G($$$ConfigIsEnabled(qHandle),0)
			Set (tCountConnected,tCountDisconnected,tCountListening,tCount)=0
			Set tJob="" For { Set tJob=$$$OrderHostMonitor(qHandle,$$$eMonitorJob,tJob)  Quit:tJob=""
				Set tConn=$e($$$GetJobMonitor(qHandle,tJob,$$$eMonitorConnected))
				If tConn=1 {
					Set tCountConnected=tCountConnected+1, tCount=tCount+1
				} ElseIf tConn=0 {
					Set tCountDisconnected=tCountDisconnected+1, tCount=tCount+1
				} ElseIf tConn="." {
					Set tCountListening=tCountListening+1, tCount=tCount+1
				}
			}
			If tCount {
				Set tConnectState=$S(tCountConnected:tCountConnected_" job"_$S(tCountConnected=1:"",1:"s")_" connected",1:"")
				Set tConnectState=tConnectState_$S(tCountDisconnected:$S(""=tConnectState:"",1:", ")_tCountDisconnected_" job"_$S(tCountDisconnected=1:"",1:"s")_" disconnected",1:"")
				Set tConnectState=tConnectState_$S(tCountListening:$S(""=tConnectState:"",1:", ")_tCountListening_" job"_$S(tCountListening=1:"",1:"s")_" listening",1:"")
			} Else {
				If 'tEnabled {
					#; Check the config database for enabled - Enabled in DB but not in Production results from being suspended by the schedule handler
					Set tConnectState=$S(##class(Ens.Director).IsItemEnabled(qHandle):"unscheduled",1:"disabled")
				} Else {
					Set tStayConn=$G($$$ConfigSetting(qHandle,"Adapter","StayConnected"),"-")
					Set tConnectState=$S("-"=tStayConn:"n/a", 1:"not connecting")
				}
			}

			Set tQueueCount=$G($$$EnsQueue(qHandle,0,"count"))
			If tQueueCount=0 Set tQueueCount=""

			// DK - wee need to return Config Item ID for further work
			Set Row=$ListBuild($$$ConfigId(qHandle),qHandle,
								$$$ConfigTypeName($G($$$ConfigBusinessType(qHandle))),
								$s(tEnabled:$$$GetHostMonitor(qHandle,$$$eMonitorStatus),1:"Disabled"),
								tConnectState,
								$$$timeUTCtoLocal($$$GetHostMonitor(qHandle,$$$eMonitorLastActivity)),
								$System.SQL.DATEDIFF("ss",$$$GetHostMonitor(qHandle,$$$eMonitorLastActivity),$$$timeUTC),
								tQueueCount,
								+$$$GetHostMonitor(qHandle,$$$eMonitorCount))
		}
	} While (0)
Exit
	Quit tSC
Trap
 	Set $ZT="",tSC=$$$EnsSystemError
	Goto Exit
}

}
