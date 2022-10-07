%lang starknet

from starkware.cairo.common.alloc import alloc

from src.models.map import Map
from src.constants.grid import X, O

func generate_map(grids: felt*, width: felt, height: felt) -> Map {
    let map = Map(grids, width, height);
    return map;
}

func generate_map_without_obstacles(width: felt, height: felt) -> Map {
    alloc_locals;
    let grids: felt* = alloc();
    _generate_map_grids(grids, 0, width * height);

    let map = Map(grids, width, height);
    return map;
}

func _generate_map_grids(grids: felt*, index: felt, lenght_left: felt) {
   if (lenght_left == 0) {
        return ();
    }
    assert grids[index] = O;
    return _generate_map_grids(grids, index + 1, lenght_left - 1);
}