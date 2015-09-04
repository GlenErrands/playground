<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output 
		method="xml" 
		version="1.0" 
		encoding="utf-8" 
		omit-xml-declaration="no" 
		standalone="yes" 
		doctype-public="xml"
		cdata-section-elements="" 
		indent="yes" 
		media-type="application/xml" />
	<!-- override default text template to avoid output of unexpected text matches -->
	<xsl:template match="/text()" />
	<xsl:strip-space elements="*" />
	
	<xsl:template match="/">
		<xsl:apply-templates select="id('content')" />
	</xsl:template>

	<xsl:template match="id('content')">
		<profile>
			<title><xsl:value-of select="//h1" /></title>
			<sections>
				<xsl:apply-templates select="div[@class='row']/div/div/div[@class='gp-section section']/div[@class='header']/h2" />
			</sections>
		</profile>
	</xsl:template>

	<xsl:template match="h2">
		<section>
			<name><xsl:value-of select="." /></name>
			<xsl:choose>
				<xsl:when test="normalize-space(text())='Projekte'">
					<projects>
						<xsl:apply-templates select="../../div[@class='content']/a[starts-with(@id, 'id')]" mode="project"/>
					</projects>
				</xsl:when>
				<xsl:when test="normalize-space(text())='Position'">
					<position>
						<roles>
							<xsl:for-each select="../../div[@class='content']/div/div/div[@class='medium-8 large-9 column end']">
								<role>
									<name><xsl:value-of select="text()"/></name>
								</role>
							</xsl:for-each>
						</roles>
						<comment>
							<xsl:for-each select="../../div[@class='content']/div/div/div[@class='medium-8 large-9 column left']/p[normalize-space(text())!='&#160;']">
								<paragraph><xsl:value-of select="text()"/></paragraph>
							</xsl:for-each>
						</comment>
					</position>
				</xsl:when>
				<xsl:when test="normalize-space(text())='Branchen'">
					<sectors>
						<xsl:for-each select="../../div[@class='content']/div/div">
							<paragraph><xsl:value-of select="text()"/></paragraph>
						</xsl:for-each>
					</sectors>
				</xsl:when>
				<xsl:when test="normalize-space(text())='Kompetenzen'">
					<fieldsOfCompetence>
						<xsl:apply-templates select="../../div[@class='content']/div/div[@class='add-margin-bottom']/div/div[@class='medium-3 large-3 column'][normalize-space(text())]" mode="skills"/>
					</fieldsOfCompetence>
				</xsl:when>
				<xsl:when test="normalize-space(text())='Aus- und Weiterbildung'">
					<furtherEducation>
						<xsl:apply-templates select="../../div[@class='content']/a[starts-with(@id, 'id')]" mode="education"/>
					</furtherEducation>
				</xsl:when>
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
		</section>
	</xsl:template>

	<xsl:template match="a[starts-with(@id, 'id')]" mode="project">
		<xsl:call-template name="render_project">
			<xsl:with-param name="head" select="." />
			<xsl:with-param name="content" select="following-sibling::div[1]" />
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="a[starts-with(@id, 'id')]" mode="education">
		<xsl:variable name="head" select="." />
		<xsl:variable name="content" select="following-sibling::div[1]" />
		<xsl:variable name="education-name" select="$head//p[contains(concat(' ', normalize-space(@class), ' '), ' project-name ')]" />
		<xsl:variable name="education-period" select="$head//p[contains(concat(' ', normalize-space(@class), ' '), ' project-period ')]" />
		<xsl:variable name="education-duration" select="$head//p[contains(concat(' ', normalize-space(@class), ' '), ' project-duration ')]" />
		<xsl:variable name="education-degree" select="$content//div[normalize-space(text())='Abschluss']/following-sibling::div[1]" />
		<xsl:variable name="education-institution" select="$content//div[normalize-space(text())='Institution, Ort']/following-sibling::div[1]" />
		<xsl:variable name="education-focus" select="$content//div[normalize-space(text())='Schwerpunkt']/following-sibling::div[1]" />
		
		<education>
			<name><xsl:value-of select="$education-name" /></name>
			<period><xsl:value-of select="$education-period" /></period>
			<duration><xsl:value-of select="$education-duration" /></duration>
			<degree><xsl:value-of select="$education-degree" /></degree>
			<institution><xsl:value-of select="$education-institution" /></institution>
			<focus><xsl:value-of select="$education-focus" /></focus>
		</education>
	</xsl:template>
	
	<xsl:template match="div[@class='medium-3 large-3 column'][normalize-space(text())]" mode="skills">
		<fieldOfCompetence>
			<name><xsl:value-of select="."/></name>
			<skills>
				<xsl:apply-templates select="../../div/div[@class='medium-5 large-5 column left']" mode="skills"/>
			</skills>
			<comment>
				<xsl:for-each select="../../div[@class='row collapse'][last()]/div/*[normalize-space(text())!='']">
					<paragraph><xsl:value-of select="."/></paragraph>
				</xsl:for-each>
			</comment>
		</fieldOfCompetence>
	</xsl:template>

	<xsl:template match="div[@class='medium-5 large-5 column left']" mode="skills">
		<skill>
			<name><xsl:value-of select="." /></name>
			<xsl:variable name="comment" select="following-sibling::*[1][normalize-space()]" />
			<xsl:if test="$comment">
				<comment>
					<xsl:value-of select="$comment"/>
				</comment>
			</xsl:if>
		</skill>
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
		<xsl:variable name="project-customer-name" select="$content//div[normalize-space(text())='Kunde']/following-sibling::div" />
		<xsl:variable name="project-customer-department" select="$content//div[normalize-space(text())='Geschäftsstelle']/following-sibling::div" />
		<xsl:variable name="project-customer-size" select="$content//div[normalize-space(text())='Unternehmensgröße']/following-sibling::div" />
		<xsl:variable name="project-customer-sector" select="$content//div[normalize-space(text())='Branche']/following-sibling::div" />
		
		<project>
			<name><xsl:value-of select="$project-name" /></name>
			<period><xsl:value-of select="$project-period" /></period>
			<duration><xsl:value-of select="$project-duration" /></duration>
			<location><xsl:value-of select="$project-location" /></location>
			<role><xsl:value-of select="$project-role" /></role>
			<tasks><xsl:value-of select="$project-tasks" /></tasks>
			<skills>
				<xsl:for-each select="$project-skills">
					<skill><xsl:value-of select="." /></skill>
				</xsl:for-each>
			</skills>			
			<products>
				<xsl:for-each select="$project-products">
					<product><xsl:value-of select="." /></product>
				</xsl:for-each>
			</products>
			<customer>
			    <name><xsl:value-of select="$project-customer-name" /></name>
			    <department><xsl:value-of select="$project-customer-department" /></department>
				<numberOfEmployees><xsl:value-of select="$project-customer-size" /></numberOfEmployees>
				<sector><xsl:value-of select="$project-customer-sector" /></sector>
			</customer>
		</project>
	</xsl:template>
</xsl:stylesheet> 