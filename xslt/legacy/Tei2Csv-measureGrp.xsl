<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:till="http://www.sitzextase.de" xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:param name="pCommodity" select="'wheat'"/>
    <xsl:param name="pUnit" select="'kile'"/>
    <xsl:template match="tei:measureGrp">
        <!-- there is usually just one entry for non-curreny commodities -->
        <!-- as I feed the output directly into a graph, the commodity should be omitted -->
        <xsl:for-each select="./descendant::tei:measure[@commodity = $pCommodity]">
            <xsl:value-of select="@quantity"/>
            <xsl:text>;</xsl:text>
            <xsl:value-of select="@unit"/>
            <xsl:text>;</xsl:text>
        </xsl:for-each>
        <!-- followed by the price or a price range -->
        <xsl:for-each select="./descendant::tei:measure[@commodity = 'currency'][@unit = 'ops']">
            <xsl:sort select="@quantity" order="ascending"/>
            <xsl:value-of select="@quantity"/>
            <xsl:text>;</xsl:text>
            <xsl:value-of select="@unit"/>
            <xsl:text>;</xsl:text>
        </xsl:for-each>
        <xsl:text>
</xsl:text>
    </xsl:template>
</xsl:stylesheet>