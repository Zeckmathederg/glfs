<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

  <xsl:output method="text"/>

  <xsl:template match="/">
    <xsl:apply-templates select="//sect1[./sect2[@role='installation']]"/>
  </xsl:template>

  <xsl:template match="sect1">
    <xsl:variable name="config-string">
      <xsl:apply-templates
        select=".//screen/userinput[contains(string(),'configure') or
                                    contains(string(),'autogen') or
                                    contains(string(),'cmake') or
                                    contains(string(),'meson') or
                                    contains(string(),'b2') or
                                    contains(string(),'Local/Makefile') or
                                    contains(string(),'testlog') or
                                    contains(string(),'make')]"/>
    </xsl:variable>
    <xsl:text>
-------------------
</xsl:text>
    <xsl:value-of select="@xreflabel"/>
    <xsl:text>
-------------------
</xsl:text>
    <xsl:apply-templates select=".//sect2[@role='commands']//option">
      <xsl:with-param name="config-string"
                      select="normalize-space($config-string)"/>
    </xsl:apply-templates>
    <xsl:apply-templates select=".//sect2[@role='commands']//parameter">
      <xsl:with-param name="config-string"
                      select="normalize-space($config-string)"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="parameter">
    <xsl:param name="config-string"/>
    <xsl:variable name="param-string">
      <xsl:choose>
        <xsl:when test="contains(string(),'...')">
          <xsl:copy-of
            select="normalize-space(substring-before(string(),'...'))"/>
        </xsl:when>
        <xsl:when test="contains(string(),'*')">
          <xsl:copy-of
            select="normalize-space(substring-before(string(),'*'))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="normalize-space(string())"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="not(contains($config-string, $param-string))">
      <xsl:copy-of select="string()"/>
      <xsl:text> is a parameter, but is not in config string
</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="option">
    <xsl:param name="config-string"/>
    <xsl:variable name="option-string">
      <xsl:choose>
        <xsl:when test="contains(string(),'...')">
          <xsl:copy-of
            select="normalize-space(substring-before(string(),'...'))"/>
        </xsl:when>
        <xsl:when test="contains(string(),'*')">
          <xsl:copy-of
            select="normalize-space(substring-before(string(),'*'))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="normalize-space(string())"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="contains($config-string, $option-string)">
      <xsl:copy-of select="string()"/>
      <xsl:text> is an option, but is in config string
</xsl:text>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
