unit inital;
interface

uses globals,modutils;
var  mon,iday,inyear:integer;

procedure ReadInputs;
Procedure getspray(date1,date2:single);
Procedure SetDates;

implementation
{$I BollwormRate.pas}
{$I BudwormRate.pas}

Procedure SetDates;
var
	j2,seasonlength : integer;
begin
// month1,day1,year1 are from command line.
// Start on Jan 1 in northern hemisphere, Jul 1 in southern.
	if LatitudeDegrees>0.0 then jdayStartModel:=1 else jdaystartModel:=julian(7,1,Year1);
	modelyear:=Year1;
	ModelStartDate:=rdate(Year1,jdayStartModel);

	jdayEmerge:=julian(month1,day1,Year1);
	Emergencedate1:=rdate(Year1,jdayEmerge);

	{End of simulation date}
	j2:=julian(month2,day2,Year2);
	ModelEndDate:=rdate(Year2,j2);
	if(ModelEndDate<ModelStartDate)then
	begin
		reporterror('Error. plant planting date should precede end date.');
		Runok:=false;
		exit;
	end;

{julian day of harvest}
{If using tmin avg this will be recomputed in main program.}
	jdayHarvest:=270;

{Count Days in model run.}
	ndays:=round(modelenddate-modelstartdate+1);

//season length using input dates
	seasonlength:=j2-jdayStartModel;

	if latitudeDegrees<0 then seasonlength:=trunc(rdate(year1+1,day2)-modelStartDate); //assume season crosses years

	HarvestDate:=ModelStartDate+seasonlength;
	if UseMinTempEnd then {Allow 60? extra days in case of cold long season.}
	begin
		harvestdate:=harvestdate+60;
		ndays:=ndays+60;
		if(modelyear mod 4)=0 then yearlength:=366 else yearlength:= 365;
	//	jdayharvest:=jdayharvest+60;
	//	if jdayharvest>yearlength then jdayharvest:=jdayharvest-yearlength;
	end;

	Emergencedate:=Emergencedate1;
	Plowdowndate:=harvestdate+10;


// Set Emergence and harvest timing dates assuming N. hemisphere.
	jdayEmergeLow:=90;	 //low end of date range to test for emergence
	jdayEmergeHigh:=180;	 //high end of date range to test for emergence

{
	Harvest date limits:
	When using low temps as harvest criterion the date must be later than EarliestHarvestDate.
	If temps don't go low enough then harvest is forced on HarvestDateLimit.

	When using only a set date as harvest time then harvest occurs on ModelEndDate -- the second date on the command line.
}

	EarliestHarvestDate:=rdate(year1,273);	//258= 9/15
	if LatitudeDegrees>34.8 then HarvestDateLimit:=rdate(year1,330);
	if ((LatitudeDegrees<=34.8)and(LatitudeDegrees>0)) then HarvestDateLimit:=rdate(year1,310);

{
previous values for HarvestDateLimit:
	if LatitudeDegrees>34.8 then HarvestDateLimit:=330; //330 is for china (11/26)- 260 for California
	if LatitudeDegrees<=34.8 then HarvestDateLimit:=330; //330 is for china - 290 for California
}

//If S. hemisphere then add 181 days to timing dates.
	if LatitudeDegrees<0.0 then
	begin
		jdayEmergeLow:=jdayEmergeLow+181;	 //low end of date range to test for emergence
		jdayEmergeHigh:=jdayEmergeHigh+181;	 //high end of date range to test for emergence

		EarliestHarvestDate:=EarliestHarvestDate+181;
		HarvestDateLimit:=rdate(year1,330)+181; //may 26 in year2
	end;

//Set Diapause start dates assuming N. hemisphere.
	BAWDiapDate:=rdate(Year1,BAWDiapJdayStart);		
	FAWDiapDate:=rdate(Year1,FAWDiapJdayStart);		
	TniDiapDate:=rdate(Year1,TniDiapJdayStart);
	BollWormDiapDate:=rdate(Year1,BollWormDiapJdayStart);
	BudWormDiapDate:=rdate(year1,BudWormDiapJdayStart);

//If S. hemisphere then add 181 days to Diapause start dates.
	if LatitudeDegrees<0.0 then
	begin
		BAWDiapDate:=BAWDiapDate+181;
		FAWDiapDate:=FAWDiapDate+181;
		TniDiapDate:=TniDiapDate+181;
		BollWormDiapDate:=BollWormDiapDate+181;
		BudWormDiapDate:=BudWormDiapDate+181;
	end;

	stopirrdate:=ModelStartDate+DaysToIrrigationStopDate;
	StopSprayDate:=ModelStartDate+DaysToSprayStopDate;
	d1wf:=modelStartdate+1000; //set very late.  it will be set at emergence.

end;

	
procedure readaster;
{
Verify order of separator lines in setup file.
Test first character for asterisk.
}
var jk:char;
begin
	readln(setFile,jk);
	if jk <> aster then
	begin
		reporterror('Input out of sequence in setup file.  Expected to read asterisk.');
		Runok:=false;
		exit;
	end;
end;

Procedure getspray(date1,date2:single);
(*
 Get the pesticide application specifications for one season.
 The first line in the data file is text.
 Each other line has a date and  toxicity, duration, and cost.
 This data is put into array sprayspecs.
 Sprayspecs will contain one row for each spray.
 Each row will have 4 columns:
  date(single format),toxicity,duration and cost.
 NUMSPR will be number of sprays specified in file

 Here is an example, the beginning of SPRAYS.73:

Mo da yr   tox   dur  cost  Spray data for Corc 73
 6 23 73   .85   7.  10.0
 6 30 73   .85   7.  10.0
 7  6 73   .85   7.  10.0
 7 13 73   .85   7.  10.0
 
 This data is put into array Sprayspecs.
 Sprayspecs will have 1 row for each pesticide application.
 SpraySpecs can hold up to 30 rows.
*) 
var
	d1,tox,dur,cost:single;
	i:byte;
	tfile:text;
	ok:boolean;
begin
	assign(tFile,SprayFile);
	{$i-} reset(tFile) {$i+};
	ok:=(ioresult = 0);
	if not ok then
	begin
		reporterror('Spray schedule file not found: '+sprayfile+'"');
		Runok:=false;
		exit;
	end;

	for i:=1 to 30 do
	begin
		Sprayspecs[i,1]:=0.0;
		Sprayspecs[i,2]:=0.0;
		Sprayspecs[i,3]:=0.0;
		Sprayspecs[i,4]:=0.0;
	end;

{ read 1 header line}
	readln(tFile);
(*
 Loop to read Spray data.
 If the date is within the season increment the counter nSprays.
*)
	numspr:=0;
	i:=1;
	repeat
		readln(tFile,mon,day,inyear,tox,dur,cost);
		if (not eof(tFile))then
		begin
			j:=julian(mon,day,inyear);
			d1:=rdate(inyear,j);
			Sprayspecs[i,1]:=d1;
			Sprayspecs[i,2]:=tox;
			Sprayspecs[i,3]:=dur;
			Sprayspecs[i,4]:=cost;
			if ((d1>=date1)and(d1<=date2))then inc(numspr);
			inc(i);
		end;
			
	until (eof(tFile) or (i=30));
	close(tFile);
end;


procedure ReadInputs;
(*
	  read initialization info from setup file.
*)
var
	ch: char;
	i,code : integer;

begin

	{Setup error log.}
	assign(errorlogfile,'errorlog');
	{$i-} append(errorlogfile) {$i+};
	i:=ioresult;
	ok:=(i = 0);
	if not ok then
	begin
		if i=2 then rewrite(errorlogfile); 
	end;


{Get command line parameters.}

	SetupFileName:=paramstr(1);

{First date on command line is planting date.  It can also be computed using running avg of soil temps.}
 
	val(paramstr(2),month1,code);
	if ((code>0)or (month1>12)) then
	begin
		reporterror('Error in date month1 ');
		Runok:=false;
		exit;
	end;

	val(paramstr(3),day1,code);
	if code>0 then
	begin
		reporterror('Error in date day1 ');
		Runok:=false;
		exit;
	end;

	val(paramstr(4),Year1,code);
	if code>0 then
	begin
		reporterror('Error in date Year1 ');
		Runok:=false;
		exit;
	end;

{Second date on command line specifies the harvest date.}

{Harvest date may be determined by running avg of tmin.}

	val(paramstr(5),month2,code);
	if ((code>0)or(month2>12)) then
	begin
		reporterror('Error in date month2 ');
		Runok:=false;
		exit;
	end;

	val(paramstr(6),day2,code);
	if code>0 then
	begin
		reporterror('Error in date day2 ');
		Runok:=false;
		exit;
	end;

	val(paramstr(7),Year2,code);
	if code>0 then
	begin
		reporterror('Error in date Year2 ');
		Runok:=false;
		exit;
	end;

	val(paramstr(8),GisOutPutInterval,code);  {0=end of season only, 10=every 10 days, 20=every 20 days,... }
	if code>0 then
	begin
		reporterror('Error in GIS output interval ');
		Runok:=false;
		exit;
	end;

	wxFilename:=paramstr(9);
(*
//can use this for collecting long sequences of runs (Diemuth)
	val(paramstr(10),RunNumber,code);
	if RunNumber=0 then
	begin
		write('RunNumber= ');
		readln(runnumber)
	end;
writeln('runnumber=',runnumber);
*)
// open weather file and get latitude.  Latitude is needed in routine SetDates.
	assign(wxfile,wxfilename);
	{$i-} reset(wxfile) {$i+};
	ok:=(ioresult=0);
	while not ok do
	begin
		reporterror('Initialize cot. Wx file not found: "'+wxfilename+'"');
		Runok:=false;
		exit;
	end;
	readln(wxfile);	//skip first line in wx file.
	readln(wxfile,Longitude,LatitudeDegrees);
	close(wxfile);
// wxfile will be opened again in Readwx.


	{Open the setup file   -- Cotton.ini for instance.}
	assign(setFile,SetupFilename);
	{$i-} reset(setFile) {$i+};
	ok:=(ioresult = 0);
	if not ok then
	begin
		reporterror('Setup file not found: '+setupfilename+'"');
		Runok:=false;
		exit;
	end;

	readln(setFile,NumberToxins);
	OneBtToxin:=false;
	TwoBtToxin:=false;
	if NumberToxins=0 then BtCotton:=false; 
	if NumberToxins=1 then OneBtToxin:=true;
	if NumberToxins=2 then TwoBtToxin:=true;
	if numbertoxins>0 then BtCotton:=true;

	{Use soil temps to determine emergence date (else use first date on command line).}
	readln(setFile,ch); UseSoilTempStart:=(upcase(ch)='T');

	{Use min temps to determine end of season   (else use second date on command line).}
	readln(setFile,ch); UseMinTempEnd:=(upcase(ch)='T');

{Adjustments for weather data --  normally=0.0}
	for i:=1 to 5 do readln(setFile,wxcons[i]);

{ImmigScalar used for Bollworm and BAW}
	readln(setfile,ImmigScalar);
	readln(setFile,EcologicalDisruption); {effect on natural enemies}
	readln(setFile,ch); EcoDisruptRandom:=(upcase(ch)='T'); // use random value each season instead of constant value read in previous line.

{Read Randseed - system variable for the randomize function.  if > 0 then use same random sequence each time.}
	readln(setfile,randseed);
	if randseed=0 then randomize;
	
{plant stand}
	readln (setFile,density);
	GISrngchk(density,1.0,20.0,'plants per meter-row');
{plant thermal threshold}
	readln(setFile,base);
	readln(setFile,kfol,kstem,kroot,kfru);

	GISirngck(kfol,10,100,'kfol');
	GISirngck(kstem,10,100,'kstem');
	GISirngck(kroot,10,100,'kroot');
	GISirngck(kfru,10,100,'kfru');
	readln(setFile,ndelay); 
	GISirngck(ndelay,1,20,'ndelay');

	readln(setFile,iety); {variety}

{	white fly }
	ReadAster;
	readln(setFile,ch); whitefly:=(upcase(ch)='T');
	readln(setFile,kwf);
	readln(setFile,ndelaywf);
	readln(setFile,betawf);
	readln(setFile,remwf);
	readln(setFile,DaysToWhiteFlyStart);//days after plant start.  D1wf will be set in main program.

	readln(setFile,nm1wf);
	readln(setFile,ch);wfimmig:=(upcase(ch)='T');
	readln(setFile,WFsprayScalar); {Spray mort scalar (0.0 to 1.0)}

	if whitefly then
	begin
		GISirngck(kwf,1,101,'kwf');
		GISirngck(ndelaywf,1,10, 'wf mort delay');
		GISrngchk(betawf,0.0,10.,'wf BETA');
		GISrngchk(remwf,0.0,30.,'wf EMERGENCE RATE');
		GISrngchk(nm1wf,0.0,1000.0, 'wf inital value');
	end;

{ Parasitoid p1}
	ReadAster;
	readln(setFile,ch);
	WFPara1:=(upcase(ch)='T');


	readln(setFile,p1num[1],p1num[2],p1num[3]);
	readln(setFile,p1wgt[1],p1wgt[2],p1wgt[3]);
	readln(setFile,kp1);
	readln(setFile,KGOp1);
	readln(setFile,ch);p1immig:=(upcase(ch)='T');

	if(WFPara1)then
	begin
		GISrngchk(p1num[1],0.0,10.0, 'p1(1) inital mass');
		GISrngchk(p1num[2],0.0,10.0, 'p1(2) inital mass');
		GISrngchk(p1num[3],0.0,10.0, 'p1(3) inital mass');
		GISrngchk(p1wgt[1],0.0,100.0, 'p1(1) inital numbers ');
		GISrngchk(p1wgt[2],0.0,100.0, 'p1(2) inital numbers ');
		GISrngchk(p1wgt[3],0.0,100.0, 'p1(3) inital numbers ');
		GISirngck(kp1,1,60,'kp1');
		GISirngck(KGOp1,0,200,'KGOp1 days>wf start');
	end; {WFPara1}
	ReadAster;

{ WFPara2}
	readln(setFile,ch);
	WFPara2:=(upcase(ch)='T');
	readln(setFile,p2num[1],p2num[2],p2num[3]);
	readln(setFile,p2wgt[1],p2wgt[2],p2wgt[3]);
	readln(setFile,kp2);
	readln(setFile,kgop2);
	readln(setFile,ch);p2immig:=(upcase(ch)='T');
	IF(WFPara2)then
	begin
		GISrngchk(p2num[1],0.0,10.0, 'p2(1) inital mass	');
		GISrngchk(p2num[2],0.0,10.0, 'p2(2) inital mass   ');
		GISrngchk(p2num[3],0.0,10.0, 'p2(3) inital mass   ');
		GISrngchk(p2wgt[1],0.0,100.0, 'p2(1) inital numbers ');
		GISrngchk(p2wgt[2],0.0,100.0, 'p2(2) inital numbers ');
		GISrngchk(p2wgt[3],0.0,100.0, 'p2(3) inital numbers ');
		GISirngck(kp2,1,60,'kp2');
		GISirngck(kgop2,0,200,'kgop2 days > CMB ');
	end; {WFPara2}

{ WFPara3}
	ReadAster;
	readln(setFile,ch);
	WFPara3:=(upcase(ch)='T');
	readln(setFile,p3num[1],p3num[2],p3num[3]);
	readln(setFile,p3wgt[1],p3wgt[2],p3wgt[3]);
	readln(setFile,kp3);
	readln(setFile,kgop3);
	readln(setFile,ch);p3immig:=(upcase(ch)='T');
	IF(WFPara3)then
	begin
		GISrngchk(p3num[1],0.0,10.0, 'p3(1) inital mass	');
		GISrngchk(p3num[2],0.0,10.0, 'p3(2) inital mass   ');
		GISrngchk(p3num[3],0.0,10.0, 'p3(3) inital mass   ');
		GISrngchk(p3wgt[1],0.0,100.0, 'p3(1) inital numbers ');
		GISrngchk(p3wgt[2],0.0,100.0, 'p3(2) inital numbers ');
		GISrngchk(p3wgt[3],0.0,100.0, 'p3(3) inital numbers ');
		GISirngck(kp3,1,60,'kp3');
		GISirngck(kgop3,0,200,'kgop3 days > CMB ');
	end; {WFPara3}
	sexr1:=0.0;
	sexr2:=0.0;
	sexr3:=0.0;


{ BAW}
	ReadAster;
	readln(setFile,ch);BAWinRun:=(upcase(ch)='T');
	readln(setFile,BAWPrefLeafAge);
	readln(setFile,kBAW);
	readln(setFile,BAWdays); {days>germination to start BAW}
	readln(setFile,BawDiapJdayStart); //jday pupae start going into diapause in N. hemisphere. (Program translates for S. hemisphere.)
	readln(setFile,pBAW); {Initial frequency of Bt resistant gene p (Cry1Ac).}
	readln(setFile,qBAW); {Initial frequency of Bt resistant gene q (Cry1Ab).}
	readln(setFile,BAWRefugeEffect); {1=zero effect, dilution effects on gene frequency}
	
{FAW}
	ReadAster;
	readln(setFile,ch);FAWinRun:=(upcase(ch)='T');
	readln(setFile,FAWPrefLeafAge);
	readln(setFile,kFAW);
	readln(setFile,FAWdays); {days>germination to start FAWmod}
	readln(setFile,FawDiapJdayStart); //jday pupae start going into diapause in N. hemisphere. (Program translates for S. hemisphere.)
	readln(setFile,pFAW); {Initial frequency of Bt resistant gene p (Cry1Ac).}
	readln(setFile,qFAW); {Initial frequency of Bt resistant gene q (Cry1Ab).}
	readln(setFile,FAWRefugeEffect); {1=zero effect, dilution effects on gene frequency}

{TNI}
	ReadAster;
	readln(setFile,ch);TniInrun:=(upcase(ch)='T');
	readln(setFile,TniPrefLeafAge);
	readln(setFile,kTni);
	readln(setFile,Tnidays); {days>germination to start Tnimod}
	readln(setFile,TniDiapJdayStart); //jday pupae start going into diapause in N. hemisphere. (Program translates for S. hemisphere.)
	readln(setFile,pTni); {Initial frequency of Bt resistant gene p (Cry1Ac).}
	readln(setFile,qTni); {Initial frequency of Bt resistant gene q (Cry1Ab).}
	readln(setFile,TniRefugeEffect); {1=zero effect, dilution effects on gene frequency}

{BollWorm}
	ReadAster;
	readln(setFile,ch);BollWorminRun:=(upcase(ch)='T');
	readln(setFile,kBollWorm);
	readln(setFile,ch);UseBollwormCounts:=(upcase(ch)='T'); //for immigration pattern, else use dd function.
	if (bollworminrun and UseBollwormCounts)then SetBollwormRate; //fill an array with normalized bollworm counts from Diemuth
	readln(setFile,BollWormDiapJdayStart); //jday pupae start going into diapause in N. hemisphere. (Program translates for S. hemisphere.)
	readln(setFile,pBollWorm); {Initial frequency of Bt resistant gene p (Cry1Ac).}
	readln(setFile,qBollWorm); {Initial frequency of Bt resistant gene q (Cry1Ab).}
	readln(setFile,BollWormRefugeEffect); {1=zero effect, dilution effects on gene frequency}
	readln(setFile,BollWormBtSusceptibility);
//BollWormDemandScalar,  %+- (i.e., 1.0 10 = stochastic 0.9 to 1.1,  or 1.0 0 = constant 1.0)
	readln(setFile, BollWormDemScalarIn, BollWormDemScalarPcnt);    //02/14/04  Need to find good value for this.  also in budworm  ????
	readln(setFile, BollWormSpMx); //Scalar applied to spray level mort.  Max=1.0;

{ BudWorm}
	ReadAster;
	readln(setFile,ch);BudWorminRun:=(upcase(ch)='T');
	readln(setFile,kBudWorm);
	readln(setFile,ch);UseBudwormCounts:=(upcase(ch)='T'); //for immigration pattern, else use dd function.
	if (Budworminrun and UseBudwormCounts)then SetBudwormRate; //fill an array with normalized bollworm counts from Diemuth
	readln(setFile,BudWormDiapJdayStart); //jday pupae start going into diapause in N. hemisphere. (Program translates for S. hemisphere.)
	readln(setFile,pBudWorm); {Initial frequency of Bt resistant gene p (Cry1Ac).}
	readln(setFile,qBudWorm); {Initial frequency of Bt resistant gene q (Cry1Ab).}
	readln(setFile,BudWormRefugeEffect); {1=zero effect, dilution effects on gene frequency}
	readln(setFile,BudwormBtSusceptibility);
//BudWormDemandScalar,  %+- (i.e., 1.0 10 = stochastic 0.9 to 1.1,  or 1.0 0 = constant 1.0)
	readln(setFile, BudWormDemScalarIn, BudWormDemScalarPcnt);    //02/14/04  Need to find good value for this.  also in bollworm  ????
	readln(setFile, BudWormSpMx); //Scalar applied to spray level mort.  Max=1.0;

{Boll weevil}
	ReadAster;
	readln(setFile,ch);bwvl:=(upcase(ch)='T');
	readln(setFile,ch);grandlure:=(upcase(ch)='T');
	readln(setfile,LureIntervalDays); {Days between applications}
	readln(setfile,LureEfficacy);
	readln(setfile,LureStartday); {days > plant emergence for 1st application}
	readln(setfile,LureStopday);  {days <> harvest for last application}
	LureAlpha:=(ln(0.1)-ln(LureEfficacy))/LureIntervalDays;

	readln(setFile,bwimrt); {#/acre during durim}
{1 acre = 4047 m**2}
{density=plants/meter row}
	bwimrt:=(bwimrt/4047.0)/density; {#/plant during durim}
	readln(setFile,durim); {immig. period time limit  dd}
	readln(setFile,bwbakim); {background immig. (nr/plant/day)}
	readln(setFile,{bwmult}bwsprayscalar); {Spray mort scalar (0.0 to 1.0)}

	ReadAster;
{
  include pink bollworm?.....................................PBW...
   PBW    TRUE if Pink BollWorm is to be included in simulation
   RINFIN infestation of overwintering  #/milliacre
   PBWSPR TRUE if PBW levels are used to signal spray
   FBINF  fraction of bolls infested to signal start spraying
   PBWPH  TRUE if pheromone application is wished
   PHMAX  maximum strength of pheromones  0 - 100
   IPH2   last date for pheromones (use as nr days past emergence)
   PTSRCO thousands of pt sources of pheromone at application
   PHINT  interval between pheromone applications
   PHEDD  start time for pheromones (DD relative to TFFB)
}
 	readln(setFile,ch);pbw:=(upcase(ch)='T');
	readln(setFile,rinfin);

	readln(setFile,BTResistP); { Frequency of BT resistance gene P}
	readln(setFile,BTResistQ); { Frequency of BT resistance gene Q}
	BtResistOrigP:=BTResistP;
	BtResistOrigQ:=BTResistQ;
	readln(setFile,ch); BtEvolution:=(upcase(ch)='T'); {Bt cotton?}

	if pbw then
	begin
		{convert to PinkBollWorm per square meter}
		rinfpp:=rinfin/4.047;
		{and then to PinkBollWorm per meter-row}
		rinfpp:=rinfpp*(38.0/39.4);
		{and finally to PinkBollWorm/plant}
		rinfpp:=rinfpp/density;
		PbwColdlx:=1.0;
	end;

	GISrngchk(rinfin,0.0,50.0, 'PBW infestation rate');
	readln(setFile,ch);pbwph:=(upcase(ch)='T');
	readln(setFile,ptsrc0);
(*
	if ptsrc0<=1000.0 then
	begin	

		writeln(' PBW pheromone parameter ptsrco has value',ptsrc0:9:2);
		writeln(' it should be > 1000.0');
		exit;
	end;
*)
	ptsrc0:=ptsrc0/1000.0;
	readln(setFile,phmax);	
	GISrngchk(phmax,1.0,99.0, 'PBW max pheromone   ');
	phmax:=phmax/100.0;
	readln(setFile,phedd);
	GISrngchk(phedd,-400.0,600.0,'Pheromone start time');
	readln(setFile,phint);
	GISrngchk(phint,100.0,500.0, 'Pheromone interval  ');
	readln(setFile,DaysToPheromoneStopDate);
	phStop:=ModelStartDate+DaysToPheromoneStopDate;	//? 1/1 or emergence?
	
	{Convert to number of days since emergence.}
	iph2:=round(phstop-Emergencedate1);	//? 1/1 or emergence?

	{Fraction of infested bolls to signal start spray}
	readln(setFile,fbinf); 
	readln(setfile,PBWsprayscalar);
	readln(setfile,PBWRefugeEffect);
{ LYGUS........................}
	ReadAster;
	readln(setFile,ch);slyg:=(upcase(ch)='T');
{ Estimate of field adult count at 1st sq}
	readln(setFile,dnslyin);
	GISrngchk(dnslyin,0.0,50.0,'LYGUS ADLT/50 SWEEPS');
{ Max lygus spray mort}
	readln(setFile,LygusSprayMortMax);
	GISrngchk(LygusSprayMortMax,0.0,1.0,'Lygus spray strength');

	ReadAster;

(*
{Get unit of output: per acre or per n plants}
	readln(setFile,rho);
	iacre:=(rho=0.0);
	if iacre then rho:=density*4000./1000.;
*)
	readln(setFile,ch);Daily:=upcase(ch)='T';
	readln(setFile,DailyOutPutInterval); {Output interval for tabular output - not gis files.}

{ Save yearly summaries?}
	readln(setFile,ch);summary:=upcase(ch)='T';

//Gis output Target: 1=ArcInfo(Casas), 2=Grass(Luigi)
	readln(setfile,GisOutputTarget);

	if daily then
	begin
		PlantFilename:='daycotgis.txt';
		assign(DailyFile,PlantFileName);
		{$i-} rewrite(DailyFile); {$i+};
		i:=ioresult;
		ok:=(i = 0);

		if not ok then
		begin
			if i=32 then writeln('The output file "daycotgis.txt" is being used.  Close it first.'); //not when in GIS system
			reporterror('Can not open: daycotgis.txt');
			Runok:=false;
			exit;
		end;
	end;

(*
 Allow Vert Wilt.............
*)
	ReadAster;
	readln(setFile,ch);VW:=upcase(ch)='T';
	readln(setfile,prpgm);
	readln(setFile,VWlx);
	readln(setFile,nVWcoh);
	if(VW)then
	begin
		GISrngchk(prpgm,0.0,61.0,'propagules/gm  soil ');
		GISrngchk(VWlx,0.,100.,'VW survivorship %   ');
		VWlx:=VWlx/100.0;

		GISirngck(nVWcoh,1,15,'VW cohorts          ');
{		estimyl(density,prpgm,VWlx);}
	end;
	if not vw then nvwcoh:=0;

{ Pesticides ----------------}
	ReadAster;
	readln(setFile,SprayMaxMortDefault); { spray strength (0 to 1.0)}

	GISrngchk(SprayMaxMortDefault,0.0,1.0,'spray strength      ');
	readln(setFile,SprayDurationDefault); {number of days to decay to 0}
	GISrngchk(SprayDurationDefault,1.0,20.0,'days spray decay    ');
	readln(setFile,PredEffectDuration); {Duration of pred spray mort}

 {Spray option 1: use bugs to trigger}
	ReadAster;
 	{use bwvl ecothr to trigger sprays?}
	readln(setFile,ch);bwsp:=(upcase(ch)='T');

	{use lygus ecothr to trigger sprays?}
	readln(setFile,ch);lygsp:=(upcase(ch)='T');

	{use pbw fbinf   to trigger sprays?}
	readln(setFile,ch);pbwspr:=(upcase(ch)='T');

	{ecothr - economic threshold of btb2}
	readln(setFile,ecothr); {controls spray start (bwv or lyg)}
{Spray option 2: use dates from a file to trigger}
	ReadAster;
	{use dates from file to schedule sprays?}
	readln(setFile,ch);spdates:=(upcase(ch)='T');

	readln(setFile,sprayFile); {name of File with spray specifications}	

 {Spray option 3: use regular intervals starting relative to tffb}
	ReadAster;
	readln(setFile,ch);SprayRelTffb:=(upcase(ch)='T'); {SprayRelTffb : boolean; Trigger sprays based on tffb and regular intervals}
	readln(setFile,SprayDDRelTffb);	{Start sprays based on tffb and regular intervals}
	readln(setFile,SprayInterval);	{Days between sprays in option 3}

	{SimspraysIn is true if pesticides are to be simulated.}
	simspraysIn:=(bwsp or lygsp or pbwspr or spdates or SprayRelTffb);
	simsprays:=simspraysin;

	readln(setFile,DaysToSprayStopDate);
	readln(setFile,maxspr); {max number of sprays}

{ Irrigation/soil water ----------------}
	ReadAster;
	readln(setFile,autoirrthresh);{When WSD < a. then irrigate.  0=no autoirr}
	autoirr:=(autoirrthresh>0.0); {Irrigate automatically when WSD<AUTOITH}
	readln(setFile,autoirramnt);{How much water per auto irr. (acre-feet)}

	{ Initial soil water conditions}
	readln(setFile,pwp); {Permanent wilting point}
	readln(setFile,soilw);
	readln(setFile,soilwmax);
	soilworig:=soilw;
{ Irr. stop date}
	readln(setFile,DaysToIrrigationStopDate);

	SetDates; 


{ inital nitr. conditions -------------------------------------}
	ReadAster;
	readln(setFile,org);    {ORG=g. initial organic matter/m**2}
	readln(setFile,soiln);  {SOILN=initial residual inorganic soil N}
	orgorig:=org;
	soilnorig:=soiln;
	readln(setFile,autoferthresh);{When SDN < autoferthresh then fertilize.}
	autofer:=(autoferthresh>0.0); {fertilize automatically if thresh>0}
	readln(setFile,autoferlbs);{How many lbs/acre auto fer.}

{ Costs --------------------------------------------------------}
{These are default costs.}
{They can be overidden by specs from file.}
	ReadAster;
	readln(setFile,costfert); { Cost/fert   $/acre}
	readln(setFile,costirr);  { Cost/irr   $/acre}
	readln(setFile,costspray);{ Cost/spray   $/acre}
	readln(setFile,costphero);{ Cost/phero   $/acre}

	readln(setFile,pricecot); { $/lb lint}
	firstcols:=true;
	GisFileIndex:=0;

	Tddb10:=0.0; {Cold measure for PBW}
	Tddb0:=0.0;
end; {procedure ReadInputs}
end.

