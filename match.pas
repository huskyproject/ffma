unit match;

interface

{$ifdef __GPC__}
{$x+}
	uses fparser,gpcsmapi,erweiter,utils,memman,gpcstrings;
{$endif}

{$ifdef fpc}
	{$ifdef linux}
	uses fparser,smapi,erweiter,utils,memman,strings,log;
	{$endif}
{$endif}

function match_(var area:pharea;var msg:phmsg;var xmsg:pxmsg;x: pfparserknoten):boolean;

implementation

type
 matchfkt=function(var area:pharea;var msg:phmsg;var xmsg:pxmsg;x:pfparserknoten):boolean;

function mstr(var area:pharea;var msg:phmsg;var xmsg:pxmsg;x:pfparserknoten):boolean;forward;
function mflag(var area:pharea;var msg:phmsg;var xmsg:pxmsg;x:pfparserknoten):boolean;forward;
function mbody(var area:pharea;var msg:phmsg;var xmsg:pxmsg;x:pfparserknoten):boolean;forward;
function mkludge(var area:pharea;var msg:phmsg;var xmsg:pxmsg;x:pfparserknoten):boolean;forward;
function mzahl(var area:pharea;var msg:phmsg;var xmsg:pxmsg;x:pfparserknoten):boolean;forward;
function maddr(var area:pharea;var msg:phmsg;var xmsg:pxmsg;x:pfparserknoten):boolean;forward;

const
	{$ifdef __GPC__}
{                                **************STATIC TEXT********************************************************************
                                   SUB         TO         Orig        LEN    **********ORIG******** **********DEST********
        Str  Zahl   ADDR  FLAGS        FROM         Body       Dest         Zone  NET  NODE   PONT Zone  NET  NODE   PONT   Flag                                       }
 m:array[0..21,0..21] of matchfkt=
 ( 
 (matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,  matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil),matchfkt(nil) ),
 (matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,  mstr ,mstr ,mstr ,mbody,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil),matchfkt(nil) ), {String}
 (matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,  matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,matchfkt(nil),matchfkt(nil)), {Zahl}
 (matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,  matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,maddr,maddr,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,mflag,matchfkt(nil)), {ADDR}
 (matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,  matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,mbody,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil),matchfkt(nil) ,matchfkt(nil)), {Flags}

 (matchfkt(nil) ,mstr ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,  matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil),matchfkt(nil)), {SUBJ}
 (matchfkt(nil) ,mstr ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,  matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil),matchfkt(nil)), {FROM}
 (matchfkt(nil) ,mstr ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,  matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil),matchfkt(nil)), {TO}
 (matchfkt(nil) ,mbody,matchfkt(nil) ,matchfkt(nil) ,mbody,  matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil),matchfkt(nil)), {BODY}
 (matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,maddr,matchfkt(nil) ,  matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,maddr,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil),matchfkt(nil)), {ORIG}

 (matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,maddr,matchfkt(nil) ,  matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,maddr,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil),matchfkt(nil)), {DEST}
 (matchfkt(nil) ,matchfkt(nil) ,mzahl,matchfkt(nil) ,matchfkt(nil) ,  matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil),matchfkt(nil)),  {LEN}
 (matchfkt(nil) ,matchfkt(nil) ,mzahl,matchfkt(nil) ,matchfkt(nil) ,  matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,matchfkt(nil),matchfkt(nil)), {OZONE}
 (matchfkt(nil) ,matchfkt(nil) ,mzahl,matchfkt(nil) ,matchfkt(nil) ,  matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,matchfkt(nil),matchfkt(nil)), {ONET}
 (matchfkt(nil) ,matchfkt(nil) ,mzahl,matchfkt(nil) ,matchfkt(nil) ,  matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,matchfkt(nil),matchfkt(nil)), {ONODE}

 (matchfkt(nil) ,matchfkt(nil) ,mzahl,matchfkt(nil) ,matchfkt(nil) ,  matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,matchfkt(nil),matchfkt(nil)), {OZONE}
 (matchfkt(nil) ,matchfkt(nil) ,mzahl,matchfkt(nil) ,matchfkt(nil) ,  matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,matchfkt(nil),matchfkt(nil)), {DZONE}
 (matchfkt(nil) ,matchfkt(nil) ,mzahl,matchfkt(nil) ,matchfkt(nil) ,  matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,matchfkt(nil),matchfkt(nil)), {DNET}
 (matchfkt(nil) ,matchfkt(nil) ,mzahl,matchfkt(nil) ,matchfkt(nil) ,  matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,matchfkt(nil),matchfkt(nil)), {DNODE}
 (matchfkt(nil) ,matchfkt(nil) ,mzahl,matchfkt(nil) ,matchfkt(nil) ,  matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,matchfkt(nil),matchfkt(nil)), {DZONE}

 (matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,mflag  ,  matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil),matchfkt(nil)),  {Flag }
 (matchfkt(nil) ,mkludge , matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil)  ,  matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) , matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil) ,matchfkt(nil),matchfkt(nil))  {Flag }
);
	{$else}
{                                **************STATIC TEXT********************************************************************
                                   SUB         TO         Orig        LEN    **********ORIG******** **********DEST********
 Str   Zahl ADDR FLAGS        FROM         Body       Dest         Zone  NET  NODE   PONT Zone  NET  NODE   PONT   Flag                                       }
 m:array[0..21,0..21] of matchfkt=
 ( 
 (nil ,nil ,nil ,nil ,nil ,  nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil, nil ),
 (nil ,nil ,nil ,nil ,nil ,  mstr ,mstr ,mstr ,mbody,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil , nil ), {String}
 (nil ,nil ,nil ,nil ,nil ,  nil ,nil ,nil ,nil ,nil ,nil ,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,nil, nil ), {Zahl}
 (nil ,nil ,nil ,nil ,nil ,  nil ,nil ,nil ,nil ,maddr,maddr,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,mflag, nil ), {ADDR}
 (nil ,nil ,nil ,nil ,nil ,  nil ,nil ,nil ,mbody,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil, nil ), {Flags}

 (nil ,mstr ,nil ,nil ,nil ,  nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil, mkludge ), {SUBJ}
 (nil ,mstr ,nil ,nil ,nil ,  nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil, nil ), {FROM}
 (nil ,mstr ,nil ,nil ,nil ,  nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil, nil ), {TO}
 (nil ,mbody,nil ,nil ,mbody,  nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil, nil ), {BODY}
 (nil ,nil ,nil ,maddr,nil ,  nil ,nil ,nil ,nil ,nil ,maddr,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil, nil ), {ORIG}

 (nil ,nil ,nil ,maddr,nil ,  nil ,nil ,nil ,nil ,maddr,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil, nil ), {DEST}
 (nil ,nil ,mzahl,nil ,nil ,  nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil, nil ),  {LEN}
 (nil ,nil ,mzahl,nil ,nil ,  nil ,nil ,nil ,nil ,nil ,nil ,nil ,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,nil, nil ), {OZONE}
 (nil ,nil ,mzahl,nil ,nil ,  nil ,nil ,nil ,nil ,nil ,nil ,nil ,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,nil, nil ), {ONET}
 (nil ,nil ,mzahl,nil ,nil ,  nil ,nil ,nil ,nil ,nil ,nil ,nil ,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,nil, nil ), {ONODE}

 (nil ,nil ,mzahl,nil ,nil ,  nil ,nil ,nil ,nil ,nil ,nil ,nil ,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,nil, nil ), {OZONE}
 (nil ,nil ,mzahl,nil ,nil ,  nil ,nil ,nil ,nil ,nil ,nil ,nil ,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,nil, nil ), {DZONE}
 (nil ,nil ,mzahl,nil ,nil ,  nil ,nil ,nil ,nil ,nil ,nil ,nil ,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,nil, nil ), {DNET}
 (nil ,nil ,mzahl,nil ,nil ,  nil ,nil ,nil ,nil ,nil ,nil ,nil ,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,nil, nil ), {DNODE}
 (nil ,nil ,mzahl,nil ,nil ,  nil ,nil ,nil ,nil ,nil ,nil ,nil ,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,mzahl,nil, nil ), {DZONE}

 (nil ,nil ,nil ,nil ,mflag  ,  nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil, nil),  {Flag }
 (nil ,mkludge ,nil ,nil ,nil  ,  nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil ,nil, nil)  {Flag }
);
	{$endif}
 flags:array[1..12] of record s:String; x:word; end=
  ((s:'PRIVATE';x:1),
   (s:'CRASH';x:$2),
   (s:'READ';x:$4),
   (s:'SENT';x:$8),
   (s:'FILE';x:$10),
   (s:'FWD';x:$20),
   (s:'ORPHAN';x:$40),
   (s:'KILL';x:$80),
   (s:'LOCAL';x:$100),
   (s:'HOLD';x:$200),
   (s:'FRQ';x:$800),
   (s:'URQ';x:$8000)
   );
function getflag(s:string):word;
var
 i:word;
begin
 getflag:=0;
 for i:=low(flags) to high(flags) do begin
   if flags[i].s=up(s) then getflag:=flags[i].x;
 end;
end;

function get(s:String;area:pharea;msg:phmsg;xmsg:pxmsg;x:pfparserknoten):string;
var
 d:netaddr;
begin
  if (s[1]='"') and (s[length(s)]='"') then begin
   delete(s,1,1); delete(s,length(s),1);
   get:=s; exit;
  end;
  if s='SUBJ' then begin get:=array2string(xmsg^.subj,72); exit; end;
  if s='FROM' then begin get:=array2string(xmsg^.fromname,36); exit; end;
  if s='TO' then begin get:=array2string(xmsg^.toname,36); exit; end;
  if s='DEST' then begin get:=showaddr(xmsg^.dest); exit; end;
  if s='ORIG' then begin get:=showaddr(xmsg^.orig); exit; end;
  if s='LEN' then begin get:=z2s(area^.f^.GetTextLen(msg)); exit; end;

  if S='OZONE' then begin get:=z2s(xmsg^.orig.zone); exit; end;
  if S='ONODE' then begin get:=z2s(xmsg^.orig.node); exit; end;
  if S='ONET' then begin get:=z2s(xmsg^.orig.net); exit; end;
  if S='OPOINT' then begin get:=z2s(xmsg^.orig.point); exit; end;
  if S='DZONE' then begin get:=z2s(xmsg^.dest.zone); exit; end;
  if S='DNODE' then begin get:=z2s(xmsg^.dest.node); exit; end;
  if S='DNET' then begin get:=z2s(xmsg^.dest.net); exit; end;
  if S='DPOINT' then begin get:=z2s(xmsg^.dest.point); exit; end;
  writeln('MatchError: ',s); halt;
end;

function id(s:String):word;
var
 i:word;
 x:longint;
 a:netaddr;
begin
  if (s[1]='"') and (s[length(s)]='"') then begin
   delete(s,1,1); delete(s,length(s),1);
   val(s,x,i);
   if i=0 then begin id:=2; exit; end;
   if string2addr(s,a) then begin id:=3; exit; end;
   if getflag(s)>0 then begin id:=4; exit; end;
   id:=1;
   exit;
  end;
  for i:=low(symbole) to high(symbole) do begin
   if s=symbole[i] then begin id:=i; exit; end;
  end;
  writeln('Can not handle: ',s); halt;
end;

function mflag(var area:pharea;var msg:phmsg;var xmsg:pxmsg;x:pfparserknoten):boolean;
var
 not_:boolean;
 fl:word;
 att:longint;
 myflag:longint;
begin
 mflag:=false;
 if not (x^.ele[1] in ['=','%']) then begin
  writeln('Error: ',x^.ele,' not supported in flag-statment'); halt;
 end;
 att:=xmsg^.attr;
 if up(x^.l^.ele)='FLAG' then begin
  myflag:=getflag(get(x^.r^.ele,area,msg,xmsg,x));
 end else begin
  myflag:=getflag(get(x^.l^.ele,area,msg,xmsg,x));
 end;
 if x^.ele='=' then mflag:=(att and myflag)<>0;
 if x^.ele='%' then mflag:=(att and myflag)=0;
end;

function mbody(var area:pharea;var msg:phmsg;var xmsg:pxmsg;x:pfparserknoten):boolean;
var
 s:string;
 not_:boolean;
 i,textsize:longint;
 ppp,p,pp:pchar;
 b:boolean;
begin	
 not_:=false;
 if x^.ele<>'=' then begin
  writeln('Error: ',x^.ele,' not supported in body-statment'); halt;
 end;
 if x^.r^.ele='BODY' then begin
    s:=get(x^.l^.ele,area,msg,xmsg,x);
 end else begin
    s:=get(x^.r^.ele,area,msg,xmsg,x);
 end;
 if (length(s)>0) and (s[1]='!') then begin not_:=true; delete(s,1,1); end;
 if (length(s)>0) and (s[1]='~') then begin writeln('~ not neccessary in body-statment'); delete(s,1,1); end;
 textsize:=area^.f^.GetTextLen(msg);
 if textsize=0 then begin mbody:=false; exit; end;

 p:=getmemory(textsize+1);
 area^.f^.ReadMsg(msg,xmsg,0,textsize,p,0,nil);
 p[textsize]:=#0;

 pp:=getmemory(length(s)+1);
 strpcopy(pp,s);

 b:=psearchi(p,pp)<>nil;
 if not_ then b:=not b;
 mbody:=b;
 freememory(p,true);
 freememory(pp,true);
end;

function mkludge(var area:pharea;var msg:phmsg;var xmsg:pxmsg;x:pfparserknoten):boolean;
var
	s:string;
	not_:boolean;
	i,ctrlsize:longint;
	ppp,p,pp:pchar;
	b:boolean;
	F:file;
begin	
	not_:=false;
	if x^.ele<>'=' then begin
		writeln('Error: ',x^.ele,' not supported in kludge-statment'); halt;
	end;
	if x^.r^.ele='KLUDGE' then begin
		s:=get(x^.l^.ele,area,msg,xmsg,x);
	end else begin
		s:=get(x^.r^.ele,area,msg,xmsg,x);
	end;
	if (length(s)>0) and (s[1]='!') then begin not_:=true; delete(s,1,1); end;
	if (length(s)>0) and (s[1]='~') then begin writeln('~ not neccessary in kludge-statment'); delete(s,1,1); end;
	ctrlsize:=area^.f^.GetCtrlLen(msg);
	if ctrlsize=0 then begin mkludge:=false; exit; end;

	p:=getmemory(ctrlsize+1);
	area^.f^.ReadMsg(msg,xmsg,0,0,nil,ctrlsize,p);
	p[ctrlsize]:=#0;

	pp:=getmemory(length(s)+1);
	strpcopy(pp,s);

	b:=psearchi(p,pp)<>nil;
	if not_ then b:=not b;
	mkludge:=b;
	freememory(p,true);
	freememory(pp,true);
end;

function maddr(var area:pharea;var msg:phmsg;var xmsg:pxmsg;x:pfparserknoten):boolean;
var
 s,t:string;
 b:boolean;
 a:netaddr;
begin
 if not (x^.ele[1] in ['=','%']) then begin
  writeln('Error: ',x^.ele,' not supported in ORIG or DEST statment'); halt;
 end;
 s:=up(get(x^.l^.ele,area,msg,xmsg,x));
 string2addr(s,a); s:=showaddr(a);
 t:=up(get(x^.r^.ele,area,msg,xmsg,x));
 string2addr(t,a); t:=showaddr(a);
 case x^.ele[1] of
  '=':b:=s=t;
  '%':b:=s<>t;
 end;
 maddr:=b;
end;

function mzahl(var area:pharea;var msg:phmsg;var xmsg:pxmsg;x:pfparserknoten):boolean;
var
 s,t:string;
 b:boolean;
begin
 s:=up(get(x^.l^.ele,area,msg,xmsg,x));
 t:=up(get(x^.r^.ele,area,msg,xmsg,x));
 case x^.ele[1] of
  '=':b:=s2z(s)=s2z(t);
  '<':b:=s2z(s)<s2z(t);
  '>':b:=s2z(s)>s2z(t);
  '%':b:=s2z(s)<>s2z(t);
 end;
 mzahl:=b;
end;

function mstr(var area:pharea;var msg:phmsg;var xmsg:pxmsg;x:pfparserknoten):boolean;
var
 s,t:string;
 sub_,not_:boolean;
 b,lsub,rsub:boolean;
begin
 s:=up(get(x^.l^.ele,area,msg,xmsg,x));
 t:=up(get(x^.r^.ele,area,msg,xmsg,x));
 sub_:=false; not_:=false; lsub:=false; rsub:=false;
 if (length(s)>0) and (s[1]='!') then begin not_:=true; delete(s,1,1); end;
 if (length(s)>0) and (s[1]='~') then begin sub_:=true; lsub:=true; delete(s,1,1); end;
 if (length(t)>0) and (t[1]='!') then begin not_:=true; delete(t,1,1); end;
 if (length(t)>0) and (t[1]='~') then begin sub_:=true; rsub:=true; delete(t,1,1); end;
 if ((x^.ele[1] in ['<','>']) and sub_) or (rsub and lsub) then begin
   writeln('Error: '+x^.l^.ele+x^.ele+x^.r^.ele); halt
 end;
 if ((x^.ele[1] in ['<','>','%']) and sub_) or (rsub and lsub) then begin
   writeln('Error: '+x^.l^.ele+x^.ele+x^.r^.ele); halt
 end;
 b:=false;
 case x^.ele[1] of
 '<':b:=s<t;
 '>':b:=s>t;
 '%':b:=s<>t;
 '=':if sub_ then begin
         if lsub then begin
            b:=pos(s,t)>0;
         end else begin
            b:=pos(t,s)>0;
         end;
     end else begin
       b:=s=t;
     end;
 end;
 if not_ then b:=not b;
 mstr:=b;
end;


function match_(var area:pharea;var msg:phmsg;var xmsg:pxmsg;x:pfparserknoten):boolean;
var
 p:pointer;
 c,b:boolean;
begin
 match_:=false;
 if x=nil then begin
	writeln('ERROR: x=nil in match_');
	halt;
 end;
 if x^.ele[1] in ['|','&'] then begin
    b:=match_(area,msg,xmsg,x^.l);
    c:=match_(area,msg,xmsg,x^.r);
    case x^.ele[1] of
       '|':match_:=c or b;
       '&':match_:=c and b;
       else begin
         writeln('Error: '+x^.l^.ele+x^.ele+x^.r^.ele); halt;
      end;
    end;
    exit;
 end;
 if not assigned(m[id(x^.l^.ele),id(x^.r^.ele)]) then begin
    writeln('Can not handle ('+z2s(id(x^.l^.ele))+':'+z2s(id(x^.r^.ele))+'): '+x^.l^.ele+x^.ele+x^.r^.ele); halt;
 end else begin
   match_:=m[id(x^.l^.ele),id(x^.r^.ele)](area,msg,xmsg,x);
 end;
end;

end.
