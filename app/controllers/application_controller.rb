class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
