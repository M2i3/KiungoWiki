module KiungoHelpers
  
  def select_token(token)
    find('li.token-input-dropdown-item2', text:token).click
    find('li.token-input-token', text:token) # token was selected
  end
  
  def select_fb_token(token)
    find('li.token-input-dropdown-item2-facebook', text:token).click
    find('li.token-input-token-facebook', text:token) # token was selected
  end
  
end

World(KiungoHelpers)