<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                version="1.0">

<!-- glossary:
     Output title before the containing <div>, so that it can be at a fixed
     position
     Simplify due to the fact that we have only one glossdiv children, and
     no other glossxxx child -->
<!-- the original template is in {docbook-xsl}/xhtml/glossary.xsl -->
  <xsl:template match="glossary">

    <xsl:variable name="language">
      <xsl:call-template name="l10n.language"/>
    </xsl:variable>

    <xsl:variable name="lowercase">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key">normalize.sort.input</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="uppercase">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key">normalize.sort.output</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>

    <xsl:call-template name="id.warning"/>

    <xsl:call-template name="glossary.titlepage"/>

    <xsl:element name="div" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="." mode="common.html.attributes"/>
      <xsl:call-template name="id.attribute">
        <xsl:with-param name="conditional" select="0"/>
      </xsl:call-template>

      <xsl:apply-templates select="(glossdiv[1]/preceding-sibling::*)"/>

      <xsl:apply-templates select="glossdiv"/>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
