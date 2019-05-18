module Multisplit
  class Route
    attr_reader :names, :total_length

    def initialize(routes)
      @routes_data = routes
      @all_routes = []
      @static_splits = []
      @total_length = 0
      init_route
      reset
    end

    def switch(split_index, path_index)
      route = route_index(split_index)
      path = [path_index, @all_routes[route].length - 1].min
      @current_routes[route] = path
      update
    end

    def reset
      @current_routes = Array.new(@static_splits.count(:placeholder_head), 0)
      update
    end

    private

    def route_index(split_index)
      @static_splits[0...split_index].count(:placeholder_head)
    end

    def update
      route_index = -1
      route = @static_splits.map do |name|
        case name
        when :placeholder_head
          route_index += 1
          pathnum = @current_routes[route_index]
          next @all_routes[route_index][pathnum]
        when :placeholder then next
        else next name
        end
      end
      @names = route.compact.flatten
    end

    def init_route
      route_index = 0
      @routes_data.each do |name_or_route|
        if name_or_route.is_a?(Hash)
          route_index += 1
          route_data(name_or_route, route_index)
        else
          @static_splits << name_or_route
          @total_length += 1
        end
      end
    end

    def route_data(route, route_index)
      route_length = route.values.first.length
      @all_routes << route.values
      @static_splits << :placeholder_head
      @static_splits += Array.new(route_length - 1, :placeholder)
      @total_length += route_length
    end
  end
end
