<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                exclude-result-prefixes="exsl"
                version='1.0'>

<!-- ********************************************************************
     $Id: footnote.xsl,v 1.2 2002/09/09 00:52:19 nilgun Exp $
     ********************************************************************

     This file is part of the XSL DocBook Stylesheet distribution.
     See ../README or http://nwalsh.com/docbook/xsl/ for copyright
     and other information.

     ******************************************************************** -->

<xsl:template match="footnote">
  <xsl:variable name="name">
    <xsl:call-template name="object.id"/>
  </xsl:variable>
  <xsl:variable name="href">
    <xsl:text>#ftn.</xsl:text>
    <xsl:call-template name="object.id"/>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="ancestor::table|ancestor::informaltable">
      <sup>
        <xsl:text>[</xsl:text>
        <a name="{$name}" href="{$href}">
          <xsl:apply-templates select="." mode="footnote.number"/>
        </a>
        <xsl:text>]</xsl:text>
      </sup>
    </xsl:when>
    <xsl:otherwise>
      <sup>
        <xsl:text>[</xsl:text>
        <a name="{$name}" href="{$href}">
          <xsl:apply-templates select="." mode="footnote.number"/>
        </a>
        <xsl:text>]</xsl:text>
      </sup>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="footnoteref">
  <xsl:variable name="targets" select="key('id',@linkend)"/>
  <xsl:variable name="footnote" select="$targets[1]"/>
  <xsl:variable name="href">
    <xsl:text>#ftn.</xsl:text>
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="$footnote"/>
    </xsl:call-template>
  </xsl:variable>
  <sup>
    <xsl:text>[</xsl:text>
    <a href="{$href}">
      <xsl:apply-templates select="$footnote" mode="footnote.number"/>
    </a>
    <xsl:text>]</xsl:text>
  </sup>
</xsl:template>

<xsl:template match="footnote" mode="footnote.number">
  <xsl:choose>
    <xsl:when test="ancestor::table or ancestor::informaltable">
      <xsl:number level="any" from="table|informaltable" format="a"/>
    </xsl:when>
    <xsl:when test="ancestor::refentry">
      <xsl:number level="any" from="refentry" format="1"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:number level="any" format="1"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="footnote/para[1]|footnote/simpara[1]" priority="2">

  <!-- this only works if the first thing in a footnote is a para, -->
  <!-- which is ok, because it usually is. -->

  <xsl:variable name="name">
    <xsl:text>ftn.</xsl:text>
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="ancestor::footnote"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="href">
    <xsl:text>#</xsl:text>
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="ancestor::footnote"/>
    </xsl:call-template>
  </xsl:variable>
  <p>
    <sup>
      <xsl:text>[</xsl:text>
      <a name="{$name}" href="{$href}">
        <xsl:apply-templates select="ancestor::footnote"
                             mode="footnote.number"/>
      </a>
      <xsl:text>] </xsl:text>
    </sup>
    <xsl:apply-templates/>
  </p>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="*" mode="footnote.body.number">
  <xsl:variable name="name">
    <xsl:text>ftn.</xsl:text>
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="ancestor::footnote"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="href">
    <xsl:text>#</xsl:text>
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="ancestor::footnote"/>
    </xsl:call-template>
  </xsl:variable>


  <xsl:variable name="html">
    <xsl:apply-templates select="."/>
  </xsl:variable>

  <xsl:variable name="html-nodes" select="exsl:node-set($html)"/>

  <xsl:variable name="footnote.mark">
    <xsl:if test="name(.)!='para'">
      <sup>
        <xsl:text>[</xsl:text>
        <a name="{$name}" href="{$href}">
          <xsl:apply-templates select="ancestor::footnote"
                               mode="footnote.number"/>
        </a>
        <xsl:text>] </xsl:text>
      </sup>
    </xsl:if>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="$html-nodes//p">
      <xsl:apply-templates select="$html-nodes" mode="insert.html.p">
        <xsl:with-param name="mark" select="$footnote.mark"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="$html-nodes" mode="insert.html.text">
        <xsl:with-param name="mark" select="$footnote.mark"/>
      </xsl:apply-templates>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ==================================================================== -->

<!--
<xsl:template name="count-element-from">
  <xsl:param name="from" select=".."/>
  <xsl:param name="to" select="."/>
  <xsl:param name="count" select="0"/>
  <xsl:param name="list" select="$from/following::*[name(.)=name($to)]
                                 |$from/descendant-or-self::*[name(.)=name($to)]"/>

  <xsl:choose>
    <xsl:when test="not($list)">
      <xsl:text>-1</xsl:text>
    </xsl:when>
    <xsl:when test="$list[1] = $to">
      <xsl:value-of select="$count + 1"/>
    </xsl:when>
    <xsl:otherwise>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
-->

<!-- ==================================================================== -->

<xsl:template name="process.footnotes">
  <xsl:variable name="footnotes" select=".//footnote"/>
  <xsl:variable name="table.footnotes"
                select=".//table//footnote|.//informaltable//footnote"/>

  <!-- Only bother to do this if there's at least one non-table footnote -->
  <xsl:if test="count($footnotes)>count($table.footnotes)">
    <div class="footnotes">
      <br/>
      <hr width="100" align="left"/>
      <xsl:apply-templates select="$footnotes" mode="process.footnote.mode"/>
    </div>
  </xsl:if>
</xsl:template>

<xsl:template name="process.chunk.footnotes">
  <!-- nop -->
</xsl:template>

<xsl:template match="footnote" mode="process.footnote.mode">
  <xsl:choose>
    <xsl:when test="$html.cleanup != 0 and function-available('exsl:node-set')">
      <table width="100%" summary="Footnotes" cellspacing="3" cellpading="1" class="{name(.)}">
        <tr><td bgcolor="white" class="footoutline">
          <table width="100%" cellpadding="3" cellspacing="0" border="0">
            <tr><td bgcolor="white" class="footinline">
              <xsl:apply-templates select="*[1]" mode="footnote.body.number"/>
              <xsl:apply-templates select="*[position() &gt; 1]"/>
            </td></tr>
          </table>
        </td></tr>
      </table>
      <!--
      <div class="{name(.)}">
        <xsl:apply-templates select="*[1]" mode="footnote.body.number"/>
        <xsl:apply-templates select="*[position() &gt; 1]"/>
      </div>
      -->
    </xsl:when>
    <xsl:otherwise>
      <xsl:if test="local-name(*[1]) != 'para' and local-name(*[1]) != 'simpara'">
        <xsl:message>
          <xsl:text>Warning: footnote number may not be generated </xsl:text>
          <xsl:text>correctly; </xsl:text>
          <xsl:value-of select="local-name(*[1])"/>
          <xsl:text> unexpected as first child of footnote.</xsl:text>
        </xsl:message>
      </xsl:if>
      <table width="100%" summary="Footnotes" cellspacing="3" cellpading="1" class="{name(.)}">
        <tr><td bgcolor="white" class="footoutline">
          <table width="100%" cellpadding="3" cellspacing="0" border="0">
            <tr><td bgcolor="white" class="footinline">
              <xsl:apply-templates/>
            </td></tr>
          </table>
        </td></tr>
      </table>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="informaltable//footnote|table//footnote" 
              mode="process.footnote.mode">
</xsl:template>

<xsl:template match="footnote" mode="table.footnote.mode">
  <xsl:choose>
    <xsl:when test="$html.cleanup != 0 and function-available('exsl:node-set')">
      <div class="{name(.)}">
        <xsl:apply-templates select="*[1]" mode="footnote.body.number"/>
        <xsl:apply-templates select="*[position() &gt; 1]"/>
      </div>
    </xsl:when>
    <xsl:otherwise>
      <xsl:if test="local-name(*[1]) != 'para'
                    and local-name(*[1]) != 'simpara'">
        <xsl:message>
          <xsl:text>Warning: footnote number may not be generated </xsl:text>
          <xsl:text>correctly; </xsl:text>
          <xsl:value-of select="local-name(*[1])"/>
          <xsl:text> unexpected as first child of footnote.</xsl:text>
        </xsl:message>
      </xsl:if>
      <table width="100%" summary="Footnotes" cellspacing="3" cellpading="1" class="{name(.)}">
        <tr><td bgcolor="white" class="footoutline">
          <table width="100%" cellpadding="3" cellspacing="0" border="0">
            <tr><td bgcolor="white" class="footinline">
              <xsl:apply-templates/>
            </td></tr>
          </table>
        </td></tr>
      </table>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
