%lang starknet
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE

from starkware.cairo.common.math_cmp import is_in_range
from src.models.point import Point, contains_point_equals
from src.utils.condition import _and, _equals

struct Map {
    grid: Point*,
    width: felt,
    height: felt,
}

func get_point_by_position{range_check_ptr}(map: Map, x: felt, y: felt) -> Point {
    alloc_locals;
    let is_in_range_x = is_in_range(x, 0, map.width);
    let is_in_range_y = is_in_range(y, 0, map.height);

    let is_in_map = is_inside_of_map(map, x, y); 
    if (is_in_map == 0) {
        with_attr error_message("Point ({x}, {y}) is out of map range.") {
            assert 1 = 0;
        }
    }

    let p = get_point_by_position_internal(map.grid, map.width * map.height, x, y);
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

func is_inside_of_map{range_check_ptr}(map: Map, x: felt, y: felt) -> felt {
    let is_in_range_x = is_in_range(x, 0, map.width);
    let is_in_range_y = is_in_range(y, 0, map.height);
    
    let res = _and(is_in_range_x, is_in_range_y);

    return res;
}

func get_all_neighbours_of{range_check_ptr}(map: Map, node: Point) -> (len_res: felt, res: Point*) {
    alloc_locals;
    let (all_neighbours_len: felt, all_neighbours: Point*) = get_inmediate_neighbours(map, node.x, node.y);

    let filtered_neighbours: Point* = alloc();
    filter_neighbours_if_not_walkable(all_neighbours, 8, filtered_neighbours, 0);
    let filtered_neighbours_len =  filter_neighbours_if_not_walkable_len(all_neighbours, 8);

    return (filtered_neighbours_len, filtered_neighbours);
}

func filter_neighbours_if_not_walkable(all_neighbours: Point*, all_neighbours_len: felt, filtered_neighbours: Point*, idx_filtered_neighbours: felt) {
    alloc_locals;
    if (all_neighbours_len == 0) {
        return ();
    }

    if ([all_neighbours].walkable == 1) {
        assert filtered_neighbours[idx_filtered_neighbours] = [all_neighbours];
        filter_neighbours_if_not_walkable(all_neighbours + Point.SIZE, all_neighbours_len - 1, filtered_neighbours, idx_filtered_neighbours + 1);
        return(); 
    }
    filter_neighbours_if_not_walkable(all_neighbours + Point.SIZE, all_neighbours_len - 1, filtered_neighbours, idx_filtered_neighbours);
    return(); 
}

func filter_neighbours_if_not_walkable_len(all_neighbours: Point*, all_neighbours_len: felt) -> felt {
    alloc_locals;
    if (all_neighbours_len == 0) {
        return (0);
    }

    local cont;
    if ([all_neighbours].walkable == 1) {
        cont = 1;
    } else {
        cont = 0;
    }
    let total = filter_neighbours_if_not_walkable_len(all_neighbours + Point.SIZE, all_neighbours_len - 1); 
    let res = cont + total;
    return res; 
}

func get_inmediate_neighbours{range_check_ptr}(map: Map, x: felt, y: felt) -> (felt, Point*) {
    let res: Point* = alloc();
    return get_inmediate_neighbours_internal{range_check_ptr=range_check_ptr}(map, x, y, 0, res, 0, -1, -1, 0);
}

func get_inmediate_neighbours_internal{range_check_ptr}(map: Map, x: felt, y: felt, closed_count: felt, res: Point*, res_len: felt, actual_x: felt, actual_y: felt, reset_y: felt) -> (felt, Point*) { 
    alloc_locals;
    if (reset_y == 2 and actual_x == 2) {
        return (res_len, res);
    }

    if (actual_x == 2) {
        return get_inmediate_neighbours_internal(map, x, y, closed_count + 1, res, res_len, -1, actual_y + 1, reset_y + 1);
    }

    if (actual_x == 0 and actual_y == 0) {
        return get_inmediate_neighbours_internal(map, x, y, closed_count + 1, res, res_len, actual_x + 1, actual_y, reset_y);
    }

    let inside_of_map = is_inside_of_map(map, x + actual_x, y + actual_y);
    if (inside_of_map == 1) {
        let temp = get_point_by_position(map, x + actual_x, y + actual_y);
        assert res[res_len] = Point(temp.x, temp.y, temp.walkable);
        return get_inmediate_neighbours_internal(map, x, y, closed_count + 1, res, res_len + 1, actual_x + 1, actual_y, reset_y);
    } else {
        return get_inmediate_neighbours_internal(map, x, y, closed_count + 1, res, res_len, actual_x + 1, actual_y, reset_y);
    }
}


func map_equals(map: Map, other: Map) -> felt {
    let has_same_height = _equals(map.height, other.height);
    let has_same_width = _equals(map.width, other.width);
    let maps_has_same_size = _and(has_same_height, has_same_width);
    if (maps_has_same_size == FALSE) {
        return FALSE;
    }

    return map_equals_internal(map.grid, map.width * map.height, other.grid, other.width * other.height);
}

func map_equals_internal(nodes: Point*, lenght: felt, points: Point*, points_lenght: felt) -> felt {
    if (points_lenght == 0) {
        return 1;
    }

    let not_found_flag = contains_point_equals(nodes, lenght, [points].x, [points].y, [points].walkable); 
    if (not_found_flag == 0) {
        return 0;
    }

    return map_equals_internal(nodes, lenght, points + Point.SIZE, points_lenght - 1);
}