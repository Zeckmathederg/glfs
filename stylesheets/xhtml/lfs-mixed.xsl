<?xml version='1.0' encoding='ISO-8859-1'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                version="1.0">

    <!-- screen -->
  <xsl:template match="screen">
    <xsl:choose>
      <xsl:when test="@role = 'root'">
        <pre class="root">
            <xsl:apply-templates/>
        </pre>
      </xsl:when>
      <xsl:when test="child::* = userinput">
        <pre class="userinput">
            <xsl:apply-templates/>
        </pre>
      </xsl:when>
      <xsl:otherwise>
        <pre class="{name(.)}">
          <xsl:apply-templates/>
        </pre>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

    <!-- userinput -->
  <xsl:template match="userinput">
    <xsl:choose>
      <xsl:when test="ancestor::screen">
        <kbd class="command">
          <xsl:apply-templates/>
        </kbd>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-imports/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

    <!-- Body attributes -->
  <xsl:template name="body.attributes">
    <xsl:attribute name="id">
      <xsl:text>blfs</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="class">
      <xsl:value-of select="substring-after(/book/bookinfo/subtitle, ' ')"/>
    </xsl:attribute>
  </xsl:template>

    <!-- External URLs in class='url' -->
  <xsl:template match="ulink" name="ulink">
    <a>
      <xsl:if test="@id">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:attribute name="href"><xsl:value-of select="@url"/></xsl:attribute>
       <span class='url'>
        <xsl:choose>
          <xsl:when test="count(child::node())=0">
            <xsl:value-of select="@url"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </span>
    </a>
  </xsl:template>

    <!-- Cunstomizing segementedlist -->
  <xsl:template match="seg">
    <xsl:variable name="segnum" select="count(preceding-sibling::seg)+1"/>
    <xsl:variable name="seglist" select="ancestor::segmentedlist"/>
    <xsl:variable name="segtitles" select="$seglist/segtitle"/>
      <!-- Note: segtitle is only going to be the right thing in a well formed
      SegmentedList.  If there are too many Segs or too few SegTitles,
      you'll get something odd...maybe an error -->
      <div class="seg">
      <strong>
        <span class="segtitle">
          <xsl:apply-templates select="$segtitles[$segnum=position()]"
                  mode="segtitle-in-seg"/>
          <xsl:text>: </xsl:text>
        </span>
      </strong>
      <span class="seg">
        <xsl:apply-templates/>
      </span>
    </div>
  </xsl:template>

    <!-- The <code> xhtml tag have look issues in some browsers, like Konqueror and.
      isn't semantically correct (a filename isn't a code fragment) We will use <tt> for now. -->
  <xsl:template name="inline.monoseq">
    <xsl:param name="content">
      <xsl:call-template name="anchor"/>
      <xsl:call-template name="simple.xlink">
        <xsl:with-param name="content">
          <xsl:apply-templates/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:param>
    <tt class="{local-name(.)}">
      <xsl:if test="@dir">
        <xsl:attribute name="dir">
          <xsl:value-of select="@dir"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:copy-of select="$content"/>
    </tt>
  </xsl:template>

  <xsl:template name="inline.boldmonoseq">
    <xsl:param name="content">
      <xsl:call-template name="anchor"/>
      <xsl:call-template name="simple.xlink">
        <xsl:with-param name="content">
          <xsl:apply-templates/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:param>
    <!-- don't put <strong> inside figure, example, or table titles -->
    <!-- or other titles that may already be represented with <strong>'s. -->
    <xsl:choose>
      <xsl:when test="local-name(..) = 'title' and (local-name(../..) = 'figure'
              or local-name(../..) = 'example' or local-name(../..) = 'table' or local-name(../..) = 'formalpara')">
        <tt class="{local-name(.)}">
          <xsl:if test="@dir">
            <xsl:attribute name="dir">
              <xsl:value-of select="@dir"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:copy-of select="$content"/>
        </tt>
      </xsl:when>
      <xsl:otherwise>
        <strong class="{local-name(.)}">
          <tt>
            <xsl:if test="@dir">
              <xsl:attribute name="dir">
                <xsl:value-of select="@dir"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="$content"/>
          </tt>
        </strong>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="inline.italicmonoseq">
    <xsl:param name="content">
      <xsl:call-template name="anchor"/>
      <xsl:call-template name="simple.xlink">
        <xsl:with-param name="content">
          <xsl:apply-templates/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:param>
    <em class="{local-name(.)}">
      <tt>
        <xsl:if test="@dir">
          <xsl:attribute name="dir">
            <xsl:value-of select="@dir"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:copy-of select="$content"/>
      </tt>
    </em>
  </xsl:template>

    <!-- Revision History -->
  <xsl:template match="revhistory" mode="titlepage.mode">
    <xsl:variable name="numcols">
      <xsl:choose>
        <xsl:when test="//authorinitials">4</xsl:when>
        <xsl:otherwise>3</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="id"><xsl:call-template name="object.id"/></xsl:variable>
    <xsl:variable name="title">
      <xsl:call-template name="gentext">
        <xsl:with-param name="key">RevHistory</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="contents">
      <div class="{name(.)}">
        <table summary="Revision history">
          <tr>
            <th colspan="{$numcols}">
              <b>
                <xsl:call-template name="gentext">
                  <xsl:with-param name="key" select="'RevHistory'"/>
                </xsl:call-template>
              </b>
            </th>
          </tr>
          <xsl:apply-templates mode="titlepage.mode">
            <xsl:with-param name="numcols" select="$numcols"/>
          </xsl:apply-templates>
        </table>
      </div>
    </xsl:variable>
    <!--<xsl:choose>
      <xsl:when test="$generate.revhistory.link != 0">
        <xsl:variable name="filename">
          <xsl:call-template name="make-relative-filename">
            <xsl:with-param name="base.dir" select="$base.dir"/>
            <xsl:with-param name="base.name" select="concat($id,$html.ext)"/>
          </xsl:call-template>
        </xsl:variable>
        <a href="{concat($id,$html.ext)}">
          <xsl:copy-of select="$title"/>
        </a>
        <xsl:call-template name="write.chunk">
          <xsl:with-param name="filename" select="$filename"/>
          <xsl:with-param name="quiet" select="$chunk.quietly"/>
          <xsl:with-param name="content">
          <xsl:call-template name="user.preroot"/>
            <html>
              <head>
                <xsl:call-template name="system.head.content"/>
                <xsl:call-template name="head.content">
                  <xsl:with-param name="title">
                      <xsl:value-of select="$title"/>
                      <xsl:if test="../../title">
                          <xsl:value-of select="concat(' (', ../../title, ')')"/>
                      </xsl:if>
                  </xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="user.head.content"/>
              </head>
              <body>
                <xsl:call-template name="body.attributes"/>
                <xsl:copy-of select="$contents"/>
              </body>
            </html>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>-->
        <xsl:copy-of select="$contents"/>
      <!--</xsl:otherwise>
    </xsl:choose>-->
  </xsl:template>

  <xsl:template match="revhistory/revision" mode="titlepage.mode">
    <xsl:param name="numcols" select="'3'"/>
    <xsl:variable name="revnumber" select="revnumber"/>
    <xsl:variable name="revdate" select="date"/>
    <xsl:variable name="revauthor" select="authorinitials"/>
    <xsl:variable name="revremark" select="revremark|revdescription"/>
    <tr>
      <td>
        <xsl:if test="$revnumber">
          <xsl:call-template name="gentext">
            <xsl:with-param name="key" select="'Revision'"/>
          </xsl:call-template>
          <xsl:call-template name="gentext.space"/>
          <xsl:apply-templates select="$revnumber[1]" mode="titlepage.mode"/>
        </xsl:if>
      </td>
      <td>
        <xsl:apply-templates select="$revdate[1]" mode="titlepage.mode"/>
      </td>
      <xsl:choose>
        <xsl:when test="$revauthor">
          <td align="left">
            <xsl:for-each select="$revauthor">
              <xsl:apply-templates select="." mode="titlepage.mode"/>
              <xsl:if test="position() != last()">
                <xsl:text>, </xsl:text>
              </xsl:if>
            </xsl:for-each>
          </td>
        </xsl:when>
        <xsl:when test="$numcols &gt; 3">
          <td>&#160;</td>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
      <td>
        <xsl:apply-templates select="$revremark[1]" mode="titlepage.mode"/>
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>
