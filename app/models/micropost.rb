class Micropost < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :content, presence: true,
    length: {maximum: Settings.micropost.maximum_length}
  validate  :picture_size

  scope :recent_post, ->{order created_at: :desc}
  scope :feed, (lambda do |following_ids, user_id|
    where "user_id IN (?) OR user_id = ?", following_ids, user_id
  end)

  mount_uploader :picture, PictureUploader

  private

  # Validates the size of an uploaded picture.
  def picture_size
    return if picture.size <= Settings.picture.max_size.megabytes
    errors.add(:picture, t("micropost.picture.max_size"))
  end
end
