unit fidoconfig;

{  Automatically converted by H2PAS.EXE from h2pas.temp2
   Utility made by Florian Klaempfl 25th-28th september 96
   Improvements made by Mark A. Malakanov 22nd-25th may 97 
   Further improvements by Michael Van Canneyt, April 1998 
   define handling and error recovery by Pierre Muller, June 1998 }


  interface

  { C default packing is dword }

{$PACKRECORDS 4}

 { Pointers to basic pascal types, inserted by h2pas conversion program.}
  Type
     PLongint  = ^Longint;
     PByte     = ^Byte;
     PWord     = ^Word;
     PInteger  = ^Integer;
     PCardinal = ^Cardinal;
     PReal     = ^Real;
     PDouble   = ^Double;






  const
     MSGTYPEPASSTHROUGH = $04;


  const
      a = 5; 


  const
     PATHDELIM = '\\';

  { was #define dname(params) defexpr }
  { argument types are unknown }
  { return type might be wrong }   
  function strend(str : longint) : longint;
    { return type might be wrong }   


    var
       actualLine : pchar;cvar;external;
       actualLineNr : longint;cvar;external;
       wasError : char;cvar;external;

  function striptwhite(str:pchar):pchar;


  type
     Padddr = ^adddr;
     adddr = record
          zone : cardinal;
          net : cardinal;
          node : cardinal;
          point : cardinal;
          domain : pchar;
       end;

     Ppack = ^pack;
     pack = record
          packer : pchar;
          call : pchar;
       end;

     flavour = (normal,hold,crash,direct,immediate);

     forward = (fOff,fSecure,fOn);

     emptypktpwd = (eOff,eSecure,eOn);

     Plink = ^link;
     link = record
          hisAka : adddr;
          ourAka : ^adddr;
          name : pchar;
          defaultPwd : pchar;
          pktPwd : pchar;
          ticPwd : pchar;
          areaFixPwd : pchar;
          fileFixPwd : pchar;
          bbsPwd : pchar;
          sessionPwd : pchar;
          handle : pchar;
          email : pchar;
          autoAreaCreate : longint;
          autoFileCreate : longint;
          AreaFix : longint;
          FileFix : longint;
          forwardRequests : longint;
          fReqFromUpLink : longint;
          allowEmptyPktPwd : longint;
          forwardPkts : forward;
          pktFile : pchar;
          packFile : pchar;
          floFile : pchar;
          bsyFile : pchar;
          packerDef : ^pack;
          echoMailFlavour : flavour;
          LinkGrp : pchar;
          AccessGrp : pchar;
          autoAreaCreateFile : pchar;
          autoFileCreateFile : pchar;
          autoAreaCreateDefaults : pchar;
          autoFileCreateDefaults : pchar;
          forwardRequestFile : pchar;
          RemoteRobotName : pchar;
          msg : pointer;
          Pause : longint;
          autoPause : cardinal;
          level : cardinal;
          arcmailSize : cardinal;
          export : pchar;
          import : pchar;
          mandatory : pchar;
          optGrp : pchar;
       end;

     routing = (host := 1,hub,boss,noroute);

     Proute = ^route;
     route = record
          flavour : flavour;
          enc : char;
          target : ^link;
          routeVia : routing;
          pattern : pchar;
       end;

     dupeCheck = (dcOff,dcMove,dcDel);

     Parealink = ^arealink;
     arealink = record
          link : ^link;
          export : char;
          import : char;
          mandatory : char;
       end;

     Parea = ^area;
     area = record
          areaName : pchar;
          fileName : pchar;
          description : pchar;
          msgbType : longint;
          useAka : ^adddr;
          downlinks : ^parealink;
          downlinkCount : cardinal;
          purge : cardinal;
          max : cardinal;
          dupeSize : cardinal;
          dupeHistory : cardinal;
          keepUnread : char;
          killRead : char;
          dupeCheck : dupeCheck;
          tinySB : char;
          manual : char;
          hide : char;
          noPause : char;
          mandatory : char;
          DOSFile : char;
          levelread : cardinal;
          levelwrite : cardinal;
          dupes : pointer;
          newDupes : pointer;
          imported : cardinal;
          group : char;
          rwgrp : pchar;
          wgrp : pchar;
          rgrp : pchar;
          ccoff : longint;
          uid : cardinal;
          gid : cardinal;
          fperm : cardinal;
          keepsb : longint;
          scn : longint;
       end;

     Psfilearea = ^filearea;
     filearea = record
          areaName : pchar;
          pathName : pchar;
          description : pchar;
          pass : longint;
          useAka : ^adddr;
          downlinks : ^parealink;
          downlinkCount : cardinal;
          levelread : cardinal;
          levelwrite : cardinal;
          manual : char;
          hide : char;
          noPause : char;
          group : char;
          rwgrp : pchar;
          wgrp : pchar;
          rgrp : pchar;
       end;

     Pbbsareatype = ^bbsarea;
     bbsarea = record
          areaName : pchar;
          pathName : pchar;
          description : pchar;
       end;

     carbonType = (too,from,kludge,subject,msgtext);

     Pcarbon = ^carbon;
     carbon = record
          typee : carbonType;
          str : pchar;
          reason : pchar;
          area : ^area;
          areaName : pchar;
          export : longint;
          netMail : longint;
          move : longint;
          extspawn : longint;
       end;

     Punpack = ^unpack;
     unpack = record
          offset : longint;
          matchCode : ^byte;
          mask : ^byte;
          codeSize : longint;
          call : pchar;
       end;

     Premap = ^remap;
     remap = record
          oldadddr : adddr;
          newadddr : adddr;
          toname : pchar;
       end;

     nodelistFormat = (fts5000,points24);

     Pnodelist = ^nodelist;
     nodelist = record
          nodelistName : pchar;
          diffUpdateStem : pchar;
          fullUpdateStem : pchar;
          defaultZone : cardinal;
          format : longint;
       end;

     psfidoconfig = ^sfidoconfig;
     sfidoconfig = record
          cfgVersionMajor : cardinal;
          cfgVersionMinor : cardinal;
          name : pchar;
          location : pchar;
          sysop : pchar;
          adddrCount : cardinal;
          adddr : ^adddr;
          publicCount : cardinal;
          publicDir : ^pchar;
          linkCount : cardinal;
          links : ^link;
          inbound : pchar;
          outbound : pchar;
          protInbound : pchar;
          listInbound : pchar;
          localInbound : pchar;
          tempInbound : pchar;
          logFileDir : pchar;
          dupeHistoryDir : pchar;
          nodelistDir : pchar;
          msgBaseDir : pchar;
          magic : pchar;
          areafixhelp : pchar;
          filefixhelp : pchar;
          tempOutbound : pchar;
          ticOutbound : pchar;
          fileAreaBaseDir : pchar;
          passFileAreaDir : pchar;
          semaDir : pchar;
          badFilesDir : pchar;
          loglevels : pchar;
          dupeArea : area;
          badArea : area;
          netMailAreaCount : cardinal;
          netMailAreas : ^area;
          echoAreaCount : cardinal;
          echoAreas : ^area;
          localAreaCount : cardinal;
          localAreas : ^area;
          fileAreaCount : cardinal;
          fileAreas : ^filearea;
          bbsAreaCount : cardinal;
          bbsAreas : ^bbsarea;
          routeCount : cardinal;
          route : ^route;
          routeFileCount : cardinal;
          routeFile : ^route;
          routeMailCount : cardinal;
          routeMail : ^route;
          packCount : cardinal;
          pack : ^pack;
          unpackCount : cardinal;
          unpack : ^unpack;
          intab : pchar;
          outtab : pchar;
          echotosslog : pchar;
          importlog : pchar;
          LinkWithImportlog : pchar;
          lockfile : pchar;
          loguid : longint;
          loggid : longint;
          logperm : longint;
          fileAreasLog : pchar;
          longNameList : pchar;
          fileNewAreasLog : pchar;
          fileArcList : pchar;
          filePassList : pchar;
          fileDupeList : pchar;
          msgidfile : pchar;
          carbonCount : cardinal;
          carbons : ^carbon;
          carbonAndQuit : cardinal;
          carbonKeepSb : cardinal;
          includeFiles : ^pchar;
          includeCount : cardinal;
          remapCount : cardinal;
          remaps : ^remap;
          areafixFromPkt : cardinal;
          areafixKillReports : cardinal;
          areafixKillRequests : cardinal;
          areafixMsgSize : cardinal;
          areafixSplitStr : pchar;
          PublicGroup : pchar;
          ReportTo : pchar;
          logEchoToScreen : cardinal;
          separateBundles : cardinal;
          defarcmailSize : cardinal;
          afterUnpack : pchar;
          beforePack : pchar;
          createDirs : cardinal;
          longDirNames : cardinal;
          splitDirs : cardinal;
          addDLC : cardinal;
          fileSingleDescLine : cardinal;
          fileCheckDest : cardinal;
          filefixKillReports : cardinal;
          filefixKillRequests : cardinal;
          fileDescPos : cardinal;
          DLCDigits : cardinal;
          fileMaxDupeAge : cardinal;
          fileFileUMask : cardinal;
          fileDirUMask : cardinal;
          fileLocalPwd : pchar;
          fileLDescString : pchar;
          nodelistCount : cardinal;
          nodelists : ^nodelist;
          fidoUserList : pchar;
       end;


  function readConfig:psfidoconfig;

  procedure disposeConfig(config:psfidoconfig);

  function getLink(config:sfidoconfig; adddr:pchar):plink;

  function getLinkFromAddr(config:sfidoconfig; aka:adddr):plink;

  function getAddr(config:sfidoconfig; adddr:pchar):padddr;

  function existAddr(config:sfidoconfig; aka:adddr):longint;

  function getArea(config:psfidoconfig; areaName:pchar):parea;

  function getNetMailArea(config:psfidoconfig; areaName:pchar):parea;

  function isLinkOfArea(link:plink; area:parea):longint;

  function dumpConfigToFile(config:psfidoconfig; fileName:pchar):longint;

  function readLine(F:file):pchar;

  function parseLine(line:pchar; config:psfidoconfig):longint;

  procedure parseConfig(f:file; config:psfidoconfig);

  function getConfigFileName:pchar;

  function trimLine(line:pchar):pchar;

  function getConfigFileNameForProgram(envVar:pchar; configName:pchar):pchar;

  function isLinkOfFileArea(link:plink; area:psfilearea):longint;

  function getFileArea(config:psfidoconfig; areaName:pchar):psfilearea;

  procedure dumpConfig(config:psfidoconfig; f:file);



  implementation

const Externallibrary='fidoconfig'; {Setup as you need!}

  { was #define dname(params) defexpr }
  { argument types are unknown }
  { return type might be wrong }   
  function strend(str : longint) : longint;
    { return type might be wrong }   
    begin
       strend:=3;
    end;

  function striptwhite(str:pchar):pchar;
external 'fidoconfig';
  function readConfig:psfidoconfig;
external 'fidoconfig';
  procedure disposeConfig(config:psfidoconfig);
external 'fidoconfig';
  function getLink(config:sfidoconfig; adddr:pchar):plink;
external 'fidoconfig';
  function getLinkFromAddr(config:sfidoconfig; aka:adddr):plink;
external 'fidoconfig';
  function getAddr(config:sfidoconfig; adddr:pchar):padddr;
external 'fidoconfig';
  function existAddr(config:sfidoconfig; aka:adddr):longint;
external 'fidoconfig';
  function getArea(config:psfidoconfig; areaName:pchar):parea;
external 'fidoconfig';
  function getNetMailArea(config:psfidoconfig; areaName:pchar):parea;
external 'fidoconfig';
  function isLinkOfArea(link:plink; area:parea):longint;
external 'fidoconfig';
  function dumpConfigToFile(config:psfidoconfig; fileName:pchar):longint;
external 'fidoconfig';
  function readLine(F:file):pchar;
external 'fidoconfig';
  function parseLine(line:pchar; config:psfidoconfig):longint;
external 'fidoconfig';
  procedure parseConfig(f:file; config:psfidoconfig);
external 'fidoconfig';
  function getConfigFileName:pchar;
external 'fidoconfig';
  function trimLine(line:pchar):pchar;
external 'fidoconfig';
  function getConfigFileNameForProgram(envVar:pchar; configName:pchar):pchar;
external 'fidoconfig';
  function isLinkOfFileArea(link:plink; area:psfilearea):longint;
external 'fidoconfig';
  function getFileArea(config:psfidoconfig; areaName:pchar):psfilearea;
external 'fidoconfig';
  procedure dumpConfig(config:psfidoconfig; f:file);
external 'fidoconfig';

end.
