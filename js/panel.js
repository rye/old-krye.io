function Panel(minHeight, classList) {
	var element = document.createElement('div');
	element.minHeight = minHeight;
	element.classList.add('panel');

	classList.forEach(function(cssClass) {
		element.classList.add(cssClass);
	});

	element.style.minHeight = element.minHeight;

	return element;
};
