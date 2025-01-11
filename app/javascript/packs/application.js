// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import './products';
import './global';


Rails.start()
Turbolinks.start()
ActiveStorage.start()

document.addEventListener('turbolinks:load', () => {
  console.log("Toast JS loaded"); // Debug log
  
  const toasts = document.querySelectorAll('.notification.toast');
  console.log("Found toasts:", toasts.length); // Debug log
  
  toasts.forEach(toast => {
    // Show the toast
    setTimeout(() => {
      toast.classList.add('show');
      console.log("Added show class"); // Debug log
    }, 100);

    // Hide and remove the toast after 5 seconds
    setTimeout(() => {
      toast.classList.remove('show');
      console.log("Removed show class"); // Debug log
      // Remove the element after animation completes
      setTimeout(() => {
        toast.remove();
        console.log("Removed toast"); // Debug log
      }, 500);
    }, 5000);
  });
});
  