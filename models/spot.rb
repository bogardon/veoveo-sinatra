class Spot < ActiveRecord::Base
  belongs_to :user
  has_many :answers, :dependent => :destroy

  attr_accessible :latitude, :longitude, :hint

  def self.in_region(region)
    latitude_range = (region['latitude'].to_f-region['latitude_delta'].to_f/2)..(region['latitude'].to_f+region['latitude_delta'].to_f/2)
    longitude_range = (region['longitude'].to_f-region['longitude_delta'].to_f/2)..(region['longitude'].to_f+region['longitude_delta'].to_f/2)
    includes(:answers, :user).where(:latitude => latitude_range, :longitude => longitude_range)
  end
end
