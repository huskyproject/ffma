unit log;

interface

{$ifdef __GPC__}
	uses gpcstrings,erweiter;
{$endif}

{$ifdef fpc}
	{$ifdef linux}
	uses erweiter,dos;
	{$define havedosunit}
	{$endif}
{$endif}



const
 showlevel:word=5;
 loglevel:word=3;

procedure Logit(pri:word;t:string);
procedure Openlogfile(s:string);
procedure Closelogfile;

implementation

var
 f:text;
 exitsave:pointer;

{$i-}
procedure openlogfile(s:string);
var
 io:word;
begin
 assign(f,s);
 append(f);
 io:=ioresult;
 if io=2 then begin rewrite(f); io:=ioresult; end;
 if io<>0 then begin
  writeln('Could not create logfile ',s,' Error:',io);
  halt(255);
 end;
 close(f);
append(f);
end;

{pri 0..9  9 very important  0 not important}

procedure logit(pri:word;t:string);
const
     month:array[1..12] of string=  ('Jan'  ,  'Feb' ,  'Mar'  ,  'Apr'
                 ,  'May'  ,  'Jun' ,  'Jul'  ,  'Aug'
                 ,  'Sep'  ,  'Oct' ,  'Nov'  ,  'Dec');
var
 y,m,d,dow:word;
 h,min,sec,s100:word;
 s:String;
begin
 s:='';
	{$ifdef __GPC__}
	y:=0; m:=0; d:=0; dow:=0; h:=0; min:=0; sec:=0; s100:=0;
	{$else}
 getdate (y,m,d,dow);
 gettime(h,min,sec,s100);
	{$endif}
 if pri>9 then pri:=9;
 s:=z2s(pri)+' '+z2s_nullen(d,2)+' '+month[m]+' '+z2s_nullen(h,2)+':'+z2s_nullen(min,2)+':'+z2s_nullen(sec,2)+' FFMA '+t;
 if loglevel<=pri then writeln(f,s);
 if showlevel<=pri then writeln(t);
 flush(f);
end;

procedure closelogfile;
begin
	close(f);
    if ioresult=0 then;
end;

procedure logexit;
begin
	{$ifdef __GPC__}
    closelogfile;
	{$else}
	exitproc:=exitsave;
	closelogfile;
	{$endif}
end;

begin
	{$ifdef __GPC__}
	{$else}
	exitsave:=exitproc;
	exitproc:=@logexit;
	{$endif}
	{$ifdef debugit}
	loglevel:=0;
	{$endif}
end.