module HousesHelper
  def rooms_select_options(rooms)
    rooms.map{|room| [room['name'],room['id']]}
  end
end
