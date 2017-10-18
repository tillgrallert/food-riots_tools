<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:html="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs"
    version="2.0">

<xsl:output method="text" encoding="UTF-8" omit-xml-declaration="yes"/>
    
    <!-- this stylesheet can be run on any XML input. The actual data set is provided by $v_data-source -->

<!--    <xsl:include href="tei-measure_normalize.xsl"/>-->
    <xsl:include href="tei-measureGrp_convert-to-csv.xsl"/>
    
    <xsl:param name="p_commodity" select="'wheat'"/>
    <xsl:param name="p_unit" select="'kile'"/>
    <xsl:param name="p_debug" select="false()"/>
    
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
    
    <xsl:variable name="v_data-source-normalized">
        <xsl:apply-templates select="$v_data-source" mode="m_normalize-unit"/>
    </xsl:variable>
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
                    <xsl:result-document href="_output/prices_{$p_commodity}-{$p_unit}-{ format-date(current-date(),'[Y0001]-[M01]-[D01]')}.csv">
                        <xsl:value-of select="$v_csv-head"/>
                    <xsl:apply-templates select="$v_data-source-regularized/descendant::tei:measureGrp[descendant::tei:measure[@commodity=$p_commodity][@unit=$p_unit]]" mode="m_tei-to-csv">
                        <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@year"/>
                        <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@month"/>
                        <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@day"/>
                    </xsl:apply-templates>
                    </xsl:result-document>
                </xsl:when>
                <!-- only commodity is set -->
                <xsl:when test="$p_commodity!=''">
                    <xsl:result-document href="_output/prices_{$p_commodity}-{ format-date(current-date(),'[Y0001]-[M01]-[D01]')}.csv">
                        <xsl:value-of select="$v_csv-head"/>
                    <xsl:apply-templates select="$v_data-source-regularized/descendant::tei:measureGrp[descendant::tei:measure[@commodity=$p_commodity]]" mode="m_tei-to-csv">
                        <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@year"/>
                        <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@month"/>
                        <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@day"/>
                    </xsl:apply-templates>
                    </xsl:result-document>
                </xsl:when>
                <!-- only unit is set  -->
                <xsl:when test="$p_unit!=''">
                    <xsl:result-document href="_output/prices_{$p_unit}-{ format-date(current-date(),'[Y0001]-[M01]-[D01]')}.csv">
                        <xsl:value-of select="$v_csv-head"/>
                        <xsl:apply-templates select="$v_data-source-regularized/descendant::tei:measureGrp[descendant::tei:measure[@unit=$p_unit]]" mode="m_tei-to-csv">
                            <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@year"/>
                            <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@month"/>
                            <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@day"/>
                        </xsl:apply-templates>
                    </xsl:result-document>
                </xsl:when>
                <!-- all prices -->
                <xsl:otherwise>
                    <xsl:result-document href="_output/prices-{ format-date(current-date(),'[Y0001]-[M01]-[D01]')}.csv">
                        <xsl:value-of select="$v_csv-head"/>
                    <xsl:apply-templates select="$v_data-source-regularized/descendant::tei:measureGrp" mode="m_tei-to-csv">
                        <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@year"/>
                        <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@month"/>
                        <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@day"/>
                    </xsl:apply-templates>
                    </xsl:result-document>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:template>
</xsl:stylesheet>