<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:till="http://www.sitzextase.de" xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    
    <!-- this stylesheet takes a Sente reference as input and returns a clickable link-->
    <xsl:include href="functions/BachFunctions v3.xsl"/>
    <xsl:template match="tss:reference">
        <xsl:call-template name="funcCitationLink">
            <xsl:with-param name="pRef" select="."/>
                    <!--<xsl:with-param name="pOutputFormat" select="'html'"/>-->
        </xsl:call-template