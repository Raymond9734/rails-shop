document.addEventListener('turbolinks:load', function() {
    console.log("Mpesa JS loaded");
    
    // Wait a brief moment for the DOM to be fully ready
    setTimeout(() => {
        const form = document.querySelector('form.payment-form');
        console.log("Looking for form:", form);
        
        if (!form) {
            console.log("Payment form not found");
            return;
        }
        
        // Create toast container if it doesn't exist
        let toastContainer = document.querySelector('.toast-container');
        if (!toastContainer) {
            toastContainer = document.createElement('div');
            toastContainer.className = 'toast-container';
            document.body.appendChild(toastContainer);
        }
        
        form.addEventListener('ajax:success', function(event) {
          console.log("Ajax success:", event.detail);
          const [data, status, xhr] = event.detail;
          if (data.status === 'success') {
            // Show success toast
            const toast = document.createElement('div');
            toast.className = 'notification is-success global-notification toast';
            toast.style.cssText = `
              position: fixed;
              top: 20px;
              right: 20px;
              z-index: 9999;
              min-width: 300px;
              opacity: 1;
              padding: 16px;
              border-radius: 4px;
              box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            `;
            toast.innerHTML = `<p>${data.message}</p>`;
            toastContainer.appendChild(toast);
            
            // Clear any cart-related elements from the page
            const cartContainer = document.querySelector('.cart-container');
            if (cartContainer) {
              cartContainer.innerHTML = `
                <div class="has-text-centered py-6">
                  <p class="is-size-4 mb-4">Payment initiated successfully!</p>
                  <p class="mb-4">Please check your phone to complete the payment.</p>
                </div>
              `;
            }
            
            // Redirect after 3 seconds
            setTimeout(() => {
              window.location.href = data.redirect_url;
            }, 3000);
          } else {
            // Show error toast
            const toast = document.createElement('div');
            toast.className = 'notification is-danger global-notification toast';
            toast.style.cssText = `
              position: fixed;
              top: 20px;
              right: 20px;
              z-index: 9999;
              min-width: 300px;
              opacity: 1;
              padding: 16px;
              border-radius: 4px;
              box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            `;
            toast.innerHTML = `<p>${data.message}</p>`;
            toastContainer.appendChild(toast);
          }
        });
      
        form.addEventListener('ajax:error', function(event) {
          console.log("Ajax error:", event);
          const toast = document.createElement('div');
          toast.className = 'notification is-danger global-notification toast';
          toast.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 9999;
            min-width: 300px;
            opacity: 1;
            padding: 16px;
            border-radius: 4px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
          `;
          toast.innerHTML = '<p>An error occurred while processing your payment. Please try again.</p>';
          toastContainer.appendChild(toast);
        });
    }, 100);
});