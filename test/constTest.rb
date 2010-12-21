class A
  def initialize
    puts self.class::C
  end
end

class B < A
  C = 'blah'
end

B.new
