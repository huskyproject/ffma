unit fparser;

 {

 }

interface
uses erweiter;

type
 pfparserknoten=^tfparserknoten;
 tfparserknoten=record
          ele:string;
          l,r:pfparserknoten;
         end;

procedure parser(var s:string;var x:pfparserknoten);
const
 Symbole:array[5..22] of string=('SUBJ','FROM','TO','BODY','ORIG','DEST','LEN','OZONE','ONET','ONODE','OPOINT','DZONE','DNET','DNODE','DPOINT','FLAG','KLUDGE','ANY');


implementation

const
 a_klammerauf=1; { ( }
 a_klammerzu=2;  { ) }
 a_not=3;        { not }
 a_and=4;        { and }
 a_or=5;         { or, xor }
 a_vergleich=6; { =,<,>,%}
 a_symbol=7;
 a_vergleichmit=8; { "..." }

function unescape(s:string):string;
type
	replacearray=array[1..2] of record 
									orig,repl:string 
								end;
const
	rep:replacearray=((orig:'\\';repl:'\'),(orig:'\1';repl:#1));
var
	i:integer;
	wert:word;
	position:word;
begin
	for i:=1 to high(rep) do begin
		while pos(rep[i].orig,s)>0 do begin
			position:=pos(rep[i].orig,s);
			delete(s,position,length(rep[i].orig));
			insert(rep[i].repl,s,position);
		end;
	end;
	for i:=1 to length(s)-3 do
	begin
		if (s[i]='\') and (s[i+1] in ['0'..'9']) and (s[i+2] in ['0'..'9']) and (s[i+3] in ['0'..'9']) then begin
			wert:=s2z(s[i+1]+s[i+2]+s[i+3]);
			delete(s,i,4);
			insert(char(wert),s,i);
		end;
	end;
	unescape:=s;
end;

function whatis(s:String):integer;
var
 i:word;
begin
 if s='(' then begin whatis:=a_klammerauf; exit; end;
 if s=')' then begin whatis:=a_klammerzu; exit; end;
 if s='-' then begin whatis:=a_not; exit; end;
 if s='&' then begin whatis:=a_and; exit; end;
 if s='|' then begin whatis:=a_or; exit; end;
 if (s='=') or (s='<') or (s='>') or (s='%') then begin whatis:=a_vergleich; exit; end;
 if (s[1]='"') and (s[length(s)]='"') then begin whatis:=a_vergleichmit; exit; end;
 for i:=low(symbole) to high(symbole) do if symbole[i]=Up(s) then begin whatis:=a_symbol; exit; end;
 writeln('ParserError (WHATIS): ',s); whatis:=0;
end;

function nextklammer(var s:String):String;
var
 level,i:word;
begin
 level:=1;
 for i:=1 to length(s) do begin
  if s[i]='(' then inc(level);
  if s[i]=')' then dec(level);
  if level=0 then begin
   nextklammer:=copy(s,1,i-1);
   delete(s,1,i);
   exit;
  end;
 end;
 writeln('PaserError Klammerebenen falsch'); nextklammer:='';
end;

function getobj(var s:String):string;
var
 t:String;
 i:word;
begin
 s:=killspaceae(s);
 if length(s)=0 then begin getobj:=''; exit; end;
 if s[1] in ['(',')','&','|','=','<','>','%'] then begin
  getobj:=s[1];
  delete(s,1,1);
  s:=killspaceae(s);
  exit;
 end;
 if s[1]='"' then begin
   t:='"';
   delete(s,1,1);
   if pos('"',s)=0 then begin writeln('ParserError (" missing) ',s); getobj:=''; exit; end;
   t:=t+copy(s,1,pos('"',s));
   delete(s,1,pos('"',s));
   getobj:=t;
   s:=killspaceae(s);
   exit;
 end;
 for i:=low(symbole) to high(symbole) do begin
    if symbole[i]=Up(copy(s,1,length(symbole[i]))) then begin
       getobj:=symbole[i];
       delete(s,1,length(symbole[i]));
       s:=killspaceae(s);
       exit;
    end;
 end;
 writeln('ParserError (getobj)',s); getobj:='';
end;

procedure parser(var s:string;var x:pfparserknoten);
var
 t:string;
 y:pfparserknoten;
begin
 s:=killspaceae(s);
 new(x);
 fillchar(x^,sizeof(x^),0);
 while s<>'' do begin
    t:=getobj(s);
    if t='' then begin x:=nil; halt; end; {evtl. exit}
    case whatis(t) of
      0:begin x:=nil; exit; end;
      a_klammerauf:begin
                     t:=nextklammer(s);
                     if t='' then begin x:=nil; exit; end;
                     if (x^.ele='') and (x^.r=nil) and (x^.l=nil) then begin
                       dispose(x); x:=nil;
                       parser(t,x); if x=nil then begin x:=nil; exit; end;
                     end else begin
                       parser(t,x^.l); if x=nil then begin x:=nil; exit; end;
                     end;
                  end;
      a_not,a_and,
      a_or,a_vergleich:begin
                       if not (
                         (x^.l<>nil) and (x^.r=nil) and (x^.ele='') or
                         (x^.l<>nil) and (x^.r<>nil) and (x^.ele<>'')
                         ) then begin
                        writeln('ParserError (CASE 1)'); x:=nil; exit;
                       end;
                       if x^.r<>nil then begin
                        new(y); fillchar(y^,sizeof(y^),0);
                        y^.l:=x;
                        x:=y;
                        x^.ele:=up(t);
                        parser(s,x^.r); if x=nil then begin x:=nil; exit; end;
                       end;
                       x^.ele:=up(t);
                     end;
      a_symbol,
      a_vergleichmit:begin
						t:=unescape(t);
                       if not (
                          ((x^.ele='') and (x^.l=nil) and (x^.r=nil)) or
                          ((x^.ele<>'') and (x^.l<>nil) and (x^.r=nil)) or
                          ((x^.ele<>'') and (x^.l<>nil) and (x^.r<>nil))
                       ) then begin
                         writeln('ParserError (CASE 2)'); x:=nil; exit;
                         end;
                       if (x^.ele='') and (x^.l=nil) and (x^.r=nil) then begin
                         new(x^.l);
                         fillchar(x^.l^,sizeof(x^.l^),0);
                         x^.l^.ele:=t;
                         continue;
                       end;
                       if (x^.ele<>'') and (x^.l<>nil) and (x^.r=nil) then begin
                         new(x^.r);
                         fillchar(x^.r^,sizeof(x^.r^),0);
                         x^.r^.ele:=t;
                         continue;
                       end;
                       if (x^.ele<>'') and (x^.l<>nil) and (x^.r=nil) then begin
                         new(y); fillchar(y^,sizeof(y^),0);
                         y^.l:=x;
                         x:=y;
                         continue;
                       end;
                       writeln('ParserError (CASE 3)');  x:=nil; exit;
                     end;
      else begin
        writeln('ParserError in Case');   x:=nil; exit;
      end;
    end;
 end;
end;

procedure show(x:pfparserknoten);
begin
{ if x=nil then exit;
   gotoxy(wherex,wherey+1);
   show(x^.l);
   write(x^.ele);
   show(x^.r);
   gotoxy(wherex,wherey-1);}
end;

end.