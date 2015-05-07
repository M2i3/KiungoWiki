class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  ## Database authenticatable
  field :email,              type: String#, null: false
  field :encrypted_password, type: String#, null: false

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Encryptable
  # field :password_salt, :type => String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  # Token authenticatable
  # field :authentication_token, :type => String

  ## Invitable
  # field :invitation_token, :type => String


  field :nickname
  validates_uniqueness_of :nickname 
  validates_presence_of :nickname

  field :groups, type: Array, default: ["user"]

  embeds_many :release_wiki_links, as: :linkable
  accepts_nested_attributes_for :release_wiki_links
  validates_associated :release_wiki_links
  
  has_many :possessions, foreign_key: "owner_id", dependent: :destroy
  has_many :labels, dependent: :destroy
  has_many :user_tags, dependent: :destroy

  # TODO: Check if that release_wiki_links isn't dead code
  #
  def release_wiki_links_text
    release_wiki_links.collect{|v| v.reference_text }.join(",")
  end

  def release_wiki_links_combined_links
    release_wiki_links.collect{|v| v.combined_link }
  end

  def release_wiki_links_text=(value)
    self.release_wiki_links.reverse.each{|a| a.destroy} #TODO find a way to do it at large since the self.release_wiki_links.clear does not work
    value.split(",").uniq.each{|q| 
      self.release_wiki_links.build(:reference_text=>q.strip) 
    }    
  end
  
  def groups_text
    self.groups.join(", ")
  end

  def groups_text=(value)
    self.groups.clear
    value.split(",").collect{|g| g.strip }.uniq.each{|q| 
      self.groups << q
    }    
  end
  
  def tokenized_groups
    tokenized = []
    self.groups.each {|group| tokenized << {id:group, name:group}}
    tokenized.to_json
  end
  
  
  class << self
    def groups
      ["user", "reviewer", "super-admin"]
    end
  end
end
