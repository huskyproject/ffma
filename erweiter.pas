 
unit erweiter;

{
 ERWEITER.PAS - Copyright (C) 1998 by Sven Bursch, Germany

 Revision 1.8  1998/10/16 18:10:41  sven
 - geterrortext

 Revision 1.7  1998/10/04 17:10:47  sven
 - Žnderungen fr DPMI vorgenommen

 Revision 1.6  1998/10/03 14:52:34  sven
 - diverse Žnderungen wegen verschiedenenen Compilern

 Revision 1.5  1998/10/02 19:34:32  sven
 - diverses

 Revision 1.4  1998/06/03 18:01:41  ingo
 - Copyrightnotiz

 Revision 1.3  1998/06/03 17:15:01  ingo
 - Funktionen fuer Cursorgroesse von MPEDITOR in ERWEITER verschoben

 Revision 1.2  1998/06/02 09:48:38  ingo
 Neue Funktion: Getlines
 Gibt die derzeitige Zeilenanzahl zurueck

 Revision 1.1  1998/06/02 09:12:36  ingo
 Initial revision

}

interface

{$ifdef __GPC__}
{$X+}
uses gpcstrings;
{$endif}

{$ifdef fpc}
	{$ifdef linux}
	uses strings,dos;
	{$define havedosunit}
	{$endif}
{$endif}


{$ifdef ver70}
   {$ifdef dpmi}
      uses strings,dos,winapi;
      {$define havedosunit}
      {$define realmode}
   {$else}
      uses strings,dos;
      {$define havedosunit}
   {$endif}
{$endif}


const
   k_down=20480;
   k_up=18432;
   k_altn=12544;
   k_esc=27;

{$ifdef ver70}{$ifdef dpmi}
type
    dpmiRegisters = record
       EDI, ESI, EBP, shouldbezero, EBX, EDX, ECX, EAX : longint;
       Flags, ES, DS, FS, GS, IP, CS, SP, SS : word;
     end;
{$endif} {$endif}
 {$i err.inc}

{$ifdef __GPC__}
	FUNCTION Exist (Filename : STRING):BOOLEAN;
{$endif}
	
{$ifdef havedosunit}
	FUNCTION Exist (Filename : STRING):BOOLEAN;
	function checkpath(var path:string):boolean;
{$endif}

{$ifdef realmode}
	FUNCTION GetLines: Word;
	PROCEDURE SetCursor(StartLine,EndLine: Byte);
	FUNCTION  GetCursor(Page: Byte): Word;   { High: Start  Low: End }
	FUNCTION  GetPage: Byte;
	procedure cursoroff;
{$endif}

{$ifndef linux}
function key:word;
procedure beep;
procedure writexyc(x,y,c1,c2:byte;s:string);
procedure writexy(x,y:byte;s:String);
procedure color(i,j:byte);
{$endif}
var vram:word;
function anzahl(haupt:string;se:string):byte;
function replace(haupt:string;se:string;er:string):string;
function hoch(a,b:integer):longint;
function getzeichen(x,y:integer):string;
function leer(x:integer):String;
function kill_last_space(a:string):string;
function zahl2string(I: Longint): String;
function zen(a:string;b:integer):string;
function up(a:string):string;
function z2s(I: Longint): String;
function z2s_nullen(I: Longint;j:longint): String;
function s2z(i:string):integer;
FUNCTION Hex2String(n: Byte): String;
function asc(i:byte;c:char):string;
function killspaceAE(t:String):string;
function find_last(s:String;c:char):byte;
function geterrortext(x:word):string;
function psearch(p:pchar;tosearch:pchar):pchar;
function psearchI(p:pchar;tosearch:pchar):pchar;


implementation

{$ifdef __GPC__}
FUNCTION Exist (Filename : STRING):BOOLEAN;
begin
 writeln('exist: Nicht implementiert');
 halt;
end;
{$endif}

{===========================================================================}
{===========================================================================}
{===========================================================================}
{===========================================================================}

{$ifdef havedosunit}
FUNCTION Exist (Filename : STRING):BOOLEAN;
var
 dir:searchrec;
 i:word;
BEGIN
   FindFirst(filename, anyfile, Dir);
   Exist := (doserror=0);
END;

function checkpath(var path:string):boolean;
var
 old:string;
 s:string;
begin
 if ioresult=0 then ;
 checkpath:=false;
 while (length(path)>0) and (path[length(path)]='\') do delete(path,length(path),1);
 {$i-}
 getdir(0,old);   if ioresult<>0 then exit;
 chdir(path);     if ioresult<>0 then exit;
 getdir(0,s);     if ioresult<>0 then exit;
 chdir(old);      if ioresult<>0 then exit;
 path:=s+'\';
 checkpath:=true;
 {$i+}
end;
{$endif}

{===========================================================================}
{===========================================================================}
{===========================================================================}
{===========================================================================}
{$ifdef realmode}
FUNCTION GetLines: Word;
type
 tbuf=array[0..63] of byte;
VAR
 buf: ^tbuf;
 r: Registers;
 {$ifdef ver70}{$ifdef dpmi}
 rr:dpmiregisters;
 result:byte;
 allocres:longint;
 {$endif}{$endif}
BEGIN
 getlines:=20;

 {$ifdef fpc}
 getlines:=25;
 exit;
 {$endif}

 {Borland-Pascal 7.0 Real-Mode}
 {$ifdef ver70}
 {$ifndef dpmi}
  getmem(buf,64);
  r.ax := $1b00;
  r.bx := 0;
  r.es := Seg(buf^);
  r.di := Ofs(buf^);
  Intr($10,r);
  IF r.al <> $1b THEN GetLines := 25
                 ELSE GetLines := Buf^[$22];
  freemem(buf,64);
  exit;
  {$endif}
  {$endif}

 {Borland-Pascal 7.0 DPMI-Mode}
 {$ifdef ver70}
 {$ifdef dpmi}
  fillchar(rr,sizeof(rr),0);
  AllocRes := GlobalDosAlloc(64);
  rr.eax := $1b00;
  rr.es:=AllocRes SHR 16;
  result:=realmodeint($10,rr);
  buf:=Ptr(AllocRes AND 65535,0);
  IF (result=0) and ( (rr.eax and $ff)=$1b ) then begin
    getlines := buf^[$22];
  end else begin
    getlines:=25;
  end;
  IF GlobalDosFree(AllocRes AND 65535) <> 0 THEN ;
  exit;
  {$endif}
  {$endif}
END;

procedure cursoroff;
var
a:Registers;
begin
 a.al:=15;
 a.ah:=0;
 intr($10,a);
end;

PROCEDURE SetCursor(StartLine,EndLine: Byte);
VAR r: Registers;
BEGIN
  r.ah := 1;
  r.ch := StartLine;
  r.cl := EndLine;
  Intr($10,r);
END;

FUNCTION GetCursor(Page: Byte): Word;   { High: Start  Low: End }
VAR r: Registers;
BEGIN
  getcursor:=0;
  r.ah := 3;
  r.bh := Page;
  Intr($10,r);
  GetCursor := 256*r.ch+r.cl;
END;

FUNCTION GetPage: Byte;
VAR r: Registers;
BEGIN
  getpage:=$ff;
  r.ah := $0f;
  Intr($10,r);
  GetPage := r.bh;
END;

{$endif}

{===========================================================================}
{===========================================================================}
{===========================================================================}
{===========================================================================}

{$ifndef linux}
procedure color(i,j:byte);
begin
 textcolor(i);
 textbackground(j);
end;
function key:word;
var
 ch:char;
begin
 ch:=readkey;
 if ch=#0 then begin
  key:=byte(readkey)*256;
 end else begin
  key:=byte(ch);
 end;
end;
procedure beep;
begin
 sound(220);
 delay(299);
 nosound;
end;
procedure writexyc(x,y,c1,c2:byte;s:string);
begin
 textcolor(c1);
 textbackground(c2);
 gotoxy(x,y);
 write(s);
end;
procedure writexy(x,y:byte;s:String);
begin
 gotoxy(x,y);
 write(s);
end;

{$endif}

function psearch(p:pchar;tosearch:pchar):pchar;
var
 i,j:longint;
 found:boolean;
begin
 i:=0;
 found:=false;
 while (p[i]<>#0) and (not found) do begin
    found:=true;
    for j:=0 to Strlen(tosearch)-1 do begin
       if p[i+j]<>tosearch[j] then begin found:=false; break; end;
    end;
    inc(i);
 end;
 if found then
  psearch:=@p[i-1]
 else
  psearch:=nil;
end;

function psearchI(p:pchar;tosearch:pchar):pchar;
var
 i,j:longint;
 found:boolean;
begin
 i:=0;
 found:=false;
 while (p[i]<>#0) and (not found) do begin
    found:=true;
    for j:=0 to Strlen(tosearch)-1 do begin
       if upcase(p[i+j])<>upcase(tosearch[j]) then begin found:=false; break; end;
    end;
    inc(i);
 end;
 if found then begin
  psearchi:=@p[i-1]
 end else begin
  psearchi:=nil;
 end; 
end;

function geterrortext(x:word):string;
var
 i:word;
begin
 for i:=low(errorcodes) to high(errorcodes) do begin
  if x=errorcodes[i].nr then begin
    geterrortext:=errorcodes[i].s; exit;
  end;
 end;
 geterrortext:='Error '+z2s(x);
end;

function find_last(s:String;c:char):byte;
var
 i:byte;
begin
 for i:=length(s) downto 1 do begin
   if s[i]=c then break;
 end;
 if i>1 then find_last:=i;
 if (i=1) and (s[i]=c) then find_last:=1;
 if (i=1) and (s[i]<>c) then find_last:=0;
end;
function killspaceAE(t:String):string;
var
 s:string;
begin
 s:=t;
 while (length(s)>0) and (s[1]=' ') do delete(s,1,1);
 while (length(s)>0) and (s[length(s)]=' ') do delete(s,length(s),1);
 killspaceae:=s;
end;



FUNCTION Hex2String(n: Byte): String;
  CONST hex: ARRAY[0..15] OF Char = '0123456789ABCDEF';
BEGIN
  Hex2String := hex[n SHR 4] + hex[n AND 15];
END;



{slow, but portable}
function asc(i:byte;c:char):string;
var
 s:string;
 j:byte;
begin
 s:='';
 for j:=1 to i do  s:=s+c;
 asc:=s;
end;


function zahl2string(I: Longint): String;
var
  S: string[11];
begin
  Str(I, S);
  zahl2string := S;
end;

function s2z(i:string):integer;
var
 tmp2,tmp:integer;
begin
 val(i,tmp2,tmp);
 s2z:=tmp2;
end;

function z2s_nullen(I: Longint;j:longint): String;
var
  S: string;
begin
  Str(I, S);
  while length(s)<j do s:='0'+s;
  z2s_nullen := S;
end;

function z2s(I: Longint): String;
var
  S: string;
begin
  s:='';
  Str(I, S);
  z2s := S;
end;



function up(a:string):string;
var
 tmp:string;
 i:integer;
begin
 tmp:='';
 for i:=1 to length(a) do tmp:=tmp+upcase(a[i]);
 up:=tmp;
end;

function zen(a:string;b:integer):string;
var
  i:integer;
begin
 i:=(b-length(a)) div 2;
 zen:=leer(i)+a;
end;


function getzeichen(x,y:integer):string;
begin
{getzeichen:=chr(mem[vram:((x-1)+((y-1)*80))*2]);}
getzeichen:='';
end;

function kill_last_space(a:string):string;
var i:integer;
begin
 i:=length(a)+1;
 repeat
  i:=i-1;
 until a[i]<>' ';
 kill_last_space:=copy(a,1,i);
end;

function leer(x:integer):String;
var
 a:string;
 i:integer;
begin
a:='';
for i:=1 to x do a:=a+' ';
leer:=a
end;

function anzahl(haupt:string;se:string):byte;
var
    b:byte;
    d:char;
begin
 b:=0;
 if se=' ' then d:='„' else d:=' ';
 while pos(se,haupt)>0 do begin
  haupt[pos(se,haupt)]:=d;
  b:=b+1;
 end;
 anzahl:=b
end;

function hoch(a,b:integer):longint;
var
 i,j:longint;
begin
 j:=1;
 if b>1 then j:=a;
 for i:=2 to b do j:=j*a;
 hoch:=J;
end;

function replace(haupt:string;se:string;er:string):string;
var i,j,k:integer;
begin
 j:=anzahl(haupt,se);
 for i:=1 to j do begin
   k:=pos(se,haupt);
   delete(haupt,k,length(se));
   insert(er,haupt,k);
 end;
 replace:=haupt;
end;


{$ifdef ver70}
{$ifdef dpmi}
function RealModeInt(int:word; regs:dpmiregisters): word; assembler;
asm
 push bp
 mov ax,$300
 les di, regs
 xor cx,cx
 mov bx,int
 int $31
 jc  @ende
 xor ax,ax
 @ende:
 pop bp
end;
{$endif}
{$endif}



end.
