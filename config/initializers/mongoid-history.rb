# initializer for mongoid-history
# defaulting tracker for all monitored 
Mongoid::History.tracker_class_name = :change
Mongoid::History.current_user_method = :current_user
