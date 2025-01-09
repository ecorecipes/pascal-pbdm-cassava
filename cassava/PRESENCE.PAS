Procedure Presence;
(*
Called from Mulcas at start of each year to determine presence or absence
of each selected insect (and fungus mortality).
*)
begin
	if presenceabsence then
	begin
		CMBPresent:=random>0.5;
		ELPresent:=random>0.5;
		EDPresent:=random>0.5;
		GMPresent:=random>0.5;
		TaripoPresent:=random>0.5;
		TmanihotiPresent:=random>0.5;
		HJPresent:=random>0.5; {Coccinellid}
		FMPresent:=random>0.5; {Fungus Mort}
	end
	else
	begin
		CMBPresent:=true;
		ELPresent:=true;
		EDPresent:=true;
		GMPresent:=true;
		TaripoPresent:=true;
		TmanihotiPresent:=true;
		HJPresent:=true; {Coccinellid}
		FMPresent:=true; {Fungus Mort}
	end;

{
	These true/false variables will be used AND with existing selection
	variables.
}
	cmbin:=cmbpresent and cmbinfield;
	elin:=elpresent and elinfield;
	edin:=edpresent and edinfield;
	gmin:=gmpresent and gminfield;
	Taripoin:=Taripopresent and Taripoinfield;
	Tmanihotiin:=Tmanihotipresent and Tmanihotiinfield;
	hjin:=hjpresent and hjinfield;
	fmin:=fmpresent and fminfield;
end;

