%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.dict import DictAccess
from starkware.cairo.common.cairo_builtins import HashBuiltin

from src.models.map import Map, map_equals, get_neighbours
from src.models.point import Point, set_point_attribute
from src.constants.point_attribute import UNDEFINED, PARENT
from src.constants.grid import X, O
from src.utils.dictionary import create_attribute_dict
from src.utils.array import contains, contains_all, array_equals
from src.utils.point_converter import convert_coords_to_id
from src.utils.map_factory import generate_map_without_obstacles

// // Giving a map and a point that is inside of the map,
// // When call get_point_by_position(),
// // Then the method should return TRUE.
// @external
// func test_get_point_by_position_happy_path{range_check_ptr}() {
//     alloc_locals;
//     tempvar map_grids: felt* = cast(new(O, X, O,
//                                         O, O, O,
//                                         O, O, O),  felt*);
//     let map = Map(map_grids, 3, 3);

//     let result = get_point_by_position(map, 1);
//     assert result = Point(1, 0, FALSE);

//     let result = get_point_by_position(4);
//     assert result = Point(1, 1, TRUE);
    
//     return();
// }

// // Giving a map and a point that is outside of the map,
// // When call get_point_by_position(),
// // Then the method should throw error.
// @external
// func test_get_point_by_position_point_outside_of_map{range_check_ptr}() {
//     alloc_locals;
//     let map = generate_map_without_obstacles(2, 2); 

//     %{ expect_revert("TRANSACTION_FAILED", "Point (5, 2) = 9 is out of map range.") %}
//     let result = get_point_by_position(map, 9);
    
//     return();
// }

// // Giving a map and a point that is inside of the map,
// // When call is_inside_of_map(),
// // Then the method should return TRUE.
// @external
// func test_is_inside_of_map_happy_path{range_check_ptr}() {
//     alloc_locals;
//     let map = generate_map_without_obstacles(2, 5);

//     let result = is_inside_of_map(map, 15);
//     assert result = TRUE;
    
//     return();
// }

// // Giving a map and a point that is outside of the map,
// // When call is_inside_of_map(),
// // Then the method should return FALSE.
// @external
// func test_is_inside_of_map_point_outside{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
//     alloc_locals;
//     let map = generate_map_without_obstacles(2, 3);

//     let result = is_inside_of_map(map, 12);
//     assert result = FALSE;
    
//     return(); 
// }

// A: actual node, no parent.
// O O O
// O A O
// O O O
@external
func test_get_neighbours_center_no_obstacles{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    let point_attribute = create_attribute_dict();
    let map = generate_map_without_obstacles(3, 3);

    let (grids_len, grids) = get_neighbours{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, point_attribute=point_attribute}(map, 4);

    let grids_expected_len = 8;
    tempvar grids_expected: felt* = cast(new(0, 1, 2,
                                             3,    5,
                                             6, 7, 8,), felt*);

    let result = array_equals(grids, grids_len, grids_expected, grids_expected_len);
    assert result = TRUE;

    return();
}

// A: actual node, no parent.
// A O O
// O O O
// O O O
@external
func test_get_neighbours_up_left_corner_no_obstacles{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    let point_attribute = create_attribute_dict();
    let map = generate_map_without_obstacles(3, 3);

    let (grids_len, grids) = get_neighbours{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, point_attribute=point_attribute}(map, 0);
    let grids_expected_len = 3;
    tempvar grids_expected: felt* = cast(new(   1,
                                             3, 4   
                                                    ), felt*);

    let result = array_equals(grids, grids_len, grids_expected, grids_expected_len);
    assert result = TRUE;

    return();
}

// A: actual node, no parent.
// O A O
// O O O
// O O O
@external
func test_get_neighbours_middle_up_no_obstacles{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    let point_attribute = create_attribute_dict();
    let map = generate_map_without_obstacles(3, 3);

    let (grids_len, grids) = get_neighbours{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, point_attribute=point_attribute}(map, 1);
    let grids_expected_len = 5;
    tempvar grids_expected: felt* = cast(new(0,    2,
                                             3, 4, 5
                                                     ), felt*);

    let result = array_equals(grids, grids_len, grids_expected, grids_expected_len);
    assert result = TRUE;

    return();
}

// A: actual node, no parent.
// O O A
// O O O
// O O O
@external
func test_get_neighbours_up_right_corner_no_obstacles{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    let point_attribute = create_attribute_dict();
    let map = generate_map_without_obstacles(3, 3);

    let (grids_len, grids) = get_neighbours{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, point_attribute=point_attribute}(map, 2);
    let grids_expected_len = 3;
    tempvar grids_expected: felt* = cast(new(1,
                                             4, 5
                                                  ), felt*);

    let result = array_equals(grids, grids_len, grids_expected, grids_expected_len);
    assert result = TRUE;

    return();
}

// A: actual node, no parent.
// O O O
// O O O
// O O A
@external
func test_get_neighbours_down_right_corner_no_obstacles{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    let point_attribute = create_attribute_dict();
    let map = generate_map_without_obstacles(3, 3);

    let (grids_len, grids) = get_neighbours{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, point_attribute=point_attribute}(map, 8);
    let grids_expected_len = 3;
    tempvar grids_expected: felt* = cast(new(
                                              4, 5,
                                              7   ), felt*);

    let result = array_equals(grids, grids_len, grids_expected, grids_expected_len);
    assert result = TRUE;

    return();
}

// A: actual node, no parent.
// O O O
// O O O
// O A O
@external
func test_get_neighbours_middle_down_no_obstacles{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    let point_attribute = create_attribute_dict();
    let map = generate_map_without_obstacles(3, 3);

    let (grids_len, grids) = get_neighbours{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, point_attribute=point_attribute}(map, 7);
    let grids_expected_len = 5;
    tempvar grids_expected: felt* = cast(new(
                                             3, 4, 5,
                                             6,    8 ), felt*);

    let result = array_equals(grids, grids_len, grids_expected, grids_expected_len);
    assert result = TRUE;

    return();
}

// A: actual node, no parent.
// O O O
// O O O
// A O O
@external
func test_get_neighbours_down_left_corner_no_obstacles{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    let point_attribute = create_attribute_dict();
    let map = generate_map_without_obstacles(3, 3);

    let (grids_len, grids) = get_neighbours{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, point_attribute=point_attribute}(map, 6);
    let grids_expected_len = 3;
    // assert points_expected[0] = Point(0, 1, TRUE);
    // assert points_expected[1] = Point(1, 1, TRUE);
    // assert points_expected[2] = Point(1, 2, TRUE);
    tempvar grids_expected: felt* = cast(new(     
                                             3, 4,  
                                                7   ), felt*);
    let result = array_equals(grids, grids_len, grids_expected, grids_expected_len);
    assert result = TRUE;

    return();
}

// A: actual node, no parent.
// X A X
// O X O 
// O O O
@external
func test_get_neighbours_middle_blocked_by_obstacles{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    let point_attribute = create_attribute_dict();

    tempvar map_grids: felt* = cast(new(X, O, X,
                                        O, X, O,
                                        O, O, O),  felt*);
    let map = Map(map_grids, 3, 3);

    let (grids_len, grids) = get_neighbours{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, point_attribute=point_attribute}(map, 1);
    let grids_expected_len = 0;
    let (grids_expected: felt*) = alloc();

    let result = array_equals(grids, grids_len, grids_expected, grids_expected_len);
    assert result = TRUE;

    return();
}

// A: actual node, no parent.
// O A X
// O X O 
// O O O
@external
func test_get_neighbours_middle_with_one_way{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    let point_attribute = create_attribute_dict();

    tempvar map_grids: felt* = cast(new(O, O, X,
                                        O, X, O,
                                        O, O, O),  felt*);
    let map = Map(map_grids, 3, 3);

    let (grids_len, grids) = get_neighbours{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, point_attribute=point_attribute}(map, 1);
    let grids_expected_len = 2;
    tempvar grids_expected: felt* = cast(new(0, 3), felt*);
    let result = array_equals(grids, grids_len, grids_expected, grids_expected_len);
    assert result = TRUE;

    return();
}

// A: actual node, P: parent
// X O X O
// P A O O 
// O O O O 
// O O O O
// dx = 1, dy = 0
@external
func test_get_neighbours_with_parent_horizontal_right_direction{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    let point_attribute = create_attribute_dict();

    tempvar map_grids: felt* = cast(new(X, O, X, O,
                                        O, O, O, O,
                                        O, O, O, O,
                                        O, O, O, O),  felt*);
    let map = Map(map_grids, 4, 4);

    let parent_id = convert_coords_to_id(0, 1, 4);
    let grid_id = 5;
    set_point_attribute{pedersen_ptr=pedersen_ptr, point_attribute=point_attribute}(grid_id, PARENT, parent_id);

    let (grids_len, grids) = get_neighbours{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, point_attribute=point_attribute}(map, 5);
    let grids_expected_len = 1;
    tempvar grids_expected: felt* = cast(new(6), felt*);
    let result = array_equals(grids, grids_len, grids_expected, grids_expected_len);
    assert result = TRUE;

    return();
}

// A: actual node, P: parent
// X O X O
// O A P O 
// O O O O 
// O O O O
// dx = -1, dy = 0
@external
func test_get_neighbours_with_parent_horizontal_left_direction{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    let point_attribute = create_attribute_dict();

    tempvar map_grids: felt* = cast(new(X, O, X, O,
                                        O, O, O, O,
                                        O, O, O, O,
                                        O, O, O, O),  felt*);
    let map = Map(map_grids, 4, 4);

    let parent_id = convert_coords_to_id(2, 1, 4);
    let grid_id = 5;
    set_point_attribute{pedersen_ptr=pedersen_ptr, point_attribute=point_attribute}(grid_id, PARENT, parent_id);

    let (grids_len, grids) = get_neighbours{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, point_attribute=point_attribute}(map, grid_id);
    let grids_expected_len = 1;
    tempvar grids_expected: felt* = cast(new(4), felt*);
    let result = array_equals(grids, grids_len, grids_expected, grids_expected_len);
    assert result = TRUE;

    return();
}


// A: actual node, P: parent
// X O X O
// O A O O 
// O P O O 
// O O O O
// dx = 0, dy = -1
@external
func test_get_neighbours_with_parent_vertical_up_direction{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    let point_attribute = create_attribute_dict();

    tempvar map_grids: felt* = cast(new(X, O, X, O,
                                        O, O, O, O,
                                        O, O, O, O,
                                        O, O, O, O),  felt*);
    let map = Map(map_grids, 4, 4);

    let parent_id = convert_coords_to_id(1, 2, 4);
    let grid_id = 5;
    set_point_attribute{pedersen_ptr=pedersen_ptr, point_attribute=point_attribute}(grid_id, PARENT, parent_id);

    let (grids_len, grids) = get_neighbours{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, point_attribute=point_attribute}(map, 5);
    let grids_expected_len = 1;
    tempvar grids_expected: felt* = cast(new(1), felt*);
    let result = array_equals(grids, grids_len, grids_expected, grids_expected_len);
    assert result = TRUE;

    return();
}

// A: actual node, P: parent
// X O X O
// O P O O 
// O X A O 
// O O O O
// dx = 1, dy = 1
@external
func test_get_neighbours_with_parent_diagonal_right_down_direction{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    let point_attribute = create_attribute_dict();

    tempvar map_grids: felt* = cast(new(X, O, X, O,
                                        O, O, O, O,
                                        O, X, O, O,
                                        O, O, O, O),  felt*);
    let map = Map(map_grids, 4, 4);
    let parent_id = convert_coords_to_id(1, 1, 4);
    let grid_id = 10;
    set_point_attribute{pedersen_ptr=pedersen_ptr, point_attribute=point_attribute}(grid_id, PARENT, parent_id);

    let (grids_len, grids) = get_neighbours{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, point_attribute=point_attribute}(map, grid_id);
    let grids_expected_len = 4;
    tempvar grids_expected: felt* = cast(new(            11,
                                                 13, 14, 15), felt*);
    let result = array_equals(grids, grids_len, grids_expected, grids_expected_len);
    assert result = TRUE;

    return();
}

// A: actual node, P: parent
// X O X O
// O P O O 
// A X O O 
// O O O O
// dx = -1, dy = 1
@external
func test_get_neighbours_with_parent_diagonal_left_down_direction_in_border{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    let point_attribute = create_attribute_dict();

    tempvar map_grids: felt* = cast(new(X, O, X, O,
                                        O, O, O, O,
                                        O, X, O, O,
                                        O, O, O, O),  felt*);
    let map = Map(map_grids, 4, 4);
    let parent_id = convert_coords_to_id(1, 1, 4);
    
    let grid_id = 8;
    set_point_attribute{pedersen_ptr=pedersen_ptr, point_attribute=point_attribute}(grid_id, PARENT, parent_id);

    let (grids_len, grids) = get_neighbours{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, point_attribute=point_attribute}(map, grid_id);
    let grids_expected_len = 2;
    tempvar grids_expected: felt* = cast(new(12, 13), felt*);
    let result = array_equals(grids, grids_len, grids_expected, grids_expected_len);
    assert result = TRUE;

    return();
}
