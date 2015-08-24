var request = require('request');
var xslt = require('node_xslt');
var path = require('path');
var sanitizeHtml = require('sanitize-html');

exports.index = function(req, res) {
	var profileUrl = "https://www.gulp.de/gulp2/home/profil/" + encodeURIComponent(req.body.profileName);
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
			var xsltStylesheet = xslt.readXsltFile(path.join(__dirname, 'transform.xslt'));
			var sanitizedBody = sanitizeHtml(body, {
				allowedTags : [ 'html', 'head', 'title', 'body', 'section', 'h1', 'h2' ].concat([ 'h3', 'h4', 'h5', 'h6',
						'blockquote', 'p', 'a', 'ul', 'ol', 'nl', 'li', 'b', 'i', 'strong', 'em', 'strike', 'code', 'hr', 'br',
						'div', 'table', 'thead', 'caption', 'tbody', 'tr', 'th', 'td', 'pre' ]),
				allowedAttributes : false,
				// allowedAttributes: {
				// a: [ 'href', 'name', 'target' ],
				// // We don't currently allow img itself by default,
				// but this
				// // would make sense if we did
				// img: [ 'src' ]
				// },
				// Lots of these won't come up by default because we
				// don't allow them
				selfClosing : [/* 'section' */]
						.concat([ 'img', 'br', 'hr', 'area', 'base', 'basefont', 'input', 'link', 'meta' ]),
				// URL schemes we permit
				allowedSchemes : [ 'http', 'https', 'ftp', 'mailto' ],
				// Be more specific about allowed schemes
				// for a certain tag
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
			// console.log(sanitizedBody);
			var htmlDocument = xslt.readHtmlString(sanitizedBody);
			var transformedDocument = xslt.transform(xsltStylesheet, htmlDocument, []);
			res.set('Content-Type', response.headers['content-type']);
			res.end(transformedDocument);
			// res.end(sanitizedBody);
			break;
		default:
			// any other
			res.writeHeader(response.statusCode, response.statusMessage);
			res.end();
			return console.log('Invalid Status Code Returned:', response.statusCode, response.statusMessage);
		}
	});
};
