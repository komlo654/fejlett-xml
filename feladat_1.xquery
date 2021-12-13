(:A lekérdezés visszaadja a versenyek számát.:)

xquery version "3.1";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:indent "yes";

let $file := doc('f1.xml')
return count($file/RaceTable/Race)
