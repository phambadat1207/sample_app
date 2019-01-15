class StaticPagesController < ApplicationController
  def home
    return unless logged_in?
    @micropost  = current_user.microposts.build
    @feed_items = Micropost.feed(current_user.following_ids, current_user.id)
                           .recent_post
                           .paginate(page: params[:page],
                              per_page: Settings.per_page.microposts)
  end

  def help; end

  def about; end

  def contact; end
end
