var trianglifyPattern = Trianglify({
	width: 2048,
	height: 2048,
	cell_size: 128,
	seed: '19sadgwje',
	x_colors: 'Blues'
});

var trianglifyTargets = [].slice.call(document.querySelectorAll('.trianglify-me'));

console.debug(trianglifyTargets);

var svg = trianglifyPattern.svg();
svg.setAttribute('xmlns', 'http://www.w3.org/2000/svg');

trianglifyTargets.forEach(function(e) {
	e.style.backgroundImage = "linear-gradient(rgba(0,0,0,0.6),rgba(0,0,0,0.5)), url('data:image/svg+xml;base64," + window.btoa(svg.outerHTML) + "')";
});
