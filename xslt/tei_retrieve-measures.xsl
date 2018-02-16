<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="xs xsi"
    version="2.0">

    <xsl:output method="text" encoding="UTF-8" omit-xml-declaration="yes" name="text"/>
    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" name="xml" indent="yes"/>
    
    <!-- this stylesheet can be run on any XML input. The actual data set is provided by $v_data-source -->

    <xsl:include href="tei-measure_normalize.xsl"/>
    
    
    <xsl:param name="p_commodity" select="'wheat'"/>
    <xsl:param name="p_unit" select="'kile'"/>
    <xsl:param name="p_debug" select="true()"/>
    
    <xsl:variable name="v_data-source">
        <xsl:choose>
            <!-- run on small sample of test data -->
            <xsl:when test="$p_debug = true()">
                <xsl:copy-of select="collection('/Volumes/Dessau HD/BachCloud/BTSync/FormerDropbox/FoodRiots/food-riots_tools/examples/tss?select=*.TSS.xml')[not(descendant::tss:publicationType[@name='Archival File' or @name='Archival Material'])][descendant::tei:measureGrp]"/>
            </xsl:when>
            <!-- run on full sample: the source collection does contain double entries of information (one reference for an archival file and one for each consituent letters). The summary files must be excluded to not significantly distort the sample -->
            <xsl:otherwise>
                <xsl:copy-of select="collection('/Volumes/Dessau HD/BachUni/BachBibliothek/GitHub/Sente/tss_data/BachSources?select=*.TSS.xml')[not(descendant::tss:publicationType[@name='Archival File' or @name='Archival Material'])][descendant::tei:measureGrp]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- 1. enrich all measures with date information -->
    <xsl:variable name="v_data-source-enriched-dates">
        <xsl:apply-templates select="$v_data-source" mode="m_enrich-dates"/>
    </xsl:variable>
    <!-- enrich with location information -->
    <xsl:variable name="v_data-source-enriched-locations">
        <xsl:apply-templates select="$v_data-source" mode="m_enrich-locations"/>
    </xsl:variable>
    <!-- 2. normalize all non-metrical values -->
    <xsl:variable name="v_data-source-normalized">
        <xsl:apply-templates select="$v_data-source-enriched-locations" mode="m_normalize-unit"/>
    </xsl:variable>
    <!-- 3. regularize everything to quantity = 1 for comparability of values -->
    <xsl:variable name="v_data-source-regularized">
        <xsl:apply-templates select="$v_data-source-normalized" mode="m_normalize-quantity"/>
    </xsl:variable>
    
    <xsl:template match="/">
        <!-- one line for each normalized tei:measureGrp:
        1. column: should information on dates
        2. column: UUID of the source reference
        3. column: full copy of the original data
        4. column and following: normalized CSV data -->
            <xsl:choose>
                <!-- commodity and unit are set -->
                <xsl:when test="$p_commodity!='' and $p_unit!=''">
                    <xsl:result-document href="_output/measureGrp_{$p_commodity}-{$p_unit}-{ format-date(current-date(),'[Y0001]-[M01]-[D01]')}.xml" format="xml">
                    <tei:div><xsl:for-each select="$v_data-source-enriched-locations/descendant::tei:measureGrp[descendant::tei:measure[@commodity=$p_commodity][@unit=$p_unit]]">
                        <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@year"/>
                        <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@month"/>
                        <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@day"/>
<!--                        <xsl:apply-templates select="." mode="m_enrich-dates"/>-->
                        <xsl:copy-of select="."/>
                    </xsl:for-each></tei:div>
                    </xsl:result-document>
                </xsl:when>
                <!-- only commodity is set -->
                <xsl:when test="$p_commodity!=''">
                    <xsl:result-document href="_output/measureGrp_{$p_commodity}-{ format-date(current-date(),'[Y0001]-[M01]-[D01]')}.xml">
                    <tei:div><xsl:for-each select="$v_data-source-regularized/descendant::tei:measureGrp[descendant::tei:measure[@commodity=$p_commodity]]">
                        <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@year"/>
                        <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@month"/>
                        <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@day"/>
                        <xsl:copy-of select="."/>
                    </xsl:for-each></tei:div>
                    </xsl:result-document>
                </xsl:when>
                <!-- only unit is set  -->
                <xsl:when test="$p_unit!=''">
                    <xsl:result-document href="_output/measureGrp_{$p_unit}-{ format-date(current-date(),'[Y0001]-[M01]-[D01]')}.xml">
                        <xsl:apply-templates select="$v_data-source-regularized/descendant::tei:measureGrp[descendant::tei:measure[@unit=$p_unit]]" mode="m_tei-to-csv">
                            <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@year"/>
                            <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@month"/>
                            <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@day"/>
                        </xsl:apply-templates>
                    </xsl:result-document>
                </xsl:when>
                <!-- all prices -->
                <xsl:otherwise>
                    <xsl:result-document href="_output/measureGrp-{ format-date(current-date(),'[Y0001]-[M01]-[D01]')}.xml">
                    <xsl:apply-templates select="$v_data-source-regularized/descendant::tei:measureGrp" mode="m_tei-to-csv">
                        <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@year"/>
                        <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@month"/>
                        <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@day"/>
                    </xsl:apply-templates>
                    </xsl:result-document>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:template>
    
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
    <!-- add temporal information -->
    <!-- undated measureGrp -->
    <xsl:template match="tei:measureGrp[not(@when)]" mode="m_enrich-dates" priority="10">
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
                <xsl:if test="$p_debug=true()">
                    <xsl:message>This measureGrp has dated measure children</xsl:message>
                </xsl:if>
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
        <xsl:variable name="v_location">
            <xsl:choose>
                <!-- if the measureGrp has located measure children, the value of @location should be set to "NA" -->
                <xsl:when test="count(descendant::tei:measure[@commodity='currency'][@location]) &gt; 1">
                    <xsl:text>NA</xsl:text>
                </xsl:when>
                <!-- when there is only one located measure child, its @location value should also be applied to the parent -->
                <xsl:when test="count(descendant::tei:measure[@commodity='currency'][@location]) = 1">
                    <xsl:value-of select="descendant::tei:measure[@commodity='currency'][@location]"/>
                </xsl:when>
                <!-- otherwise pick the publication place of the source -->
                <xsl:when test="ancestor::tss:reference/tss:characteristics/tss:characteristic[@name='publicationCountry']">
                    <xsl:value-of select="normalize-space(ancestor::tss:reference/tss:characteristics/tss:characteristic[@name='publicationCountry'])"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy>
            <xsl:if test="$p_debug = true()">
                <xsl:message>
                    <xsl:value-of select="."/>
                </xsl:message>
            </xsl:if>
            <xsl:apply-templates select="@*" mode="m_enrich-locations"/>
            <xsl:attribute name="location" select="$v_location"/>
            <xsl:apply-templates select="node()" mode="m_enrich-locations"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- add source information -->
    <xsl:template match="tei:measureGrp[not(@source)]" mode="m_enrich-dates">
        <xsl:variable name="v_id-source" select="ancestor::tss:reference/tss:characteristics/tss:characteristic[@name='UUID']"/>
        <xsl:copy>
            <xsl:attribute name="source" select="$v_id-source"/>
            <xsl:apply-templates select="@* | node()" mode="m_enrich-dates"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>