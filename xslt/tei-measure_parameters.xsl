<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs" version="2.0">
    
    <xsl:param name="p_measures">
        <!-- establish the type of measures encountered in @unit -->
        <tei:measureGrp type="volume">
            <tei:measure unit="shunbul"/>
            <tei:measure unit="madd"/>
            <tei:measure unit="kile"/>
            <tei:measure unit="cift"/>
            <tei:measure unit="ghirara"/>
            <tei:measure unit="tchinik"/>
            <tei:measure unit="tabba"/>
            <tei:measure unit="l"/>
        </tei:measureGrp>
        <tei:measureGrp type="weight">
            <tei:measure unit="t"/>
            <tei:measure unit="kg"/>
            <tei:measure unit="gr"/>
            <tei:measure unit="ratl"/>
            <tei:measure unit="okka"/>
            <tei:measure unit="dirham"/>
            <tei:measure unit="qintar"/>
            <tei:measure unit="wazna"/>
        </tei:measureGrp>
        <tei:measureGrp type="currency">
            <tei:measure unit="ops"/>
            <tei:measure unit="lt"/>
            <tei:measure unit="ltq"/>
            <tei:measure unit="mec"/>
            <tei:measure unit="gpb"/>
            <tei:measure unit="frc"/>
        </tei:measureGrp>
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
        <tei:measureGrp type="volume" location="Aleppo" when="1860-02-29" source="226DCF23-CF34-4000-B441-B886E11607E5">
            <tei:measure unit="shunbul" quantity="1"/>
            <tei:measure unit="kileOld" quantity="2.5">2.5 Istanbul kilesi</tei:measure>
        </tei:measureGrp>
        <!-- Damascus  -->
        <tei:measureGrp type="volume" location="Damascus" source="83D74086-8E7D-4D96-9638-03F2A5BEA10F" when="1893">
            <!-- shunbul = 72 madd -->
            <tei:measure unit="shunbul" quantity="0.013888889"/>
            <!-- ghirāra = 12 madd -->
            <tei:measure unit="ghirara" quantity="0.083333333">ghirāra</tei:measure>
            <tei:measure unit="madd" quantity="1"/>
            <tei:measure unit="kile" quantity="2"/>
            <tei:measure unit="cift" quantity="2"/>
        </tei:measureGrp>
        <!-- Gaza -->
        <tei:measureGrp type="volume" location="Gaza" source="83D74086-8E7D-4D96-9638-03F2A5BEA10F" when="1893">
            <!-- Gaza used the old Istanbul kilesi -->
            <tei:measure unit="kile" quantity="10"/>
            <tei:measure unit="tchinik" quantity="37"/>
        </tei:measureGrp>
        <!-- Haifa -->
        <tei:measureGrp type="volume" location="Haifa" source="83D74086-8E7D-4D96-9638-03F2A5BEA10F" when="1893">
            <!-- Haifa used the Istanbul kilesi -->
            <tei:measure unit="kile" quantity="1"/>
        </tei:measureGrp>
        <!-- Istanbul -->
        <tei:measureGrp type="volume" location="Istanbul" source="83D74086-8E7D-4D96-9638-03F2A5BEA10F" when="1893">
            <tei:measure unit="kileNew" quantity="1"/>
            <tei:measure unit="l" quantity="40"/>
        </tei:measureGrp>
        <tei:measureGrp type="volume" location="Istanbul" source="83D74086-8E7D-4D96-9638-03F2A5BEA10F" when="1893">
            <tei:measure unit="kileOld" quantity="1">Istanbul kilesi</tei:measure>
            <tei:measure unit="l" quantity="36.8"/>
        </tei:measureGrp>
        <!-- Jaffa -->
        <tei:measureGrp type="volume" location="Haifa" source="83D74086-8E7D-4D96-9638-03F2A5BEA10F" when="1893">
            <!-- Jaffa used the old Istanbul kilesi -->
            <tei:measure unit="kile" quantity="10"/>
            <tei:measure unit="tchinik" quantity="37"/>
        </tei:measureGrp>
        <!-- Jerusalem -->
        <tei:measureGrp type="volume" location="Jerusalem" source="83D74086-8E7D-4D96-9638-03F2A5BEA10F" when="1893">
            <!-- don't know conversions of tabba yet. There is a source from 1878 that stated the weight of a ṭabba of wheat as 7 to 7.5 raṭl -->
            <tei:measure unit="tabba" quantity="12"/>
            <tei:measure unit="kile" quantity="10"/>
        </tei:measureGrp>
        <!-- Nablus -->
        <tei:measureGrp type="volume" location="Nablus" source="83D74086-8E7D-4D96-9638-03F2A5BEA10F" when="1893">
            <tei:measure unit="tabba" quantity="12"/>
            <tei:measure unit="kile" quantity="10"/>
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
        <tei:measureGrp type="weight" location="Antiochia">
            <tei:measure unit="okka" quantity="250"/>
            <tei:measure unit="qintar" quantity="1"/>
        </tei:measureGrp>
        <!-- Damascus  -->
        <tei:measureGrp type="weight" location="Damascus" source="83D74086-8E7D-4D96-9638-03F2A5BEA10F" when="1893">
            <tei:measure unit="qintar" quantity="0.005"/>
            <!-- wazna = 12.5 ratl -->
            <tei:measure unit="wazna" quantity="6.25"/>
            <tei:measure unit="ratl" quantity="0.5"/>
            <tei:measure unit="okka" quantity="1"/>
            <tei:measure unit="dirham" quantity="400"/>
            <tei:measure unit="kg" quantity="1.282945"/>
        </tei:measureGrp>
        <!-- Gaza -->
        <tei:measureGrp type="weight" location="Gaza" source="83D74086-8E7D-4D96-9638-03F2A5BEA10F" when="1893">
            <tei:measure unit="ratl" quantity="1"/>
            <tei:measure unit="okka" quantity="2.25"/>
            <tei:measure unit="dirham" quantity="900"/>
            <tei:measure unit="kg" quantity="2.88662625"/>
        </tei:measureGrp>
        <!-- Haifa -->
        <tei:measureGrp type="weight" location="Haifa" source="83D74086-8E7D-4D96-9638-03F2A5BEA10F" when="1893">
            <tei:measure unit="qintar" quantity="0.0025"/>
            <tei:measure unit="ratl" quantity="0.5"/>
            <tei:measure unit="okka" quantity="1"/>
            <tei:measure unit="dirham" quantity="400"/>
        </tei:measureGrp>
        <!-- Homs -->
        <tei:measureGrp type="weight" location="Homs" source="CF40D65F-019A-421C-96F9-A0E5A413BAA5" when="1890">
            <tei:measure unit="ratl" quantity="1">One raṭl</tei:measure> 
            <tei:measure unit="okka" quantity="12">12 uqqiyya ḥomṣiyya</tei:measure>
            <tei:measure unit="kg" quantity="1">3 kg</tei:measure>
        </tei:measureGrp>
        <!-- Hama -->
        <tei:measureGrp type="weight" location="Hama" source="CF40D65F-019A-421C-96F9-A0E5A413BAA5" when="1890">
            <xsl:copy-of select="..//tei:measureGrp[@type='weight'][@location='Damascus']/tei:measure"/>
        </tei:measureGrp>
        <!-- Istanbul -->
        <tei:measureGrp type="weight" location="Istanbul">
            <tei:measure unit="okka" quantity="44"/>
            <tei:measure unit="qintar" quantity="1"/>
        </tei:measureGrp>
        <!-- Jaffa -->
        <tei:measureGrp type="weight" location="Jaffa" source="83D74086-8E7D-4D96-9638-03F2A5BEA10F" when="1893">
            <tei:measure unit="ratl" quantity="1"/>
            <tei:measure unit="okka" quantity="2.25"/>
            <tei:measure unit="dirham" quantity="900"/>
            <tei:measure unit="kg" quantity="2.88662625"/>
        </tei:measureGrp>
        <!-- Jerusalem -->
        <tei:measureGrp type="weight" location="Jerusalem" source="83D74086-8E7D-4D96-9638-03F2A5BEA10F" when="1893">
            <tei:measure unit="ratl" quantity="1"/>
            <tei:measure unit="okka" quantity="2.25"/>
            <tei:measure unit="dirham" quantity="900"/>
            <tei:measure unit="kg" quantity="2.88662625"/>
        </tei:measureGrp>
        <!-- Mosul -->
        <tei:measureGrp type="weight" location="Mosul" source="83D74086-8E7D-4D96-9638-03F2A5BEA10F" when="1893">
            <tei:measure unit="wazna" quantity="0.096153846"/>
            <tei:measure unit="qintar" quantity="0.025"/>
            <tei:measure unit="okka" quantity="1"/>
            <tei:measure unit="kg" quantity="1.282945"/>
        </tei:measureGrp>
        <!-- weight of coins -->
        <tei:measureGrp type="weight" source="83D74086-8E7D-4D96-9638-03F2A5BEA10F" when="1844">
            <tei:measure unit="lt" commodity="gold" quantity="1"/>
            <tei:measure unit="gr" quantity="7.216"/>
        </tei:measureGrp>
        <tei:measureGrp type="weight" source="83D74086-8E7D-4D96-9638-03F2A5BEA10F" when="1844">
            <tei:measure unit="ops" commodity="silver" quantity="1"/>
            <tei:measure unit="gr" quantity="1.202"/>
        </tei:measureGrp>
        <tei:measureGrp type="weight" source="83D74086-8E7D-4D96-9638-03F2A5BEA10F" when="1844">
            <tei:measure unit="mec" commodity="silver" quantity="1"/>
            <tei:measure unit="gr" quantity="24.055"/>
        </tei:measureGrp>
        
        
        <!-- currencies -->
        <!-- Ottoman Empire  -->
        <!-- even though the nominal value of £T1 remained Ps 100, the Ottoman empire established an official exchange rate of £T1= Ps 123 in May 1883 -->
        <!-- the Ottoman Empire devaluated the mecidiye for the purpose of tax payments from Ps 20 to 19 in 1880 -->
        <tei:measureGrp type="currency" subtype="Ottoman">
            <!-- I used both "lt" and "ltq" in the transcription of my sources -->
            <tei:measure unit="lt" quantity="1"/>
            <tei:measure unit="ltq" quantity="1"/>
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