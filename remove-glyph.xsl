<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="page" version="2.0"
    xmlns:page="http://schema.primaresearch.org/PAGE/gts/pagecontent/2019-07-15"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://schema.primaresearch.org/PAGE/gts/pagecontent/2019-07-15 http://schema.primaresearch.org/PAGE/gts/pagecontent/2019-07-15/pagecontent.xsd">
    <xsl:output indent="yes"/>
    <xsl:template match="/">
        <xsl:apply-templates select="*" />
    </xsl:template>
    <xsl:template match="page:TextLine">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="child::page:Coords" />
            <xsl:apply-templates select="child::page:Baseline" />
            <xsl:apply-templates select="child::page:TextEquiv" />
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>