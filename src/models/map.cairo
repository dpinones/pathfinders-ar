%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import abs_value
from starkware.cairo.common.math_cmp import is_in_range
from starkware.cairo.common.dict import DictAccess
from starkware.cairo.common.cairo_builtins import HashBuiltin

from src.models.point import Point, contains_point, contains_point_equals, get_point_attribute
from src.constants.point_attribute import PARENT, UNDEFINED
from src.constants.grid import X, O
from src.utils.condition import _and, _equals, _max
from src.utils.point_converter import convert_id_to_coords, convert_coords_to_id

struct Map {
    grids: felt*,
    width: felt,
    height: felt,
}

func get_point_by_position{range_check_ptr}(map: Map, x: felt, y: felt) -> Point {
    alloc_locals;
    tempvar is_in_range_x = is_in_range(x, 0, map.width);
    tempvar is_in_range_y = is_in_range(y, 0, map.height);

    let is_in_map = is_inside_of_map(map, x, y); 
    if (is_in_map == FALSE) {
        with_attr error_message("Point ({x}, {y}) is out of map range.") {
            assert 1 = 0;
        }
    }
        
    let id = convert_coords_to_id(x, y, map.width);
    if (map.grids[id] == X) {
        let point = Point(x, y, FALSE);
        return point;
    } else {
        let point = Point(x, y, TRUE);
        return point;
    }
}

func is_inside_of_map{range_check_ptr}(map: Map, x: felt, y: felt) -> felt {
    let is_in_range_x = is_in_range(x, 0, map.width);
    let is_in_range_y = is_in_range(y, 0, map.height);
    
    let res = _and(is_in_range_x, is_in_range_y);

    return res;
}

func is_walkable_at{range_check_ptr}(map: Map, x: felt, y: felt) -> felt {
    let is_in_map = is_inside_of_map(map, x, y);
    if (is_in_map == FALSE) {
        return FALSE;
    }

    let point = get_point_by_position(map, x, y);
    if (point.walkable == FALSE) {
        return FALSE;
    }

    return TRUE;
}

func get_neighbours{range_check_ptr, pedersen_ptr: HashBuiltin*, dict_ptr: DictAccess*}(map: Map, grid: Point) -> (felt, Point*) {
    alloc_locals;
    let parent_id = get_point_attribute{pedersen_ptr = pedersen_ptr, dict_ptr = dict_ptr}(grid, PARENT);

    if (parent_id == UNDEFINED) {
        return get_neighbours_internal(map, grid.x, grid.y);
    } else {
        let (px, py) = convert_id_to_coords(parent_id, map.width);
        return prune_neighbours(grid.x, grid.y, px, py, map);
    }
}

func prune_neighbours{range_check_ptr, pedersen_ptr: HashBuiltin*, dict_ptr: DictAccess*}(x: felt, y: felt, px: felt, py: felt, map: Map) -> (felt, Point*) {
    alloc_locals;
    let relevant_neighbours: Point* = alloc(); 
    local relevant_neighbours_len = 0;

    tempvar pre_dx = x - px;
    tempvar abs_value_x_minus_px = abs_value(pre_dx);
    tempvar max_between_x_minus_px_and_one = _max(abs_value_x_minus_px, 1);
    tempvar dx = pre_dx / max_between_x_minus_px_and_one;

    tempvar pre_dy = y - py;
    tempvar abs_value_y_minus_py = abs_value(pre_dy);
    tempvar max_between_y_minus_py_and_one = _max(abs_value_y_minus_py, 1);
    tempvar dy = pre_dy / max_between_y_minus_py_and_one;

    tempvar is_diagonal_a_move = _and(abs_value(dx), abs_value(dy));

    if (is_diagonal_a_move == 1) {
        let (relevant_neighbours_len) = check_and_add_point(map, x, y + dy, x, y + dy, TRUE, relevant_neighbours_len, relevant_neighbours);
        let (relevant_neighbours_len) = check_and_add_point(map, x + dx, y, x + dx, y, TRUE, relevant_neighbours_len, relevant_neighbours);
        let (relevant_neighbours_len) = check_and_add_point(map, x + dx, y + dy, x + dx, y + dy, TRUE, relevant_neighbours_len, relevant_neighbours);
        
        let (relevant_neighbours_len) = check_and_add_point(map, x - dx, y, x - dx, y - dy, FALSE, relevant_neighbours_len, relevant_neighbours);
        let (relevant_neighbours_len) = check_and_add_point(map, x, y - dy, x + dx, y - dy, FALSE, relevant_neighbours_len, relevant_neighbours);
    
    } else {
        if (dx == 0) {
            let (relevant_neighbours_len) = check_and_add_point(map, x, y + dy, x, y + dy, TRUE,relevant_neighbours_len, relevant_neighbours);
            let (relevant_neighbours_len) = check_and_add_point(map, x + 1, y, x + 1, y + dy, FALSE, relevant_neighbours_len, relevant_neighbours);
            let (relevant_neighbours_len) = check_and_add_point(map, x - 1, y, x - 1, y + dy, FALSE, relevant_neighbours_len, relevant_neighbours);
        } else {
            let (relevant_neighbours_len) = check_and_add_point(map, x + dx, y, x + dx, y, TRUE, relevant_neighbours_len, relevant_neighbours);
            let (relevant_neighbours_len) = check_and_add_point(map, x, y + 1, x + dx, y + 1, FALSE, relevant_neighbours_len, relevant_neighbours);
            let (relevant_neighbours_len) = check_and_add_point(map, x, y - 1, x + dx, y - 1, FALSE, relevant_neighbours_len, relevant_neighbours);
        }
    }
    return (relevant_neighbours_len, relevant_neighbours);
}

func check_and_add_point{range_check_ptr}(map: Map, x: felt, y: felt, relevant_x: felt, relevant_y: felt, walkable_condition: felt, relevant_neighbours_len: felt, relevant_neighbours: Point*) -> (felt){
    let is_walkable = is_walkable_at(map, x, y);
    if (is_walkable == walkable_condition) {
        assert relevant_neighbours[relevant_neighbours_len] = Point(relevant_x, relevant_y, TRUE);
        return (relevant_neighbours_len + 1,);
    } else {
        return (relevant_neighbours_len,);
    }
}

func get_neighbours_internal{range_check_ptr, pedersen_ptr: HashBuiltin*, dict_ptr: DictAccess*}(map: Map, x: felt, y: felt) -> (felt, Point*) {
    let res: Point* = alloc();
    let (all_neighbours_len, all_neighbours) = get_neighbours_without_out_of_range_internal(map, x, y, 0, res, 0, -1, -1, 0);
    let filtered: Point* = alloc();
    return filter_neighbours_if_not_walkable(all_neighbours, all_neighbours_len, filtered, 0);
}

func get_neighbours_without_out_of_range_internal{range_check_ptr, pedersen_ptr: HashBuiltin*, dict_ptr: DictAccess*}(map: Map, x: felt, y: felt, closed_count: felt, res: Point*, res_len: felt, actual_x: felt, actual_y: felt, reset_y: felt) -> (felt, Point*) { 
    alloc_locals;
    if (reset_y == 2 and actual_x == 2) {
        return (res_len, res);
    }

    if (actual_x == 2) {
        return get_neighbours_without_out_of_range_internal(map, x, y, closed_count + 1, res, res_len, -1, actual_y + 1, reset_y + 1);
    }

    if (actual_x == 0 and actual_y == 0) {
        return get_neighbours_without_out_of_range_internal(map, x, y, closed_count + 1, res, res_len, actual_x + 1, actual_y, reset_y);
    }

    let inside_of_map = is_inside_of_map(map, x + actual_x, y + actual_y);
    if (inside_of_map == 1) {
        let temp = get_point_by_position(map, x + actual_x, y + actual_y);
        assert res[res_len] = Point(temp.x, temp.y, temp.walkable);
        return get_neighbours_without_out_of_range_internal(map, x, y, closed_count + 1, res, res_len + 1, actual_x + 1, actual_y, reset_y);
    } else {
        return get_neighbours_without_out_of_range_internal(map, x, y, closed_count + 1, res, res_len, actual_x + 1, actual_y, reset_y);
    }
}

func filter_neighbours_if_not_walkable{range_check_ptr, pedersen_ptr: HashBuiltin*, dict_ptr: DictAccess*}(all_neighbours: Point*, all_neighbours_len: felt, filtered_neighbours: Point*, filtered_neighbours_lenght: felt) -> (felt, Point*) {
    alloc_locals;
    if (all_neighbours_len == 0) {
        return (filtered_neighbours_lenght, filtered_neighbours);
    }

    if ([all_neighbours].walkable == TRUE) {
        assert filtered_neighbours[filtered_neighbours_lenght] = [all_neighbours];
        return filter_neighbours_if_not_walkable(all_neighbours + Point.SIZE, all_neighbours_len - 1, filtered_neighbours, filtered_neighbours_lenght + 1);
    }
    return filter_neighbours_if_not_walkable(all_neighbours + Point.SIZE, all_neighbours_len - 1, filtered_neighbours, filtered_neighbours_lenght);
}

func map_equals(map: Map, other: Map) -> felt {
    let has_same_height = _equals(map.height, other.height);
    let has_same_width = _equals(map.width, other.width);
    let maps_has_same_size = _and(has_same_height, has_same_width);
    
    if (maps_has_same_size == FALSE) {
        return FALSE;
    }

    return _map_equals(map.grids, other.grids, 0, map.width * map.height);
}

func _map_equals(grids: felt*, other_grids: felt*, index: felt, map_lenght: felt) -> felt {
    if (map_lenght == 0) {
        return TRUE;
    }

    if ([grids] != [other_grids]) {
        return FALSE;
    } 

    return _map_equals(grids, other_grids, index + 1, map_lenght - 1);
}

