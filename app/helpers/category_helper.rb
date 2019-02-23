module CategoryHelper
  def categories_for_select(categories)
    categories.pluck(:name, :id)
  end
end