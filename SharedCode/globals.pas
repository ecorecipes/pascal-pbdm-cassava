unit globals;
interface
type
	single100  = array[1..100] of single;
	SINGLE100100 = array[1..100, 1..100] of single;
	single10   = array[1..10] of single;
	weather   = array [1..73050] of single;	//73050=365.25*200  allows 200 years
	weathers  = array [1..73050, 1..2] of single;
	string14  = string[14];
	real6 = array[1..6] of real;
const
	tb = #9; {Tab character for output}

{general variables}
var
	runok:boolean; {set false if an error requires ending current run.  Allows next run to continue.}
	EndFileWritten,DoEndFile:					boolean;


	CottonGrowing:boolean; {true between emergence and 	harvest dates}
	CottonHasStarted:boolean;
	jdayEmergeLow,jdayEmergeHigh:integer; //used for date range to test for emergence
	EarliestHarvestDate,HarvestDateLimit:real; //used in season end tests

	solar,rain,relhum,winds                         : weather;
	temps                                           : weathers;
	wxcons : array[1..5] of single;
	v                                               : SINGLE100;
	vs,location : string; {used in reporterror messages}

	wxid                                     : string[32];
	Filename,Plantfilename: string;
	gisFilename,SummaryFileName,Wxfilename,setupFileName: string; 
	wxfile,dailyfile: text;
	gisfile,errorlogfile,SummaryFile: text;
	gisfilesListfile:text; //list of gis file names to use at end for averages.
	gisavgfile:text;

	PlantDatesFile:text;

	dailyOutputInterval:integer;
	iacre,ok,firstcols,Summary,SummaryWritten,daily       : boolean;
	rainmrt,smooth                                  : boolean;
	tmax,tmin,tmean,precip,wind,rhmean,solrad       : single;

	UseSoilTempStart			: boolean;
	SoilTempMean:single;
	SoilTempArray:SINGLE100;
	SoilTempRunAvg:single;
	SoilTempIndex:word;

	UseMinTempEnd			: boolean;
	MinTempArray:SINGLE100;
	MinTempRunAvg:single;
	MinTempIndex:word;

	density                                     : single;
	nrSeasons,jday,nplants,iyr                   : integer;
	ndays:word; {May be many years so could be larger than 32767}

	jdaylimit:integer;

	JdayEmerge:integer;
	month1,day1,Year1                               : integer;
	month2,day2,Year2                               : integer;
	modelday,modelyear	                        : word;
	yearlength                        : integer;
	GisOutputInterval:integer; {0=end of season only, 10=every 10 days, 20=every 20 days,... Set in setup file.}

	GisFileIndex:integer;

	IHR,IMIN,ISEC,Ic1,IHR2,IMIN2,ISEC2,Ic2          : word;
	i,j,k,m                                         : integer;
	month,day,modelnday                                      : byte;
	ModelDate                                       : single;
	RunNumber:byte;

{varietal variables }
	vbud,vbloom     : SINGLE100;
	vyboll,vgrow,vgreenb,vgrnfrt,vBwmFrt,vopen,vseedcot,vfruit : SINGLE100;
	ddb,dda,base                                    : single;
	dda10,ddb10,Tddb10,dda0,ddb0,Tddb0,ColdMort,ColdMortLx  :single;
	
	ageboll                                         : single; {start of bolls}
	BTcotton,OneBtToxin,TwoBtToxin	:boolean; 
	NumberToxins:byte;
	ageflr,agegrow,seedage,agemax   : single;
	shedminbud,shedmaxbud,winmax    : single;
	shedminboll,shedmaxboll                 : single;
	dmgmle                                                  : single;
	tffb,ratefp                                             : single;
	fpmult    : single; {used to vary ratefp each season in Inits.}
	kfol,kroot,kstem,kbud,kfru              : byte;
	delfol,delroot,delstem                  : single;
	delkfol,delkroot,delkstem,delkFru  : single;
	db                                              : single;
	dlp,dsp,drp                             : single;
	costph                                  : single;
	ndelay                                  : byte;
	bales : single;

{plant variables}
	iety                                            : byte;
	ModelStartDate,ModelEndDate			: single;
	GisOutputTarget:byte; //1=ArcInfo(Casas), 2=Grass(Luigi)

	Emergencedate1,harvestdate1,PlowdownDate1       : single; {for season 1}
	Emergencedate,harvestdate,PlowdownDate          : single; {for subsequent seasons}
	HarvestDateInput:single;
	HarvestMonth,HarvestDay:byte;
	PlowdownDateCounter:byte;
	JdayStartModel,JdayStartPlant,JdayHarvest : integer;
	folwgt,stemwgt,rootwgt,fruwgt,frunum,frunit             : SINGLE100;
	Fruwgtattkd,frunumsattkd:single100;

	pcntpar,frumass,bloom,pbwdam:single;
	fol1,vdl,vdr,vds,vlmax,stem1,vsmax : single;
	ginlx,rateq,tnode,yintcp : single;
	FruMassOut,DamagedFruMassOut,FruNumOut,fp,attkfrumass,attkFruNums:single;
	MassAtkd,NumAtkd:array[1..7] of single;

	fruitinc,veginc,respinc         : single;
	d1,d2,d3,d4                             : single;
	shdnr,shdmass,SumFruitShed,tshdmass,tdwgt   : single;

	DaysToEmergence,DaysToWhiteFlyStart,DaysToStartBawDiapause,DaysToStartFawDiapause,DaysToStartTniDiapause:integer;
	DaysToStartBollWormDiapause,DaysToStartBudWormDiapause,DaysToPheromoneStopDate,DaysToSprayStopDate,DaysToIrrigationStopDate:integer;

{
SumFruitShed= cumulative sheds due to sd stress +
		 squares shed due to BW attack +
		 BW damaged bolls due to sd stress +
		 sheds due to lygus.
}
	tdda, TddToHarvest              : single;
	totph,reserve,resinc,resold     : single;
	sdarray                         : single10;
	sdweek                          : array[1..12] of single;
	lai,prevlairatio,maxlai         : single;
	laiLimitReached : boolean;
   {recomputed each day}                
	fruplr                          	: SINGLE100;
	BWDamagedBolls,BWDamagedBollsm                            : SINGLE100; {damagedbolls}
	dsq,wdsq                                : array[1..20] of single;
	totalr,totall,totals,totalf                             : single;{current wgts}

	buds,openbollmass,openbollnums,greenbollnums,greenbollmass           : single;
	totalbollnums,totalbollmass,seedcotnums,seedcotmass:single;
	pdemand,costmr,costlr                 : single; {set in demand, used in supply}
	dmlsr,dmbud,dmfru               : single; {set in demand, used in ratios}
	dmres                                   : single; {set in demand, used in ratios, plant}
	dmresp                                  : single; {set in supply, used in ratios}
	dl,ds,dr,dlmax                               : single;
	sdfrt,sdlsr,sdtot               : single;
	gb,gf : single;
	TempScalar:single;

{variables to save values at harvest for Gis cotton plant output:}
	UseHarvestValues:boolean;
//plant
	tddaSave,BudsSave,greenbollNumsSave,openbollnumsSave,TotalSSave,TotalLsave,FruMassSave,sdlsrSave,wsdSave,nsdtotSave,BalesSave:real;
	FruNumOutSave,FruMassOutSave:real;
//wf
	OvanumwfSave,larvnwfSave,pupawfSave,adultswfSave,p1num1Save,p2num1Save,p3num1Save:real;
//BAW
	BawEggtotSave,BawLarsmallSave,BawLarbigSave,BawPuptotSave,BawAdlttotSave,BawPretotSave,BawSdSave,BawDiapTotSave,
	BawAdpreSave,pBawSave,qBawSave:real;
	BawBtLeafConcentration:real;
//FAW
	FAWeggtotSave,FAWlarsmallSave,FAWlarbigSave,FAWpuptotSave,FAWadlttotSave,FAWpretotSave,FAWsdSave,FAWDiapTotSave,
	FAWadpreSave,pFAWSave,qFAWSave:real;
	FawBtLeafConcentration:real;
//Tni
	TnieggtotSave,TnilarsmallSave,TnilarbigSave,TnipuptotSave,TniadlttotSave,TnipretotSave,TnisdSave,TniDiapTotSave,
	TniadpreSave,pTniSave,qTniSave:real;
	TniBtLeafConcentration:real;
//BollWorm
	BollWormeggtotSave,BollWormlarsmallSave,BollWormlarbigSave,BollWormpuptotSave,BollWormadpreSave,BollWormpretotSave,BollWormsdSave,BollWormDiapTotSave,
	pBollWormSave,qBollWormSave:real;
	BollWormDemScalarIn, BollWormDemScalar:single;
	BollWormDemScalarPcnt:integer;

	BollWormBtFruitConcentration:single;
	UseBollwormCounts:boolean; //for immigration pattern, else use dd function.
	BollwormDiapTot:real;	
	BollWormSpMx:real; //Scalar applied to spray level mort.  Max=1.0;
	BWRate:array[1..366]of real;
	BollwormOvipAdults:real;
	BollwormFruitDemand:array[1..5]of real;
	BollWormBt1MortArray,BollWormBt2MortArray:single10;
//BudWorm
	BudwormeggtotSave,BudwormlarsmallSave,BudwormlarbigSave,BudwormpuptotSave,BudwormAdPreSave,BudwormpretotSave,BudwormsdSave,BudwormDiapTotSave,
	pBudwormSave,qBudwormSave:real;
	BudwormDemScalarIn, BudwormDemScalar:single;
	BudwormDemScalarPcnt:integer;
	BudwormBtFruitConcentration:single;
	BudwormBtSusceptibility:real;
	BudwormDiapTot:real;
	BudwormSpMx:real; //Scalar applied to spray level mort.  Max=1.0;
	BudWRate:array[1..366]of real;
	BudwormOvipAdults:real;
	BudwormFruitDemand:array[1..5]of real;
	BudwormBt1MortArray,BudwormBt2MortArray:single10;

//BWVL
	bweggSave,bwLarvSave,bwAdltsSave:real;
	bweggSum,bwLarvSum,bwAdltsSum:real;

//pbw
	PbweggsSave,PbwImmaturesSave,PbwAdultsSave,TotPbwDiapausersSave,SumDiapsEmergedSave,PbwColdLxSave,btresistPSave,btresistQSave:real;
	TotPBWLarvFromBollsSave,Tddb10Save,Tddb0Save:real;
	TotPbwDiapausersToGIS,SumDiapsEmergedToGis:real;

	PbweggsSum,PbwImmaturesSum,PbwAdultsSum,TotPbwDiapausersSum,TotPBWLarvFromBollsSum:real;
	LarvPerBollSave:real;
	TotLarvToPupSum:real;
//lygus
	lyguspersquare:single;
	xnymphsSave,hadultSave,LygusPerSquareSave:real;


{water}
   {individual plant variables}
   {kept day to day}
	wsdarray                        : single10;{wsd record}
	iwsd                            : byte;{ptr to most recent ws in wsdarray}

   {recomputed each day}
	wsd                     : single;
	wdemand {was tritch}            : single; {plant demand for transpiration}
	transpire                       : single; {water used by plant}

   {associated with a plant  or with a region of field?}
	evapsoil {was ES}               : single; {may be F(all nearby plants)}

	{field water variables}
	soilw,soilwmax,avlw,pwp  :single;
	soilworig:single;
	autoirr       : boolean;
	autoirrthresh : single;
	autoirramnt   : single;
	irrdates      : boolean;
	irrfile       : string14;
	stopirrdate   : single;
	irrspecs          : array[1..10,1..2] of single; {irr specs from file}
	nirrs :byte;
	totwatloss        : single;
	
	es1,es2,watertime,prevawat              : single;
	watfirst                                        : boolean;

{nitrogen}
	orgorig,soilnorig:single;
	folnit,npcfol,npcfru,stnit,rtnit                        : SINGLE100;
	ndl,nds,ndr,ndfru,ndres,ndlsr,ndtot             : single;
	pcntln,pcntstn,pcntrtn,pcntsqn,pcntbln : single;
	nappl1,nappl : single;
	autofer : boolean;
	autoferthresh : single;
	autoferlbs    : single;
	ferdates    : boolean;
	ferspecs    : array[1..10,1..2] of single; {fert specs from file}
	nsdfru,nsdlsr,nsdtot,org,org1,soiln,soiln1,nres,nveg    : single;
	prevanit,ntlout,ntsout,ntrout                   : single;
	nferts          : byte; {number of fertilizer applications}

{pesticide}
	simsprays,simspraysin      : boolean; {inital.  simulate spray?}
	spraytoday                 : boolean; 
	markspray : byte;	{Used in output to indicate a spray day}
	SprayMaxMortDefault      : single; {shape of spray mort funct.}
	SprayDurationDefault                     : integer; {days of spray duration}
	SprayMaxMort,SprayCost : single;
	spraylevel : single; 
	sprday : integer;       {count of days since last spray - used in spraylevel function}
	SprayDuration :integer;
	PredEffectDuration:integer; { Duration of pred spray mort}
	LinearPredEffect:single;
	StopSprayDate                             : single;       {no sprays after this date}
	maxspr                                    : byte;  {max number of sprays}
	SpraysDone                                : byte; {number of sprays done}
	EcologicalDisruption:single;	//spray effect on natural enemies  1.0=max.
	EcoDisruptRandom:boolean; //use random value each season instead of  value in EcologicalDisruption.
      {option 1}
	bwsp,lygsp,pbwspr : boolean; {trigger sprays based on bugs}
	bwSprayScalar:single; {modify effect of sprays on bw}
	BwSprayLX,ecothr,btb2,cumd : single; 

      {option 2}
	spdates : boolean;	{trigger sprays based on dates in a file}
	sprayfile                                 : string14; {file with dates and spray specs}
	numspr                                    : byte; {number of sprays specified in file}
	sprayspecs                                : array[1..30,1..4] of single;{array of spray specs from file}

      {Option 3}
	SprayRelTffb : boolean; {Trigger sprays based on tffb and regular intervals}
	SprayDDRelTffb:real;
	SprayInterval:byte;

	costirr,costfert,costspray,costphero : single;
	totspraycost : single;
	pricecot : single;
	StartDateExcel : single; {Excel date for first date to worksheet file}
{PBW}
	pher                                      : boolean; {use pheromones for PBW}
	npheros                                   : byte; {number of pheromone applications}
	pbw    		: boolean;
	basepbw,tddpbw,tddaDiapEmerge,tddem,ddem		:single;
	DelEgg,DelLar,DelPup,Deladl,ddapbw	:single;
	kadl,kpbw,kbolo,ilast			:word;
	DelkAdltPbw				:single;
	DelPrQr,DelPrQh,DelPrQs,DelPhQr,DelPhQh,DelPhQs,DelPsQr,DelPsQh,DelPsQs:SINGLE100;

	PbwSexRatio				:single;
	PBWemergeTime					:single; {emergence time from diapause}
//	JdayStartPbwSeason:integer;
	smaxy,salpha,sbeta,bmaxy,balpha,bbeta,smaxn,bmaxn,sysn,bybn:single;
	rrmult,romult,ormult,ssmult:single;
	vsusb,vsuso,vecon,v1,v2,pref,frdp:SINGLE100;
	frDiapToday:single;
	eggsPrQr,eggsPrQh,eggsPrQs,
		eggsPhQr,eggsPhQh,eggsPhQs,
		eggsPsQr,eggsPsQh,eggsPsQs		:SINGLE100;
	PbwInFruitPrQr,PbwInFruitPrQh,PbwInFruitPrQs,
		PbwInFruitPhQr,PbwInFruitPhQh,PbwInFruitPhQs,
		PbwInFruitPsQr,PbwInFruitPsQh,PbwInFruitPsQs	:SINGLE100100;
	spupPrQr,spupPrQh,spupPrQs,
		spupPhQr,spupPhQh,spupPhQs,
		spupPsQr,spupPsQh,spupPsQs		:SINGLE100;
	bpupPrQr,bpupPrQh,bpupPrQs,
		bpupPhQr,bpupPhQh,bpupPhQs,
		bpupPsQr,bpupPsQh,bpupPsQs		:SINGLE100;
	dpupsPrQr,dpupsPrQh,dpupsPrQs,
		dpupsPhQr,dpupsPhQh,dpupsPhQs,
		dpupsPsQr,dpupsPsQh,dpupsPsQs		:SINGLE100; 
	sadltPrQr,sadltPrQh,sadltPrQs,
		sadltPhQr,sadltPhQh,sadltPhQs,
		sadltPsQr,sadltPsQh,sadltPsQs		:SINGLE100;
	badltPrQr,badltPrQh,badltPrQs,
		badltPhQr,badltPhQh,badltPhQs,
		badltPsQr,badltPsQh,badltPsQs		:SINGLE100;
	badlts,badlth,badltr:SINGLE100;

	diadlts:SINGLE100;
	diadltsPrQr,diadltsPrQh,diadltsPrQs,
		diadltsPhQr,diadltsPhQh,diadltsPhQs,
		diadltsPsQr,diadltsPsQh,diadltsPsQs		:SINGLE100;

	pbweggs,pbwspups,pbwImmatures,pbwLarvae,pbwLarvinBolls,pbwprepup,pbwpupae	:single;
	pbwAdfromBolls,pbwAdults:single;
	PbwEggsPrQr,PbwEggsPrQh,PbwEggsPrQs,
		PbwEggsPhQr,PbwEggsPhQh,PbwEggsPhQs,
		PbwEggsPsQr,PbwEggsPsQh,PbwEggsPsQs			:single;
	PbwImmaturesPrQr,PbwImmaturesPrQh,PbwImmaturesPrQs,
		PbwImmaturesPhQr,PbwImmaturesPhQh,PbwImmaturesPhQs,
		PbwImmaturesPsQr,PbwImmaturesPsQh,PbwImmaturesPsQs	:single;
	PbwPupaePrQr,PbwPupaePrQh,PbwPupaePrQs,
		PbwPupaePhQr,PbwPupaePhQh,PbwPupaePhQs,
		PbwPupaePsQr,PbwPupaePsQh,PbwPupaePsQs			:single;
	PbwAdultsPrQr,PbwAdultsPrQh,PbwAdultsPrQs,
		PbwAdultsPhQr,PbwAdultsPhQh,PbwAdultsPhQs,
		PbwAdultsPsQr,PbwAdultsPsQh,PbwAdultsPsQs		:single;

	TotPbwDiapausers,TotPrevSeasonDiapausers			:single;
	PbwDiapNotchanged:boolean;

	PBWdiapEmergers					:SINGLE100;
	BTResistP,BTResistQ,BTResistOrigP,BTResistOrigQ:single; { Frequency of BT resistance gene P & Q}
	BtFreqOldP,BtFreqOldQ, evolution		:single;
	BtEvolution	:boolean;

	{ Btlx arrays that give lx = f(fruit age,genotype,Bt variety}
	BtlxPrQr,BtlxPrQh,BtlxPrQs,
		BtlxPhQr,BtlxPhQh,BtlxPhQs,
		BtlxPsQr,BtlxPsQh,BtlxPsQs		:SINGLE100;

	TotvinPrQr,TotvinPrQh,TotvinPrQs,
		TotvinPhQr,TotvinPhQh,TotvinPhQs,
		TotvinPsQr,TotvinPsQh,TotvinPsQs	:single{50};
	outInOldFruit:single; {v4out}

	voutsPrQr,voutsPrQh,voutsPrQs,
	voutsPhQr,voutsPhQh,voutsPhQs,
	voutsPsQr,voutsPsQh,voutsPsQs,
	voutbPrQr,voutbPrQh,voutbPrQs,
	voutbPhQr,voutbPhQh,voutbPhQs,
	voutbPsQr,voutbPsQh,voutbPsQs			:single;

	diapx:single;
	
	pbwlarvpboll:single;
	TotPBWLarvFromSquares,TotPBWLarvFromBolls	:single;
	phmax,ptsrc0,ddpher,phedd,phint			:single;
	iph2:word; {last day from season start for pherom.}
	npher,nphappspec				:word;
	PbwColdLx:single;
	ddalx,ddblx,ddblxSave:single;
	rinfpp,rinfout,rinfin,phstop			:single;
	pbwph,phcont,FirstPherCall,PherToday:boolean;
	PBWsprayscalar:single;
	PBWRefugeEffect:single;
	solar90,rain90,relhum90,winds90 		: array[1..90] of single;
	tempmins,tempmax                		: array[1..90] of single;
	Longitude,LatitudeDegrees,LatitudeRadians,daylng,dlprev			:single;
	EmergedToday					:single;
	SumDiapsEmerged:single;
{misc PBW things*****}
	fnutrifile:text;
	test:boolean;
	Log10PBWlarv:single;
	LarvPerBoll:single;


{Boll weevil}
	bwvl:boolean;
	BwvlUseInitialImrt:boolean;

	BWatkdSquares,BWatkdBolls:single;
	bwmult:single;  kbw:integer;
	bwbase:single; {dd threshold}
	ddabw,tddabw:single; {daily and cumulative dd for bw}
	delbw:single; {max dd age for bw}
	lboll,smboll,ageatks,ageatkb:single;
	bwimrt,durim,bwbakim,bwspmx,bollx1,bollx2:single;       
	sqlx,BWOvipRate:single;{BWOvipRate is the ovip. rate/fem}
	Log10BwvlLarv:single;
	sq,SumSqrShed : single;
	bwsd,BwDiaplx,TotalBWDiapausers:single;
	{ window vectors for bwvl life stages}
	vbwegg,vbwlarv,vbwpup,vbwae,vbwad,vbwnonad,vbwtotad:SINGLE100;
	{ window vectors for cotton categories relevant to bwvl}
	vsqdam,voldsq,vybldam,vbldam:SINGLE100;
	BwvlInFruitr:SINGLE100100;
	BWinSquares,BWinBolls:SINGLE100;
	bwegg,bwlarv,bwpup,bwae,bwadlts:single; {number of eggs, larv, etc.}
	sqavl,bwdsq,bwdsmb,bwdlgb,BWpcntDamSquares:single;
	prsmall,prmed,prbig : single; {pref. for small, medium, large bolls.}
	{Pheromones}
	Grandlure:boolean;
	LureIntervalDays:integer; {Days between applications}
	LureEfficacy:single;
	LureStartday:integer; {days > planting for 1st application}
	LureStopday:integer;  {days <> harvest for last application}
	LureAlpha:single;
	LureDayCount:integer; {Running count since last appl,}
	tffb200day:single; {-1 until tffb+200, after that it holds the date of tffb+200}
	Lureff,Lurelx:single;
	NaturalPheromone:single;
	cumdsq                                    : single; {cumulative bw damaged squares}
	cumdbolls                                 : single; {cumulative bw damaged bolls}
	BwLarvinFruit                    : single; {bw larvae in all fruit}
	BwimmTot:real; {total immigrants due to grandlure attraction}
	BwRemainder:real;
	BwvlYieldParameter:single;
	fbinf        : single;

{white fly}
	numwf,wgtwf,wfresv :single100;
	lxage,lxsize : boolean; {p1 and p2 mort based on age or size}
	whitefly,firstWF,goWF,finWF,WFimmig                             : boolean;
	baseWF,betaWF,d1WF,nm1WF,tWFdays                                : single;
	reservesWF,ddaWF,tddWF,dwimm,ovawgt                             : single;
	frexcr,sdtotWF,dmtotWF,sdgrow,rsvplr                    : single;
	immWF,wgtimmWF,adultsWF,ovanumWF,preovnWF               : single;
	larvnWF,pupaWF,totWF,dmWF,remWF,bWF,adl2nWF             : single;
	prepupaWF                                                                               : single;
	Larv1WFnum,Larv2WFnum,Larv3WFnum,larv1w,larv2w,larv3w       : single;
{average sizes}
	sizelarv1n,sizelarv2n,sizelarv3n,sizepreovWF    : single;
	philarv1,philarv2,philarv3,phipreov,phiadlt2    : single;

	lxWF1,lxWF2,lxWF3,lxWF4,lxWF5,lxWF6,rnsdlx              : single;
	dmgrow,totdm,dmresWF,delkWF                                             : single;
	dwres,fecq,rmortWF,WFsprayscalar,WFlxspray      : single;
	daysWF,kWF,ndelayWF,nextWF                                              : integer;

	cumlWF,cumlp1,cumlp2,cumlp3:single;
	OvaNumWFSum,LarvnWFSum,PupaWfSum,AdultsWFSum :real;
	P1Num1Sum,P2Num1Sum,P3Num1Sum : real;

{defoliator (beet army worm and cabbage looper types)}
	vBawEggPrQr,vBawLarv1PrQr,vBawLarv2PrQr,vBawLarv3PrQr,vBawLarv4PrQr:SINGLE100;
	vBawPupaPrQr,vBawPrePrQr,vBawAdltPrQr,vBawLarvsPrQr : SINGLE100;
	vBawEggPrQh,vBawLarv1PrQh,vBawLarv2PrQh,vBawLarv3PrQh,vBawLarv4PrQh:SINGLE100;
	vBawPupaPrQh,vBawPrePrQh,vBawAdltPrQh,vBawLarvsPrQh : SINGLE100;
	vBawEggPrQs,vBawLarv1PrQs,vBawLarv2PrQs,vBawLarv3PrQs,vBawLarv4PrQs:SINGLE100;
	vBawPupaPrQs,vBawPrePrQs,vBawAdltPrQs,vBawLarvsPrQs : SINGLE100;
	vBawEggPhQr,vBawLarv1PhQr,vBawLarv2PhQr,vBawLarv3PhQr,vBawLarv4PhQr:SINGLE100;
	vBawPupaPhQr,vBawPrePhQr,vBawAdltPhQr,vBawLarvsPhQr : SINGLE100;
	vBawEggPsQr,vBawLarv1PsQr,vBawLarv2PsQr,vBawLarv3PsQr,vBawLarv4PsQr:SINGLE100;
	vBawPupaPsQr,vBawPrePsQr,vBawAdltPsQr,vBawLarvsPsQr : SINGLE100;
	vBawEggPhQh,vBawLarv1PhQh,vBawLarv2PhQh,vBawLarv3PhQh,vBawLarv4PhQh:SINGLE100;
	vBawPupaPhQh,vBawPrePhQh,vBawAdltPhQh,vBawLarvsPhQh : SINGLE100;
	vBawEggPhQs,vBawLarv1PhQs,vBawLarv2PhQs,vBawLarv3PhQs,vBawLarv4PhQs:SINGLE100;
	vBawPupaPhQs,vBawPrePhQs,vBawAdltPhQs,vBawLarvsPhQs : SINGLE100;
	vBawEggPsQh,vBawLarv1PsQh,vBawLarv2PsQh,vBawLarv3PsQh,vBawLarv4PsQh:SINGLE100;
	vBawPupaPsQh,vBawPrePsQh,vBawAdltPsQh,vBawLarvsPsQh : SINGLE100;
	vBawEggPsQs,vBawLarv1PsQs,vBawLarv2PsQs,vBawLarv3PsQs,vBawLarv4PsQs:SINGLE100;
	vBawPupaPsQs,vBawPrePsQs,vBawAdltPsQs,vBawLarvsPsQs : SINGLE100;


	BawDiapdate:real;
	BawDiapJdayStart:integer;
	BawDiapPrQr,BawDiapPrQh,BawDiapPrQs,BawDiapPhQr,BawDiapPsQr,BawDiapPhQh,BawDiapPhQs,BawDiapPsQh,BawDiapPsQs:real;

	// Cumulatives for GIS and Summary.
	BawEggSum,BawLarvSmallSum,BawLarvBigSum,BawPupSum,BawAdPreSum,BawDiapsSum:real;

	cumlBawPrQr,cumlBawPrQh,cumlBawPrQs,cumlBawPhQr,cumlBawPsQr,cumlBawPhQh,cumlBawPhQs,cumlBawPsQh,cumlBawPsQs:real;
	cumlBawWgtPrQr,cumlBawWgtPrQh,cumlBawWgtPrQs,cumlBawWgtPhQr,cumlBawWgtPsQr,cumlBawWgtPhQh,cumlBawWgtPhQs,cumlBawWgtPsQh,cumlBawWgtPsQs:real;

	ageBawR:array[1..8]of single;
	ageBawPrQr,ageBawPrQh,ageBawPrQs,ageBawPhQr,ageBawPsQr,ageBawPhQh,ageBawPhQs,ageBawPsQh,ageBawPsQs:array[1..8] of single;
	delBawPrQr,delBawPrQh,delBawPrQs,delBawPhQr,delBawPsQr,delBawPhQh,delBawPhQs,delBawPsQh,delBawPsQs:single;
	delkBawPrQr,delkBawPrQh,delkBawPrQs,delkBawPhQr,delkBawPsQr,delkBawPhQh,delkBawPhQs,delkBawPsQh,delkBawPsQs:single;

	BawLxBtTotal:real;
	BawDmgrow,dmresBAW,dmrespBAW : single;

	kBAW : integer;
	BawB,BawPreferredleafmass:single;

	BawAlpha,BawBeta:single;
	BAWovipa:single; {multiplier for baw ovip function}
	BawInRun: boolean; {using BAW?}
	goBAW: boolean; {has BAW started?}
	BawUseInitialImrt:boolean;
	BawDays : integer;
	BawPrefLeafAge:byte;
	BawImrt : single;
	BawD1 : single; {start date}
	BawNumsPrQr,BawNumsPrQh,BawNumsPrQs,BawNumsPhQr,BawNumsPsQr,BawNumsPhQh,BawNumsPhQs,BawNumsPsQh,BawNumsPsQs:SINGLE100;
	BawWgtsPrQr,BawWgtsPrQh,BawWgtsPrQs,BawWgtsPhQr,BawWgtsPsQr,BawWgtsPhQh,BawWgtsPhQs,BawWgtsPsQh,BawWgtsPsQs:SINGLE100;

	BawPref : array[1..6] of single;

	BawEggPrQr,BawEggPrQh,BawEggPrQs,BawEggPhQr,BawEggPsQr,BawEggPhQh,BawEggPhQs,BawEggPsQh,BawEggPsQs:single;
	BawLarv1PrQr,BawLarv1PrQh,BawLarv1PrQs,BawLarv1PhQr,BawLarv1PsQr,BawLarv1PhQh,BawLarv1PhQs,BawLarv1PsQh,BawLarv1PsQs:single;
	BawLarv2PrQr,BawLarv2PrQh,BawLarv2PrQs,BawLarv2PhQr,BawLarv2PsQr,BawLarv2PhQh,BawLarv2PhQs,BawLarv2PsQh,BawLarv2PsQs:single;
	BawLarv3PrQr,BawLarv3PrQh,BawLarv3PrQs,BawLarv3PhQr,BawLarv3PsQr,BawLarv3PhQh,BawLarv3PhQs,BawLarv3PsQh,BawLarv3PsQs:single;
	BawLarv4PrQr,BawLarv4PrQh,BawLarv4PrQs,BawLarv4PhQr,BawLarv4PsQr,BawLarv4PhQh,BawLarv4PhQs,BawLarv4PsQh,BawLarv4PsQs:single;
	BawLarPrQr,BawLarPrQh,BawLarPrQs,BawLarPhQr,BawLarPsQr,BawLarPhQh,BawLarPhQs,BawLarPsQh,BawLarPsQs:single;
	BawPupPrQr,BawPupPrQh,BawPupPrQs,BawPupPhQr,BawPupPsQr,BawPupPhQh,BawPupPhQs,BawPupPsQh,BawPupPsQs:single;
	BawPrePrQr,BawPrePrQh,BawPrePrQs,BawPrePhQr,BawPrePsQr,BawPrePhQh,BawPrePhQs,BawPrePsQh,BawPrePsQs:single;
	BawAdltPrQr,BawAdltPrQh,BawAdltPrQs,BawAdltPhQr,BawAdltPsQr,BawAdltPhQh,BawAdltPhQs,BawAdltPsQh,BawAdltPsQs:single;

	BawEggtot,BawLartot,BawPuptot,BawPretot,BawAdlttot : single;
	BawLarsmall,BawLarbig:single;
	BawLarvWgt1PrQr,BawLarvWgt1PrQh,BawLarvWgt1PrQs,BawLarvWgt1PhQr,BawLarvWgt1PsQr,BawLarvWgt1PhQh,BawLarvWgt1PhQs,BawLarvWgt1PsQh,BawLarvWgt1PsQs:single;
	BawLarvWgt2PrQr,BawLarvWgt2PrQh,BawLarvWgt2PrQs,BawLarvWgt2PhQr,BawLarvWgt2PsQr,BawLarvWgt2PhQh,BawLarvWgt2PhQs,BawLarvWgt2PsQh,BawLarvWgt2PsQs:single;
	BawLarvWgt3PrQr,BawLarvWgt3PrQh,BawLarvWgt3PrQs,BawLarvWgt3PhQr,BawLarvWgt3PsQr,BawLarvWgt3PhQh,BawLarvWgt3PhQs,BawLarvWgt3PsQh,BawLarvWgt3PsQs:single;
	BawLarvWgt4PrQr,BawLarvWgt4PrQh,BawLarvWgt4PrQs,BawLarvWgt4PhQr,BawLarvWgt4PsQr,BawLarvWgt4PhQh,BawLarvWgt4PhQs,BawLarvWgt4PsQh,BawLarvWgt4PsQs:single;

	BawEggwPrQr,BawEggwPrQh,BawEggwPrQs,BawEggwPhQr,BawEggwPsQr,BawEggwPhQh,BawEggwPhQs,BawEggwPsQh,BawEggwPsQs:single;
	BawLarwPrQr,BawLarwPrQh,BawLarwPrQs,BawLarwPhQr,BawLarwPsQr,BawLarwPhQh,BawLarwPhQs,BawLarwPsQh,BawLarwPsQs:single;
	BawPupwPrQr,BawPupwPrQh,BawPupwPrQs,BawPupwPhQr,BawPupwPsQr,BawPupwPhQh,BawPupwPhQs,BawPupwPsQh,BawPupwPsQs:single;
	BawPrwPrQr,BawPrwPrQh,BawPrwPrQs,BawPrwPhQr,BawPrwPsQr,BawPrwPhQh,BawPrwPhQs,BawPrwPsQh,BawPrwPsQs:single;
	BawPrewPrQr,BawPrewPrQh,BawPrewPrQs,BawPrewPhQr,BawPrewPsQr,BawPrewPhQh,BawPrewPhQs,BawPrewPsQh,BawPrewPsQs:single;
	BawAdwPrQr,BawAdwPrQh,BawAdwPrQs,BawAdwPhQr,BawAdwPsQr,BawAdwPhQh,BawAdwPhQs,BawAdwPsQh,BawAdwPsQs:single;

	BawParasitized:single;
	BawToteggs :single;
	BawBase                 : single;
	PBAW,QBAW,BawRefugeEffect :single;{Initial frequency of Bt resistant gene & refuge effects}

	BawDd,tBawDd,FromBawPeakDd: single;
	BawSd,BawDmtot,BawFood : single;
	BawReserve : single;
	BawTotcons,cumlBawTotcons,BawSpmx : single;

	totBawGrow:single;
	BawEggdays,BawL1days,BawL2days,BawL3days,BawL4days,
		BawPupadays,BawAdltdays:single;
	lxBAW1,lxBAW2,lxBAW3,lxBAW4,lxBAW5,lxBAW6               : single;
	startBAW:boolean;
	L10BawLarv:single;

{defoliator (Fall armyworm)}
	vFAWeggPrQr,vFAWlarv1PrQr,vFAWlarv2PrQr,vFAWlarv3PrQr,vFAWlarv4PrQr:SINGLE100;
	vFAWpupaPrQr,vFAWprePrQr,vFAWadltPrQr,vFAWlarvsPrQr : SINGLE100;
	vFAWeggPrQh,vFAWlarv1PrQh,vFAWlarv2PrQh,vFAWlarv3PrQh,vFAWlarv4PrQh:SINGLE100;
	vFAWpupaPrQh,vFAWprePrQh,vFAWadltPrQh,vFAWlarvsPrQh : SINGLE100;
	vFAWeggPrQs,vFAWlarv1PrQs,vFAWlarv2PrQs,vFAWlarv3PrQs,vFAWlarv4PrQs:SINGLE100;
	vFAWpupaPrQs,vFAWprePrQs,vFAWadltPrQs,vFAWlarvsPrQs : SINGLE100;
	vFAWeggPhQr,vFAWlarv1PhQr,vFAWlarv2PhQr,vFAWlarv3PhQr,vFAWlarv4PhQr:SINGLE100;
	vFAWpupaPhQr,vFAWprePhQr,vFAWadltPhQr,vFAWlarvsPhQr : SINGLE100;
	vFAWeggPsQr,vFAWlarv1PsQr,vFAWlarv2PsQr,vFAWlarv3PsQr,vFAWlarv4PsQr:SINGLE100;
	vFAWpupaPsQr,vFAWprePsQr,vFAWadltPsQr,vFAWlarvsPsQr : SINGLE100;
	vFAWeggPhQh,vFAWlarv1PhQh,vFAWlarv2PhQh,vFAWlarv3PhQh,vFAWlarv4PhQh:SINGLE100;
	vFAWpupaPhQh,vFAWprePhQh,vFAWadltPhQh,vFAWlarvsPhQh : SINGLE100;
	vFAWeggPhQs,vFAWlarv1PhQs,vFAWlarv2PhQs,vFAWlarv3PhQs,vFAWlarv4PhQs:SINGLE100;
	vFAWpupaPhQs,vFAWprePhQs,vFAWadltPhQs,vFAWlarvsPhQs : SINGLE100;
	vFAWeggPsQh,vFAWlarv1PsQh,vFAWlarv2PsQh,vFAWlarv3PsQh,vFAWlarv4PsQh:SINGLE100;
	vFAWpupaPsQh,vFAWprePsQh,vFAWadltPsQh,vFAWlarvsPsQh : SINGLE100;
	vFAWeggPsQs,vFAWlarv1PsQs,vFAWlarv2PsQs,vFAWlarv3PsQs,vFAWlarv4PsQs:SINGLE100;
	vFAWpupaPsQs,vFAWprePsQs,vFAWadltPsQs,vFAWlarvsPsQs : SINGLE100;


	FAWdiapdate:real;
	FawDiapJdayStart:integer;
	FAWDiapPrQr,FAWDiapPrQh,FAWDiapPrQs,FAWDiapPhQr,FAWDiapPsQr,FAWDiapPhQh,FAWDiapPhQs,FAWDiapPsQh,FAWDiapPsQs:real;

	cumlFAWPrQr,cumlFAWPrQh,cumlFAWPrQs,cumlFAWPhQr,cumlFAWPsQr,cumlFAWPhQh,cumlFAWPhQs,cumlFAWPsQh,cumlFAWPsQs:real;
	cumlFAWWgtPrQr,cumlFAWWgtPrQh,cumlFAWWgtPrQs,cumlFAWWgtPhQr,cumlFAWWgtPsQr,cumlFAWWgtPhQh,cumlFAWWgtPhQs,cumlFAWWgtPsQh,cumlFAWWgtPsQs:real;

	ageFAWr:array[1..8]of single;
	ageFAWPrQr,ageFAWPrQh,ageFAWPrQs,ageFAWPhQr,ageFAWPsQr,ageFAWPhQh,ageFAWPhQs,ageFAWPsQh,ageFAWPsQs:array[1..8] of single;
	delFAWPrQr,delFAWPrQh,delFAWPrQs,delFAWPhQr,delFAWPsQr,delFAWPhQh,delFAWPhQs,delFAWPsQh,delFAWPsQs:single;
	delkFAWPrQr,delkFAWPrQh,delkFAWPrQs,delkFAWPhQr,delkFAWPsQr,delkFAWPhQh,delkFAWPhQs,delkFAWPsQh,delkFAWPsQs:single;

	FAWLxBtTotal:real;
	FAWdmgrow,dmresFAW,dmrespFAW : single;

	kFAW : integer;
	Fawb,FawPreferredleafmass:single;

	FAWalpha,FAWbeta:single;
	FAWovipa:single; {multiplier for baw ovip function}
	FAWinRun: boolean; {using FAW?}
	goFAW: boolean; {has FAWoliator started?}
	FawUseInitialImrt:boolean;
	FAWdays : integer;
	FAWPrefLeafAge:byte;
	FAWimrt: single;
	FAWNumsPrQr,FAWNumsPrQh,FAWNumsPrQs,FAWNumsPhQr,FAWNumsPsQr,FAWNumsPhQh,FAWNumsPhQs,FAWNumsPsQh,FAWNumsPsQs:SINGLE100;
	FAWWgtsPrQr,FAWWgtsPrQh,FAWWgtsPrQs,FAWWgtsPhQr,FAWWgtsPsQr,FAWWgtsPhQh,FAWWgtsPhQs,FAWWgtsPsQh,FAWWgtsPsQs:SINGLE100;

	FAWpref : array[1..6] of single;

	FAWEggPrQr,FAWEggPrQh,FAWEggPrQs,FAWEggPhQr,FAWEggPsQr,FAWEggPhQh,FAWEggPhQs,FAWEggPsQh,FAWEggPsQs:single;
	FAWLarv1PrQr,FAWLarv1PrQh,FAWLarv1PrQs,FAWLarv1PhQr,FAWLarv1PsQr,FAWLarv1PhQh,FAWLarv1PhQs,FAWLarv1PsQh,FAWLarv1PsQs:single;
	FAWLarv2PrQr,FAWLarv2PrQh,FAWLarv2PrQs,FAWLarv2PhQr,FAWLarv2PsQr,FAWLarv2PhQh,FAWLarv2PhQs,FAWLarv2PsQh,FAWLarv2PsQs:single;
	FAWLarv3PrQr,FAWLarv3PrQh,FAWLarv3PrQs,FAWLarv3PhQr,FAWLarv3PsQr,FAWLarv3PhQh,FAWLarv3PhQs,FAWLarv3PsQh,FAWLarv3PsQs:single;
	FAWLarv4PrQr,FAWLarv4PrQh,FAWLarv4PrQs,FAWLarv4PhQr,FAWLarv4PsQr,FAWLarv4PhQh,FAWLarv4PhQs,FAWLarv4PsQh,FAWLarv4PsQs:single;
	FAWLarPrQr,FAWLarPrQh,FAWLarPrQs,FAWLarPhQr,FAWLarPsQr,FAWLarPhQh,FAWLarPhQs,FAWLarPsQh,FAWLarPsQs:single;
	FAWPupPrQr,FAWPupPrQh,FAWPupPrQs,FAWPupPhQr,FAWPupPsQr,FAWPupPhQh,FAWPupPhQs,FAWPupPsQh,FAWPupPsQs:single;
	FAWPrePrQr,FAWPrePrQh,FAWPrePrQs,FAWPrePhQr,FAWPrePsQr,FAWPrePhQh,FAWPrePhQs,FAWPrePsQh,FAWPrePsQs:single;
	FAWAdltPrQr,FAWAdltPrQh,FAWAdltPrQs,FAWAdltPhQr,FAWAdltPsQr,FAWAdltPhQh,FAWAdltPhQs,FAWAdltPsQh,FAWAdltPsQs:single;

	FAWeggtot,FAWlartot,FAWpuptot,FAWpretot,FAWadlttot : single;
	FAWlarsmall,FAWlarbig:single;
	// Cumulatives for GIS and Summary.
	FaweggSum,FawLarvSmallSum,FawLarvBigSum,FawpupSum,FawAdPreSum,FawDiapsSum:real;

	FAWLarvWgt1PrQr,FAWLarvWgt1PrQh,FAWLarvWgt1PrQs,FAWLarvWgt1PhQr,FAWLarvWgt1PsQr,FAWLarvWgt1PhQh,FAWLarvWgt1PhQs,FAWLarvWgt1PsQh,FAWLarvWgt1PsQs:single;
	FAWLarvWgt2PrQr,FAWLarvWgt2PrQh,FAWLarvWgt2PrQs,FAWLarvWgt2PhQr,FAWLarvWgt2PsQr,FAWLarvWgt2PhQh,FAWLarvWgt2PhQs,FAWLarvWgt2PsQh,FAWLarvWgt2PsQs:single;
	FAWLarvWgt3PrQr,FAWLarvWgt3PrQh,FAWLarvWgt3PrQs,FAWLarvWgt3PhQr,FAWLarvWgt3PsQr,FAWLarvWgt3PhQh,FAWLarvWgt3PhQs,FAWLarvWgt3PsQh,FAWLarvWgt3PsQs:single;
	FAWLarvWgt4PrQr,FAWLarvWgt4PrQh,FAWLarvWgt4PrQs,FAWLarvWgt4PhQr,FAWLarvWgt4PsQr,FAWLarvWgt4PhQh,FAWLarvWgt4PhQs,FAWLarvWgt4PsQh,FAWLarvWgt4PsQs:single;

	FAWEggwPrQr,FAWEggwPrQh,FAWEggwPrQs,FAWEggwPhQr,FAWEggwPsQr,FAWEggwPhQh,FAWEggwPhQs,FAWEggwPsQh,FAWEggwPsQs:single;
	FAWLarwPrQr,FAWLarwPrQh,FAWLarwPrQs,FAWLarwPhQr,FAWLarwPsQr,FAWLarwPhQh,FAWLarwPhQs,FAWLarwPsQh,FAWLarwPsQs:single;
	FAWPupwPrQr,FAWPupwPrQh,FAWPupwPrQs,FAWPupwPhQr,FAWPupwPsQr,FAWPupwPhQh,FAWPupwPhQs,FAWPupwPsQh,FAWPupwPsQs:single;
	FAWPrwPrQr,FAWPrwPrQh,FAWPrwPrQs,FAWPrwPhQr,FAWPrwPsQr,FAWPrwPhQh,FAWPrwPhQs,FAWPrwPsQh,FAWPrwPsQs:single;
	FAWPrewPrQr,FAWPrewPrQh,FAWPrewPrQs,FAWPrewPhQr,FAWPrewPsQr,FAWPrewPhQh,FAWPrewPhQs,FAWPrewPsQh,FAWPrewPsQs:single;
	FAWAdwPrQr,FAWAdwPrQh,FAWAdwPrQs,FAWAdwPhQr,FAWAdwPsQr,FAWAdwPhQh,FAWAdwPhQs,FAWAdwPsQh,FAWAdwPsQs:single;

	FAWparasitized:single;
	FAWtoteggs :single;
	FAWbase                 : single;
	PFAW,QFAW,FAWRefugeEffect :single;{Initial frequency of Bt resistant gene & refuge effects}

	FAWdd,tFAWdd,FromFAWPeakDd: single;
	FAWsd,FAWdmtot,FAWfood : single;
	FAWreserve: single;
	FAWTotcons,cumlFAWTotcons,FAWspmx : single;

	totFAWgrow:single;
	FAWeggdays,FAWl1days,FAWl2days,FAWl3days,FAWl4days,
		FAWpupadays,FAWadltdays:single;
	lxFAW1,lxFAW2,lxFAW3,lxFAW4,lxFAW5,lxFAW6               : single;
	startFAW:boolean;
	L10FAWLarv:single;

{TNI cabbage looper}
	vTNIeggPrQr,vTNIlarv1PrQr,vTNIlarv2PrQr,vTNIlarv3PrQr,vTNIlarv4PrQr:SINGLE100;
	vTNIpupaPrQr,vTNIprePrQr,vTNIadltPrQr,vTNIlarvsPrQr : SINGLE100;
	vTNIeggPrQh,vTNIlarv1PrQh,vTNIlarv2PrQh,vTNIlarv3PrQh,vTNIlarv4PrQh:SINGLE100;
	vTNIpupaPrQh,vTNIprePrQh,vTNIadltPrQh,vTNIlarvsPrQh : SINGLE100;
	vTNIeggPrQs,vTNIlarv1PrQs,vTNIlarv2PrQs,vTNIlarv3PrQs,vTNIlarv4PrQs:SINGLE100;
	vTNIpupaPrQs,vTNIprePrQs,vTNIadltPrQs,vTNIlarvsPrQs : SINGLE100;
	vTNIeggPhQr,vTNIlarv1PhQr,vTNIlarv2PhQr,vTNIlarv3PhQr,vTNIlarv4PhQr:SINGLE100;
	vTNIpupaPhQr,vTNIprePhQr,vTNIadltPhQr,vTNIlarvsPhQr : SINGLE100;
	vTNIeggPsQr,vTNIlarv1PsQr,vTNIlarv2PsQr,vTNIlarv3PsQr,vTNIlarv4PsQr:SINGLE100;
	vTNIpupaPsQr,vTNIprePsQr,vTNIadltPsQr,vTNIlarvsPsQr : SINGLE100;
	vTNIeggPhQh,vTNIlarv1PhQh,vTNIlarv2PhQh,vTNIlarv3PhQh,vTNIlarv4PhQh:SINGLE100;
	vTNIpupaPhQh,vTNIprePhQh,vTNIadltPhQh,vTNIlarvsPhQh : SINGLE100;
	vTNIeggPhQs,vTNIlarv1PhQs,vTNIlarv2PhQs,vTNIlarv3PhQs,vTNIlarv4PhQs:SINGLE100;
	vTNIpupaPhQs,vTNIprePhQs,vTNIadltPhQs,vTNIlarvsPhQs : SINGLE100;
	vTNIeggPsQh,vTNIlarv1PsQh,vTNIlarv2PsQh,vTNIlarv3PsQh,vTNIlarv4PsQh:SINGLE100;
	vTNIpupaPsQh,vTNIprePsQh,vTNIadltPsQh,vTNIlarvsPsQh : SINGLE100;
	vTNIeggPsQs,vTNIlarv1PsQs,vTNIlarv2PsQs,vTNIlarv3PsQs,vTNIlarv4PsQs:SINGLE100;
	vTNIpupaPsQs,vTNIprePsQs,vTNIadltPsQs,vTNIlarvsPsQs : SINGLE100;


	TNIdiapdate:real;
	TniDiapJdayStart:integer;
	TniDiapPrQr,TniDiapPrQh,TniDiapPrQs,TniDiapPhQr,TniDiapPsQr,TniDiapPhQh,TniDiapPhQs,TniDiapPsQh,TniDiapPsQs:real;

	cumlTNIPrQr,cumlTNIPrQh,cumlTNIPrQs,cumlTNIPhQr,cumlTNIPsQr,cumlTNIPhQh,cumlTNIPhQs,cumlTNIPsQh,cumlTNIPsQs:real;
	cumlTNIWgtPrQr,cumlTNIWgtPrQh,cumlTNIWgtPrQs,cumlTNIWgtPhQr,cumlTNIWgtPsQr,cumlTNIWgtPhQh,cumlTNIWgtPhQs,cumlTNIWgtPsQh,cumlTNIWgtPsQs:real;

	ageTNIr:array[1..8]of single;
	ageTNIPrQr,ageTNIPrQh,ageTNIPrQs,ageTNIPhQr,ageTNIPsQr,ageTNIPhQh,ageTNIPhQs,ageTNIPsQh,ageTNIPsQs:array[1..8] of single;
	delTNIPrQr,delTNIPrQh,delTNIPrQs,delTNIPhQr,delTNIPsQr,delTNIPhQh,delTNIPhQs,delTNIPsQh,delTNIPsQs:single;
	delkTNIPrQr,delkTNIPrQh,delkTNIPrQs,delkTNIPhQr,delkTNIPsQr,delkTNIPhQh,delkTNIPhQs,delkTNIPsQh,delkTNIPsQs:single;

	TNiLxBtTotal:real;
	TNIdmgrow,dmresTNI,dmrespTNI : single;

	kTNI : integer;
	Tnib,TniPreferredleafmass:single;

	TNIalpha,TNIbeta:single;
	TNIovipa:single; {multiplier for baw ovip function}
	TniInRun: boolean; {using TNI?}
	goTNI: boolean; {has TNIr started?}
	TniUseInitialImrt:boolean;
	TNIdays : integer;
	TNIPrefLeafAge:byte;
	TNIimrt: single;
	TNId1 : single; {start date}
	TNINumsPrQr,TNINumsPrQh,TNINumsPrQs,TNINumsPhQr,TNINumsPsQr,TNINumsPhQh,TNINumsPhQs,TNINumsPsQh,TNINumsPsQs:SINGLE100;
	TNIWgtsPrQr,TNIWgtsPrQh,TNIWgtsPrQs,TNIWgtsPhQr,TNIWgtsPsQr,TNIWgtsPhQh,TNIWgtsPhQs,TNIWgtsPsQh,TNIWgtsPsQs:SINGLE100;

	TNIpref : array[1..6] of single;

	TNIEggPrQr,TNIEggPrQh,TNIEggPrQs,TNIEggPhQr,TNIEggPsQr,TNIEggPhQh,TNIEggPhQs,TNIEggPsQh,TNIEggPsQs:single;
	TNILarv1PrQr,TNILarv1PrQh,TNILarv1PrQs,TNILarv1PhQr,TNILarv1PsQr,TNILarv1PhQh,TNILarv1PhQs,TNILarv1PsQh,TNILarv1PsQs:single;
	TNILarv2PrQr,TNILarv2PrQh,TNILarv2PrQs,TNILarv2PhQr,TNILarv2PsQr,TNILarv2PhQh,TNILarv2PhQs,TNILarv2PsQh,TNILarv2PsQs:single;
	TNILarv3PrQr,TNILarv3PrQh,TNILarv3PrQs,TNILarv3PhQr,TNILarv3PsQr,TNILarv3PhQh,TNILarv3PhQs,TNILarv3PsQh,TNILarv3PsQs:single;
	TNILarv4PrQr,TNILarv4PrQh,TNILarv4PrQs,TNILarv4PhQr,TNILarv4PsQr,TNILarv4PhQh,TNILarv4PhQs,TNILarv4PsQh,TNILarv4PsQs:single;
	TNILarPrQr,TNILarPrQh,TNILarPrQs,TNILarPhQr,TNILarPsQr,TNILarPhQh,TNILarPhQs,TNILarPsQh,TNILarPsQs:single;
	TNIPupPrQr,TNIPupPrQh,TNIPupPrQs,TNIPupPhQr,TNIPupPsQr,TNIPupPhQh,TNIPupPhQs,TNIPupPsQh,TNIPupPsQs:single;
	TNIPrePrQr,TNIPrePrQh,TNIPrePrQs,TNIPrePhQr,TNIPrePsQr,TNIPrePhQh,TNIPrePhQs,TNIPrePsQh,TNIPrePsQs:single;
	TNIAdltPrQr,TNIAdltPrQh,TNIAdltPrQs,TNIAdltPhQr,TNIAdltPsQr,TNIAdltPhQh,TNIAdltPhQs,TNIAdltPsQh,TNIAdltPsQs:single;

	TNIeggtot,TNIlartot,TNIpuptot,TNIpretot,TNIadlttot : single;
	TNIlarsmall,TNIlarbig:single;
	// Cumulatives for GIS and Summary.
	TnieggSum,TniLarvSmallSum,TniLarvBigSum,TnipupSum,TniAdPreSum,TniDiapsSum:real;

	TNILarvWgt1PrQr,TNILarvWgt1PrQh,TNILarvWgt1PrQs,TNILarvWgt1PhQr,TNILarvWgt1PsQr,TNILarvWgt1PhQh,TNILarvWgt1PhQs,TNILarvWgt1PsQh,TNILarvWgt1PsQs:single;
	TNILarvWgt2PrQr,TNILarvWgt2PrQh,TNILarvWgt2PrQs,TNILarvWgt2PhQr,TNILarvWgt2PsQr,TNILarvWgt2PhQh,TNILarvWgt2PhQs,TNILarvWgt2PsQh,TNILarvWgt2PsQs:single;
	TNILarvWgt3PrQr,TNILarvWgt3PrQh,TNILarvWgt3PrQs,TNILarvWgt3PhQr,TNILarvWgt3PsQr,TNILarvWgt3PhQh,TNILarvWgt3PhQs,TNILarvWgt3PsQh,TNILarvWgt3PsQs:single;
	TNILarvWgt4PrQr,TNILarvWgt4PrQh,TNILarvWgt4PrQs,TNILarvWgt4PhQr,TNILarvWgt4PsQr,TNILarvWgt4PhQh,TNILarvWgt4PhQs,TNILarvWgt4PsQh,TNILarvWgt4PsQs:single;

	TNIEggwPrQr,TNIEggwPrQh,TNIEggwPrQs,TNIEggwPhQr,TNIEggwPsQr,TNIEggwPhQh,TNIEggwPhQs,TNIEggwPsQh,TNIEggwPsQs:single;
	TNILarwPrQr,TNILarwPrQh,TNILarwPrQs,TNILarwPhQr,TNILarwPsQr,TNILarwPhQh,TNILarwPhQs,TNILarwPsQh,TNILarwPsQs:single;
	TNIPupwPrQr,TNIPupwPrQh,TNIPupwPrQs,TNIPupwPhQr,TNIPupwPsQr,TNIPupwPhQh,TNIPupwPhQs,TNIPupwPsQh,TNIPupwPsQs:single;
	TNIPrwPrQr,TNIPrwPrQh,TNIPrwPrQs,TNIPrwPhQr,TNIPrwPsQr,TNIPrwPhQh,TNIPrwPhQs,TNIPrwPsQh,TNIPrwPsQs:single;
	TNIPrewPrQr,TNIPrewPrQh,TNIPrewPrQs,TNIPrewPhQr,TNIPrewPsQr,TNIPrewPhQh,TNIPrewPhQs,TNIPrewPsQh,TNIPrewPsQs:single;
	TNIAdwPrQr,TNIAdwPrQh,TNIAdwPrQs,TNIAdwPhQr,TNIAdwPsQr,TNIAdwPhQh,TNIAdwPhQs,TNIAdwPsQh,TNIAdwPsQs:single;

	TNIparasitized:single;
	TNItoteggs :single;
	TNIbase                 : single;
	PTNI,QTNI,TNIRefugeEffect :single;{Initial frequency of Bt resistant gene & refuge effects}

	TNIdd,tTNIdd,FromTNIPeakDd: single;
	TNIsd,TNIdmtot,TNIfood : single;
	TNIreserve : single;
	TNITotcons,cumlTNITotcons,TNIspmx : single;

	totTNIgrow:single;
	TNIeggdays,TNIl1days,TNIl2days,TNIl3days,TNIl4days,
		TNIpupadays,TNIadltdays:single;
	lxTNI1,lxTNI2,lxTNI3,lxTNI4,lxTNI5,lxTNI6               : single;
	startTNI:boolean;
	L10TNILarv:single;


{white fly parasitoids p1,p2,p3}
	WFPara1 : boolean;
	p1num,p1wgt : array[1..3] of single;
	kp1,kgop1 : integer;
	p1immig : boolean;
	p1atpf,p1femad,p1malad,ovipp1,p1sr : single;
	totp1wgt,p1births : single;
	gop1,p1begin,p1fin : boolean;
	lxp1,lxp11,lxp12 : single;
	p1sd : array[1..7] of single;
	alpha1:single;
	immig1:single;

	WFPara2 : boolean;
	p2num,p2wgt : array[1..3] of single;
	kp2,kgop2 : integer;
	p2immig : boolean;
	p2atpf,p2femad,ovipp2,p2sr      :single;
	totp2wgt,p2births : single;
	gop2,p2begin,p2fin : boolean;
	lxp2,lxp21,lxp22 : single;
	p2sd : array[1..7] of single;
	alpha2:single;
	immig2:single;

	WFPara3 : boolean;
	p3num,p3wgt : array[1..3] of single;
	kp3,kgop3 : integer;
	p3immig : boolean;
	p3atpf,p3femad,ovipp3,p3sr      :single;
	totp3wgt,p3births : single;
	gop3,p3begin,p3fin : boolean;
	lxp3,lxp31,lxp32 : single;
	p3sd : array[1..7] of single;
	p1delt,p2delt,p3delt,delkp1,delkp2,delkp3 : single;
	p1b,p1BirthrateTotal,p2b,p2BirthrateTotal,p3b,p3BirthrateTotal : single;
	alpha3:single;
	immig3:single;
	sexr1,sexr2,sexr3:single;

{All Fruit pests}
	AllSpeciesAtkdfruwgt1,AllSpeciesAtkdfruwgt2,AllSpeciesAtkdfruwgt3,AllSpeciesAtkdfruwgt4:SINGLE100;
	AllSpeciesAtkdfrunum1,AllSpeciesAtkdfrunum2,AllSpeciesAtkdfrunum3,AllSpeciesAtkdfrunum4:SINGLE100;
	AllSpeciesTotWgtdResource,AllSpeciesDmTot,AllSpeciesTotFood,AllSpeciesTotMassAttacked,AllSpeciesTotNumAttacked:single;
	AllSpeciesFruWgtAtkd,AllSpeciesFruNumAtkd : array[1..7] of single;
	ImmigScalar:single; {Used for all noctuid pests.}
	Fruitmass,FruitNums : array[1..7] of single;
{BollWorm}
	MuStarBoll, MuStarBollP,MustarBollQ: array[1..5]of real;
	ageBollWormPrQr,ageBollWormPrQh,ageBollWormPrQs,ageBollWormPhQr,ageBollWormPsQr,ageBollWormPhQh,ageBollWormPhQs,ageBollWormPsQh,ageBollWormPsQs:array[1..9] of single;
	delBollWormPrQr,delBollWormPrQh,delBollWormPrQs,delBollWormPhQr,delBollWormPsQr,delBollWormPhQh,delBollWormPhQs,delBollWormPsQh,delBollWormPsQs:single;
	delPrevBollWormPrQr,delPrevBollWormPrQh,delPrevBollWormPrQs,delPrevBollWormPhQr,delPrevBollWormPsQr,delPrevBollWormPhQh,delPrevBollWormPhQs,delPrevBollWormPsQh,delPrevBollWormPsQs:single;
	BollwormBtSusceptibility:real;
	delkBollWormPrQr,delkBollWormPrQh,delkBollWormPrQs,delkBollWormPhQr,delkBollWormPsQr,delkBollWormPhQh,delkBollWormPhQs,delkBollWormPsQh,delkBollWormPsQs:single;
	kBollWorm : integer;
	vBollWormeggPrQr,vBollWormlarv1PrQr,vBollWormlarv2PrQr,vBollWormlarv3PrQr,vBollWormlarv4PrQr,vBollWormlarv5PrQr:SINGLE100;
	vBollWormpupaPrQr,vBollWormprePrQr,vBollWormadltPrQr,vBollWormlarvsPrQr : SINGLE100;
	vBollWormeggPrQh,vBollWormlarv1PrQh,vBollWormlarv2PrQh,vBollWormlarv3PrQh,vBollWormlarv4PrQh,vBollWormlarv5PrQh:SINGLE100;
	vBollWormpupaPrQh,vBollWormprePrQh,vBollWormadltPrQh,vBollWormlarvsPrQh : SINGLE100;
	vBollWormeggPrQs,vBollWormlarv1PrQs,vBollWormlarv2PrQs,vBollWormlarv3PrQs,vBollWormlarv4PrQs,vBollWormlarv5PrQs:SINGLE100;
	vBollWormpupaPrQs,vBollWormprePrQs,vBollWormadltPrQs,vBollWormlarvsPrQs : SINGLE100;
	vBollWormeggPhQr,vBollWormlarv1PhQr,vBollWormlarv2PhQr,vBollWormlarv3PhQr,vBollWormlarv4PhQr,vBollWormlarv5PhQr:SINGLE100;
	vBollWormpupaPhQr,vBollWormprePhQr,vBollWormadltPhQr,vBollWormlarvsPhQr : SINGLE100;
	vBollWormeggPsQr,vBollWormlarv1PsQr,vBollWormlarv2PsQr,vBollWormlarv3PsQr,vBollWormlarv4PsQr,vBollWormlarv5PsQr:SINGLE100;
	vBollWormpupaPsQr,vBollWormprePsQr,vBollWormadltPsQr,vBollWormlarvsPsQr : SINGLE100;
	vBollWormeggPhQh,vBollWormlarv1PhQh,vBollWormlarv2PhQh,vBollWormlarv3PhQh,vBollWormlarv4PhQh,vBollWormlarv5PhQh:SINGLE100;
	vBollWormpupaPhQh,vBollWormprePhQh,vBollWormadltPhQh,vBollWormlarvsPhQh : SINGLE100;
	vBollWormeggPhQs,vBollWormlarv1PhQs,vBollWormlarv2PhQs,vBollWormlarv3PhQs,vBollWormlarv4PhQs,vBollWormlarv5PhQs:SINGLE100;
	vBollWormpupaPhQs,vBollWormprePhQs,vBollWormadltPhQs,vBollWormlarvsPhQs : SINGLE100;
	vBollWormeggPsQh,vBollWormlarv1PsQh,vBollWormlarv2PsQh,vBollWormlarv3PsQh,vBollWormlarv4PsQh,vBollWormlarv5PsQh:SINGLE100;
	vBollWormpupaPsQh,vBollWormprePsQh,vBollWormadltPsQh,vBollWormlarvsPsQh : SINGLE100;
	vBollWormeggPsQs,vBollWormlarv1PsQs,vBollWormlarv2PsQs,vBollWormlarv3PsQs,vBollWormlarv4PsQs,vBollWormlarv5PsQs:SINGLE100;
	vBollWormpupaPsQs,vBollWormprePsQs,vBollWormadltPsQs,vBollWormlarvsPsQs : SINGLE100;

	vBollWormlarv1r,vBollWormlarv1h,vBollWormlarv1s:SINGLE100;
	vBollWormlarv2r,vBollWormlarv2h,vBollWormlarv2s:SINGLE100;
	vBollWormlarv3r,vBollWormlarv3h,vBollWormlarv3s:SINGLE100;
	vBollWormlarv4r,vBollWormlarv4h,vBollWormlarv4s:SINGLE100;
	vBollWormlarv5r,vBollWormlarv5h,vBollWormlarv5s:SINGLE100;

	cumlBollWormPrQr,cumlBollWormPrQh,cumlBollWormPrQs,cumlBollWormPhQr,cumlBollWormPsQr,cumlBollWormPhQh,cumlBollWormPhQs,cumlBollWormPsQh,cumlBollWormPsQs:real;
	cumlBollWormWgtPrQr,cumlBollWormWgtPrQh,cumlBollWormWgtPrQs,cumlBollWormWgtPhQr,cumlBollWormWgtPsQr,cumlBollWormWgtPhQh,cumlBollWormWgtPhQs,cumlBollWormWgtPsQh,cumlBollWormWgtPsQs:real;
	cumlBollWormwgtr,cumlBollWormwgth,cumlBollWormwgts:single;

	FromPeakDdBollWorm:single;

	BollWormdiapdate:real;
	BollWormDiapJdayStart:integer;
	BollWormDiapPrQr,BollWormDiapPrQh,BollWormDiapPrQs,BollWormDiapPhQr,BollWormDiapPsQr,BollWormDiapPhQh,BollWormDiapPhQs,BollWormDiapPsQh,BollWormDiapPsQs:real;

	BollWormDemand:single10;
	BollWormdmgrow,dmresBollWorm,dmrespBollWorm : single;
	TotBollWormfood:single;
	
	BollWorminRun: boolean; {using BollWorm?}
	BollWormPrefLeafAge:byte;
	BollWormimrt : single;
	BollWormd1 : single; {start date}
	BollWormUseInitialImrt:boolean;

	BollWormalpha,BollWormbeta:single;
	BollWormovipa:single; {multiplier for BollWorm ovip function}
	goBollWorm: boolean; {has BollWorm started?}
	
	BollWormNumsPrQr,BollWormNumsPrQh,BollWormNumsPrQs,BollWormNumsPhQr,BollWormNumsPsQr,BollWormNumsPhQh,BollWormNumsPhQs,BollWormNumsPsQh,BollWormNumsPsQs:SINGLE100;
	BollWormWgtsPrQr,BollWormWgtsPrQh,BollWormWgtsPrQs,BollWormWgtsPhQr,BollWormWgtsPsQr,BollWormWgtsPhQh,BollWormWgtsPhQs,BollWormWgtsPsQh,BollWormWgtsPsQs:SINGLE100;
	BollWormNumsTot:SINGLE100;

	BollWormpref : array[1..5,1..7] of single;
	BollWormEggPrQr,BollWormEggPrQh,BollWormEggPrQs,BollWormEggPhQr,BollWormEggPsQr,BollWormEggPhQh,BollWormEggPhQs,BollWormEggPsQh,BollWormEggPsQs:single;
	BollWormLarv1PrQr,BollWormLarv1PrQh,BollWormLarv1PrQs,BollWormLarv1PhQr,BollWormLarv1PsQr,BollWormLarv1PhQh,BollWormLarv1PhQs,BollWormLarv1PsQh,BollWormLarv1PsQs:single;
	BollWormLarv2PrQr,BollWormLarv2PrQh,BollWormLarv2PrQs,BollWormLarv2PhQr,BollWormLarv2PsQr,BollWormLarv2PhQh,BollWormLarv2PhQs,BollWormLarv2PsQh,BollWormLarv2PsQs:single;
	BollWormLarv3PrQr,BollWormLarv3PrQh,BollWormLarv3PrQs,BollWormLarv3PhQr,BollWormLarv3PsQr,BollWormLarv3PhQh,BollWormLarv3PhQs,BollWormLarv3PsQh,BollWormLarv3PsQs:single;
	BollWormLarv4PrQr,BollWormLarv4PrQh,BollWormLarv4PrQs,BollWormLarv4PhQr,BollWormLarv4PsQr,BollWormLarv4PhQh,BollWormLarv4PhQs,BollWormLarv4PsQh,BollWormLarv4PsQs:single;
	BollWormLarv5PrQr,BollWormLarv5PrQh,BollWormLarv5PrQs,BollWormLarv5PhQr,BollWormLarv5PsQr,BollWormLarv5PhQh,BollWormLarv5PhQs,BollWormLarv5PsQh,BollWormLarv5PsQs:single;
	BollWormLarPrQr,BollWormLarPrQh,BollWormLarPrQs,BollWormLarPhQr,BollWormLarPsQr,BollWormLarPhQh,BollWormLarPhQs,BollWormLarPsQh,BollWormLarPsQs:single;
	BollWormPupPrQr,BollWormPupPrQh,BollWormPupPrQs,BollWormPupPhQr,BollWormPupPsQr,BollWormPupPhQh,BollWormPupPhQs,BollWormPupPsQh,BollWormPupPsQs:single;
	BollWormPrePrQr,BollWormPrePrQh,BollWormPrePrQs,BollWormPrePhQr,BollWormPrePsQr,BollWormPrePhQh,BollWormPrePhQs,BollWormPrePsQh,BollWormPrePsQs:single;
	BollWormAdltPrQr,BollWormAdltPrQh,BollWormAdltPrQs,BollWormAdltPhQr,BollWormAdltPsQr,BollWormAdltPhQh,BollWormAdltPhQs,BollWormAdltPsQh,BollWormAdltPsQs:single;

	BollWormeggtot,BollWormlartot,BollWormpuptot,BollWormpretot,BollWormadlttot : single;
	BollWormlarsmall,BollWormlarbig:single;
	// Cumulatives for GIS and Summary.
	BollWormeggSum,BollWormLarvSmallSum,BollWormLarvBigSum,BollWormpupSum,BollWormAdPreSum,BollWormDiapsSum:real;

	BollWormLarvWgt1PrQr,BollWormLarvWgt1PrQh,BollWormLarvWgt1PrQs,BollWormLarvWgt1PhQr,BollWormLarvWgt1PsQr,BollWormLarvWgt1PhQh,BollWormLarvWgt1PhQs,BollWormLarvWgt1PsQh,BollWormLarvWgt1PsQs:single;
	BollWormLarvWgt2PrQr,BollWormLarvWgt2PrQh,BollWormLarvWgt2PrQs,BollWormLarvWgt2PhQr,BollWormLarvWgt2PsQr,BollWormLarvWgt2PhQh,BollWormLarvWgt2PhQs,BollWormLarvWgt2PsQh,BollWormLarvWgt2PsQs:single;
	BollWormLarvWgt3PrQr,BollWormLarvWgt3PrQh,BollWormLarvWgt3PrQs,BollWormLarvWgt3PhQr,BollWormLarvWgt3PsQr,BollWormLarvWgt3PhQh,BollWormLarvWgt3PhQs,BollWormLarvWgt3PsQh,BollWormLarvWgt3PsQs:single;
	BollWormLarvWgt4PrQr,BollWormLarvWgt4PrQh,BollWormLarvWgt4PrQs,BollWormLarvWgt4PhQr,BollWormLarvWgt4PsQr,BollWormLarvWgt4PhQh,BollWormLarvWgt4PhQs,BollWormLarvWgt4PsQh,BollWormLarvWgt4PsQs:single;
	BollWormLarvWgt5PrQr,BollWormLarvWgt5PrQh,BollWormLarvWgt5PrQs,BollWormLarvWgt5PhQr,BollWormLarvWgt5PsQr,BollWormLarvWgt5PhQh,BollWormLarvWgt5PhQs,BollWormLarvWgt5PsQh,BollWormLarvWgt5PsQs:single;

	BollWormEggwPrQr,BollWormEggwPrQh,BollWormEggwPrQs,BollWormEggwPhQr,BollWormEggwPsQr,BollWormEggwPhQh,BollWormEggwPhQs,BollWormEggwPsQh,BollWormEggwPsQs:single;
	BollWormLarwPrQr,BollWormLarwPrQh,BollWormLarwPrQs,BollWormLarwPhQr,BollWormLarwPsQr,BollWormLarwPhQh,BollWormLarwPhQs,BollWormLarwPsQh,BollWormLarwPsQs:single;
	BollWormPupwPrQr,BollWormPupwPrQh,BollWormPupwPrQs,BollWormPupwPhQr,BollWormPupwPsQr,BollWormPupwPhQh,BollWormPupwPhQs,BollWormPupwPsQh,BollWormPupwPsQs:single;
	BollWormPrwPrQr,BollWormPrwPrQh,BollWormPrwPrQs,BollWormPrwPhQr,BollWormPrwPsQr,BollWormPrwPhQh,BollWormPrwPhQs,BollWormPrwPsQh,BollWormPrwPsQs:single;
	BollWormPrewPrQr,BollWormPrewPrQh,BollWormPrewPrQs,BollWormPrewPhQr,BollWormPrewPsQr,BollWormPrewPhQh,BollWormPrewPhQs,BollWormPrewPsQh,BollWormPrewPsQs:single;
	BollWormAdwPrQr,BollWormAdwPrQh,BollWormAdwPrQs,BollWormAdwPhQr,BollWormAdwPsQr,BollWormAdwPhQh,BollWormAdwPhQs,BollWormAdwPsQh,BollWormAdwPsQs:single;


	BollwormImmigrants:real;
	BollwormBudDamage:real;

	BollWormtoteggs :single;
	BollWormbase                 : single;
	BollWormdd,tBollWormdd,FromBollWormPeakDd: single;
	PBollWorm,QBollWorm,BollWormRefugeEffect :single;{Initial frequency of Bt resistant gene & refuge effects}

	BollWormsd,BollWormdmtot,BollWormfood,BollWormTotWgtdResource : single;
	BollWormreserve : single;
	BollWormTotcons,cumlBollWormTotcons : single;
	totBollWormgrow:single;
	
	BollWormeggdays,BollWorml1days,BollWorml2days,BollWorml3days,BollWorml4days,BollWorml5days,
	BollWormpupadays,BollWormadltdays:single;

	startBollWorm:boolean;
	L10BollWormLarv:single;
	
	BollWormMusum:single;
	
	BollWormlxbtr,BollWormlxbth,BollWormlxbts:SINGLE100;
	BollWormlxbtrr,BollWormlxbtrs,BollWormlxbtsr,BollWormlxbtss:SINGLE100;
	lxBollWorm1,lxBollWorm2,lxBollWorm3,lxBollWorm4,lxBollWorm5,lxBollWorm6 : single;



{Budworm}
	MuStarBud, MuStarBudP,MustarBudQ: array[1..5]of real;
	ageBudWormPrQr,ageBudWormPrQh,ageBudWormPrQs,ageBudWormPhQr,ageBudWormPsQr,ageBudWormPhQh,ageBudWormPhQs,ageBudWormPsQh,ageBudWormPsQs:array[1..9] of single;
	delBudWormPrQr,delBudWormPrQh,delBudWormPrQs,delBudWormPhQr,delBudWormPsQr,delBudWormPhQh,delBudWormPhQs,delBudWormPsQh,delBudWormPsQs:single;
	delPrevBudWormPrQr,delPrevBudWormPrQh,delPrevBudWormPrQs,delPrevBudWormPhQr,delPrevBudWormPsQr,delPrevBudWormPhQh,delPrevBudWormPhQs,delPrevBudWormPsQh,delPrevBudWormPsQs:single;

	delkBudWormPrQr,delkBudWormPrQh,delkBudWormPrQs,delkBudWormPhQr,delkBudWormPsQr,delkBudWormPhQh,delkBudWormPhQs,delkBudWormPsQh,delkBudWormPsQs:single;
	kBudWorm : integer;
	vBudWormeggPrQr,vBudWormlarv1PrQr,vBudWormlarv2PrQr,vBudWormlarv3PrQr,vBudWormlarv4PrQr,vBudWormlarv5PrQr:SINGLE100;
	vBudWormpupaPrQr,vBudWormprePrQr,vBudWormadltPrQr,vBudWormlarvsPrQr : SINGLE100;
	vBudWormeggPrQh,vBudWormlarv1PrQh,vBudWormlarv2PrQh,vBudWormlarv3PrQh,vBudWormlarv4PrQh,vBudWormlarv5PrQh:SINGLE100;
	vBudWormpupaPrQh,vBudWormprePrQh,vBudWormadltPrQh,vBudWormlarvsPrQh : SINGLE100;
	vBudWormeggPrQs,vBudWormlarv1PrQs,vBudWormlarv2PrQs,vBudWormlarv3PrQs,vBudWormlarv4PrQs,vBudWormlarv5PrQs:SINGLE100;
	vBudWormpupaPrQs,vBudWormprePrQs,vBudWormadltPrQs,vBudWormlarvsPrQs : SINGLE100;
	vBudWormeggPhQr,vBudWormlarv1PhQr,vBudWormlarv2PhQr,vBudWormlarv3PhQr,vBudWormlarv4PhQr,vBudWormlarv5PhQr:SINGLE100;
	vBudWormpupaPhQr,vBudWormprePhQr,vBudWormadltPhQr,vBudWormlarvsPhQr : SINGLE100;
	vBudWormeggPsQr,vBudWormlarv1PsQr,vBudWormlarv2PsQr,vBudWormlarv3PsQr,vBudWormlarv4PsQr,vBudWormlarv5PsQr:SINGLE100;
	vBudWormpupaPsQr,vBudWormprePsQr,vBudWormadltPsQr,vBudWormlarvsPsQr : SINGLE100;
	vBudWormeggPhQh,vBudWormlarv1PhQh,vBudWormlarv2PhQh,vBudWormlarv3PhQh,vBudWormlarv4PhQh,vBudWormlarv5PhQh:SINGLE100;
	vBudWormpupaPhQh,vBudWormprePhQh,vBudWormadltPhQh,vBudWormlarvsPhQh : SINGLE100;
	vBudWormeggPhQs,vBudWormlarv1PhQs,vBudWormlarv2PhQs,vBudWormlarv3PhQs,vBudWormlarv4PhQs,vBudWormlarv5PhQs:SINGLE100;
	vBudWormpupaPhQs,vBudWormprePhQs,vBudWormadltPhQs,vBudWormlarvsPhQs : SINGLE100;
	vBudWormeggPsQh,vBudWormlarv1PsQh,vBudWormlarv2PsQh,vBudWormlarv3PsQh,vBudWormlarv4PsQh,vBudWormlarv5PsQh:SINGLE100;
	vBudWormpupaPsQh,vBudWormprePsQh,vBudWormadltPsQh,vBudWormlarvsPsQh : SINGLE100;
	vBudWormeggPsQs,vBudWormlarv1PsQs,vBudWormlarv2PsQs,vBudWormlarv3PsQs,vBudWormlarv4PsQs,vBudWormlarv5PsQs:SINGLE100;
	vBudWormpupaPsQs,vBudWormprePsQs,vBudWormadltPsQs,vBudWormlarvsPsQs : SINGLE100;

	vBudWormlarv1r,vBudWormlarv1h,vBudWormlarv1s:SINGLE100;
	vBudWormlarv2r,vBudWormlarv2h,vBudWormlarv2s:SINGLE100;
	vBudWormlarv3r,vBudWormlarv3h,vBudWormlarv3s:SINGLE100;
	vBudWormlarv4r,vBudWormlarv4h,vBudWormlarv4s:SINGLE100;
	vBudWormlarv5r,vBudWormlarv5h,vBudWormlarv5s:SINGLE100;

	cumlBudWormPrQr,cumlBudWormPrQh,cumlBudWormPrQs,cumlBudWormPhQr,cumlBudWormPsQr,cumlBudWormPhQh,cumlBudWormPhQs,cumlBudWormPsQh,cumlBudWormPsQs:real;
	cumlBudWormWgtPrQr,cumlBudWormWgtPrQh,cumlBudWormWgtPrQs,cumlBudWormWgtPhQr,cumlBudWormWgtPsQr,cumlBudWormWgtPhQh,cumlBudWormWgtPhQs,cumlBudWormWgtPsQh,cumlBudWormWgtPsQs:real;
	cumlBudWormwgtr,cumlBudWormwgth,cumlBudWormwgts:single;
	BudWormNumsTot:SINGLE100;

	FromPeakDdBudWorm:single;
	UseBudwormCounts:Boolean;
	BudWormdiapdate:real;
	BudWormDiapJdayStart:integer;
	BudWormDiapPrQr,BudWormDiapPrQh,BudWormDiapPrQs,BudWormDiapPhQr,BudWormDiapPsQr,BudWormDiapPhQh,BudWormDiapPhQs,BudWormDiapPsQh,BudWormDiapPsQs:real;
	BudWormDemand:single10;
	BudWormdmgrow,dmresBudWorm,dmrespBudWorm : single;
	TotBudWormfood:single;
	
	BudWorminRun: boolean; {using BudWorm?}
	BudWormPrefLeafAge:byte;
	BudWormimrt : single;
	BudWormd1 : single; {start date}
	BudWormUseInitialImrt:boolean;

	BudWormalpha,BudWormbeta:single;
	BudWormovipa:single; {multiplier for BudWorm ovip function}
	goBudWorm: boolean; {has BudWorm started?}
	
	BudWormNumsPrQr,BudWormNumsPrQh,BudWormNumsPrQs,BudWormNumsPhQr,BudWormNumsPsQr,BudWormNumsPhQh,BudWormNumsPhQs,BudWormNumsPsQh,BudWormNumsPsQs:SINGLE100;
	BudWormWgtsPrQr,BudWormWgtsPrQh,BudWormWgtsPrQs,BudWormWgtsPhQr,BudWormWgtsPsQr,BudWormWgtsPhQh,BudWormWgtsPhQs,BudWormWgtsPsQh,BudWormWgtsPsQs:SINGLE100;

	BudWormpref : array[1..5,1..7] of single;
	BudWormEggPrQr,BudWormEggPrQh,BudWormEggPrQs,BudWormEggPhQr,BudWormEggPsQr,BudWormEggPhQh,BudWormEggPhQs,BudWormEggPsQh,BudWormEggPsQs:single;
	BudWormLarv1PrQr,BudWormLarv1PrQh,BudWormLarv1PrQs,BudWormLarv1PhQr,BudWormLarv1PsQr,BudWormLarv1PhQh,BudWormLarv1PhQs,BudWormLarv1PsQh,BudWormLarv1PsQs:single;
	BudWormLarv2PrQr,BudWormLarv2PrQh,BudWormLarv2PrQs,BudWormLarv2PhQr,BudWormLarv2PsQr,BudWormLarv2PhQh,BudWormLarv2PhQs,BudWormLarv2PsQh,BudWormLarv2PsQs:single;
	BudWormLarv3PrQr,BudWormLarv3PrQh,BudWormLarv3PrQs,BudWormLarv3PhQr,BudWormLarv3PsQr,BudWormLarv3PhQh,BudWormLarv3PhQs,BudWormLarv3PsQh,BudWormLarv3PsQs:single;
	BudWormLarv4PrQr,BudWormLarv4PrQh,BudWormLarv4PrQs,BudWormLarv4PhQr,BudWormLarv4PsQr,BudWormLarv4PhQh,BudWormLarv4PhQs,BudWormLarv4PsQh,BudWormLarv4PsQs:single;
	BudWormLarv5PrQr,BudWormLarv5PrQh,BudWormLarv5PrQs,BudWormLarv5PhQr,BudWormLarv5PsQr,BudWormLarv5PhQh,BudWormLarv5PhQs,BudWormLarv5PsQh,BudWormLarv5PsQs:single;
	BudWormLarPrQr,BudWormLarPrQh,BudWormLarPrQs,BudWormLarPhQr,BudWormLarPsQr,BudWormLarPhQh,BudWormLarPhQs,BudWormLarPsQh,BudWormLarPsQs:single;
	BudWormPupPrQr,BudWormPupPrQh,BudWormPupPrQs,BudWormPupPhQr,BudWormPupPsQr,BudWormPupPhQh,BudWormPupPhQs,BudWormPupPsQh,BudWormPupPsQs:single;
	BudWormPrePrQr,BudWormPrePrQh,BudWormPrePrQs,BudWormPrePhQr,BudWormPrePsQr,BudWormPrePhQh,BudWormPrePhQs,BudWormPrePsQh,BudWormPrePsQs:single;
	BudWormAdltPrQr,BudWormAdltPrQh,BudWormAdltPrQs,BudWormAdltPhQr,BudWormAdltPsQr,BudWormAdltPhQh,BudWormAdltPhQs,BudWormAdltPsQh,BudWormAdltPsQs:single;

	BudWormeggtot,BudWormlartot,BudWormpuptot,BudWormpretot,BudWormadlttot : single;
	BudWormlarsmall,BudWormlarbig:single;
	BudWormLarvWgt1PrQr,BudWormLarvWgt1PrQh,BudWormLarvWgt1PrQs,BudWormLarvWgt1PhQr,BudWormLarvWgt1PsQr,BudWormLarvWgt1PhQh,BudWormLarvWgt1PhQs,BudWormLarvWgt1PsQh,BudWormLarvWgt1PsQs:single;
	BudWormLarvWgt2PrQr,BudWormLarvWgt2PrQh,BudWormLarvWgt2PrQs,BudWormLarvWgt2PhQr,BudWormLarvWgt2PsQr,BudWormLarvWgt2PhQh,BudWormLarvWgt2PhQs,BudWormLarvWgt2PsQh,BudWormLarvWgt2PsQs:single;
	BudWormLarvWgt3PrQr,BudWormLarvWgt3PrQh,BudWormLarvWgt3PrQs,BudWormLarvWgt3PhQr,BudWormLarvWgt3PsQr,BudWormLarvWgt3PhQh,BudWormLarvWgt3PhQs,BudWormLarvWgt3PsQh,BudWormLarvWgt3PsQs:single;
	BudWormLarvWgt4PrQr,BudWormLarvWgt4PrQh,BudWormLarvWgt4PrQs,BudWormLarvWgt4PhQr,BudWormLarvWgt4PsQr,BudWormLarvWgt4PhQh,BudWormLarvWgt4PhQs,BudWormLarvWgt4PsQh,BudWormLarvWgt4PsQs:single;
	BudWormLarvWgt5PrQr,BudWormLarvWgt5PrQh,BudWormLarvWgt5PrQs,BudWormLarvWgt5PhQr,BudWormLarvWgt5PsQr,BudWormLarvWgt5PhQh,BudWormLarvWgt5PhQs,BudWormLarvWgt5PsQh,BudWormLarvWgt5PsQs:single;

	BudWormEggwPrQr,BudWormEggwPrQh,BudWormEggwPrQs,BudWormEggwPhQr,BudWormEggwPsQr,BudWormEggwPhQh,BudWormEggwPhQs,BudWormEggwPsQh,BudWormEggwPsQs:single;
	BudWormLarwPrQr,BudWormLarwPrQh,BudWormLarwPrQs,BudWormLarwPhQr,BudWormLarwPsQr,BudWormLarwPhQh,BudWormLarwPhQs,BudWormLarwPsQh,BudWormLarwPsQs:single;
	BudWormPupwPrQr,BudWormPupwPrQh,BudWormPupwPrQs,BudWormPupwPhQr,BudWormPupwPsQr,BudWormPupwPhQh,BudWormPupwPhQs,BudWormPupwPsQh,BudWormPupwPsQs:single;
	BudWormPrwPrQr,BudWormPrwPrQh,BudWormPrwPrQs,BudWormPrwPhQr,BudWormPrwPsQr,BudWormPrwPhQh,BudWormPrwPhQs,BudWormPrwPsQh,BudWormPrwPsQs:single;
	BudWormPrewPrQr,BudWormPrewPrQh,BudWormPrewPrQs,BudWormPrewPhQr,BudWormPrewPsQr,BudWormPrewPhQh,BudWormPrewPhQs,BudWormPrewPsQh,BudWormPrewPsQs:single;
	BudWormAdwPrQr,BudWormAdwPrQh,BudWormAdwPrQs,BudWormAdwPhQr,BudWormAdwPsQr,BudWormAdwPhQh,BudWormAdwPhQs,BudWormAdwPsQh,BudWormAdwPsQs:single;

	BudwormImmigrants:real;
	BudwormBudDamage:real;

	BudWormtoteggs :single;
	BudWormbase                 : single;
	BudWormdd,tBudWormdd,FromBudWormPeakDd: single;
	PBudWorm,QBudWorm,BudWormRefugeEffect :single;{Initial frequency of Bt resistant gene & refuge effects}

	BudWormsd,BudWormdmtot,BudWormfood,BudWormTotWgtdResource : single;
	BudWormreserve : single;
	BudWormTotcons,cumlBudWormTotcons : single;
	totBudWormgrow:single;
	
	BudWormeggdays,BudWorml1days,BudWorml2days,BudWorml3days,BudWorml4days,BudWorml5days,
	BudWormpupadays,BudWormadltdays:single;

	// Cumulatives for GIS and Summary.
	BudWormeggSum,BudWormLarvSmallSum,BudWormLarvBigSum,BudWormpupSum,BudWormAdPreSum,BudWormDiapsSum:real;

	startBudWorm:boolean;
	L10BudWormLarv:single;
	
	BudWormMusum:single;
	
	BudWormlxbtr,BudWormlxbth,BudWormlxbts:SINGLE100;
	BudWormlxbtrr,BudWormlxbtrs,BudWormlxbtsr,BudWormlxbtss:SINGLE100;
	lxBudWorm1,lxBudWorm2,lxBudWorm3,lxBudWorm4,lxBudWorm5,lxBudWorm6 : single;
	btFruitConcentration:single;

{Lygus}
	vlyvul : SINGLE100; {Select age range of fruit vulnerable to lygus.}
	slyg,dlyg,lygspray:boolean;
	dnslyin,dnsly5:single;
	LygusSprayMortMax:single; {lygus spray strength}
	LYgusAdults,LygusAge:array[1..75]of single;     
	hadult,xnymphs,HSPLX,LYSQ,AGEVUL,deltfahr,tdeltfahr:single;
	xnymphsSum,hadultSum : single; // Cumulatives for GIS and Summary.
	t200,t800,facnym:single;
	last:word;
	L10LygN,L10LygA:single;
	shedly                    : single; {Cumulative sheds due to lygus}
	ShedsToday:single; {today's sheds due to Lygus. added to SumSqrShed.}

{Verticillium wilt}
	VW:boolean;
	icohor,nvwcoh:byte;
	delqt,T100,ftdelt:single;
	derv:single;
	qt,qt0:single;
	dnsity:single;
	prpgm:single; {propagules/gm}
	VWlx:single;
	yield:SINGLE100; {yield of each cohort}
	PbwB,BollWeevilB,BudwormB, BollWormB:single;
	VWalfa,VWk:single;

implementation
end.

