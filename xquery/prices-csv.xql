xquery version "3.0";

declare namespace tss = "http://www.thirdstreetsoftware.com/SenteXML-1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace html = "http://www.w3.org/1999/xhtml";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "text";
declare option output:media-type "text/plain";
declare option output:indent "no";

let $vLib := doc('/db/BachSources/xml/SourcesClean160620.TSS.xml')
(: let $vNyms := doc('/db/BachSources/xml/NymMaster.TEIP5.xml') :)
let $v_commodity := request:get-parameter('commodity', 'wheat')
let $v_unit:= request:get-parameter('unit', 'kile')
let $v_year-start:= request:get-parameter('year-start', '1850')
let $v_year-stop:= request:get-parameter('year-stop', '1950')
(: set a separator to separate values in the resulting file:)
let $v_separator := ','

(:let $vStyleRefs := doc('/db/BachSources/xslt/Tss2Html-refs-link.xsl'):)
let $vStyleMeasureGrp := doc('/db/BachSources/xslt/Tei2Csv-measureGrp-normalised.xsl')
(: $vStyleMeasureGrp attempts to normalises the unit of measurement. Thus the condition [@unit=$v_unit] should be removed from the let selection :)
(: let $vMeasureGrps := for $vHit in $vLib/descendant::tss:reference[./tss:publicationType[not(@name = 'Archival File')]]/descendant::tei:measureGrp[not(ancestor::tei:measureGrp)][descendant::tei:measure[@commodity = $v_commodity][@unit=$v_unit]][descendant::tei:measure[@commodity = 'currency'][@unit ='ops']] :)
let $vMeasureGrps := for $vHit in $vLib/descendant::tss:reference[./tss:publicationType[not(@name = 'Archival File')]][tss:dates/tss:date[@type='Publication']/@year > $v_year-start][tss:dates/tss:date[@type='Publication']/@year < $v_year-stop]/descendant::tei:measureGrp[not(ancestor::tei:measureGrp)][descendant::tei:measure[@commodity = $v_commodity]][descendant::tei:measure[@commodity = 'currency'][@unit ='ops']]
    return
        $vHit
let $vValueList :=    for $vMeasureGrp in $vMeasureGrps/self::tei:measureGrp
    (:let $vPrice := $vMeasureGrp/descendant::tei:measure[@commodity='currency'][1] :)
    let $vRef := $vMeasureGrp/ancestor::tss:reference
    let $vDate := $vRef/tss:dates/tss:date[@type = 'Publication']
    let $vDateFormatted := concat($vDate/@year, '-', format-number($vDate/@month, '00'), '-', format-number($vDate/@day, '00'))
    order by $vDateFormatted
    return
         concat($vDateFormatted,$v_separator,transform:transform($vMeasureGrp, $vStyleMeasureGrp, <parameters><param name="pCommodity" value="{$v_commodity}"/><param name="pUnit" value="{$v_unit}"/><param name="p_separator" value="{$v_separator}"/></parameters>))

return 
$vValueList