unit fidoconf;

{  Automatically converted by H2PAS.EXE from fidoconf.h
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
     PDouble   = ^Double; PFile = ^File; PPChar = ^PChar;

{$ifndef FIDOCONFIG_H}
{$define FIDOCONFIG_H}

  const
     MSGTYPE_PASSTHROUGH = $04;
{$ifdef UNIX}

  const
     PATH_DELIM = '/';
{$else}

  const
     PATH_DELIM = '\\';
{$endif}
  { was #define dname(params) def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function strend(str : pchar) : pchar;
    { return type might be wrong }   



  function striptwhite(str:pchar):pchar;cdecl;


  type

     s_addr = record
          zone : cardinal;
          net : cardinal;
          node : cardinal;
          point : cardinal;
          domain : pchar;
       end;

     ps_addr = ^s_addr;

     addr = s_addr;

     s_pack = record
          packer : pchar;
          call : pchar;
       end;

     ps_pack = ^s_pack;

     pack = s_pack;

     s_execonfile = record
          filearea : pchar;
          filename : pchar;
          command : pchar;
       end;

     ps_execonfile = ^s_execonfile;

     execonfile = s_execonfile;

     e_flavour = (normal,hold,crash,direct,immediate);

     flavour = e_flavour;

     e_forward = (fOff,fSecure,fOn);

     _forward = e_forward;

     e_emptypktpwd = (eOff,eSecure,eOn);

     emptypktpwd = e_emptypktpwd;

     e_pktheaderdiffer = (pdOff,pdOn);

     pktheaderdiffer = e_pktheaderdiffer;

     e_nameCase = (eLower,eUpper);

     nameCase = e_nameCase;

     s_link = record
          hisAka : s_addr;
          ourAka : ^s_addr;
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
          autoAreaCreate : cardinal;
          autoFileCreate : cardinal;
          AreaFix : cardinal;
          FileFix : cardinal;
          forwardRequests : cardinal;
          fReqFromUpLink : cardinal;
          allowEmptyPktPwd : longint;
          allowPktAddrDiffer : longint;
          forwardPkts : e_forward;
          pktFile : pchar;
          packFile : pchar;
          floFile : pchar;
          bsyFile : pchar;
          packerDef : ps_pack;
          echoMailFlavour : e_flavour;
          fileEchoFlavour : e_flavour;
          LinkGrp : pchar;
          AccessGrp : ^pchar;
          numAccessGrp : cardinal;
          autoAreaCreateFile : pchar;
          autoFileCreateFile : pchar;
          autoAreaCreateDefaults : pchar;
          autoFileCreateDefaults : pchar;
          forwardRequestFile : pchar;
          RemoteRobotName : pchar;
          msg : pointer;
          noTIC : cardinal;
          Pause : cardinal;
          autoPause : cardinal;
          level : cardinal;
          arcmailSize : cardinal;
          pktSize : cardinal;
          export : cardinal;
          import : cardinal;
          mandatory : cardinal;
          optGrp : ^pchar;
          numOptGrp : cardinal;
       end;

     ps_link = ^s_link;

     link = s_link;

     e_routing = (route_zero,host,hub,boss,noroute);

     routing = e_routing;

     s_route = record
          flavour : e_flavour;
          enc : char;
          target : ps_link;
          routeVia : e_routing;
          pattern : pchar;
          viaStr : pchar;
       end;

     ps_route = ^s_route;

     route = s_route;

     e_dupeCheck = (dcOff,dcMove,dcDel);

     dupeCheck = e_dupeCheck;

     s_arealink = record
          link : ps_link;
          export : cardinal;
          import : cardinal;
          mandatory : cardinal;
       end;

     ps_arealink = ^s_arealink;

     arealink = s_arealink;

     s_area = record
          areaName : pchar;
          fileName : pchar;
          description : pchar;
          msgbType : longint;
          useAka : ps_addr;
          downlinks : ^ps_arealink;
          downlinkCount : cardinal;
          purge : cardinal;
          max : cardinal;
          dupeSize : cardinal;
          dupeHistory : cardinal;
          keepUnread : char;
          killRead : char;
          dupeCheck : e_dupeCheck;
          tinySB : char;
          hide : char;
          noPause : char;
          mandatory : char;
          DOSFile : char;
          levelread : cardinal;
          levelwrite : cardinal;
          dupes : pointer;
          newDupes : pointer;
          imported : cardinal;
          group : pchar;
          ccoff : longint;
          uid : cardinal;
          gid : cardinal;
          fperm : cardinal;
          nolink : longint;
          keepsb : longint;
          scn : longint;
          nopack : longint;
       end;

     ps_area = ^s_area;

     area = s_area;

     s_filearea = record
          areaName : pchar;
          pathName : pchar;
          description : pchar;
          sendorig : longint;
          pass : longint;
          noCRC : longint;
          useAka : ps_addr;
          downlinks : ^ps_arealink;
          downlinkCount : cardinal;
          levelread : cardinal;
          levelwrite : cardinal;
          mandatory : char;
          hide : char;
          noPause : char;
          group : pchar;
       end;

     ps_filearea = ^s_filearea;

     fileareatype = s_filearea;

     s_bbsarea = record
          areaName : pchar;
          pathName : pchar;
          description : pchar;
       end;

     ps_bbsarea = ^s_bbsarea;

     bbsareatype = s_bbsarea;

     e_carbonType = (ct_to,ct_from,ct_kludge,ct_subject,ct_msgtext
       );

     carbonType = e_carbonType;

     s_carbon = record
          ctype : e_carbonType;
          str : pchar;
          reason : pchar;
          area : ps_area;
          areaName : pchar;
          export : longint;
          netMail : longint;
          move : longint;
          extspawn : longint;
       end;

     ps_carbon = ^s_carbon;

     carbon = s_carbon;

     s_unpack = record
          offset : longint;
          matchCode : ^byte;
          mask : ^byte;
          codeSize : longint;
          call : pchar;
       end;

     ps_unpack = ^s_unpack;

     unpack = s_unpack;

     s_remap = record
          oldaddr : s_addr;
          newaddr : s_addr;
          toname : pchar;
       end;

     ps_remap = ^s_remap;

     remap = s_remap;

     e_nodelistFormat = (fts5000,points24);

     nodelistFormat = e_nodelistFormat;

     s_nodelist = record
          nodelistName : pchar;
          diffUpdateStem : pchar;
          fullUpdateStem : pchar;
          defaultZone : cardinal;
          format : longint;
       end;

     ps_nodelist = ^s_nodelist;

     nodelist = s_nodelist;

     e_typeDupeCheck = (hashDupes,hashDupesWmsgid,textDupes,commonDupeBase
       );

     typeDupeCheck = e_typeDupeCheck;

     s_savetic = record
          fileAreaNameMask : pchar;
          pathName : pchar;
       end;

     ps_savetic = ^s_savetic;

     savetictype = s_savetic;

     s_fidoconfig = record
          cfgVersionMajor : cardinal;
          cfgVersionMinor : cardinal;
          name : pchar;
          location : pchar;
          sysop : pchar;
          addrCount : cardinal;
          addr : ps_addr;
          publicCount : cardinal;
          publicDir : ^pchar;
          linkCount : cardinal;
          links : ps_link;
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
          busyFileDir : pchar;
          semaDir : pchar;
          badFilesDir : pchar;
          loglevels : pchar;
          dupeArea : s_area;
          badArea : s_area;
          netMailAreaCount : cardinal;
          netMailAreas : ps_area;
          echoAreaCount : cardinal;
          echoAreas : ps_area;
          localAreaCount : cardinal;
          localAreas : ps_area;
          fileAreaCount : cardinal;
          fileAreas : ps_filearea;
          bbsAreaCount : cardinal;
          bbsAreas : ps_bbsarea;
          routeCount : cardinal;
          route : ps_route;
          routeFileCount : cardinal;
          routeFile : ps_route;
          routeMailCount : cardinal;
          routeMail : ps_route;
          packCount : cardinal;
          pack : ps_pack;
          unpackCount : cardinal;
          unpack : ps_unpack;
          intab : pchar;
          outtab : pchar;
          echotosslog : pchar;
          importlog : pchar;
          LinkWithImportlog : pchar;
          lockfile : pchar;
          loguid : cardinal;
          loggid : cardinal;
          logperm : cardinal;
          fileAreasLog : pchar;
          longNameList : pchar;
          fileNewAreasLog : pchar;
          fileArcList : pchar;
          filePassList : pchar;
          fileDupeList : pchar;
          msgidfile : pchar;
          carbonCount : cardinal;
          carbons : ps_carbon;
          carbonAndQuit : cardinal;
          carbonKeepSb : cardinal;
          includeFiles : ^pchar;
          includeCount : cardinal;
          remapCount : cardinal;
          remaps : ps_remap;
          areafixFromPkt : cardinal;
          areafixKillReports : cardinal;
          areafixKillRequests : cardinal;
          areafixMsgSize : cardinal;
          areafixSplitStr : pchar;
          areafixOrigin : pchar;
          PublicGroup : ^pchar;
          numPublicGroup : cardinal;
          ReportTo : pchar;
          execonfileCount : cardinal;
          execonfile : ps_execonfile;
          logEchoToScreen : cardinal;
          separateBundles : cardinal;
          defarcmailSize : cardinal;
          ignoreCapWord : cardinal;
          noProcessBundles : cardinal;
          disableTID : cardinal;
          afterUnpack : pchar;
          beforePack : pchar;
          processPkt : pchar;
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
          originInAnnounce : cardinal;
          MaxTicLineLength : cardinal;
          fileLocalPwd : pchar;
          fileLDescString : pchar;
          saveTicCount : cardinal;
          saveTic : ps_savetic;
          nodelistCount : cardinal;
          nodelists : ps_nodelist;
          fidoUserList : pchar;
          typeDupeBase : e_typeDupeCheck;
          areasMaxDupeAge : cardinal;
          linkDefaults : ps_link;
          describeLinkDefaults : longint;
          createAreasCase : e_nameCase;
          areasFileNameCase : e_nameCase;
          tossingExt : pchar;
       end;

     ps_fidoconfig = ^s_fidoconfig;

     fidoconfig = s_fidoconfig;

  function readConfig:ps_fidoconfig;cdecl;

  procedure disposeConfig(config:ps_fidoconfig);cdecl;

  function getLink(config:s_fidoconfig; addr:pchar):ps_link;cdecl;

  function getLinkForArea(config:s_fidoconfig; addr:pchar; area:ps_area):ps_link;cdecl;

  function getLinkFromAddr(config:s_fidoconfig; aka:s_addr):ps_link;cdecl;

  function getAddr(config:s_fidoconfig; addr:pchar):ps_addr;cdecl;

  function existAddr(config:s_fidoconfig; aka:s_addr):longint;cdecl;

  function getArea(config:ps_fidoconfig; areaName:pchar):ps_area;cdecl;

  function getEchoArea(config:ps_fidoconfig; areaName:pchar):ps_area;cdecl;

  function getNetMailArea(config:ps_fidoconfig; areaName:pchar):ps_area;cdecl;

  function isLinkOfArea(link:ps_link; area:ps_area):longint;cdecl;

  function dumpConfigToFile(config:ps_fidoconfig; fileName:pchar):longint;cdecl;

  function readLine(F:pFILE):pchar;cdecl;

  function parseLine(line:pchar; config:ps_fidoconfig):longint;cdecl;

  procedure parseConfig(f:pFILE; config:ps_fidoconfig);cdecl;

  function getConfigFileName:pchar;cdecl;

  function trimLine(line:pchar):pchar;cdecl;

  procedure carbonNames2Addr(config:ps_fidoconfig);cdecl;

  function getConfigFileNameForProgram(envVar:pchar; configName:pchar):pchar;cdecl;

  function isLinkOfFileArea(link:ps_link; area:ps_filearea):longint;cdecl;

  function getFileArea(config:ps_fidoconfig; areaName:pchar):ps_filearea;cdecl;

  procedure dumpConfig(config:ps_fidoconfig; f:pFILE);cdecl;

  function grpInArray(group:pchar; strarray:ppchar; len:cardinal):longint;cdecl;

{$endif}

  implementation

const External_library='fidoconfig'; {Setup as you need!}

  { was #define dname(params) def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function strend(str : pchar) : pchar;
    { return type might be wrong }   
    begin
       strend:=(str + (strlen(str))) - 1;
    end;

  function striptwhite(str:pchar):pchar;cdecl;external;

  function readConfig:ps_fidoconfig;cdecl;external;

  procedure disposeConfig(config:ps_fidoconfig);cdecl;external;

  function getLink(config:s_fidoconfig; addr:pchar):ps_link;cdecl;external;

  function getLinkForArea(config:s_fidoconfig; addr:pchar; area:ps_area):ps_link;cdecl;external;

  function getLinkFromAddr(config:s_fidoconfig; aka:s_addr):ps_link;cdecl;external;

  function getAddr(config:s_fidoconfig; addr:pchar):ps_addr;cdecl;external;

  function existAddr(config:s_fidoconfig; aka:s_addr):longint;cdecl;external;

  function getArea(config:ps_fidoconfig; areaName:pchar):ps_area;cdecl;external;

  function getEchoArea(config:ps_fidoconfig; areaName:pchar):ps_area;cdecl;external;

  function getNetMailArea(config:ps_fidoconfig; areaName:pchar):ps_area;cdecl;external;

  function isLinkOfArea(link:ps_link; area:ps_area):longint;cdecl;external;

  function dumpConfigToFile(config:ps_fidoconfig; fileName:pchar):longint;cdecl;external;

  function readLine(F:pFILE):pchar;cdecl;external;

  function parseLine(line:pchar; config:ps_fidoconfig):longint;cdecl;external;

  procedure parseConfig(f:pFILE; config:ps_fidoconfig);cdecl;external;

  function getConfigFileName:pchar;cdecl;external;

  function trimLine(line:pchar):pchar;cdecl;external;

  procedure carbonNames2Addr(config:ps_fidoconfig);cdecl;external;

  function getConfigFileNameForProgram(envVar:pchar; configName:pchar):pchar;cdecl;external;

  function isLinkOfFileArea(link:ps_link; area:ps_filearea):longint;cdecl;external;

  function getFileArea(config:ps_fidoconfig; areaName:pchar):ps_filearea;cdecl;external;

  procedure dumpConfig(config:ps_fidoconfig; f:pFILE);cdecl;external;

  function grpInArray(group:pchar; strarray:ppchar; len:cardinal):longint;cdecl;external;


end.
