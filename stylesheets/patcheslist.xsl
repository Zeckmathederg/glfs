<?xml version='1.0' encoding='ISO-8859-1'?>
<!DOCTYPE xsl:stylesheet [
 <!ENTITY % general-entities SYSTEM "../general.ent">
  %general-entities;
]>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <xsl:output method="text"/>

    <!-- Allow select the dest dir at runtime -->
  <xsl:param name="dest.dir">
    <xsl:value-of select="concat('/home/httpd/', substring-after('&patch-root;', 'http://'))"/>
  </xsl:param>

  <xsl:template match="/">
    <xsl:text>#! /bin/bash&#x0a;&#x0a;</xsl:text>
      <!-- Create dest.dir if it don't exist -->
    <xsl:text>  mkdir -p </xsl:text>
    <xsl:value-of select="$dest.dir"/>
    <xsl:text> &amp;&amp;&#x0a;</xsl:text>
    <xsl:text>  cd </xsl:text>
    <xsl:value-of select="$dest.dir"/>
    <xsl:text> &amp;&amp;&#x0a;&#x0a;</xsl:text>
      <!-- Touch a dummy patch to prevent fails if dest dir is empty, then remove old patches -->
    <xsl:text>  touch dummy.patch &amp;&amp;&#x0a;  rm -f *.patch &amp;&amp;&#x0a;&#x0a;</xsl:text>
    <xsl:apply-templates/>
      <!-- Ensure correct owneship -->
    <xsl:text>&#x0a;  chgrp lfswww *.patch &amp;&amp;&#x0a;</xsl:text>
    <xsl:text>&#x0a;  exit&#x0a;</xsl:text>
  </xsl:template>

  <xsl:template match="//text()"/>

  <xsl:template match="//ulink">
      <!-- Match only local patches links and skip duplicated URLs splitted for PDF output-->
    <xsl:if test="contains(@url, '.patch') and contains(@url, '&patch-root;') 
            and not(ancestor-or-self::*/@condition = 'pdf')">
      <xsl:variable name="patch.name" select="substring-after(@url, '&patch-root;')"/>
      <xsl:text>  cp /home/httpd/www.linuxfromscratch.org/patches/downloads</xsl:text>
      <xsl:choose>
          <!-- cdparanoia -->
        <xsl:when test="contains($patch.name, '-III')">
          <xsl:text>/cdparanoia</xsl:text>
        </xsl:when>
          <!-- Open Office -->
        <xsl:when test="contains($patch.name, 'OOo')">
          <xsl:text>/OOo</xsl:text>
        </xsl:when>
          <!-- QT -->
        <xsl:when test="contains($patch.name, 'qt-x')">
          <xsl:text>/qt</xsl:text>
        </xsl:when>
          <!-- XOrg -->
        <xsl:when test="contains($patch.name, 'X11R6')">
          <xsl:text>/xorg</xsl:text>
        </xsl:when>
          <!-- General rule -->
        <xsl:otherwise>
          <xsl:variable name="cut" 
                  select="translate(substring-after($patch.name, '-'), '0123456789', '0000000000')"/>
          <xsl:variable name="patch.name2">
            <xsl:value-of select="substring-before($patch.name, '-')"/>
            <xsl:text>-</xsl:text>
            <xsl:value-of select="$cut"/>
          </xsl:variable>
          <xsl:value-of select="substring-before($patch.name2, '-0')"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="$patch.name"/>
      <xsl:text> . &#x0a;</xsl:text>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>