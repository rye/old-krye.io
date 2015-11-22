HTMLCollection.prototype.toArray = function() {
	return [].slice.call(this);
};

Element.prototype.clearChildren = function() {
	while(this.lastChild != null) {
		this.removeChild(this.lastChild);
	}
};

function Site(attrName) {
	var bodies = document.getElementsByTagName('body').toArray();

	this.body = null;

	bodies.forEach(function(body) {
		if(body.getAttribute(attrName) !== null)
			this.body = body;
	}.bind(this));

	this.body.bootstrap = function() {
		this.body.clearChildren();

		var header = new Header('Kristofer Rye', 'Software Engineer, Private Pilot, Cellist', '80vh', ['header', 'picture']);
		var about = new AboutSection('20vh', ['about']);

		this.body.appendChild(header);
		this.body.appendChild(about);
	}.bind(this);

	this.body.bootstrap();
};

var SITE = new Site('target');
