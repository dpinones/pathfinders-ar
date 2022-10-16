%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE
from src.constants.point_status import OPENED, CLOSED
from src.constants.point_attribute import UNDEFINED
from src.constants.grid import X, O
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.dict import DictAccess

from src.utils.dictionary import create_attribute_dict
from src.models.point import Point, contains_all_points
from src.models.map import Map
from src.utils.map_factory import generate_map_without_obstacles
from src.utils.min_heap_custom import heap_create
from src.jps import jump, find_path

// Giving parent (P) and actual (G) 
// When actual is the goal and call jump()
// Then method will return actual node as jump point
// Map:
// O O O 
// O P G 
// O O O 
@external
func test_jump_actual_node_is_the_goal{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    let map = generate_map_without_obstacles(3, 3); 
    let goal = Point(2, 1);

    let result_after = jump(2, 1, 1, 1, map, goal);
    assert result_after = 5;
    // assert result_after = Point(2, 1);

    return ();
}

// Giving parent (P) and actual (A) has an obstacle in (y + 1) position
// When call jump()
// Then method will return actual node as jump point
// Map:
// O O O
// P A O
// O X O 
@external
func test_jump_with_horizontal_right_obstacle_in_y_plus_1{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    tempvar map_grids: felt* = cast(new(O, O, O,
                                        O, O, O,
                                        O, X, O),  felt*);
    let map = Map(map_grids, 3, 3);

    let result_after: Point = jump(1, 1, 0, 1, map, UNDEFINED);
    assert result_after = 4;
    // assert result_after = Point(1, 1);

    return ();
}

// Giving parent (P) and actual (A) has an obstacle in (y - 1) position
// When call jump()
// Then method will return actual node as jump point
// Map:
// O X O 
// P A O 
// O O O 
@external
func test_jump_with_horizontal_right_obstacle_in_y_minus_1{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;   
    tempvar map_grids: felt* = cast(new(O, X, O,
                                        O, O, O,
                                        O, O, O),  felt*);
    let map = Map(map_grids, 3, 3);   

    let result_after: Point = jump(1, 1, 0, 1, map, UNDEFINED);
    assert result_after = 4;
    // assert result_after = Point(1, 1);

    return ();
}

// Giving parent (P) and actual (A) has an obstacle in (y - 1) position
// When call jump()
// Then method will return actual node as jump point
// Map:
// O X O
// O A P
// O O O
@external
func test_jump_with_horizontal_left_obstacle_in_y_minus_1{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    tempvar map_grids: felt* = cast(new(O, X, O,
                                        O, O, O,
                                        O, O, O),  felt*);
    let map = Map(map_grids, 3, 3);  

    let result_after: Point = jump(1, 1, 2, 1, map, UNDEFINED);
    assert result_after = 4;
    // assert result_after = Point(1, 1);

    return ();
}

// Giving parent (P) and actual (A) has an obstacle in (y + 1) position
// When call jump()
// Then method will return actual node as jump point
// Map:
// O O O
// O A P
// O X O
@external
func test_jump_with_horizontal_left_obstacle_in_y_plus_1{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    tempvar map_grids: felt* = cast(new(O, O, O,
                                        O, O, O,
                                        O, X, O),  felt*);
    let map = Map(map_grids, 3, 3);  

    let result_after: Point = jump(1, 1, 2, 1, map, UNDEFINED);
    assert result_after = 4;
    // assert result_after = Point(1, 1, TRUE);

    return ();
}

// Giving parent (P) and actual (A) has an obstacle in (x + 1) position
// When call jump()
// Then method will return actual node as jump point
// Map:
// O P O 
// O A X 
// O O O 
@external
func test_jump_with_vertical_down_obstacle_in_x_plus_1{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    tempvar map_grids: felt* = cast(new(O, O, O,
                                        O, O, X,
                                        O, O, O),  felt*);
    let map = Map(map_grids, 3, 3); 

    let result_after: Point = jump(1, 1, 1, 0, map, UNDEFINED);
    assert result_after = 4;
    // assert result_after = Point(1, 1, TRUE);

    return ();
}

// Giving parent (P) and actual (A) has an obstacle in (x - 1) position
// When call jump()
// Then method will return actual node as jump point
// Map:
// O P O 
// X A O 
// O O O 
@external
func test_jump_with_vertical_down_obstacle_in_x_minus_1{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    tempvar map_grids: felt* = cast(new(O, O, O,
                                        X, O, O,
                                        O, O, O),  felt*);
    let map = Map(map_grids, 3, 3);  

    let result_after: Point = jump(1, 1, 1, 0, map, UNDEFINED);
    assert result_after = 4;
    // assert result_after = Point(1, 1, TRUE);

    return ();
}

// Giving parent (P) and actual (A) has an obstacle in (x - 1) position
// When call jump()
// Then method will return actual node as jump point
// Map:
// O O O 
// O A X 
// O P O 
@external
func test_jump_with_vertical_up_obstacle_in_x_plus_1{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    tempvar map_grids: felt* = cast(new(O, O, O,
                                        O, O, X,
                                        O, O, O),  felt*);
    let map = Map(map_grids, 3, 3);  

    let result_after: Point = jump(1, 1, 1, 2, map, UNDEFINED);
    assert result_after = 4;
    // assert result_after = Point(1, 1, TRUE);

    return ();
}

// Giving parent (P) and actual (A) has an obstacle in (x - 1) position
// When call jump()
// Then method will return actual node as jump point
// Map:
// O O O 
// X A O 
// O P O 
@external
func test_jump_with_vertical_up_obstacle_in_x_minus_1{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    tempvar map_grids: felt* = cast(new(O, O, O,
                                        X, O, O,
                                        O, O, O),  felt*);
    let map = Map(map_grids, 3, 3);  

    let result_after: Point = jump(1, 1, 1, 2, map, UNDEFINED);
    assert result_after = 4;
    // assert result_after = Point(1, 1, TRUE);

    return ();
}

// Giving parent (P) and actual (A) has an obstacle in (x - 1) position
// When call jump()
// Then method will return actual node as jump point
// Map:
// O O O 
// O X A 
// O P O 
@external
func test_jump_with_diagonal_up_right_obstacle_in_x_minus_1{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    tempvar map_grids: felt* = cast(new(O, O, O,
                                        O, X, O,
                                        O, O, O),  felt*);
    let map = Map(map_grids, 3, 3);  
    
    let result_after: Point = jump(2, 1, 1, 2, map, UNDEFINED);
    assert result_after = 5;
    // assert result_after = Point(2, 1, TRUE);

    return ();
}

// Giving parent (P) and actual (A) has an obstacle in (y + 1) position
// When call jump()
// Then method will return actual node as jump point
// Map:
// O O O 
// O A O  
// P X O 
@external
func test_jump_with_diagonal_up_right_obstacle_in_y_plus_1{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    tempvar map_grids: felt* = cast(new(O, O, O,
                                        O, O, O,
                                        O, X, O),  felt*);
    let map = Map(map_grids, 3, 3);  
    
    let result_after: Point = jump(1, 1, 0, 2, map, UNDEFINED);
    assert result_after = 4;
    // assert result_after = Point(1, 1, TRUE);

    return ();
}

// Giving parent (P) and actual (A) has an obstacle in (x - 1) position
// When call jump()
// Then method will return actual node as jump point
// Map:
// O P O
// O X A 
// O O O 
@external
func test_jump_with_diagonal_down_right_obstacle_in_x_minus_1{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    tempvar map_grids: felt* = cast(new(O, O, O,
                                        O, X, O,
                                        O, O, O),  felt*);
    let map = Map(map_grids, 3, 3);  
    
    let result_after: Point = jump(2, 1, 1, 0, map, UNDEFINED);
    assert result_after = 5;
    // assert result_after = Point(2, 1, TRUE);

    return ();
}

// Giving parent (P) and actual (A) has an obstacle in (y - 1) position
// When call jump()
// Then method will return actual node as jump point
// Map:
// O O O
// P X O 
// O A O 
@external
func test_jump_with_diagonal_down_right_obstacle_in_y_minus_1{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    tempvar map_grids: felt* = cast(new(O, O, O,
                                        O, X, O,
                                        O, O, O),  felt*);
    let map = Map(map_grids, 3, 3);  
    
    let result_after: Point = jump(1, 2, 0, 1, map, UNDEFINED);
    assert result_after = 7;
    // assert result_after = Point(1, 2, TRUE);

    return ();
}

// Giving parent (P) and actual (A) has an obstacle in (x + 1) position
// When call jump()
// Then method will return actual node as jump point
// Map:
// O O O 
// A X O 
// O P O 
@external
func test_jump_with_diagonal_up_left_obstacle_in_x_plus_1{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    tempvar map_grids: felt* = cast(new(O, O, O,
                                        O, X, O,
                                        O, O, O),  felt*);
    let map = Map(map_grids, 3, 3);

    let result_after: Point = jump(0, 1, 1, 2, map, UNDEFINED);
    // assert result_after = Point(0, 1, TRUE);
    assert result_after = 3;

    return ();
}

// Giving parent (P) and actual (A) has an obstacle in (y + 1) position
// When call jump()
// Then method will return actual node as jump point
// Map:
// O O O
// O A O 
// O X P 
@external
func test_jump_with_diagonal_up_left_obstacle_in_y_plus_1{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    tempvar map_grids: felt* = cast(new(O, O, O,
                                        O, O, O,
                                        O, X, O),  felt*);
    let map = Map(map_grids, 3, 3);
    
    let result_after: Point = jump(1, 1, 2, 2, map, UNDEFINED);
    assert result_after = 4;

    return ();
}

// Giving parent (P) and actual (A) has an obstacle in (x + 1) position
// When call jump()
// Then method will return actual node as jump point
// Map:
// O O P
// O A X 
// O O O 
@external
func test_jump_with_diagonal_down_left_obstacle_in_x_plus_1{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    tempvar map_grids: felt* = cast(new(O, O, O,
                                        O, O, X,
                                        O, O, O),  felt*);
    let map = Map(map_grids, 3, 3);
    
    let result_after: Point = jump(1, 1, 2, 0, map, UNDEFINED);
    assert result_after = 4;

    return ();
}

// Giving parent (P) and actual (A) has an obstacle in (y - 1) position
// When call jump()
// Then method will return actual node as jump point
// Map:
// O X P 
// O A O 
// O O O 
@external
func test_jump_with_diagonal_down_left_obstacle_in_y_minus_1{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    tempvar map_grids: felt* = cast(new(O, X, O,
                                        O, O, O,
                                        O, O, O),  felt*);
    let map = Map(map_grids, 3, 3);

    let result_after: Point = jump(1, 1, 2, 0, map, UNDEFINED);
    // assert result_after = Point(1, 1, TRUE);
    assert result_after = 4;

    return ();
}

//   0 1 2 3 4 5  
// 0 O O O O X O  
// 1 O S O X G O  
// 2 O O O X X O  
// 3 O O X O O O  
// 4 O O O X O X  
// 5 O X O O O X  
// S: Start, G: Goal
// Map width = 6, height = 6
@external
func test_find_path_with_small_map{pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let point_attribute: DictAccess* = create_attribute_dict(UNDEFINED);
    let (heap: DictAccess*, heap_len: felt) = heap_create();
    tempvar map_grids: felt* = cast(new(O,O,O,O,X,O,
                                        O,O,O,X,O,O,
                                        O,O,O,X,X,O,
                                        O,O,X,O,O,O,
                                        O,O,O,X,O,X,
                                        O,X,O,O,O,X), felt*);
    let map = Map(map_grids, 6, 6);

    let start_x = 1;
    let start_y = 1;
    let end_x = 4;
    let end_y = 1;
    let (result_after_lenght: felt, result_after: Point*) = find_path{pedersen_ptr=pedersen_ptr, range_check_ptr=range_check_ptr, point_attribute=point_attribute, heap=heap}(start_x, start_y, end_x, end_y, map);

    let expected_result_points: Point* = alloc();
    let expected_result_points_lenght = 8;
    assert expected_result_points[0] = Point(1, 1);
    assert expected_result_points[1] = Point(1, 3);
    assert expected_result_points[2] = Point(2, 4);
    assert expected_result_points[3] = Point(3, 5);
    assert expected_result_points[4] = Point(4, 4);
    assert expected_result_points[5] = Point(5, 3);
    assert expected_result_points[6] = Point(5, 2);
    assert expected_result_points[7] = Point(4, 1);

    let paths_are_equals = contains_all_points(result_after, result_after_lenght, expected_result_points, expected_result_points_lenght);
    assert paths_are_equals = TRUE;

    return ();
}

//   0 1 2 3 4 5  
// 0 O O O O X O  
// 1 O S O X G O  
// 2 O O O X X O  
// 3 O O X O O O  
// 4 O O O X O X  
// 5 O X O X O X  
// S: Start, G: Goal
// Map width = 6, height = 6
@external
func test_find_path_with_small_map_non_solution{pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let point_attribute: DictAccess* = create_attribute_dict(UNDEFINED);
    let heap: DictAccess* = heap_create();
    tempvar map_grids: felt* = cast(new(O,O,O,O,X,O,
                                        O,O,O,X,O,O,
                                        O,O,O,X,X,O,
                                        O,O,X,O,O,O,
                                        O,O,O,X,O,X,
                                        O,X,O,X,O,X), felt*);
    let map = Map(map_grids, 6, 6);

    let start_x = 1;
    let start_y = 1;
    let end_x = 4;
    let end_y = 1;
    let (result_after_lenght: felt, result_after: Point*) = find_path{pedersen_ptr=pedersen_ptr, range_check_ptr=range_check_ptr, point_attribute=point_attribute, heap=heap}(start_x, start_y, end_x, end_y, map);

    let expected_result_points: Point* = alloc();
    let expected_result_points_lenght = 0;

    let paths_are_equals = contains_all_points(result_after, result_after_lenght, expected_result_points, expected_result_points_lenght);
    assert paths_are_equals = TRUE;

    return ();
}

//   0 1 2 3 4 5  
// 0 O O O O X O  
// 1 O S O X G O  
// 2 O O O X X O  
// S: Start, G: Goal
// Map width = 6, height = 3
@external
func test_find_path_with_small_rectangular_map{pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let point_attribute: DictAccess* = create_attribute_dict(UNDEFINED);
    let heap: DictAccess* = heap_create();
    tempvar map_grids: felt* = cast(new(O,X,O,O,O,O,
                                        O,O,O,X,X,O,
                                        O,O,X,O,O,O), felt*);
    let map = Map(map_grids, 6, 3);

    let start_x = 1;
    let start_y = 2;
    let end_x = 5;
    let end_y = 0;
    let (result_after_lenght: felt, result_after: Point*) = find_path{pedersen_ptr=pedersen_ptr, range_check_ptr=range_check_ptr, point_attribute=point_attribute, heap=heap}(start_x, start_y, end_x, end_y, map);

    let expected_result_points: Point* = alloc();
    let expected_result_points_lenght = 5;
    assert expected_result_points[0] = Point(1, 2);
    assert expected_result_points[1] = Point(2, 1);
    assert expected_result_points[2] = Point(3, 0);
    assert expected_result_points[3] = Point(4, 0);
    assert expected_result_points[4] = Point(5, 0);

    let paths_are_equals = contains_all_points(result_after, result_after_lenght, expected_result_points, expected_result_points_lenght);
    assert paths_are_equals = TRUE;

    return ();
}


// @external
// func test_find_path_with_big_map{pedersen_ptr: HashBuiltin*, range_check_ptr}() {
//     alloc_locals;
//     let point_attribute: DictAccess* = create_attribute_dict(UNDEFINED);
//     let heap: DictAccess* = heap_create();
//     tempvar map_grids: felt* = cast(new(O,O,O,O,X,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,
//                                         O,X,O,O,O,X,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,
//                                         O,O,O,O,O,X,O,O,O,O,O,O,X,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,
//                                         O,O,O,O,X,X,X,X,X,O,O,O,X,X,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,
//                                         O,O,O,O,O,X,O,O,X,X,O,O,X,X,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,
//                                         O,X,O,O,O,O,O,O,O,O,X,O,X,X,X,X,X,X,X,X,X,X,X,X,X,O,O,X,X,X,
//                                         O,X,O,O,X,X,O,O,O,O,X,O,X,X,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,
//                                         O,X,O,X,O,O,X,O,O,X,O,O,X,O,O,O,X,X,X,X,X,X,X,X,X,X,O,O,O,O,
//                                         O,X,X,O,O,X,X,O,O,X,O,O,X,O,O,O,O,O,O,O,O,O,O,O,O,O,X,X,O,O,
//                                         X,O,O,O,O,O,O,O,O,O,O,O,X,O,O,O,O,O,O,O,O,O,O,O,O,O,O,O,X,O,
//                                         O,O,O,O,O,X,X,O,O,O,O,O,X,O,O,O,X,X,O,O,O,O,O,O,O,O,O,O,O,X,
//                                         O,O,X,X,O,O,X,O,O,O,O,X,O,O,O,X,O,O,X,X,X,X,X,X,X,X,X,O,O,X,
//                                         O,O,X,X,O,O,X,O,X,O,O,X,X,X,X,O,X,X,O,X,X,O,O,O,O,O,O,O,O,X,
//                                         O,O,X,X,X,O,X,O,X,O,O,O,O,O,O,O,X,X,O,X,O,O,O,O,O,X,O,O,O,X,
//                                         O,O,O,O,O,O,X,O,X,O,O,O,O,O,O,O,O,O,O,X,X,O,O,X,X,X,X,X,X,X), felt*);
//     let map = Map(map_grids, 30, 15);

//     let start_x = 1;
//     let start_y = 2;
//     let end_x = 22;
//     let end_y = 13;
//     let (result_after_lenght: felt, result_after: Point*) = find_path{pedersen_ptr=pedersen_ptr, range_check_ptr=range_check_ptr, point_attribute=point_attribute, heap=heap}(start_x, start_y, end_x, end_y, map);
//     return ();
// }