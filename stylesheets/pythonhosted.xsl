<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

  <xsl:output method="text"/>

  <xsl:include href="pyhosted-inc.xsl"/>
  <xsl:param name="packages">requests sphinx_rtd_theme pytest</xsl:param>
  <xsl:variable name="python-deps">python-dependencies.xml</xsl:variable>
  <xsl:variable name="raw-dep-list">
    <xsl:call-template name="gen-deps">
      <xsl:with-param name="list" select="$packages"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="dep-list">
    <xsl:call-template name="make-unique">
      <xsl:with-param name="list" select="$raw-dep-list"/>
      <xsl:with-param name="temp" select="' '"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:template name="gen-deps">
    <xsl:param name="list" select="$packages"/>
    <xsl:choose>
      <xsl:when test="contains($list,' ')">
        <xsl:call-template name="gen-deps">
          <xsl:with-param name="list" select="substring-before($list,' ')"/>
        </xsl:call-template>
        <xsl:call-template name="gen-deps">
          <xsl:with-param name="list" select="substring-after($list,' ')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="id($list)" mode="gen-dep"/>
        <xsl:value-of select="$list"/>
        <xsl:text> </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*" mode="gen-dep">
    <!--
    <xsl:message>
      <xsl:text>generating deps for </xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>
</xsl:text>
    </xsl:message>
-->
    <xsl:apply-templates
      select="descendant::para[@role='required' or
                               @role='recommended']"
      mode="dep-list"/>
  </xsl:template>

  <xsl:template match="para" mode="dep-list">
    <xsl:for-each select="xref">
      <xsl:choose>
        <xsl:when test="//*[@id=current()/@linkend]">
          <xsl:apply-templates select="//*[@id=current()/@linkend]" mode="gen-dep"/>
          <xsl:value-of select="@linkend"/>
          <xsl:text> </xsl:text>
        </xsl:when>
        <xsl:when test="document($python-deps,/)//*[@id=current()/@linkend]">
          <xsl:apply-templates select="document($python-deps,/)//*[@id=current()/@linkend]" mode="gen-dep"/>
          <xsl:value-of select="@linkend"/>
          <xsl:text> </xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="make-unique">
    <xsl:param name="list" select="$raw-dep-list"/>
    <xsl:param name="temp" select="' '"/>
    <xsl:choose>
      <xsl:when test="contains($list,' ')">
        <xsl:variable name="package" select="substring-before($list,' ')"/>
        <xsl:variable name="temp1">
          <xsl:choose>
            <xsl:when test="contains($temp,concat(' ',$package,' '))">
              <xsl:copy-of select="$temp"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="$temp"/>
              <xsl:text> </xsl:text>
              <xsl:copy-of select="$package"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="make-unique">
          <xsl:with-param name="list" select="substring-after($list,' ')"/>
          <xsl:with-param name="temp" select="$temp1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="contains($temp,concat(' ',$list,' '))">
            <xsl:copy-of select="$temp"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$temp"/>
            <xsl:text> </xsl:text>
            <xsl:copy-of select="$list"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/">
    <!--
    <xsl:message>
      <xsl:text>Generating new pythonhosted.xml with list:
</xsl:text>
      <xsl:value-of select="normalize-space($dep-list)"/>
      <xsl:text>
</xsl:text>
    </xsl:message>
-->
    <xsl:value-of select="$part1"/>
    <xsl:call-template name="make-md5">
      <xsl:with-param name="list" select="normalize-space($dep-list)"/>
    </xsl:call-template>
    <xsl:value-of select="$part2"/>
  </xsl:template>

  <xsl:template name="make-md5">
    <xsl:param name="list" select="normalize-space($dep-list)"/>
    <xsl:choose>
      <xsl:when test="contains($list,' ')">
        <xsl:call-template name="make-md5">
          <xsl:with-param name="list" select="substring-before($list,' ')"/>
        </xsl:call-template>
        <xsl:text>
</xsl:text>
        <xsl:call-template name="make-md5">
          <xsl:with-param name="list" select="substring-after($list,' ')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates
          select="id($list)"
          mode="md5-line">
          <xsl:with-param name="first-char" select="'#'"/>
        </xsl:apply-templates>
        <xsl:apply-templates
          select="document($python-deps,/)//sect2[@id=$list]"
          mode="md5-line"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="sect2" mode="md5-line">
    <xsl:param name="first-char" select="''"/>
    <!--
    <xsl:message>
      <xsl:text>Generating md5 for </xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>
</xsl:text>
    </xsl:message>
-->
    <xsl:copy-of select="$first-char"/>
    <xsl:apply-templates select=".//para[contains(text(),'MD5')]" mode="md5"/>
    <xsl:text>  </xsl:text>
    <xsl:apply-templates select=".//para[contains(text(),'HTTP')]" mode="http"/>
  </xsl:template>

    <xsl:template match="para" mode="md5">
    <xsl:choose>
      <xsl:when test="contains(substring-after(string(),'sum: '),'&#xA;')">
        <xsl:value-of select="substring-before(substring-after(string(),'sum: '),'&#xA;')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="substring-after(string(),'sum: ')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="para" mode="http">
    <xsl:call-template name="base">
      <xsl:with-param name="path" select="ulink/@url"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="base">
    <xsl:param name="path" select="''"/>
    <xsl:choose>
      <xsl:when test="contains($path,'/')">
        <xsl:call-template name="base">
          <xsl:with-param name="path" select="substring-after($path,'/')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$path"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
