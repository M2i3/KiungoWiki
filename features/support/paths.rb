module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name
    when /the home\s?page/
      '/'
    when /a release/
      release_path Release.first
    when /My Music/
      possessions_path
    when /new possession/
      new_possession_path
    when /see works without artists/
      without_artist_works_path
    when /see works without recordings/
      without_recordings_works_path
    when /see works without lyrics/
      without_lyrics_works_path
    when /see works without tags/
      without_tags_works_path
    when /see works without supplementary sections/
      without_supplementary_sections_works_path
    when /see recordings without artists/
      without_artist_recordings_path
    when /see recordings without releases/
      without_releases_recordings_path
    when /see recordings without tags/
      without_tags_recordings_path
    when /see recordings without supplementary sections/
      without_supplementary_sections_recordings_path
    when /see artists without work/
      without_work_artists_path
    when /see artists without releases/
      without_releases_artists_path
    when /see artists without recordings/
      without_recordings_artists_path
    when /see artists without supplementary sections/
      without_supplementary_sections_artists_path
    when /see releases without artists/
      without_artist_releases_path
    when /see releases without recordings/
      without_recordings_releases_path
    when /see releases without supplementary sections/
      without_supplementary_sections_releases_path
    when /users administration/
      admin_users_path
    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
