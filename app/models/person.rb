class Person < ActiveRecord::Base
  has_many :worked_on
  has_many :projects, :through => :worked_on
end
