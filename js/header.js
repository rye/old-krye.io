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

	{
		panel.chevron = document.createElement('div');
		panel.chevron.classList.add('chevron');

		{
			var ns = 'http://www.w3.org/2000/svg';
			var chevronSvg = document.createElementNS(ns, 'svg');
			chevronSvg.setAttribute('width', '80');
			chevronSvg.setAttribute('height', '20');

			var g = document.createElementNS(ns, 'g');
			g.setAttribute('transform', 'scale(20, 20)');

			var path = document.createElementNS(ns, 'path');
			path.setAttribute('d', 'M0.125 0.125L2.0 0.875L3.875 0.125');
			path.setAttribute('fill', 'none');
			path.setAttribute('stroke', '#aaaaaa');
			path.setAttribute('stroke-width', '0.125');
			path.setAttribute('stroke-linecap', 'round');
			path.setAttribute('stroke-linejoin', 'round');

			g.appendChild(path);
			chevronSvg.appendChild(g);
			panel.chevron.appendChild(chevronSvg);
		}

		panel.appendChild(panel.chevron);
	}

	return panel;
};
