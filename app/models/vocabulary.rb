# frozen_string_literal: true
class Vocabulary < ActiveHash::Base
  include ActiveModel::Serialization

  fields :tags, :name, :resource
end
