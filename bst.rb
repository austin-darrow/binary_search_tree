# frozen_string_literal: true

require_relative 'node.rb'
require_relative 'arraygen.rb'

class Tree
  attr_accessor :root, :data

  def initialize(array_length)
    array = ArrayGen.new(array_length).array
    @root = build_tree(array)
  end

  def build_tree(array)
    return nil if array.empty?

    mid = (array.length - 1) / 2
    root = Node.new(array[mid])

    root.left = build_tree(array[0...mid])
    root.right = build_tree(array[(mid + 1)..-1])

    root
  end

  def insert(data, node = @root)
    if data > node.data && node.right
      insert(data, node.right)
    elsif data > node.data
      node.right = Node.new(data)
    elsif data < node.data && node.left
      insert(data, node.left)
    elsif data < node.data
      node.left = Node.new(data)
    end
  end

  def delete(value, node = @root)
    return node if node.nil?

    if value < node.data
      node.left = delete(value, node.left)
    elsif value > node.data
      node.right = delete(value, node.right)
    else
      # if node has one or no child
      return node.right if node.left.nil?
      return node.left if node.right.nil?

      # if node has two children
      current = node.right
      leftmost_node = current
      leftmost_node = current.left until current.left.nil?
      node.data = leftmost_node.data
      node.right = delete(leftmost_node.data, node.right)
    end
    node
  end

  def find(data, node = @root)
    return node if node.data == data

    if data > node.data && node.right
      find(data, node.right)
    elsif data < node.data && node.left
      find(data, node.left)
    else
      return "tree does not contain given value"
    end
  end

  def level_order(result = [], queue = [@root])
    return if @root.nil?

    until queue.empty?
      current = queue.first
      yield current if block_given?
      result << current.data

      queue.push(current.left) unless current.left.nil?
      queue.push(current.right) unless current.right.nil?
      queue.shift
    end
    result
  end

  def level_order_recursive(node = @root, queue = [], values = [])
    return if @root.nil?

    yield node if block_given?
    values << node.data
    queue << node.left unless node.left.nil?
    queue << node.right unless node.right.nil?

    return values if queue.empty?

    level_order_recursive(queue.shift, queue, values)
  end

  def preorder(node = @root, values = [])
    return if node.nil?

    yield node if block_given?
    values << node.data
    preorder(node.left, values)
    preorder(node.right, values)
    values
  end

  def postorder(node = @root, values = [])
    return if node.nil?

    postorder(node.left, values)
    postorder(node.right, values)
    yield node if block_given?
    values << node.data
  end

  def inorder(node = @root, values = [])
    return if node.nil?

    inorder(node.left, values)
    yield node if block_given?
    values << node.data
    inorder(node.right, values)
    values
  end

  def height(value, node = find(value), height = 0)
    return 'invalid entry' if node.is_a?(String)
    return height - 1 if node.nil?

    if height(value, node.left, height + 1) > height(value, node.right, height + 1)
      height(value, node.left, height += 1)
    else
      height(value, node.right, height += 1)
    end
  end

  def depth(value, depth = 0, current = @root)
    return 'invalid entry' if current.nil?

    if value < current.data
      depth(value, depth += 1, current.left)
    elsif value > current.data
      depth(value, depth += 1, current.right)
    else
      depth
    end
  end

  def balanced?(node = @root)
    return true if node.nil?

    left = node.left ? height(node.left.data) + 1 : 0
    right = node.right ? height(node.right.data) + 1 : 0

    if difference(left, right) <= 1 && balanced?(node.left) && balanced?(node.right)
      return true
    end

    false
  end

  def rebalance
    array = inorder
    @root = build_tree(array)
  end

  def difference(num1, num2)
    if num1 < num2
      return num2 - num1
    else
      return num1 - num2
    end
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end
end

tree = Tree.new(15)
puts tree.balanced?

p tree.level_order_recursive
p tree.preorder
p tree.postorder
p tree.inorder

tree.pretty_print

10.times do
  random = rand(1000)
  tree.insert(random)
end

tree.pretty_print
puts tree.balanced?

tree.rebalance
tree.pretty_print
puts tree.balanced?

p tree.level_order_recursive
p tree.preorder
p tree.postorder
p tree.inorder
