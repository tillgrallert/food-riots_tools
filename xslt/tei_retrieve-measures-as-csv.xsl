<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:html="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs"
    version="2.0">
    
<!--    <xsl:include href="tei-measure_normalize.xsl"/>-->
    <xsl:include href="tei-measureGrp_convert-to-csv.xsl"/>
    
    <xsl:param name="p_commodity" select="''"/>
    <xsl:param name="p_debug" select="true()"/>
    
    <xsl:variable name="v_data-source">
        <xsl:choose>
            <!-- run on small sample of test data -->
            <xsl:when test="$p_debug = true()">
                <xsl:copy-of select="collection('/Volumes/Dessau HD/BachCloud/BTSync/FormerDropbox/PostDoc Food Riots/food-riots_tools/examples/tss?select=*.TSS.xml')"/>
            </xsl:when>
            <!-- run on full sample -->
            <xsl:otherwise>
                <xsl:copy-of select="collection('/Volumes/Dessau HD/BachUni/BachBibliothek/GitHub/Sente/tss_data/BachSources?select=*.TSS.xml')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:template match="/">
        <!-- one line for each normalized tei:measureGrp:
        1. column: should information on dates
        2. column: full copy of the original data
        3. column and following: normalized CSV data -->
        <xsl:value-of select="$v_new-line"/>
        <xsl:choose>
            <xsl:when test="$p_commodity!=''">
                <xsl:apply-templates select="$v_data-source/descendant::tei:measureGrp[descendant::tei:measure[@commodity=$p_commodity]]" mode="m_tei-to-csv">
                    <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@year"/>
                    <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@month"/>
                    <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@day"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$v_data-source/descendant::tei:measureGrp" mode="m_tei-to-csv">
                    <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@year"/>
                    <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@month"/>
                    <xsl:sort select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@day"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>