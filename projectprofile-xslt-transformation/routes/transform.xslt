<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

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
		<h1>
			<xsl:value-of select="//h1" />
		</h1>
		<xsl:apply-templates select="div/div/div/div[contains(concat(' ', normalize-space(@class), ' '), ' gp-section ')]" />
	</xsl:template>

	<xsl:template match="div[contains(concat(' ', normalize-space(@class), ' '), ' gp-section ') and normalize-space(div/h2)='Projekte']">
		<h2>
			<xsl:value-of select="div/h2" />
		</h2>
		<xsl:apply-templates
			select="div[contains(concat(' ', normalize-space(@class), ' '), ' content ')]/a[starts-with(@id, 'id')][following-sibling::div]" />
	</xsl:template>

	<xsl:template match="a[starts-with(@id, 'id')][following-sibling::div]">
		<xsl:call-template name="render_project">
			<xsl:with-param name="head" select="." />
			<xsl:with-param name="content" select="following-sibling::div[1]" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="render_project">
		<xsl:param name="head" />
		<xsl:param name="content" />

		<xsl:variable name="project-name" select="$head//p[contains(concat(' ', normalize-space(@class), ' '), ' project-name ')]" />
		<xsl:variable name="project-period" select="$head//p[contains(concat(' ', normalize-space(@class), ' '), ' project-period ')]" />
		<xsl:variable name="project-duration" select="$head//p[contains(concat(' ', normalize-space(@class), ' '), ' project-duration ')]" />
		<xsl:variable name="project-location" select="$content//div[normalize-space(text())='Einsatzort']/following-sibling::div" />
		<xsl:variable name="project-role" select="$content//div[normalize-space(text())='Rolle']/following-sibling::div/div" />
		<xsl:variable name="project-tasks" select="$content//div[normalize-space(text())='Aufgaben']/following-sibling::div/div/div" />
		<xsl:variable name="project-skills"
			select="$content//div[normalize-space(text())='Kenntnisse']/following-sibling::div[1]/div/div[@class='gp-tag']/p" />
		<xsl:variable name="project-products"
			select="$content//div[normalize-space(text())='Eingesetzte Produkte']/following-sibling::div/div/div[@class='gp-tag']/p" />
		<xsl:variable name="project-customer-size" select="$content//div[normalize-space(text())='Unternehmensgröße']/following-sibling::div" />
		<xsl:variable name="project-customer-sector" select="$content//div[normalize-space(text())='Branche']/following-sibling::div" />
		<h3>
			<xsl:value-of select="$project-name" />
		</h3>
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
					<xsl:value-of select="." />
					<xsl:if test="position() != last()">
						,
					</xsl:if>
				</xsl:for-each>
			</p>
		</xsl:if>
		<xsl:if test="$project-products">
			<h4>Eingesetzte Produkte</h4>
			<p>
				<xsl:for-each select="$project-products">
					<xsl:value-of select="." />
					<xsl:if test="position() != last()">
						,
					</xsl:if>
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

</xsl:stylesheet> 