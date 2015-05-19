class UserTagsWorker
  
  def initialize taggable
    @taggable = taggable
  end
  
  def []= user,tags
    @taggable.user_tags.destroy_all user:user
    tags.split("||").each {|tag| @taggable.user_tags.create! name:tag, user:user }
  end
  
  def [] user
    @taggable.user_tags.where(user:user).collect{|tag| tag.name }.join("||")
  end
  
end