class ProjectMembership < ActiveRecord::Base
  belongs_to :person
  belongs_to :project
  has_many :project_bookings

  validates_presence_of :person, :project
end
