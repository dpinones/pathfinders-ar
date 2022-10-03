%lang starknet
from starkware.cairo.common.math_cmp import is_in_range, is_not_zero
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc

from src.utils.condition import _or, _and, _not, _abs
from src.models.point import Point
from src.models.movement import Movement
from src.models.map import Map, get_point_by_position, get_neighbours, is_inside_of_map

func identify_successors() -> (res: felt) {
    // let (successors: Point*) = alloc();
    // let (neighbours: Point*) = alloc();
    
    // neighbours = prune(x, neighbours);
    let res = 0;
    return (res,);
}

func prune{range_check_ptr}(map: Map, node: Point, movement: Movement, neighbours: Point*) -> (res: Point*) {
    let (len_res, all_neighbours: Point*) = get_all_neighbours_of(map, node);
    let (res: Point*) = alloc();
    return (res,);
}

func jump{range_check_ptr}(x: felt, y: felt, px: felt, py: felt, map: Map, end_node: Point) -> Point {
    alloc_locals;

    let is_in_map = is_inside_of_map(map, x, y);
    
    if (is_in_map == 0) {
        let point = Point(-1, -1, -1);
        return point;
    }

    let point = get_point_by_position(map, x, y);
    if(point.walkable == 0) {
        let point = Point(-1, -1, -1);
        return point;
    }

    // si es caminable, fijarse si es el nodo final, pedir el nodo con (x, y)?
    let node = get_point_by_position(map, x, y);

    // assert node.x = 100;
    // assert node.y = 100;
    // assert end_node.x = 100;
    // assert end_node.y = 100;
    
    if(node.x == end_node.x and node.y == end_node.y) {
        return node;
    }

    // reviso los vecinos forzados de forma diagonal
    let dx = x - px;
    let dy = y - py;

    // assert dx = 100;
    // assert dy = 100;

    // tempvar is_diagonal_move = _and(_abs(dx), _abs(dy));
    // assert is_diagonal_move = 100;

    // if (dx !== 0 && dy !== 0) {
    let cond_1 = is_not_zero(dx);
    let cond_2 = is_not_zero(dy);
    let is_diagonal_move = _and(cond_1, cond_2); 

    // if (is_diagonal_move == 1) {
    if (is_diagonal_move == 1) {
        let p1 = get_point_by_position(map, x - dx, y + dy);
        let p2 = get_point_by_position(map, x - dx, y);
        let p3 = get_point_by_position(map, x + dx, y - dy);
        let p4 = get_point_by_position(map, x, y - dy);

        let cond1 = _and(p1.walkable, _not(p2.walkable));
        let cond2 = _and(p3.walkable, _not(p4.walkable));
        let cond_final = _or(cond1, cond2);

        // assert cond_final = 100;
        if(cond_final == 1) {
            return node;
        }

        let point_rec_1 = jump(x + dx, y, x, y, map, end_node);
        assert point_rec_1.x = 100;
        if(point_rec_1.x != -1) {
            return node;
        }

        let point_rec_2 = jump(x, y + dy, x, y, map, end_node);
        if(point_rec_2.x != -1) {
            return node;
        } 
        tempvar range_check_ptr = range_check_ptr;
    } else {
        if (dx != 0) {
            let p1 = get_point_by_position(map, x + dx, y + 1);
            let p2 = get_point_by_position(map, x, y + 1);
            let p3 = get_point_by_position(map, x + dx, y - 1);
            let p4 = get_point_by_position(map, x, y - 1);

            let cond1 = _and(p1.walkable, _not(p2.walkable));
            let cond2 = _and(p3.walkable, _not(p4.walkable));
            let cond_final = _or(cond1, cond2);

            if(cond_final == 1) {
                return node;
            }
            tempvar range_check_ptr = range_check_ptr;
        } else {    
            let p1 = get_point_by_position(map, x + 1, y + dy);
            let p2 = get_point_by_position(map, x + 1, y);
            let p3 = get_point_by_position(map, x - 1, y + dy);
            let p4 = get_point_by_position(map, x - 1, y);

            let cond1 = _and(p1.walkable, _not(p2.walkable));
            let cond2 = _and(p3.walkable, _not(p4.walkable));
            let cond_final = _or(cond1, cond2);

            if(cond_final == 1) {
                return node;
            }
            tempvar range_check_ptr = range_check_ptr;
        }
    }
    return jump(x + dx, y + dy, x, y, map, end_node);
}
