module Multisplit
  class Route
    attr_reader :names, :length

    def initialize(routes)
      @routes = routes
      @base = []
      @paths = {}
      @route_lengths = []
      @routes.each do |name_or_route|
        if name_or_route.is_a?(Hash)
          routename = name_or_route.keys.first
          init_paths(name_or_route)
          init_base(routename, name_or_route)
          init_route_lengths(routename)
          @prev_routename = routename
        else
          @base << name_or_route
        end
      end
      @length = @base.length
      reset
    end

    def switch(split_index, path_index)
      route = route_index(split_index)
      path = [path_index, @route_lengths[route]].min
      @current_paths[route] = nsucc(path)
      update
    end

    def reset
      @current_paths = Array.new(@base.grep(Integer).count, "a")
      update
    end

    private

    def route_index(split_index)
      @base[0...split_index].grep(Integer).count
    end

    def nsucc(num)
      char = "a"
      num.times { char.succ! }
      return char
    end

    def update
      route = @base.compact.map do |name_or_routenum|
        if name_or_routenum.is_a?(Integer)
          pathnum = @current_paths[name_or_routenum - 1]
          @paths["#{name_or_routenum}#{pathnum}"]
        else
          name_or_routenum
        end
      end
      @names = route.flatten
    end

    def init_paths(route)
      @paths.merge!(route)
    end

    def init_base(routename, route)
      return if routename == @prev_routename&.succ
      @base << routename.to_i
      @base += Array.new(route.values.first.length - 1, nil)
    end

    def init_route_lengths(routename)
      if routename == @prev_routename&.succ
        @route_lengths[-1] += 1
      else
        @route_lengths << 0
      end
    end
  end
end
