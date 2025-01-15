document.addEventListener('DOMContentLoaded', () => {
  const dragDropArea = document.getElementById('drag-drop-area');
  const fileInput = document.getElementById('file-input');
  const fileNameDisplay = document.getElementById('file-name');
  const imagePreview = document.getElementById('image-preview');

  if (!dragDropArea || !fileInput || !fileNameDisplay || !imagePreview) {
    console.error('One or more elements are missing in the DOM.');
    return;
  }

  function createUploadElements() {
    // Create upload elements
    const uploadIcon = document.createElement('i');
    uploadIcon.className = 'fa fa-cloud-upload drag-drop-icon';
    const uploadText = document.createElement('p');
    uploadText.className = 'drag-drop-text';
    uploadText.textContent = 'Drag & drop your files here';
    const uploadSubtext = document.createElement('p');
    uploadSubtext.className = 'drag-drop-subtext';
    uploadSubtext.textContent = 'or click to upload';
    
    // Clear any existing upload elements first
    const existingElements = dragDropArea.querySelectorAll('.drag-drop-icon, .drag-drop-text, .drag-drop-subtext');
    existingElements.forEach(el => el.remove());
    
    // Add new elements
    dragDropArea.insertBefore(uploadSubtext, fileInput);
    dragDropArea.insertBefore(uploadText, uploadSubtext);
    dragDropArea.insertBefore(uploadIcon, uploadText);
  }

  function resetImagePreview() {
    imagePreview.innerHTML = '';
    fileInput.value = '';
    fileNameDisplay.textContent = 'No file selected';
    imagePreview.style.display = 'none';
    document.getElementById('remove-image-field').value = '1';
    createUploadElements();
  }

  // Handle file processing and preview
  function handleFiles(files) {
    const file = files[0];
    if (file && file.type.startsWith('image/')) {
      fileNameDisplay.textContent = file.name;
      document.getElementById('remove-image-field').value = '0'; // Reset remove flag when new image is uploaded

      // Clear existing preview first
      imagePreview.style.display = 'block';
      imagePreview.innerHTML = '';

      // Create a preview of the image
      const reader = new FileReader();
      reader.onload = (e) => {
        const img = document.createElement('img');
        img.src = e.target.result;
        img.alt = 'Uploaded Image';
        img.style.maxWidth = '100%';

        const closeIcon = document.createElement('span');
        closeIcon.className = 'close-icon';
        closeIcon.innerHTML = '&times;';
        closeIcon.addEventListener('click', resetImagePreview);

        imagePreview.appendChild(img);
        imagePreview.appendChild(closeIcon);

        // Remove upload elements when showing preview
        const uploadElements = dragDropArea.querySelectorAll('.drag-drop-icon, .drag-drop-text, .drag-drop-subtext');
        uploadElements.forEach(el => el.remove());
      };
      reader.readAsDataURL(file);
    } else {
      alert('Please upload an image file (JPG, PNG, etc.)');
      resetImagePreview();
    }
  }

  // Create initial upload elements
  function createUploadElements() {
    // Create upload elements
    const uploadIcon = document.createElement('i');
    uploadIcon.className = 'fa fa-cloud-upload drag-drop-icon';
    const uploadText = document.createElement('p');
    uploadText.className = 'drag-drop-text';
    uploadText.textContent = 'Drag & drop your files here';
    const uploadSubtext = document.createElement('p');
    uploadSubtext.className = 'drag-drop-subtext';
    uploadSubtext.textContent = 'or click to upload';
    
    // Clear any existing upload elements first
    const existingElements = dragDropArea.querySelectorAll('.drag-drop-icon, .drag-drop-text, .drag-drop-subtext');
    existingElements.forEach(el => el.remove());
    
    // Add new elements
    dragDropArea.insertBefore(uploadSubtext, fileInput);
    dragDropArea.insertBefore(uploadText, uploadSubtext);
    dragDropArea.insertBefore(uploadIcon, uploadText);
  }

  // Create initial upload elements if no image is present
  if (!imagePreview.querySelector('img')) {
    createUploadElements();
  }

  // Handle dropped files
  dragDropArea.addEventListener('drop', (e) => {
    e.preventDefault();
    e.stopPropagation();
    dragDropArea.classList.remove('highlight');
    
    const dt = e.dataTransfer;
    const files = dt.files;
    
    if (files.length > 0) {
      fileInput.files = files;
      handleFiles(files);
    }
  });

  // Handle file input change
  fileInput.addEventListener('change', () => {
    if (fileInput.files.length > 0) {
      handleFiles(fileInput.files);
    }
  });

  // Prevent default drag behaviors
  ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
    dragDropArea.addEventListener(eventName, (e) => {
      e.preventDefault();
      e.stopPropagation();
    });
  });

  // Highlight drop area when item is dragged over it
  ['dragenter', 'dragover'].forEach(eventName => {
    dragDropArea.addEventListener(eventName, () => dragDropArea.classList.add('highlight'));
  });

  ['dragleave', 'drop'].forEach(eventName => {
    dragDropArea.addEventListener(eventName, () => dragDropArea.classList.remove('highlight'));
  });

  // Add click handler to existing close icon if present
  const existingCloseIcon = document.querySelector('.close-icon');
  if (existingCloseIcon) {
    existingCloseIcon.addEventListener('click', (e) => {
      e.preventDefault();
      e.stopPropagation();
      resetImagePreview();
      document.getElementById('remove-image-field').value = '1';
    });
  }
});
console.log("Products.js loaded");