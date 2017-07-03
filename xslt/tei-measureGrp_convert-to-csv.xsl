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
    <xsl:param name="p_separator-escape" select="';'"/>
    <xsl:param name="p_normalize" select="true()"/>
    <xsl:variable name="v_new-line" select="'&#x0A;'"/>
    
    <!--<xsl:template match="/">
        <xsl:apply-templates select="descendant::tei:measureGrp" mode="m_tei-to-csv"/>
    </xsl:template>-->
    
    <!-- currently this nested <tei:measureGrp>s -->
    <!-- one line for each normalized tei:measureGrp:
        1. column: should information on dates
        2. column: UUID of the source reference
        3. column: full copy of the original data
        4. column and following: normalized CSV data -->
    <xsl:variable name="v_csv-head">
        <xsl:text>date, source-uuid, orig-data, commodity-1, quantity-1, unit-1, commodity-2, quantity-2, unit-2,</xsl:text><xsl:copy-of select="$v_new-line"/>
    </xsl:variable>
    <xsl:template match="tei:measureGrp[ancestor::tss:senteContainer]" mode="m_tei-to-csv">
        <!-- 1. column: information on dates -->
        <xsl:apply-templates select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']"/><xsl:value-of select="$p_separator"/>
        <!-- 2. column: UUID of the source reference -->
        <xsl:value-of select="ancestor::tss:reference/tss:characteristics/tss:characteristic[@name='UUID']"/><xsl:value-of select="$p_separator"/>
        <!-- 3. column: full copy of the original data -->
        <xsl:value-of select=" replace(normalize-space(.),$p_separator,$p_separator-escape)" disable-output-escaping="no"/><xsl:value-of select="$p_separator"/>
        <xsl:apply-templates select="tei:measure[not(@commodity='currency')]" mode="m_tei-to-csv"/>
        <xsl:apply-templates select="tei:measure[@commodity='currency']" mode="m_tei-to-csv"/>
        <xsl:value-of select="$v_new-line"/>
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
        <!-- since the output re-sorts the child elements, following-sibling:: is not the correct axis -->
        <xsl:if test="count(parent::node()/tei:measure) &gt; 1">
            <xsl:value-of select="$p_separator"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tss:date">
        <xsl:choose>
            <xsl:when test="@year and @month and @day">
                <xsl:value-of select="concat(format-number(@year,'0000'),'-',format-number(@month,'00'),'-',format-number(@day,'00'))"/>
            </xsl:when>
            <xsl:when test="@year and @month">
                <xsl:value-of select="concat(format-number(@year,'0000'),'-',format-number(@month,'00'),'-01')"/>
            </xsl:when>
            <xsl:when test="@year">
                <xsl:value-of select="concat(format-number(@year,'0000'),'-01-01')"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>