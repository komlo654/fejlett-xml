xquery version "3.1";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace array = "http://www.w3.org/2005/xpath-functions/array";

declare option output:method "html";
declare option output:indent "yes";

declare variable $file := doc("f1.xml");

declare function local:get-points() {
    let $points := map:merge(for $result in $file/RaceTable/Race/ResultsList/Result return map:entry(xs:integer($result/@number), sum(for $r in $file/RaceTable/Race/ResultsList/Result where $r[@number = xs:integer($result/@number)] return xs:integer($r/@points))))
    return $points
};

declare function local:get-driverinfo($number as xs:integer) {
    let $points := map:merge(for $result in $file/RaceTable/Race/ResultsList/Result where $result[@number = $number] return map:put(map:put(map:put(map:put(map:entry('name',  $result/Driver/GivenName//text() || ' ' || $result/Driver/FamilyName//text()), 'dob', $result/Driver/DateOfBirth//text()), 'nationality', $result/Driver/Nationality//text()), 'url', xs:string($result/Driver/@url)), 'car', $result/Constructor/Name//text()))
    return $points
};

declare function local:get-drivers() {
    let $drivers := map:merge(for $result in $file/RaceTable/Race/ResultsList/Result return map:entry(xs:integer($result/@number), local:get-driverinfo(xs:integer($result/@number))))
    return $drivers
};

declare function local:get-const-points() {
    let $points := map:merge(for $result in $file/RaceTable/Race/ResultsList/Result return map:entry(xs:string($result/Constructor/@constructorId), sum(for $r in $file/RaceTable/Race/ResultsList/Result where $r/Constructor[@constructorId = xs:string($result/Constructor/@constructorId)] return xs:integer($r/@points))))
    return $points
};

declare function local:get-constructorinfo($constructorId as xs:string) {
    let $constructors := map:merge(for $result in $file/RaceTable/Race/ResultsList/Result where $result/Constructor[@constructorId = $constructorId] return map:put(map:put(map:entry('name',  $result/Constructor/Name//text()), 'nationality', $result/Constructor/Nationality//text()), 'url', xs:string($result/Constructor/@url)))
    return $constructors
};

declare function local:get-constructors() {
    let $drivers := map:merge(for $result in $file/RaceTable/Race/ResultsList/Result return map:entry(xs:string($result/Constructor/@constructorId), local:get-constructorinfo(xs:string($result/Constructor/@constructorId))))
    return $drivers
};

declare function local:get-year(){ 
    let $year := xs:integer($file/RaceTable/@season)
    return $year
};

declare function local:get-orderednumbers() {
    let $numbers := array { for $key in map:keys(local:get-points()) order by local:get-points()($key) descending return $key }
    return $numbers
};

declare function local:get-orderedconstructors() {
    let $constructors := array { for $key in map:keys(local:get-const-points()) order by local:get-const-points()($key) descending return $key }
    return $constructors
};

declare function local:generate-html() {
    let $html := document{ 
        <html>
            <head>
                <link rel="stylesheet" href="style.css"/>
            </head>
            <body>
            <div class="wrapper">
                <h1>Formula-1</h1>
                <h2>Driver Standings ({local:get-year()})</h2>
                <table>
                    <thead>
                        <tr>
                            <th class="table-dark">Position</th>
                            <th class="table-dark">Number</th>
                            <th class="table-dark">Name</th>
                            <th class="table-dark">Date of Birth</th>
                            <th class="table-dark">Nationality</th>
                            <th class="table-dark">Car</th>
                            <th class="table-dark">Points</th>
                        </tr>
                    </thead>
                    <tbody>
                        {for $key at $position in array:flatten(local:get-orderednumbers()) return <tr><td>{$position}</td><td>{$key}</td><td><a target="_blank" href="{local:get-drivers()($key)('url')}">{local:get-drivers()($key)('name')}</a></td><td>{local:get-drivers()($key)('dob')}</td><td>{local:get-drivers()($key)('nationality')}</td><td>{local:get-drivers()($key)('car')}</td><td>{local:get-points()($key)}</td></tr>}
                    </tbody>
                </table>
                <h2>Constructor Standings ({local:get-year()})</h2>
                <table>
                    <thead>
                        <tr>
                            <th class="table-dark">Position</th>
                            <th class="table-dark">Name</th>
                            <th class="table-dark">Nationality</th>
                            <th class="table-dark">Points</th>
                        </tr>
                    </thead>
                    <tbody>
                        {for $key at $position in array:flatten(local:get-orderedconstructors()) return <tr><td>{$position}</td><td><a target="_blank" href="{local:get-constructors()($key)('url')}">{local:get-constructors()($key)('name')}</a></td><td>{local:get-constructors()($key)('nationality')}</td><td>{local:get-const-points()($key)}</td></tr>}
                    </tbody>
                </table>
                </div>
            </body>
        </html>
    }
    return $html
};

local:generate-html()
