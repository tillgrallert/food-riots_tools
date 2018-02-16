<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs" version="2.0">
    
    <xsl:param name="p_measures">
        <!-- volumes -->
        <!-- fallback -->
        <tei:measureGrp type="volume">
            <tei:measure unit="madd" quantity="0.5"/>
            <tei:measure unit="kile" quantity="1"/>
            <tei:measure unit="cift" quantity="1"/>
        </tei:measureGrp>
        <!-- Aleppo -->
        <tei:measureGrp type="volume" location="Aleppo">
            <tei:measure unit="shunbul" quantity="1"/>
            <tei:measure unit="madd" quantity="6"/>
            <tei:measure unit="kile" quantity="3"/>
        </tei:measureGrp>
        <!-- Tripoli -->
        <tei:measureGrp type="volume" location="Tripoli">
            <tei:measure unit="shunbul" quantity="1"/>
            <tei:measure unit="kile" quantity="2.25"/>
        </tei:measureGrp>
        <!-- Acre -->
        <tei:measureGrp type="volume" location="Acre">
            <tei:measure unit="shunbul" quantity="1"/>
            <tei:measure unit="kile" quantity="2.25"/>
        </tei:measureGrp>

        <!-- weights -->
        <!-- metrical weights -->
        <tei:measureGrp type="weight">
            <tei:measure unit="kg" quantity="1"/>
            <tei:measure unit="gr" quantity="1000"/>
            <tei:measure unit="t" quantity="0.001"/>
        </tei:measureGrp>
        <!-- okka-based weights -->
        <tei:measureGrp type="weight">
            <tei:measure unit="ratl" quantity="0.5"/>
            <tei:measure unit="okka" quantity="1"/>
            <tei:measure unit="dirham" quantity="400"/>
            <tei:measure unit="kg" quantity="1.282945"/>
        </tei:measureGrp>
        <!-- 1 qintār = 44 okka in Istanbul
                      1 qintār = 200 okka in Damascus
                      1 qintār = 250 okka in Antiochia / 
                      1 qinṭār = 40 okka in Mosul 
                      1 qinṭar = 400 okka in Haifa -->
        <tei:measureGrp type="weight" location="Istanbul">
            <tei:measure unit="okka" quantity="44"/>
            <tei:measure unit="qintar" quantity="1"/>
        </tei:measureGrp>
        <tei:measureGrp type="weight" location="Damascus">
            <tei:measure unit="okka" quantity="200"/>
            <tei:measure unit="qintar" quantity="1"/>
        </tei:measureGrp>
        <tei:measureGrp type="weight" location="Antiochia">
            <tei:measure unit="okka" quantity="250"/>
            <tei:measure unit="qintar" quantity="1"/>
        </tei:measureGrp>
        <tei:measureGrp type="weight" location="Mosul">
            <tei:measure unit="okka" quantity="40"/>
            <tei:measure unit="qintar" quantity="1"/>
        </tei:measureGrp>
        <tei:measureGrp type="weight" location="Haifa">
            <tei:measure unit="okka" quantity="400"/>
            <tei:measure unit="qintar" quantity="1"/>
        </tei:measureGrp>
    </xsl:param>
    
    <xsl:param name="p_measure-volumes">
        <!-- fallback -->
        <tei:measureGrp>
            <tei:measure unit="madd" quantity="0.5"/>
            <tei:measure unit="kile" quantity="1"/>
            <tei:measure unit="cift" quantity="1"/>
        </tei:measureGrp>
        <!-- Aleppo -->
        <tei:measureGrp location="Aleppo">
            <tei:measure unit="shunbul" quantity="1"/>
            <tei:measure unit="madd" quantity="6"/>
            <tei:measure unit="kile" quantity="3"/>
        </tei:measureGrp>
        <!-- Tripoli -->
        <tei:measureGrp location="Tripoli">
            <tei:measure unit="shunbul" quantity="1"/>
            <tei:measure unit="kile" quantity="2.25"/>
        </tei:measureGrp>
        <!-- Acre -->
        <tei:measureGrp location="Acre">
            <tei:measure unit="shunbul" quantity="1"/>
            <tei:measure unit="kile" quantity="2.25"/>
        </tei:measureGrp>
    </xsl:param>
    
    <xsl:param name="p_measures-weights">
        <!-- metrical weights -->
        <tei:measureGrp>
            <tei:measure unit="kg" quantity="1"/>
            <tei:measure unit="gr" quantity="1000"/>
            <tei:measure unit="t" quantity="0.001"/>
        </tei:measureGrp>
        <!-- okka-based weights -->
        <tei:measureGrp>
            <tei:measure unit="ratl" quantity="0.5"/>
            <tei:measure unit="okka" quantity="1"/>
            <tei:measure unit="dirham" quantity="400"/>
            <tei:measure unit="kg" quantity="1.282945"/>
        </tei:measureGrp>
        <!-- 1 qintār = 44 okka in Istanbul
                      1 qintār = 200 okka in Damascus
                      1 qintār = 250 okka in Antiochia / 
                      1 qinṭār = 40 okka in Mosul 
                      1 qinṭar = 400 okka in Haifa -->
        <tei:measureGrp location="Istanbul">
            <tei:measure unit="okka" quantity="44"/>
            <tei:measure unit="qintar" quantity="1"/>
        </tei:measureGrp>
        <tei:measureGrp location="Damascus">
            <tei:measure unit="okka" quantity="200"/>
            <tei:measure unit="qintar" quantity="1"/>
        </tei:measureGrp>
        <tei:measureGrp location="Antiochia">
            <tei:measure unit="okka" quantity="250"/>
            <tei:measure unit="qintar" quantity="1"/>
        </tei:measureGrp>
        <tei:measureGrp location="Mosul">
            <tei:measure unit="okka" quantity="40"/>
            <tei:measure unit="qintar" quantity="1"/>
        </tei:measureGrp>
        <tei:measureGrp location="Haifa">
            <tei:measure unit="okka" quantity="400"/>
            <tei:measure unit="qintar" quantity="1"/>
        </tei:measureGrp>
    </xsl:param>
    
    <!-- $v_weight-okka expresses the weight of an okka in kg -->
    <xsl:variable name="v_weight-okka" select="$p_measures-weights/descendant-or-self::tei:measureGrp/tei:measure[@unit='kg'][parent::node()/tei:measure[@unit='okka'][@quantity='1']]/@quantity"/>
    
</xsl:stylesheet>