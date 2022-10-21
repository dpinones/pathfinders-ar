%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.dict import DictAccess
from starkware.cairo.common.math import abs_value
from starkware.cairo.common.math_cmp import is_le

from src.constants.point_status import OPENED, CLOSED
from src.constants.point_attribute import STATUS, DISTANCE_TRAVELED, PARENT, DISTANCE_TO_GOAL, ESTIMATED_TOTAL_PATH_DISTANCE, UNDEFINED
from src.models.heuristic import manhattan, octile
from src.models.map import Map, get_neighbours, is_walkable_at
from src.models.movement import get_movement_direction_coords
from src.models.point import Point, point_equals, set_point_attribute, get_point_attribute, build_reverse_path_from
from src.utils.condition import _or, _and, _not, _equals
from src.utils.dictionary import create_attribute_dict
from src.utils.min_heap_custom import heap_create, add, poll
from src.utils.point_converter import convert_coords_to_id, convert_id_to_coords

func find_path{pedersen_ptr: HashBuiltin*, range_check_ptr, point_attribute: DictAccess*,  heap: DictAccess*}(start_x: felt, start_y: felt, goal_x: felt, goal_y: felt, map: Map) -> (felt, Point*) {
    alloc_locals;
    let (heap: DictAccess*, heap_len: felt) = heap_create();
    let point_attribute: DictAccess* = create_attribute_dict();

    let start_is_walkable = is_walkable_at(map, start_x, start_y);
    let end_is_walkable = is_walkable_at(map, goal_x, goal_y);
    let start_or_end_are_not_walkable = _or(_not(start_is_walkable), _not(end_is_walkable));
    if (start_or_end_are_not_walkable == TRUE) {
        let empty_list: Point* = alloc();
        return (0, empty_list);
    }

    let start_id = convert_coords_to_id(start_x, start_y, map.width);
    let distance_to_goal = manhattan(abs_value(start_x - goal_x), abs_value(start_y - goal_y)); 
    set_point_attribute{point_attribute=point_attribute}(start_id, STATUS, OPENED);
    let heap_len = add(heap_len, start_id, distance_to_goal);

    return _find_path{pedersen_ptr=pedersen_ptr, range_check_ptr=range_check_ptr, point_attribute=point_attribute, heap=heap}(map, goal_x, goal_y, heap_len);
}

func _find_path{pedersen_ptr: HashBuiltin*, range_check_ptr, point_attribute: DictAccess*, heap: DictAccess*}(map: Map, goal_x: felt, goal_y: felt, heap_len: felt) -> (felt, Point*) {
    alloc_locals;
    if (heap_len == 0) {
        let empty_list: Point* = alloc();
        return (0, empty_list);
    }

    let (node_id, _, new_heap_len) = poll(heap_len);
    let (node_x, node_y) = convert_id_to_coords(node_id, map.width);
    if (node_x == goal_x and node_y == goal_y) {
        return build_reverse_path_from(node_id, map.width);
    }

    identify_successors{heap_len = new_heap_len}(node_id, node_x, node_y, goal_x, goal_y, map);
    return _find_path(map, goal_x, goal_y, new_heap_len);
}

func identify_successors{pedersen_ptr: HashBuiltin*, range_check_ptr, point_attribute: DictAccess*, heap: DictAccess*, heap_len}(node_id: felt, node_x: felt, node_y: felt, goal_x: felt, goal_y: felt, map: Map) {
    set_point_attribute{pedersen_ptr=pedersen_ptr, point_attribute=point_attribute}(node_id, STATUS, CLOSED);
        //         %{
        //     from requests import post
        //     json = { # creating the body of the post request so it's printed in the python script
        //         "setting close status": f"{ids.node_id} CLOSED"
        //     }
        //     post(url="http://localhost:5000", json=json) # sending the request to our small "server"
        // %}
    let (neighbours_lenght: felt, neighbours: felt*) = get_neighbours(map, node_id);
    return _identify_successors(neighbours, neighbours_lenght, node_x, node_y, goal_x, goal_y, map);
}

func _identify_successors{pedersen_ptr: HashBuiltin*, range_check_ptr, point_attribute: DictAccess*, heap: DictAccess*, heap_len}(neighbours: felt*, neighbours_lenght: felt, parent_x: felt, parent_y: felt, goal_x: felt, goal_y: felt, map: Map) {
    alloc_locals;
    if (neighbours_lenght == 0) {
        return ();
    }
    let (x, y) = convert_id_to_coords([neighbours], map.width);
    let jump_point = jump(x, y, parent_x, parent_y, goal_x, goal_y, map);

    if (jump_point != UNDEFINED) {
        let jump_status = get_point_attribute(jump_point, STATUS);
        if (jump_status == CLOSED) {
            return _identify_successors(neighbours + 1, neighbours_lenght - 1, parent_x, parent_y, goal_x, goal_y, map);
        } 

        let (jx, jy) = convert_id_to_coords(jump_point, map.width);
        let parent_id = convert_coords_to_id(parent_x, parent_y, map.width);
        let estimated_distance_to_jump_point = manhattan(abs_value(jx - parent_x), abs_value(jy - parent_y)); 
        let g_value = get_point_attribute(parent_id, DISTANCE_TRAVELED);
        tempvar next_g = g_value + estimated_distance_to_jump_point;

        let jump_g_value = get_point_attribute(jump_point, DISTANCE_TRAVELED);
        tempvar jump_g_is_bigger = is_le(next_g, jump_g_value + 1); // ng < jg
        tempvar j_is_not_opened = _equals(jump_status, UNDEFINED); // !opened
        tempvar is_valid_add_jump_point = _or(jump_g_is_bigger, j_is_not_opened);
        if (is_valid_add_jump_point == TRUE) {
            set_point_attribute(jump_point, DISTANCE_TRAVELED, next_g);
            set_point_attribute(jump_point, PARENT, parent_id);
            
            let jump_point_attribute_h = get_point_attribute(jump_point, DISTANCE_TO_GOAL);
            if (jump_point_attribute_h == UNDEFINED) {
                let jump_h_value = manhattan(abs_value(jx - goal_x), abs_value(jy - goal_y));
                set_point_attribute(jump_point, DISTANCE_TO_GOAL, jump_h_value);
                set_point_attribute(jump_point, ESTIMATED_TOTAL_PATH_DISTANCE, next_g + jump_h_value);

                tempvar pedersen_ptr = pedersen_ptr;
                tempvar range_check_ptr = range_check_ptr;
                tempvar point_attribute = point_attribute;
                tempvar heap = heap;
                tempvar heap_len = heap_len;
            } else {
                set_point_attribute(jump_point, ESTIMATED_TOTAL_PATH_DISTANCE, next_g + jump_point_attribute_h);
                tempvar pedersen_ptr = pedersen_ptr;
                tempvar range_check_ptr = range_check_ptr;
                tempvar point_attribute = point_attribute;
                tempvar heap = heap;
                tempvar heap_len = heap_len;
            }

            tempvar pedersen_ptr = pedersen_ptr;
            tempvar range_check_ptr = range_check_ptr;
            tempvar point_attribute = point_attribute;
            tempvar heap = heap;
            tempvar heap_len = heap_len;
            if (j_is_not_opened == TRUE) {
                let jump_f_value = get_point_attribute(jump_point, ESTIMATED_TOTAL_PATH_DISTANCE);
                let new_heap_lengh = add(heap_len, jump_point, jump_f_value);
                set_point_attribute(jump_point, STATUS, OPENED);
                
                tempvar pedersen_ptr = pedersen_ptr;
                tempvar range_check_ptr = range_check_ptr;
                tempvar point_attribute = point_attribute;
                tempvar heap = heap;
                tempvar heap_len = heap_len + 1;
            } else {
                return _identify_successors(neighbours + 1, neighbours_lenght - 1, parent_x, parent_y, goal_x, goal_y, map);
            }
        } else {
            return _identify_successors(neighbours + 1, neighbours_lenght - 1, parent_x, parent_y, goal_x, goal_y, map);
        }
    } else {
        return _identify_successors(neighbours + 1, neighbours_lenght - 1, parent_x, parent_y, goal_x, goal_y, map);
    }
    return _identify_successors(neighbours + 1, neighbours_lenght - 1, parent_x, parent_y, goal_x, goal_y, map);
}

// Definition 2. Node y is the jump point from node x, heading in direction ~d, if y minimizes the value k such that y = x+k~d
// and one of the following conditions holds:
// 1. Node y is the goal node.
// 2. Node y has at least one neighbour whose evaluation is forced according to Definition 1.
// 3. ~d is a diagonal move and there exists a node z = y +ki~di
// which lies ki ∈ N steps in direction ~di ∈ { ~d1,~d2} such that z is a jump point from y by condition 1 or condition 2.
func jump{range_check_ptr, pedersen_ptr: HashBuiltin*}(x: felt, y: felt, px: felt, py: felt, goal_x: felt, goal_y: felt, map: Map) -> felt {
    alloc_locals;

    let is_walkable = is_walkable_at(map, x, y);
    if (is_walkable == FALSE) {
        return UNDEFINED;
    }

    if(x == goal_x and y == goal_y) {
        let grid_id = convert_coords_to_id(x, y, map.width);
        return grid_id;
    }

    let (dx, dy) = get_movement_direction_coords(x, y, px, py);
    tempvar is_diagonal_a_move = _and(abs_value(dx), abs_value(dy));

    if (is_diagonal_a_move == TRUE) {
        let p1 = is_walkable_at(map, x - dx, y + dy);
        let p2 = is_walkable_at(map, x - dx, y);
        let p3 = is_walkable_at(map, x + dx, y - dy);
        let p4 = is_walkable_at(map, x, y - dy);

        tempvar cond1 = _and(p1, _not(p2));
        tempvar cond2 = _and(p3, _not(p4));
        tempvar has_forced_neighbours = _or(cond1, cond2);

        if(has_forced_neighbours == TRUE) {
            let grid_id = convert_coords_to_id(x, y, map.width);
            return grid_id;
        }

        // We check if horizontal jump point obtained has not an invalid position in X (could be x, y or walkable value)
        let horizontal_recursion_grid = jump(x + dx, y, x, y, goal_x, goal_y, map);
        if(horizontal_recursion_grid != UNDEFINED) {
            let grid_id = convert_coords_to_id(x, y, map.width);
            return grid_id;
        }

        // We check if vertical jump point obtained has not an invalid position in X (could be x, y or walkable value)
        let vertical_recursion_grid = jump(x, y + dy, x, y, goal_x, goal_y, map);
        if(vertical_recursion_grid != UNDEFINED) {
            let grid_id = convert_coords_to_id(x, y, map.width);
            return grid_id;
        } 
        tempvar range_check_ptr = range_check_ptr;
        tempvar pedersen_ptr = pedersen_ptr;
    } else {
        if (dx != 0) {
            let p1 = is_walkable_at(map, x + dx, y + 1);
            let p2 = is_walkable_at(map, x, y + 1);
            let p3 = is_walkable_at(map, x + dx, y - 1);
            let p4 = is_walkable_at(map, x, y - 1);

            tempvar cond1 = _and(p1, _not(p2));
            tempvar cond2 = _and(p3, _not(p4));
            tempvar has_forced_neighbours = _or(cond1, cond2);

            if(has_forced_neighbours == TRUE) {
                let grid_id = convert_coords_to_id(x, y, map.width);
                return grid_id;
            }
            tempvar range_check_ptr = range_check_ptr;
            tempvar pedersen_ptr = pedersen_ptr;
        } else {    
            let p1 = is_walkable_at(map, x + 1, y + dy);
            let p2 = is_walkable_at(map, x + 1, y);
            let p3 = is_walkable_at(map, x - 1, y + dy);
            let p4 = is_walkable_at(map, x - 1, y);

            local cond1 = _and(p1, _not(p2));
            local cond2 = _and(p3, _not(p4));
            tempvar has_forced_neighbours = _or(cond1, cond2);

            if(has_forced_neighbours == TRUE) {
                let grid_id = convert_coords_to_id(x, y, map.width);
                return grid_id;
            }
            tempvar range_check_ptr = range_check_ptr;
            tempvar pedersen_ptr = pedersen_ptr;
        }
    }
    
    tempvar range_check_ptr = range_check_ptr;
    tempvar pedersen_ptr = pedersen_ptr;

    let is_walkable_in_dx = is_walkable_at(map, x + dx, y); 
    let is_walkable_in_dy = is_walkable_at(map, x, y + dy); 
    let is_walkable_in_dx_or_dy = _or(is_walkable_in_dx, is_walkable_in_dy);
    if (is_walkable_in_dx_or_dy == TRUE) {
        return jump(x + dx, y + dy, x, y, goal_x, goal_y, map);
    } else {
        return UNDEFINED;
    }
}

