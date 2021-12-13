(:A lekérdezés egy XML dokumentumot állít elő, amely tartalmazza az adott versenyeken pontot szerző pilótákat, valamint a pilótákhoz, illetve a pozíciókhoz tartozó adatokat.:)

xquery version "3.1";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace validate = "http://basex.org/modules/validate";

declare option output:method "xml";
declare option output:indent "yes";

declare variable $file := doc("f1.xml");

let $names := map:merge(for $result in $file/RaceTable/Race/ResultsList/Result return map:entry($result/@number, $result/Driver/GivenName//text() || " " || $result/Driver/FamilyName//text()))
let $datesofbirth := map:merge(for $result in $file/RaceTable/Race/ResultsList/Result return map:entry($result/@number, $result/Driver/DateOfBirth//text()))
let $nationality := map:merge(for $result in $file/RaceTable/Race/ResultsList/Result return map:entry($result/@number, $result/Driver/Nationality//text()))

let $xml := 
    <season year="{$file/RaceTable/@season}">
        <races count="{count($file/RaceTable/Race)}">
            {for $race in $file/RaceTable/Race return <race round="{$race/@round}" name="{$race/RaceName//text()}">
                {for $result in $race/ResultsList/Result where $result[@points != 0] return <position number="{$result/@position}" points="{$result/@points}" fastest_lap = "{$result/FastestLap/Time//text()}">
                    {for $key in map:keys($names) where $key = $result/@number return <driver number="{$key}">
                        <name>{map:get($names, $key)}</name>
                        {for $key in map:keys($datesofbirth) where $key = $result/@number return <dateofbirth>{map:get($datesofbirth, $key)}</dateofbirth>}
                        {for $key in map:keys($nationality) where $key = $result/@number return <nationality>{map:get($nationality, $key)}</nationality>}
                    </driver>} 
                </position>}
            </race>}
        </races>
    </season>

let $error := validate:xsd-report($xml, "feladat_6.xsd")
return
    if (fn:contains($error, "invalid"))
    then $error
    else $xml