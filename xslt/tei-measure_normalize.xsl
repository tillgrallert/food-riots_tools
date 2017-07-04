<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs" version="2.0">

    <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no" name="xml"/>
    <xsl:output method="text" indent="yes" encoding="UTF-8" omit-xml-declaration="yes" name="text"/>
    
    <!-- this stylesheet normalizes the attributes on tei:measure. Unfortunately <tei:measure> is not datable and cannot carry the when attribute. Therefore normalization cannot be based on changes over time -->

    <!-- identity transform -->
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
        <xsl:message>
            <xsl:text>@quantity: </xsl:text><xsl:value-of select="@quantity"/>
            <xsl:text>, factor: </xsl:text><xsl:value-of select="$p_regularization-factor"/>
        </xsl:message>
          <xsl:copy>
              <xsl:attribute name="type" select="'regularized'"/>
              <xsl:apply-templates select="@commodity | @unit" mode="m_normalize-quantity"/>
              <xsl:attribute name="quantity" select="@quantity * $p_regularization-factor"/>
              <xsl:apply-templates mode="m_normalize-quantity"/>
          </xsl:copy>
    </xsl:template>

    <!-- normalize and harmonize the commodities and units of <tei:measure> -->
    <xsl:template match="tei:measure" mode="m_normalize-unit">
        <xsl:copy>
            <!-- some commodity values vould be normalized -->
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
                <!-- normalize Ottoman weights to ratl -->
                <!-- 1 ratl = 2 okka -->
                <xsl:when test="@unit = 'okka'">
                    <xsl:attribute name="type" select="'normalized'"/>
                    <xsl:attribute name="unit" select="'ratl'"/>
                    <xsl:attribute name="quantity" select="@quantity * 0.5"/>
                </xsl:when>
                <!-- 1 ratl = 800 dirham -->
                <xsl:when test="@unit = 'dirham'">
                    <xsl:attribute name="type" select="'normalized'"/>
                    <xsl:attribute name="unit" select="'ratl'"/>
                    <xsl:attribute name="quantity" select="@quantity div 800"/>
                </xsl:when>
                <!-- 100 ratl = 1 qintar -->
                <xsl:when test="@unit = 'qintar'">
                    <xsl:attribute name="type" select="'normalized'"/>
                    <xsl:attribute name="unit" select="'ratl'"/>
                    <xsl:attribute name="quantity" select="@quantity * 100"/>
                </xsl:when>
                <!-- normalize metrical weights to kg -->
                <!-- 1 t = 1000 kg -->
                <xsl:when test="@unit = 't'">
                    <xsl:attribute name="type" select="'normalized'"/>
                    <xsl:attribute name="unit" select="'kg'"/>
                    <xsl:attribute name="quantity" select="@quantity * 1000"/>
                </xsl:when>
                <!-- normalise currencies -->
                <!-- 100 Ps = 1 Lt -->
                <!-- even though the nominal value of £T1 remained Ps 100,the Ottoman empire established an official exchange rate of £T1= Ps 123 in May 1883 -->
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
