// Allocate a blank image for background loading.
var internalImage = new Image();

// Locate our background div.
var landingBackgroundDiv = document.querySelector('.landing-background');

// Prior to setting up callbacks and firing things off, we should first
// make sure that the landing background is prepared.
landingBackgroundDiv.style.opacity = 0.0;

internalImage.onload = function() {
	// Set the image background value before changing the opacity.
	landingBackgroundDiv.style.backgroundImage = "url('" + internalImage.src + "')";
	landingBackgroundDiv.style.opacity = 1.0;
};

// Specify our image and get things rolling.
internalImage.src = 'Header Background.jpg';
