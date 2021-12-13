(:A lekérdezés egy olyan XML dokumentumot állít elő, amely visszaadja a futamokat, illetve a futamok győzteseit, a földrajzi hosszúsági köröket tekintve Magyarországtól való távolság alapján csökkenő sorrendben.:)

xquery version "3.1";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace validate = "http://basex.org/modules/validate";

declare option output:method "xml";
declare option output:indent "yes";

declare variable $file := doc("f1.xml");

let $hungary := for $race in $file/RaceTable/Race where $race/Circuit[@circuitId = "hungaroring"] return xs:decimal($race/Circuit/Location/@long)
let $distancefromhungary := map:merge(for $race in $file/RaceTable/Race return map:entry($race/RaceName//text(), fn:abs($hungary - xs:decimal($race/Circuit/Location/@long))))

let $xml :=  <RaceTable>
    {for $key in map:keys($distancefromhungary) order by  map:get($distancefromhungary, $key) descending return <race racename="{$key}" distance="{map:get($distancefromhungary, $key)}">
        {for $race in $file/RaceTable/Race where $race/RaceName = $key return <winner number="{for $result in $race/ResultsList/Result where $result[@position = 1] return xs:integer($result/@number)}">{for $result in $race/ResultsList/Result where $result[@position = 1] return $result/Driver/GivenName//text() || ' ' || $result/Driver/FamilyName//text()}</winner>}
    </race> }
</RaceTable>

let $error := validate:xsd-report($xml, "feladat_8.xsd")
return
    if (fn:contains($error, "invalid"))
    then $error
    else $xml