<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="xs xsi html" version="2.0">
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:include href="tei-measure_parameters.xsl"/>
    
    <xsl:param name="p_debug" select="true()"/>
    
    <xsl:template match="/">
        <tei:div>
            <xsl:apply-templates select="descendant::tei:measure"/>
        </tei:div>
    </xsl:template>
    <xsl:template match="tei:measure">
        <xsl:copy>
            <!-- reproduce existing attributes -->
            <xsl:copy-of select="@*"/>
            <!-- some commodity values should be normalized -->
            <xsl:variable name="v_commodity">
                <xsl:choose>
                    <xsl:when test="(@commodity='ervil') or (@commodity='kirsanna')">
                        <xsl:text>vetch</xsl:text>
                    </xsl:when>
                    <xsl:when test="@commodity='ful'">
                        <xsl:text>broad-beans</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@commodity"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="v_source-unit" select="@unit"/>
            <xsl:variable name="v_location" select="@location"/>
            <!-- check for the type of a measure, i.e. volume, weight, currency -->
            <xsl:variable name="v_type" select="$p_measures/descendant-or-self::tei:measureGrp[tei:measure/@unit=$v_source-unit][1]/@type"/>
            <xsl:variable name="v_target-unit">
                <xsl:choose>
                    <xsl:when test="$v_type = 'volume'">
                        <xsl:text>kile</xsl:text>
                    </xsl:when>
                    <xsl:when test="$v_type = 'weight'">
                        <xsl:text>kg</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@unit"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <!-- add attributes -->
            <xsl:attribute name="commodity" select="$v_commodity"/>
            <xsl:attribute name="unit" select="$v_target-unit"/>
            <!-- normalise quantity for @unit: one has to find the normalization factor for  $v_unit and the chosen $v_target-unit -->
            <!-- one has to find the first tei:measureGrp wich a  tei:measure child whose @unit is $v_target-unit and whose @quantity is 1 -->
            <xsl:attribute name="quantity">
                <!-- find a measureGrp that has children of both $v_unit and $v_normalization-target -->
                <xsl:choose>
                <xsl:when test="$p_measures/descendant-or-self::tei:measureGrp[tei:measure[@unit=$v_target-unit]][tei:measure[@unit=$v_source-unit]]">
                    <xsl:variable name="v_m" select="$p_measures/descendant-or-self::tei:measureGrp[tei:measure[@unit=$v_target-unit]][tei:measure[@unit=$v_source-unit]][1]"/>
                    <xsl:variable name="v_target-unit-quantity" select="$v_m/tei:measure[@unit=$v_target-unit]/@quantity"/>
                    <xsl:variable name="v_source-unit-quantity" select="$v_m/tei:measure[@unit=$v_source-unit]/@quantity"/>
                    <!-- use Dreisatz -->
                    <xsl:value-of select="@quantity * $v_source-unit-quantity div $v_target-unit-quantity"/>
                   <xsl:if test="$p_debug=true()">
                       <xsl:message>
                           <xsl:value-of select="concat(@quantity,'(',$v_source-unit,')')"/>
                           <xsl:text> * </xsl:text>
                           <xsl:value-of select="$v_source-unit-quantity"/>
                           <xsl:text> / </xsl:text>
                           <xsl:value-of select="concat($v_target-unit-quantity,'(',$v_target-unit,')')"/>
                       </xsl:message>
                   </xsl:if>
                </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@quantity"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>