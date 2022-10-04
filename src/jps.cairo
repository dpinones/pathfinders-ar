%lang starknet
from starkware.cairo.common.math_cmp import is_in_range, is_not_zero
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE

from src.utils.condition import _or, _and, _not, _abs
from src.models.map import Map, get_point_by_position, get_neighbours, is_inside_of_map, is_walkable_at
from src.models.movement import Movement
from src.models.point import Point, PointWithParent, point_equals
from src.models.point_status import OPEN, CLOSED

func find_path{range_check_ptr}(start_x: felt, start_y: felt, end_x: felt, end_y: felt, map: Map) -> (felt, PointWithParent*) {
    alloc_locals;
    
    let open_list: PointWithParent* = alloc();
    let open_list_lenght = 0;
    let end_point = Point(end_x, end_y, TRUE);

    // Check if first and end are walkable
    local point: PointWithParent;
    assert point.x = start_x;
    assert point.y = start_y;
    assert point.walkable = TRUE; 
    assert point.status = OPEN;

    assert open_list[0] = point;

    return find_path_internal(map, open_list, open_list_lenght, end_point);
}

func find_path_internal{range_check_ptr}(map: Map, open_list: PointWithParent*, open_list_lenght: felt, goal: Point) -> (felt, PointWithParent*) {
    if (open_list_lenght == 0) {
        let empty_list: PointWithParent* = alloc();
        return (0, empty_list);
    }

    let node = [open_list];
    if (node.x == goal.x and node.y == goal.y) {
        let empty_list: PointWithParent* = alloc();
        return (0, empty_list);
        //return build_backtrace(node);
    }

    identify_successors{open_list = open_list, open_list_lenght = open_list_lenght}(node, goal, map);
    return find_path_internal(map, open_list, open_list_lenght, goal);
}

func identify_successors{open_list: PointWithParent*, open_list_lenght: felt, range_check_ptr}(parent: PointWithParent, goal: Point, map: Map) {
    let point = Point(parent.x, parent.y, parent.walkable);
    let (neighbours_lenght: felt, neighbours: Point*) = get_neighbours(map, point);
    return identify_successors_internal(neighbours, neighbours_lenght, parent, goal, map);
}

func identify_successors_internal{open_list: PointWithParent*, open_list_lenght: felt, range_check_ptr}(neighbours: Point*, neighbours_lenght: felt, parent: PointWithParent, goal: Point, map: Map) {
    alloc_locals;
    if (neighbours_lenght == 0) {
        return ();
    }
    let jump_point = jump([neighbours].x, [neighbours].y, parent.x, parent.y, map, goal);
    let invalid_jump_point = point_equals(jump_point, Point(-1, -1, -1));

    if (invalid_jump_point == FALSE) {

        let jx = jump_point.x;
        let jy = jump_point.y;



        
    }

    return ();
}

// Definition 2. Node y is the jump point from node x, heading in direction ~d, if y minimizes the value k such that y = x+k~d
// and one of the following conditions holds:
// 1. Node y is the goal node.
// 2. Node y has at least one neighbour whose evaluation is forced according to Definition 1.
// 3. ~d is a diagonal move and there exists a node z = y +ki~di
// which lies ki ∈ N steps in direction ~di ∈ { ~d1,~d2} such that z is a jump point from y by condition 1 or condition 2.
func jump{range_check_ptr}(x: felt, y: felt, px: felt, py: felt, map: Map, end_node: Point) -> Point {
    alloc_locals;

    let is_walkable = is_walkable_at(map, x, y);
    if (is_walkable == FALSE) {
        tempvar invalid_point = Point(-1, -1, -1);
        return invalid_point;
    }
    
    let node = get_point_by_position(map, x, y);
    if(node.x == end_node.x and node.y == end_node.y) {
        return node;
    }

    tempvar dx = x - px;
    tempvar dy = y - py;
    tempvar is_diagonal_a_move = _and(_abs(dx), _abs(dy));

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
        }
    }
    // Jump forward in original direction
    return jump(x + dx, y + dy, x, y, map, end_node);
}

