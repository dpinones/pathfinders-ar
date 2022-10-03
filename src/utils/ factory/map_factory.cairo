%lang starknet

from starkware.cairo.common.alloc import alloc

from src.models.map import Map
from src.models.point import Point, contains_point

func generate_map_without_obstacles(width: felt, height: felt) -> Map {
    alloc_locals;
    let obstacles: Point* = alloc();
    let points: Point* = generate_grid(width, height, obstacles, 0);
    let map = Map(points, width, height);

    return map;
}

func generate_map_with_obstacles(width: felt, height: felt, obstacles: Point*, obstacles_lenght) -> Map {
    alloc_locals;
    let points: Point* = generate_grid(width, height, obstacles, obstacles_lenght);
    let map = Map(points, width, height);

    return map;
}

func generate_grid(width: felt, height: felt, obstacles: Point*, obstacles_lenght) -> (felt, Point*) {
    alloc_locals;
    let points: Point* = alloc(); 
    generate_grid_internal(obstacles, obstacles_lenght, points, 0, width, height, 0, 0, 0);
    return ((width * height) - 1, points);
}

func generate_grid_internal(obstacles: Point*, obstacles_lenght: felt, points: Point*, index: felt, width: felt, height: felt, x: felt, y: felt, reset_y: felt) {
    if (reset_y == height) {
        return ();
    }

    if (x == width) {
        return generate_grid_internal(obstacles, obstacles_lenght, points, index, width, height, 0, y + 1, reset_y + 1);
    }
    let obstacles_contains_point = contains_point(obstacles, obstacles_lenght, x, y);
    if (obstacles_contains_point == 1) {
        assert points[index] = Point(x, y, 0);
    } else {
        assert points[index] = Point(x, y, 1);
    }
    
    generate_grid_internal(obstacles, obstacles_lenght, points, index + 1, width, height, x + 1, y, reset_y);
    return ();
}