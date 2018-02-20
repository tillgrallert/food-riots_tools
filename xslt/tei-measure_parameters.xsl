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
        <!-- Acre -->
        <tei:measureGrp type="volume" location="Acre">
            <tei:measure unit="shunbul" quantity="1"/>
            <tei:measure unit="kile" quantity="2.25"/>
        </tei:measureGrp>
        <!-- Aleppo -->
        <tei:measureGrp type="volume" location="Aleppo">
            <tei:measure unit="shunbul" quantity="1"/>
            <tei:measure unit="madd" quantity="6"/>
            <tei:measure unit="kile" quantity="3"/>
        </tei:measureGrp>
        <!-- Damascus  -->
        <tei:measureGrp type="volume" location="Damascus">
            <!-- shunbul = 72 madd -->
            <tei:measure unit="shunbul" quantity="0.013888889"/>
            <!-- ghirāra = 12 madd -->
            <tei:measure unit="ghirara" quantity="0.083333333"/>
            <tei:measure unit="madd" quantity="1"/>
            <tei:measure unit="kile" quantity="2"/>
            <tei:measure unit="cift" quantity="2"/>
        </tei:measureGrp>
        <!-- Haifa -->
        <tei:measureGrp type="volume" location="Haifa">
            <!-- Haifa used the Istanbul kilesi -->
            <tei:measure unit="kile" quantity="1"/>
        </tei:measureGrp>
        <!-- Jerusalem -->
        <tei:measureGrp type="volume" location="Jerusalem">
            <!-- don't know conversions of tabba yet. There is a source from 1878 that stated the weight of a ṭabba of wheat as 7 to 7.5 raṭl -->
            <tei:measure unit="tabba" quantity="1"/>
        </tei:measureGrp>
        <!-- Tripoli -->
        <tei:measureGrp type="volume" location="Tripoli">
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
            <tei:measure unit="qintar" quantity="0.005"/>
            <!-- wazna = 12.5 ratl -->
            <tei:measure unit="wazna" quantity="6.25"/>
            <tei:measure unit="ratl" quantity="0.5"/>
            <tei:measure unit="okka" quantity="1"/>
            <tei:measure unit="dirham" quantity="400"/>
            <tei:measure unit="kg" quantity="1.282945"/>
        </tei:measureGrp>
        <tei:measureGrp type="weight" location="Antiochia">
            <tei:measure unit="okka" quantity="250"/>
            <tei:measure unit="qintar" quantity="1"/>
        </tei:measureGrp>
        <tei:measureGrp type="weight" location="Mosul">
            <tei:measure unit="wazna" quantity="0.096153846"/>
            <tei:measure unit="qintar" quantity="0.025"/>
            <tei:measure unit="okka" quantity="1"/>
            <tei:measure unit="kg" quantity="1.282945"/>
        </tei:measureGrp>
        <tei:measureGrp type="weight" location="Haifa">
            <tei:measure unit="okka" quantity="400"/>
            <tei:measure unit="qintar" quantity="1"/>
        </tei:measureGrp>
        
        <!-- currencies -->
        <!-- Ottoman Empire  -->
        <!-- even though the nominal value of £T1 remained Ps 100, the Ottoman empire established an official exchange rate of £T1= Ps 123 in May 1883 -->
        <!-- the Ottoman Empire devaluated the mecidiye for the purpose of tax payments from Ps 20 to 19 in 1880 -->
        <tei:measureGrp type="currency" subtype="Ottoman">
            <tei:measure unit="lt" quantity="1"/>
            <tei:measure unit="ops" quantity="100"/>
            <tei:measure unit="mec" quantity="5"/>
        </tei:measureGrp>
        
        <!-- time -->
        <tei:measureGrp type="time">
            <tei:measure unit="year" quantity="1"/>
            <!-- the month is computed as 1/12 of a year of 365 days -->
            <tei:measure unit="month" quantity="30.416666667"/>
            <tei:measure unit="day" quantity="365"/>
            <tei:measure unit="hour" quantity="8760"/>
            <tei:measure unit="min" quantity="525600"/>
        </tei:measureGrp>
    </xsl:param>
    
</xsl:stylesheet>