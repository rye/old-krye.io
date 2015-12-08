function SiteSVGElement(name, id, attributes) {
	this.ns = 'http://www.w3.org/2000/svg';
	var element = document.createElementNS(this.ns, name);

	element.setAttribute('id', id);

	if(attributes) {

		Object.keys(attributes).forEach(function(key) {
			var value = attributes[key];
			element.setAttribute(key, value);
		});

	}

	return element;
}
