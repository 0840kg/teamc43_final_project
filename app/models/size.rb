class Size < ApplicationRecord

has_many :category_sizes
has_many :categories, through: :category_sizes
end
