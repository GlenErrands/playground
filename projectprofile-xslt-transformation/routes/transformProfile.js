var request = require('request');
var xslt = require('node_xslt');
var path = require('path');
var sanitizeHtml = require('sanitize-html');

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
			res.set('Content-Type', response.headers['content-type']);
			var sanitizedHtml = transformToSanitizedHtml(body);
			var transformedDocument = transformXslt(sanitizedHtml, 'transform.xslt');
			res.end(transformedDocument);
			break;
		default:
			// any other
			res.writeHeader(response.statusCode, response.statusMessage);
			res.end();
			return console.log('Invalid Status Code Returned:', response.statusCode, response.statusMessage);
		}
	});
};
