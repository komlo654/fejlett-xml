(:A lekérdezés egy olyan XML dokumentumot állít elő, amely kilistázza, hogy az adott hónapban mely pilóták születtek.:)

xquery version "3.1";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace validate = "http://basex.org/modules/validate";

declare option output:method "xml";
declare option output:indent "yes";

declare variable $file := doc("f1.xml");

let $datesofbirth := map:merge(for $result in $file/RaceTable/Race/ResultsList/Result return map:entry($result/@number, $result/Driver/DateOfBirth//text()))
let $count := map:merge(for $key in map:keys($datesofbirth) return map:entry(fn:month-from-date(map:get($datesofbirth, $key)), count(for $k in map:keys($datesofbirth) where fn:month-from-date(map:get($datesofbirth, $k))  = fn:month-from-date(map:get($datesofbirth, $key)) return $k)))
let $numbers := map:merge(for $result in $file/RaceTable/Race/ResultsList/Result return map:entry($result/@number, $result/Driver/GivenName || ' ' || $result/Driver/FamilyName))
let $months := map{ 1: 'January', 2: 'February', 3: 'March', 4: 'April', 5: 'May', 6: 'June', 7: 'July', 8: 'August', 9: 'September', 10: 'October', 11: 'November', 12: 'December' }

let $xml := <months>
    {for $key in map:keys($count) return <month id="{$key}" name="{map:get($months, $key)}" count="{map:get($count, $key)}">
        {for $number in map:keys($datesofbirth) where fn:month-from-date(map:get($datesofbirth, $number)) = $key return <driver number="{$number}">{map:get($numbers, $number)}</driver>}
    </month>}
</months>

let $error := validate:xsd-report($xml, "feladat_7.xsd")
return
    if (fn:contains($error, "invalid"))
    then $error
    else $xml