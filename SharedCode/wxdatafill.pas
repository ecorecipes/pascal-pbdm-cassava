{$APPTYPE CONSOLE}
uses modutils,sysutils;

type
	weather   = array [1..73050] of single;	//73050=365.25*200  allows 200 years
	weathers  = array [1..73050, 1..2] of single;
const
	tb = #9; {Tab character for output}

label ErrorExit;

var
	nday:byte;

	solar,rain,relhum,winds		: weather;
	temps				: weathers;
	solar2,rain2,relhum2,winds2	: weather;
	temps2				: weathers;
	solmiss,rainmiss,rhmiss,windmiss,tmiss:word;
	solmissOK,rainmissOK,rhmissOK,windmissOK,tmissOK:word;
	month,day,year,mm,dd,yy:integer;
	month2,day2,year2,mm2,dd2,yy2:integer;
	i:word;
	long1,long2,lat1,lat2:real;
	wxid1,wxid2,wx1name,wx2name,tempfilename:string[20];
	LINE,LINE1,LINE2,LINE3:STRING;
	wx1file,wx2file,tempfile:text;
begin
{Get command line parameters.}

	Wx1Name:=paramstr(1);
	Wx2Name:=paramstr(2);

// open weather file 1
	assign(wx1file,wx1name);
	{$i-} reset(wx1file) {$i+};
	ok:=(ioresult=0);
	while not ok do
	begin
		writeln(' Wx file 1 not found');
		readln;
		exit;
	end;

// open weather file 2
	assign(wx2file,wx2name);
	{$i-} reset(wx2file) {$i+};
	ok:=(ioresult=0);
	while not ok do
	begin
		writeln('Wx file 2 not found');
		readln;
		exit;
	end;

	TempFilename:='tempfile';
	assign(TempFile,TempFileName);
	{$i-} rewrite(TempFile); {$i+};
	i:=ioresult;
	ok:=(i = 0);
	if not ok then
	begin
		writeln('Can not open: tempfile');
		readln;
		exit;
	end;

	solmiss:=0;rainmiss:=0;rhmiss:=0;windmiss:=0;tmiss:=0;
	solmissOK:=0;rainmissOK:=0;rhmissOK:=0;windmissOK:=0;tmissOK:=0;

	readln(wx1file,LINE1);
WRITELN('WXID1= ',LINE1);
WXID1:=LINE1;
WRITELN('WXID1= ',WXID1);
	readln(wx1file,LINE2);              {read long,latitude}
WRITELN(LINE2);
	readln(wx1file,LINE3);  {read line of column headers in data file}
WRITELN(LINE3);
	readln(wx2file,LINE);
WXID2:=LINE;
WRITELN(LINE);
	readln(wx2file,LINE);              {read long,latitude}
WRITELN(LINE);
	readln(wx2file);  {read line of column headers in data file}
	writeln(Tempfile,LINE1);
	writeln(Tempfile,LINE2);             
	writeln(TempFile,line3);
writeln('Check for missing data at ',wxid1:12);
writeln(' using data from ',wxid2);
readln;
	mm:=13;
	i:=1;
	while ((not eof(wx1file))and (not eof(wx2file))and(mm>0)) do
	begin
		readln(wx1file,mm,dd,yy,temps[i,1],temps[i,2],solar[i],
			rain[i],relhum[i],winds[i]);
		readln(wx2file,mm2,dd2,yy2,temps2[i,1],temps2[i,2],solar2[i],
			rain2[i],relhum2[i],winds2[i]);


writeln(mm,dd:3,yy:5,temps[i,1]:7:2,temps[i,2]:7:2,solar[i]:7:0,rain[i]:7:2,relhum[i]:7:2,winds[i]:7:2);
writeln(mm2,dd2:3,yy2:5,temps2[i,1]:7:2,temps2[i,2]:7:2,solar2[i]:7:0,rain2[i]:7:2,relhum2[i]:7:2,winds2[i]:7:2);
writeln;

		if (temps[i,1]<-99)then 
		begin
			inc(tmiss);
			if temps2[i,1]>-100 then
			begin
				temps[i,1]:=temps2[i,1];
				inc(tmissok);
			end;
		end;
		if (temps[i,2]<-99)then 
		begin
			inc(tmiss);
			if temps2[i,2]>-100 then
			begin
				temps[i,2]:=temps2[i,2];
				inc(tmissok);
			end;
		end;

		if (solar[i]<0)then 
		begin
			inc(solmiss);
			if solar2[i]>=0 then
			begin
				solar[i]:=solar2[i];
				inc(solmissok);
			end;
		end;
		if (rain[i]<0)then 
		begin
			inc(rainmiss);
			if rain2[i]>=0 then
			begin
				rain[i]:=rain2[i];
				inc(rainmissok);
			end;
		end;
		if (relhum[i]<0)then 
		begin
write('rh dmiss');
			inc(rhmiss);
			if relhum2[i]>=0 then
			begin
				relhum[i]:=relhum2[i];
				inc(rhmissok);
write('rh1= ',relhum[i]:8:0,' rh2= ',relhum2[i]:8:2);
			end;
writeln;
		end;
		if (winds[i]<0)then 
		begin
			inc(windmiss);
			if winds2[i]>=0 then
			begin
				winds[i]:=winds2[i];
				inc(windmissok);
			end;
		end;
	
		writeln(TempFile,mm:1,tb,dd:1,tb,yy:1,tb,temps[i,1]:1:2,tb,temps[i,2]:1:2,tb,solar[i]:1:1,tb,
			rain[i]:1:3,tb,relhum[i]:1:2,tb,winds[i]:1:0);
		inc(i);
	end;
	if eof(wx1file)then writeln('eof on wx1 after ',mm:2,dd:3,yy:5);
	if eof(wx2file)then writeln('eof on wx2 after ',mm2:2,dd2:3,yy2:5);
	if (tmiss>0)then writeln('tmiss= ',tmiss:6,' tmissok= ',tmissok:6);
	if (solmiss>0)then writeln('solmiss= ',solmiss:6,' solmissok= ',solmissok:6);
	if (rainmiss>0)then writeln('rainmiss= ',rainmiss:6,' rainmissok= ',rainmissok:6);
	if (rhmiss>0)then writeln('rhmiss= ',rhmiss:6,' rhmissok= ',rhmissok:6);
	if (windmiss>0)then writeln('windmiss= ',windmiss:6,' windmissok= ',windmissok:6);
	
	close(wx1file);
	close(wx2file);
	close(tempfile);
	if ((tmissok>0)or(solmissok>0)or (rainmissok>0)or(rhmissok>0)or(windmissok>0))then
	begin
		if renamefile(wx1name,'temporarywx')then
		begin
			writeln('file ',wx1name,' renamed temporarywx');
			if not renamefile(tempfilename,Wx1Name) then
			begin
				writeln('file ',tempfilename,' not renamed.');
			end
			else
				writeln('Changed file is now ',wx1name);
		end;
	end;
			

	

end.
