function Header(name, tagline, minHeight, classList) {
	var panel = new Panel(minHeight, classList);

	{
		panel.text = document.createElement('div');
		panel.text.classList.add('header-text');

		var generateText = function(cssClass, innerHTML) {
			var element = document.createElement('div');
			element.classList.add(cssClass);

			element.innerHTML = innerHTML;

			return element;
		}

		panel.text.appendChild(generateText('name-text', name));
		panel.text.appendChild(generateText('tagline-text', tagline));
		panel.appendChild(panel.text);
	}

	return panel;
};
