unit fidoconf2;

interface


{$ifdef __GPC__}
uses gpcstrings,gpcfidoconf;
{$endif}

{$ifdef fpc}
	{$ifdef linux}
    uses fidoconfig,strings;
	{$endif}
{$endif}


{Improved getarea}
function Getareaimp(config:psfidoconfig; areaName:pchar):Parea;

implementation

function Getareaimp(config:psfidoconfig; areaName:pchar):Parea;
type
 area_array=array[1..10000] of area;
 Parea_array=^area_array;
var 
 a:parea;
 aa:parea_array;
 i:integer;
 p:pointer;
begin
{Netmailarea?}
{$ifdef __GPC__}
	aa:=parea_array(config^.netmailareas^);  
{$else}
	aa:=addr(config^.netmailareas^);
{$endif}

if stricomp(areaname,'netmailarea')=0 then begin
	getareaimp:=@aa^[1];
    exit;
end;

if stricomp(areaname,aa^[1].areaname)=0 then begin
	getareaimp:=@aa^[1];
    exit;
end;

{normal area?}
a:=getarea(config,areaname);
if a=@config^.badarea then a:=nil;
if a=@config^.dupearea then a:=nil;

{localarea}
if a=nil then begin
	{$ifdef __GPC__}
	aa:=parea_array(config^.localareas^);  
	{$else}
	aa:=addr(config^.localareas^);
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
