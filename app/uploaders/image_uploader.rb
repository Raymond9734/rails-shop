class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include Cloudinary::CarrierWave

  # Choose what kind of storage to use for this uploader
  # Use file storage for development and test, cloudinary for production
  if Rails.env.production?
    # No need to specify storage as Cloudinary handles it
  else
    storage :file unless Rails.env.production? || Rails.env.development?
  end

  # Keep this for local development
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Add a default URL for when no image is uploaded
  def default_url(*args)
    ActionController::Base.helpers.asset_path("fallback/default.png")
  end

  # Create different versions of your uploaded files
  version :thumb do
    process resize_to_fit: [400, 300]
  end

  version :default do
    process resize_to_fit: [800, 600]
  end

  def extension_allowlist
    %w(jpg jpeg gif png)
  end

  # Add cache storage configuration
  def cache_dir
    "tmp/uploads"
  end
end
