var internalImage = new Image();
var landingBackgroundDiv = document.querySelector('.landing-background');

// Prior to setting up callbacks and firing things off, we should first
// make sure that the landing background is prepared.
landingBackgroundDiv.style.opacity = 0.0;

internalImage.onload = function() {
	landingBackgroundDiv.style.backgroundImage = "url('" + internalImage.src + "')";
	landingBackgroundDiv.style.opacity = 1.0;
};

internalImage.src = 'Header Background.jpg';
