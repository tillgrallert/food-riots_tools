<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="xs xsi"
    version="2.0">

    <xsl:output method="text" encoding="UTF-8" omit-xml-declaration="yes" name="text"/>
    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" name="xml" indent="yes"/>

    <!-- this stylesheet can be run on any XML input. The actual data set is provided by $v_data-source -->

    <xsl:include href="tei-measure_normalize.xsl"/>
    <xsl:include href="tei-measureGrp_convert-to-csv.xsl"/>
    
    <xsl:param name="p_regularize" select="true()"/>

   <!-- identity transform -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- transform individual measureGrps in the context they occur -->
    <xsl:template match="tei:measureGrp">
        <!-- 1. enrich all measureGrp with date information -->
        <xsl:variable name="v_data-source-enriched-dates">
            <xsl:apply-templates select="." mode="m_enrich-dates"/>
        </xsl:variable>
        <!-- 2. enrich all measureGrp with location information -->
        <xsl:variable name="v_data-source-enriched-locations">
            <xsl:apply-templates select="$v_data-source-enriched-dates" mode="m_enrich-locations"/>
        </xsl:variable>
        <!-- 3. add date and location information to measure descendants -->
        <xsl:variable name="v_data-source-enriched">
            <xsl:apply-templates select="$v_data-source-enriched-locations" mode="m_enrich"/>
        </xsl:variable>
        <!-- 4. normalize all non-metrical values -->
        <xsl:variable name="v_data-source-normalized">
            <xsl:apply-templates select="$v_data-source-enriched" mode="m_normalize-unit"/>
        </xsl:variable>
        <!-- 5. regularize everything to quantity = 1 for comparability of values -->
        <xsl:variable name="v_data-source-regularized">
            <xsl:apply-templates select="$v_data-source-normalized" mode="m_normalize-quantity"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$p_regularize = false()">
                <xsl:copy-of select="$v_data-source-regularized"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$v_data-source-normalized"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="/">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
        <!-- export summary files -->
        <!-- 1. enrich all measureGrp with date information -->
        <xsl:variable name="v_data-source-enriched-dates">
            <xsl:apply-templates select="descendant::tei:measureGrp" mode="m_enrich-dates"/>
        </xsl:variable>
        <!-- 2. enrich all measureGrp with location information -->
        <xsl:variable name="v_data-source-enriched-locations">
            <xsl:apply-templates select="$v_data-source-enriched-dates" mode="m_enrich-locations"/>
        </xsl:variable>
        <!-- 3. add date and location information to measure descendants -->
        <xsl:variable name="v_data-source-enriched">
            <xsl:apply-templates select="$v_data-source-enriched-locations" mode="m_enrich"/>
        </xsl:variable>
        <!-- 4. normalize all non-metrical values -->
        <xsl:variable name="v_data-source-normalized">
            <xsl:apply-templates select="$v_data-source-enriched" mode="m_normalize-unit"/>
        </xsl:variable>
        <!-- 5. regularize everything to quantity = 1 for comparability of values -->
        <xsl:variable name="v_data-source-regularized">
            <xsl:apply-templates select="$v_data-source-normalized" mode="m_normalize-quantity"/>
        </xsl:variable>
        
                <xsl:result-document href="_output/measureGrp-{
                    format-date(current-date(),'[Y0001]-[M01]-[D01]')}.xml" format="xml">
                    <tei:div>
                        <xsl:for-each select="$v_data-source-regularized/descendant::tei:measureGrp[tei:measure]">
                            <xsl:sort select="@when"/>
                            <xsl:sort select="@location"/>
                            <xsl:copy-of select="."/>
                        </xsl:for-each>
                    </tei:div>
                </xsl:result-document>
                <xsl:result-document href="_output/prices-{
                    format-date(current-date(),'[Y0001]-[M01]-[D01]')}.csv" format="text">
                    <xsl:value-of select="$v_csv-head"/>
                    <xsl:apply-templates
                        select="$v_data-source-regularized/descendant::tei:measureGrp"
                        mode="m_tei-to-csv">
                        <xsl:sort select="@when"/>
                        <xsl:sort select="@location"/>
                    </xsl:apply-templates>
                </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>
