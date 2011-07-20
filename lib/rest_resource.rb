require 'active_resource'
module KiungoAPI
  class Recording < ActiveResource::Base
    self.site = "http://localhost:3000/"
    self.primary_key = "_id"
  end 


  def self.demo
    r = Recording.new
    r.work_name = "Un enregistrement de test"
    r.duration = 123
    r.save

    puts "le id du nouvel enregistrement est #{r.id} il est a la version #{r.version}"


    r1 = Recording.find(r.id)
    r1.location = "Montreal"    

    r1.save

    puts "l'enregistrement est sauvegarde et il est maintenant a la version #{r1.version}"


    # l'enregistrement est détruit
    r1.destroy


  end
end
