class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_language  

  private
  def set_language
    # by priorities (in the code last to first)
    # 1. established in the URL
    # 2. established by the user profile
    # 3. detected onto the browser
    # 4. default for the site (and if all else fails)

    # 4.
    request_language = KiungoWiki::Application.config.i18n.default_locale
    @language_source = :default

    # 3.look for Gem http_accept_language
    request_language = request.preferred_language_from(%w{en fr})
    @language_source = :http_header

    # 2.
    if current_user && current_user.locale
      request_language = current_user.locale
      @language_source = :profile
    end

    # 1.
    if params[:lang] && params[:lang] != request_language.to_s
      request_language = params[:lang]
      @language_source = :params
    end


    I18n.locale = request_language
  end

  def default_url_options(options={})
    if @language_source == :params
      {:lang => I18n.locale}
    else  
      {}
    end
  end
end
