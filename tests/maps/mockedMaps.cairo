%lang starknet

// In this class we have some predefined maps for testing

// Map 1 (no obstacles)
from starkware.cairo.common.alloc import alloc
from src.data import Point, Map, contains_point

func map_without_obstacles() -> Map {
    alloc_locals;
    // setup map
    let points: Point* = alloc();

    let map = Map(points, 25, 5, 5);
    return map;
}

func generate_points_with_obstacles(width: felt, height: felt, obstacles: Point*, obstacles_lenght) -> (felt, Point*) {
    alloc_locals;
    let points: Point* = alloc(); 
    generate_points_internal(obstacles, obstacles_lenght, points, 0, width, height, 0, 0, 0);
    return (width * height, points);
}

func generate_points_internal(obstacles: Point*, obstacles_lenght: felt, points: Point*, index: felt, width: felt, height: felt, x: felt, y: felt, reset_y: felt) {
    // dejo de llamar cuando el contador de reinicio de x es igual a la altura
    if (reset_y == height) {
        return ();
    }
    // cada vez que y llega al borde, incremento un contador, cuando hice todos los y dejo de incrementar x
    // cuando x es igual al ancho entonces reinicio x a 0 y aumento y + 1
    if (x == width) {
        return generate_points_internal(obstacles, obstacles_lenght, points, index, width, height, 0, y + 1, reset_y + 1);
    }
    let obstacles_contains_point = contains_point(obstacles, obstacles_lenght, x, y);
    if (obstacles_contains_point == 1) {
        assert points[index] = Point(x, y, 0);
    } else {
        assert points[index] = Point(x, y, 1);
    }
    
    // return generate_points_internal(obstacles, obstacles_lenght, points, index, width, height, x + 1, y, reset_y);
    // llamado recursivo incrementando x + 1
    generate_points_internal(obstacles, obstacles_lenght, points, index + 1, width, height, x + 1, y, reset_y);
    return ();
}