<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:till="http://www.sitzextase.de" xmlns:tss="http://www.thirdstreetsoftware.com/SenteXML-1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:param name="pCommodity" select="'wheat'"/>
    <xsl:param name="pUnit" select="'kile'"/>
    <xsl:variable name="v_separator" select="','"/>
    <xsl:template match="tei:measureGrp">
        <!-- there is usually just one entry for non-curreny commodities -->
        <!-- as I feed the output directly into a graph, the commodity should be omitted -->
        <xsl:choose>
            <xsl:when test="$pCommodity='wheat' and $pUnit = 'kile'">
                <xsl:for-each select="./descendant::tei:measure[@commodity=$pCommodity]">
                    <xsl:variable name="vCommodity" select="."/>
                    <xsl:choose>
                        <xsl:when test="@unit='kile'">
                            <xsl:value-of select="@quantity"/>
                            <xsl:value-of select="$v_separator"/>
                            <xsl:value-of select="@unit"/>
                            <xsl:value-of select="$v_separator"/>
                        </xsl:when>
                        <xsl:when test="@unit='kg' and @quantity=1">
                            <xsl:text>1</xsl:text>
                            <xsl:value-of select="$v_separator"/>
                            <xsl:text>kile</xsl:text>
                            <xsl:value-of select="$v_separator"/>
                        </xsl:when>
                        <xsl:when test="@unit='madd' and @quantity=1">
                            <xsl:text>1</xsl:text>
                            <xsl:value-of select="$v_separator"/>
                            <xsl:text>kile</xsl:text>
                            <xsl:value-of select="$v_separator"/>
                        </xsl:when>
                        <xsl:when test="@unit='cift' and @quantity=1">
                            <xsl:text>1</xsl:text>
                            <xsl:value-of select="$v_separator"/>
                            <xsl:text>kile</xsl:text>
                            <xsl:value-of select="$v_separator"/>
                        </xsl:when>
                    </xsl:choose>
                    <!-- followed by the price or a price range -->
                    <xsl:for-each select="ancestor::tei:measureGrp/descendant::tei:measure[@commodity='currency'][@unit='ops']">
                        <xsl:sort select="@quantity" order="ascending"/>
                        <xsl:choose>
                            <xsl:when test="$vCommodity[@unit='kile']">
                                <xsl:value-of select="@quantity"/>
                                <xsl:value-of select="$v_separator"/>
                                <xsl:value-of select="@unit"/>
                                <xsl:value-of select="$v_separator"/>
                            </xsl:when>
                            <!-- 1 kile wheat weights between 31 and 35 kg; I opted for 33kg -->
                            <xsl:when test="$vCommodity[@unit='kg'][@quantity=1]">
                                <xsl:value-of select="33* @quantity"/>
                                <xsl:value-of select="$v_separator"/>
                                <xsl:value-of select="@unit"/>
                                <xsl:value-of select="$v_separator"/>
                            </xsl:when>
                            <!-- 1 madd = 0.5 kile -->
                            <xsl:when test="$vCommodity[@unit='madd'][@quantity=1]">
                                <xsl:value-of select="2* @quantity"/>
                                <xsl:value-of select="$v_separator"/>
                                <xsl:value-of select="@unit"/>
                                <xsl:value-of select="$v_separator"/>
                            </xsl:when>
                            <!-- 1 cift = 1 kile -->
                            <xsl:when test="$vCommodity[@unit='cift'][@quantity=1]">
                                <xsl:value-of select="@quantity"/>
                                <xsl:value-of select="$v_separator"/>
                                <xsl:value-of select="@unit"/>
                                <xsl:value-of select="$v_separator"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$pUnit = 'kile'">
                <xsl:for-each select="./descendant::tei:measure[@commodity=$pCommodity]">
                    <xsl:variable name="vCommodity" select="."/>
                    <xsl:variable name="vCommodityQuantity" select="$vCommodity/@quantity"/>
                    <xsl:choose>
                        <xsl:when test="@unit='kile'">
                            <xsl:value-of select="@quantity"/>
                            <xsl:value-of select="$v_separator"/>
                            <xsl:value-of select="@unit"/>
                            <xsl:value-of select="$v_separator"/>
                        </xsl:when>
                        <xsl:when test="@unit='madd' and @quantity=1">
                            <xsl:text>1</xsl:text>
                            <xsl:value-of select="$v_separator"/>
                            <xsl:text>kile</xsl:text>
                            <xsl:value-of select="$v_separator"/>
                        </xsl:when>
                        <xsl:when test="@unit='cift' and @quantity=1">
                            <xsl:text>1</xsl:text>
                            <xsl:value-of select="$v_separator"/>
                            <xsl:text>kile</xsl:text>
                            <xsl:value-of select="$v_separator"/>
                        </xsl:when>
                    </xsl:choose>
                    <!-- followed by the price or a price range -->
                    <xsl:for-each select="ancestor::tei:measureGrp/descendant::tei:measure[@commodity='currency'][@unit='ops']">
                        <xsl:sort select="@quantity" order="ascending"/>
                        <xsl:choose>
                            <xsl:when test="$vCommodity[@unit='kile']">
                                <xsl:value-of select="@quantity"/>
                                <xsl:value-of select="$v_separator"/>
                                <xsl:value-of select="@unit"/>
                                <xsl:value-of select="$v_separator"/>
                            </xsl:when>
                            <!-- 1 madd = 0.5 kile -->
                            <xsl:when test="$vCommodity[@unit='madd']">
                                <xsl:value-of select="2* @quantity div $vCommodityQuantity"/>
                                <xsl:value-of select="$v_separator"/>
                                <xsl:value-of select="@unit"/>
                                <xsl:value-of select="$v_separator"/>
                            </xsl:when>
                            <!-- 1 cift = 1 kile -->
                            <xsl:when test="$vCommodity[@unit='cift']">
                                <xsl:value-of select="@quantity div $vCommodityQuantity"/>
                                <xsl:value-of select="$v_separator"/>
                                <xsl:value-of select="@unit"/>
                                <xsl:value-of select="$v_separator"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$pUnit = 'ratl'">
                <xsl:for-each select="./descendant::tei:measure[@commodity=$pCommodity]">
                    <xsl:variable name="vCommodity" select="."/>
                    <xsl:variable name="vCommodityQuantity" select="$vCommodity/@quantity"/>
                    <xsl:choose>
                        <xsl:when test="@unit='ratl'">
                            <xsl:value-of select="@quantity"/>
                            <xsl:value-of select="$v_separator"/>
                            <xsl:value-of select="@unit"/>
                            <xsl:value-of select="$v_separator"/>
                        </xsl:when>
                        <xsl:when test="@unit='okka'">
                            <xsl:text>1;ratl;</xsl:text>
                        </xsl:when>
                        <xsl:when test="@unit='dirham'">
                            <xsl:text>1;ratl;</xsl:text>
                        </xsl:when>
                        <xsl:when test="@unit='qintar'">
                            <xsl:text>1;ratl;</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                    <!-- followed by the price or a price range -->
                    <xsl:for-each select="ancestor::tei:measureGrp/descendant::tei:measure[@commodity='currency'][@unit='ops']">
                        <xsl:sort select="@quantity" order="ascending"/>
                        <xsl:choose>
                            <xsl:when test="$vCommodity[@unit='ratl']">
                                <xsl:value-of select="@quantity"/>
                                <xsl:value-of select="$v_separator"/>
                                <xsl:value-of select="@unit"/>
                                <xsl:value-of select="$v_separator"/>
                            </xsl:when>
                            <!-- 1 ratl = 2 okka -->
                            <xsl:when test="$vCommodity[@unit='okka']">
                                <xsl:value-of select="2* @quantity div $vCommodityQuantity"/>
                                <xsl:value-of select="$v_separator"/>
                                <xsl:value-of select="@unit"/>
                                <xsl:value-of select="$v_separator"/>
                            </xsl:when>
                            <!-- 1 ratl = 800 dirham -->
                            <xsl:when test="$vCommodity[@unit='dirham']">
                                <xsl:value-of select="800* @quantity div $vCommodityQuantity"/>
                                <xsl:value-of select="$v_separator"/>
                                <xsl:value-of select="@unit"/>
                                <xsl:value-of select="$v_separator"/>
                            </xsl:when>
                            <!-- 100 ratl = 1 qintar -->
                            <xsl:when test="$vCommodity[@unit='qintar']">
                                <xsl:value-of select="@quantity div 100 div $vCommodityQuantity"/>
                                <xsl:value-of select="$v_separator"/>
                                <xsl:value-of select="@unit"/>
                                <xsl:value-of select="$v_separator"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="./descendant::tei:measure[@commodity=$pCommodity]">
                    <xsl:value-of select="@quantity"/>
                    <xsl:value-of select="$v_separator"/>
                    <xsl:value-of select="@unit"/>
                    <xsl:value-of select="$v_separator"/>
                </xsl:for-each>
                <!-- followed by the price or a price range -->
                <xsl:for-each select="./descendant::tei:measure[@commodity='currency'][@unit='ops']">
                    <xsl:sort select="@quantity" order="ascending"/>
                    <xsl:value-of select="@quantity"/>
                    <xsl:value-of select="$v_separator"/>
                    <xsl:value-of select="@unit"/>
                    <xsl:value-of select="$v_separator"/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>
</xsl:text>
    </xsl:template>
</xsl:stylesheet>