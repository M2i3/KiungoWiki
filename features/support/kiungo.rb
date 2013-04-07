module KiungoHelpers
  
  def select_token(token)
    find('li.token-input-dropdown-item2', text:token).click
    find('li.token-input-token', text:token) # token was selected
  end
  
end

World(KiungoHelpers)