unit memman;

interface

function getmemory(size:longint):pointer;
procedure freememory(p:pointer);
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
 getmem(p,size);
 new(x);
 x^.p:=p;
 x^.size:=size;
 x^.next:=l;
 l:=x;
 getmemory:=p;
end;

procedure shownotfree;
var
 x:pliste;
 ll:longint;
begin
 x:=l;
 ll:=0;
 while x<>nil do begin
  writeln('Not free',x^.size);
  inc(ll,x^.size);
  x:=x^.next;
 end;
 if ll<>0 then writeln('Together: ',ll);
end;

procedure freememory(p:pointer);
var
 x:pliste;
 t:pliste;
begin
 if l=nil then exit;
 if l^.p=p then begin
   freemem(p,l^.size);
   x:=l;
   l:=l^.next;
   dispose(x);
   exit;
 end;
 x:=l;
 while x^.next<>Nil do begin
  if x^.next^.p=p then begin
    freemem(p,x^.next^.size);
    t:=x^.next;
    x^.next:=x^.next^.next;
    dispose(t);
    exit;
  end;
  x:=x^.next;
 end;
 writeln('FREEMEMORY: NOT FOUND');
end;

begin
 l:=nil;
end.
