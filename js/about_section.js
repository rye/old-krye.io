function AboutSection(minHeight, classList) {
	var panel = new Panel(minHeight, classList);

	{
		panel.header = document.createElement('div');
		panel.header.classList.add('header');

		var generateRibbonData = function(side) {
			var tl = '0 0';
			var tr = '1 0';
			var bl = '0 1';
			var br = '1 1';
			var il = '0.125 0.5';
			var ir = '0.875 0.5';

			switch(side) {
				case 'left':
					return 'M' + tl + 'L' + tr + 'L' + br + 'L' + bl + 'L' + il + 'z';
					break;

				case 'right':
					return 'M' + tl + 'L' + tr + 'L' + ir + 'L' + br + 'L' + bl + 'z';
					break;

				default:
					console.error('Invalid Ribbon Side! (' + side + ')');
			}
		};

		var generateRibbon = function(side) {
			var element = document.createElement('div');
			element.classList.add('ribbon');

			var ns = 'http://www.w3.org/2000/svg';
			var svg = document.createElementNS(ns, 'svg');
			svg.setAttribute('width', '80');
			svg.setAttribute('height', '8');

			var g = document.createElementNS(ns, 'g');
			g.setAttribute('transform', 'scale(80, 8)')

			var path = document.createElementNS(ns, 'path');
			path.setAttribute('d', generateRibbonData(side));
			path.setAttribute('fill', '#aaaaaa');
			path.setAttribute('stroke-width', '0');

			g.appendChild(path);
			svg.appendChild(g);
			element.appendChild(svg);

			return element;
		}

		panel.header.leftRibbon = generateRibbon('left');
		panel.header.rightRibbon = generateRibbon('right');

		panel.header.text = document.createElement('div');
		panel.header.text.classList.add('text');
		panel.header.text.innerHTML = 'About';

		panel.header.appendChild(panel.header.leftRibbon);
		panel.header.appendChild(panel.header.text);
		panel.header.appendChild(panel.header.rightRibbon);
		panel.appendChild(panel.header);
	}

	{
		panel.content = document.createElement('div');
		panel.content.classList.add('content');

		panel.content.text = document.createElement('div');
		panel.content.text.classList.add('text');
		panel.content.text.innerHTML = '[Coming soon, when I get around to stuff.]';

		panel.content.appendChild(panel.content.text);
		panel.appendChild(panel.content);
	}

	return panel;
};
