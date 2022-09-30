%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc

from src.data import Point, Movement, Map, get_point_in_map

@view
func identify_successors{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt) {
    // let (successors: Point*) = alloc();
    // let (neighbours: Point*) = alloc();
    
    // neighbours = prune(x, neighbours);
    let res = 0;
    return (res,);
}

func prune{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(map: Map, node: Point, movement: Movement, neighbours: Point*) -> (res: Point*) {
    let (all_neighbours: Point*) = get_all_neighbours_of(map, node);
    let (res: Point*) = alloc();




    return (res,);
}

func get_all_neighbours_of{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(map: Map, node: Point) -> (len_res: felt, res: Point*) {
    alloc_locals;
    let (res: Point*) = alloc();

    let neighbour = get_point_in_map(map, node.x + 1, node.y);
    assert res[0] =  neighbour;
    
    let neighbour = get_point_in_map(map, node.x - 1, node.y);
    assert res[1] =  neighbour;
    
    let neighbour = get_point_in_map(map, node.x, node.y + 1);
    assert res[2] =  neighbour;
    
    let neighbour = get_point_in_map(map, node.x, node.y - 1);
    assert res[3] =  neighbour;
    
    let neighbour = get_point_in_map(map, node.x + 1, node.y + 1);
    assert res[4] =  neighbour;
    
    let neighbour = get_point_in_map(map, node.x - 1, node.y - 1);
    assert res[5] =  neighbour;
    
    let neighbour = get_point_in_map(map, node.x + 1, node.y - 1);
    assert res[6] =  neighbour;
    
    let neighbour = get_point_in_map(map, node.x - 1, node.y + 1);
    assert res[7] =  neighbour;

    return (8,res,);
}
