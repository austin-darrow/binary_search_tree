# frozen_string_literal: true

class ArrayGen
  attr_reader :array

  def initialize(element_count)
    @array = create_array(element_count)
  end

  def create_array(element_count)
    array = []
    until array.length == element_count
      random = rand(100)
      array << random
      array = array.sort.uniq
    end
    return array
  end
end
