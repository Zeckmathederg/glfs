<?xml version='1.0' encoding='ISO-8859-1'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                version="1.0">

  <!-- This stylesheet controls how preface, chapter, and sections are handled -->

    <!-- Chunk the first top-level section? 1 = yes, 0 = no
         If preface and chapters TOC are generated, this must be 1. -->
  <xsl:param name="chunk.first.sections" select="1"/>

    <!-- preface:
           Output non sect1 child elements before the TOC -->
    <!-- The original template is in {docbook-xsl}/xhtml/components.xsl -->
  <xsl:template match="preface">
    <xsl:call-template name="id.warning"/>
    <div>
      <xsl:apply-templates select="." mode="class.attribute"/>
      <xsl:call-template name="dir">
        <xsl:with-param name="inherit" select="1"/>
      </xsl:call-template>
      <xsl:call-template name="language.attribute"/>
      <xsl:if test="$generate.id.attributes != 0">
        <xsl:attribute name="id">
          <xsl:call-template name="object.id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:call-template name="component.separator"/>
      <xsl:call-template name="preface.titlepage"/>
      <xsl:apply-templates/>
      <xsl:variable name="toc.params">
        <xsl:call-template name="find.path.params">
          <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:if test="contains($toc.params, 'toc')">
        <xsl:call-template name="component.toc">
          <xsl:with-param name="toc.title.p" select="contains($toc.params, 'title')"/>
        </xsl:call-template>
        <xsl:call-template name="component.toc.separator"/>
      </xsl:if>
      <xsl:call-template name="process.footnotes"/>
    </div>
  </xsl:template>

    <!-- chapter:
           Output non sect1 child elements before the TOC -->
    <!-- The original template is in {docbook-xsl}/xhtml/components.xsl -->
  <xsl:template match="chapter">
    <xsl:call-template name="id.warning"/>
    <div>
      <xsl:apply-templates select="." mode="class.attribute"/>
      <xsl:call-template name="dir">
        <xsl:with-param name="inherit" select="1"/>
      </xsl:call-template>
      <xsl:call-template name="language.attribute"/>
      <xsl:if test="$generate.id.attributes != 0">
        <xsl:attribute name="id">
          <xsl:call-template name="object.id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:call-template name="component.separator"/>
      <xsl:call-template name="chapter.titlepage"/>
      <xsl:apply-templates/>
      <xsl:variable name="toc.params">
        <xsl:call-template name="find.path.params">
          <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:if test="contains($toc.params, 'toc')">
        <xsl:call-template name="component.toc">
          <xsl:with-param name="toc.title.p" select="contains($toc.params, 'title')"/>
        </xsl:call-template>
        <xsl:call-template name="component.toc.separator"/>
      </xsl:if>
      <xsl:call-template name="process.footnotes"/>
    </div>
  </xsl:template>

    <!-- sect1:
           When there is a role attibute, use it as the class value.
