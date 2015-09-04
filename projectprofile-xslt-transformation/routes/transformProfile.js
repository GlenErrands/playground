var request = require('request');
var xslt = require('node_xslt');
var path = require('path');
var sanitizeHtml = require('sanitize-html');
var xml2js = require('xml2js');
var officeClippy = require('office-clippy');
var docx = officeClippy.docx;

function transformToSanitizedHtml(rawHtml) {
	return sanitizeHtml(rawHtml, {
		allowedTags : [ 'html', 'head', 'title', 'body', 'section', 'h1', 'h2' ].concat([ 'h3', 'h4', 'h5', 'h6',
				'blockquote', 'p', 'a', 'ul', 'ol', 'nl', 'li', 'b', 'i', 'strong', 'em', 'strike', 'code', 'hr', 'br',
				'div', 'table', 'thead', 'caption', 'tbody', 'tr', 'th', 'td', 'pre' ]),
		allowedAttributes : false,
		selfClosing : [ 'img', 'br', 'hr', 'area', 'base', 'basefont', 'input', 'link', 'meta' ],
		allowedSchemes : [ 'http', 'https', 'ftp', 'mailto' ],
		allowedSchemesByTag : {
			img : [ 'http' ]
		},
		transformTags : {
			'section' : function(tagName, attribs) {
				return {
					tagName : 'div',
					attribs : {
						'class' : attribs['class'] + ' section'
					}
				};
			}
		}
	});
}

function transformXslt(source, xsltStylesheetName) {
	var xsltStylesheet = xslt.readXsltFile(path.join(__dirname, xsltStylesheetName));
	var document = xslt.readHtmlString(source);
	return xslt.transform(xsltStylesheet, document, []);
}

function paragraph(text) {
	return docx.createParagraph(text.trim());
}

function forEach(arrayOrElement, handler) {
	if (arrayOrElement) {
		if (Array.isArray(arrayOrElement)) {
			arrayOrElement.forEach(handler);
		} else {
			handler(arrayOrElement);
		}
	}
}

function commaSeparated(arrayOrString) {
	if (Array.isArray(arrayOrString)) {
		return arrayOrString.join(', ');
	} else {
		return arrayOrString;
	}
}

exports.index = function(req, res) {
	var profileUrl = "https://www.gulp.de/gulp2/home/profil/" + encodeURIComponent(req.query.profileName);
	console.log("transforming " + profileUrl);
	var options = {
		uri : profileUrl,
		followRedirect : true,
		jar : true,
	};
	request(options, function(error, response, body) {
		if (error) {
			return console.log('Error:', error);
		}

		switch (response.statusCode) {
		case 200:
			// OK
			res.set('Content-Type', 'application/xml; charset=utf-8');
			var sanitizedHtml = transformToSanitizedHtml(body);
			var transformedDocument = transformXslt(sanitizedHtml, 'transform.xslt');
			xml2js.parseString(transformedDocument, {trim: true, explicitArray: false}, function(err, result) {
				console.log(result);
				var doc = docx.create();
				var profile = result.profile;
				doc.addParagraph(paragraph(profile.title).title());
				var sections = profile.sections.section;
				console.log(sections);
				forEach(sections, function(section) {
					console.log(section.name);
					doc.addParagraph(paragraph(section.name).heading1());
					if (section.position) {
						doc.addParagraph(paragraph('Rollen').heading2());
						forEach(section.position.roles.role, function(role) {
							doc.addParagraph(paragraph(role.name).bullet());
						});
						doc.addParagraph(paragraph('Kommentar').heading2());
						forEach(section.position.comment.paragraph, function(paragraphText) {
							doc.addParagraph(paragraph(paragraphText));
						});
					}
					if (section.sectors) {
						doc.addParagraph(paragraph(section.sectors.paragraph));
					}
					if (section.projects) {
						forEach(section.projects.project, function(project) {
							doc.addParagraph(paragraph(project.name).heading2());
							doc.addParagraph(paragraph(project.period + ' - ' + project.duration));
							doc.addParagraph(paragraph('Einsatzort').heading3());
							doc.addParagraph(paragraph(project.location));
							doc.addParagraph(paragraph('Rolle').heading3());
							doc.addParagraph(paragraph(project.role));
							doc.addParagraph(paragraph('Aufgaben').heading3());
							doc.addParagraph(paragraph(project.tasks));
							if (project.skills.skill) {
								doc.addParagraph(paragraph('Kenntnisse').heading3());
								doc.addParagraph(paragraph(commaSeparated(project.skills.skill)));
							}
							if (project.products.product) {
								doc.addParagraph(paragraph('Eingesetzte Produkte').heading3());
								doc.addParagraph(paragraph(commaSeparated(project.products.product)));
							}
							forEach(project.customer, function(customer) {
								doc.addParagraph(paragraph('Kunde').heading3());
								var customerParagraph = docx.createParagraph();
								if (customer.name) { customerParagraph.addText(docx.createText(customer.name)); }
								if (customer.department) { customerParagraph.addText(docx.createText(customer.department).break()); }
								if (customer.numberOfEmployees) { customerParagraph.addText(docx.createText('Anzahl Mitarbeiter: ' + customer.numberOfEmployees).break()); }
								if (customer.sector) { customerParagraph.addText(docx.createText('Branche: ' + customer.sector).break()); }
								doc.addParagraph(customerParagraph);
							});
						});
					}
					if (section.fieldsOfCompetence) {
						forEach(section.fieldsOfCompetence.fieldOfCompetence, function(fieldOfCompetence) {
							console.log(fieldOfCompetence);
							doc.addParagraph(paragraph(fieldOfCompetence.name).heading2());
							forEach(fieldOfCompetence.skills.skill, function(skill) {
								doc.addParagraph(paragraph(skill.name).bullet());
							});
							forEach(fieldOfCompetence.comment.paragraph, function(p) {
								doc.addParagraph(paragraph(p));
							});
						});
					}
					if (section.furtherEducation) {
						forEach(section.furtherEducation.education, function(education) {
							doc.addParagraph(paragraph(education.name).heading2());
							doc.addParagraph(paragraph(education.period));
							//doc.addParagraph(paragraph(education.duration));
							doc.addParagraph(paragraph(education.degree));
							doc.addParagraph(paragraph(education.institution));
							doc.addParagraph(paragraph(education.focus));
						});
					}
				});
				officeClippy.exporter.express(res, doc, "Profile-" + req.query.profileName);
			});
			//res.end(transformedDocument);
			break;
		default:
			// any other
			res.writeHeader(response.statusCode, response.statusMessage);
			res.end();
			return console.log('Invalid Status Code Returned:', response.statusCode, response.statusMessage);
		}
	});
};
