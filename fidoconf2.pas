unit fidoconf2;

interface


{$ifdef __GPC__}
uses gpcstrings,fconf;
{$endif}

{$ifdef fpc}
	{$ifdef linux}
    uses fconf,strings;
	{$endif}
{$linklib fidoconfig}
{$endif}


{Improved getarea}
function Getareaimp(config:ps_fidoconfig; areaName:pchar):ps_area;

implementation

function Getareaimp(config:ps_fidoconfig; areaName:pchar):ps_area;
type
 area_array=array[1..10000] of area;
 ps_area_array=^area_array;
var 
 a:ps_area;
 aa:ps_area_array;
 i:integer;
 p:pointer;
begin
{Netmailarea?}
{$ifdef __GPC__}
	aa:=ps_area_array(config^.netmailareas^);  
{$else}
	aa:= ps_area_array(config^.netmailareas);
{$endif}

if stricomp(areaname,'netmailarea')=0 then begin
	getareaimp:=@aa^[1];
    exit;
end;

for i:=1 to config^.netmailareacount do begin
	if stricomp(areaname,aa^[i].areaname)=0 then begin
		getareaimp:=@aa^[i];
	    exit;
	end;
end;

{normal area?}
a:=getarea(config,areaname);
if a=@config^.badarea then a:=nil;
if a=@config^.dupearea then a:=nil;

{localarea}
if a=nil then begin
	{$ifdef __GPC__}
	aa:=ps_area_array(config^.localareas^);  
	{$else}
	aa:=ps_area_array(config^.localareas);
	{$endif}
    for i:=1 to config^.localareacount do begin
		{$ifdef __GPC__}
		if stricomp(aa^[i].areaname,areaname)=0 then begin
			a:=@aa^[i];
            break;
        end;
		{$else}
		if stricomp(aa^[i].areaname,areaname)=0 then begin
			a:=@aa^[i];
            break;
        end;
		{$endif}
    end;
end;
getareaimp:=a;
end;

end.
