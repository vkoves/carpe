module Profile
  extend ActiveSupport::Concern

  REGEX_VALID_URL_CHARACTERS = /\A[a-zA-Z0-9_\-]*\Z/
  REGEX_ID = /\A\d+\Z/

  included do
    validates :custom_url,
              format: { with: REGEX_VALID_URL_CHARACTERS,
                        message: 'must be alphanumeric' },
              allow_blank: true,
              uniqueness: true,
              length: { maximum: 64 }

    # Record ids are used for routing by default, so they can't be used in a custom url.
    validates :custom_url,
              format: { without: REGEX_ID,
                        message: 'cannot be an integer'}

    has_attached_file :avatar, *Rails.application.config.paperclip_avatar_settings
    validates_attachment :avatar, Rails.application.config.paperclip_avatar_validations

    has_attached_file :banner, *Rails.application.config.paperclip_banner_settings
    validates_attachment :banner, Rails.application.config.paperclip_banner_validations

    after_validation :clean_paperclip_errors
  end

  class_methods do
    def from_param(param)
      self.find_by!(param.is_int? ? { id: param } : { custom_url: param })
    end
  end

  def has_custom_url?
    !custom_url.blank?
  end

  def clean_paperclip_errors
    # Remove avatar/banner file size error if the avatar/banner error's exist
    errors.delete(:avatar_file_size) unless errors[:avatar].empty?
    errors.delete(:banner_file_size) unless errors[:banner].empty?
  end

  # defaults to 'mm', which is a silhouette of a man.
  def gravatar_url(size)
    "https://www.gravatar.com/avatar/?default=mm&size=#{size}"
  end
end