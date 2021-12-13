(:A lekérdezés visszaadja, hogy csapatonként az egyes pilóták hány kört teljesítettek az évben, hogy melyik volt a legjobb elért eredményük, illetve a hozzájuk tartozó id-t:)

xquery version "3.1";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";

declare option output:method "json";
declare option output:indent "yes";

declare variable $file := doc('f1.xml');

declare function local:get-driverinfo($teamname as xs:string) {
    let $driverinfo := map:merge(for $driver in $file/RaceTable/Race/ResultsList/Result where $driver/Constructor/Name = $teamname
    return
       map:entry($driver/Driver/GivenName//text() || " " || $driver/Driver/FamilyName//text(), map:put(map:put(map:entry('laps', sum(for $result in $file/RaceTable/Race/ResultsList/Result where $result/Driver[@driverId = $driver/Driver/@driverId] return $result/Laps//text())), "highest rank", min(for $result in $file/RaceTable/Race/ResultsList/Result where $result/Driver[@driverId = $driver/Driver/@driverId] return $result/@position)), 'id', distinct-values(for $result in $file/RaceTable/Race/ResultsList/Result where $result/Driver[@driverId = $driver/Driver/@driverId] return $result/Driver/@driverId))))
    return $driverinfo 
};

declare function local:get-teams(){
    let $map := map:merge(for $constructor in $file/RaceTable/Race/ResultsList/Result/Constructor/Name//text()
    return
        map:entry($constructor, local:get-driverinfo($constructor)))
    return
        $map
};

local:get-teams()

