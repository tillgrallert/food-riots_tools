<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs" version="2.0">

    <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no" name="xml"/>
    <xsl:output method="text" indent="yes" encoding="UTF-8" omit-xml-declaration="yes" name="text"/>
    
    <!-- this stylesheet normalizes the attributes on tei:measure. Unfortunately <tei:measure> is not datable and cannot carry the when attribute. Therefore normalization cannot be based on changes over time -->
    <!-- The normalizations are based on a number of primary sources, most notably among them: Chambre de Commerce Française de Constantinople. *Poids, Mesures, Monnaies et Cours du Change Dans les Principales Localités de L'Empire Ottoman à la Fin du 19e Siècle.* Istanbul: Isis, 2002 [1893]; Handelsarchiv 15 Nov. 1878 (#1878, Teil 2):II 489-96; NACP RG 84 Damascus Vol.8 Damascus 85, *Weights and Measures*, Mishāqa to Bissinger 22 Nov. 1889. -->
    
    <!-- $v_weight-okka expresses the weight of an okka in kg -->
    <xsl:variable name="v_weight-okka" select="1.282945"/>

    <!-- identity transform -->
    <xsl:template match="node() | @*" mode="m_enrich-dates">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="m_enrich-dates"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="node() | @*" mode="m_enrich-locations">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="m_enrich-locations"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="node() | @*" mode="m_enrich">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="m_enrich"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="@* | node()" mode="m_normalize-unit">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="m_normalize-unit"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="@* | node()" mode="m_normalize-quantity">
        <xsl:param name="p_regularization-factor" select="1"/>
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="m_normalize-quantity">
                <xsl:with-param name="p_regularization-factor" select="$p_regularization-factor"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <!-- add temporal information -->
    <!-- undated measureGrp -->
    <xsl:template match="tei:measureGrp[not(@when)]" mode="m_enrich-dates">
        <xsl:variable name="v_date-publication">
            <xsl:choose>
                <!-- check if full publication date is available -->
                <xsl:when test="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@day!=''">
                    <xsl:value-of select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@year"/>
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="format-number(ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@month,'00')"/>
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="format-number(ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@day,'00')"/>
                </xsl:when>
                <!-- otherwise use only publication year -->
                <xsl:when test="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@year!=''">
                    <xsl:value-of select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@year"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="v_id-source" select="ancestor::tss:reference/tss:characteristics/tss:characteristic[@name='UUID']"/>
        <!-- it can be that more than one of the <tei:measure> children are dated. In this case the measureGrp should be split -->
        <xsl:choose>
            <!-- test if the measure describing the money commodity is dated -->
            <xsl:when test="count(descendant::tei:measure[@commodity='currency'][@when]) &gt; 1">
                <xsl:for-each select="descendant::tei:measure[@commodity='currency'][@when]">
                    <tei:measureGrp type="split" source="{$v_id-source}" when="{@when}">
                        <xsl:copy-of select="ancestor::tei:measureGrp/descendant::tei:measure[not(@commodity='currency')]"/>
                        <xsl:apply-templates select="." mode="m_enrich-dates"/>
                    </tei:measureGrp>
                </xsl:for-each>
            </xsl:when>
            <!-- otherwise the measureGrp shall be dated with the publication date  -->
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*" mode="m_enrich-dates"/>
                    <xsl:attribute name="when" select="$v_date-publication"/>
                    <xsl:attribute name="source" select="$v_id-source"/>
                    <xsl:apply-templates select="node()" mode="m_enrich-dates"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- add location information -->
    <xsl:template match="tei:measureGrp[not(@location)]" mode="m_enrich-locations">
        <!-- it can be that more than one of the <tei:measure> children carry location data. In this case the measureGrp should be split. Note that @location on measure is only provided in exactly these cases -->
        <xsl:choose>
            <!-- test if the measure describing the money commodity is dated -->
            <xsl:when test="count(descendant::tei:measure[@commodity='currency'][@location]) &gt; 1">
                <xsl:for-each select="descendant::tei:measure[@commodity='currency'][@location]">
                    <tei:measureGrp type="split">
                        <xsl:apply-templates select="@*" mode="m_enrich-locations"/>
                        <xsl:attribute name="location" select="@location"/>
                        <xsl:copy-of select="ancestor::tei:measureGrp/descendant::tei:measure[not(@commodity='currency')]"/>
                        <xsl:apply-templates select="." mode="m_enrich-locations"/>
                    </tei:measureGrp>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
        <xsl:variable name="v_location">
            <xsl:choose>
                <!-- when there is only one located measure child, its @location value should also be applied to the parent -->
                <xsl:when test="count(descendant::tei:measure[@commodity='currency'][@location]) = 1">
                    <xsl:value-of select="descendant::tei:measure[@commodity='currency'][@location]"/>
                </xsl:when>
                <!-- probably a parent measureGrp has location information -->
                <xsl:when test="ancestor::tei:measureGrp[@location]">
                    <xsl:value-of select="ancestor::tei:measureGrp/@location"/>
                </xsl:when>
                <!-- otherwise pick the publication place of the source -->
                <xsl:when test="ancestor::tss:reference/tss:characteristics/tss:characteristic[@name='publicationCountry']">
                    <xsl:value-of select="normalize-space(ancestor::tss:reference/tss:characteristics/tss:characteristic[@name='publicationCountry'])"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="m_enrich-locations"/>
            <xsl:attribute name="location" select="$v_location"/>
            <xsl:apply-templates select="node()" mode="m_enrich-locations"/>
        </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- add source information -->
    <xsl:template match="tei:measureGrp[not(@source)]" mode="m_enrich">
        <xsl:variable name="v_id-source" select="ancestor::tss:reference/tss:characteristics/tss:characteristic[@name='UUID']"/>
        <xsl:copy>
            <xsl:attribute name="source" select="$v_id-source"/>
            <xsl:apply-templates select="@* | node()" mode="m_enrich"/>
        </xsl:copy>
    </xsl:template>
    <!-- add date and location information based on the nearest ancestor measureGrp -->
    <xsl:template match="tei:measure" mode="m_enrich">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="not(@when) and not(@location)">
                    <xsl:attribute name="when" select="ancestor::tei:measureGrp[1]/@when"/>
                    <xsl:attribute name="location" select="ancestor::tei:measureGrp[1]/@location"/>
                </xsl:when>
                <xsl:when test="not(@when)">
                    <xsl:attribute name="when" select="ancestor::tei:measureGrp[1]/@when"/>
                </xsl:when>
                <xsl:when test="not(@location)">
                    <xsl:attribute name="location" select="ancestor::tei:measureGrp[1]/@location"/>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="@* | node()" mode="m_enrich"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- regularize all measureGrp that express a price to provide information on one whole unit  -->
    <xsl:template match="tei:measureGrp[descendant::tei:measure/@commodity='currency'][descendant::tei:measure[@commodity!='currency'][@quantity!=1]]" mode="m_normalize-quantity">
        <xsl:variable name="v_regularization-factor" select="1 div number(descendant::tei:measure[@commodity!='currency'][1]/@quantity)" as="xs:double"/>
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="m_normalize-quantity">
                <xsl:with-param name="p_regularization-factor" select="$v_regularization-factor"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:measure" mode="m_normalize-quantity">
        <xsl:param name="p_regularization-factor" select="1" as="xs:double"/>
          <xsl:copy>
              <!-- reproduce existing attributes -->
              <xsl:copy-of select="@*"/>
              <xsl:attribute name="type" select="'regularized'"/>
              <xsl:apply-templates select="@commodity | @unit" mode="m_normalize-quantity"/>
              <xsl:attribute name="quantity" select="@quantity * $p_regularization-factor"/>
              <xsl:apply-templates mode="m_normalize-quantity"/>
          </xsl:copy>
    </xsl:template>

    <!-- normalize and harmonize the commodities and units of <tei:measure> -->
    <xsl:template match="tei:measure" mode="m_normalize-unit">
        <xsl:copy>
            <!-- reproduce existing attributes -->
            <xsl:copy-of select="@*"/>
            <!-- some commodity values should be normalized -->
            <xsl:choose>
                <xsl:when test="(@commodity='ervil') or (@commodity='kirsanna')">
                    <xsl:attribute name="commodity" select="'vetch'"/>
                </xsl:when>
                <xsl:when test="@commodity='ful'">
                    <xsl:attribute name="commodity" select="'broad-beans'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@commodity" mode="m_normalize-unit"/>
                </xsl:otherwise>
            </xsl:choose>
            <!-- normalise @unit -->
            <xsl:choose>
                <!-- normalize volumes to kile -->
                <!--    1 shunbul = 6 madd = 3 kile (in Aleppo)
                         1 shunbul = 2,25 kile (in Tripoli and Acre) -->
                <xsl:when test="@unit = 'shunbul'">
                    <xsl:attribute name="type" select="'normalized'"/>
                    <xsl:attribute name="unit" select="'kile'"/>
                    <xsl:attribute name="quantity" select="@quantity * 3"/>
                </xsl:when>
                <!-- 1 cift = 1 kile -->
                <xsl:when test="@unit = 'cift'">
                    <xsl:attribute name="type" select="'normalized'"/>
                    <xsl:attribute name="unit" select="'kile'"/>
                    <xsl:attribute name="quantity" select="@quantity"/>
                </xsl:when>
                <!-- 1 madd = 0.5 kile -->
                <xsl:when test="@unit = 'madd'">
                    <xsl:attribute name="type" select="'normalized'"/>
                    <xsl:attribute name="unit" select="'kile'"/>
                    <xsl:attribute name="quantity" select="@quantity * 0.5"/>
                </xsl:when>
                <!-- the basis of all weights in the Arabic provinces of the Ottoman Empire is the okka with the help of $v_weihgt-okka they are normalized to kg  -->
                <xsl:when test="@unit = 'okka'">
                    <xsl:attribute name="type" select="'normalized'"/>
                    <xsl:attribute name="unit" select="'kg'"/>
                    <xsl:attribute name="quantity" select="@quantity  * $v_weight-okka"/>
                </xsl:when>
                <!-- 1 ratl = 2 okka -->
                <xsl:when test="@unit = 'ratl'">
                    <xsl:attribute name="type" select="'normalized'"/>
                    <xsl:attribute name="unit" select="'kg'"/>
                    <xsl:attribute name="quantity" select="@quantity * 2 * $v_weight-okka"/>
                </xsl:when>
                <!-- 1 okka = 400 dirham -->
                <xsl:when test="@unit = 'dirham'">
                    <xsl:attribute name="type" select="'normalized'"/>
                    <xsl:attribute name="unit" select="'kg'"/>
                    <xsl:attribute name="quantity" select="@quantity div 400 * $v_weight-okka"/>
                </xsl:when>
                <!-- 1 qintār = 44 okka in Istanbul
                      1 qintār = 200 okka in Damascus
                      1 qintār = 250 okka in Antiochia / 
                      1 qinṭār = 40 okka in Mosul 
                      1 qinṭar = 400 okka in Haifa -->
                <xsl:when test="@unit = 'qintar'">
                    <xsl:attribute name="type" select="'normalized'"/>
                    <xsl:attribute name="unit" select="'kg'"/>
                    <xsl:attribute name="quantity" select="@quantity * 200 * $v_weight-okka"/>
                </xsl:when>
                <!-- 1 wazna = 12,5 ratl = 25 okka (in Damascus) -->
                <xsl:when test="@unit = 'wazana' or @unit = 'wazna'">
                    <xsl:attribute name="type" select="'normalized'"/>
                    <xsl:attribute name="unit" select="'kg'"/>
                    <xsl:attribute name="quantity" select="@quantity * 25 * $v_weight-okka"/>
                </xsl:when>
                <!-- normalize metrical weights to kg -->
                <!-- 1 t = 1000 kg -->
                <xsl:when test="@unit = 't'">
                    <xsl:attribute name="type" select="'normalized'"/>
                    <xsl:attribute name="unit" select="'kg'"/>
                    <xsl:attribute name="quantity" select="@quantity * 1000"/>
                </xsl:when>
                <!-- 1 kg = 1000 gr -->
                <xsl:when test="@unit = 'gr'">
                    <xsl:attribute name="type" select="'normalized'"/>
                    <xsl:attribute name="unit" select="'kg'"/>
                    <xsl:attribute name="quantity" select="@quantity div 1000"/>
                </xsl:when>
                <!-- normalise currencies -->
                <!-- 100 Ps = 1 Lt -->
                <!-- even though the nominal value of £T1 remained Ps 100, the Ottoman empire established an official exchange rate of £T1= Ps 123 in May 1883 -->
                <xsl:when test="@commodity = 'currency' and @unit = 'lt'">
                    <xsl:attribute name="type" select="'normalized'"/>
                    <xsl:attribute name="unit" select="'ops'"/>
                    <xsl:attribute name="quantity" select="@quantity * 100"/>
                </xsl:when>
                <!-- 20 Ps = 1 Mec -->
                <!-- the Ottoman Empire devaluated the mecidiye for the purpose of tax payments from Ps 20 to 19 in 1880 -->
                <xsl:when test="@commodity = 'currency' and @unit = 'mec'">
                    <xsl:attribute name="type" select="'normalized'"/>
                    <xsl:attribute name="unit" select="'ops'"/>
                    <xsl:attribute name="quantity" select="@quantity * 20"/>
                </xsl:when>
                <!-- fallback -->
                <xsl:otherwise>
                    <xsl:apply-templates select="@*" mode="m_normalize-unit"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates mode="m_normalize-unit"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
