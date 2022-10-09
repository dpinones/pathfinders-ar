%lang starknet

from starkware.cairo.common.alloc import alloc

from src.models.map import Map
from src.constants.grid import O

// Generates a width * height map 
// with the positions and obstacles given by parameter.
// Example:
// tempvar map_grids: felt* = cast(new(O, O, X,
//                                     O, X, O,
//                                     O, X, O),  felt*);
//  
// generate_map(map_grids, 3, 3); 
// This will generate a map with obstacles in the positions that are with X.
//
// @param: grids - List of felt that represent each grid of the map.
// @param: width - Besired map width.
// @param: height - Besired map height.
// @return: Map - Returns the built map.
func generate_map(grids: felt*, width: felt, height: felt) -> Map { 
    let map = Map(grids, width, height);
    return map;
}

// Generate a map with width * height size.
// For each of the positions on this map, the points will be walkable.
//
// @param: width - Besired map width.
// @param: height - Besired map height.
// @return: Map - Returns the built map.
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