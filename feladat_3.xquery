(:A lekérdezés visszaadja egy objektumban a csapatok nevét, illetve az általuk elért átlagos sebességet:)

xquery version "3.1";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";

declare option output:method "json";
declare option output:indent "yes";

let $file := doc('f1.xml')
let $map := map:merge(for $constructor in $file/RaceTable/Race/ResultsList/Result/Constructor/Name//text()
return
    map:entry($constructor, avg($file/RaceTable/Race/ResultsList/Result[Constructor/Name//text() = $constructor]/FastestLap/AverageSpeed)))
return
    $map

