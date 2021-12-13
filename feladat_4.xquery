(:A lekérdezés visszaadja, hogy hányszor NEM a Mercedes végzett az első helyen:)

xquery version "3.1";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:indent "yes";

let $file := doc('f1.xml')
return
    count(for $race in $file/RaceTable/Race
    return
        $race) -
    
    count(
    for $win in $file/RaceTable/Race/ResultsList/Result
        where $win[@position = 1] and $win/Constructor[@constructorId = "mercedes"]
    return
        $win
    )
