type
 terrorcodes=record nr:word; s:string[255]; end;
const
errorcodes:array[1..46] of terrorcodes=
      ((nr:1;s:'Ungltiger DOS-Funktionscode.'),(nr:
      2;s:'Datei nicht gefunden. '),(nr:
      3;s:'Pfad nicht gefunden.'),(nr:
      4;s:'Zu viele Dateien ge”ffnet.'),(nr:
      5;s:'Zugriff auf Datei verweigert.'),(nr:
      6;s:'Ungltiges Datei-Handle.'),(nr:
     12;s:'Ungltiger Zugriffscode.'),(nr:
     15;s:'Ungltiges Laufwerk.'),(nr:
     16;s:'Aktuelles Verzeichnis kann nicht gel”scht werden.'),(nr:
     17;s:'Umbenennen ber Laufwerke hinweg nicht erlaubt.'),(nr:
     18;s:'Keine weiteren Dateien.'),(nr:
    100;s:'Lesefehler von Diskette/Platte.'),(nr:
    101;s:'Schreibfehler auf Diskette/Platte.'),(nr:
    102;s:'Dateivariable ist keiner Datei zugeordnet.'),(nr:
    103;s:'Datei nicht ge”ffnet.'),(nr:
    104;s:'Datei nicht fr Eingabe ge”ffnet.'),(nr:
    105;s:'Datei nicht fr Ausgabe ge”ffnet.'),(nr:
    106;s:'Ungltiges numerisches Format.'),(nr:
    150;s:'Disk oder Datei ist schreibgeschtzt oder ist in Benutzung.'),(nr:
    151;s:'Peripherieger„t nicht bekannt/nicht angeschlossen.'),(nr:
    152;s:'Laufwerk nicht bereit.'),(nr:
    154;s:'CRC-Fehler in Daten.'),(nr:
    156;s:'Seek-Fehler auf Diskette/Platte.'),(nr:
    157;s:'Unbekanntes Sektorformat.'),(nr:
    158;s:'Sektor nicht gefunden.'),(nr:
    159;s:'Drucker hat kein Papier.'),(nr:
    160;s:'Fehler beim Schreiben auf Peripherieger„t.'),(nr:
    161;s:'Fehler beim Lesen von einem Peripherieger„t.'),(nr:
    162;s:'Hardware-Fehler.'),(nr:
    200;s:'Division durch Null.'),(nr:
    201;s:'Bereichsberschreitung.'),(nr:
    202;s:'Stack-šberlauf.'),(nr:
    203;s:'Heap-šberlauf.'),(nr:
    204;s:'Ungltige Zeiger-Operation.'),(nr:
    205;s:'šberlauf bei Gleitkomma-Operation.'),(nr:
    206;s:'Unterlauf bei Gleitkomma-Operation.'),(nr:
    207;s:'Fehler bei Gleitkomma-Operation.'),(nr:
    208;s:'Overlay-Manager nicht installiert.'),(nr:
    209;s:'Lesefehler bei Overlay-Datei.'),(nr:
    210;s:'Objekt nicht initialisiert.'),(nr:
    211;s:'Aufruf einer abstrakten Methode.'),(nr:
    212;s:'Fehler bei Stream-Registrierung.'),(nr:
    213;s:'Collection-Index auáerhalb des gltigen Bereichs.'),(nr:
    214;s:'Collection-šberlauf.'),(nr:
    215;s:'Arithmetik-šberlauf.'),(nr:
    216;s:'Schutzfehler.')
);