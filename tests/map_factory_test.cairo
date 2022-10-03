%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import FALSE, TRUE

from src.models.point import Point, contains_point
from src.models.map import Map, get_point_by_position, map_equals
from src.utils.factory.map_factory import generate_map_with_obstacles, generate_map_without_obstacles

// Giving width = 3, height = 3,
// When call generate_map_without_obstacles(),
// Then the map is generated with 0 obstacles and has 3 x 3 size.
@external
func test_generate_map_without_obstacles_happy_path{range_check_ptr}() { 
    let actual = generate_map_without_obstacles(3, 3);

    let expected_points: Point* = alloc(); 
    assert expected_points[0] = Point(0, 0, TRUE);
    assert expected_points[1] = Point(0, 1, TRUE);
    assert expected_points[2] = Point(0, 2, TRUE);
    assert expected_points[3] = Point(1, 0, TRUE);
    assert expected_points[4] = Point(1, 1, TRUE);
    assert expected_points[5] = Point(1, 2, TRUE);
    assert expected_points[6] = Point(2, 0, TRUE);
    assert expected_points[7] = Point(2, 1, TRUE);
    assert expected_points[8] = Point(2, 2, TRUE);

    let expected = Map(expected_points, 3, 3);

    let maps_are_equals = map_equals(actual, expected);
    assert maps_are_equals = TRUE;

    return(); 
}

// Giving width = 3, height = 3,
// When call generate_map_without_obstacles(),
// Then the map generated not contains points out of range.
@external
func test_generate_map_without_obstacles_non_points_out_of_range{range_check_ptr}() { 
    alloc_locals;
    let actual = generate_map_without_obstacles(3, 3);

    let grid_point_out_of_map = contains_point(actual.grid, actual.width * actual.height, -1, 0);
    assert grid_point_out_of_map = FALSE;

    let grid_point_out_of_map = contains_point(actual.grid, actual.width * actual.height, 0, -1);
    assert grid_point_out_of_map = FALSE;
    
    let grid_point_out_of_map = contains_point(actual.grid, actual.width * actual.height, 3, 0);
    assert grid_point_out_of_map = FALSE;

    let grid_point_out_of_map = contains_point(actual.grid, actual.width * actual.height, 0, 3);
    assert grid_point_out_of_map = FALSE;

    let grid_point_out_of_map = contains_point(actual.grid, actual.width * actual.height, 3, 2);
    assert grid_point_out_of_map = FALSE;

    let grid_point_out_of_map = contains_point(actual.grid, actual.width * actual.height, 2, 3);
    assert grid_point_out_of_map = FALSE;
    
    let grid_point_out_of_map = contains_point(actual.grid, actual.width * actual.height, -1, 3);
    assert grid_point_out_of_map = FALSE;

    let grid_point_out_of_map = contains_point(actual.grid, actual.width * actual.height, 3, -1);
    assert grid_point_out_of_map = FALSE;
    
    return(); 
}

// Giving width = 3, height = 3 and obstacles,
// When call generate_map_with_obstacles(),
// Then the map generated contains the obstacles.
// Map representation: (X: obstacle, O: walkable)
// X O O
// O O X
// O X O
@external
func test_generate_map_with_obstacles_happy_path{range_check_ptr}() { 
    let obstacles: Point* = alloc();
    let obstacles_len = 3;
    assert obstacles[0] = Point(0, 0, FALSE);
    assert obstacles[1] = Point(1, 2, FALSE);
    assert obstacles[2] = Point(2, 1, FALSE);

    let actual = generate_map_with_obstacles(3, 3, obstacles, obstacles_len);

    let expected_points: Point* = alloc(); 
    assert expected_points[0] = Point(0, 0, FALSE);
    assert expected_points[1] = Point(0, 1, TRUE);
    assert expected_points[2] = Point(0, 2, TRUE);
    assert expected_points[3] = Point(1, 0, TRUE);
    assert expected_points[4] = Point(1, 1, TRUE);
    assert expected_points[5] = Point(1, 2, FALSE);
    assert expected_points[6] = Point(2, 0, TRUE);
    assert expected_points[7] = Point(2, 1, FALSE);
    assert expected_points[8] = Point(2, 2, TRUE);

    let expected = Map(expected_points, 3, 3);

    let maps_are_equals = map_equals(actual, expected);
    assert maps_are_equals = TRUE;

    return(); 
}
