%lang starknet
// Dict imports
from starkware.cairo.common.default_dict import default_dict_new, default_dict_finalize
from starkware.cairo.common.dict import dict_write, dict_read, dict_update
from starkware.cairo.common.dict_access import DictAccess

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

func prune{range_check_ptr}(map: Map, node: Point, movement: Movement, neighbours: Point*) -> (res: Point*) {
    let (len_res, all_neighbours: Point*) = get_all_neighbours_of(map, node);
    let (res: Point*) = alloc();
    return (res,);
}

func get_all_neighbours_of{range_check_ptr}(map: Map, node: Point) -> (len_res: felt, res: Point*) {
    alloc_locals;
    let (all_neighbours: Point*) = alloc();
    tempvar all_neighbours_len = 8;

    let neighbour = get_point_by_position(map, node.x + 1, node.y);
    assert all_neighbours[0] =  neighbour;
    
    let neighbour = get_point_by_position(map, node.x - 1, node.y);
    assert all_neighbours[1] =  neighbour;
    
    let neighbour = get_point_by_position(map, node.x, node.y + 1);
    assert all_neighbours[2] =  neighbour;
    
    let neighbour = get_point_by_position(map, node.x, node.y - 1);
    assert all_neighbours[3] =  neighbour;
    
    let neighbour = get_point_by_position(map, node.x + 1, node.y + 1);
    assert all_neighbours[4] =  neighbour;
    
    let neighbour = get_point_by_position(map, node.x - 1, node.y - 1);
    assert all_neighbours[5] =  neighbour;
    
    let neighbour = get_point_by_position(map, node.x + 1, node.y - 1);
    assert all_neighbours[6] =  neighbour;
    
    let neighbour = get_point_by_position(map, node.x - 1, node.y + 1);
    assert all_neighbours[7] =  neighbour;

    let filtered_neighbours: Point* = alloc();
    // func 
    filter_neighbours_if_not_walkable(all_neighbours, 8, filtered_neighbours, 0);


    let filtered_neighbours_len =  filter_neighbours_if_not_walkable_len(all_neighbours, 8);
    // func 

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