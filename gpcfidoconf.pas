unit Gpcfidoconf;
{
FIDOCONFIG --- library for fidonet configs

Copyright (C) 1998-1999

Matthias Tichy

Fido:     2:2433/1245 2:2433/1247 2:2432/605.14
Internet: mtt@tichy.de

Grimmestr. 12         Buchholzer Weg 4
33098 Paderborn       40472 Duesseldorf
Germany               Germany

This file is part of FIDOCONFIG.

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Library General Public
License as published by the Free Software Foundation; either
version 2 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Library General Public License for more details.

You should have received a copy of the GNU Library General Public
License along with this library; see file COPYING. If not, write to the Free
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}

interface
{$l fidoconfig}
{ C default packing is dword }

  const
     MSGTYPE_PASSTHROUGH = $04;
{$ifdef UNIX}

  const
     PATH_DELIM = '/';
{$else}

  const
     PATH_DELIM = '\\';
{$endif}
type
	dword=longint;
{    var
       actualLine : asmname 'actualLine' Pchar;
       actualLineNr : asmname 'actualLineNr' Pchar;
       wasErrorr : asmname 'wasError' Pchar;
}
  function striptwhite(str:pchar):Pchar;


  type
     saddr = record
          zone : dword;
          net : dword;
          node : dword;
          point : dword;
          domain : Pchar;
       end;
     Psaddr = ^saddr;

     spack = record
          packer : Pchar;
          call : Pchar;
       end;
     Pspack = ^spack;

     eflavour = (normal,hold,crash,direct,immediate);

     eforward = (fOff,fSecure,fOn);

     eemptypktpwd = (eOff,eSecure,eOn);

     slink = record
          hisAka : saddr;
          ourAka : Psaddr;
          name : Pchar;
          defaultPwd : Pchar;
          pktPwd : Pchar;
          ticPwd : Pchar;
          areaFixPwd : Pchar;
          fileFixPwd : Pchar;
          bbsPwd : Pchar;
          sessionPwd : Pchar;
          handle : Pchar;
          autoAreaCreate : longint;
          autoFileCreate : longint;
          AreaFix : longint;
          FileFix : longint;
          forwardRequests : longint;
          fReqFromUpLink : longint;
          allowEmptyPktPwd : longint;
          forwardPkts : eforward;
          pktFile : Pchar;
          packFile : Pchar;
          floFile : Pchar;
          bsyFile : Pchar;
          packerDef : Pspack;
          echoMailFlavour : eflavour;
          LinkGrp : Pchar;
          AccessGrp : Pchar;
          autoAreaCreateFile : Pchar;
          autoFileCreateFile : Pchar;
          autoAreaCreateDefaults : Pchar;
          autoFileCreateDefaults : Pchar;
          forwardRequestFile : Pchar;
          RemoteRobotName : Pchar;
          msg : pointer;
          Pause : longint;
          autoPause : dword;
          level : dword;
          arcmailSize : dword;
          export_a : Pchar;
          import : Pchar;
          mandatory : Pchar;
          optGrp : Pchar;
       end;
     Pslink = ^slink;

{     erouting = (host := 1,hub,boss,noroute);}
	erouting=dword;



  { if target = NULL use }
  { this }
     sroute = record
          flavour : eflavour;
          enc : char;
          target : Pslink;
          routeVia : erouting;
          pattern : Pchar;
       end;
     Psroute = ^sroute;

     edupeCheck = (dcOff,dcMove,dcDel);

     sarealink = record
          link : Pslink;
          export_a : char;
          import : char;
          mandatory : char;
       end;
     Psarealink = ^sarealink;

     sarea = record
          areaName : Pchar;
          fileName : Pchar;
          description : Pchar;
          msgbType : longint;
          useAka : Psaddr;
          downlinks : ^Psarealink;
          downlinkCount : dword;
          purge : dword;
          max : dword;
          dupeSize : dword;
          dupeHistory : dword;
          keepunread,killread:char;
          dupeCheck : edupeCheck;
          tinySB : char;
          manual : char;
          hide : char;
          noPause : char;
          mandatory : char;
          DOSFile : char;
          levelread : dword;
          levelwrite : dword;
          dupes : pointer;
          newDupes : pointer;
          imported : dword;
          group : char;
          rwgrp : Pchar;
          wgrp : Pchar;
          rgrp : Pchar;
          ccoff : cardinal;
          uid,gid,perm:dword;
          keepsb : longint;
          scn : longint;
       end;
     Psarea = ^sarea;

     sfileareatype = record
          areaName : Pchar;
          pathName : Pchar;
          description : Pchar;
          pass : longint;
          useAka : Psaddr;
          downlinks : ^Psarealink;
          downlinkCount : dword;
          levelread : dword;
          levelwrite : dword;
          manual : char;
          hide : char;
          noPause : char;
          group : char;
          rwgrp : Pchar;
          wgrp : Pchar;
          rgrp : Pchar;
       end;
     Psfileareatype = ^sfileareatype;

     sbbsareatype = record
          areaName : Pchar;
          pathName : Pchar;
          description : Pchar;
       end;
     Psbbsareatype = ^sbbsareatype;

{     ecarbonType = (cto,cfrom,ckludge,csubject,cmsgtext);}

     scarbon = record
{          type : ecarbonType;}
          type_a : dword;
          str : Pchar;
          area : Psarea;
          export_a : longint;
       end;
     Pscarbon = ^scarbon;

     sunpack = record
          offset : longint;
          matchCode : ^byte;
          mask : ^byte;
          codeSize : longint;
          call : Pchar;
       end;
     Psunpack = ^sunpack;

     sremap = record
          oldaddr : saddr;
          newaddr : saddr;
          toname : Pchar;
       end;
     Psremap = ^sremap;

     sfidoconfig = record
          cfgVersionMajor : dword;
          cfgVersionMinor : dword;
          name : Pchar;
          location : Pchar;
          sysop : Pchar;
          addrCount : dword;
          addr : Psaddr;
          publicCount : dword;
          publicDir : ^Pchar;
          linkCount : dword;
          links : Pslink;
          inbound : Pchar;
          outbound : Pchar;
          protInbound : Pchar;
          listInbound : Pchar;
          localInbound : Pchar;
          tempInbound : Pchar;
          logFileDir : Pchar;
          dupeHistoryDir : Pchar;
          nodelistDir : Pchar;
          msgBaseDir : Pchar;
          magic : Pchar;
          areafixhelp : Pchar;
          filefixhelp : Pchar;
          tempOutbound : Pchar;
          ticoutbound : Pchar;
          fileAreaBaseDir : Pchar;
          passFileAreaDir : Pchar;
          semaDir : Pchar;
          badFilesDir : Pchar;
          loglevels : Pchar;
          dupeArea : sarea;
          badArea : sarea;
          netmailareacount:cardinal;
          netmailareas:psarea;
          echoAreaCount : dword;
          echoAreas : Psarea;
          localAreaCount : dword;
          localAreas : Psarea;
          fileAreaCount : dword;
          fileAreas : Psfileareatype;
          bbsAreaCount : dword;
          bbsAreas : Psbbsareatype;
          routeCount : dword;
          route : Psroute;
          routeFileCount : dword;
          routeFile : Psroute;
          routeMailCount : dword;
          routeMail : Psroute;
          packCount : dword;
          pack : Pspack;
          unpackCount : dword;
          unpack : Psunpack;
          intab : Pchar;
          outtab : Pchar;
          echotosslog : Pchar;
          importlog : Pchar;
          LinkWithImportlog : Pchar;
          lockfile : Pchar;
          fileAreasLog : Pchar;
          longNameList : Pchar;
          fileNewAreasLog : Pchar;
          fileArcList : Pchar;
          filePassList : Pchar;
          fileDupeList : Pchar;
          msgidfile : Pchar;
          carbonCount : dword;
          carbons : Pscarbon;
          carbonAndQuit : dword;
          carbonKeepSb : dword;
          includeFiles : ^Pchar;
          includeCount : dword;
          remapCount : dword;
          remaps : Psremap;
          areafixFromPkt : dword;
          areafixKillReports : dword;
          areafixKillRequests : dword;
          areafixMsgSize : dword;
          areafixSplitStr : Pchar;
          PublicGroup : Pchar;
          ReportTo : Pchar;
          logEchoToScreen : dword;
          separateBundles : dword;
          defarcmailSize : dword;
          afterUnpack : Pchar;
          beforePack : Pchar;
          createDirs : dword;
          longDirNames : dword;
          splitDirs : dword;
          addDLC : dword;
          fileSingleDescLine : dword;
          fileCheckDest : dword;
          filefixKillReports : dword;
          filefixKillRequests : dword;
          fileDescPos : dword;
          DLCDigits : dword;
          fileMaxDupeAge : dword;
          fileFileUMask : dword;
          fileDirUMask : dword;
          fileLocalPwd : Pchar;
          fileLDescString : Pchar;
       end;
     Psfidoconfig = ^sfidoconfig;

  function readConfig:Psfidoconfig;asmname 'readConfig';

  procedure disposeConfig(config:psfidoconfig);

  function getLink(config:sfidoconfig; addr:pchar):Pslink;

  function getLinkFromAddr(config:sfidoconfig; aka:saddr):Pslink;

  function getAddr(config:sfidoconfig; addr:pchar):Psaddr;

  function existAddr(config:sfidoconfig; aka:saddr):longint;

  function getarea(config:psfidoconfig; areaName:pchar):psarea;asmname 'getArea'; 

  { 
     This function return 0 if the link is not linked to the area,
     else it returns 1.
    }
  function isLinkOfArea(link:pslink; area:psarea):longint;

  { 
     This function dumps the config to a file. The file is in fidoconfig format so,
     it is possible to change the config in memory and write it to disk.
     All formatting and comments are removed and the include structure of the config
     cannot be recreated. So be careful. A file called <fileName> which already exists
     will be overwritten.
     1 if there were problems writing the config
     0 else
    }
  function dumpConfigToFile(config:psfidoconfig; fileName:pchar):longint;

(*
  { the following functions are for internal use. }
  { Only use them if you really know what you do. }
  function readLine(F:pFILE):Pchar;

  function parseLine(line:pchar; config:psfidoconfig):longint;

  procedure parseConfig(f:pFILE; config:psfidoconfig);

  function getConfigFileName:Pchar;

*)

  function trimLine(line:pchar):Pchar;
  { 
     This method can be used to get a program-specifically config-filename, in the same directories which are searched for fidoconfig.
     envVar should be set to a string which resembles a environment-variable which should be checked if it includes the fileName.
     configName is the filename of the config  without  any prefixes.
     e.g.
          getConfigFileNameForProgram("FIDOCONFIG", "config");
     is the call which is used for fidoconfig
    }
  function getConfigFileNameForProgram(envVar:pchar; configName:pchar):Pchar;

  function isLinkOfFileArea(link:pslink; area:psfileareatype):longint;

  function getFileArea(config:psfidoconfig; areaName:pchar):Psfileareatype;

(*
  { this function can be used to dump config to stdout or to an already opened file. }
  procedure dumpConfig(config:psfidoconfig; f:pFILE);
*)


implementation

{  function striptwhite(str:pchar):Pchar; external;
  function readConfig:Psfidoconfig; external;
  procedure disposeConfig(config:psfidoconfig); external;
  function getLink(config:sfidoconfig; addr:pchar):Pslink; external;
  function getLinkFromAddr(config:sfidoconfig; aka:saddr):Pslink; external;
  function getAddr(config:sfidoconfig; addr:pchar):Psaddr; external;
  function existAddr(config:sfidoconfig; aka:saddr):longint; external;
  function getarea2(config:psfidoconfig; areaName:pchar):Psarea; asmname 'getarea';
  function isLinkOfArea(link:pslink; area:psarea):longint; external;
  function dumpConfigToFile(config:psfidoconfig; fileName:pchar):longint; external;

  function readLine(F:pFILE):Pchar; external;
  function parseLine(line:pchar; config:psfidoconfig):longint; external;
  procedure parseConfig(f:pFILE; config:psfidoconfig); external;

  function getConfigFileName:Pchar; external;
  function trimLine(line:pchar):Pchar; external;
  function getConfigFileNameForProgram(envVar:pchar; configName:pchar):Pchar; external;
  function isLinkOfFileArea(link:pslink; area:psfileareatype):longint; external;
  function getFileArea(config:psfidoconfig; areaName:pchar):Psfileareatype; external;

  procedure dumpConfig(config:psfidoconfig; f:pFILE); external;
}

end.
