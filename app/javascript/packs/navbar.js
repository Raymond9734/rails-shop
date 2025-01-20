const initializeNavbar = () => {
  // Get all "navbar-burger" elements
  const $navbarBurgers = Array.prototype.slice.call(document.querySelectorAll('.navbar-burger'), 0);

  // Add a click event on each of them
  $navbarBurgers.forEach(el => {
    // Remove any existing click event listeners first
    el.removeEventListener('click', burgerClickHandler);
    // Add the new click event listener
    el.addEventListener('click', burgerClickHandler);
  });
};

const burgerClickHandler = function() {
  // Get the target from the "data-target" attribute
  const target = this.dataset.target;
  const $target = document.getElementById(target);

  // Toggle the "is-active" class on both the "navbar-burger" and the "navbar-menu"
  this.classList.toggle('is-active');
  $target.classList.toggle('is-active');
};

// Initialize on both DOMContentLoaded and turbolinks:load
document.addEventListener('DOMContentLoaded', initializeNavbar);
document.addEventListener('turbolinks:load', initializeNavbar); 