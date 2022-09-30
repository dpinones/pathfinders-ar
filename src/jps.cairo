%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc

from src.data import Point, Movement, Map, get_point_by_position

@view
func identify_successors{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt) {
    // let (successors: Point*) = alloc();
    // let (neighbours: Point*) = alloc();
    
    // neighbours = prune(x, neighbours);
    let res = 0;
    return (res,);
}

func prune{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(map: Map, node: Point, movement: Movement, neighbours: Point*) -> (res: Point*) {
    let (len_res, all_neighbours: Point*) = get_all_neighbours_of(map, node);
    let (res: Point*) = alloc();
    return (res,);
}

func get_all_neighbours_of{range_check_ptr}(map: Map, node: Point) -> (len_res: felt, res: Point*) {
    alloc_locals;
    let (res: Point*) = alloc();
    let len_res = 0;



    let neighbour = get_point_by_position(map, node.x + 1, node.y);
    assert res[0] =  neighbour;
    
    let neighbour = get_point_by_position(map, node.x - 1, node.y);
    assert res[1] =  neighbour;
    
    let neighbour = get_point_by_position(map, node.x, node.y + 1);
    assert res[2] =  neighbour;
    
    let neighbour = get_point_by_position(map, node.x, node.y - 1);
    assert res[3] =  neighbour;
    
    let neighbour = get_point_by_position(map, node.x + 1, node.y + 1);
    assert res[4] =  neighbour;
    
    let neighbour = get_point_by_position(map, node.x - 1, node.y - 1);
    assert res[5] =  neighbour;
    
    let neighbour = get_point_by_position(map, node.x + 1, node.y - 1);
    assert res[6] =  neighbour;
    
    let neighbour = get_point_by_position(map, node.x - 1, node.y + 1);
    assert res[7] =  neighbour;

    return (8,res,);
}


// func get_all_neighbours_of_internal{range_check_ptr}(map: Map, node: Point, x: felt, finish_x:felt, y: felt, finish_y) -> (len_res: felt, res: Point*) {
func get_all_neighbours_of_internal{range_check_ptr}(map: Map, node: Point) -> (len_res: felt, res: Point*) {
    alloc_locals;
    // if (x == -1 and finish_x == 1) {
    //     x = 1;
    //     finish_x = 0;
    // }

    let immediateNeighbors: Point* = alloc();
    let idx_immediateNeighbors = 0; 
    for_each_x(-1, 1, map, node, immediateNeighbors, idx_immediateNeighbors);
    return (idx_immediateNeighbors, immediateNeighbors,);
}

func for_each_x{range_check_ptr}(index: felt, length: felt, map: Map, node: Point, immediateNeighbors: Point*, idx_immediateNeighbors: felt) {

    if (index == length + 1) {
        return ();
    }

    for_each_y(-1, 1, index, map, node, immediateNeighbors, idx_immediateNeighbors);

    for_each_x(index + 1, length, map, node, immediateNeighbors, idx_immediateNeighbors);
    return ();
}

func for_each_y{range_check_ptr}(index_y: felt, length: felt, index_x: felt, map: Map, node: Point, immediateNeighbors: Point*, idx_immediateNeighbors: felt) {
    
    if (index_y == length + 1) {
        return ();
    }

    // distinto del (0, 0)
    // if (index_x == 0 and index_y == 0) {
    //     return ();
    // }
    
    // si es caminable, por ahora que devuelva todos
    // let p = get_point_by_position(map, node.x + index_x, node.y + index_y);
    assert immediateNeighbors[idx_immediateNeighbors] = Point(node.x + index_x, node.y + index_y, 1);


    return for_each_y(index_y + 1, length, index_x, map, node, immediateNeighbors, idx_immediateNeighbors + 1);
}