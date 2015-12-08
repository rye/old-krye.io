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

		{
			panel.content.programmerSection = document.createElement('div');
			panel.content.programmerSection.classList.add('section');

			{
				panel.content.programmerSection.tile = document.createElement('div');
				panel.content.programmerSection.tile.classList.add('tile');

				{
					var programmerSvg = new SiteSVGElement('svg', 'programmer', {
						'height': '100%',
						'width': '100%',
						'viewBox': '0 0 512 512'
					});

					var ns = 'http://www.w3.org/2000/svg';

					{
						var g = new SiteSVGElement('g', 'background', null);

						{
							var circle = new SiteSVGElement('circle', 'outer', {'cx': 256, 'cy': 256, 'r': 224, 'fill': '#888888'});
							g.appendChild(circle);
						}

						{
							var circle = new SiteSVGElement('circle', 'outer', {'cx': 256, 'cy': 256, 'r': 216, 'fill': '#999999'});
							g.appendChild(circle);
						}

						programmerSvg.appendChild(g);
					}

					{
						var g = new SiteSVGElement('g', 'contents', {'transform': 'translate(256 256)'});

						{
							var branchG = new SiteSVGElement('g', 'branch', {
								'stroke': '#444',
								'stroke-width': 8,
								'fill': '#444',
								'fill-opacity': 0.0,
								'transform': 'rotate(-150) translate(128 0) rotate(150)'
							});

							var master = new SiteSVGElement('path', 'master', {'d': 'M0 32 L0 -32'});
							var branch = new SiteSVGElement('path', 'branch', {'d': 'M0 32C0 16 32 16 32 0'});
							var rootCommit = new SiteSVGElement('circle', 'rootCommit', {'cx': 0, 'cy': 36, 'r': 8});
							var masterNextCommit = new SiteSVGElement('circle', 'masterNextCommit', {'cx': 0, 'cy': -36, 'r': 8});
							var forkCommit = new SiteSVGElement('circle', 'forkCommit', {'cx': 32, 'cy': '-4', 'r': 8});

							branchG.appendChild(master);
							branchG.appendChild(branch);
							branchG.appendChild(rootCommit);
							branchG.appendChild(masterNextCommit);
							branchG.appendChild(forkCommit);

							g.appendChild(branchG);
						}

						{
							var toolsG = new SiteSVGElement('g', 'tools', {
								'stroke': '#444',
								'stroke-width': 0,
								'fill': '#444',
								'transform': 'rotate(-30) translate(128 0) rotate(30)'
							});

							var hammer = new SiteSVGElement('g', 'hammer', {
								transform: 'rotate(-45) translate(32 0)'
							});

							var handle = new SiteSVGElement('path', 'handle', {
								d: 'M-88 -8 l0 16 l88 -4 l0 -8'
							});

							var head = new SiteSVGElement('path', 'head', {
								d: 'M0 -4' +
									 ' c   4   0   2 -18  -2 -24' +
									 ' c   6   4   14  8  16  24' +
									 ' c   1   7   0   8   0   8' +
									 ' c  -2   4  -6   6  -4   8' +
									 ' c   4   0   4   4   0   4' +
									 ' l -10   0' +
									 ' c  -4   0  -4  -4   0  -4' +
									 ' c   3  -2   4  -6   0  -8'
							});

							hammer.appendChild(handle);
							hammer.appendChild(head);
							toolsG.appendChild(hammer);
							g.appendChild(toolsG);
						}

						{
							var binaryG = new SiteSVGElement('g', 'tools', {
								'stroke': '#444',
								'stroke-width': 8,
								'stroke-linecap': 'round',
								'fill': '#444',
								'fill-opacity': 0.0,
								'transform': 'rotate(90) translate(128 0) rotate(-90)'
							});

							var topLeft = new SiteSVGElement('path', 'topLeft', {
								transform: 'translate(-16 -16)',
								d: 'M8 -8 L8 8'
							});

							var topRight = new SiteSVGElement('circle', 'topRight', {
								transform: 'translate(16 -16)',
								cx: 8,
								cy: 0,
								r: 8
							});

							var bottomLeft = new SiteSVGElement('circle', 'bottomLeft', {
								transform: 'translate(-16 16)',
								cx: 8,
								cy: 0,
								r: 8
							});

							var bottomRight = new SiteSVGElement('path', 'bottomRight', {
								transform: 'translate(16 16)',
								d: 'M8 -8 L8 8'
							});

							binaryG.appendChild(topLeft);
							binaryG.appendChild(topRight);
							binaryG.appendChild(bottomLeft);
							binaryG.appendChild(bottomRight);

							g.appendChild(binaryG);
						}

						programmerSvg.appendChild(g);
					}

					panel.content.programmerSection.tile.appendChild(programmerSvg);
				}

				panel.content.programmerSection.appendChild(panel.content.programmerSection.tile);
			}

			{
				panel.content.programmerSection.text = document.createElement('div');
				panel.content.programmerSection.text.classList.add('text');

				panel.content.programmerSection.text.innerHTML = 'I am a programmer.'

				panel.content.programmerSection.appendChild(panel.content.programmerSection.text);
			}

			panel.content.appendChild(panel.content.programmerSection);
		}

		panel.appendChild(panel.content);
	}

	return panel;
};
