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
    
    <xsl:include href="tei-measure_parameters.xsl"/>

    <xsl:param name="p_test" select="true()"/>

    <xsl:variable name="v_data-source">
        <xsl:choose>
            <!-- run on small sample of test data -->
            <xsl:when test="$p_test = true()">
                <xsl:copy-of
                    select="collection('/Volumes/Dessau HD/BachCloud/BTSync/FormerDropbox/FoodRiots/food-riots_tools/examples/tss?select=*.TSS.xml')[not(descendant::tss:publicationType[@name = 'Archival File' or @name = 'Archival Material'])]"
                />
            </xsl:when>
            <!-- run on full sample: the source collection does contain double entries of information (one reference for an archival file and one for each consituent letters). The summary files must be excluded to not significantly distort the sample -->
            <xsl:otherwise>
                <xsl:copy-of
                    select="collection('/Volumes/Dessau HD/BachUni/BachBibliothek/GitHub/Sente/tss_data/BachSources?select=*.TSS.xml')[not(descendant::tss:publicationType[@name = 'Archival File' or @name = 'Archival Material'])]"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!--  variables for csv output -->
    <xsl:param name="p_separator" select="','"/>
    <xsl:param name="p_separator-escape" select="';'"/>
    <xsl:param name="p_quote-escape" select="'&quot;&quot;'"/>
    <xsl:param name="p_new-line" select="'&#x0A;'"/>
    
    <xsl:variable name="v_refs-qualiative-price-data">
        <xsl:apply-templates select="$v_data-source/descendant::tss:keyword" mode="m_tss-to-csv"/>
    </xsl:variable>
    
    <xsl:template match="tss:keyword[string() = ('prices: high', 'prices: rising', 'prices: stable', 'prices: falling', 'prices: low', 'prices: normal') ]" mode="m_tss-to-csv">
        <!-- publication date -->
        <xsl:apply-templates select="ancestor::tss:reference" mode="m_establish-date"/><xsl:value-of select="$p_separator"/>
        <!-- publication place -->
        <xsl:call-template name="t_normalize-toponyms">
            <xsl:with-param name="p_toponym" select="ancestor::tss:reference/tss:characteristics/tss:characteristic[@name='publicationCountry']"/>
        </xsl:call-template>
        <xsl:value-of select="$p_separator"/>
        <!-- source identifier -->
        <xsl:value-of select="ancestor::tss:reference/tss:characteristics/tss:characteristic[@name='UUID']"/><xsl:value-of select="$p_separator"/>
        <!-- tag value -->
        <xsl:value-of select="."/><xsl:value-of select="$p_new-line"/>
    </xsl:template>
    
    <xsl:template match="tss:keyword" mode="m_tss-to-csv"/>
    <xsl:template match="tss:reference" mode="m_establish-date">
            <xsl:choose>
                <!-- If an original publication date is available, this should be used here  -->
                <!-- NOTE: in the case of published diaries / journals this rule breaks the extraction of correct dates -->
                <xsl:when test="tss:dates/tss:date[@type='Original']/@day!=''">
                    <xsl:value-of select="tss:dates/tss:date[@type='Original']/@year"/>
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="format-number(tss:dates/tss:date[@type='Original']/@month,'00')"/>
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="format-number(tss:dates/tss:date[@type='Original']/@day,'00')"/>
                </xsl:when>
                <!-- otherwise use only publication year -->
                <xsl:when test="tss:dates/tss:date[@type='Original']/@year!=''">
                    <xsl:value-of select="tss:dates/tss:date[@type='Original']/@year"/>
                </xsl:when>
                <!-- check if full publication date is available -->
                <xsl:when test="tss:dates/tss:date[@type='Publication']/@day!=''">
                    <xsl:value-of select="tss:dates/tss:date[@type='Publication']/@year"/>
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="format-number(tss:dates/tss:date[@type='Publication']/@month,'00')"/>
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="format-number(tss:dates/tss:date[@type='Publication']/@day,'00')"/>
                </xsl:when>
                <!-- otherwise use only publication year -->
                <xsl:when test="tss:dates/tss:date[@type='Publication']/@year!=''">
                    <xsl:value-of select="tss:dates/tss:date[@type='Publication']/@year"/>
                </xsl:when>
            </xsl:choose>
    </xsl:template>
    

    <xsl:variable name="v_csv-head">
        <xsl:text>schema:date,schema:Place,source,tag</xsl:text><xsl:value-of select="$p_new-line"/>
    </xsl:variable>    

    <xsl:template match="/">
                <xsl:result-document href="_output/qualitative-prices-{
                    format-date(current-date(),'[Y0001]-[M01]-[D01]')}.csv" format="text">
                    <xsl:value-of select="$v_csv-head"/>
                    <xsl:copy-of select="$v_refs-qualiative-price-data"/>
                </xsl:result-document>
    </xsl:template>
    
    <!-- this template checks a TEI gazetteer for authoritative names of locations based on the input of toponym and target language -->
    <xsl:template name="t_normalize-toponyms">
        <xsl:param name="p_toponym"/>
        <xsl:param name="p_lang" select="$p_lang-target"/>
        <!-- where is the gazetteer? -->
        <xsl:param name="p_gazetteer" select="$p_file-gazetteer"/>
        <xsl:variable name="v_place" select="$p_gazetteer/descendant::tei:place[tei:placeName/string()=$p_toponym][1]"/>
        <xsl:choose>
            <xsl:when test="$v_place/tei:placeName[@xml:lang=$p_lang]">
                <xsl:value-of select="$v_place/tei:placeName[@xml:lang=$p_lang][1]/string()"/>
            </xsl:when>
            <!-- fallback option 1: use regularised toponym from the Gazetteer -->
            <xsl:when test="$v_place/tei:placeName">
                <xsl:value-of select="$v_place/tei:placeName[not(@xml:lang='ar')][1]/string()"/>
            </xsl:when>
            <!-- fallback option 2: return input -->
            <xsl:otherwise>
                <xsl:value-of select="$p_toponym"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
