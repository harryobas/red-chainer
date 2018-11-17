# frozen_string_literal: true

require 'chainer'

class Chainer::WeightDecayTest < Test::Unit::TestCase
  data({
    test1: {
      case: { rate: 0.5 },
      expected: xm::DFloat[4.5, 6.0 , 7.5]
    },
    test2: {
      case: { rate: 0.3 },
      expected: xm::DFloat[4.3, 5.6, 6.9]
    }
  })
  def test_weight_decay(data)
    var = Chainer::Variable.new(xm::DFloat[1, 2, 3])
    var.grad = xm::DFloat[4, 5, 6]
    Chainer::WeightDecay.new(data[:case][:rate]).(nil, var)
    assert_equal(data[:expected], var.grad)
    assert_equal(xm::DFloat[1, 2, 3], var.data)
  end
end
