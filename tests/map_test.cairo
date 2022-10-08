%lang starknet
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.dict import DictAccess
from starkware.cairo.common.cairo_builtins import HashBuiltin

from src.models.map import Map, get_point_by_position, map_equals, is_inside_of_map, get_neighbours
from src.models.point import Point, contains_point_equals, contains_all_points, contains_all_points_equals, set_point_attribute
from src.constants.point_attribute import UNDEFINED, PARENT
from src.constants.grid import X, O
from src.utils.dictionary import create_dict
from src.utils.point_converter import convert_coords_to_id
from src.utils.map_factory import generate_map_without_obstacles

// Giving a map and a point that is inside of the map,
// When call get_point_by_position(),
// Then the method should return TRUE.
@external
func test_get_point_by_position_happy_path{range_check_ptr}() {
    alloc_locals;
    tempvar map_grids: felt* = cast(new(O, X, O,
                                        O, O, O,
                                        O, O, O),  felt*);

    let map = Map(map_grids, 3, 3);

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

// A: actual node, no parent.
// A O O
// O O O
// O O O
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

    tempvar map_grids: felt* = cast(new(X, O, X,
                                        O, X, O,
                                        O, O, O),  felt*);
    let map = Map(map_grids, 3, 3);

    let (points_len, points) = get_neighbours{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, dict_ptr=dict_ptr}(map, Point(1, 0, TRUE));

    let points_expected: Point* = alloc();
    let points_expected_len = 0;

    let result = contains_all_points_equals(points, points_len, points_expected, points_expected_len);
    assert result = TRUE;

    return();
}

// X O X O
// P A O O 
// O O O O 
// O O O O
@external
func test_get_neighbours_with_parent_middle{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    let dict_ptr = create_dict(UNDEFINED);

    tempvar map_grids: felt* = cast(new(X, O, X, O,
                                        O, O, O, O,
                                        O, O, O, O,
                                        O, O, O, O),  felt*);
    let map = Map(map_grids, 4, 4);

    let point = Point(1, 1, TRUE);
    let parent_id = convert_coords_to_id(0, 1, 4);
    set_point_attribute{pedersen_ptr=pedersen_ptr, dict_ptr=dict_ptr}(point, PARENT, parent_id);

    let (points_len, points) = get_neighbours{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, dict_ptr=dict_ptr}(map, point);

    let points_expected: Point* = alloc();
    let points_expected_len = 1;
    assert points_expected[0] = Point(2, 1, TRUE);

    let result = contains_all_points_equals(points, points_len, points_expected, points_expected_len);
    assert result = TRUE;

    return();
}

// X O X O
// O P O O 
// O X A O 
// O O O O
// dx = 1, dy = 1
@external
func test_get_neighbours_with_parent_middle_diagonal{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    let dict_ptr = create_dict(UNDEFINED);

    tempvar map_grids: felt* = cast(new(X, O, X, O,
                                        O, O, O, O,
                                        O, X, O, O,
                                        O, O, O, O),  felt*);
    let map = Map(map_grids, 4, 4);
    let point = Point(2, 2, TRUE);
    let parent_id = convert_coords_to_id(1, 1, 4);
    
    set_point_attribute{pedersen_ptr=pedersen_ptr, dict_ptr=dict_ptr}(point, PARENT, parent_id);

    let (points_len, points) = get_neighbours{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, dict_ptr=dict_ptr}(map, point);

    let points_expected: Point* = alloc();
    let points_expected_len = 4;
    assert points_expected[0] = Point(2, 3, TRUE);
    assert points_expected[1] = Point(3, 2, TRUE);
    assert points_expected[2] = Point(3, 3, TRUE);
    assert points_expected[3] = Point(1, 3, TRUE);

    let result = contains_all_points_equals(points, points_len, points_expected, points_expected_len);
    assert result = TRUE;

    return();
}