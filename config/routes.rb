KiungoWiki::Application.routes.draw do

  resources :possessions

  resources :changes

  resources :portal_articles

  devise_for :users

  resources :labels, only: :index do
    collection do
      get 'lookup'
    end
  end
  
  resources :works do
    resources :user_tags
    collection do
      get 'lookup'
      get 'portal'
      get 'letter_:letter', action: "alphabetic_index", as: :alphabetic
      get 'recent_changes' #, :action=>"recent_changes", :recent_changes=>1, :as=>:recent_changes
      get 'search'
    end
    member do
      get 'add_supplementary_section'
    end
  end

  resources :artists do
    resources :user_tags
    collection do
      get 'lookup'
      get 'portal'
      get 'letter_:letter', action: "alphabetic_index", as: :alphabetic
      get 'recent_changes' #, :action=>"recent_changes", :recent_changes=>1, :as=>:recent_changes
      get 'search'
      get 'list'
    end
    member do
      get 'add_supplementary_section'
    end
  end

  resources :releases do
    resources :user_tags
    collection do
      get 'lookup'
      get 'portal'
      get 'letter_:letter', action: "alphabetic_index", as: :alphabetic
      get 'recent_changes' #, :action=>"recent_changes", :recent_changes=>1, :as=>:recent_changes
      get 'search'
    end
    member do
      get 'add_supplementary_section'
    end
  end
  
  resources :recordings do
    resources :user_tags
    collection do
      get 'lookup'
      get 'portal'
      get 'letter_:letter', action: "alphabetic_index", as: :alphabetic
      get 'recent_changes' #, :action=>"recent_changes", :recent_changes=>1, :as=>:recent_changes
      get 'search'
    end
    member do
      get 'add_supplementary_section'
    end
  end

  resources :categories do
    collection do
      get 'lookup'
      get 'search'
    end
  end

  match 'search' => 'search#index'
  match 'site_plan' => "home#site_plan"

  root to: "home#index"
end
