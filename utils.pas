unit utils;

 {
 }


interface


{$ifdef __GPC__}
uses gpcstrings,memman,gpcsmapi,erweiter;
{$endif}

{$ifdef fpc}
	{$ifdef linux}
	uses strings,dos,memman,erweiter,smapi;
	{$define havedosunit}
	{$endif}
{$endif}


{$ifdef ver70}
 Sorry. Borland Pascal is not supported.
{$endif}


function transstring(s:string):string;
procedure writelnspe(p:pchar);
function string2addr(s:String;var a:netaddr):boolean;
procedure word2timedate(time:word;date:word;var h,min,s:word; var d,mon,y:word);
function showdatetime(date:word;time:word):string;
function showdate(date:word):string;
function showtime(time:word):string;
procedure datetime2ftsdate(var date,time:word;var fts:array of char);
function showaddr(a:netaddr):string;
function longint2hex(l:longint):string;
function msgid:longint;
function array2string(p:pchar;max:word):string;
procedure getfulladdr(var p:pchar;var size:longint;var o:netaddr;var d:netaddr);

implementation
const
   RCSID: PChar = '$Id$';
   lastmsgid:longint=0;
function string2addrspe(s:String;var a:netaddr):boolean;
var
 z,net,node,p:word;
 t:string;
 err:word;
begin
 string2addrspe:=false;
 s:=killspaceae(s)+'.';

 val(copy(s,1,pos(':',s)-1),z,err);
 if err<>0 then exit;
 delete(s,1,pos(':',s));

 val(copy(s,1,pos('/',s)-1),net,err);
 if err<>0 then exit;
 delete(s,1,pos('/',s));

 val(copy(s,1,pos('.',s)-1),node,err);
 if err<>0 then exit;
 delete(s,1,pos('.',s));

 if s='' then begin
 end else begin
   val(copy(s,1,pos('.',s)-1),p,err);
   if err<>0 then exit;
   delete(s,1,pos('.',s));
   if s<>'' then exit;
   a.point:=p;
 end;
 a.zone:=z;
 a.node:=node;
 a.net:=net;
 string2addrspe:=true;
end;
function array2string(p:pchar;max:word):string;
var
 s:string;
 i:word;
begin
 s:='';
 for i:=0 to max-1 do begin
  if p[i]=#0 then break;
  s:=s+p[i];
 end;
 array2string:=s;
end;

function transstring(s:string):string;
begin
 if (length(s)>0) and (s[1]='"') then delete(s,1,1);
 if (length(s)>0) and (s[length(s)]='"') then delete(s,length(s),1);
 transstring:=s;
end;
procedure getfulladdr(var p:pchar;var size:longint;var o:netaddr;var d:netaddr);
var
 s:String;
 t:string;
 i:longint;
 k,j:longint;
 ziel:pchar;
begin
 i:=0; j:=0;
 s:='';
 ziel:=getmemory(size+1000);
 while p[i]<>#0 do begin
   s:=s+p[i];
   inc(i);
   if (p[i]=#1) or (p[i]=#0) then begin
    if copy(s,1,6)=#1'INTL ' then begin
      delete(s,1,6);
      t:=killspaceae(copy(s,1,pos(' ',s)));
      string2addrspe(t,d);
      delete(s,1,pos(' ',s));
      string2addrspe(killspaceae(s),o);
      s:='';
      continue;
    end;
    if copy(s,1,6)=#1'TOPT ' then begin
      delete(s,1,6);
      d.point:=s2z(s);
      s:='';
      continue;
    end;
    if copy(s,1,6)=#1'FMPT ' then begin
       delete(s,1,6);
       o.point:=s2z(s);
       s:='';
       continue;
    end;
    {if copy(s,1,8)=#1'MSGID: ' then begin  s:=''; continue; end;}
    for k:=1 to length(s) do begin
       ziel[j]:=s[k]; inc(j);
    end;
    s:='';
   end;
 end;
 ziel[j]:=#0;
 freememory(p,true);
 size:=j-1;
 p:=ziel;
end;

procedure writelnspe(p:pchar);
var
 i:longint;
begin
 i:=0;
 while p[i]<>#0 do begin
  case p[i] of
  #1:write('#');
  else begin
   write(p[i]);
  end
  end;
  inc(i);
 end;
 writeln;
end;

function longint2hex(l:longint):string;
const
 conv:string='0123456789ABCDEF';
var
 s:string;
 i:integer;
begin
 s:='';
 for i:=1 to 8 do begin
  s:=conv[(l and $f)+1]+s;
  l:=l shr 4;
 end;
 longint2hex:=s;
end;

function msgid:longint;
{     Year Mon Day Hour Min Sec Counter}
{BITS  3    4   5   5    6   6    3    }
{The Msgid is unique at least for 7 Years}
{I can only gernate 7 unique Msgid per Sec}
var
 y,m,d,dow:word;
 h,min,sec,s100:word;

var
 l:longint;
begin
 repeat
	{$ifdef __GPC__}
		y:=0; m:=0; d:=0; dow:=0; h:=0; min:=0; sec:=0; s100:=0;
	{$else}
		getdate(y,m,d,dow);
		gettime(h,min,sec,s100);
	{$endif}

   l:=((longint(y) mod 7) shl 29) or
       (longint(m) shl 25) or
       (longint(d) shl 20) or
       (longint(h) shl 15) or
       (longint(min) shl 9) or
       (longint(sec) shl 3);
   if (l=(lastmsgid and $fffffff8)) then begin
      if (lastmsgid and 7)=7 then continue;
      l:=lastmsgid+1;
   end;
   break;
 until false;
 lastmsgid:=l;
 msgid:=l;
end;

procedure datetime2ftsdate(var date,time:word;var fts:array of char);
const
      day:array[0..6] of string=('Sun','Mon','Tue', 'Wed','Thu','Fri','Sat');
     month:array[1..12] of string=  ('Jan'  ,  'Feb' ,  'Mar'  ,  'Apr'
                 ,  'May'  ,  'Jun' ,  'Jul'  ,  'Aug'
                 ,  'Sep'  ,  'Oct' ,  'Nov'  ,  'Dec');
var
 y,m,d,dow:word;
 h,min,sec,s100:word;
 s:String;
 i:word;
begin
	{$ifdef __GPC__}
		y:=0; m:=0; d:=0; dow:=0; h:=0; min:=0; sec:=0; s100:=0;
	{$else}
		getdate(y,m,d,dow);
		gettime(h,min,sec,s100);
	{$endif}
 time:=(sec div 2)+(min shl 5)+(h shl 11);
 date:=d+(m shl 5)+((y-1980) shl 9);
 fillchar(fts,sizeof(fts),0);
 s:='Date: '+day[dow]+', '+z2s_nullen(d,2)+' '+month[m]+' '+z2s(y)+' '+z2s_nullen(h,2)+':'+z2s_nullen(min,2)+':'+
 z2s_nullen(sec,2)+' +0100';
 for i:=1 to length(s) do begin
  fts[i-1]:=s[i]; if i=20 then break;
 end;
end;

function showaddr(a:netaddr):string;
begin
 showaddr:=z2s(a.zone)+':'+z2s(a.net)+'/'+z2s(a.node)+'.'+z2s(a.point);
end;

function showtime(time:word):string;
var
h,min,s,d,mon,y:word;
begin
  word2timedate(time,0,h,min,s,d,mon,y);
  showtime:= z2s_nullen(h,2)+':'+
                z2s_nullen(min,2)+':'+
                z2s_nullen(s,2);
end;

function showdate(date:word):string;
var
h,min,s,d,mon,y:word;
begin
  word2timedate(0,date,h,min,s,d,mon,y);
  showdate:=z2s_nullen(d,2)+'.'+
                z2s_nullen(mon,2)+'.'+
                z2s(y);
end;

function showdatetime(date:word;time:word):string;
var
h,min,s,d,mon,y:word;
begin
  word2timedate(time,date,h,min,s,d,mon,y);
  showdatetime:=z2s_nullen(d,2)+'.'+
                z2s_nullen(mon,2)+'.'+
                z2s(y)+' '+
                z2s_nullen(h,2)+':'+
                z2s_nullen(min,2)+':'+
                z2s_nullen(s,2);
end;

procedure word2timedate(time:word;date:word;var h,min,s:word; var d,mon,y:word);
begin
 s:=(time and 31)*2;
 min:=(time shr 5) and 63;
 h:=(time shr 11) and 31;

 d:=date and 31;
 mon:=(date shr 5) and 15;
 y:=((date shr 9) and 127)+1980 {Years since 1980!?};
end;

function string2addr(s:String;var a:netaddr):boolean;
var
 z,net,node,p:word;
 t:string;
 err:word;
begin
 p:=0;
 string2addr:=false;
 s:=killspaceae(s)+'.';

 val(copy(s,1,pos(':',s)-1),z,err);
 if err<>0 then exit;
 delete(s,1,pos(':',s));

 val(copy(s,1,pos('/',s)-1),net,err);
 if err<>0 then exit;
 delete(s,1,pos('/',s));

 val(copy(s,1,pos('.',s)-1),node,err);
 if err<>0 then exit;
 delete(s,1,pos('.',s));

 if s='' then begin
  p:=0
 end else begin
   val(copy(s,1,pos('.',s)-1),p,err);
   if err<>0 then exit;
   delete(s,1,pos('.',s));
   if s<>'' then exit;
 end;
 a.zone:=z;
 a.node:=node;
 a.net:=net;
 a.point:=p;
 string2addr:=true;
end;

end.
