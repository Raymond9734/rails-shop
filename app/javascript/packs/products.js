document.addEventListener('DOMContentLoaded', () => {
  const dragDropArea = document.getElementById('drag-drop-area');
  const fileInput = document.getElementById('file-input');
  const fileNameDisplay = document.getElementById('file-name');
  const imagePreview = document.getElementById('image-preview');

  if (!dragDropArea || !fileInput || !fileNameDisplay || !imagePreview) {
    console.error('One or more elements are missing in the DOM.');
    return;
  }

  // Prevent default drag behaviors
  ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
    dragDropArea.addEventListener(eventName, preventDefaults, false);
  });

  function preventDefaults(e) {
    e.preventDefault();
    e.stopPropagation();
  }

  // Highlight drop area when item is dragged over it
  ['dragenter', 'dragover'].forEach(eventName => {
    dragDropArea.addEventListener(eventName, () => dragDropArea.classList.add('highlight'), false);
  });

  ['dragleave', 'drop'].forEach(eventName => {
    dragDropArea.addEventListener(eventName, () => dragDropArea.classList.remove('highlight'), false);
  });

  // Handle dropped files
  dragDropArea.addEventListener('drop', handleDrop, false);

  function handleDrop(e) {
    const files = e.dataTransfer.files;
    if (files.length > 0) {
      fileInput.files = files;
      handleFiles(files);
    }
  }

  // Handle file input change
  fileInput.addEventListener('change', () => {
    if (fileInput.files.length > 0) {
      handleFiles(fileInput.files);
    }
  });

   // Open file dialog when the drag-drop area is clicked
   function openFileInput() {
    if (!imagePreview.querySelector('img')) {
      fileInput.click();
    }
  }

  // Handle file processing and preview
  function handleFiles(files) {
    const file = files[0];
    if (file && file.type.startsWith('image/')) {
      fileNameDisplay.textContent = file.name;

      // Create a preview of the image
      const reader = new FileReader();
      reader.onload = (e) => {
        console.log('FileReader result:', e.target.result); // Debugging
        imagePreview.innerHTML = '';

        const img = document.createElement('img');
        img.src = e.target.result;
        img.alt = 'Uploaded Image';

        const closeIcon = document.createElement('span');
        closeIcon.className = 'close-icon';
        closeIcon.innerHTML = '&times;';
        closeIcon.addEventListener('click', () => {
          imagePreview.innerHTML = '';
          fileInput.value = '';
          fileNameDisplay.textContent = 'No file selected';
          imagePreview.style.display = 'none';
        });

        imagePreview.appendChild(img);
        imagePreview.appendChild(closeIcon);
        imagePreview.style.display = 'block';
      };
      reader.readAsDataURL(file);
    } else {
      fileNameDisplay.textContent = 'Invalid file type. Please upload an image.';
      imagePreview.style.display = 'none';
    }
  }
});
console.log("Products.js loaded");