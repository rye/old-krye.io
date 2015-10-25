HTMLCollection.prototype.toArray = function() {
	return [].slice.call(this);
};

Element.prototype.clearChildren = function() {
	while(this.lastChild != null) {
		this.removeChild(this.lastChild);
	}
};

function Site(attrName) {
	var bodies = document.getElementsByTagName("body").toArray();

	this.body = null;

	bodies.forEach(function(body) {
		if(body.getAttribute(attrName) !== null)
			this.body = body;
	}.bind(this));

	this.body.generateGreeting = function() {
		var greeting = "Hi.";

		var element = document.createElement("div");
		element.classList.add("greeting");

		{
			var text = document.createElement("div");
			text.classList.add("text");
			var textNode = document.createTextNode(greeting);
			text.appendChild(textNode);
			element.appendChild(text);
		}

		return element;
	}.bind(this);

	this.body.generateTagline = function() {
		var element = document.createElement("div");
		element.classList.add("tagline");

		{
			var text = document.createElement("div");
			text.classList.add("text");
			text.classList.add("center");

			{
				var iam = document.createElement("span");
				iam.innerHTML = "I am&nbsp;"
				text.appendChild(iam);
			}

			{
				var kristoferRye = document.createElement("span");
				kristoferRye.innerHTML = "Kristofer Rye";
				text.appendChild(kristoferRye);
			}

			element.appendChild(text);
		}

		return element;
	}.bind(this);

	this.body.generateActivity = function(klass, innerHTML) {
		var element = document.createElement("div");
		element.classList.add("activity");
		element.classList.add(klass);

		{
			var text = document.createElement("div");
			text.classList.add("text");

			text.innerHTML = innerHTML;

			element.appendChild(text);
		}

		return element;
	}.bind(this);

	this.body.generateActivities = function() {
		var element = document.createElement("div");
		element.classList.add("activities");

		var codeActivity = this.body.generateActivity("code", "I write code.  <a href=\"https://github.com/rye\" class=\"mega-octicon octicon-mark-github\" />");
		var celloActivity = this.body.generateActivity("cello", "I play the cello.");

		element.appendChild(codeActivity);
		element.appendChild(celloActivity);

		return element;
	}.bind(this);

	this.body.bootstrap = function() {
		this.body.clearChildren();

		this.body.appendChild(this.body.generateGreeting());
		this.body.appendChild(this.body.generateTagline());
		this.body.appendChild(this.body.generateActivities());
	}.bind(this);

	this.body.bootstrap();
};

var SITE = new Site("target");
