module KiungoHelpers
  
  def select_token(token)
    find('li.token-input-dropdown-item2-facebook', text:token).click
    find('li.token-input-token-facebook', text:token) # token was selected
  end
  
end

World(KiungoHelpers)