unit smapi;

interface

uses gpcstrings;
{$define pack4}
{$packrecords 1}
const
 MSGAREA_NORMAL:word=0;
 MSGAREA_CREATE:word=1;
 MSGAREA_CRIFNEC:word=2;
 UID_EXACT:word=0;
 UID_NEXT:word=1;
 UID_PREV:word=2;

 MSGTYPE_SDM:word=1;
 MSGTYPE_SQUISH:word=2;
 MSGTYPE_ECHO:word=$80;

 MOPEN_CREATE:word=0;
 MOPEN_READ:word=1;
 MOPEN_WRITE:word=2;
 MOPEN_RW:word=3;

{$ifdef LINUX}
  {$linklib smapi}
  { $linklib gcc}
  {$linklib c}
{$endif}

{$ifdef GO32V2}
  {$linklib smapidjp}
  {$linklib c}
{$endif}

const
 msgid=$0201414;

 {_XMSG.ATTR}
 MSGPRIVATE =01;
 MSGCRASH   =$02;
 MSGREAD    =$04;
 MSGSENT    =$08;
 MSGFILE    =$10;
 MSGFWD     =$20;
 MSGORPHAN  =$40;
 MSGKILL    =$80;
 MSGLOCAL   =$100;
 MSGHOLD    =$200;
 MSGXX2     =$400;
 MSGFRQ     =$800;
 MSGRRQ     =$1000;
 MSGCPT     =$2000;
 MSGARQ     =$4000;
 MSGURQ     =$8000;
 MSGSCANNED =$10000;


type
 array035=array[0..35] of char;
 p_netaddr=^netaddr;
 netaddr=record
           zone,net,node,point:word;
          end;
 pxmsg=^_xmsg;
 _xmsg=record
    attr:longint;
    fromname:array035;
    toname:array035;
    subj:array[0..71] of char;
    orig,dest:netaddr;
    date_written,date_arrived:record
         date:word;
         {$ifdef pack4} timedummy:word; {$endif}
         time:word;
         {$ifdef pack4} datedummy:word; {$endif}
    end;
    {$ifdef pack4} timedummy2:word; {$endif}
    utc_ofs:integer;
    replyto:longint;
    replies:array[0..9] of longint;
    umsgid:longint;
    __ftsc_date:array[0..19] of char;
   end;
 p_minf=^_minf;
 _minf=record
       req_version,def_zone,havesahre:word;
      end;

 phmsg=^hmsg;
 hmsg=record
       sq:pointer;
       id:longint;
       bytes_written:longint;
       cur_pos:longint;
      end;

 pfkt=^fkt;
 pharea=^harea;

 fkt=record
       CloseArea:function(mh:pharea):byte;cdecl;
           {sword(EXPENTRY * CloseArea) (MSG * mh);}

       OpenMsg:function(mh:pharea;mode:word;n:longint):phmsg;cdecl;
           { MSGH *(EXPENTRY * OpenMsg) (MSG * mh, word mode, dword n);}

       CloseMsg:function(mh:phmsg):integer;cdecl;
           {sword(EXPENTRY * CloseMsg) (MSGH * msgh);}

       ReadMsg:function(mh:phmsg;XMSG:PXMSG;ofs:longint;bytes:longint;text:pchar;cbyt:longint;ctxt:pchar):longint;cdecl;
           {dword(EXPENTRY * ReadMsg) (MSGH * msgh, XMSG * msg, dword ofs, dword bytes, byte * text, dword cbyt, byte * ctxt);}

       WriteMsg:function(mh:phmsg;appending:word;xmsg:pxmsg;text:pchar;textlen:longint;totlen:longint;clen:longint;ctxt:pchar):longint;cdecl;
          {sword(EXPENTRY * WriteMsg) (MSGH * msgh, word append, XMSG * msg, byte * text, dword textlen, dword totlen, dword clen, byte * ctxt);}

       KillMsg:function(mh:pharea;msgnum:longint):byte;cdecl;
          {sword(EXPENTRY * KillMsg) (MSG * mh, dword msgnum);}

       Lock:function(mh:pharea):byte;cdecl;
          {sword(EXPENTRY * Lock) (MSG * mh);}

       Unlock:function(mh:pharea):byte;cdecl;
          {sword(EXPENTRY * Unlock) (MSG * mh);}

       SetCurpos:function(mh:phmsg;pos:longint):byte;cdecl;
          {sword(EXPENTRY * SetCurPos) (MSGH * msgh, dword pos);}

       GetCurpos:function(mh:phmsg):longint;cdecl;
          {dword(EXPENTRY * GetCurPos) (MSGH * msgh);}

       MsgnToUid:function(mh:pharea;msgnum:longint):longint;cdecl;
          {UMSGID(EXPENTRY * MsgnToUid) (MSG * mh, dword msgnum);}

       UidToMsgn:function(mh:pharea;umsgid:longint;type_:word):longint;cdecl;
          {dword(EXPENTRY * UidToMsgn) (MSG * mh, UMSGID umsgid, word type);}

       GetHighWater:function(mh:pharea):longint;cdecl;
          {dword(EXPENTRY * GetHighWater) (MSG * mh);}

       SetHighWater:function(mh:pharea;hwm:longint):byte;cdecl;
          {sword(EXPENTRY * SetHighWater) (MSG * mh, dword hwm);}

       GetTextLen:function(msgh:phmsg):longint;cdecl;
          {dword(EXPENTRY * GetTextLen) (MSGH * msgh);}

       GetCtrlLen:function(msgh:phmsg):longint;cdecl;
          {dword(EXPENTRY * GetCtrlLen) (MSGH * msgh);}
     end;
 harea=record
       id:longint;
       len:word;
       type_:word;
       num_msg:longint;
       cur_msg:longint;
       high_msg:longint;
       high_water:longint;
       sz_xmsg:word;
{       locked:byte;
       isecho:byte; }
       mix:word;
       f:pfkt;

       apidata:pointer;
        dummy:array[1..20000] of char; {very bad}
      end;

function MsgOpenApi(_minf:p_minf):byte; cdecl; {return 0 if OK}
function MsgCloseApi:byte;cdecl;

function MsgOpenArea(name:pchar;mode:word;AreaType:word):pharea;cdecl;
function InvalidMsgh(hmsg:phmsg):boolean;cdecl;
function InvalidMh(HAREA:pharea):boolean;cdecl;
function MsgOpenMsg(h:pharea;mode:word;msgn:longint):phmsg;cdecl;
function MsgReadMsg(p:phmsg;ofs:longint;bytes:longint;text:pchar;cbtye:longint;ctext:pchar):longint;cdecl;
function MsgValidate(type_:word;name:pchar):byte;cdecl;
         {sword EXPENTRY MsgValidate(word type, byte * name);}

{function MsgGetCurMsg(HAREA:pharea):longint;
function MsgGetNumMsg(HAREA:pharea):longint;
function MsgGetHighMsg(HAREA:pharea):longint;
byte *EXPENTRY CvtCtrlToKludge(byte * ctrl);
byte *EXPENTRY GetCtrlToken(byte * where, byte * what);
byte *EXPENTRY CopyToControlBuf(byte * txt, byte ** newtext, unsigned *length);
word EXPENTRY NumKludges(char *txt);
                                            }
{function RemoveFromCtrl(ctrl:pchar;what:pchar);cdecl;
function ConvertControlInfo(ctrl:pchar;orig:p_netaddr;dest:p_netaddr);cdecl;}


implementation
const
   RCSID: PChar = '$Id$';

{var
 _msgapierror:word;external;}
{function RemoveFromCtrl(ctrl:pchar;what:pchar);cdecl;external;
function ConvertControlInfo(ctrl:pchar;orig:p_netaddr;dest:p_netaddr);cdecl;external;}

function MsgOpenApi(_minf:p_minf):byte; cdecl; external;
function MsgCloseApi:byte;cdecl; external;

function MsgOpenArea(name:pchar;mode:word;AreaType:word):pharea;cdecl; external;

function InvalidMh(HAREA:pharea):boolean;cdecl;external;
function InvalidMsgh(hmsg:phmsg):boolean;cdecl;external;
function MsgOpenMsg(h:pharea;mode:word;msgn:longint):phmsg;cdecl;external;
function MsgReadMsg(p:phmsg;ofs:longint;bytes:longint;text:pchar;cbtye:longint;ctext:pchar):longint;cdecl;external;
function MsgValidate(type_:word;name:pchar):byte;cdecl;external;
{
function MsgGetCurMsg(HAREA:pharea):longint;
begin
 MsgGetCurMsg:=HAREA^.cur_msg;
end;

function MsgGetNumMsg(HAREA:pharea):longint;
begin
 MsgGetNumMsg:=HAREA^.num_msg;
end;

function MsgGetHighMsg(HAREA:pharea):longint;
begin
 MsgGetHighMsg:=HAREA^.high_msg;
end;
 }

end.
