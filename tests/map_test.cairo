%lang starknet
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.dict import DictAccess
from starkware.cairo.common.cairo_builtins import HashBuiltin

from src.models.map import Map, get_point_by_position, map_equals, is_inside_of_map, get_neighbours
from src.models.point import Point, contains_point_equals, contains_all_points, contains_all_points_equals
from src.models.point_status import UNDEFINED
from src.utils.dictionary import create_dict
from src.utils.map_factory import generate_map_with_obstacles, generate_map_without_obstacles

// Giving a map and a point that is inside of the map,
// When call get_point_by_position(),
// Then the method should return TRUE.
@external
func test_get_point_by_position_happy_path{range_check_ptr}() {
    alloc_locals;
    let obstacles: Point* = alloc();
    let obstacles_lenght = 1;
    assert obstacles[0] = Point(1, 0, FALSE);

    let map = generate_map_with_obstacles(3, 3, obstacles, obstacles_lenght); 

    let result = get_point_by_position(map, 1, 0);
    assert result = Point(1, 0, FALSE);

    let result = get_point_by_position(map, 1, 1);
    assert result = Point(1, 1, TRUE);
    
    return();
}

// Giving a map and a point that is outside of the map,
// When call get_point_by_position(),
// Then the method should throw error.
@external
func test_get_point_by_position_point_outside_of_map{range_check_ptr}() {
    alloc_locals;
    let map = generate_map_without_obstacles(2, 2); 

    %{ expect_revert("TRANSACTION_FAILED", "Point (5, 2) is out of map range.") %}
    let result = get_point_by_position(map, 5, 2);
    
    return();
}

// Giving a map and a point that is inside of the map,
// When call is_inside_of_map(),
// Then the method should return TRUE.
@external
func test_is_inside_of_map_happy_path{range_check_ptr}() {
    alloc_locals;
    let map = generate_map_without_obstacles(2, 5);

    let result = is_inside_of_map(map, 0, 3);
    assert result = TRUE;
    
    return();
}

// Giving a map and a point that is outside of the map,
// When call is_inside_of_map(),
// Then the method should return FALSE.
@external
func test_is_inside_of_map_point_outside{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    let map = generate_map_without_obstacles(2, 3);

    let result = is_inside_of_map(map, 0, 4);
    assert result = FALSE;
    
    return(); 
}

@external
func test_get_neighbours_happy_path{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    let dict_ptr = create_dict(UNDEFINED);
    let map = generate_map_without_obstacles(3, 3);

    let (points_len, points) = get_neighbours{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, dict_ptr=dict_ptr}(map, Point(1, 1, TRUE));

    let points_expected: Point* = alloc();
    let points_expected_len = 8;
    assert points_expected[0] = Point(0, 0, TRUE);
    assert points_expected[1] = Point(0, 1, TRUE);
    assert points_expected[2] = Point(0, 2, TRUE);
    assert points_expected[3] = Point(1, 0, TRUE);
    assert points_expected[4] = Point(1, 2, TRUE);
    assert points_expected[5] = Point(2, 0, TRUE);
    assert points_expected[6] = Point(2, 1, TRUE);
    assert points_expected[7] = Point(2, 2, TRUE);

    let result = contains_all_points_equals(points, points_len, points_expected, points_expected_len);
    assert result = TRUE;

    return();
}

@external
func test_get_neighbours_corner{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    let dict_ptr = create_dict(UNDEFINED);
    let map = generate_map_without_obstacles(3, 3);

    let (points_len, points) = get_neighbours{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, dict_ptr=dict_ptr}(map, Point(0, 0, TRUE));

    let points_expected: Point* = alloc();
    let points_expected_len = 3;
    assert points_expected[0] = Point(1, 0, TRUE);
    assert points_expected[1] = Point(1, 1, TRUE);
    assert points_expected[2] = Point(0, 1, TRUE);

    let result = contains_all_points_equals(points, points_len, points_expected, points_expected_len);
    assert result = TRUE;

    return();
}

@external
func test_get_neighbours_middle{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    let dict_ptr = create_dict(UNDEFINED);

    let obstacles: Point* = alloc();
    let obstacles_lenght = 3;
    assert obstacles[0] = Point(0, 0, FALSE);
    assert obstacles[1] = Point(1, 1, FALSE);
    assert obstacles[2] = Point(2, 0, FALSE);

    let map = generate_map_with_obstacles(3, 3, obstacles, obstacles_lenght);

    let (points_len, points) = get_neighbours{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, dict_ptr=dict_ptr}(map, Point(1, 0, TRUE));

    let points_expected: Point* = alloc();
    let points_expected_len = 5;
    assert points_expected[0] = Point(0, 0, FALSE);
    assert points_expected[1] = Point(0, 1, TRUE);
    assert points_expected[2] = Point(1, 1, FALSE);
    assert points_expected[3] = Point(2, 1, TRUE);
    assert points_expected[4] = Point(2, 0, FALSE);

    let result = contains_all_points_equals(points, points_len, points_expected, points_expected_len);
    assert result = TRUE;

    return();
}