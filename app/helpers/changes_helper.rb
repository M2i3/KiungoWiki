module ChangesHelper
  def change_description(change)
    change.change_type.to_s
  end
end
