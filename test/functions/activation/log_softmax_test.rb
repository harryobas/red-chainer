# frozen_string_literal: true

require 'numo/narray'
require 'chainer'
require 'chainer/functions/activation/log_softmax'

class Chainer::Functions::Activation::LogSoftmaxTest < Test::Unit::TestCase
  data = {
    # Not Support test1 case. See xm::NArray issue #78.
    #'test1' => {shape: nil, dtype: xm::SFloat},
    'test2' => {shape: [2, 3], dtype: xm::SFloat},
    'test3' => {shape: [2, 2, 3], dtype: xm::SFloat},
    'test4' => {shape: [2, 2, 2, 3], dtype: xm::SFloat},
    'test5' => {shape: nil, dtype: xm::DFloat},
    'test6' => {shape: [2, 3], dtype: xm::DFloat},
    'test7' => {shape: [2, 2, 3], dtype: xm::DFloat},
    'test8' => {shape: [2, 2, 2, 3], dtype: xm::DFloat}}

  def _setup(data)
    @shape = data[:shape]
    @dtype = data[:dtype]
    if @shape.nil?
      value = -1000
      @x = @dtype.cast([[value, 1]])
    else
      @dtype.srand(1) # To avoid false of "nearly_eq().all?", Use fixed seed value.
      @x = @dtype.new(@shape).rand(2) - 1
    end
    @gy = @dtype.new(@x.shape).rand(2) - 1
    @check_forward_options = {}
    @check_backward_options = {dtype: xm::DFloat}
  end

  def check_forward(x_data, use_cudnn: "always")
    x = Chainer::Variable.new(x_data)
    y = Chainer::Functions::Activation::LogSoftmax.log_softmax(x).dup
    assert_equal(@dtype, y.data.class)

    xm = Chainer.get_array_module(@x)
    log_z = xm::NMath.log(xm::NMath.exp(@x).sum(axis:1, keepdims:true))
    y_expect = @x - log_z
    assert_true(y.data.nearly_eq(y_expect).all?)
  end

  data(data)
  def test_forward(data)
    _setup(data)
    check_forward(@x.dup)
  end

  def check_backward(x_data, gy_data, use_cudnn: "always")
    Chainer::check_backward(Chainer::Functions::Activation::LogSoftmax.method(:log_softmax), x_data, gy_data, @check_backward_options)
  end

  data(data)
  def test_backward(data)
    _setup(data)
    check_backward(@x.dup, @gy.dup)
  end
end
