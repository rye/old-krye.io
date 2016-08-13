trianglifyTargets = document.querySelectorAll('.trianglify-target')

trianglifyTargets.forEach (element) ->
	parameter = {}

	parameter.width = parseInt(element.dataset.width) if element.dataset.width
	parameter.height = parseInt(element.dataset.height) if element.dataset.height

	parameter.cell_size = parseInt(element.dataset.cell_size) if element.dataset.cell_size
	parameter.variance = parseFloat(element.dataset.variance) if element.dataset.variance
	parameter.seed = seed if element.dataset.seed

	parameter.x_colors = element.dataset.x_colors	if element.dataset.x_colors
	parameter.y_colors = element.dataset.y_colors if element.dataset.y_colors
	parameter.color_space = element.dataset.color_space if element.dataset.color_space
	parameter.color_function = element.dataset.color_function if element.dataset.color_function
	parameter.stroke_width = parseFloat(element.dataset.stroke_width) if element.dataset.stroke_width

	__trianglifier__ = Trianglify(parameter)

	svg = __trianglifier__.svg()
	svg.setAttribute('xmlns', 'http://www.w3.org/2000/svg')

	first_stop = 'rgba(0, 0, 0, 0.75)'
	last_stop = 'rgba(0, 0, 0, 0.6)'

	linear_gradient = "linear-gradient(#{first_stop}, #{last_stop})"

	svg_data_url = "url('data:image/svg+xml;base64,#{window.btoa(svg.outerHTML)}')";

	element.style.backgroundImage = "#{linear_gradient}, #{svg_data_url}"
