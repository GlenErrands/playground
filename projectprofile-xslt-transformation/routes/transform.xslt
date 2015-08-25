<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output 
		method="html" 
		version="1" 
		encoding="utf-8" 
		omit-xml-declaration="yes" 
		standalone="yes" 
		doctype-public="html"
		cdata-section-elements="" 
		indent="no" 
		media-type="text/html" />
	<!-- override default text template to avoid output of unexpected text matches -->
	<xsl:template match="/text()" />
	<xsl:strip-space elements="*" />
	
	<xsl:template match="/">
		<html>
			<head>
				<xsl:apply-templates select="id('content')" mode="head" />
			</head>
			<body>
				<xsl:apply-templates select="id('content')" mode="body" />
			</body>
		</html>
	</xsl:template>

	<xsl:template match="id('content')" mode="head">
		<title>
			<xsl:value-of select="//h1" />
		</title>
	</xsl:template>

	<xsl:template match="id('content')" mode="body">
		<h1><xsl:value-of select="//h1" /></h1>
		<xsl:apply-templates select="div[@class='row']/div/div/div[@class='gp-section section']/div[@class='header']/h2" />
	</xsl:template>

	<xsl:template match="h2">
		<h2><xsl:value-of select="." /></h2>
		<xsl:choose>
			<xsl:when test="normalize-space(text())='Projekte'">
				<xsl:apply-templates select="../../div[@class='content']/a[starts-with(@id, 'id')]" mode="project"/>
			</xsl:when>
			<xsl:when test="normalize-space(text())='Position'">
				<h3>Rollen</h3>
				<ul>
					<xsl:for-each select="../../div[@class='content']/div/div/div[@class='medium-8 large-9 column end']">
						<li><xsl:value-of select="text()"/></li>
					</xsl:for-each>
				</ul>
				<h3>Kommentar</h3>
				<xsl:for-each select="../../div[@class='content']/div/div/div[@class='medium-8 large-9 column left']/p[normalize-space(text())!='&#160;']">
					<p><xsl:value-of select="text()"/></p>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="normalize-space(text())='Branchen'">
				<xsl:for-each select="../../div[@class='content']/div/div">
					<p><xsl:value-of select="text()"/></p>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="normalize-space(text())='Kompetenzen'">
				<xsl:apply-templates select="../../div[@class='content']/div/div[@class='add-margin-bottom']/div/div[@class='medium-3 large-3 column'][normalize-space(text())]" mode="kompetenzen"/>
			</xsl:when>
			<xsl:when test="normalize-space(text())='Aus- und Weiterbildung'">
				<xsl:apply-templates select="../../div[@class='content']/a[starts-with(@id, 'id')]" mode="aus-und-weiterbildung"/>
			</xsl:when>
			<xsl:otherwise></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="a[starts-with(@id, 'id')]" mode="project">
		<xsl:call-template name="render_project">
			<xsl:with-param name="head" select="." />
			<xsl:with-param name="content" select="following-sibling::div[1]" />
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="a[starts-with(@id, 'id')]" mode="aus-und-weiterbildung">
		<xsl:variable name="head" select="." />
		<xsl:variable name="content" select="following-sibling::div[1]" />
		<xsl:variable name="project-name" select="$head//p[contains(concat(' ', normalize-space(@class), ' '), ' project-name ')]" />
		<xsl:variable name="project-period" select="$head//p[contains(concat(' ', normalize-space(@class), ' '), ' project-period ')]" />
		<xsl:variable name="project-duration" select="$head//p[contains(concat(' ', normalize-space(@class), ' '), ' project-duration ')]" />
		<xsl:variable name="project-abschluss" select="$content//div[normalize-space(text())='Abschluss']/following-sibling::div[1]" />
		<xsl:variable name="project-institution" select="$content//div[normalize-space(text())='Institution, Ort']/following-sibling::div[1]" />
		<xsl:variable name="project-focus" select="$content//div[normalize-space(text())='Schwerpunkt']/following-sibling::div[1]" />
		
		<h3><xsl:value-of select="$project-name" /></h3>
		<p>
			<xsl:value-of select="$project-period" />
		</p>
		<p>
			<xsl:value-of select="$project-duration" />
		</p>
		<h4>Abschluss</h4>
		<p>
			<xsl:value-of select="$project-abschluss" />
		</p>
		<h4>Institution, Ort</h4>
		<p>
			<xsl:value-of select="$project-institution" />
		</p>
		<h4>Schwerpunkt</h4>
		<p>
			<xsl:value-of select="$project-focus" />
		</p>
	</xsl:template>
	
	<xsl:template match="div[@class='medium-3 large-3 column'][normalize-space(text())]" mode="kompetenzen">
		<h3><xsl:value-of select="."/></h3>
		<ul>
			<xsl:apply-templates select="../../div/div[@class='medium-5 large-5 column left']" mode="kompetenzen"/>
		</ul>
		<xsl:for-each select="../../div[@class='row collapse'][last()]/div/*[normalize-space(text())!='']">
			<p><xsl:value-of select="."/></p>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="div[@class='medium-5 large-5 column left']" mode="kompetenzen">
		<li>
			<xsl:value-of select="." />
			<xsl:variable name="comment" select="following-sibling::*[1][normalize-space()]" />
			<xsl:if test="$comment"> (<xsl:value-of select="$comment"/>)</xsl:if>
		</li>
	</xsl:template>

	<xsl:template name="render_project">
		<xsl:param name="head" />
		<xsl:param name="content" />

		<xsl:variable name="project-name" select="$head//p[contains(concat(' ', normalize-space(@class), ' '), ' project-name ')]" />
		<xsl:variable name="project-period" select="$head//p[contains(concat(' ', normalize-space(@class), ' '), ' project-period ')]" />
		<xsl:variable name="project-duration" select="$head//p[contains(concat(' ', normalize-space(@class), ' '), ' project-duration ')]" />
		<xsl:variable name="project-location" select="$content//div[normalize-space(text())='Einsatzort']/following-sibling::div[1]" />
		<xsl:variable name="project-role" select="$content//div[normalize-space(text())='Rolle']/following-sibling::div[1]/div" />
		<xsl:variable name="project-tasks" select="$content//div[normalize-space(text())='Aufgaben']/following-sibling::div[1]/div/div" />
		<xsl:variable name="project-skills" select="$content//div[normalize-space(text())='Kenntnisse']/following-sibling::div[1]/div/div[@class='gp-tag']/p" />
		<xsl:variable name="project-products" select="$content//div[normalize-space(text())='Eingesetzte Produkte']/following-sibling::div/div/div[@class='gp-tag']/p" />
		<xsl:variable name="project-customer-size" select="$content//div[normalize-space(text())='Unternehmensgröße']/following-sibling::div" />
		<xsl:variable name="project-customer-sector" select="$content//div[normalize-space(text())='Branche']/following-sibling::div" />
		
		<h3><xsl:value-of select="$project-name" /></h3>
		<p>
			<xsl:value-of select="$project-period" />
		</p>
		<p>
			<xsl:value-of select="$project-duration" />
		</p>
		<h4>Einsatzort</h4>
		<p>
			<xsl:value-of select="$project-location" />
		</p>
		<h4>Rolle</h4>
		<p>
			<xsl:value-of select="$project-role" />
		</p>
		<h4>Aufgaben</h4>
		<p>
			<xsl:value-of select="$project-tasks" />
		</p>
		<xsl:if test="$project-skills">
			<h4>Kenntnisse</h4>
			<p>
				<xsl:for-each select="$project-skills">
					<xsl:value-of select="." /><xsl:if test="position() != last()">, </xsl:if>
				</xsl:for-each>
			</p>
		</xsl:if>
		<xsl:if test="$project-products">
			<h4>Eingesetzte Produkte</h4>
			<p>
				<xsl:for-each select="$project-products">
					<xsl:value-of select="." /><xsl:if test="position() != last()">, </xsl:if>
				</xsl:for-each>
			</p>
		</xsl:if>
		<xsl:if test="$project-customer-size or $project-customer-sector">
			<h4>Kunde</h4>
			<xsl:if test="$project-customer-size">
				<h5>Unternehmensgröße</h5>
				<p>
					<xsl:value-of select="$project-customer-size" />
				</p>
			</xsl:if>
			<xsl:if test="$project-customer-sector">
				<h5>Branche</h5>
				<p>
					<xsl:value-of select="$project-customer-sector" />
				</p>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<!-- <xsl:template match="div[contains(concat(' ', normalize-space(@class), ' '), ' gp-section ') and div/h2]"></xsl:template> -->
</xsl:stylesheet> 