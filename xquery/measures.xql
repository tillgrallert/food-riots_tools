xquery version "3.0";

declare namespace tss="http://www.thirdstreetsoftware.com/SenteXML-1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace html="http://www.w3.org/1999/xhtml";

declare option exist:serialize 'method=xhtml media-type=text/html indent=yes';
     
let $vLib := doc('/db/BachSources/xml/SourcesClean160620.TSS.xml')
(: let $vNyms := doc('/db/BachSources/xml/NymMaster.TEIP5.xml') :)
let $v_commodity :=request:get-parameter('commodity','wheat')

let $vStyleRefs := doc('/db/BachSources/xslt/Tss2Html-refs-link.xsl')
let $vStyleMeasureGrp := doc('/db/BachSources/xslt/Tei2Html-measureGrp-table.xsl')
let $vMeasureGrps := for $vHit in $vLib/descendant::tss:reference[./tss:publicationType[not(@name='Archival File')]]/descendant::tei:measureGrp[not(ancestor::tei:measureGrp)][descendant::tei:measure/@commodity=$v_commodity]
    return $vHit
    
(: construct a search form :)
let $v_form-search :=
    <tei:div xml:lang="en">
        <form action="measures.xql" method="get">
            <tei:p>
                <span lang="en">Search for the </span>
                <input lang="en" type="text" name="commodity" size="7" value="{$v_commodity}"/>
                <span lang="en"> commodity.</span>
                <input class="gobox" type="submit" value="GO" />
                </tei:p>
        </form>
    </tei:div>

return 
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>BachSources</title>
        <link rel="stylesheet" href="../css/reference-list.css" type="text/css"></link>
        <link rel="stylesheet" href="../css/table.css" type="text/css"></link>
    </head>
    <body>
        <div>
            <h1>BachSources</h1>
            <div>
                <p>This page searches for measures and prices of <em>{$v_commodity}</em> can reached under <a href="http://localhost:8080/exist/rest/db/BachSources/xquery/measures.xql">http://localhost:8080/exist/rest/db/BachSources/xquery/measures.xql</a></p>
            </div>
            {$v_form-search}
            <div>
                <h2></h2>
                <!-- <div>{$vSearchQuery}</div> -->
                <table>
                    <thead>
                        <th>Date</th>
                        <th>Source</th>
                    </thead>
                    <tbody>
                {
                for $vMeasureGrp in $vMeasureGrps/self::tei:measureGrp
                    (:let $vPrice := $vMeasureGrp/descendant::tei:measure[@commodity='currency'][1] :)
                    let $vRef := $vMeasureGrp/ancestor::tss:reference
                    let $vDate := $vRef/tss:dates/tss:date[@type='Publication']
                    let $vDateFormatted := concat($vDate/@year,'-',format-number($vDate/@month,'00'),'-',format-number($vDate/@day,'00'))
                    order by $vDateFormatted
                return
                    <tr>
                        <td>{$vDateFormatted}</td>
                        <td>{transform:transform($vRef, $vStyleRefs,())}</td>
                        {transform:transform($vMeasureGrp, $vStyleMeasureGrp,())}
                        <td>{$vMeasureGrp}</td>
                    </tr>
                    
                }
                </tbody>
                </table>
            </div>
            <!-- debugging section -->
            <!-- <div>{$vRefs}</div> -->
        </div>
    </body>
</html>