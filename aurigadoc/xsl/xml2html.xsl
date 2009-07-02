<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: xml2html.xsl,v 1.3 2007/08/08 10:19:12 gordon Exp $ -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output method="html" indent="yes" doctype-public="--//W3C//DTD HTML 4.01 Transitional//EN"/>

<!-- B: COMMON VARIABLES -->
<!--
*************************************************************************
Here we declare the document scope variable 
*************************************************************************
-->
<xsl:variable name="dfi" select="/document/document-formatting-info"/>

<xsl:variable name="toc" select="/document/document-body/table-of-content"/>

<xsl:variable name="dmi" select="/document/document-meta-info"/>

<xsl:variable name="nbsp">
<xsl:text> </xsl:text>
</xsl:variable>

<!-- number format for numbering sections -->
<xsl:variable name="snf">
<xsl:choose>
<xsl:when test="$dfi/generate-section-numbers/@number-format">
<xsl:value-of select="$dfi/generate-section-numbers/@number-format"/>
</xsl:when>
<xsl:otherwise>1</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<xsl:variable name="generate-section-numbers">
<xsl:choose>
<xsl:when test="$dfi/generate-section-numbers  = 'no'">no</xsl:when>
<xsl:otherwise>yes</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<!-- E: COMMON VARIABLES -->

<!-- 
*************************************************************************
Template for the document element. This template matches other templates 
from here
*************************************************************************
-->
<xsl:template match="document">
<html>
<head>
<xsl:apply-templates select="$dfi/stylesheet"/>
<meta name="generator" content="AurigaDoc"/>
<title>
<xsl:value-of select="$dmi/title"/>
</title>
</head>
	
<body>
	<!-- call the cover page -->
	<xsl:call-template name="cover-page"/>
			
	<xsl:apply-templates select="document-header"/>	

	<xsl:apply-templates select="document-body/table-of-content" mode="toc"/>	
	
	<xsl:apply-templates select="document-body"/>
		
	<xsl:apply-templates select="document-footer"/>	
</body>
</html>
</xsl:template>


<!-- 
*************************************************************************
Template for the document body. Defines a fo:block and appies other 
templates.
*************************************************************************
-->
<xsl:template match="document-body">
	<xsl:apply-templates/>
</xsl:template>


<!-- 
*************************************************************************
This template handles a section element
*************************************************************************
-->
<xsl:template match="section">
	<xsl:variable name="section-name" select="@name"/>
	<xsl:variable name="href" select="concat('#', $section-name)"/>
	<div class="navigation">
	<a name="{@name}"/>	
	<!-- navigation -->
	<xsl:call-template name="get-section-navigation">
		<xsl:with-param name="href" select="$href"/>
	</xsl:call-template>
	</div>	
	
	<xsl:variable name="section-level">
	<xsl:call-template name="get-section-level">
	<xsl:with-param name="href" select="$href"/>
	</xsl:call-template>
	</xsl:variable>
	
	<div class="section-heading-{$section-level}">
	<b>
	<xsl:if test="$generate-section-numbers = 'yes'">
	<xsl:call-template name="get-section-number">
	<xsl:with-param name="href" select="$href"/>
	</xsl:call-template>
<xsl:value-of select="$nbsp"/>
	</xsl:if>
	<xsl:value-of select="@label"/>
	</b>
<xsl:value-of select="$nbsp"/>
</div>
	
	<div class="section-body-{$section-level}">
	<xsl:apply-templates/>

	<!-- make the tree for this section -->
	<xsl:call-template name="sub-section-links">
		<xsl:with-param name="link-node" select="$toc//link[@href = $href]"/>
	</xsl:call-template>
	</div>
	<xsl:if test="following-sibling::section">
		<hr size="1" noshade="true"/>	
	</xsl:if>
</xsl:template>


<!-- 
*************************************************************************
This template handles the table-of-content tag
*************************************************************************
-->
<xsl:template match="table-of-content" mode="toc">
	<a name="table_of_content">
<b>Table of Contents</b>
</a>
	<xsl:choose>
	<xsl:when test="$generate-section-numbers = 'yes'">
		<xsl:apply-templates select="link" mode="section-nos"/>
	</xsl:when>
	<xsl:otherwise>
	<ul>
		<xsl:apply-templates select="link" mode="no-section-nos"/>
	</ul>
	</xsl:otherwise>
	</xsl:choose>
	<hr size="1" noshade="true"/>
</xsl:template>

<!--
*************************************************************************
This template renders a toc link with section numbers
*************************************************************************
-->
<xsl:template match="link" mode="section-nos">
<xsl:variable name="section-number">
<xsl:number level="multiple"/>.</xsl:variable>
<xsl:variable name="section-no">
<xsl:number level="multiple" format="{$snf}"/>.</xsl:variable>
<xsl:variable name="link" select="."/>
<xsl:variable name="level" select="string-length(translate($section-number, '0123456789',''))"/>
<table cellpadding="1" cellspacing="0" border="0">
	<tr>
	<td width="{$level * 25}" align="right">
<xsl:value-of select="concat($section-no, $nbsp)"/>
</td>
	<td>
<a href="{$link/@href}">
<xsl:value-of select="$link/text()"/>
</a>
</td>
	</tr>
</table>
<xsl:apply-templates select="link" mode="section-nos"/>
</xsl:template>

<!--
*************************************************************************
This template renders a toc link without section numbers
*************************************************************************
-->
<xsl:template match="link" mode="no-section-nos">
<li>
	<a href="{@href}">
<xsl:value-of select="text()"/>
</a>
	<xsl:if test="link">
	<ul>
<xsl:apply-templates select="link" mode="no-section-nos"/>
</ul>
	</xsl:if>
</li>	
</xsl:template>


<!-- 
*************************************************************************
Dummy template to avoid the below template being applied in normal mode
*************************************************************************
-->
<xsl:template match="table-of-content|page-number|link|page-break">
</xsl:template>


<!-- 
*************************************************************************
This template renders the document header
*************************************************************************
-->
<xsl:template match="document-header">
	<div class="document-header">
	<xsl:apply-templates/>
	</div>
</xsl:template>


<!-- 
*************************************************************************
This template renders the document footer
*************************************************************************
-->
<xsl:template match="document-footer">
	<div class="document-footer">
	<xsl:apply-templates/>
	</div>
</xsl:template>


<!-- 
*************************************************************************
This template renders the cover page
*************************************************************************
-->
<xsl:template name="cover-page">
	<!-- title -->
	<div class="document-title">
	<xsl:value-of select="$dmi/title"/>
	</div>
	<br/>
	<br/>
		
	<!-- all attributes -->
	<div class="document-attributes">
	<xsl:for-each select="$dmi/attribute">
		<xsl:value-of select="@name"/>: <xsl:apply-templates select="."/>
		<br/>
<br/>
	</xsl:for-each>
	</div>
	<hr size="4" noshade="true"/>
</xsl:template>


<!-- 
*************************************************************************
This template renders the attribute content
*************************************************************************
-->
<xsl:template match="attribute">
	<xsl:apply-templates/>
</xsl:template>

<!-- 
*************************************************************************
This template renders the sub section links
*************************************************************************
-->
<xsl:template name="sub-section-links">
<xsl:param name="link-node"/>

<xsl:if test="$link-node/link">
<br/>
<br/>
<xsl:choose>
<xsl:when test="$generate-section-numbers = 'yes'">
	<xsl:for-each select="$link-node/link">
		<xsl:apply-templates select="." mode="section-nos"/>
	</xsl:for-each>
</xsl:when>
<xsl:otherwise>
	<ul>
	<xsl:for-each select="$link-node/link">
		<xsl:apply-templates select="." mode="no-section-nos"/>
	</xsl:for-each>
	</ul>
</xsl:otherwise>
</xsl:choose>
</xsl:if>
</xsl:template>

<!-- 
*************************************************************************
This template renders the navigation links for each section
*************************************************************************
-->
<xsl:template name="get-section-navigation">
<xsl:param name="href"/>
<xsl:variable name="nodes" select="$toc//link[@href = $href]/../link"/>
		
	<!-- toc link -->
	<xsl:value-of select="$nbsp"/>
<a href="#table_of_content">Table of Contents</a>
	
	<xsl:for-each select="$nodes">
		<!-- Up link -->
		<xsl:if test="@href = $href and parent::link">
			<xsl:value-of select="$nbsp"/>| Up: <a href="{parent::link/@href}">
			<xsl:if test="$generate-section-numbers = 'yes'">
			<xsl:call-template name="get-section-number">
			<xsl:with-param name="href" select="parent::link/@href"/>
			</xsl:call-template>
<xsl:value-of select="$nbsp"/>
</xsl:if>
			<xsl:value-of select="parent::link/text()[1]"/>
</a>
		</xsl:if>
	</xsl:for-each>
	
	<xsl:for-each select="$nodes">
		<!-- previous link -->
		<xsl:if test="following-sibling::link[1][@href = $href]">
			<xsl:value-of select="$nbsp"/>| Previous: <a href="{@href}">
			<xsl:if test="$generate-section-numbers = 'yes'">
			<xsl:number level="multiple" format="{$snf}"/>.<xsl:value-of select="$nbsp"/>
</xsl:if>
			<xsl:value-of select="text()[1]"/>
</a>
		</xsl:if>
	
		<!-- next link -->
		<xsl:if test="preceding-sibling::link[1][@href=$href]">
			<xsl:value-of select="$nbsp"/>| Next: <a href="{@href}">
			<xsl:if test="$generate-section-numbers = 'yes'">
			<xsl:number level="multiple" format="{$snf}"/>.<xsl:value-of select="$nbsp"/>
</xsl:if>
			<xsl:value-of select="text()[1]"/>
</a>
		</xsl:if>
	</xsl:for-each>
<br/>
<br/>
</xsl:template>

<!-- 
*************************************************************************
This template renders the stylesheet tag
*************************************************************************
-->
<xsl:template match="stylesheet">
	<link href="{@url}" rel="stylesheet" type="text/css"/>
</xsl:template>

<!-- 
*************************************************************************
This template renders a link to another section
*************************************************************************
-->
<xsl:template match="section-link">
<xsl:variable name="href">
<xsl:choose>
<xsl:when test="contains(@href,'#')">
<xsl:value-of select="concat('#', substring-after(@href, '#'))"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="concat('#', @href)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<a href="{$href}">
<xsl:apply-templates/>
</a>
</xsl:template>

<!-- 
*************************************************************************
This template copies all other elements, except what is matched above as 
it is to the output tree
*************************************************************************
-->
<xsl:template match="*|@*|comment()|text()">
<xsl:copy>
<xsl:apply-templates select="*|@*|comment()|text()"/>
</xsl:copy>
</xsl:template>

<!-- B: SECTION FUNCTIONS -->
<!--
*************************************************************************
Template to get the section no.
*************************************************************************
-->
<xsl:template name="get-section-number">
<xsl:param name="format">
<xsl:value-of select="$snf"/>
</xsl:param>
<xsl:param name="href"/>
<xsl:for-each select="/document/document-body/table-of-content//link[@href = $href]">
<xsl:number level="multiple" format="{$format}"/>.</xsl:for-each>
</xsl:template>

<!--
*************************************************************************
Template to get the section level.
*************************************************************************
-->
<xsl:template name="get-section-level">
<xsl:param name="href"/>
<xsl:for-each select="/document/document-body/table-of-content//link[@href = $href]">
<xsl:variable name="section-number">
<xsl:call-template name="get-section-number">
<xsl:with-param name="href" select="$href"/>
<xsl:with-param name="format">1</xsl:with-param>
</xsl:call-template>
</xsl:variable>
<xsl:variable name="level" select="string-length(translate($section-number, '0123456789',''))"/>
<xsl:value-of select="$level"/>
</xsl:for-each>
</xsl:template>
<!-- E: SECTION FUNCTIONS -->

<!-- B: STRING FUNCTIONS -->
<!-- common space characters -->
<xsl:variable name="lf">
<xsl:text>
</xsl:text>
</xsl:variable>
<xsl:variable name="tab">
<xsl:text>	</xsl:text>
</xsl:variable>
<xsl:variable name="lftab">
<xsl:copy-of select="$lf"/>
<xsl:copy-of select="$tab"/>
</xsl:variable>
<!-- template to replace characters like tab, newline, etc -->
<xsl:template name="make-safe">
<xsl:param name="str"/>
<xsl:variable name="replacement" select="concat('','')"/>
<xsl:variable name="tab-safe">
<xsl:call-template name="replace-text">
<xsl:with-param name="str" select="$str"/>
<xsl:with-param name="replace" select="$tab"/>
<xsl:with-param name="replacement" select="$replacement"/>
</xsl:call-template>
</xsl:variable>
<xsl:variable name="lf-safe">
<xsl:call-template name="replace-text">
<xsl:with-param name="str" select="$tab-safe"/>
<xsl:with-param name="replace" select="$lf"/>
<xsl:with-param name="replacement" select="$replacement"/>
</xsl:call-template>
</xsl:variable>
<xsl:variable name="safe">
<xsl:call-template name="replace-text">
<xsl:with-param name="str" select="$lf-safe"/>
<xsl:with-param name="replace" select="$lftab"/>
<xsl:with-param name="replacement" select="$replacement"/>
</xsl:call-template>
</xsl:variable>
<xsl:value-of select="$safe"/>
</xsl:template>
<!-- template to replace text -->
<xsl:template name="replace-text">
<xsl:param name="str"/>
<xsl:param name="replace"/>
<xsl:param name="replacement"/>
<xsl:choose>
<xsl:when test="contains($str, $replace)">
<xsl:value-of select="concat(substring-before($str, $replace), $replacement)"/>
<xsl:call-template name="replace-text">
<xsl:with-param name="str" select="substring-after($str, $replace)"/>
<xsl:with-param name="replace" select="$replace"/>
<xsl:with-param name="replacement" select="$replacement"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$str"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<!-- E: STRING FUNCTIONS -->
</xsl:stylesheet>
