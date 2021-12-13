(:A lekérdezés visszaadja a versenyzők nevét egy tömbben:)

xquery version "3.1";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";

declare option output:method "json";
declare option output:indent "yes";

let $file := doc('f1.xml')

return
    array {
        distinct-values(
            for $driver in $file/RaceTable/Race/ResultsList/Result/Driver
                return concat($driver/GivenName//text(), " ", $driver/FamilyName//text())
        )
    }
