<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0" 
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:html="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no" name="xml"/>
    <xsl:output method="text" indent="yes" encoding="UTF-8" omit-xml-declaration="yes" name="text"/>
    <!-- there is usually just one entry for non-curreny commodities -->
    <!-- as I feed the output directly into a graph, the commodity should be omitted -->
    <!-- the structure should be:
        - commodity
        - prices -->
    
    <xsl:include href="tei-measure_normalize.xsl"/>
    
    <xsl:param name="p_separator" select="','"/>
    <xsl:param name="p_normalize" select="true()"/>
    <xsl:variable name="v_new-line" select="'&#x0A;'"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="descendant::tei:measureGrp" mode="m_tei-to-csv"/>
    </xsl:template>
    
    <!-- currently this nested <tei:measureGrp>s -->
    <xsl:template match="tei:measureGrp" mode="m_tei-to-csv">
        <xsl:value-of select="$v_new-line"/>
        <xsl:apply-templates select="tei:measure[not(@commodity='currency')]" mode="m_tei-to-csv"/>
        <xsl:apply-templates select="tei:measure[@commodity='currency']" mode="m_tei-to-csv"/>
    </xsl:template>
    
    <xsl:template match="tei:measure" mode="m_tei-to-csv">
        <xsl:variable name="v_normalized">
            <xsl:choose>
            <xsl:when test="$p_normalize = true()">
                <xsl:apply-templates select="."/>
            </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$v_normalized/tei:measure/@commodity"/><xsl:value-of select="$p_separator"/>
        <xsl:value-of select="$v_normalized/tei:measure/@quantity"/><xsl:value-of select="$p_separator"/>
        <xsl:value-of select="$v_normalized/tei:measure/@unit"/>
        <xsl:if test="following-sibling::tei:measure">
            <xsl:value-of select="$p_separator"/>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>