unit memman;

interface

function getmemory(size:longint):pointer;
procedure freememory(var p:pointer;doit:boolean);
procedure shownotfree;

implementation
type
 pliste=^tliste;
 tliste=record
          p:pointer;
          size:longint;
          next:pliste;
        end;
var
 l:pliste;

function getmemory(size:longint):pointer;
var
 p:pointer;
 x:pliste;
begin
 if size<1 then begin writeln('Getmemory Size: ',size); end;
 getmem(p,size);
 new(x);
 if p=nil then begin writeln('Getmem failed!'); halt; end;
 if x=nil then begin writeln('new(x) in getmemory failed!'); halt; end;
 x^.p:=p;
 x^.size:=size;
 x^.next:=l^.next;

 l^.next:=x;
 getmemory:=p;
end;

procedure shownotfree;
var
 x:pliste;
 ll:longint;
begin
 x:=l^.next;
 ll:=0;
 while x<>nil do begin
  writeln('Not free',x^.size);
  inc(ll,x^.size);
  x:=x^.next;
 end;
 if ll<>0 then writeln('Together: ',ll);
end;

procedure freememory(var p:pointer;doit:boolean);
var
 x,y:pliste;
 t:pliste;
begin
 if p=nil then begin writeln('FREEMEMORY: NOT FOUND (NIL)'); exit; end;
 x:=l^.next;
 y:=l;
 while x<>Nil do begin
  if x^.p=p then begin
	if doit then begin
{			fillchar(p^,x^.size,0)}
			freemem(p,x^.size);
	end;
	y^.next:=x^.next;
    dispose(x);
	p:=nil;
    exit;
  end;
  x:=x^.next;
  y:=y^.next;
 end;
 writeln('FREEMEMORY: NOT FOUND');
end;

var
 x:pliste;
begin
 new(x);
 x^.size:=999999999;
 x^.p:=nil;
 x^.next:=nil;
 l:=x;
end.
