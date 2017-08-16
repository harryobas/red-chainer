module Chainer
  class Variable
    attr_accessor :data, :grad, :requires_grad, :node

    def initialize(data, **kwargs)
      args = Utils::Argument.parse_kwargs(kwargs, name: nil, grad: nil, requires_grad: true)
      unless data.is_a?(Numo::NArray)
        raise TypeError, "Numo::NArray are expected."
      end

      @data = [data]
      @grad = args[:grad]
      @requires_grad = args[:requires_grad]
      @node = VariableNode.new(variable: self, name: args[:name], grad: args[:grad])
    end

    def data
      return @data[0]
    end

    def name
      return @node.name
    end

    def name=(n)
      @node.name = n
    end

    def label
      @node.label
    end

    def creator
      @node.creator
    end

    def creator=(func)
      @node.creator = func
    end

    def grad
      @node.grad
    end

    def grad=(g)
      @node.set_grad_with_check(g, nil, self)
    end

    def rank
      @node.rank
    end

    def set_creator(gen_func)
      @node.set_creator(gen_func)
    end

    def +(other)
      if other.instance_of?(Chainer::Variable)
        Functions::Math::Add.new.([self, other])
      end
      Functions::Math::AddConstant.new(other).(self)
    end
  end
end

