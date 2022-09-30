%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin

struct Point {
    x: felt,
    y: felt,
    walkable: felt,
}

struct PointWithParent {
    x: felt,
    y: felt,
    walkable: felt,
    parent: Point*,
}

struct Map {
    grid: Point*,
    map_grid_length: felt,
    width: felt,
    height: felt,
}

// This Struct represent a movement where values can be {-1, 0, 1}
// Diagonal movements is represented as:
// horizotal = {-1, 0, 1}
// vertical = {-1, 0, 1}
struct Movement {
    horizontal: felt,
    vertical: felt,
}

func get_movement_type{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}(movement: Movement) -> (felt) {
    // TODO: check if horizontal and vertical values are one of this: {-1, 0, 1}
    
    if (movement.horizontal != 0 and movement.vertical != 0) {
        return ('diagonal',);
    }
    if (movement.horizontal != 0) {
        return ('horizontal',);
    }
    if (movement.vertical != 0) {
        return ('vertical',);
    }
    
    with_attr error_message("Cannot identify movement type") {
        assert 1 = 0;
    }
    return ('none',);
}

func  get_point_in_map{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}(map: Map, x: felt, y: felt) -> Point {
    return get_point_in_map_internal(map, 0, x, y);
}

func get_point_in_map_internal{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}(map: Map, index: felt, x: felt, y: felt) -> Point {
    if (map.map_grid_length == index + 1) {
        with_attr error_message("Point not found in map") {
            assert 1 = 0;
        }
    }

    if (map.grid[index].x == x and map.grid[index].y == y) {
        tempvar res = Point(map.grid[index].x, map.grid[index].y, map.grid[index].walkable);
        return res;
    }
    
    return get_point_in_map_internal(map, index + 1, x, y);
}

func get_point_by_position(nodes: Point*, lenght: felt, x: felt, y: felt) -> Point {
    return get_point_by_position_internal(nodes, 0, lenght, x, y);
}

func get_point_by_position_internal(nodes: Point*, index: felt, lenght: felt, x: felt, y: felt) -> Point {
    if (index == lenght) {
        with_attr error_message("Point not found in list") {
            assert 1 = 0;
        }
    }

    if (nodes[index].x == x and nodes[index].y == y) {
        tempvar res = Point(nodes[index].x, nodes[index].y, nodes[index].walkable);
        return res;
    }

    return get_point_by_position_internal(nodes, index + 1, lenght, x, y);
}

func contains_point(nodes: Point*, lenght: felt, x: felt, y: felt) -> felt {
    return contains_point_internal(nodes, 0, lenght, x, y);
}

func contains_point_internal(nodes: Point*, index: felt, lenght: felt, x: felt, y: felt) -> felt {
    if (0 == lenght) {
        return 0;
    }

    if ([nodes].x == x and [nodes].y == y) {
        return 1;
    }

    return contains_point_internal(nodes + Point.SIZE, index + 1, lenght - 1, x, y);
}

func contains_all_points(nodes: Point*, lenght: felt, points: Point*, points_lenght: felt) -> felt {
    return contains_points_all_internal(nodes, lenght, points, 0, points_lenght);
}

func contains_points_all_internal(nodes: Point*, lenght: felt, points: Point*, points_index: felt, points_lenght: felt) -> felt {
    if (0 == points_lenght ) {
        return 1;
    }

    let not_found_flag = contains_point(nodes, lenght, [points].x, [points].y); 
    if (not_found_flag == 0) {
        return 0;
    }

    return contains_points_all_internal(nodes, lenght, points + Point.SIZE, points_index + 1, points_lenght - 1);
}
