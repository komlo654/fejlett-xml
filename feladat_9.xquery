(:A lekérdezés egy olyan XML dokumentumot állít elő, amely visszaadja a versenyzőket, számuk szerint növekvő sorrendben. Visszaadja továbbá a versenyzőkhöz tartozó státuszok darabszámát, amelyeket az év során elértek a különböző versenyeken.:)

xquery version "3.1";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";
declare namespace validate = "http://basex.org/modules/validate";

declare option output:method "xml";
declare option output:indent "yes";

declare variable $file := doc("f1.xml");

declare function local:get-statuses($number as xs:integer) {
    let $statuses := array { for $race in $file/RaceTable/Race return $race/ResultsList/Result[@number = $number]/Status//text()}
    return $statuses
};

declare function local:get-count($number as xs:integer, $statusname as xs:string) {
    let $count := array:size(array:filter(local:get-statuses($number), function($item) {$item = $statusname}))
    return $count
};

declare function local:get-dataaboutdriver($number as xs:integer) {
    let $data := map:merge(for $status in array:flatten(local:get-statuses($number)) return map:entry($status, local:get-count($number, $status)))
    return $data
};

declare function local:get-drivers(){
    let $drivers := array { distinct-values(for $result in $file/RaceTable/Race/ResultsList/Result return $result/@number) }
    return $drivers
};

declare function local:get-code($number as xs:integer) {
    let $code := map:merge(for $result in $file/RaceTable/Race/ResultsList/Result where $result[@number = $number] return map:entry($number, xs:string($result/Driver/@code)))
    return $code
};

declare function local:generate-xml() {
    let $xml := <drivers>
        {for $number in array:flatten(local:get-drivers()) order by xs:integer($number) return <driver number="{$number}" code="{map:get(local:get-code($number), xs:integer($number))}">
            {for $status in map:keys(local:get-dataaboutdriver($number)) order by map:get(local:get-dataaboutdriver($number), $status) descending return <status count="{map:get(local:get-dataaboutdriver($number), $status)}">{$status}</status>}
        </driver> }
    </drivers>
    let $error := validate:xsd-report($xml, "feladat_9.xsd")
    return
        if (fn:contains($error, "invalid"))
        then $error
        else $xml 
};

local:generate-xml()