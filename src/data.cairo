%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_in_range
from starkware.cairo.common.alloc import alloc

from src.util.condition import _or, _and, _not

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

func get_movement_type(movement: Movement) -> felt {
    // TODO: check if horizontal and vertical values are one of this: {-1, 0, 1}
    
    if (movement.horizontal != 0 and movement.vertical != 0) {
        return 'diagonal';
    }
    if (movement.horizontal != 0) {
        return 'horizontal';
    }
    if (movement.vertical != 0) {
        return 'vertical';
    }
    
    with_attr error_message("Cannot identify movement type") {
        assert 1 = 0;
    }
    return 'none';
}

// func  get_point_in_map(map: Map, x: felt, y: felt) -> Point {
//     return get_point_in_map_internal(map, 0, x, y);
// }

// func get_point_in_map_internal(map: Map, index: felt, x: felt, y: felt) -> Point {
//     if (map.map_grid_length == index + 1) {
//         with_attr error_message("Point not found in map") {
//             assert 1 = 0;
//         }
//     }

//     if (map.grid[index].x == x and map.grid[index].y == y) {
//         tempvar res = Point(map.grid[index].x, map.grid[index].y, map.grid[index].walkable);
//         return res;
//     }
    
//     return get_point_in_map_internal(map, index + 1, x, y);
// }

func get_point_by_position{range_check_ptr}(map: Map, x: felt, y: felt) -> Point {
    alloc_locals;
    let is_in_range_x = is_in_range(x, 0, map.width);
    let is_in_range_y = is_in_range(y, 0, map.height);

    tempvar is_out_of_range = _not(_and(is_in_range_x, is_in_range_y)); 
    if (is_out_of_range == 1) {
        with_attr error_message("Point ({x}, {y}) is out of map range.") {
            assert 1 = 0;
        }
    }

    let p = get_point_by_position_internal(map.grid, map.map_grid_length, x, y);
    return p;
}

func get_point_by_position_internal(nodes: Point*, lenght: felt, x: felt, y: felt) -> Point {
    if (lenght == 0) {
        with_attr error_message("Point ({x}, {y}) was not found in nodes.") {
            assert 1 = 0;
        }
    }

    if ([nodes].x == x and [nodes].y == y) {
        tempvar res = Point([nodes].x, [nodes].y, [nodes].walkable);
        return res;
    }

    return get_point_by_position_internal(nodes + Point.SIZE, lenght - 1, x, y);
}

func contains_point(nodes: Point*, lenght: felt, x: felt, y: felt) -> felt {
    return contains_point_internal(nodes, lenght, x, y);
}

func contains_point_internal(nodes: Point*, lenght: felt, x: felt, y: felt) -> felt {
    if (0 == lenght) {
        return 0;
    }

    if ([nodes].x == x and [nodes].y == y) {
        return 1;
    }

    return contains_point_internal(nodes + Point.SIZE, lenght - 1, x, y);
}

func contains_all_points(nodes: Point*, lenght: felt, points: Point*, points_lenght: felt) -> felt {
    return contains_all_points_internal(nodes, lenght, points, points_lenght);
}

func contains_all_points_internal(nodes: Point*, lenght: felt, points: Point*, points_lenght: felt) -> felt {
    if (0 == points_lenght ) {
        return 1;
    }

    let not_found_flag = contains_point(nodes, lenght, [points].x, [points].y); 
    if (not_found_flag == 0) {
        return 0;
    }

    return contains_all_points_internal(nodes, lenght, points + Point.SIZE, points_lenght - 1);
}


func prune(nodes: Point*, lenght: felt, parent: Point, direction: felt) -> (Point*, felt) {
    let res: Point* = alloc();
    let res_lenght = 0;
    if (direction == 'horizontal') {
        return prune_horizontal(nodes, lenght, parent, res, res_lenght);
    }
    if (direction == 'diagonal') {
        return prune_diagonal(nodes, lenght, parent, res, res_lenght);
    }
    return(res, res_lenght,);
}

func prune_horizontal(nodes: Point*, lenght: felt, parent: Point, res: Point*, res_lenght: felt) -> (Point*, felt) {
    if (lenght == 0) {
        return (res, res_lenght,);
    }
    return (nodes, lenght,);
}

func prune_diagonal(nodes: Point*, lenght: felt, parent: Point, res: Point*, res_lenght: felt) -> (Point*, felt) {
    return (nodes, lenght,);
}

// func get_minimum_lenght_path_with_x(nodes: Point*, _from: Point, _to: Point, _x: Point) -> felt {
//     get_minimum_lenght_path_with_x_internal(nodes, _from, _to, _x, 0, 0);
// }

// func get_minimum_lenght_path_with_x_internal(actual: Point, dest: Point, x: Point, current_path_size: felt, path_contains_x: felt) -> felt {
//     if (actual.x == dest.x and actual.y == dest.y and path_contains_x == 1) {
//         return current_path_size;
//     }

//     if (actual.x == x.x and actual.y == x.y) {
//         path_contains_x = 1;
//     }

//     let next_mov =  3
// }
