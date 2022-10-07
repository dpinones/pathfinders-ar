%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE

from src.models.map import Map
from src.models.point import Point, contains_point

// func generate_map_without_obstacles(width: felt, height: felt) -> Map {
//     alloc_locals;
//     let obstacles: Point* = alloc();
//     let map = Map(obstacles, 0, width, height);

//     return map;
// }

// func generate_map_with_obstacles(width: felt, height: felt, obstacles: Point*, obstacles_lenght) -> Map {
//     alloc_locals;
//     let map = Map(obstacles, obstacles_lenght, width, height);

//     return map;
// }

func generate_map_static(grids: felt*, width: felt, height: felt) -> Map {
    alloc_locals;
    let map = Map(grids, width, height);

    return map;
}