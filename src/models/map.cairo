%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import abs_value
from starkware.cairo.common.math_cmp import is_le, is_in_range
from starkware.cairo.common.dict import DictAccess
from starkware.cairo.common.cairo_builtins import HashBuiltin

from src.models.point import Point, get_point_attribute
from src.models.movement import get_movement_direction_coords
from src.constants.point_attribute import PARENT, UNDEFINED
from src.constants.grid import X, O
from src.utils.condition import _and, _equals, _max, _not, _or
from src.utils.point_converter import convert_id_to_coords, convert_coords_to_id

struct Map {
    grids: felt*,
    width: felt,
    height: felt,
}

// Check if the (x,y) coordinates are accessible:
//   (1) The point is inside the map 
//   (2) The point has the attribute as walkable in TRUE
//
// @param: map - Map from which we want to verify.
// @param: x - X position.
// @param: y - Y position.
// @return: Point - Returns TRUE if conditions (1) and (2) are met.
func is_walkable_at{range_check_ptr}(map: Map, x: felt, y: felt) -> felt {
    %{
        from requests import post
        json = { # creating the body of the post request so it's printed in the python script
            "is_walkable_at": f"just check for ({ids.x}, {ids.y})"
        }
        post(url="http://localhost:5000", json=json) # sending the request to our small "server"
    %}
    let is_in_map = is_inside_of_map(map, x, y);
    if (is_in_map == FALSE) {
        return FALSE;
    }
    let grid_converted = convert_coords_to_id(x, y, map.width);
    if (map.grids[grid_converted] == X) {
        return FALSE;
    } else {
        return TRUE;
    }
}

// Check if the (x,y) coordinates are inside of the map.
//
// @param: map - Map from which we want to verify.
// @param: x - X position.
// @param: y - Y position.
// @return: Point - Returns TRUE if point is in the map, FALSE otherwise.
func is_inside_of_map{range_check_ptr}(map: Map, x: felt, y: felt) -> felt {
    let is_in_range_x = is_in_range(x, 0, map.width);
    let is_in_range_y = is_in_range(y, 0, map.height);
    let res = _and(is_in_range_x, is_in_range_y);

    return res;
}

// Returns the neighbors of the point (x, y) on the map.
// Depending on whether the point has a parent or not, 
// some strategy will be executed that allows us to optimize 
// the number of relevant neighboring nodes that we will return.
// This method is based on "if at most one obstacle" logic.
//
// @param: map - Map from which we want to verify.
// @param: point - Point from which you want to get the neighbors.
// @return: (felt, Point*) - The list of neighbours of point.
func get_neighbours{range_check_ptr, pedersen_ptr: HashBuiltin*, point_attribute: DictAccess*}(map: Map, grid_id: felt) -> (felt, felt*) {
    alloc_locals;
    let (x, y) = convert_id_to_coords(grid_id, map.width);
    let parent_id = get_point_attribute{pedersen_ptr = pedersen_ptr, point_attribute = point_attribute}(grid_id, PARENT);

    if (parent_id == UNDEFINED) {
        return _get_neighbours(map, x, y);
    } else {
        let (px, py) = convert_id_to_coords(parent_id, map.width);
        return _prune_neighbours(x, y, px, py, map);
    }
}

func _prune_neighbours{range_check_ptr, pedersen_ptr: HashBuiltin*, point_attribute: DictAccess*}(x: felt, y: felt, px: felt, py: felt, map: Map) -> (felt, felt*) {
    alloc_locals;
    let relevant_neighbours: felt* = alloc(); 
    local relevant_neighbours_len = 0;

    let (dx, dy) = get_movement_direction_coords(x, y, px, py);
    tempvar is_diagonal_a_move = _and(abs_value(dx), abs_value(dy));

    if (is_diagonal_a_move == TRUE) {
        let (_, relevant_neighbours_len) = check_and_add_point(map, x, y + dy, x, y + dy, TRUE, relevant_neighbours_len, relevant_neighbours);
        let (_, relevant_neighbours_len) = check_and_add_point(map, x + dx, y, x + dx, y, TRUE, relevant_neighbours_len, relevant_neighbours);
        let (relevant_neighbours_len) = check_and_add_point_double_or_condition(map, x, y + dy, x + dx, y, x + dx, y + dy, relevant_neighbours_len, relevant_neighbours);
        let (relevant_neighbours_len) = check_and_add_point_double_and_condition(map, x - dx, y, x, y + dy, x - dx, y + dy, relevant_neighbours_len, relevant_neighbours);
        let (relevant_neighbours_len) = check_and_add_point_double_and_condition(map, x, y - dy, x + dx, y, x + dx, y - dy, relevant_neighbours_len, relevant_neighbours);
        
        return (relevant_neighbours_len, relevant_neighbours);
    }     
    if (dx == 0) {
        let is_walkable_at_grid = is_walkable_at(map, x, y + dy);
        if (is_walkable_at_grid == TRUE) {
            let (_, relevant_neighbours_len) = check_and_add_point(map, x, y + dy, x, y + dy, TRUE, relevant_neighbours_len, relevant_neighbours);
            let (_, relevant_neighbours_len) = check_and_add_point(map, x + 1, y, x + 1, y + dy, FALSE, relevant_neighbours_len, relevant_neighbours);
            let (_, relevant_neighbours_len) = check_and_add_point(map, x - 1, y, x - 1, y + dy, FALSE, relevant_neighbours_len, relevant_neighbours);

            return (relevant_neighbours_len, relevant_neighbours);
        } else {
            tempvar range_check_ptr = range_check_ptr; 
        }
    } else {
        let is_walkable_at_grid = is_walkable_at(map, x + dx, y);
        if (is_walkable_at_grid == TRUE) {
            let (_, relevant_neighbours_len) = check_and_add_point(map, x + dx, y, x + dx, y, TRUE, relevant_neighbours_len, relevant_neighbours);
            let (_, relevant_neighbours_len) = check_and_add_point(map, x, y + 1, x + dx, y + 1, FALSE, relevant_neighbours_len, relevant_neighbours);
            let (_, relevant_neighbours_len) = check_and_add_point(map, x, y - 1, x + dx, y - 1, FALSE, relevant_neighbours_len, relevant_neighbours);

            return (relevant_neighbours_len, relevant_neighbours);
        } else {
            tempvar range_check_ptr = range_check_ptr; 
        }
    }
    return (relevant_neighbours_len, relevant_neighbours);
}

func _get_neighbours{range_check_ptr, pedersen_ptr: HashBuiltin*, point_attribute: DictAccess*}(map: Map, x: felt, y: felt) -> (felt, felt*) {
    alloc_locals;
    let relevant_neighbours: Point* = alloc(); 
    local relevant_neighbours_len = 0;

    // ↑
    let (s0, relevant_neighbours_len) = check_diagonal_and_check_same_as_add(map, TRUE, TRUE, x, y - 1, relevant_neighbours_len, relevant_neighbours);
    // →
    let (s1, relevant_neighbours_len) = check_diagonal_and_check_same_as_add(map, TRUE, TRUE, x + 1, y, relevant_neighbours_len, relevant_neighbours);
    // ↓
    let (s2, relevant_neighbours_len) = check_diagonal_and_check_same_as_add(map, TRUE, TRUE, x, y + 1, relevant_neighbours_len, relevant_neighbours);
    // ←
    let (s3, relevant_neighbours_len) = check_diagonal_and_check_same_as_add(map, TRUE, TRUE, x - 1, y, relevant_neighbours_len, relevant_neighbours);

    tempvar d0 = _or(s3, s0);
    tempvar d1 = _or(s0, s1);
    tempvar d2 = _or(s1, s2);
    tempvar d3 = _or(s2, s3);

    // ↖
    let (_, relevant_neighbours_len) = check_diagonal_and_check_same_as_add(map, d0, TRUE, x - 1, y - 1, relevant_neighbours_len, relevant_neighbours);
    // ↗
    let (_, relevant_neighbours_len) = check_diagonal_and_check_same_as_add(map, d1, TRUE, x + 1, y - 1, relevant_neighbours_len, relevant_neighbours);
    // ↘
    let (_, relevant_neighbours_len) = check_diagonal_and_check_same_as_add(map, d2, TRUE, x + 1, y + 1, relevant_neighbours_len, relevant_neighbours);
    // ↙
    let (_, relevant_neighbours_len) = check_diagonal_and_check_same_as_add(map, d3, TRUE, x - 1, y + 1, relevant_neighbours_len, relevant_neighbours);
    
    return (relevant_neighbours_len, relevant_neighbours);
}

// Verify if two maps are equals
//
// @param: map - map to compare.
// @param: other - other map to compare.
// @return: felt - TRUE if maps are equals, FALSE otherwise.
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
// Aux methods

func check_diagonal_and_check_same_as_add{range_check_ptr}(map: Map, diagonal_condition: felt, walkable_condition: felt, x: felt, y: felt, relevant_neighbours_len: felt, relevant_neighbours: felt*) -> (felt, felt) {
    let is_walkable = is_walkable_at(map, x, y);
    
    if (diagonal_condition == FALSE) {
        return (is_walkable, relevant_neighbours_len);
    }
    if (is_walkable == walkable_condition) {
        let candidate_grid_id = convert_coords_to_id(x, y, map.width);
        %{
            from requests import post
            json = { # creating the body of the post request so it's printed in the python script
                "check_diagonal_and_check_same_as_add": f"just added{ids.candidate_grid_id}"
            }
            post(url="http://localhost:5000", json=json) # sending the request to our small "server"
        %}
        assert relevant_neighbours[relevant_neighbours_len] = candidate_grid_id;
        return (is_walkable, relevant_neighbours_len + 1);
    } else {
        return (is_walkable, relevant_neighbours_len);
    }
}

func check_and_add_point{range_check_ptr}(map: Map, x: felt, y: felt, relevant_x: felt, relevant_y: felt, walkable_condition: felt, relevant_neighbours_len: felt, relevant_neighbours: felt*) -> (felt, felt) {
    let is_walkable = is_walkable_at(map, x, y);
    if (is_walkable == walkable_condition) {
        let candidate_grid_id = convert_coords_to_id(relevant_x, relevant_y, map.width);
        assert relevant_neighbours[relevant_neighbours_len] = candidate_grid_id;
        return (is_walkable, relevant_neighbours_len + 1,);
    } else {
        return (is_walkable, relevant_neighbours_len,);
    }
}

func check_and_add_point_double_and_condition{range_check_ptr}(map: Map, first_x: felt, first_y: felt, second_x: felt, second_y: felt, relevant_x: felt, relevant_y: felt, relevant_neighbours_len: felt, relevant_neighbours: felt*) -> (felt){
    alloc_locals;
    let is_walkable_first = is_walkable_at(map, first_x, first_y);
    let is_walkable_second = is_walkable_at(map, second_x, second_y);
    let meet_conditions = _and(_not(is_walkable_first), is_walkable_second);

    if (meet_conditions == TRUE) {
        let candidate_grid_id = convert_coords_to_id(relevant_x, relevant_y, map.width);
        assert relevant_neighbours[relevant_neighbours_len] = candidate_grid_id;
        return (relevant_neighbours_len + 1,);
    } else {
        return (relevant_neighbours_len,);
    }
}

func check_and_add_point_double_or_condition{range_check_ptr}(map: Map, first_x: felt, first_y: felt, second_x: felt, second_y: felt, relevant_x: felt, relevant_y: felt, relevant_neighbours_len: felt, relevant_neighbours: felt*) -> (felt){
    alloc_locals;
    let is_walkable_first = is_walkable_at(map, first_x, first_y);
    let is_walkable_second = is_walkable_at(map, second_x, second_y);
    let meet_conditions = _or(is_walkable_first, is_walkable_second);
    
    let candidate_is_walkable = is_walkable_at(map, relevant_x, relevant_y);
    if (candidate_is_walkable == FALSE) {
        return (relevant_neighbours_len,);
    }

    if (meet_conditions == TRUE) {
        let candidate_grid_id = convert_coords_to_id(relevant_x, relevant_y, map.width);
        assert relevant_neighbours[relevant_neighbours_len] = candidate_grid_id;
        return (relevant_neighbours_len + 1,);
    } else {
        return (relevant_neighbours_len,);
    }
}