<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output 
		method="xml" 
		version="1" 
		encoding="utf-8" 
		omit-xml-declaration="no" 
		standalone="yes" 
		doctype-public="xml"
		cdata-section-elements="" 
		indent="no" 
		media-type="application/xml" />
	<!-- override default text template to avoid output of unexpected text matches -->
	<xsl:template match="/text()" />
	<xsl:strip-space elements="*" />
	
	<xsl:template match="/">
		<xsl:apply-templates select="id('content')" />
	</xsl:template>

	<xsl:template match="id('content')">
		<profile>
			<profile-title><xsl:value-of select="//h1" /></profile-title>
			<sections>
				<xsl:apply-templates select="div[@class='row']/div/div/div[@class='gp-section section']/div[@class='header']/h2" />
			</sections>
		</profile>
	</xsl:template>

	<xsl:template match="h2">
		<section>
			<section-name><xsl:value-of select="." /></section-name>
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
									<role-name><xsl:value-of select="text()"/></role-name>
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
					<fields-of-competence>
						<xsl:apply-templates select="../../div[@class='content']/div/div[@class='add-margin-bottom']/div/div[@class='medium-3 large-3 column'][normalize-space(text())]" mode="skills"/>
					</fields-of-competence>
				</xsl:when>
				<xsl:when test="normalize-space(text())='Aus- und Weiterbildung'">
					<further-education>
						<xsl:apply-templates select="../../div[@class='content']/a[starts-with(@id, 'id')]" mode="education"/>
					</further-education>
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
			<education-name><xsl:value-of select="$education-name" /></education-name>
			<education-period><xsl:value-of select="$education-period" /></education-period>
			<education-duration><xsl:value-of select="$education-duration" /></education-duration>
			<education-degree><xsl:value-of select="$education-degree" /></education-degree>
			<education-institution><xsl:value-of select="$education-institution" /></education-institution>
			<education-focus><xsl:value-of select="$education-focus" /></education-focus>
		</education>
	</xsl:template>
	
	<xsl:template match="div[@class='medium-3 large-3 column'][normalize-space(text())]" mode="skills">
		<field-of-competence>
			<field-of-competence-name><xsl:value-of select="."/></field-of-competence-name>
			<skills>
				<xsl:apply-templates select="../../div/div[@class='medium-5 large-5 column left']" mode="skills"/>
			</skills>
			<comment>
				<xsl:for-each select="../../div[@class='row collapse'][last()]/div/*[normalize-space(text())!='']">
					<paragraph><xsl:value-of select="."/></paragraph>
				</xsl:for-each>
			</comment>
		</field-of-competence>
	</xsl:template>

	<xsl:template match="div[@class='medium-5 large-5 column left']" mode="skills">
		<skill>
			<skill-name><xsl:value-of select="." /></skill-name>
			<xsl:variable name="comment" select="following-sibling::*[1][normalize-space()]" />
			<xsl:if test="$comment">
				<skill-comment>
					<xsl:value-of select="$comment"/>
				</skill-comment>
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
		
		<project-name><xsl:value-of select="$project-name" /></project-name>
		<project-period><xsl:value-of select="$project-period" /></project-period>
		<project-duration><xsl:value-of select="$project-duration" /></project-duration>
		<project-location><xsl:value-of select="$project-location" /></project-location>
		<project-role><xsl:value-of select="$project-role" /></project-role>
		<project-tasks><xsl:value-of select="$project-tasks" /></project-tasks>
		<project-skills>
			<xsl:for-each select="$project-skills">
				<project-skill><xsl:value-of select="." /></project-skill>
			</xsl:for-each>
		</project-skills>			
		<project-products>
			<xsl:for-each select="$project-products">
				<project-product><xsl:value-of select="." /></project-product>
			</xsl:for-each>
		</project-products>
		<project-customer>
		    <customer-name><xsl:value-of select="$project-customer-name" /></customer-name>
		    <customer-department><xsl:value-of select="$project-customer-department" /></customer-department>
			<number-of-employees><xsl:value-of select="$project-customer-size" /></number-of-employees>
			<customer-sector><xsl:value-of select="$project-customer-sector" /></customer-sector>
		</project-customer>
	</xsl:template>
</xsl:stylesheet> 