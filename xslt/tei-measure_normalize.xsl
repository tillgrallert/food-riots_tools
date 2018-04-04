<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs" version="2.0">

    <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no" name="xml"/>
    
    <!-- this stylesheet normalizes the attributes on tei:measure. Unfortunately <tei:measure> is not datable and cannot carry the when attribute. Therefore normalization cannot be based on changes over time -->
    <!-- The normalizations are based on a number of primary sources, most notably among them: Chambre de Commerce Française de Constantinople. *Poids, Mesures, Monnaies et Cours du Change Dans les Principales Localités de L'Empire Ottoman à la Fin du 19e Siècle.* Istanbul: Isis, 2002 [1893]; Handelsarchiv 15 Nov. 1878 (#1878, Teil 2):II 489-96; NACP RG 84 Damascus Vol.8 Damascus 85, *Weights and Measures*, Mishāqa to Bissinger 22 Nov. 1889. -->
    
    <xsl:include href="tei-measure_parameters.xsl"/>
    
    <xsl:param name="p_debug" select="true()"/>
    <xsl:param name="p_normalize-by-location" select="false()"/>

    <!-- identity transform -->
    <xsl:template match="node() | @*" mode="m_enrich-dates">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="m_enrich-dates"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="node() | @*" mode="m_enrich-locations">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="m_enrich-locations"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="node() | @*" mode="m_enrich">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="m_enrich"/>
        </xsl:copy>
    </xsl:template>
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
    
    <!-- add temporal information -->
    <!-- undated measureGrp -->
    <xsl:template match="tei:measureGrp[not(@when)]" mode="m_enrich-dates">
        <xsl:variable name="v_date-publication">
            <xsl:choose>
                <!-- If an original publication date is available, this should be used here  -->
                <!-- NOTE: in the case of published diaries / journals this rule breaks the extraction of correct dates -->
                <xsl:when test="ancestor::tss:reference/tss:dates/tss:date[@type='Original']/@day!=''">
                    <xsl:value-of select="ancestor::tss:reference/tss:dates/tss:date[@type='Original']/@year"/>
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="format-number(ancestor::tss:reference/tss:dates/tss:date[@type='Original']/@month,'00')"/>
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="format-number(ancestor::tss:reference/tss:dates/tss:date[@type='Original']/@day,'00')"/>
                </xsl:when>
                <!-- otherwise use only publication year -->
                <xsl:when test="ancestor::tss:reference/tss:dates/tss:date[@type='Original']/@year!=''">
                    <xsl:value-of select="ancestor::tss:reference/tss:dates/tss:date[@type='Original']/@year"/>
                </xsl:when>
                <!-- check if full publication date is available -->
                <xsl:when test="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@day!=''">
                    <xsl:value-of select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@year"/>
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="format-number(ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@month,'00')"/>
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="format-number(ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@day,'00')"/>
                </xsl:when>
                <!-- otherwise use only publication year -->
                <xsl:when test="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@year!=''">
                    <xsl:value-of select="ancestor::tss:reference/tss:dates/tss:date[@type='Publication']/@year"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="v_id-source" select="ancestor::tss:reference/tss:characteristics/tss:characteristic[@name='UUID']"/>
        <!-- it can be that more than one of the <tei:measure> children are dated. In this case the measureGrp should be split -->
        <xsl:choose>
            <!-- test if the measure describing the money commodity is dated -->
            <xsl:when test="count(descendant::tei:measure[@commodity='currency'][@when]) &gt; 1">
                <xsl:for-each select="descendant::tei:measure[@commodity='currency'][@when]">
                    <tei:measureGrp type="split" source="{$v_id-source}" when="{@when}">
                        <xsl:copy-of select="ancestor::tei:measureGrp/descendant::tei:measure[not(@commodity='currency')]"/>
                        <xsl:apply-templates select="." mode="m_enrich-dates"/>
                    </tei:measureGrp>
                </xsl:for-each>
            </xsl:when>
            <!-- otherwise the measureGrp shall be dated with the publication date  -->
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*" mode="m_enrich-dates"/>
                    <xsl:attribute name="when" select="$v_date-publication"/>
                    <xsl:attribute name="source" select="$v_id-source"/>
                    <xsl:apply-templates select="node()" mode="m_enrich-dates"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- add location information -->
    <xsl:template match="tei:measureGrp[not(@location)]" mode="m_enrich-locations">
        <!-- it can be that more than one of the <tei:measure> children carry location data. In this case the measureGrp should be split. Note that @location on measure is only provided in exactly these cases -->
        <xsl:choose>
            <!-- test if the measure describing the money commodity is dated -->
            <xsl:when test="count(descendant::tei:measure[@commodity='currency'][@location]) &gt; 1">
                <xsl:for-each select="descendant::tei:measure[@commodity='currency'][@location]">
                    <tei:measureGrp type="split">
                        <xsl:apply-templates select="@*" mode="m_enrich-locations"/>
                        <xsl:attribute name="location" select="@location"/>
                        <xsl:copy-of select="ancestor::tei:measureGrp/descendant::tei:measure[not(@commodity='currency')]"/>
                        <xsl:apply-templates select="." mode="m_enrich-locations"/>
                    </tei:measureGrp>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
        <xsl:variable name="v_location">
            <xsl:choose>
                <!-- when there is only one located measure child, its @location value should also be applied to the parent -->
                <xsl:when test="count(descendant::tei:measure[@commodity='currency'][@location]) = 1">
                    <xsl:value-of select="descendant::tei:measure[@commodity='currency'][@location]"/>
                </xsl:when>
                <!-- probably a parent measureGrp has location information -->
                <xsl:when test="ancestor::tei:measureGrp[@location]">
                    <xsl:value-of select="ancestor::tei:measureGrp/@location"/>
                </xsl:when>
                <!-- otherwise pick the publication place of the source -->
                <xsl:when test="ancestor::tss:reference/tss:characteristics/tss:characteristic[@name='publicationCountry']">
                    <xsl:value-of select="normalize-space(ancestor::tss:reference/tss:characteristics/tss:characteristic[@name='publicationCountry'])"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="m_enrich-locations"/>
            <xsl:attribute name="location" select="$v_location"/>
            <xsl:apply-templates select="node()" mode="m_enrich-locations"/>
        </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- add source information -->
    <xsl:template match="tei:measureGrp[not(@source)]" mode="m_enrich">
        <xsl:variable name="v_id-source" select="ancestor::tss:reference/tss:characteristics/tss:characteristic[@name='UUID']"/>
        <xsl:copy>
            <xsl:attribute name="source" select="$v_id-source"/>
            <xsl:apply-templates select="@* | node()" mode="m_enrich"/>
        </xsl:copy>
    </xsl:template>
    <!-- add date and location information based on the nearest ancestor measureGrp -->
    <xsl:template match="tei:measure" mode="m_enrich">
        <xsl:variable name="v_unit" select="@unit"/>
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="not(@when) and not(@location)">
                    <xsl:attribute name="when" select="ancestor::tei:measureGrp[1]/@when"/>
                    <xsl:attribute name="location" select="ancestor::tei:measureGrp[1]/@location"/>
                </xsl:when>
                <xsl:when test="not(@when)">
                    <xsl:attribute name="when" select="ancestor::tei:measureGrp[1]/@when"/>
                </xsl:when>
                <xsl:when test="not(@location)">
                    <xsl:attribute name="location" select="ancestor::tei:measureGrp[1]/@location"/>
                </xsl:when>
            </xsl:choose>
            <!-- add a type attribute -->
            <!-- check for the type of a measure, i.e. volume, weight, currency -->
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when test="$p_measures/descendant-or-self::tei:measureGrp[tei:measure/@unit=$v_unit][1]/@type">
                        <xsl:value-of select="$p_measures/descendant-or-self::tei:measureGrp[tei:measure/@unit=$v_unit][1]/@type"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>NA</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="@* | node()" mode="m_enrich"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- normalize and harmonize the commodities and units of <tei:measure> -->
    <xsl:template match="tei:measure[@quantity!='']" mode="m_normalize-unit">
        <xsl:if test="$p_debug = true()">
            <xsl:message>
                <xsl:value-of select="parent::tei:measureGrp/@source"/>
                <xsl:text>: m_normalize-unit</xsl:text>
            </xsl:message>
        </xsl:if>
        <xsl:copy>
            <!-- reproduce existing attributes -->
            <xsl:apply-templates select="@*" mode="m_normalize-unit"/>
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
            <xsl:variable name="v_location" select="@location"/>
            <!-- some unit values must be normalized due to variations in the mark-up of sources -->
            <xsl:variable name="v_source-unit">
                <xsl:choose>
                    <xsl:when test="@unit = 'wazana'">
                        <xsl:text>wazna</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@unit"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="v_type" select="@type"/>
            <xsl:if test="$p_debug = true()">
                <xsl:message>
                    <xsl:text>@type="</xsl:text><xsl:value-of select="$v_type"/><xsl:text>" @location="</xsl:text><xsl:value-of select="$v_location"/><xsl:text>"</xsl:text>
                </xsl:message>
            </xsl:if>
            <!-- set target unit based on the type of a measure, i.e. volume, weight, currency. `@type` is generate by mode m_enrich -->
            <xsl:variable name="v_target-unit">
                <xsl:choose>
                    <xsl:when test="@type = 'volume'">
                        <xsl:text>kile</xsl:text>
                    </xsl:when>
                    <xsl:when test="@type = 'weight'">
                        <xsl:text>kg</xsl:text>
                    </xsl:when>
                    <xsl:when test="@type = 'currency'">
                        <xsl:text>ops</xsl:text>
                    </xsl:when>
                    <xsl:when test="@type = 'time'">
                        <xsl:text>day</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@unit"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <!-- add attributes -->
            <xsl:attribute name="commodity" select="$v_commodity"/>
            <xsl:attribute name="unit" select="$v_target-unit"/>
            <xsl:if test="$v_source-unit!=$v_target-unit">
                <xsl:attribute name="change" select="'#normalized'"/>
                <xsl:attribute name="unitOrig" select="$v_source-unit"/>
                <xsl:attribute name="quantityOrig" select="@quantity"/>
            </xsl:if>
            <!-- normalise quantity for @unit: one has to find the normalization factor for  $v_unit and the chosen $v_target-unit -->
            <!-- one has to find the first tei:measureGrp wich a  tei:measure child whose @unit is $v_target-unit and whose @quantity is 1 -->
            <xsl:attribute name="quantity">
                <!-- find a measureGrp that has children of both $v_unit and $v_normalization-target -->
                <xsl:choose>
                    <xsl:when test="$p_measures/descendant-or-self::tei:measureGrp[@type=$v_type][tei:measure[@unit=$v_target-unit][@quantity]][tei:measure[@unit=$v_source-unit][@quantity]]">
<!--                        <xsl:variable name="v_measureGrp" select="$p_measures/descendant-or-self::tei:measureGrp[tei:measure[@unit=$v_target-unit]][tei:measure[@unit=$v_source-unit]][1]"/>-->
                        <xsl:variable name="v_measureGrp">
                            <xsl:choose>
                                <xsl:when test="$p_normalize-by-location = true() and $v_location!=''">
                                    <!-- check if we have normalization values for a given locality, otherwise provide a fallback option -->
                                    <xsl:choose>
                                        <xsl:when test="$p_measures/descendant-or-self::tei:measureGrp[@type=$v_type][@location=$v_location][tei:measure[@unit=$v_target-unit][@quantity]][tei:measure[@unit=$v_source-unit][@quantity]]">
                                            <xsl:if test="$p_debug=true()">
                                                <xsl:message>
                                                    <xsl:text>localized data is available for </xsl:text><xsl:value-of select="$v_location"/>
                                                </xsl:message>
                                            </xsl:if>
                                            <xsl:copy-of select="$p_measures/descendant-or-self::tei:measureGrp[@type=$v_type][@location=$v_location][tei:measure[@unit=$v_target-unit][@quantity]][tei:measure[@unit=$v_source-unit][@quantity]][1]"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:if test="$p_debug=true()">
                                                <xsl:message>
                                                    <xsl:text>localized data is not available for </xsl:text><xsl:value-of select="$v_location"/>
                                                </xsl:message>
                                            </xsl:if>
                                            <xsl:copy-of select="$p_measures/descendant-or-self::tei:measureGrp[@type=$v_type][tei:measure[@unit=$v_target-unit][@quantity]][tei:measure[@unit=$v_source-unit][@quantity]][1]"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:copy-of select="$p_measures/descendant-or-self::tei:measureGrp[@type=$v_type][tei:measure[@unit=$v_target-unit][@quantity]][tei:measure[@unit=$v_source-unit][@quantity]][1]"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="v_target-unit-quantity" select="$v_measureGrp/descendant::tei:measure[@unit=$v_target-unit]/@quantity"/>
                        <xsl:variable name="v_source-unit-quantity" select="$v_measureGrp/descendant::tei:measure[@unit=$v_source-unit]/@quantity"/>
                        <xsl:variable name="v_source-quantity" select="@quantity"/>
                        <!-- use Dreisatz / rule of three -->
                        <xsl:value-of select="$v_source-quantity *  $v_target-unit-quantity div $v_source-unit-quantity"/>
                        <xsl:if test="$p_debug=true()">
                            <xsl:message>
                                <xsl:value-of select="$v_source-quantity *  $v_target-unit-quantity div $v_source-unit-quantity"/><xsl:value-of select="concat('(',$v_target-unit,')')"/>
                                <xsl:text> = </xsl:text>
                                <xsl:value-of select="concat($v_source-quantity,'(',$v_source-unit,')')"/>
                                <xsl:text> * </xsl:text>
                                <xsl:value-of select="$v_target-unit-quantity"/>
                                <xsl:text> / </xsl:text>
                                <xsl:value-of select="concat($v_source-unit-quantity,'(',$v_source-unit,')')"/>
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
    
    <!-- regularize all measureGrp that express a price to provide information on one whole unit  -->
    <xsl:template match="tei:measureGrp[descendant::tei:measure/@commodity='currency'][descendant::tei:measure[@commodity!='currency'][@quantity!=1]]" mode="m_normalize-quantity">
        <xsl:variable name="v_regularization-factor" select="1 div number(descendant::tei:measure[@commodity!='currency'][1]/@quantity)" as="xs:double"/>
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="m_normalize-quantity">
                <xsl:with-param name="p_regularization-factor" select="$v_regularization-factor"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:measure[@quantity!='']" mode="m_normalize-quantity">
        <xsl:param name="p_regularization-factor" select="1"/>
        <xsl:if test="$p_debug = true()">
            <xsl:message>
                <xsl:value-of select="parent::tei:measureGrp/@source"/>
                <xsl:text>: m_normalize-quantity</xsl:text>
            </xsl:message>
        </xsl:if>
          <xsl:copy>
              <!-- reproduce existing attributes -->
              <xsl:copy-of select="@*"/>
              <xsl:apply-templates select="@commodity | @unit" mode="m_normalize-quantity"/>
              <xsl:attribute name="quantity" select="@quantity * $p_regularization-factor"/>
              <xsl:choose>
                  <!-- if the unit had been normalized before the original quantity should not be changed -->
                  <xsl:when test="$p_regularization-factor!=1 and @quantityOrig">
                      <xsl:attribute name="change" select="'#regularized'"/>
                  </xsl:when>
                  <!-- otherwise the quantity was only changed now -->
                  <xsl:when test="$p_regularization-factor!=1">
                      <xsl:attribute name="change" select="'#regularized'"/>
                      <xsl:attribute name="quantityOrig" select="@quantity"/>
                  </xsl:when>
              </xsl:choose>
              <xsl:apply-templates mode="m_normalize-quantity"/>
          </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
