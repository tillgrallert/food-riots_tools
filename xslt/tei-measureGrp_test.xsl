<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="xs xsi html" version="2.0">
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:include href="tei-measure_normalize.xsl"/>
    
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
       <xsl:copy-of select="$v_data-source-regularized"/>
   </xsl:template>
</xsl:stylesheet>