unit ini;
{$i-}


interface

{$ifdef __GPC__}
{$x+}
	uses fparser,utils,erweiter,gpcstrings,log,gpcsmapi,memman,fconf,fidoconf2;
{$endif}

{$ifdef fpc}
	{$ifdef linux}
	uses fparser,utils,erweiter,strings,log,smapi,memman,fconf,fidoconf2;
	{$define havedosunit}
	{$endif}
{$endif}



procedure readini(filename:string;fc:ps_fidoconfig);

type
 paction=^taction;
 pliste=^tliste;
 pmask=^tmask;
 tmask=record
         maskname:string[50];
         search: pfparserknoten;
         action:paction;
		 hits:longint;
         next:pmask;
       end;
 taction=record
          action:byte;
          spe:word;
          msgbase:pchar;
          addr:netaddr;
          filename:string;
          seenby:string;
          dostat:pmask;
          str:String;
          next:paction;
         end;
 tliste=record
         msgbase:pchar;
         mask:pmask;
         next:pliste;
        end;
 type
  tparafkt=function(s:string;x:paction;y:ps_fidoconfig):boolean;
  tini_=record a:word; s:string; need:word; can:word; end;
  tpara_=record p:tparafkt; s:string; v:word; end;
  tspe_=record a:word; v:word; s:string; para:word; end;


const
 actionCOPY_=1;
 actionREWRITE_=2;
 actionMOVE_=3;
 actionDEL_=4;
 actionECHOCOPY_=5;
 actionECHOMOVE_=6;
 actionEXPORTMSG_=7;
 actionEXPORTHEADER_=8;
 actionSEMAPHORE_=9;
 actionBounce_=10;
 actionwritetofile_=11;

{actionBounce}
 actionBounceFullMessage=1;
 {actionRewrite}
 actionRewriteSubj=1;
 actionRewriteFromName=2;
 actionRewriteToName=3;
 actionRewriteFromAddr=4;
 actionRewriteToAddr=5;


 needfile=1;
 needmb=2;
 needaddr=4;
 needseenby=8;
 needdo=16;
 needtext=32;

 paranone=1;
 paraaddr=2;
 parastring=3;

const
 liste:pliste=nil;



implementation
function dostatment(s:string;p:paction;fc:ps_fidoconfig):boolean;forward;
function msgbase(s:string;p:paction;fc:ps_fidoconfig):boolean;forward;
function addr(s:string;p:paction;fc:ps_fidoconfig):boolean;forward;
function testfile(s:string;p:paction;fc:ps_fidoconfig):boolean;forward;
function seenby(s:string;p:paction;fc:ps_fidoconfig):boolean;forward;
function textstatment(s:string;p:paction;fc:ps_fidoconfig):boolean;forward;

const
  spe_:array[1..6] of tspe_=(
     (a:actionbounce_;v:actionBounceFullMessage;s:'FULLMSG';para:paranone),
     (a:actionrewrite_;v:actionrewritesubj;s:'SUBJ=';para:parastring),
     (a:actionrewrite_;v:actionrewritefromname;s:'FROM=';para:parastring),
     (a:actionrewrite_;v:actionrewritetoname;s:'TO=';para:parastring),
     (a:actionrewrite_;v:actionrewritefromaddr;s:'ORIG=';para:paraaddr),
     (a:actionrewrite_;v:actionrewritetoaddr;s:'DEST=';para:paraaddr)
  );

  ini_:array[1..11] of tini_=(
   (a:actionECHOCOPY_;s:'ECHOCOPY';need:needmb+needaddr+needseenby;can:needdo),
   (a:actionECHOMOVE_;s:'ECHOMOVE';need:needmb+needaddr+needseenby;can:needdo),
   (a:actionBounce_;s:'BOUNCE';need:needfile+needaddr;can:needdo+needmb),
   (a:actionMove_;s:'MOVE';need:needmb;can:needdo),
   (a:actioncopy_;s:'COPY';need:needmb;can:needdo),
   (a:actionexportheader_;s:'EXPORTHEADER';need:needfile;can:0),
   (a:actionexportmsg_;s:'EXPORTMSG';need:needfile;can:0),
   (a:actiondel_;s:'DEL';need:0;can:0),
   (a:actionSEMAPHORE_;s:'SEMAPHORE';need:needfile;can:0),
   (a:actionREWRITE_;s:'REWRITE';need:0;can:0),
   (a:actionwritetofile_;s:'WRITETOFILE';need:needfile+needtext;can:0)
  );
  para_:array[1..6] of tpara_=(
    (p:testfile;s:'F:';v:needfile),
    (p:Msgbase;s:'MB:';v:needmb),
    (p:addr;s:'ADDR:';v:needaddr),
    (p:seenby;s:'SEENBY:';v:needseenby),
    (p:dostatment;s:'DO:';v:needdo),
    (p:textstatment;s:'TEXT:';v:needtext)
  );
type
 stringarray=array[1..20] of string;

procedure actionInsert(var a:paction;ins:paction);
var
 b:paction;
begin
  if a=nil then begin
     a:=ins;
  end else begin
     actionInsert(a^.next,ins);
  end;
end;

function findmask(x:String;p:pliste):pmask;
var
 s:pliste;
 t:pmask;
begin
 x:=up(x);
 s:=p;
 findmask:=nil;
 while s<>nil do begin
    t:=s^.mask;
    while t<>nil do begin
     if x=up(t^.maskname) then begin findmask:=t; exit; end;
     t:=t^.next;
    end;
    s:=s^.next;
 end;
end;

procedure maskinsert(fc:ps_fidoconfig;m:pmask;msgbase:string;var p:pliste);
var
 l:pliste;
 n:pliste;
 pm:pmask;
begin
 new(n);
 getmem(n^.msgbase,length(msgbase)+1);
 strpCopy(n^.msgbase,msgbase);
 if (msgbase<>'') and (getareaimp(fc,n^.msgbase)=nil) then begin logit(9,'Msgbase "'+msgbase+'" not found!'); halt; end;
 n^.mask:=m;
 n^.next:=nil;
 if p=nil then begin
  p:=n;
  exit;
 end;
 l:=p;
 while l^.next<>nil do l:=l^.next;
 if strpas(l^.msgbase)=msgbase then begin
   pm:=l^.mask;
   while pm^.next<>nil do pm:=pm^.next;
   pm^.next:=m;
 end else begin
   l^.next:=n;
 end;
end;

function seenby(s:string;p:paction;fc:ps_fidoconfig):boolean;
begin
 seenby:=true;
 p^.seenby:=copy(s,8,255);
end;

function textstatment(s:string;p:paction;fc:ps_fidoconfig):boolean;
begin
 textstatment:=true;
 p^.str:=copy(s,6,255);
end;

function dostatment(s:string;p:paction;fc:ps_fidoconfig):boolean;
begin
 p^.dostat:=findmask(copy(s,4,255),liste);
 dostatment:=p^.dostat<>nil;
end;

function testfile(s:string;p:paction;fc:ps_fidoconfig):boolean;
begin
 testfile:=true;
 p^.filename:=copy(s,3,255);
end;

function msgbase(s:string;p:paction;fc:ps_fidoconfig):boolean;
var
 area:ps_area;
begin
 getmem(p^.msgbase,length(copy(s,4,255))+1);
 StrPCopy(p^.msgbase,copy(s,4,255));
 area:=getareaimp(fc,p^.msgbase);
 if area=nil then begin
 	writeln('Msgbase "',p^.msgbase,'" not found');
 	halt;  
 end;
 msgbase:=true;
end;

function addr(s:string;p:paction;fc:ps_fidoconfig):boolean;
begin
 addr:=string2addr(copy(s,6,255),p^.addr);
end;


procedure split(s:String;var x:Stringarray);
var
 i:byte;
 a,b:integer;
 t:string;
begin
  t:=s;
  fillchar(x,sizeof(x),0);
  for i:=1 to 20 do begin
    s:=killspaceae(s)+' ';
    a:=pos(' ',s)-1; if a=-1 then a:=30000;
    b:=pos('"',s)-1; if b=-1 then b:=30000;
    if a<b then begin
      x[i]:=copy(s,1,pos(' ',s)-1);
      delete(s,1,pos(' ',s));
    end else begin
      x[i]:=copy(s,1,pos('"',s));
      delete(s,1,pos('"',s));
      if (pos('"',s)=0) then begin writeln(t); writeln('" missing'); halt; end;
      x[i]:=x[i]+copy(s,1,pos('"',s));
      delete(s,1,pos('"',s));
   end;
  end;
end;

function foundaction(s:string):word;
var
 i:word;
begin
 s:=up(s);
 for i:=low(ini_) to high(ini_) do begin
   if ini_[i].s=s then begin foundaction:=i; exit; end;
 end;
 foundaction:=0;
end;

function foundspe(var x:word;s:string;var a:paction):boolean;
var
 i,j:word;

begin
 for i:=low(spe_) to high(spe_) do begin
   if spe_[i].a<>ini_[x].a then continue;
   if up(copy(s,1,length(spe_[i].s)))=spe_[i].s then begin
     delete(s,1,length(spe_[i].s));
     a^.spe:=a^.spe or spe_[i].v;
     case spe_[i].para of
     parastring:begin a^.str:=s;  foundspe:=true; exit; end;
     paranone:begin foundspe:=true; exit; end;
     paraaddr:begin foundspe:=string2addr(s,a^.addr); exit; end;
     end
   end;
 end;
 foundspe:=false;
end;

function foundpara(s:string):word;
var
 i:word;
begin
 s:=up(s);
 for i:=low(para_) to high(para_) do begin
   if para_[i].s=copy(s,1,length(para_[i].s)) then begin foundpara:=i; exit; end;
 end;
 foundpara:=0;
end;

procedure readini(filename:string;fc:ps_fidoconfig);
type
        tarea_array=array[1..maxint] of area;
        Parea_array=^tarea_array;
const
 inmask:boolean=false;
 msgbase:string='';
var
 f:Text;
 s,t:String;
 i:word;
 p:pmask;
 a:paction;
 x:stringarray;
 line:word;
 found:word;
 need:word;
 can:word;
 para:word;
 tmp:pmask;
begin
 assign(f,filename);
 reset(f);
 if ioresult<>0 then begin logit(9,filename+' not found'); halt; end;
 line:=0;
 p:=nil;
 while not eof(f) do begin
   readln(f,s); inc(line);
   if ioresult<>0 then begin logit(9,'Error while reading ffma.ini'); halt; end;
   s:=killspaceae(s);
   if s='' then continue;
   if s[1]='#' then continue;
   if s[1]=';' then continue;
   if up(copy(s,1,7))='MSGBASE' then begin
       if not inmask then begin logit(9,'Line '+z2s(line)+' BeginMask missing'); halt; end;
       msgbase:=killspaceae(copy(s,8,256));
       continue;
   end;
   if up(copy(s,1,9))='BEGINMASK' then begin
       if inmask then begin logit(9,'Line '+z2s(line)+' endMask missing'); halt; end;
       new(p);
		p^.hits:=0;
       p^.maskname:=killspaceae(copy(s,10,255));
       if p^.maskname='' then begin logit(9,'Line '+z2s(line)+' Maskname missing'); halt; end;
       if findmask(p^.maskname,liste)<>nil then begin logit(9,'Line '+z2s(line)+' Maskname '+p^.maskname+' already used'); halt; end;
       p^.search:=nil;
       p^.action:=nil;
       p^.next:=nil;
       logit(2,'Reading Mask: '+p^.maskname);
       inmask:=true;
       continue;
   end;
   if up(copy(s,1,7))='ENDMASK' then begin
       if p=nil then begin logit(9,'Sorry. You found a bug in FFMA: READINI ENDMASK'); halt; end;
       if not inmask then begin logit(9,'Line '+z2s(line)+' BeginMask missing'); halt; end;
       if not ((msgbase='') and (p^.search=nil)) then begin
         if msgbase='' then begin logit(9,'Line '+z2s(line)+' MsgBase missing'); halt; end;
         if p^.search=nil then begin logit(9,'Line '+z2s(line)+' Search missing'); halt; end;
       end;
{	   if msgbase='*' then begin
	
       end else begin}
	   	maskinsert(fc,p,msgbase,liste);
{       end;}
       inmask:=false;
       msgbase:='';
       continue;
   end;
   if up(copy(s,1,7))='SEARCH ' then begin
       if not inmask then begin logit(9,'Line '+z2s(line)+' beginMask missing'); halt; end;
       t:=copy(s,8,256);
       if up(t)<>'NONE' then begin
          logit(2,'To search '+t+'<<');
          parser(t,p^.search);
          if p^.search=nil then begin logit(9,'in line '+s); halt; end;
       end else begin
          p^.search:=nil;
       end;
       continue;
   end;
   split(s,x);
   if (up(x[1])<>'ACTION') then begin logit(9,'Line '+z2s(line)+': Unknown Command: '+x[1]); halt; end;
   found:=foundaction(x[2]);
   if (found=0) then begin logit(9,'Line '+z2s(line)+': Unknown Command: '+x[2]); halt; end;
   new(a); fillchar(a^,sizeof(a^),0);
   a^.action:=ini_[found].a;
   need:=ini_[found].need;
   can:=ini_[found].can;
   for i:=3 to 20 do begin
      if x[i]='' then continue;
      para:=foundpara(x[i]);
      {Parameter not found -> Spezial?}
      if para=0 then begin
         if foundspe(found,x[i],a) then begin
            continue;
         end else begin
            logit(9,'Error in Line '+z2s(line)+': '+x[i]); halt;
         end;
      end;
      {Parameter found}
      if para_[para].p(x[i],a,fc) then begin
         if (para_[para].v and need)<>0 then begin
            need:=need and not para_[para].v;
            continue;
         end;
         if (para_[para].v and can)=0 then begin logit(9,'Parameter useless. Line '+z2s(line)+': '+x[i]); halt; end;
         can:=can and not para_[para].v;
      end else begin
         logit(9,'Error in Parameter '+z2s(line)+': '+x[i]); halt;
      end;
   end; {FOR}
   if need<>0 then begin 
      logit(9,'Parameter missing in line '+z2s(line)); halt;
   end;
   actionInsert(p^.action,a);
   continue;
 end;
 if inmask then begin logit(9,'Endmask missing'); halt; end;
end;

end.
