Class DPS.Test.Util.Generator [ Abstract ]
{

/// d ##class(DPS.Test.Util.Generator).Generate(10)
ClassMethod Generate(pJobs As %String)
{
	d ##class(DPS.Test.Data).%KillExtent()
	d ##class(%DeepSee.Utils).%KillCube("QueueHistory")
	h 1
	k ^dps.worker
	for i=1:1:pJobs {
		job ..Worker(i)::2		
	}
	while (+$g(^dps.worker)>0) {
		h 1
	}
	w !,"done."
}

ClassMethod Worker(pWID As %Integer)
{
	if $i(^dps.worker)
	set fn(1)="c:\WORK\Ensemble\In\DPS-"_pWID_".dyna"
	set fn(2)="c:\WORK\Ensemble\In\DPS-"_pWID_".stat"
	for j=1:1:1 {
		set tFile(j)=##class(%Stream.FileCharacter).%New()
		set tFile(j).Filename=fn(j)
		for i=1:1:(20+$random(5000)) {
			do tFile(j).WriteLine(##class(%PopulateUtils).Name())		
		}
		set tSC=tFile(j).%Save()
	}
	s ^dps.worker=^dps.worker-1
	return
}

}
