program ffma;
{
    FFMA FreeFidoMessageAssistant

    Copyright (C) 1998-2000 Sven Bursch

	Fido:     2:2448/820
	Internet: sb100@uni-duisburg.de

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


}

{$ifdef __GPC__}
{$x+}
     Uses ini,erweiter,gpcstrings,utils,fparser,memman,log,gpcsmapi,match,fconf,fidoconf2;
{$endif}

{$ifdef fpc}
	{$ifdef linux}
     Uses crt,dos,ini,erweiter,strings,utils,fparser,memman,log,smapi,match,fconf,fidoconf2;
	{$endif}
{$endif}


const
	configfile:string='/etc/fido/ffma.ini';
	version='0.08.01';
    compiler:string='Unknown';

type
 fileuid=record msgbase:String; uid:longint; end;
 puid=^tuid;
 tuid=record
       msgbase:string;
       uid:longint;
       next:puid;
      end;
const
 uidliste:puid=nil;
 uidlisteout:puid=nil;
 ffmauid:string='';

var
 fc:ps_fidoconfig;
 para:record
        debug:boolean;
        help:boolean;
        scanall:boolean;
        scannew:boolean;
        saveuid:boolean;
        test:boolean;

		save:boolean;
      end;

function uniqfilename(path:string):string;
const
	conv:string='0123456789ABCDEF';

var
	i:word;
	name:string;
begin
	repeat
		name:=path+'/';
		for i:=1 to 8 do name:=name+conv[random(16)+1];
	until not exist(name);
	uniqfilename:=name;
end;

function isdir(s:string):boolean;
var
	dir:searchrec;
begin
	FindFirst(s, anyfile, Dir);
	isdir:=(doserror=0) and ((dir.attr and $10)=$10);
end;

procedure storeuid(var l:puid;msgbase:string;uid:longint);
begin
 if l=nil then begin
  new(l);
  fillchar(l^,sizeof(l),0);
  l^.msgbase:=msgbase;
  l^.uid:=uid;
  l^.next:=nil;
  exit;
 end;
 if l^.msgbase=msgbase then begin
   l^.uid:=uid;
   exit;
 end;
 storeuid(l^.next,msgbase,uid);
end;

procedure removeuid(var l:puid;msgbase:string);
var
 x:puid;
begin
 if l=nil then exit;
 if l^.msgbase=msgbase then begin
   x:=l;
   l:=l^.next;
   dispose(x);
   exit;
 end;
 removeuid(l^.next,msgbase);
end;

procedure writeuidtofile(l:puid);
var
	x:fileuid;
	f:file of fileuid;
	err:integer;
begin
{$i-}
logit(1,'Entering WriteUidToFile');
assign(f,ffmauid);
{$ifdef __GPC__}
rewrite(f);
{$else}
rewrite(f,1);
{$endif}
err:=ioresult;
if err<>0 then begin logit(9,'Error while opening '+ffmauid+': '+geterrortext(err)); halt; end;
while l<>nil do begin
	fillchar(x,sizeof(x),0);
	x.msgbase:=l^.msgbase;
	x.uid:=l^.uid;
	logit(1,'Saving: Msgbase: '+l^.msgbase+' UID: '+z2s(l^.uid));
	write(f,x);
	err:=ioresult;
	if err<>0 then begin logit(9,'Error while writing '+ffmauid+': '+geterrortext(err)); halt; end;
	l:=l^.next;
end;
close(f);
err:=ioresult;
if err<>0 then begin logit(9,'Error while closing '+ffmauid+': '+geterrortext(err)); halt; end;
logit(1,'Leaving WriteUidToFile');
end;

procedure loaduid;
var
 x:fileuid;
 f:file of fileuid;
 io:word;
begin
 assign(f,ffmauid);
 {$ifdef __GPC__}
 reset(f);
 {$else}
 reset(f,1);
 {$endif}
 io:=ioresult;
 if io=2 then exit;
 if io<>0 then begin
  logit(9,'Can not read File `'+ffmauid+'`');
  halt;
 end;
 while not eof(f) do begin
  read(f,x);
  storeuid(uidliste,x.msgbase,x.uid);
 end;
 close(f);
end;

function getuid(msgbase:string;var uid:longint):boolean;
var
 l:puid;
begin
 getuid:=false;
 l:=uidliste;
 while l<>nil do begin
    if l^.msgbase=msgbase then begin uid:=l^.uid; getuid:=true; exit; end;
    l:=l^.next;
 end;
end;

procedure doaction(p:paction;fcarea:ps_area;var area:pharea;var msg:phmsg;var xmsg:pxmsg;var num:longint;var del:boolean);forward;

procedure dodostatment(fcarea:ps_area;area:pharea;nr:longint;mask:pmask);
var
 del:boolean;
 msg:phmsg;
 xmsg:pxmsg;
begin
   del:=false;
   logit(4,'Message '+z2s(nr)+' -> '+mask^.maskname);
   msg:=area^.f^.OpenMsg(area,MOPEN_READ,nr);
   new(xmsg);
   area^.f^.ReadMsg(msg,xmsg,0,0,nil,0,nil);
   doaction(mask^.action,fcarea,area,msg,xmsg,nr,del);
   area^.f^.closemsg(msg);
   if del then begin
        logit(4,'Deleting Message '+z2s(nr));
        if area^.f^.KillMsg(area,nr) <>0 then begin writeln('Could not delete Message Nr.',nr); halt; end;
   end;
   dispose(xmsg);
end;


procedure actionSEMAPHORE(var ziel:String);
var
 f:file;
 c:char;
begin
 assign(f,ziel);
 if not exist(ziel) then begin
   rewrite(f);
 end else begin
 {$ifdef __GPC__}
 reset(f);
 {$else}
 reset(f,1);
 {$endif}
   if not eof(f) then begin seek(f,0); blockread(f,c,1); seek(f,0); blockwrite(f,c,1); end;
 end;
 close(f);
end;

procedure actioncopy(farea:ps_area;var area:pharea;var msg:phmsg;var xmsg:pxmsg;num:word;p:paction);
var
 destarea:pharea;
 destmsg:phmsg;
 destfcarea:ps_area;

 ctrlbuf,textbuf:pchar;
 ctrlsize,textsize:longint;
 newnr:longint;
begin
	destfcarea:=getareaimp(fc,p^.msgbase);
    if destfcarea=nil then begin
      writeln('Could not open Msgbase: ',p^.msgbase); halt;
    end;
    destarea:=MsgOpenArea(destfcarea^.filename,MSGAREA_CRIFNEC,destfcarea^.msgbtype);
    if destarea=nil then begin
      writeln('Could not open Msgbase: ',p^.msgbase);  halt;
    end;
	while destarea^.f^.lock(destarea)<>0 do begin writeln('MsgBase locked. Waiting!'); delay(5000); end;

    if InvalidMh(destarea) then begin
      writeln('Invalid handle to Msgbase');
      halt;
    end;

    textsize:=area^.f^.GetTextLen(msg);
    ctrlsize:=area^.f^.GetCtrlLen(msg);
    textbuf:=getmemory(textsize+1);
    ctrlbuf:=getmemory(ctrlsize+1);
    area^.f^.ReadMsg(msg,xmsg,0,textsize,textbuf,ctrlsize,ctrlbuf);
    destmsg:=destarea^.f^.OpenMsg(destarea,MOPEN_CREATE,0);
    newnr:=destarea^.high_msg+1;
    destarea^.f^.WriteMsg(destmsg,0,xmsg,textbuf,textsize,textsize,ctrlsize,ctrlbuf);
    destarea^.f^.closemsg(destmsg);
    freememory(textbuf,true);
    freememory(ctrlbuf,true);
    if p^.dostat<>nil then dodostatment(destfcarea,destarea,newnr,p^.dostat);
	while destarea^.f^.unlock(destarea)<>0 do begin writeln('MsgBase locked. Waiting!'); delay(5000); end;
    destarea^.f^.closearea(destarea);
end;

procedure actionexportheader(fcarea:ps_area;var area:pharea;var msg:phmsg;var xmsg:pxmsg;num:word;ziel:string);
var
 f:text;
 s,t:string;
 i:word;
 filename:string;
begin
    area^.f^.ReadMsg(msg,xmsg,0,0,nil,0,nil);
    if isdir(ziel) then begin
        filename:=uniqfilename(ziel);
    end else begin
        filename:=ziel;
    end;
    assign(f,filename);
    if not exist(filename) then begin rewrite(f); close(f); end;
    append(f);
    if ioresult<>0 then begin writeln('Could not open ',ziel); halt; end;
    writeln(f,asc(80,'='));
    if ioresult<>0 then begin writeln('Could not writeto ',ziel); halt; end;
    s:='';
    for i:=1 to 36 do if xmsg^.fromname[i-1]=#0 then break else s:=s+xmsg^.fromname[i-1];
    t:='From: '+s+' ('+showaddr(xmsg^.orig)+')';
    writeln(f,t+asc(80-length(t)-20,' ')+showdatetime(xmsg^.date_written.date,xmsg^.date_written.time));
    s:='';
    for i:=1 to 36 do if xmsg^.toname[i-1]=#0 then break else s:=s+xmsg^.toname[i-1];
    t:='To:   '+s+' ('+showaddr(xmsg^.dest)+')';
    writeln(f,t+asc(80-length(t)-20,' ')+showdatetime(xmsg^.date_arrived.date,xmsg^.date_arrived.time));
    s:='';
    for i:=1 to 72 do if xmsg^.subj[i-1]=#0 then break else s:=s+xmsg^.subj[i-1];
    writeln(f,'Subj: ',s);
    close(f);
end;

procedure actionexportmsg(fcarea:ps_area;var area:pharea;var msg:phmsg;var xmsg:pxmsg;num:word;ziel:string);
var
 textbuf:pchar;
 textsize,i:longint;
 f:text;
 s,t:string;
 filename:string;
begin
    textsize:=area^.f^.GetTextLen(msg);
    textbuf:=getmemory(textsize+1);
    area^.f^.ReadMsg(msg,xmsg,0,textsize,textbuf,0,nil);
	if isdir(ziel) then begin
		filename:=uniqfilename(ziel);
	end else begin
		filename:=ziel;
	end;
    assign(f,filename);
    if not exist(filename) then begin rewrite(f); close(f); end;
    append(f);
    if ioresult<>0 then begin writeln('Could not open ',ziel); halt; end;
    writeln(f,asc(80,'='));
    if ioresult<>0 then begin writeln('Could not writeto ',ziel); halt; end;
    s:='';
    for i:=1 to 36 do if xmsg^.fromname[i-1]=#0 then break else s:=s+xmsg^.fromname[i-1];
    t:='From: '+s+' ('+showaddr(xmsg^.orig)+')';
    writeln(f,t+asc(80-length(t)-20,' ')+showdatetime(xmsg^.date_written.date,xmsg^.date_written.time));
    s:='';
    for i:=1 to 36 do if xmsg^.toname[i-1]=#0 then break else s:=s+xmsg^.toname[i-1];
    t:='To:   '+s+' ('+showaddr(xmsg^.dest)+')';
    writeln(f,t+asc(80-length(t)-20,' ')+showdatetime(xmsg^.date_arrived.date,xmsg^.date_arrived.time));
    s:='';
    for i:=1 to 72 do if xmsg^.subj[i-1]=#0 then break else s:=s+xmsg^.subj[i-1];
    writeln(f,'Subj: ',s);
    writeln(f,asc(80,'-'));
    s:='';
    t:='';
    for i:=0 to textsize-1 do begin
      if (textbuf[i]=#13) or (textbuf[i]=#1) then begin
         if not ((length(s)>0) and (s[1]=#1)) then writeln(f,s+t);
         s:=''; T:='';
         if textbuf[i]=#1 then s:=#1;
         continue;
      end;
      if textbuf[i]=#0 then break;
      if textbuf[i]=' ' then begin
       t:=t+textbuf[i];
       if (length(s)+length(t))>80 then begin writeln(f,s); S:=''; end;
       s:=s+t;
       t:='';
       continue;
      end;
      t:=t+textbuf[i];
    end;
    if not ((length(s)>0) and (s[1]=#1)) then writeln(f,s+t);
    close(f);
    freememory(textbuf,true);
end;


procedure actionechocopy(fcarea:ps_area;var area:pharea;var msg:phmsg;var xmsg:pxmsg;num:word;a:paction);
const
 deforigin=#$0d+'---'+#$0d+' * Origin: Default ';
var
 destarea:pharea;
 destmsg:phmsg;
 destfcarea:ps_area;
 ctrlbuf,textbuf:pchar;
 ctrlsize,textsize:longint;
 pp,ppp:pchar;
 kludge,enter:pchar;
 ORIGIN:pchar;
 s:string;
 I:longint;
 newnr:longint;
begin
    destfcarea:=getareaimp(fc,a^.msgbase);
    if destfcarea=nil then begin
      writeln('Could not open Msgbase via fidoconfig: ',a^.msgbase);
      halt;
    end;
    destarea:=MsgOpenArea(destfcarea^.filename,MSGAREA_CRIFNEC,destfcarea^.msgbtype);
    if destarea=nil then begin
      writeln('Could not open Msgbase: ',a^.msgbase);
      halt;
    end;
    if InvalidMh(destarea) then begin
      writeln('Invalid handle to Msgbase');
      halt;
    end;
    newnr:=destarea^.high_msg+1;
    textsize:=area^.f^.GetTextLen(msg);
    textbuf:=getmemory(textsize+10000);
    ctrlbuf:=nil; ctrlsize:=0;
    area^.f^.ReadMsg(msg,xmsg,0,textsize,textbuf,0,nil);
	textbuf[textsize]:=#0;
    xmsg^.orig:=a^.addr;
    xmsg^.attr:=msglocal;
    pp:=psearch(textbuf,#$0d+'--- ');
    while pp<>nil do begin pp[2]:='+'; pp:=psearch(textbuf,#$0d+'--- '); end;

    pp:=psearchI(textbuf,#$0d+' * Origin: ');
    while pp<>nil do begin pp[2]:='+'; pp:=psearchI(textbuf,#$0d+' * Origin: '); end;

	{Entfernung alle Kludges am Ende der Nachricht}
    repeat
      enter:=strrscan(textbuf,#$0d);
      if enter=nil then break;
      kludge:=strrscan(textbuf,#1);
      if kludge=nil then break;
      ppp:=strscan(kludge,#$0d);
      if ppp=nil then break;
      if ppp=enter then begin
        kludge[0]:=#0;
      end else break;
    until false;

    textsize:=strlen(textbuf)+1;
	s:=deforigin+'('+showaddr(xmsg^.orig)+')'#13'SEEN-BY: '+a^.seenby+#13#0;
	origin:=getmemory(length(s)+1);
	strpcopy(origin,s);

	strcat(textbuf,origin);

    destmsg:=destarea^.f^.OpenMsg(destarea,MOPEN_CREATE,0);
    destarea^.f^.WriteMsg(destmsg,0,xmsg,textbuf,strlen(textbuf),strlen(textbuf),0,ctrlbuf);
    destarea^.f^.closemsg(destmsg);
    freememory(textbuf,true);
	freememory(origin,true);
    if a^.dostat<>nil then dodostatment(destfcarea,destarea,newnr,a^.dostat);
    destarea^.f^.closearea(destarea);
end;

function createkludges(orig,dest:netaddr;createmsgid:boolean):pchar;
var
 s:string;
 p:pchar;
begin
 s:='';
 if createmsgid then s:=#1+'MSGID: '+z2s(orig.zone)+':'+z2s(orig.net)+'/'+z2s(orig.node)+'.'+z2s(orig.point)+' '+longint2hex(msgid);
 s:=s+#1+'INTL '+z2s(dest.zone)+':'+z2s(dest.net)+'/'+z2s(dest.node)+' '+
    z2s(orig.zone)+':'+z2s(orig.net)+'/'+z2s(orig.node);
 if dest.point<>0 then begin
  s:=s+#1+'TOPT '+z2s(dest.point);
 end;
 if orig.point<>0 then begin
  s:=s+#1+'FMPT '+z2s(orig.point);
 end;
 p:=getmemory(length(s)+1);
 strpcopy(p,s);
 createkludges:=p;
end;

procedure eval(xmsg:pxmsg;var textsize:longint;var textbuf:pchar);
const
 syb:array[1..7] of string=('TO','FR','OR','DE','SU','TI','DA');
 function found(s:string):byte;
 var
  k:byte;
 begin
  found:=0;
  for k:=1 to 9 do if '%'+syb[k]=s then begin found:=k; break; end;
 end;

var
 i,j,x:longint;
 l:boolean;
 s:string;
 p,org:pchar;
begin
 p:=getmemory(textsize+10000);
 org:=textbuf;
 x:=0;
 l:=false;
 S:='';
 for i:=0 to textsize-1 do begin
     if l then begin
        s:=s+textbuf[i];
        if length(s)=3 then begin
          case found(up(s)) of
          0: begin s:=''; end;
          1: s:=array2string(xmsg^.toname,36);
          2: s:=array2string(xmsg^.fromname,36);
          3: s:=showaddr(xmsg^.orig);
          4: s:=showaddr(xmsg^.dest);
          5: s:=array2string(xmsg^.subj,72);
          6: s:=showtime(xmsg^.date_written.time);
          7: s:=showdate(xmsg^.date_written.date);
          end;
          for j:=1 to length(s) do begin p[x]:=s[j]; inc(x); end;
          s:='';
          l:=false;
        end;
        continue;
     end;
     if textbuf[i]<>'%' then begin
        p[x]:=textbuf[i]; inc(x);
     end else begin
        l:=true;
        s:='%';
     end;
 end;
 if p[x]<>#0 then begin
  p[x]:=#0; inc(x);
 end;
 textbuf:=p;
 textsize:=x;
 freememory(org,true);
end;


procedure actionbounce(fcarea:ps_area;var area:pharea;var msg:phmsg;var xmsg:pxmsg;num:word;p:paction);
var
 f:file;
 destarea:pharea;
 destfcarea:ps_area;
 xmsgnew:pxmsg;
 msgnew:phmsg;
 textsize:longint;
 ctrlbuf,textbuf,msgbuf:pchar;
 destmsg:phmsg;
 msgsize,buffersize:longint;
 newnr:longint;
 del:boolean;
begin
  assign(f,p^.filename);
 if not exist(P^.filename) then begin 
 	logit(9,'File '+p^.filename+' not found!'); halt; 
 end;
 {$ifdef __GPC__}
 reset(f);
 {$else}
 reset(f,1);
 {$endif}
  textsize:=filesize(f);
  textbuf:=getmemory(textsize+10000);
  {Reading File}
  blockread(f,textbuf^,filesize(f));
  textbuf[textsize]:=#0; inc(textsize);
  {Reading Msg-Header, creating new Header}
  area^.f^.ReadMsg(msg,xmsg,0,0,nil,0,nil);
  new(xmsgnew);
  fillchar(xmsgnew^,sizeof(xmsgnew^),0);
  xmsgnew^.fromname:=xmsg^.toname;
  xmsgnew^.attr:=msglocal;
  xmsgnew^.toname:=xmsg^.fromname;
  xmsgnew^.subj:=xmsg^.subj;
  xmsgnew^.orig:=p^.addr;
  xmsgnew^.dest:=xmsg^.orig;
  xmsgnew^.utc_ofs:=0;
  datetime2ftsdate(xmsgnew^.date_written.date,xmsgnew^.date_written.time,xmsgnew^.__ftsc_date);
  xmsgnew^.date_arrived.date:=xmsgnew^.date_written.date;
  xmsgnew^.date_arrived.time:=xmsgnew^.date_written.time;
{Ersetze %?? durch Headerdaten}
  eval(xmsg,textsize,textbuf);
  ctrlbuf:=createkludges(xmsgnew^.orig,xmsgnew^.dest,true);
  if (p^.msgbase=nil) or (strpas(p^.msgbase)='') then begin
     newnr:=area^.high_msg+1;
     destmsg:=area^.f^.OpenMsg(area,MOPEN_CREATE,0);
     destarea:=area;
  end else begin
	destfcarea:=getareaimp(fc,p^.msgbase);
    if destfcarea=nil then begin
      writeln('Could not open Msgbase via fidoconfig: ',p^.msgbase);
      halt;
    end;
    destarea:=MsgOpenArea(destfcarea^.filename,MSGAREA_CRIFNEC,destfcarea^.msgbtype);
    if destarea=nil then begin
      writeln('Could not open Msgbase via fidoconfig: ',p^.msgbase);
      halt;
    end;
    newnr:=destarea^.high_msg+1;
    if destarea=nil then begin
      writeln('Could not open Msgbase: ',p^.msgbase);
      halt;
    end;
    if InvalidMh(destarea) then begin
      writeln('Invalid handle to Msgbase');
      halt;
    end;
    destmsg:=destarea^.f^.OpenMsg(destarea,MOPEN_CREATE,0);
  end;
  if (p^.spe and actionbouncefullmessage)<>0 then begin
    msgsize:=area^.f^.GetTextLen(msg);
    msgbuf:=getmemory(msgsize+1);
    area^.f^.ReadMsg(msg,nil,0,msgsize,msgbuf,0,nil);
    destarea^.f^.WriteMsg(destmsg,0,xmsgnew,textbuf,textsize-1,textsize+msgsize,strlen(ctrlbuf),ctrlbuf);
    destarea^.f^.WriteMsg(destmsg,1,xmsgnew,msgbuf,msgsize,textsize+msgsize,0,nil);
    freememory(msgbuf,true);
  end else begin
    destarea^.f^.WriteMsg(destmsg,0,xmsgnew,textbuf,textsize,textsize,strlen(ctrlbuf),ctrlbuf);
  end;
  freememory(textbuf,true);
  freememory(ctrlbuf,true);
  destarea^.f^.closemsg(destmsg);
  dispose(xmsgnew);
  if p^.dostat<>nil then dodostatment(destfcarea,destarea,newnr,p^.dostat);
  if p^.msgbase<>nil then 
  if strpas(p^.msgbase)<>'' then begin
     destarea^.f^.closearea(area);
  end;
end;

procedure actionrewrite(var fcara:ps_area;var area:pharea;var msg:phmsg;var xmsg:pxmsg;num:word;p:paction);
var
 s:string;
 i:word;
 ppp,pp:pchar;
 ctrlbuf,textbuf:pchar;
 ctrlsize,textsize:longint;
 o,d:netaddr;
begin
 logit(1,'ACTION REWRITE: Subaction '+z2s(p^.spe)+' '+p^.str);
 if p^.str[1]='"' then delete(p^.str,1,1);
 if p^.str[length(p^.str)]='"' then delete(p^.str,length(p^.str),1);
 logit(1,'ACTION REWRITE: Subaction '+z2s(p^.spe)+' '+p^.str);
 case p^.spe of
 actionrewriteFromName:begin
                         s:=copy(p^.str,1,32); while length(s)<32 do s:=S+#0;
                         for i:=1 to 32 do xmsg^.fromname[i-1]:=s[i];
                         area^.f^.WriteMsg(msg,0,xmsg,nil,0,0,0,nil);
                       end;
 actionrewriteToName:begin
                         s:=copy(p^.str,1,32); while length(s)<32 do s:=S+#0;
                         for i:=1 to 32 do xmsg^.toname[i-1]:=s[i];
                         area^.f^.WriteMsg(msg,0,xmsg,nil,0,0,0,nil);
                       end;
 actionrewriteFromAddr,actionrewriteToaddr:begin
                         textsize:=area^.f^.GetTextLen(msg);
                         ctrlsize:=area^.f^.GetCtrlLen(msg);
                         textbuf:=getmemory(textsize+1);
                         ctrlbuf:=getmemory(ctrlsize+1000);
                         area^.f^.ReadMsg(msg,xmsg,0,textsize,textbuf,ctrlsize,ctrlbuf);
                         area^.f^.closemsg(msg);
                         {Current Orig, Dest}
                         o:=xmsg^.orig; d:=xmsg^.dest;
                         getfulladdr(ctrlbuf,ctrlsize,o,d);
                         {Change Orig, create new Kludges (intl, fmpt, topt}
                         if p^.spe=actionrewriteFromAddr then begin
                           o:=p^.addr;
                           xmsg^.orig:=p^.addr;
                         end;
                         if p^.spe=actionrewriteToaddr then begin
                           d:=p^.addr;
                           xmsg^.dest:=p^.addr;
                         end;
                         pp:=createkludges(o,d,false);
                         ppp:=getmemory(strlen(ctrlbuf)+strlen(pp)+1);
                         strcopy(ppp,pp);
                         strcat(ppp,ctrlbuf);
                         msg:=area^.f^.OpenMsg(area,MOPEN_CREATE,num);
                         area^.f^.WriteMsg(msg,0,xmsg,textbuf,textsize,textsize,strlen(ppp),ppp);
                         area^.f^.closemsg(msg);
                         msg:=area^.f^.OpenMsg(area,MOPEN_READ,num);
                         freememory(textbuf,true);
                         freememory(ctrlbuf,true);
                         freememory(ppp,true);
                         freememory(pp,true);
                       end;
 actionrewriteSubj:begin
                         s:=copy(p^.str,1,72); while length(s)<72 do s:=S+#0;
                         for i:=1 to 72 do xmsg^.subj[i-1]:=s[i];
                         area^.f^.WriteMsg(msg,0,xmsg,nil,0,0,0,nil);
                       end;
 else begin
        logit(9,'ACTION REWRITE: Subaction '+z2s(p^.spe)+' not found');
        halt;
      end;
 end;
end;

procedure actionwritetofile(filename,str:string);
var
 f:text;
begin
 assign(f,filename);
 if not exist(filename) then begin rewrite(f); close(f); end;
 append(f);
 writeln(f,transstring(str));
 close(f);
end;

procedure doaction(p:paction;fcarea:ps_area;var area:pharea;var msg:phmsg;var xmsg:pxmsg;var num:longint;var del:boolean);
begin
 del:=false;
 while p<>nil do begin
  case p^.action of
  actionCopy_: begin
               actioncopy(fcarea,area,msg,xmsg,num,p);
              end;
  actionMOVE_: begin
               actioncopy(fcarea,area,msg,xmsg,num,p);
               del:=True;
              end;
  actionDEL_: begin
                del:=true;
              end;
  actionREWRITE_: begin
                actionrewrite(fcarea,area,msg,xmsg,num,p);
              end;
  actionechoCopy_: begin
               actionechocopy(fcarea,area,msg,xmsg,num,p);
              end;
  actionechoMove_: begin
               actionechocopy(fcarea,area,msg,xmsg,num,p);
               del:=true;
              end;
  actionexportmsg_:actionexportmsg(fcarea,area,msg,xmsg,num,p^.filename);
  actionexportheader_:actionexportheader(fcarea,area,msg,xmsg,num,p^.filename);
  actionSEMAPHORE_:actionSEMAPHORE(p^.filename);
  actionbounce_:actionbounce(fcarea,area,msg,xmsg,num,p);
  actionwritetofile_:actionwritetofile(p^.filename,p^.str);
  else begin
   writeln('Unknown Action ',p^.action); halt;
   end;
  end;
  p:=p^.next;
 end;
end;




procedure scan(fc:ps_fidoconfig);
Var
 area:pharea;
 msg:phmsg;
 xmsg:pxmsg;
 l:pliste;
 mask:pmask;
 num:longint;
 anz:longint;
 del:boolean;
 uid:longint;
 a:ps_area;
begin
 l:=liste;
 while l<>nil do begin
    {OPEN}
    if strpas(l^.msgbase)='' then begin l:=l^.next; continue; end;
    logit(4,'Open Area '+strpas(l^.msgbase));
    a:=getareaimp(fc,l^.msgbase);
    if a=nil then begin logit(9,'Could not open Msgbase via fidoconfig: '+strpas(l^.msgbase)); halt; end;
    area:=MsgOpenArea(a^.filename,MSGAREA_CRIFNEC,a^.msgbtype);
    if area=nil then begin logit(9,'Could not open Msgbase: '+strpas(l^.msgbase)); halt; end;
	while area^.f^.lock(area)<>0 do begin writeln('MsgBase locked. Waiting!'); delay(5000); end;
    if InvalidMh(area) then begin logit(9,'Invalid handle to Msgbase'); halt; end;
{    if area^.num_msg<>area^.high_msg then begin logit(9,'NUM_MSG<>HIGH_MSG'); halt; end;}
    writeln('Scanning '+strpas(l^.msgbase)+' ',area^.num_msg,' Mails');
    new(xmsg);
    num:=1;
    anz:=area^.high_msg;
    {UID}
    if getuid(strpas(l^.msgbase),uid) then begin
       num:=area^.f^.UidToMsgn(area,uid,uid_exact);
       if num=0 then begin
          num:=area^.f^.UidToMsgn(area,uid,uid_next);
          logit(2,'UID ('+z2s(uid)+') matchs next to Msg '+z2s(num));
          if num=0 then begin
	      		logit(4,'Ignoring all Message in this Area because the UID is 0. Use Scanall if necessary.');
				num:=anz+1;
		  end;
       end else begin
          inc(num);
          logit(2,'UID ('+z2s(uid)+') matchs exact to Msg '+z2s(num));
       end;
    end else begin
       logit(2,'No UID for Area '+strpas(l^.msgbase)+'. Starting at Msg 1');
    end;

    {Scanning}
    if anz<num then begin writeln('No new messages to scan'); end;
    while num<=anz do begin
      msg:=area^.f^.OpenMsg(area,MOPEN_READ,num);
      if msg=nil then begin
{        logit(1,'Message '+z2s(num)+' does not exist');}
		inc(num);
		continue;
      end;
      logit(1,'Processing Message '+z2s(num));
      write(num,' ');
      area^.f^.ReadMsg(msg,xmsg,0,0,nil,0,nil);
      mask:=l^.mask;
      del:=false;
      while (mask<>nil) and (del=false) do begin
         if mask^.search=nil then begin writeln('no search statment for ',mask^.maskname); halt; end;
         if (mask^.search^.l^.ele = 'ANY') or match_(area,msg,xmsg,mask^.search) then begin
			inc(mask^.hits);
            logit(4,'Message '+z2s(num)+'/'+z2s(anZ)+' '+array2string(xmsg^.subj,72)+' matchs to  '+mask^.maskname);
            if not para.test then doaction(mask^.action,a,area,msg,xmsg,num,del);
         end;
         mask:=mask^.next;
      end;
      area^.f^.closemsg(msg);
      if del then begin
         logit(4,'Deleting Message '+z2s(num));
         if area^.f^.KillMsg(area,num) <>0 then begin logit(9,'Could not delete Message Nr.'+z2s(num)); halt; end;
         if (area^.type_ <> MSGTYPE_SQUISH) then inc(num);
      end else begin
         inc(num);
      end;
    end;
    dispose(xmsg);
    writeln; writeln;
    if area^.num_msg>0 then begin
        logit(4,'SCAN: MB:'+strpas(l^.msgbase)+' Anz:'+z2s(area^.num_msg)+' Anz2:'+z2s(area^.num_msg)+' UID:'+z2s(area^.f^.msgntouid(area,area^.num_msg)));
		storeuid(uidlisteout,strpas(l^.msgbase),area^.f^.msgntouid(area,area^.num_msg)) 
	end else begin
        logit(4,'SCAN: MB:'+strpas(l^.msgbase)+'No UID');
		removeuid(uidlisteout,strpas(l^.msgbase));
    end;
	while area^.f^.unlock(area)<>0 do begin writeln('MsgBase locked. Waiting!'); delay(5000); end;
    area^.f^.closearea(area);
    l:=l^.next;
 end;
end;

procedure Statistic;
Var
 no:boolean;
 l:pliste;
 mask:pmask;
 s:string;
 loglevel:byte;
begin
 logit(4,'Statistics:');
 l:=liste;
 no:=true;
 while l<>nil do begin
      mask:=l^.mask;
      while (mask<>nil) do begin
		if mask^.hits=0 then begin
			loglevel:=2;
		end else begin
			loglevel:=4; no:=false;
		end;
		logit(loglevel,'   '+mask^.maskname+' ('+l^.msgbase+') : '+z2s(mask^.hits));
    	mask:=mask^.next;
      end;
	  l:=l^.next;
 end;
 if no then logit(4,'   none');
end;

procedure help;
begin
 writeln;
 writeln('Commands:');
 writeln('ScanAll       Scan all Messages and execute actions.');
 writeln('ScanNew       Scan only new Messages and execute actions.');
 writeln('Saveuid       Save only the UID of the last Message. Nothing else.');
 writeln('Check         check the CFG-File. Nothing else.');
 writeln;
 writeln('Options:');
 writeln('--notsave       Do not save the UID of the last Message after scanning.');
 writeln('--save          Save the UID of the last Message after scanning. (Default)');
 writeln;
 writeln('--config=<file> Configfile (Default --config=/etc/fido/ffma)');
 writeln('--uid=<file>    File where ffma should save the uid''s.');
 writeln('--help          Help');
end;

procedure checkpara;
var
 i:word;
 s:string;
 nrpara:word;
begin
 fillchar(para,sizeof(para),0);
 if paramcount=0 then begin
   writeln('Nothing to do!');
   help; halt;
 end;
 nrpara:=0;
 para.save:=true;
 for i:=1 to paramcount do begin
    if nrpara>1 then begin
        writeln('too much commands'); halt;
    end;
    s:=up(paramstr(i));
    if (s='HELP') or (s='-HELP') or (s='--HELP') or (s='-?') or (s='/?') then begin para.help:=true; continue; end;
    if (s='--DEBUG') then begin para.debug:=true; continue; end;
    if (s='SAVEUID')  then begin inc(nrpara); para.saveuid:=true; continue; end;
    if (s='SCANALL')  then begin inc(nrpara); para.scanall:=true; continue; end;
    if (s='SCANNEW')  then begin inc(nrpara); para.scannew:=true; continue; end;
    if (s='TEST') then begin inc(nrpara); para.test:=True; continue; end;
    if (s='CHECK') then begin inc(nrpara); para.test:=True; continue; end;

    if (s='--NOTSAVE') then begin para.save:=false; continue; end;
    if (s='--SAVE') then begin para.save:=true; continue; end;

    if (copy(s,1,3)='-C=') or (copy(s,1,9)='--CONFIG=') then begin
      s:=paramstr(i);
      if copy(up(s),1,3)='-C' then delete(s,1,3) else delete(s,1,9);
      if not exist(s) then begin writeln('File not found: `',s,'`'); halt; end;
      configfile:=s;
      continue;
    end;
    if (copy(s,1,3)='-U=') or (copy(s,1,6)='--UID=') then begin
      s:=paramstr(i);
      if copy(up(s),1,3)='-U' then delete(s,1,3) else delete(s,1,6);
      ffmauid:=s;
      continue;
    end;
    writeln('unrecognized option/command `'+paramstr(i)+'`'); halt;
 end;
 if para.test then logit(9,'TESTMODE');
 if para.help then begin help; halt; end;
end;

procedure storeuid_;
Var
 area:pharea;
 l:pliste;
 anz:longint;
 fcarea:ps_area;
begin
 l:=liste;
 while l<>nil do begin
    if strpas(l^.msgbase)='' then begin l:=l^.next;  continue; end;
    logit(4,'Open Area '+strpas(l^.msgbase));
    fcarea:=getareaimp(fc,l^.msgbase);
    if fcarea=nil then begin logit(9,'Could not open Msgbase: '+strpas(l^.msgbase)); halt; end;
    area:=MsgOpenArea(fcarea^.filename,MSGAREA_CRIFNEC,fcarea^.msgbtype);
    if area=nil then begin logit(9,'Could not open Msgbase: '+strpas(l^.msgbase)); halt; end;
	while area^.f^.lock(area)<>0 do begin writeln('MsgBase locked. Waiting!'); delay(5000); end;
    if InvalidMh(area) then begin logit(9,'Invalid handle to Msgbase'); halt; end;
{    if area^.num_msg<>area^.high_msg then begin logit(9,'NUM_MSG<>HIGH_MSG'); halt; end;}
    anz:=area^.high_msg;
    logit(3,strpas(l^.msgbase)+': Msg '+z2s(area^.high_msg)+' Uid:'+z2s(area^.f^.msgntouid(area,anz)));
    if anz>0 then storeuid(uidlisteout,strpas(l^.msgbase),area^.f^.msgntouid(area,anz));
	while area^.f^.unlock(area)<>0 do begin writeln('MsgBase locked. Waiting!'); delay(5000); end;
    area^.f^.closearea(area);
    l:=l^.next;
 end;
end;


var
 m:p_minf;
 list:pliste;
 mask:pmask;
 ok:boolean;
 i:longint;
begin
	ok:=false;
	randomize;
    {$ifdef FPC}{$ifdef LINUX} ok:=true; compiler:='FPC/LINUX'; {$endif}{$endif}
	{$ifdef __GPC__} 
		writeln('Warning!'); 
		writeln('This version of FFMA is compiled with GPC.'); 
		writeln('Maybe this version does not work correct! Be careful!');
		writeln;
		writeln('Press enter to continue');
		readln;
		compiler:='GPC';
		ok:=true; 
	 {$endif}

	 if not ok then begin
	 	writeln('Please do not use FFMA under this OS!'); halt(255);
	 end;

	 fc:=readconfig(NIL);
	 openlogfile(strpas(fc^.logfiledir)+'ffma.log');
	 if getConfigFileNameForProgram('FFMA','ffma.ini')<>nil then begin
		configfile:=getConfigFileNameForProgram('FFMA','ffma.ini');
	 end;

	 logit(2,'FreeFidoMessageAssistant '+version+' '+compiler);
	 logit(2,'Copyright by Sven Bursch, Germany  1998-1999');
	 logit(2,'FFMA comes with ABSOLUTELY NO WARRANTY. See COPYING');
	 logit(2,'');
	 logit(0,'Memory: '+z2s(memavail)+'  Configfile: '+configfile);

	 checkpara;
	 readini(configfile,fc);
	 if ffmauid='' then begin
		 ffmauid:=getConfigFileName;
		 for i:=length(ffmauid) downto 1 do begin
			if ffmauid[i] in ['\','/'] then break;
			delete(ffmauid,i,1);
		 end;
		 ffmauid:=ffmauid+'ffma.uid';
	end;

 {Open Smapi}
 new(m); m^.req_version:=0; m^.def_zone:=2;
 if msgopenapi(m)<>0 then begin  writeln('Could not open MsgApi'); halt; end;

 {Loading UID}
 if para.scannew then loaduid;

 {Scaning}
 if para.scannew or para.scanall or para.test then begin
	scan(fc);
	statistic; 
 end;	
 {Storing UID}
 if para.saveuid then storeuid_;

 {Close Smapi}
 msgcloseapi; dispose(m);

 {Saving UID}
 if (para.save) and (not para.test) then writeuidtofile(uidlisteout);

 {Cleanup}
 shownotfree;
 logit(0,z2s(memavail));
 logit(3,'Normal exit');
end.
