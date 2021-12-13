## Fejlett XML technológiák - beadandó
### Ergast Developer API - https://ergast.com/mrd/

#### XQuery lekérdezések

**1. lekérdezés:**

A lekérdezés visszaadja a versenyek számát.

```xquery
xquery version "3.1";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:indent "yes";

let $file := doc('f1.xml')
return count($file/RaceTable/Race)
```
**Eredmény:**
```json
17
```

**2. lekérdezés:**

A lekérdezés visszaadja a versenyzők nevét egy tömbben

```xquery
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

```
**Eredmény:**
```json
[
  "Valtteri Bottas",
  "Charles Leclerc",
  "Lando Norris",
  "Lewis Hamilton",
  "Carlos Sainz",
  "Sergio Pérez",
  "Pierre Gasly",
  "Esteban Ocon",
  "Antonio Giovinazzi",
  "Sebastian Vettel",
  "Nicholas Latifi",
  "Daniil Kvyat",
  "Alexander Albon",
  "Kimi Räikkönen",
  "George Russell",
  "Romain Grosjean",
  "Kevin Magnussen",
  "Lance Stroll",
  "Daniel Ricciardo",
  "Max Verstappen",
  "Nico Hülkenberg",
  "Jack Aitken",
  "Pietro Fittipaldi"
]
```

**3. lekérdezés:**

A lekérdezés visszaadja egy objektumban a csapatok nevét, illetve az általuk elért átlagos sebességet

```xquery
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
```
**Eredmény:**
```json
{
  "Alfa Romeo": 213.86267647058818,
  "AlphaTauri": 216.74033333333338,
  "Red Bull": 219.3604375,
  "McLaren": 216.02540625,
  "Williams": 213.58252941176465,
  "Mercedes": 221.89717647058822,
  "Renault": 215.15858823529405,
  "Ferrari": 215.01928124999998,
  "Haas F1 Team": 213.36943750000003,
  "Racing Point": 218.00929032258068
}
```

**4. lekérdezés:**

A lekérdezés visszaadja, hogy hányszor NEM a Mercedes végzett az első helyen

```xquery
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

```
**Eredmény:**
```json
4
```

**5. lekérdezés:**

A lekérdezés visszaadja, hogy csapatonként az egyes pilóták hány kört teljesítettek az évben, hogy melyik volt a legjobb elért eredményük, illetve a hozzájuk tartozó id-t

```xquery
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
```
**Eredmény:**
```json
{
  "Alfa Romeo": {
    "Kimi Räikkönen": {
      "highest rank": 9,
      "laps": 1009,
      "id": "raikkonen"
    },
    "Antonio Giovinazzi": {
      "highest rank": 9,
      "laps": 893,
      "id": "giovinazzi"
    }
  },
  "AlphaTauri": {
    "Daniil Kvyat": {
      "highest rank": 4,
      "laps": 986,
      "id": "kvyat"
    },
    "Pierre Gasly": {
      "highest rank": 1,
      "laps": 864,
      "id": "gasly"
    }
  },
  "Red Bull": {
    "Max Verstappen": {
      "highest rank": 1,
      "laps": 795,
      "id": "max_verstappen"
    },
    "Alexander Albon": {
      "highest rank": 3,
      "laps": 994,
      "id": "albon"
    }
  },
  "McLaren": {
    "Carlos Sainz": {
      "highest rank": 2,
      "laps": 882,
      "id": "sainz"
    },
    "Lando Norris": {
      "highest rank": 3,
      "laps": 1015,
      "id": "norris"
    }
  },
  "Williams": {
    "George Russell": {
      "highest rank": 9,
      "laps": 910,
      "id": "russell"
    },
    "Jack Aitken": {
      "highest rank": 16,
      "laps": 87,
      "id": "aitken"
    },
    "Nicholas Latifi": {
      "highest rank": 11,
      "laps": 915,
      "id": "latifi"
    }
  },
  "Mercedes": {
    "George Russell": {
      "highest rank": 9,
      "laps": 910,
      "id": "russell"
    },
    "Valtteri Bottas": {
      "highest rank": 1,
      "laps": 994,
      "id": "bottas"
    },
    "Lewis Hamilton": {
      "highest rank": 1,
      "laps": 950,
      "id": "hamilton"
    }
  },
  "Renault": {
    "Esteban Ocon": {
      "highest rank": 2,
      "laps": 861,
      "id": "ocon"
    },
    "Daniel Ricciardo": {
      "highest rank": 3,
      "laps": 979,
      "id": "ricciardo"
    }
  },
  "Ferrari": {
    "Sebastian Vettel": {
      "highest rank": 3,
      "laps": 914,
      "id": "vettel"
    },
    "Charles Leclerc": {
      "highest rank": 2,
      "laps": 822,
      "id": "leclerc"
    }
  },
  "Haas F1 Team": {
    "Romain Grosjean": {
      "highest rank": 9,
      "laps": 800,
      "id": "grosjean"
    },
    "Kevin Magnussen": {
      "highest rank": 10,
      "laps": 814,
      "id": "kevin_magnussen"
    },
    "Pietro Fittipaldi": {
      "highest rank": 17,
      "laps": 140,
      "id": "pietro_fittipaldi"
    }
  },
  "Racing Point": {
    "Lance Stroll": {
      "highest rank": 3,
      "laps": 785,
      "id": "stroll"
    },
    "Sergio Pérez": {
      "highest rank": 1,
      "laps": 879,
      "id": "perez"
    },
    "Nico Hülkenberg": {
      "highest rank": 7,
      "laps": 112,
      "id": "hulkenberg"
    }
  }
}
```

**6. lekérdezés:**
A lekérdezés egy XML dokumentumot állít elő, amely tartalmazza az adott versenyeken pontot szerző pilótákat, valamint a pilótákhoz, illetve a pozíciókhoz tartozó adatokat

```xquery
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
                        <dateofbirth>{map:get($datesofbirth, $key)}</dateofbirth>
                        <nationality>{map:get($nationality, $key)}</nationality>
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
```
**Eredmény:**
```xml
<season year="2020">
  <races count="17">
    <race round="1" name="Austrian Grand Prix">
      <position number="1" points="25" fastest_lap="1:07.657">
        <driver number="77">
          <name>Valtteri Bottas</name>
          <dateofbirth>1989-08-28</dateofbirth>
          <nationality>Finnish</nationality>
        </driver>
      </position>
      <position number="2" points="18" fastest_lap="1:07.901">
        <driver number="16">
          <name>Charles Leclerc</name>
          <dateofbirth>1997-10-16</dateofbirth>
          <nationality>Monegasque</nationality>
        </driver>
      </position>
      <position number="3" points="16" fastest_lap="1:07.475">
        <driver number="4">
          <name>Lando Norris</name>
          <dateofbirth>1999-11-13</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="4" points="12" fastest_lap="1:07.712">
        <driver number="44">
          <name>Lewis Hamilton</name>
          <dateofbirth>1985-01-07</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="5" points="10" fastest_lap="1:07.974">
        <driver number="55">
          <name>Carlos Sainz</name>
          <dateofbirth>1994-09-01</dateofbirth>
          <nationality>Spanish</nationality>
        </driver>
      </position>
      <position number="6" points="8" fastest_lap="1:08.305">
        <driver number="11">
          <name>Sergio Pérez</name>
          <dateofbirth>1990-01-26</dateofbirth>
          <nationality>Mexican</nationality>
        </driver>
      </position>
      <position number="7" points="6" fastest_lap="1:09.025">
        <driver number="10">
          <name>Pierre Gasly</name>
          <dateofbirth>1996-02-07</dateofbirth>
          <nationality>French</nationality>
        </driver>
      </position>
      <position number="8" points="4" fastest_lap="1:08.932">
        <driver number="31">
          <name>Esteban Ocon</name>
          <dateofbirth>1996-09-17</dateofbirth>
          <nationality>French</nationality>
        </driver>
      </position>
      <position number="9" points="2" fastest_lap="1:08.796">
        <driver number="99">
          <name>Antonio Giovinazzi</name>
          <dateofbirth>1993-12-14</dateofbirth>
          <nationality>Italian</nationality>
        </driver>
      </position>
      <position number="10" points="1" fastest_lap="1:08.623">
        <driver number="5">
          <name>Sebastian Vettel</name>
          <dateofbirth>1987-07-03</dateofbirth>
          <nationality>German</nationality>
        </driver>
      </position>
    </race>
    <race round="2" name="Styrian Grand Prix">
      <position number="1" points="25" fastest_lap="1:06.719">
        <driver number="44">
          <name>Lewis Hamilton</name>
          <dateofbirth>1985-01-07</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="2" points="18" fastest_lap="1:07.534">
        <driver number="77">
          <name>Valtteri Bottas</name>
          <dateofbirth>1989-08-28</dateofbirth>
          <nationality>Finnish</nationality>
        </driver>
      </position>
      <position number="3" points="15" fastest_lap="1:06.145">
        <driver number="33">
          <name>Max Verstappen</name>
          <dateofbirth>1997-09-30</dateofbirth>
          <nationality>Dutch</nationality>
        </driver>
      </position>
      <position number="4" points="12" fastest_lap="1:07.299">
        <driver number="23">
          <name>Alexander Albon</name>
          <dateofbirth>1996-03-23</dateofbirth>
          <nationality>Thai</nationality>
        </driver>
      </position>
      <position number="5" points="10" fastest_lap="1:07.193">
        <driver number="4">
          <name>Lando Norris</name>
          <dateofbirth>1999-11-13</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="6" points="8" fastest_lap="1:07.188">
        <driver number="11">
          <name>Sergio Pérez</name>
          <dateofbirth>1990-01-26</dateofbirth>
          <nationality>Mexican</nationality>
        </driver>
      </position>
      <position number="7" points="6" fastest_lap="1:07.833">
        <driver number="18">
          <name>Lance Stroll</name>
          <dateofbirth>1998-10-29</dateofbirth>
          <nationality>Canadian</nationality>
        </driver>
      </position>
      <position number="8" points="4" fastest_lap="1:07.832">
        <driver number="3">
          <name>Daniel Ricciardo</name>
          <dateofbirth>1989-07-01</dateofbirth>
          <nationality>Australian</nationality>
        </driver>
      </position>
      <position number="9" points="3" fastest_lap="1:05.619">
        <driver number="55">
          <name>Carlos Sainz</name>
          <dateofbirth>1994-09-01</dateofbirth>
          <nationality>Spanish</nationality>
        </driver>
      </position>
      <position number="10" points="1" fastest_lap="1:08.378">
        <driver number="26">
          <name>Daniil Kvyat</name>
          <dateofbirth>1994-04-26</dateofbirth>
          <nationality>Russian</nationality>
        </driver>
      </position>
    </race>
    <race round="3" name="Hungarian Grand Prix">
      <position number="1" points="26" fastest_lap="1:16.627">
        <driver number="44">
          <name>Lewis Hamilton</name>
          <dateofbirth>1985-01-07</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="2" points="18" fastest_lap="1:19.184">
        <driver number="33">
          <name>Max Verstappen</name>
          <dateofbirth>1997-09-30</dateofbirth>
          <nationality>Dutch</nationality>
        </driver>
      </position>
      <position number="3" points="15" fastest_lap="1:17.665">
        <driver number="77">
          <name>Valtteri Bottas</name>
          <dateofbirth>1989-08-28</dateofbirth>
          <nationality>Finnish</nationality>
        </driver>
      </position>
      <position number="4" points="12" fastest_lap="1:18.973">
        <driver number="18">
          <name>Lance Stroll</name>
          <dateofbirth>1998-10-29</dateofbirth>
          <nationality>Canadian</nationality>
        </driver>
      </position>
      <position number="5" points="10" fastest_lap="1:19.440">
        <driver number="23">
          <name>Alexander Albon</name>
          <dateofbirth>1996-03-23</dateofbirth>
          <nationality>Thai</nationality>
        </driver>
      </position>
      <position number="6" points="8" fastest_lap="1:20.363">
        <driver number="5">
          <name>Sebastian Vettel</name>
          <dateofbirth>1987-07-03</dateofbirth>
          <nationality>German</nationality>
        </driver>
      </position>
      <position number="7" points="6" fastest_lap="1:20.090">
        <driver number="11">
          <name>Sergio Pérez</name>
          <dateofbirth>1990-01-26</dateofbirth>
          <nationality>Mexican</nationality>
        </driver>
      </position>
      <position number="8" points="4" fastest_lap="1:19.532">
        <driver number="3">
          <name>Daniel Ricciardo</name>
          <dateofbirth>1989-07-01</dateofbirth>
          <nationality>Australian</nationality>
        </driver>
      </position>
      <position number="9" points="2" fastest_lap="1:20.477">
        <driver number="55">
          <name>Carlos Sainz</name>
          <dateofbirth>1994-09-01</dateofbirth>
          <nationality>Spanish</nationality>
        </driver>
      </position>
      <position number="10" points="1" fastest_lap="1:19.457">
        <driver number="20">
          <name>Kevin Magnussen</name>
          <dateofbirth>1992-10-05</dateofbirth>
          <nationality>Danish</nationality>
        </driver>
      </position>
    </race>
    <race round="4" name="British Grand Prix">
      <position number="1" points="25" fastest_lap="1:29.238">
        <driver number="44">
          <name>Lewis Hamilton</name>
          <dateofbirth>1985-01-07</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="2" points="19" fastest_lap="1:27.097">
        <driver number="33">
          <name>Max Verstappen</name>
          <dateofbirth>1997-09-30</dateofbirth>
          <nationality>Dutch</nationality>
        </driver>
      </position>
      <position number="3" points="15" fastest_lap="1:29.813">
        <driver number="16">
          <name>Charles Leclerc</name>
          <dateofbirth>1997-10-16</dateofbirth>
          <nationality>Monegasque</nationality>
        </driver>
      </position>
      <position number="4" points="12" fastest_lap="1:29.482">
        <driver number="3">
          <name>Daniel Ricciardo</name>
          <dateofbirth>1989-07-01</dateofbirth>
          <nationality>Australian</nationality>
        </driver>
      </position>
      <position number="5" points="10" fastest_lap="1:30.058">
        <driver number="4">
          <name>Lando Norris</name>
          <dateofbirth>1999-11-13</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="6" points="8" fastest_lap="1:29.491">
        <driver number="31">
          <name>Esteban Ocon</name>
          <dateofbirth>1996-09-17</dateofbirth>
          <nationality>French</nationality>
        </driver>
      </position>
      <position number="7" points="6" fastest_lap="1:29.603">
        <driver number="10">
          <name>Pierre Gasly</name>
          <dateofbirth>1996-02-07</dateofbirth>
          <nationality>French</nationality>
        </driver>
      </position>
      <position number="8" points="4" fastest_lap="1:28.689">
        <driver number="23">
          <name>Alexander Albon</name>
          <dateofbirth>1996-03-23</dateofbirth>
          <nationality>Thai</nationality>
        </driver>
      </position>
      <position number="9" points="2" fastest_lap="1:30.475">
        <driver number="18">
          <name>Lance Stroll</name>
          <dateofbirth>1998-10-29</dateofbirth>
          <nationality>Canadian</nationality>
        </driver>
      </position>
      <position number="10" points="1" fastest_lap="1:30.537">
        <driver number="5">
          <name>Sebastian Vettel</name>
          <dateofbirth>1987-07-03</dateofbirth>
          <nationality>German</nationality>
        </driver>
      </position>
    </race>
    <race round="5" name="70th Anniversary Grand Prix">
      <position number="1" points="25" fastest_lap="1:29.465">
        <driver number="33">
          <name>Max Verstappen</name>
          <dateofbirth>1997-09-30</dateofbirth>
          <nationality>Dutch</nationality>
        </driver>
      </position>
      <position number="2" points="19" fastest_lap="1:28.451">
        <driver number="44">
          <name>Lewis Hamilton</name>
          <dateofbirth>1985-01-07</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="3" points="15" fastest_lap="1:29.765">
        <driver number="77">
          <name>Valtteri Bottas</name>
          <dateofbirth>1989-08-28</dateofbirth>
          <nationality>Finnish</nationality>
        </driver>
      </position>
      <position number="4" points="12" fastest_lap="1:30.552">
        <driver number="16">
          <name>Charles Leclerc</name>
          <dateofbirth>1997-10-16</dateofbirth>
          <nationality>Monegasque</nationality>
        </driver>
      </position>
      <position number="5" points="10" fastest_lap="1:29.477">
        <driver number="23">
          <name>Alexander Albon</name>
          <dateofbirth>1996-03-23</dateofbirth>
          <nationality>Thai</nationality>
        </driver>
      </position>
      <position number="6" points="8" fastest_lap="1:30.877">
        <driver number="18">
          <name>Lance Stroll</name>
          <dateofbirth>1998-10-29</dateofbirth>
          <nationality>Canadian</nationality>
        </driver>
      </position>
      <position number="7" points="6" fastest_lap="1:30.087">
        <driver number="27">
          <name>Nico Hülkenberg</name>
          <dateofbirth>1987-08-19</dateofbirth>
          <nationality>German</nationality>
        </driver>
      </position>
      <position number="8" points="4" fastest_lap="1:30.575">
        <driver number="31">
          <name>Esteban Ocon</name>
          <dateofbirth>1996-09-17</dateofbirth>
          <nationality>French</nationality>
        </driver>
      </position>
      <position number="9" points="2" fastest_lap="1:30.698">
        <driver number="4">
          <name>Lando Norris</name>
          <dateofbirth>1999-11-13</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="10" points="1" fastest_lap="1:30.738">
        <driver number="26">
          <name>Daniil Kvyat</name>
          <dateofbirth>1994-04-26</dateofbirth>
          <nationality>Russian</nationality>
        </driver>
      </position>
    </race>
    <race round="6" name="Spanish Grand Prix">
      <position number="1" points="25" fastest_lap="1:19.822">
        <driver number="44">
          <name>Lewis Hamilton</name>
          <dateofbirth>1985-01-07</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="2" points="18" fastest_lap="1:21.477">
        <driver number="33">
          <name>Max Verstappen</name>
          <dateofbirth>1997-09-30</dateofbirth>
          <nationality>Dutch</nationality>
        </driver>
      </position>
      <position number="3" points="16" fastest_lap="1:18.183">
        <driver number="77">
          <name>Valtteri Bottas</name>
          <dateofbirth>1989-08-28</dateofbirth>
          <nationality>Finnish</nationality>
        </driver>
      </position>
      <position number="4" points="12" fastest_lap="1:22.024">
        <driver number="18">
          <name>Lance Stroll</name>
          <dateofbirth>1998-10-29</dateofbirth>
          <nationality>Canadian</nationality>
        </driver>
      </position>
      <position number="5" points="10" fastest_lap="1:22.515">
        <driver number="11">
          <name>Sergio Pérez</name>
          <dateofbirth>1990-01-26</dateofbirth>
          <nationality>Mexican</nationality>
        </driver>
      </position>
      <position number="6" points="8" fastest_lap="1:21.771">
        <driver number="55">
          <name>Carlos Sainz</name>
          <dateofbirth>1994-09-01</dateofbirth>
          <nationality>Spanish</nationality>
        </driver>
      </position>
      <position number="7" points="6" fastest_lap="1:22.707">
        <driver number="5">
          <name>Sebastian Vettel</name>
          <dateofbirth>1987-07-03</dateofbirth>
          <nationality>German</nationality>
        </driver>
      </position>
      <position number="8" points="4" fastest_lap="1:22.194">
        <driver number="23">
          <name>Alexander Albon</name>
          <dateofbirth>1996-03-23</dateofbirth>
          <nationality>Thai</nationality>
        </driver>
      </position>
      <position number="9" points="2" fastest_lap="1:22.543">
        <driver number="10">
          <name>Pierre Gasly</name>
          <dateofbirth>1996-02-07</dateofbirth>
          <nationality>French</nationality>
        </driver>
      </position>
      <position number="10" points="1" fastest_lap="1:22.392">
        <driver number="4">
          <name>Lando Norris</name>
          <dateofbirth>1999-11-13</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
    </race>
    <race round="7" name="Belgian Grand Prix">
      <position number="1" points="25" fastest_lap="1:47.758">
        <driver number="44">
          <name>Lewis Hamilton</name>
          <dateofbirth>1985-01-07</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="2" points="18" fastest_lap="1:47.983">
        <driver number="77">
          <name>Valtteri Bottas</name>
          <dateofbirth>1989-08-28</dateofbirth>
          <nationality>Finnish</nationality>
        </driver>
      </position>
      <position number="3" points="15" fastest_lap="1:48.305">
        <driver number="33">
          <name>Max Verstappen</name>
          <dateofbirth>1997-09-30</dateofbirth>
          <nationality>Dutch</nationality>
        </driver>
      </position>
      <position number="4" points="13" fastest_lap="1:47.483">
        <driver number="3">
          <name>Daniel Ricciardo</name>
          <dateofbirth>1989-07-01</dateofbirth>
          <nationality>Australian</nationality>
        </driver>
      </position>
      <position number="5" points="10" fastest_lap="1:48.540">
        <driver number="31">
          <name>Esteban Ocon</name>
          <dateofbirth>1996-09-17</dateofbirth>
          <nationality>French</nationality>
        </driver>
      </position>
      <position number="6" points="8" fastest_lap="1:48.736">
        <driver number="23">
          <name>Alexander Albon</name>
          <dateofbirth>1996-03-23</dateofbirth>
          <nationality>Thai</nationality>
        </driver>
      </position>
      <position number="7" points="6" fastest_lap="1:48.552">
        <driver number="4">
          <name>Lando Norris</name>
          <dateofbirth>1999-11-13</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="8" points="4" fastest_lap="1:47.839">
        <driver number="10">
          <name>Pierre Gasly</name>
          <dateofbirth>1996-02-07</dateofbirth>
          <nationality>French</nationality>
        </driver>
      </position>
      <position number="9" points="2" fastest_lap="1:49.136">
        <driver number="18">
          <name>Lance Stroll</name>
          <dateofbirth>1998-10-29</dateofbirth>
          <nationality>Canadian</nationality>
        </driver>
      </position>
      <position number="10" points="1" fastest_lap="1:48.389">
        <driver number="11">
          <name>Sergio Pérez</name>
          <dateofbirth>1990-01-26</dateofbirth>
          <nationality>Mexican</nationality>
        </driver>
      </position>
    </race>
    <race round="8" name="Italian Grand Prix">
      <position number="1" points="25" fastest_lap="1:24.037">
        <driver number="10">
          <name>Pierre Gasly</name>
          <dateofbirth>1996-02-07</dateofbirth>
          <nationality>French</nationality>
        </driver>
      </position>
      <position number="2" points="18" fastest_lap="1:23.882">
        <driver number="55">
          <name>Carlos Sainz</name>
          <dateofbirth>1994-09-01</dateofbirth>
          <nationality>Spanish</nationality>
        </driver>
      </position>
      <position number="3" points="15" fastest_lap="1:23.897">
        <driver number="18">
          <name>Lance Stroll</name>
          <dateofbirth>1998-10-29</dateofbirth>
          <nationality>Canadian</nationality>
        </driver>
      </position>
      <position number="4" points="12" fastest_lap="1:24.232">
        <driver number="4">
          <name>Lando Norris</name>
          <dateofbirth>1999-11-13</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="5" points="10" fastest_lap="1:23.961">
        <driver number="77">
          <name>Valtteri Bottas</name>
          <dateofbirth>1989-08-28</dateofbirth>
          <nationality>Finnish</nationality>
        </driver>
      </position>
      <position number="6" points="8" fastest_lap="1:23.898">
        <driver number="3">
          <name>Daniel Ricciardo</name>
          <dateofbirth>1989-07-01</dateofbirth>
          <nationality>Australian</nationality>
        </driver>
      </position>
      <position number="7" points="7" fastest_lap="1:22.746">
        <driver number="44">
          <name>Lewis Hamilton</name>
          <dateofbirth>1985-01-07</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="8" points="4" fastest_lap="1:24.490">
        <driver number="31">
          <name>Esteban Ocon</name>
          <dateofbirth>1996-09-17</dateofbirth>
          <nationality>French</nationality>
        </driver>
      </position>
      <position number="9" points="2" fastest_lap="1:24.479">
        <driver number="26">
          <name>Daniil Kvyat</name>
          <dateofbirth>1994-04-26</dateofbirth>
          <nationality>Russian</nationality>
        </driver>
      </position>
      <position number="10" points="1" fastest_lap="1:24.336">
        <driver number="11">
          <name>Sergio Pérez</name>
          <dateofbirth>1990-01-26</dateofbirth>
          <nationality>Mexican</nationality>
        </driver>
      </position>
    </race>
    <race round="9" name="Tuscan Grand Prix">
      <position number="1" points="26" fastest_lap="1:18.833">
        <driver number="44">
          <name>Lewis Hamilton</name>
          <dateofbirth>1985-01-07</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="2" points="18" fastest_lap="1:19.432">
        <driver number="77">
          <name>Valtteri Bottas</name>
          <dateofbirth>1989-08-28</dateofbirth>
          <nationality>Finnish</nationality>
        </driver>
      </position>
      <position number="3" points="15" fastest_lap="1:20.039">
        <driver number="23">
          <name>Alexander Albon</name>
          <dateofbirth>1996-03-23</dateofbirth>
          <nationality>Thai</nationality>
        </driver>
      </position>
      <position number="4" points="12" fastest_lap="1:20.426">
        <driver number="3">
          <name>Daniel Ricciardo</name>
          <dateofbirth>1989-07-01</dateofbirth>
          <nationality>Australian</nationality>
        </driver>
      </position>
      <position number="5" points="10" fastest_lap="1:20.632">
        <driver number="11">
          <name>Sergio Pérez</name>
          <dateofbirth>1990-01-26</dateofbirth>
          <nationality>Mexican</nationality>
        </driver>
      </position>
      <position number="6" points="8" fastest_lap="1:21.198">
        <driver number="4">
          <name>Lando Norris</name>
          <dateofbirth>1999-11-13</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="7" points="6" fastest_lap="1:21.458">
        <driver number="26">
          <name>Daniil Kvyat</name>
          <dateofbirth>1994-04-26</dateofbirth>
          <nationality>Russian</nationality>
        </driver>
      </position>
      <position number="8" points="4" fastest_lap="1:21.229">
        <driver number="16">
          <name>Charles Leclerc</name>
          <dateofbirth>1997-10-16</dateofbirth>
          <nationality>Monegasque</nationality>
        </driver>
      </position>
      <position number="9" points="2" fastest_lap="1:21.164">
        <driver number="7">
          <name>Kimi Räikkönen</name>
          <dateofbirth>1979-10-17</dateofbirth>
          <nationality>Finnish</nationality>
        </driver>
      </position>
      <position number="10" points="1" fastest_lap="1:21.202">
        <driver number="5">
          <name>Sebastian Vettel</name>
          <dateofbirth>1987-07-03</dateofbirth>
          <nationality>German</nationality>
        </driver>
      </position>
    </race>
    <race round="10" name="Russian Grand Prix">
      <position number="1" points="26" fastest_lap="1:37.030">
        <driver number="77">
          <name>Valtteri Bottas</name>
          <dateofbirth>1989-08-28</dateofbirth>
          <nationality>Finnish</nationality>
        </driver>
      </position>
      <position number="2" points="18" fastest_lap="1:37.332">
        <driver number="33">
          <name>Max Verstappen</name>
          <dateofbirth>1997-09-30</dateofbirth>
          <nationality>Dutch</nationality>
        </driver>
      </position>
      <position number="3" points="15" fastest_lap="1:38.075">
        <driver number="44">
          <name>Lewis Hamilton</name>
          <dateofbirth>1985-01-07</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="4" points="12" fastest_lap="1:38.141">
        <driver number="11">
          <name>Sergio Pérez</name>
          <dateofbirth>1990-01-26</dateofbirth>
          <nationality>Mexican</nationality>
        </driver>
      </position>
      <position number="5" points="10" fastest_lap="1:37.886">
        <driver number="3">
          <name>Daniel Ricciardo</name>
          <dateofbirth>1989-07-01</dateofbirth>
          <nationality>Australian</nationality>
        </driver>
      </position>
      <position number="6" points="8" fastest_lap="1:39.053">
        <driver number="16">
          <name>Charles Leclerc</name>
          <dateofbirth>1997-10-16</dateofbirth>
          <nationality>Monegasque</nationality>
        </driver>
      </position>
      <position number="7" points="6" fastest_lap="1:39.216">
        <driver number="31">
          <name>Esteban Ocon</name>
          <dateofbirth>1996-09-17</dateofbirth>
          <nationality>French</nationality>
        </driver>
      </position>
      <position number="8" points="4" fastest_lap="1:39.133">
        <driver number="26">
          <name>Daniil Kvyat</name>
          <dateofbirth>1994-04-26</dateofbirth>
          <nationality>Russian</nationality>
        </driver>
      </position>
      <position number="9" points="2" fastest_lap="1:37.231">
        <driver number="10">
          <name>Pierre Gasly</name>
          <dateofbirth>1996-02-07</dateofbirth>
          <nationality>French</nationality>
        </driver>
      </position>
      <position number="10" points="1" fastest_lap="1:38.377">
        <driver number="23">
          <name>Alexander Albon</name>
          <dateofbirth>1996-03-23</dateofbirth>
          <nationality>Thai</nationality>
        </driver>
      </position>
    </race>
    <race round="11" name="Eifel Grand Prix">
      <position number="1" points="25" fastest_lap="1:28.145">
        <driver number="44">
          <name>Lewis Hamilton</name>
          <dateofbirth>1985-01-07</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="2" points="19" fastest_lap="1:28.139">
        <driver number="33">
          <name>Max Verstappen</name>
          <dateofbirth>1997-09-30</dateofbirth>
          <nationality>Dutch</nationality>
        </driver>
      </position>
      <position number="3" points="15" fastest_lap="1:29.584">
        <driver number="3">
          <name>Daniel Ricciardo</name>
          <dateofbirth>1989-07-01</dateofbirth>
          <nationality>Australian</nationality>
        </driver>
      </position>
      <position number="4" points="12" fastest_lap="1:29.700">
        <driver number="11">
          <name>Sergio Pérez</name>
          <dateofbirth>1990-01-26</dateofbirth>
          <nationality>Mexican</nationality>
        </driver>
      </position>
      <position number="5" points="10" fastest_lap="1:30.129">
        <driver number="55">
          <name>Carlos Sainz</name>
          <dateofbirth>1994-09-01</dateofbirth>
          <nationality>Spanish</nationality>
        </driver>
      </position>
      <position number="6" points="8" fastest_lap="1:30.110">
        <driver number="10">
          <name>Pierre Gasly</name>
          <dateofbirth>1996-02-07</dateofbirth>
          <nationality>French</nationality>
        </driver>
      </position>
      <position number="7" points="6" fastest_lap="1:30.712">
        <driver number="16">
          <name>Charles Leclerc</name>
          <dateofbirth>1997-10-16</dateofbirth>
          <nationality>Monegasque</nationality>
        </driver>
      </position>
      <position number="8" points="4" fastest_lap="1:30.733">
        <driver number="27">
          <name>Nico Hülkenberg</name>
          <dateofbirth>1987-08-19</dateofbirth>
          <nationality>German</nationality>
        </driver>
      </position>
      <position number="9" points="2" fastest_lap="1:31.562">
        <driver number="8">
          <name>Romain Grosjean</name>
          <dateofbirth>1986-04-17</dateofbirth>
          <nationality>French</nationality>
        </driver>
      </position>
      <position number="10" points="1" fastest_lap="1:30.909">
        <driver number="99">
          <name>Antonio Giovinazzi</name>
          <dateofbirth>1993-12-14</dateofbirth>
          <nationality>Italian</nationality>
        </driver>
      </position>
    </race>
    <race round="12" name="Portuguese Grand Prix">
      <position number="1" points="26" fastest_lap="1:18.750">
        <driver number="44">
          <name>Lewis Hamilton</name>
          <dateofbirth>1985-01-07</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="2" points="18" fastest_lap="1:19.345">
        <driver number="77">
          <name>Valtteri Bottas</name>
          <dateofbirth>1989-08-28</dateofbirth>
          <nationality>Finnish</nationality>
        </driver>
      </position>
      <position number="3" points="15" fastest_lap="1:19.854">
        <driver number="33">
          <name>Max Verstappen</name>
          <dateofbirth>1997-09-30</dateofbirth>
          <nationality>Dutch</nationality>
        </driver>
      </position>
      <position number="4" points="12" fastest_lap="1:20.408">
        <driver number="16">
          <name>Charles Leclerc</name>
          <dateofbirth>1997-10-16</dateofbirth>
          <nationality>Monegasque</nationality>
        </driver>
      </position>
      <position number="5" points="10" fastest_lap="1:20.551">
        <driver number="10">
          <name>Pierre Gasly</name>
          <dateofbirth>1996-02-07</dateofbirth>
          <nationality>French</nationality>
        </driver>
      </position>
      <position number="6" points="8" fastest_lap="1:20.268">
        <driver number="55">
          <name>Carlos Sainz</name>
          <dateofbirth>1994-09-01</dateofbirth>
          <nationality>Spanish</nationality>
        </driver>
      </position>
      <position number="7" points="6" fastest_lap="1:20.802">
        <driver number="11">
          <name>Sergio Pérez</name>
          <dateofbirth>1990-01-26</dateofbirth>
          <nationality>Mexican</nationality>
        </driver>
      </position>
      <position number="8" points="4" fastest_lap="1:20.859">
        <driver number="31">
          <name>Esteban Ocon</name>
          <dateofbirth>1996-09-17</dateofbirth>
          <nationality>French</nationality>
        </driver>
      </position>
      <position number="9" points="2" fastest_lap="1:20.906">
        <driver number="3">
          <name>Daniel Ricciardo</name>
          <dateofbirth>1989-07-01</dateofbirth>
          <nationality>Australian</nationality>
        </driver>
      </position>
      <position number="10" points="1" fastest_lap="1:20.731">
        <driver number="5">
          <name>Sebastian Vettel</name>
          <dateofbirth>1987-07-03</dateofbirth>
          <nationality>German</nationality>
        </driver>
      </position>
    </race>
    <race round="13" name="Emilia Romagna Grand Prix">
      <position number="1" points="26" fastest_lap="1:15.484">
        <driver number="44">
          <name>Lewis Hamilton</name>
          <dateofbirth>1985-01-07</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="2" points="18" fastest_lap="1:15.902">
        <driver number="77">
          <name>Valtteri Bottas</name>
          <dateofbirth>1989-08-28</dateofbirth>
          <nationality>Finnish</nationality>
        </driver>
      </position>
      <position number="3" points="15" fastest_lap="1:17.552">
        <driver number="3">
          <name>Daniel Ricciardo</name>
          <dateofbirth>1989-07-01</dateofbirth>
          <nationality>Australian</nationality>
        </driver>
      </position>
      <position number="4" points="12" fastest_lap="1:17.666">
        <driver number="26">
          <name>Daniil Kvyat</name>
          <dateofbirth>1994-04-26</dateofbirth>
          <nationality>Russian</nationality>
        </driver>
      </position>
      <position number="5" points="10" fastest_lap="1:18.173">
        <driver number="16">
          <name>Charles Leclerc</name>
          <dateofbirth>1997-10-16</dateofbirth>
          <nationality>Monegasque</nationality>
        </driver>
      </position>
      <position number="6" points="8" fastest_lap="1:18.084">
        <driver number="11">
          <name>Sergio Pérez</name>
          <dateofbirth>1990-01-26</dateofbirth>
          <nationality>Mexican</nationality>
        </driver>
      </position>
      <position number="7" points="6" fastest_lap="1:18.118">
        <driver number="55">
          <name>Carlos Sainz</name>
          <dateofbirth>1994-09-01</dateofbirth>
          <nationality>Spanish</nationality>
        </driver>
      </position>
      <position number="8" points="4" fastest_lap="1:18.069">
        <driver number="4">
          <name>Lando Norris</name>
          <dateofbirth>1999-11-13</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="9" points="2" fastest_lap="1:18.088">
        <driver number="7">
          <name>Kimi Räikkönen</name>
          <dateofbirth>1979-10-17</dateofbirth>
          <nationality>Finnish</nationality>
        </driver>
      </position>
      <position number="10" points="1" fastest_lap="1:18.794">
        <driver number="99">
          <name>Antonio Giovinazzi</name>
          <dateofbirth>1993-12-14</dateofbirth>
          <nationality>Italian</nationality>
        </driver>
      </position>
    </race>
    <race round="14" name="Turkish Grand Prix">
      <position number="1" points="25" fastest_lap="1:39.413">
        <driver number="44">
          <name>Lewis Hamilton</name>
          <dateofbirth>1985-01-07</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="2" points="18" fastest_lap="1:40.392">
        <driver number="11">
          <name>Sergio Pérez</name>
          <dateofbirth>1990-01-26</dateofbirth>
          <nationality>Mexican</nationality>
        </driver>
      </position>
      <position number="3" points="15" fastest_lap="1:39.662">
        <driver number="5">
          <name>Sebastian Vettel</name>
          <dateofbirth>1987-07-03</dateofbirth>
          <nationality>German</nationality>
        </driver>
      </position>
      <position number="4" points="12" fastest_lap="1:39.961">
        <driver number="16">
          <name>Charles Leclerc</name>
          <dateofbirth>1997-10-16</dateofbirth>
          <nationality>Monegasque</nationality>
        </driver>
      </position>
      <position number="5" points="10" fastest_lap="1:38.754">
        <driver number="55">
          <name>Carlos Sainz</name>
          <dateofbirth>1994-09-01</dateofbirth>
          <nationality>Spanish</nationality>
        </driver>
      </position>
      <position number="6" points="8" fastest_lap="1:38.431">
        <driver number="33">
          <name>Max Verstappen</name>
          <dateofbirth>1997-09-30</dateofbirth>
          <nationality>Dutch</nationality>
        </driver>
      </position>
      <position number="7" points="6" fastest_lap="1:39.099">
        <driver number="23">
          <name>Alexander Albon</name>
          <dateofbirth>1996-03-23</dateofbirth>
          <nationality>Thai</nationality>
        </driver>
      </position>
      <position number="8" points="5" fastest_lap="1:36.806">
        <driver number="4">
          <name>Lando Norris</name>
          <dateofbirth>1999-11-13</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="9" points="2" fastest_lap="1:39.921">
        <driver number="18">
          <name>Lance Stroll</name>
          <dateofbirth>1998-10-29</dateofbirth>
          <nationality>Canadian</nationality>
        </driver>
      </position>
      <position number="10" points="1" fastest_lap="1:40.677">
        <driver number="3">
          <name>Daniel Ricciardo</name>
          <dateofbirth>1989-07-01</dateofbirth>
          <nationality>Australian</nationality>
        </driver>
      </position>
    </race>
    <race round="15" name="Bahrain Grand Prix">
      <position number="1" points="25" fastest_lap="1:32.864">
        <driver number="44">
          <name>Lewis Hamilton</name>
          <dateofbirth>1985-01-07</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="2" points="19" fastest_lap="1:32.014">
        <driver number="33">
          <name>Max Verstappen</name>
          <dateofbirth>1997-09-30</dateofbirth>
          <nationality>Dutch</nationality>
        </driver>
      </position>
      <position number="3" points="15" fastest_lap="1:33.684">
        <driver number="23">
          <name>Alexander Albon</name>
          <dateofbirth>1996-03-23</dateofbirth>
          <nationality>Thai</nationality>
        </driver>
      </position>
      <position number="4" points="12" fastest_lap="1:33.588">
        <driver number="4">
          <name>Lando Norris</name>
          <dateofbirth>1999-11-13</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="5" points="10" fastest_lap="1:33.411">
        <driver number="55">
          <name>Carlos Sainz</name>
          <dateofbirth>1994-09-01</dateofbirth>
          <nationality>Spanish</nationality>
        </driver>
      </position>
      <position number="6" points="8" fastest_lap="1:34.817">
        <driver number="10">
          <name>Pierre Gasly</name>
          <dateofbirth>1996-02-07</dateofbirth>
          <nationality>French</nationality>
        </driver>
      </position>
      <position number="7" points="6" fastest_lap="1:32.827">
        <driver number="3">
          <name>Daniel Ricciardo</name>
          <dateofbirth>1989-07-01</dateofbirth>
          <nationality>Australian</nationality>
        </driver>
      </position>
      <position number="8" points="4" fastest_lap="1:33.352">
        <driver number="77">
          <name>Valtteri Bottas</name>
          <dateofbirth>1989-08-28</dateofbirth>
          <nationality>Finnish</nationality>
        </driver>
      </position>
      <position number="9" points="2" fastest_lap="1:34.354">
        <driver number="31">
          <name>Esteban Ocon</name>
          <dateofbirth>1996-09-17</dateofbirth>
          <nationality>French</nationality>
        </driver>
      </position>
      <position number="10" points="1" fastest_lap="1:33.625">
        <driver number="16">
          <name>Charles Leclerc</name>
          <dateofbirth>1997-10-16</dateofbirth>
          <nationality>Monegasque</nationality>
        </driver>
      </position>
    </race>
    <race round="16" name="Sakhir Grand Prix">
      <position number="1" points="25" fastest_lap="0:56.789">
        <driver number="11">
          <name>Sergio Pérez</name>
          <dateofbirth>1990-01-26</dateofbirth>
          <nationality>Mexican</nationality>
        </driver>
      </position>
      <position number="2" points="18" fastest_lap="0:57.350">
        <driver number="31">
          <name>Esteban Ocon</name>
          <dateofbirth>1996-09-17</dateofbirth>
          <nationality>French</nationality>
        </driver>
      </position>
      <position number="3" points="15" fastest_lap="0:57.388">
        <driver number="18">
          <name>Lance Stroll</name>
          <dateofbirth>1998-10-29</dateofbirth>
          <nationality>Canadian</nationality>
        </driver>
      </position>
      <position number="4" points="12" fastest_lap="0:57.165">
        <driver number="55">
          <name>Carlos Sainz</name>
          <dateofbirth>1994-09-01</dateofbirth>
          <nationality>Spanish</nationality>
        </driver>
      </position>
      <position number="5" points="10" fastest_lap="0:56.979">
        <driver number="3">
          <name>Daniel Ricciardo</name>
          <dateofbirth>1989-07-01</dateofbirth>
          <nationality>Australian</nationality>
        </driver>
      </position>
      <position number="6" points="8" fastest_lap="0:57.056">
        <driver number="23">
          <name>Alexander Albon</name>
          <dateofbirth>1996-03-23</dateofbirth>
          <nationality>Thai</nationality>
        </driver>
      </position>
      <position number="7" points="6" fastest_lap="0:57.001">
        <driver number="26">
          <name>Daniil Kvyat</name>
          <dateofbirth>1994-04-26</dateofbirth>
          <nationality>Russian</nationality>
        </driver>
      </position>
      <position number="8" points="4" fastest_lap="0:56.563">
        <driver number="77">
          <name>Valtteri Bottas</name>
          <dateofbirth>1989-08-28</dateofbirth>
          <nationality>Finnish</nationality>
        </driver>
      </position>
      <position number="9" points="3" fastest_lap="0:55.404">
        <driver number="63">
          <name>George Russell</name>
          <dateofbirth>1998-02-15</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="10" points="1" fastest_lap="0:57.270">
        <driver number="4">
          <name>Lando Norris</name>
          <dateofbirth>1999-11-13</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
    </race>
    <race round="17" name="Abu Dhabi Grand Prix">
      <position number="1" points="25" fastest_lap="1:40.958">
        <driver number="33">
          <name>Max Verstappen</name>
          <dateofbirth>1997-09-30</dateofbirth>
          <nationality>Dutch</nationality>
        </driver>
      </position>
      <position number="2" points="18" fastest_lap="1:41.131">
        <driver number="77">
          <name>Valtteri Bottas</name>
          <dateofbirth>1989-08-28</dateofbirth>
          <nationality>Finnish</nationality>
        </driver>
      </position>
      <position number="3" points="15" fastest_lap="1:41.420">
        <driver number="44">
          <name>Lewis Hamilton</name>
          <dateofbirth>1985-01-07</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="4" points="12" fastest_lap="1:41.227">
        <driver number="23">
          <name>Alexander Albon</name>
          <dateofbirth>1996-03-23</dateofbirth>
          <nationality>Thai</nationality>
        </driver>
      </position>
      <position number="5" points="10" fastest_lap="1:41.964">
        <driver number="4">
          <name>Lando Norris</name>
          <dateofbirth>1999-11-13</dateofbirth>
          <nationality>British</nationality>
        </driver>
      </position>
      <position number="6" points="8" fastest_lap="1:41.947">
        <driver number="55">
          <name>Carlos Sainz</name>
          <dateofbirth>1994-09-01</dateofbirth>
          <nationality>Spanish</nationality>
        </driver>
      </position>
      <position number="7" points="7" fastest_lap="1:40.926">
        <driver number="3">
          <name>Daniel Ricciardo</name>
          <dateofbirth>1989-07-01</dateofbirth>
          <nationality>Australian</nationality>
        </driver>
      </position>
      <position number="8" points="4" fastest_lap="1:42.474">
        <driver number="10">
          <name>Pierre Gasly</name>
          <dateofbirth>1996-02-07</dateofbirth>
          <nationality>French</nationality>
        </driver>
      </position>
      <position number="9" points="2" fastest_lap="1:42.894">
        <driver number="31">
          <name>Esteban Ocon</name>
          <dateofbirth>1996-09-17</dateofbirth>
          <nationality>French</nationality>
        </driver>
      </position>
      <position number="10" points="1" fastest_lap="1:41.866">
        <driver number="18">
          <name>Lance Stroll</name>
          <dateofbirth>1998-10-29</dateofbirth>
          <nationality>Canadian</nationality>
        </driver>
      </position>
    </race>
  </races>
</season>
```

**7. lekérdezés:**

A lekérdezés egy olyan XML dokumentumot állít elő, amely kilistázza, hogy az adott hónapban mely pilóták születtek

```xquery
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
```
**Eredmény:**
```xml
<months>
  <month id="1" name="January" count="2">
    <driver number="11">Sergio Pérez</driver>
    <driver number="44">Lewis Hamilton</driver>
  </month>
  <month id="2" name="February" count="2">
    <driver number="63">George Russell</driver>
    <driver number="10">Pierre Gasly</driver>
  </month>
  <month id="3" name="March" count="1">
    <driver number="23">Alexander Albon</driver>
  </month>
  <month id="4" name="April" count="2">
    <driver number="26">Daniil Kvyat</driver>
    <driver number="8">Romain Grosjean</driver>
  </month>
  <month id="6" name="June" count="2">
    <driver number="6">Nicholas Latifi</driver>
    <driver number="51">Pietro Fittipaldi</driver>
  </month>
  <month id="7" name="July" count="2">
    <driver number="3">Daniel Ricciardo</driver>
    <driver number="5">Sebastian Vettel</driver>
  </month>
  <month id="8" name="August" count="2">
    <driver number="77">Valtteri Bottas</driver>
    <driver number="27">Nico Hülkenberg</driver>
  </month>
  <month id="9" name="September" count="4">
    <driver number="33">Max Verstappen</driver>
    <driver number="55">Carlos Sainz</driver>
    <driver number="89">Jack Aitken</driver>
    <driver number="31">Esteban Ocon</driver>
  </month>
  <month id="10" name="October" count="4">
    <driver number="16">Charles Leclerc</driver>
    <driver number="18">Lance Stroll</driver>
    <driver number="7">Kimi Räikkönen</driver>
    <driver number="20">Kevin Magnussen</driver>
  </month>
  <month id="11" name="November" count="1">
    <driver number="4">Lando Norris</driver>
  </month>
  <month id="12" name="December" count="1">
    <driver number="99">Antonio Giovinazzi</driver>
  </month>
</months>
```

**8. lekérdezés:**

A lekérdezés egy olyan XML dokumentumot állít elő, amely visszaadja a futamokat, illetve a futamok győzteseit, a földrajzi hosszúsági köröket tekintve Magyarországtól való távolság alapján csökkenő sorrendben

```xquery
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
        {for $race in $file/RaceTable/Race where $race/RaceName = $key return <winner number="{xs:integer($race/ResultsList/Result[@position = 1]/@number)}">{$race/ResultsList/Result[@position = 1]/Driver/GivenName//text() || ' ' || $race/ResultsList/Result[@position = 1]/Driver/FamilyName//text()}</winner>}
    </race> }
</RaceTable>

let $error := validate:xsd-report($xml, "feladat_8.xsd")
return
    if (fn:contains($error, "invalid"))
    then $error
    else $xml
```
**Eredmény:**
```xml
<RaceTable>
  <race racename="Abu Dhabi Grand Prix" distance="35.3545">
    <winner number="33">Max Verstappen</winner>
  </race>
  <race racename="Bahrain Grand Prix" distance="31.262">
    <winner number="44">Lewis Hamilton</winner>
  </race>
  <race racename="Sakhir Grand Prix" distance="31.262">
    <winner number="11">Sergio Pérez</winner>
  </race>
  <race racename="Portuguese Grand Prix" distance="27.8753">
    <winner number="44">Lewis Hamilton</winner>
  </race>
  <race racename="Russian Grand Prix" distance="20.7092">
    <winner number="77">Valtteri Bottas</winner>
  </race>
  <race racename="British Grand Prix" distance="20.26554">
    <winner number="44">Lewis Hamilton</winner>
  </race>
  <race racename="70th Anniversary Grand Prix" distance="20.26554">
    <winner number="33">Max Verstappen</winner>
  </race>
  <race racename="Spanish Grand Prix" distance="16.98749">
    <winner number="44">Lewis Hamilton</winner>
  </race>
  <race racename="Belgian Grand Prix" distance="13.27721">
    <winner number="44">Lewis Hamilton</winner>
  </race>
  <race racename="Eifel Grand Prix" distance="12.3011">
    <winner number="44">Lewis Hamilton</winner>
  </race>
  <race racename="Turkish Grand Prix" distance="10.1564">
    <winner number="44">Lewis Hamilton</winner>
  </race>
  <race racename="Italian Grand Prix" distance="9.96749">
    <winner number="10">Pierre Gasly</winner>
  </race>
  <race racename="Tuscan Grand Prix" distance="7.8767">
    <winner number="44">Lewis Hamilton</winner>
  </race>
  <race racename="Emilia Romagna Grand Prix" distance="7.5319">
    <winner number="44">Lewis Hamilton</winner>
  </race>
  <race racename="Styrian Grand Prix" distance="4.4839">
    <winner number="44">Lewis Hamilton</winner>
  </race>
  <race racename="Austrian Grand Prix" distance="4.4839">
    <winner number="77">Valtteri Bottas</winner>
  </race>
  <race racename="Hungarian Grand Prix" distance="0">
    <winner number="44">Lewis Hamilton</winner>
  </race>
</RaceTable>
```

**9. lekérdezés:**

A lekérdezés egy olyan XML dokumentumot állít elő, amely visszaadja a versenyzőket, számuk szerint növekvő sorrendben. Visszaadja továbbá a versenyzőkhöz tartozó státuszok darabszámát, amelyeket az év során elértek a különböző versenyeken

```xquery
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
```
**Eredmény:**
```xml
<drivers>
  <driver number="3" code="RIC">
    <status count="12">Finished</status>
    <status count="4">+1 Lap</status>
    <status count="1">Overheating</status>
  </driver>
  <driver number="4" code="NOR">
    <status count="12">Finished</status>
    <status count="4">+1 Lap</status>
    <status count="1">Power Unit</status>
  </driver>
  <driver number="5" code="VET">
    <status count="9">Finished</status>
    <status count="6">+1 Lap</status>
    <status count="1">Brakes</status>
    <status count="1">Collision damage</status>
  </driver>
  <driver number="6" code="LAT">
    <status count="6">Finished</status>
    <status count="4">+1 Lap</status>
    <status count="3">+2 Laps</status>
    <status count="1">Engine</status>
    <status count="1">+5 Laps</status>
    <status count="1">Collision</status>
    <status count="1">Collision damage</status>
  </driver>
  <driver number="7" code="RAI">
    <status count="10">+1 Lap</status>
    <status count="6">Finished</status>
    <status count="1">Wheel</status>
  </driver>
  <driver number="8" code="GRO">
    <status count="6">Finished</status>
    <status count="5">+1 Lap</status>
    <status count="1">Brakes</status>
    <status count="1">+2 Laps</status>
    <status count="1">Collision</status>
    <status count="1">Collision damage</status>
  </driver>
  <driver number="10" code="GAS">
    <status count="10">Finished</status>
    <status count="4">+1 Lap</status>
    <status count="1">Engine</status>
    <status count="1">Water pressure</status>
    <status count="1">Collision</status>
  </driver>
  <driver number="11" code="PER">
    <status count="10">Finished</status>
    <status count="3">+1 Lap</status>
    <status count="1">Engine</status>
    <status count="1">Transmission</status>
  </driver>
  <driver number="16" code="LEC">
    <status count="10">Finished</status>
    <status count="3">+1 Lap</status>
    <status count="1">Accident</status>
    <status count="1">Collision</status>
    <status count="1">Electronics</status>
    <status count="1">Collision damage</status>
  </driver>
  <driver number="18" code="STR">
    <status count="10">Finished</status>
    <status count="2">Collision</status>
    <status count="1">+1 Lap</status>
    <status count="1">Engine</status>
    <status count="1">Puncture</status>
    <status count="1">Collision damage</status>
  </driver>
  <driver number="20" code="MAG">
    <status count="7">+1 Lap</status>
    <status count="3">Finished</status>
    <status count="2">Collision</status>
    <status count="1">Illness</status>
    <status count="1">Withdrew</status>
    <status count="1">Brakes</status>
    <status count="1">Retired</status>
    <status count="1">Power Unit</status>
  </driver>
  <driver number="23" code="ALB">
    <status count="13">Finished</status>
    <status count="2">+1 Lap</status>
    <status count="1">Radiator</status>
    <status count="1">Electronics</status>
  </driver>
  <driver number="26" code="KVY">
    <status count="8">Finished</status>
    <status count="6">+1 Lap</status>
    <status count="1">Accident</status>
    <status count="1">+2 Laps</status>
    <status count="1">Suspension</status>
  </driver>
  <driver number="27" code="HUL">
    <status count="2">Finished</status>
    <status count="1">Power Unit</status>
  </driver>
  <driver number="31" code="OCO">
    <status count="9">Finished</status>
    <status count="4">+1 Lap</status>
    <status count="2">Gearbox</status>
    <status count="1">Brakes</status>
    <status count="1">Overheating</status>
  </driver>
  <driver number="33" code="VER">
    <status count="12">Finished</status>
    <status count="1">Puncture</status>
    <status count="1">Accident</status>
    <status count="1">Collision</status>
    <status count="1">Electronics</status>
    <status count="1">Power Unit</status>
  </driver>
  <driver number="44" code="HAM">
    <status count="16">Finished</status>
  </driver>
  <driver number="51" code="FIT">
    <status count="1">+2 Laps</status>
    <status count="1">Finished</status>
  </driver>
  <driver number="55" code="SAI">
    <status count="10">Finished</status>
    <status count="4">+1 Lap</status>
    <status count="1">Exhaust</status>
    <status count="1">Accident</status>
    <status count="1">Collision</status>
  </driver>
  <driver number="63" code="RUS">
    <status count="8">+1 Lap</status>
    <status count="4">Finished</status>
    <status count="1">Fuel pressure</status>
    <status count="1">Accident</status>
    <status count="1">+2 Laps</status>
    <status count="1">Collision</status>
    <status count="1">Debris</status>
  </driver>
  <driver number="77" code="BOT">
    <status count="15">Finished</status>
    <status count="1">+1 Lap</status>
    <status count="1">Power Unit</status>
  </driver>
  <driver number="89" code="AIT">
    <status count="1">Finished</status>
  </driver>
  <driver number="99" code="GIO">
    <status count="8">+1 Lap</status>
    <status count="6">Finished</status>
    <status count="1">Accident</status>
    <status count="1">Collision</status>
    <status count="1">Gearbox</status>
  </driver>
</drivers>
```

**10. lekérdezés:**

A lekérdezés egy olyan HTML dokumentumot állít elő, amely szemlélteti a 2020-as csapat, illetve pilóta sorrendet

```xquery
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

```
