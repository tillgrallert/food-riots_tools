<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:till="http://www.sitzextase.de" xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    
    <!-- this stylesheet takes a Sente reference as input and returns a clickable link as heading with the content of the abstractText as content of a p  -->
    <xsl:include href="functions/BachFunctions v3.xsl"/>
    <xsl:template match="tei:measureGrp">
        <xsl:variable name="vRef" select="./ancestor::tss:reference"/>
        <xsl:variable name="vPrice" select="./descendant::tei:measure[@commodity='currency']"/>
        <xsl:for-each select="./descendant::tei:measure">
            <xsl:sort select="@commodity"/>
            <td>
                <xsl:value-of select="@commodity"/>
            </td>
            <td>
                <xsl:value-of select="@quantity"/>
            </td>
            <td>
                <xsl:value-of select="@unit"/>
            </td>
        </xsl:for-each