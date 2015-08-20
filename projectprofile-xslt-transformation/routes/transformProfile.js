var request = require('request');

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
			res.send(body);
			res.end();
			break;
		default:
			// any other
			res.writeHeader(response.statusCode, response.statusMessage);
			res.end();
			return console.log('Invalid Status Code Returned:', response.statusCode, response.statusMessage);
		}
	});
};
