unit gpcstrings;
{$x+}

interface

function Strlen(p:pchar):longint;
function Stricomp(a,b:pchar):longint;
procedure Strpcopy(Dest: PChar; Source: String);
function Strpas(Str: PChar):string;
function strscan(p:pchar;c:char):pchar;
function strrscan(p:pchar;c:char):pchar;
procedure strcopy(p:pchar;pp:pchar);
procedure strcat(p:pchar;pp:pchar);

implementation
procedure strcopy(p:pchar;pp:pchar);
begin
writeln('Strcopy Not supported'); halt;
end;
procedure strcat(p:pchar;pp:pchar);
begin
writeln('Strcat Not supported'); halt;
end;

function strrscan(p:pchar;c:char):pchar;
begin
writeln('Strrscan Not supported'); halt;
end;

function strscan(p:pchar;c:char):pchar;
begin
writeln('Strscan Not supported'); halt;
end;

function StrPas(Str: PChar):string;
var
 x:word;
 s:string;
begin
	if str=nil then begin strpas:=''; exit; end;
	x:=0;
 	s:='';
	while str[x]<>#0 do begin
		s:=s+str[x]; inc(x);
	end;
	strpas:=s;
end;

procedure StrPCopy(Dest: PChar; Source: String);
var
 i:word;
begin
 for i:=1 to length(source) do dest[i-1]:=source[i];
 dest[length(source)]:=#0;
end;

function Stricomp(a,b:pchar):longint;
begin
writeln('Stricomp Not supported'); halt;
stricomp:=0;
end;

function Strlen(p:pchar):longint;
var
	x:longint;
begin
x:=0;
while p[x]<>#0 do inc(x);
strlen:=x;
end;

end.
