Unit wxread;
interface

uses globals,modutils,sysutils;
procedure readwx(var wxfile:text;Firstdate,Lastdate:single;
					  var ndays:word);

Implementation

procedure wxmissing;
(*
	Check for missing data markers in wx file and fill in with
	default values.
*)
var
	tmiss,smiss,pmiss,rmiss,wmiss:boolean;
	i:integer;
	tmaxd,tmind,DefaultSolar,DefaultPrecip,DefaultRelHum,DefaultWind : single;

begin
	tmiss:=false;
	smiss:=false;
	pmiss:=false;
	rmiss:=false;
	wmiss:=false;

	for i:=1 to ndays do
	begin
		if((temps[i,1]=-100.0)or(temps[i,2]=-100.0))then tmiss:=true;
		if(solar[i]=-1.0)then smiss:=true;
		if(rain[i]=-1.0)then pmiss:=true;
		if(relhum[i]=-1.0)then rmiss:=true;
		if(winds[i]=-1.0)then wmiss:=true;
	end;            

	if tmiss then
	begin
		{default values for celsius temps:}
		tmaxd:=25.0; 
		tmind:=12.0;
//		reporterror('Some temperature data is missing. Using tmax=25, tmin=12.');
		for i:=1 to ndays do
		begin
			if (temps[i,1]=-100.0) then temps[i,1]:=tmaxd;
			if (temps[i,2]=-100.0) then temps[i,1]:=tmind;
		end;
	end;

	if smiss then
	begin
		DefaultSolar:=200.0;
//		reporterror('Some solar data is missing.  Using solrad=200.');
		for i:=1 to ndays do
		begin
			if (solar[i]=-1.0) then solar[i]:=DefaultSolar;
		end;
	end;

	if pmiss then
	begin
		DefaultPrecip:=0.0;
//		reporterror('Some rain data is missing.  Using precip=0.0.');
		for i:=1 to ndays do
		begin
			if (rain[i]=-1.0) then rain[i]:=DefaultPrecip;
		end;
	end;

	if rmiss then
	begin
//		reporterror('Some rel. hum. data is missing.  Using 55%.');
		DefaultRelHum:=55.0;
		for i:=1 to ndays do
		begin
			if (relhum[i]=-1.0) then relhum[i]:=DefaultRelHum;
		end;
	end;

	if wmiss then
	begin
//		reporterror('Some wind data is missing.  Using wind default=1.0');
		DefaultWind:=1.0;
		for i:=1 to ndays do
		begin
			if (winds[i]=-1.0) then winds[i]:=DefaultWind;
		end;
	end;
end;


procedure wxunits(fahr,watts,inches,kilom,metersPerSec:boolean);
(*
	  called from readwx to make sure weather data is in expected units.
	  arrays temps, solar, rain, winds are global.
*)
var i:word;
begin
	if fahr then
	begin
		{writeln('converting temps data from fahrenheit to celsius.');}
		for i:=1 to ndays do
		begin
			temps[i,1]:=(temps[i,1]-32)* 0.55555;
			temps[i,2]:=(temps[i,2]-32)* 0.55555;
		end;
	end;
	if watts then
	begin
		{
		All the GIS solrad data should be in watts.
		Here we convert it to langleys:
		1/0.484=2.066
		Conversion units from http://www.ces.ncsu.edu/depts/hort/hil/pdf/hil-710.pdf  2/6/2002
		}
		for i:=1 to ndays do solar[i] := solar[i]*2.066; //This converts solrad data from watts to langleys.
	end;

	if inches then
	begin
		{writeln('converting precipitation data from inches to mm.');}
		for i:=1 to ndays do rain[i]:=rain[i]*25.4;
	end;
	if kilom then
	begin
		{writeln('converting windspeed data from kilometers to miles.');}
		for i:=1 to ndays do winds[i]:=winds[i]*1.609;
	end;
	if metersPerSec then
	begin
		{writeln('converting windspeed data from meters/sec to miles/hour.');}
		for i:=1 to ndays do winds[i]:=winds[i]*2.237; {http://www.digitaldutch.com/unitconverter/}
	end;
end; {procedure wxunits}


procedure DoAdjustWx;
{ Adjust wx data by adding offsets in array wxcons (if they are<>0.0).}
var i:word;
begin
	for i:= 1 to ndays do 
	begin
		if(wxcons[1]<>0.0)then
		begin
			temps[i,1]:=temps[i,1] + wxcons[1];
			temps[i,2]:=temps[i,2] + wxcons[1];
		end;

		if(wxcons[2]<>0.0)then solar[i]:=solar[i]+wxcons[2];
		if(wxcons[3]<>0.0)then rain[i]:=rain[i]+wxcons[3];
		if(wxcons[4]<>0.0)then relhum[i]:=relhum[i]+wxcons[4];
		if(wxcons[5]<>0.0)then winds[i]:=winds[i]+wxcons[5];
	end;
end;


procedure readwx(var wxfile:text;Firstdate,Lastdate:single;
					  var ndays:word);
(*
	read weather data from text file wxfile which has been linked
	(assigned) to a disk file.
*)
var
	fahr,watts,inches,kilom,MetersPerSec,Adjustwx,ok:boolean;
	wxday : single;
//	wxdayprev : single;
	month,day,year,mm,dd,yy:integer;
	i:word;
	tb:char;
	a:array[0..255]of char;
begin

	assign(wxfile,wxfilename);
	{$i-} reset(wxfile) {$i+};
	readln(wxfile,wxid);
	tb:=#9; //tab
	strPCopy(a,wxid); //get Pascal string into null-terminated string

	//find 2nd tab in wxid header
	i:=0;	repeat inc(i) until a[i]=tb; repeat inc(i) until a[i]=tb; a[i]:=#0;{null}
	//transfer wxid up to 2nd tab into pascal string 'location'.
	//this avoids the extra text that may be at the end of the header.	
	location:=strpas(a);	

	readln(wxfile,Longitude,LatitudeDegrees);              {read long,latitude}

	{Convert LatitudeDegrees from degrees to radians}
	{1 degrees = 0.0174533 radians}
	LatitudeRadians:= 0.0174533*LatitudeDegrees;

	Adjustwx:=false;
	for i:=1 to 5 do if wxcons[i]<>0.0 then Adjustwx:=true;
	readln(wxfile);  {read line of column headers in data file}
	{read first line of data}
	readln(wxfile,month,day,year,temps[1,1],temps[1,2],solar[1],rain[1],
			 relhum[1],winds[1]);


	wxday:=rdate(year,julian(month,day,year));
	ok:=true;

	if (Modelstartdate < wxday) then
	begin
		ReportError('Model start date precedes weather data.');
		runok:=false;
		exit;
	end;


	{read from wx file until date = ModelStartDate  or eof}
	while (ok and (ModelStartdate > wxday) and not eof(wxfile)) do
	begin

		 readln(wxfile,month,day,year,temps[1,1],temps[1,2],solar[1],
				  rain[1],relhum[1],winds[1]);
		 wxday:=rdate(year,julian(month,day,year));

	end;
	if(Modelstartdate > wxday)then
	begin
	{	writeln('Weather data ends before model start date.');}
		reporterror('Weather data ends before model start date.');
		runok:=false;
		exit;
	end;
	if ok then
	begin
{		wxday:=wxday-1;}{for sequence test}
		mm:=13;
		i:=2;
		while ((not eof(wxfile)) and (wxday < Lastdate)and (mm>0)) do
		begin
			readln(wxfile,mm,dd,yy,temps[i,1],temps[i,2],solar[i],
				rain[i],relhum[i],winds[i]);
			if mm>0 then begin month:=mm;day:=dd;year:=yy; end;

//			wxdayPrev:=wxday;
			if month>0 then	wxday:=rdate(year,julian(month,day,year));


writeln(mm,dd:3,yy:5,temps[i,1]:7:2,temps[i,2]:7:2,solar[i]:7:0,rain[i]:7:2,relhum[i]:7:2,winds[i]:7:2);
if ((solar[i]<0)or(rain[i]<0)or(relhum[i]<0)or(winds[i]<0)
	or(temps[i,1]<=-100.0)or(temps[i,2]<=-100.0))then
begin
writeln(mm,dd:3,yy:5,temps[i,1]:7:2,temps[i,2]:7:2,solar[i]:7:0,rain[i]:7:2,relhum[i]:7:2,winds[i]:7:2);
 readln;
end;
//writeln(' wxday,lastdate:',wxday:8:0,lastdate:8:0);
//readln;


//turn on the following block and line 238 to verify wx data date sequence:
{
			if (wxday-wxdayPrev)<>1 then
			begin
				writeln('WEATHER DATA NOT IN SEQUENCE AT DATE ',month:2,day:3,year:5);
				readln;
			end;
}

			inc(i);
		end;

		{here if wxday<Lastdate there is not enough data in the wx file }
		if (wxday<Lastdate) then
		begin
//writeln('end date adjust.  wxday,lastdate:',wxday:8:1,lastdate:8:1);
			reporterror('Model end date adjusted to end of weather data.');
			ndays:=trunc(wxday-ModelStartDate);
		 end;
	end;
	if ok then wxmissing;
(*
dec(i);
writeln('last i=',i:9);
writeln(mm,dd:3,yy:5,temps[i,1]:7:2,temps[i,2]:7:2,solar[i]:7:0,rain[i]:7:2,relhum[i]:7:2,winds[i]:7:2);
writeln(' wxday,lastdate:',wxday:8:0,lastdate:8:0);
readln;
*)	
	fahr:=false;	//gis data is in Celsius
	watts:=true;	//All the GIS solrad data should be in watts and must be converted to Langleys.
	inches:=false;	//gis precip data is in mm.
	kilom:=false;	//gis wind data is meters/sec.
	meterspersec:=true; //gis wind data is meters/sec.
		
	wxunits(fahr,watts,inches,kilom,metersPerSec);
	if Adjustwx then doAdjustwx;	//if *.ini has adjustment values <>0.0;

end; {procedure readwx}
end.
