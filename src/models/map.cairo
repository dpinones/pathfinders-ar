%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import abs_value
from starkware.cairo.common.dict import DictAccess
from starkware.cairo.common.cairo_builtins import HashBuiltin

from src.models.point import Point, get_point_attribute, is_walkable_at
from src.models.movement import get_movement_direction
from src.constants.point_attribute import PARENT, UNDEFINED
from src.constants.grid import X, O
from src.utils.condition import _and, _equals, _max, _not, _or
from src.utils.point_converter import convert_id_to_coords, convert_coords_to_id

struct Map {
    grids: felt*,
    width: felt,
    height: felt,
}

// // Returns a Point given a position (x, y).
// //
// // @param: map - Map from which we want to get the point.
// // @param: x - X position.
// // @param: y - Y position.
// // @return: Point - Returns the point at position (x, y) if it exists, if the point is outside the map it will throw an error.
// func get_point_by_position{range_check_ptr}(map: Map, grid_id: felt) -> felt {
//     alloc_locals;
//     let is_in_map = is_inside_of_map(map, grid_id); 
//     if (is_in_map == FALSE) {
//         with_attr error_message("Point ({x}, {y}) is out of map range.") {
//             assert 1 = 0;
//         }
//     }
        
//     if (map.grids[grid_id] == X) {
//         let point = Point(x, y, FALSE);
//         return point;
//     } else {
//         let point = Point(x, y, TRUE);
//         return point;
//     }
// }


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
    let parent_grid_id = get_point_attribute{pedersen_ptr = pedersen_ptr, point_attribute = point_attribute}(grid_id, PARENT);

    if (parent_grid_id == UNDEFINED) {
        return _get_neighbours(map, grid_id);
    } else {
        return _prune_neighbours(grid_id, parent_grid_id, map);
    }
}

func _prune_neighbours{range_check_ptr, pedersen_ptr: HashBuiltin*, point_attribute: DictAccess*}(node_grid: felt, parent_grid: felt, map: Map) -> (felt, felt*) {
    alloc_locals;
    let relevant_neighbours: felt* = alloc(); 
    local relevant_neighbours_len = 0;

    let (dx, dy) = get_movement_direction(node_grid, parent_grid, map.width);
    tempvar is_diagonal_a_move = _and(abs_value(dx), abs_value(dy));

    if (is_diagonal_a_move == TRUE) {
        let (relevant_neighbours_len) = check_and_add_point(map, node_grid + (dy * map.width), node_grid + (dy * map.width), TRUE, relevant_neighbours_len, relevant_neighbours);
        let (relevant_neighbours_len) = check_and_add_point(map, node_grid + dx, node_grid + dx, TRUE, relevant_neighbours_len, relevant_neighbours);
        let (relevant_neighbours_len) = check_and_add_point_double_or_condition(map, node_grid + (dy * map.width), node_grid + dx, node_grid + dx + (dy * map.width), relevant_neighbours_len, relevant_neighbours);
        let (relevant_neighbours_len) = check_and_add_point_double_and_condition(map, node_grid - dx, node_grid + (dy * map.width), node_grid - dx + (dy * map.width), relevant_neighbours_len, relevant_neighbours);
        let (relevant_neighbours_len) = check_and_add_point_double_and_condition(map, node_grid - (dy * map.width), node_grid + dx, node_grid + dx - (dy * map.width), relevant_neighbours_len, relevant_neighbours);
    } else {
        if (dx == 0) {
            let is_walkable_at_grid = is_walkable_at(map.grids, map.width * map.height, node_grid + (dy * map.width));
            if (is_walkable_at_grid == TRUE) {
                let (relevant_neighbours_len) = check_and_add_point(map, node_grid + (dy * map.width), node_grid + (dy * map.width), TRUE, relevant_neighbours_len, relevant_neighbours);
                let (relevant_neighbours_len) = check_and_add_point(map, node_grid + 1 + (dy * map.width), node_grid - dx + (dy * map.width), FALSE, relevant_neighbours_len, relevant_neighbours);
                let (relevant_neighbours_len) = check_and_add_point(map, node_grid - 1, node_grid - 1 + (dy * map.width), FALSE, relevant_neighbours_len, relevant_neighbours);
            } else {
                tempvar range_check_ptr = range_check_ptr;
                tempvar relevant_neighbours_len = relevant_neighbours_len;
            }
        } else {
            let is_walkable_at_grid = is_walkable_at(map.grids, map.width * map.height, node_grid + dx);
                if (is_walkable_at_grid == TRUE) {
                    let (relevant_neighbours_len) = check_and_add_point(map, node_grid + dx, node_grid + dx, TRUE, relevant_neighbours_len, relevant_neighbours);
                    let (relevant_neighbours_len) = check_and_add_point(map, node_grid + map.width, node_grid + dx + map.width, FALSE, relevant_neighbours_len, relevant_neighbours);
                    let (relevant_neighbours_len) = check_and_add_point(map, node_grid - map.width, node_grid + dx - map.width, FALSE, relevant_neighbours_len, relevant_neighbours);
                } else {
                    tempvar range_check_ptr = range_check_ptr;
                    tempvar relevant_neighbours_len = relevant_neighbours_len;
                }
        }
    }
    return (relevant_neighbours_len, relevant_neighbours);
}

func _get_neighbours{range_check_ptr, pedersen_ptr: HashBuiltin*, point_attribute: DictAccess*}(map: Map, node_grid) -> (felt, felt*) {
    alloc_locals;
    let relevant_neighbours: Point* = alloc(); 
    local relevant_neighbours_len = 0;

    // ↑
    let s0 = is_walkable_at(map.grids, map.width * map.height, node_grid - map.width);
    let (relevant_neighbours_len) = check_and_add_point(map, node_grid - map.width, node_grid - map.width, TRUE, relevant_neighbours_len, relevant_neighbours);

    // →
    let s1 = is_walkable_at(map.grids, map.width * map.height, node_grid + 1);
    let (relevant_neighbours_len) = check_and_add_point(map, node_grid + 1, node_grid + 1, TRUE, relevant_neighbours_len, relevant_neighbours);

    // ↓
    let s2 = is_walkable_at(map.grids, map.width * map.height, node_grid + map.width);
    let (relevant_neighbours_len) = check_and_add_point(map, node_grid + map.width, node_grid + map.width, TRUE, relevant_neighbours_len, relevant_neighbours);

    // ←
    let s3 = is_walkable_at(map.grids, map.width * map.height, node_grid - 1);
    let (relevant_neighbours_len) = check_and_add_point(map, node_grid - 1, node_grid - 1, TRUE, relevant_neighbours_len, relevant_neighbours);
    
    tempvar d0 = _or(s3, s0);
    tempvar d1 = _or(s0, s1);
    tempvar d2 = _or(s1, s2);
    tempvar d3 = _or(s2, s3);

    // ↖
    let is_walkable = is_walkable_at(map.grids, map.width * map.height, node_grid - 1 - map.width);
    let is_walkable_and_can_do_diagonal = _and(d0, is_walkable);
    if (is_walkable_and_can_do_diagonal == TRUE) {
        let (relevant_neighbours_len) = check_and_add_point(map, node_grid - 1 - map.width, node_grid - 1 - map.width, TRUE, relevant_neighbours_len, relevant_neighbours);
    } else {
        tempvar range_check_ptr = range_check_ptr;
        tempvar relevant_neighbours_len = relevant_neighbours_len;
    }
    tempvar range_check_ptr = range_check_ptr;
    tempvar relevant_neighbours_len = relevant_neighbours_len;
    
    // ↗
    let is_walkable = is_walkable_at(map.grids, map.width * map.height, node_grid + 1 - map.width);
    let is_walkable_and_can_do_diagonal = _and(d1, is_walkable);
    if (is_walkable_and_can_do_diagonal == TRUE) {
        let (relevant_neighbours_len) = check_and_add_point(map, node_grid + 1 - map.width, node_grid + 1 - map.width, TRUE, relevant_neighbours_len, relevant_neighbours);
    } else {
        tempvar range_check_ptr = range_check_ptr;
        tempvar relevant_neighbours_len = relevant_neighbours_len;
    }
    tempvar range_check_ptr = range_check_ptr;
    tempvar relevant_neighbours_len = relevant_neighbours_len;
    
    // ↘
    let is_walkable = is_walkable_at(map.grids, map.width * map.height, node_grid + 1 + map.width);
    let is_walkable_and_can_do_diagonal = _and(d2, is_walkable);
    if (is_walkable_and_can_do_diagonal == TRUE) {
        let (relevant_neighbours_len) = check_and_add_point(map,node_grid + 1 + map.width, node_grid + 1 + map.width, TRUE, relevant_neighbours_len, relevant_neighbours);
    } else {
        tempvar range_check_ptr = range_check_ptr;
        tempvar relevant_neighbours_len = relevant_neighbours_len;
    }
    tempvar range_check_ptr = range_check_ptr;
    tempvar relevant_neighbours_len = relevant_neighbours_len;
    
    // ↙
    let is_walkable = is_walkable_at(map.grids, map.width * map.height, node_grid - 1 + map.width);
    let is_walkable_and_can_do_diagonal = _and(d3, is_walkable);
    if (is_walkable_and_can_do_diagonal == TRUE) {
        let (relevant_neighbours_len) = check_and_add_point(map, node_grid - 1 + map.width, node_grid - 1 + map.width, TRUE, relevant_neighbours_len, relevant_neighbours);
    } else {
        tempvar range_check_ptr = range_check_ptr;
        tempvar relevant_neighbours_len = relevant_neighbours_len;
    }
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
func check_and_add_point{range_check_ptr}(map: Map, node_grid_id: felt, candidate_grid: felt, walkable_condition: felt, relevant_neighbours_len: felt, relevant_neighbours: felt*) -> (felt) {
    let is_walkable = is_walkable_at(map.grids, map.width * map.height, node_grid_id);
    if (is_walkable == walkable_condition) {
        %{
            from requests import post
            json = { # creating the body of the post request so it's printed in the python script
                "check_and_add_point": f"adding {ids.candidate_grid}"
            }
            post(url="http://localhost:5000", json=json) # sending the request to our small "server"
        %}
        assert relevant_neighbours[relevant_neighbours_len] = candidate_grid;
        return (relevant_neighbours_len + 1,);
    } else {
        return (relevant_neighbours_len,);
    }
}

func check_and_add_point_double_and_condition{range_check_ptr}(map: Map, first_grid_id: felt, second_grid_id: felt, candidate_grid: felt, relevant_neighbours_len: felt, relevant_neighbours: felt*) -> (felt){
    alloc_locals;
    let is_walkable_first = is_walkable_at(map.grids, map.width * map.height, first_grid_id);
    let is_walkable_second = is_walkable_at(map.grids, map.width * map.height, second_grid_id);
    let meet_conditions = _and(_not(is_walkable_first), is_walkable_second);

    if (meet_conditions == TRUE) {
        %{
            from requests import post
            json = { # creating the body of the post request so it's printed in the python script
                "check_and_add_point_or_condition": f"adding {ids.candidate_grid}"
            }
            post(url="http://localhost:5000", json=json) # sending the request to our small "server"
        %}
        assert relevant_neighbours[relevant_neighbours_len] = candidate_grid;
        return (relevant_neighbours_len + 1,);
    } else {
        return (relevant_neighbours_len,);
    }
}

func check_and_add_point_double_or_condition{range_check_ptr}(map: Map, first_grid_id: felt, second_grid_id: felt, candidate_grid: felt, relevant_neighbours_len: felt, relevant_neighbours: felt*) -> (felt){
    alloc_locals;
    let is_walkable_first = is_walkable_at(map.grids, map.width * map.height, first_grid_id);
    let is_walkable_second = is_walkable_at(map.grids, map.width * map.height, second_grid_id);
    let meet_conditions = _or(is_walkable_first, is_walkable_second);
    
    let candidate_is_walkable = is_walkable_at(map.grids, map.width * map.height, candidate_grid);
    if (candidate_is_walkable == FALSE) {
        return (relevant_neighbours_len,);
    }

    if (meet_conditions == TRUE) {
        %{
            from requests import post
            json = { # creating the body of the post request so it's printed in the python script
                "check_and_add_point_and_condition": f"adding {ids.candidate_grid}"
            }
            post(url="http://localhost:5000", json=json) # sending the request to our small "server"
        %}
        assert relevant_neighbours[relevant_neighbours_len] = candidate_grid;
        return (relevant_neighbours_len + 1,);
    } else {
        return (relevant_neighbours_len,);
    }
}
