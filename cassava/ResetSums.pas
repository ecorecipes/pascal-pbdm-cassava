Procedure ResetSums;
//cumulative sums since previous output of insect values for Gis and Summaries outputs.	
var
	i:byte;
begin
	tddfield:=0.0;
	
	gmsum    :=0;
	TariSum  :=0;
	TmaniSum :=0;
	for i:= 1 to 6 do mbnSum[i]:=0;
	for i:=1 to 3 do
	begin
		ednumSum[i]:=0;
		elnumSum[i]:=0;
	end;
	HjEggSum := 0;
	HjLarSum := 0;
	HjAdlSum := 0;
end;


