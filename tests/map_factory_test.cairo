%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import FALSE, TRUE

from src.constants.grid import X, O
from src.models.point import Point, contains_point
from src.models.map import Map, get_point_by_position, map_equals, is_inside_of_map
from src.utils.map_factory import generate_map, generate_map_without_obstacles

// Giving width = 3, height = 3,
// When call generate_map_without_obstacles(),
// Then the map is generated with 0 obstacles and has 3 x 3 size.
@external
func test_generate_map_without_obstacles_happy_path{range_check_ptr}() { 
    let actual = generate_map_without_obstacles(3, 3);

    tempvar expected_map_points: felt* = cast(new(O, O, O,
                                                  O, O, O,
                                                  O, O, O),  felt*);

    let expected = Map(expected_map_points, 3, 3);

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

    let grid_point_out_of_map = is_inside_of_map(actual, -1, 0);
    assert grid_point_out_of_map = FALSE;

    let grid_point_out_of_map = is_inside_of_map(actual, 0, -1);
    assert grid_point_out_of_map = FALSE;
    
    let grid_point_out_of_map = is_inside_of_map(actual, 3, 0);
    assert grid_point_out_of_map = FALSE;

    let grid_point_out_of_map = is_inside_of_map(actual, 0, 3);
    assert grid_point_out_of_map = FALSE;

    let grid_point_out_of_map = is_inside_of_map(actual, 3, 2);
    assert grid_point_out_of_map = FALSE;

    let grid_point_out_of_map = is_inside_of_map(actual, 2, 3);
    assert grid_point_out_of_map = FALSE;
    
    let grid_point_out_of_map = is_inside_of_map(actual, -1, 3);
    assert grid_point_out_of_map = FALSE;

    let grid_point_out_of_map = is_inside_of_map(actual, 3, -1);
    assert grid_point_out_of_map = FALSE;
    
    return(); 
}

// Giving width = 3, height = 3 and obstacles,
// When call generate_map_with_obstacles(),
// Then the map generated contains the obstacles.
// Map representation: (X: obstacle, O: walkable)
@external
func test_generate_map_with_obstacles_happy_path{range_check_ptr}() { 
    alloc_locals;
    tempvar map_grids: felt* = cast(new(O, X, O,
                                        X, O, O,
                                        O, O, X),  felt*);

    let map = Map(map_grids, 3, 3);

    let grid = get_point_by_position(map, 0, 0);
    assert grid.walkable = TRUE;

    let grid = get_point_by_position(map, 1, 0);
    assert grid.walkable = FALSE;

    let grid = get_point_by_position(map, 2, 0);
    assert grid.walkable = TRUE;

    let grid = get_point_by_position(map, 0, 1);
    assert grid.walkable = FALSE;

    let grid = get_point_by_position(map, 1, 1);
    assert grid.walkable = TRUE;
    
    let grid = get_point_by_position(map, 2, 1);
    assert grid.walkable = TRUE;

    let grid = get_point_by_position(map, 0, 2);
    assert grid.walkable = TRUE;

    let grid = get_point_by_position(map, 1, 2);
    assert grid.walkable = TRUE;

    let grid = get_point_by_position(map, 2, 2);
    assert grid.walkable = FALSE;

    return(); 
}
