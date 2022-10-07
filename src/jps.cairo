%lang starknet
from starkware.cairo.common.math_cmp import is_in_range, is_not_zero, is_le
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.dict import dict_write, dict_update, dict_read, DictAccess
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.math import abs_value
from starkware.cairo.common.registers import get_fp_and_pc


from src.utils.condition import _or, _and, _not, _equals
from src.utils.dictionary import add_entries, create_dict, read_entry, update_entry, write_entry
from src.models.heuristic import octile, manhattan
from src.models.map import Map, get_point_by_position, get_neighbours, is_inside_of_map, is_walkable_at
from src.models.movement import Movement
from src.models.point import Point, point_equals, set_point_attribute, get_point_attribute, build_reverse_path_from, convert_coords_to_id
from src.models.point_status import OPENED, CLOSED
from src.models.point_attribute import STATUS, DISTANCE_TRAVELED, PARENT, DISTANCE_TO_GOAL, ESTIMATED_TOTAL_PATH_DISTANCE, UNDEFINED


func find_path{pedersen_ptr: HashBuiltin*, range_check_ptr, dict_ptr: DictAccess*}(start_x: felt, start_y: felt, end_x: felt, end_y: felt, map: Map) -> (felt, Point*) {
    alloc_locals;
    let dict_ptr: DictAccess* = create_dict(UNDEFINED);
    let open_list: Point* = alloc();
    let open_list_lenght = 0;

    let start_is_walkable = is_walkable_at(map, start_x, start_y);
    let end_is_walkable = is_walkable_at(map, end_x, end_y);
    let start_or_end_are_not_walkable = _or(_not(start_is_walkable), _not(end_is_walkable));
    if (start_or_end_are_not_walkable == TRUE) {
        return (open_list_lenght, open_list);
    }

    let start_point = Point(start_x, start_y, TRUE);
    let end_point = Point(end_x, end_y, TRUE);
    
    set_point_attribute{dict_ptr=dict_ptr}(start_point, STATUS, OPENED);

    assert open_list[0] = start_point;
    let open_list_lenght = 1;

    return find_path_internal{pedersen_ptr=pedersen_ptr, range_check_ptr=range_check_ptr, dict_ptr=dict_ptr}(map, open_list, open_list_lenght, end_point);
}

func find_path_internal{pedersen_ptr: HashBuiltin*, range_check_ptr, dict_ptr: DictAccess*}(map: Map, open_list: Point*, open_list_lenght: felt, goal: Point) -> (felt, Point*) {
    if (open_list_lenght == 0) {
        // %{
        //     from requests import post
        //     json = { # creating the body of the post request so it's printed in the python script
        //         "message": f"Nada mas que revisar, bye :( "
        //     }
        //     post(url="http://localhost:5000", json=json) # sending the request to our small "server"
        // %}
        let empty_list: Point* = alloc();
        return (0, empty_list);
    }

    let node = [open_list];

    if (node.x == goal.x and node.y == goal.y) {
        return build_reverse_path_from(node, map.width);
    }

    identify_successors{open_list=open_list, open_list_lenght=open_list_lenght}(node, goal, map);
    return find_path_internal(map, open_list + Point.SIZE, open_list_lenght - 1, goal);
}

func identify_successors{pedersen_ptr: HashBuiltin*, range_check_ptr, dict_ptr: DictAccess*, open_list: Point*, open_list_lenght}(parent: Point, goal: Point, map: Map) {
    set_point_attribute{pedersen_ptr=pedersen_ptr, dict_ptr=dict_ptr}(parent, STATUS, CLOSED);
    let (neighbours_lenght: felt, neighbours: Point*) = get_neighbours(map, parent);
    return identify_successors_internal(neighbours, neighbours_lenght, parent, goal, map);
}

func identify_successors_internal{pedersen_ptr: HashBuiltin*, range_check_ptr, dict_ptr: DictAccess*, open_list: Point*, open_list_lenght}(neighbours: Point*, neighbours_lenght: felt, parent: Point, goal: Point, map: Map) {
    alloc_locals;
    let (local __fp__, _) = get_fp_and_pc();
    if (neighbours_lenght == 0) {
        return ();
    }
    let jump_point = jump([neighbours].x, [neighbours].y, parent.x, parent.y, map, goal);
    tempvar invalid_jump_point = point_equals(jump_point, Point(-1, -1, -1));

    if (invalid_jump_point == FALSE) {
        tempvar jump_status = get_point_attribute(jump_point, STATUS);
        
        if (jump_status == CLOSED) {
            return identify_successors_internal(neighbours + Point.SIZE, neighbours_lenght - 1, parent, goal, map);
        } 
        let estimated_distance = manhattan(abs_value(jump_point.x - [neighbours].x), abs_value(jump_point.y - [neighbours].y)); 
        tempvar g_value = get_point_attribute([neighbours], DISTANCE_TRAVELED);
        tempvar next_g = g_value + estimated_distance;

        tempvar jump_g_value = get_point_attribute(jump_point, DISTANCE_TRAVELED);
        tempvar jump_g_is_bigger = is_le(next_g, jump_g_value + 1); // ng < jg
        tempvar j_is_not_opened = _not(_equals(jump_status, OPENED)); // !opened
        tempvar is_valid_add_jump_point = _or(jump_g_is_bigger, j_is_not_opened);
        if (is_valid_add_jump_point == TRUE) {
            set_point_attribute(jump_point, DISTANCE_TRAVELED, next_g);
            let parent_id = convert_coords_to_id(parent.x, parent.y, map.width);
            set_point_attribute(jump_point, PARENT, parent_id);
            
            let jump_point_attribute_h = get_point_attribute(jump_point, DISTANCE_TO_GOAL);
            if (jump_point_attribute_h == UNDEFINED) {
                let jump_h_value = manhattan(abs_value(jump_point.x - goal.x), abs_value(jump_point.y - goal.y));
                set_point_attribute(jump_point, DISTANCE_TO_GOAL, jump_h_value);
                //set_point_attribute(jump_point, ESTIMATED_TOTAL_PATH_DISTANCE, jump_g_value + jump_h_value);

                tempvar pedersen_ptr = pedersen_ptr;
                tempvar range_check_ptr = range_check_ptr;
                tempvar dict_ptr = dict_ptr;
                tempvar open_list_lenght = open_list_lenght;
            } else {
                //set_point_attribute(jump_point, ESTIMATED_TOTAL_PATH_DISTANCE, jump_g_value + jump_point_attribute_h);
                tempvar pedersen_ptr = pedersen_ptr;
                tempvar range_check_ptr = range_check_ptr;
                tempvar dict_ptr = dict_ptr;
                tempvar open_list_lenght = open_list_lenght;
            }

            tempvar pedersen_ptr = pedersen_ptr;
            tempvar range_check_ptr = range_check_ptr;
            tempvar dict_ptr = dict_ptr;
            tempvar open_list_lenght = open_list_lenght;
            
            if (j_is_not_opened == TRUE) {
                assert open_list[open_list_lenght] = jump_point;
                set_point_attribute(jump_point, STATUS, OPENED);
                // %{
                //     from requests import post
                //     json = { # creating the body of the post request so it's printed in the python script
                //         "message": f"Dentro de identify successors  ",
                //         "open_list_lenght": f"{ids.open_list_lenght}",
                //         "(x, y)": f"({ids.jump_point.x}, {ids.jump_point.y}) status: {ids.jump_status}"
                //     }
                //     post(url="http://localhost:5000", json=json) # sending the request to our small "server"
                // %}

                tempvar pedersen_ptr = pedersen_ptr;
                tempvar range_check_ptr = range_check_ptr;
                tempvar dict_ptr = dict_ptr;
                tempvar open_list_lenght = open_list_lenght + 1;
            } else {
                tempvar pedersen_ptr = pedersen_ptr;
                tempvar range_check_ptr = range_check_ptr;
                tempvar dict_ptr = dict_ptr;
                tempvar open_list_lenght = open_list_lenght;
            }
        } else {
            tempvar pedersen_ptr = pedersen_ptr;
            tempvar range_check_ptr = range_check_ptr;
            tempvar dict_ptr = dict_ptr;
            tempvar open_list_lenght = open_list_lenght;
        }
    } else {
        tempvar pedersen_ptr = pedersen_ptr;
        tempvar range_check_ptr = range_check_ptr;
        tempvar dict_ptr = dict_ptr;
        tempvar open_list_lenght = open_list_lenght;
    }

    return identify_successors_internal(neighbours + Point.SIZE, neighbours_lenght - 1, parent, goal, map);
}

// Definition 2. Node y is the jump point from node x, heading in direction ~d, if y minimizes the value k such that y = x+k~d
// and one of the following conditions holds:
// 1. Node y is the goal node.
// 2. Node y has at least one neighbour whose evaluation is forced according to Definition 1.
// 3. ~d is a diagonal move and there exists a node z = y +ki~di
// which lies ki ∈ N steps in direction ~di ∈ { ~d1,~d2} such that z is a jump point from y by condition 1 or condition 2.
func jump{range_check_ptr, pedersen_ptr: HashBuiltin*}(x: felt, y: felt, px: felt, py: felt, map: Map, end_node: Point) -> Point {
    alloc_locals;

    let is_walkable = is_walkable_at(map, x, y);
    if (is_walkable == FALSE) {
        let invalid_point = Point(-1, -1, -1);
        return invalid_point;
    }
    let node = get_point_by_position(map, x, y);
    if(node.x == end_node.x and node.y == end_node.y) {
        return node;
    }

    tempvar dx = x - px;
    tempvar dy = y - py;
    tempvar is_diagonal_a_move = _and(abs_value(dx), abs_value(dy));

    if (is_diagonal_a_move == 1) {
        let p1 = is_walkable_at(map, x - dx, y + dy);
        let p2 = is_walkable_at(map, x - dx, y);
        let p3 = is_walkable_at(map, x + dx, y - dy);
        let p4 = is_walkable_at(map, x, y - dy);

        tempvar cond1 = _and(p1, _not(p2));
        tempvar cond2 = _and(p3, _not(p4));
        tempvar has_forced_neighbours = _or(cond1, cond2);

        if(has_forced_neighbours == TRUE) {
            return node;
        }

        // We check if horizontal jump point obtained has not an invalid position in X (could be x, y or walkable value)
        let horizontal_recursion_point = jump(x + dx, y, x, y, map, end_node);
        if(horizontal_recursion_point.x != -1) {
            return node;
        }

        // We check if vertical jump point obtained has not an invalid position in X (could be x, y or walkable value)
        let vertical_recursion_point = jump(x, y + dy, x, y, map, end_node);
        if(vertical_recursion_point.x != -1) {
            return node;
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
                return node;
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
                return node;
            }
            tempvar range_check_ptr = range_check_ptr;
            tempvar pedersen_ptr = pedersen_ptr;
        }
    }
    // Jump forward in original direction
    return jump(x + dx, y + dy, x, y, map, end_node);
}

