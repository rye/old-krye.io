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

	this.generatePanel = function(minHeight, classList) {
		var element = document.createElement('div');
		element.classList.add('panel');

		classList.forEach(function(cssClass) {
			element.classList.add(cssClass);
		});

		element.style.minHeight = minHeight;

		return element;
	}.bind(this);

	this.body.bootstrap = function() {
		this.body.clearChildren();

		var headerPicture = this.generatePanel('20vh', ['header-picture']);

		{
			var headerText = document.createElement('div');
			headerText.classList.add('header-text');

			{
				var headerNameText = document.createElement('div');
				headerNameText.classList.add('name-text');

				headerNameText.innerHTML = 'Kristofer Rye';

				headerText.appendChild(headerNameText);
			}

			{
				var headerTaglineText = document.createElement('div');
				headerTaglineText.classList.add('tagline-text');

				headerTaglineText.innerHTML = 'Software Engineer, Private Pilot, Cellist';

				headerText.appendChild(headerTaglineText);
			}

			headerPicture.appendChild(headerText);
		}

		this.body.appendChild(headerPicture);
	}.bind(this);

	this.body.bootstrap();
};

var SITE = new Site('target');
