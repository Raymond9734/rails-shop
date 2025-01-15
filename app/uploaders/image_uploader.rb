class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Add a default URL for when no image is uploaded
  def default_url(*args)
    ActionController::Base.helpers.asset_path("fallback/default.png")
  end

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
