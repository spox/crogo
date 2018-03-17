module Crogo
  class PriorityQueue(T)
    alias Cost = Int32 | Proc(Int32)

    property queue = {} of T => Cost
    property sorted_list = [] of T
    property style = :lowscore
    property dynamics = 0

    def initialize(@style : Symbol = :lowscore)
      @sorted = false
    end

    def push(item : T, cost : Cost)
      error_on_dup!(item)
      queue[item] = cost
      @sorted = false
      self
    end

    def push(item : T, &block : Proc(Int32))
      error_on_dup!(item)
      queue[item] = block
      @sorted = false
      self
    end

    def multi_push(items : Array(Tuple(T, Cost)))
      items.each do |item|
        push(item.first, item.last)
      end
      @sorted = false
      self
    end

    def pop : T?
      sort!
      unless sorted_list.empty?
        item = sorted_list.pop
        delete(item)
        item
      end
    end

    def delete(item : T)
      sorted_list.delete(item)
      cost = queue.delete(item)
      if cost.is_a?(Proc(Int32))
        @dynamics -= 1
      end
      self
    end

    def highscore_priority?
      style == :highscore
    end

    def sort!
      if !@sorted || @dynamics > 0
        @dynamics = 0
        cost_list = queue.map do |item, cost|
          if cost.is_a?(Proc(Int32))
            @dynamics += 1
            cost = cost.call
          end
          [cost.to_i, item]
        end
        _sorted_list = cost_list.sort do |x, y|
          if highscore_priority?
            x.first.to_i <=> y.first.to_i
          else
            y.first.to_i <=> x.first.to_i
          end
        end
        @sorted_list = _sorted_list.map{|l| l.last.as(T) }
        @sorted = true
      end
      sorted_list
    end

    def error_on_dup!(item)
      if (queue.key?(item))
        raise KeyError.new("Item has already been entered into queue! (`#{item}`)")
      end
    end
  end
end
