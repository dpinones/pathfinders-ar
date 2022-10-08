%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE
from src.constants.point_status import OPENED, CLOSED
from src.constants.point_attribute import UNDEFINED
from src.constants.grid import X, O
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.dict import DictAccess

from src.utils.dictionary import create_dict
from src.models.point import Point
from src.models.map import Map
from src.utils.map_factory import generate_map_without_obstacles
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
    let goal = Point(2, 1, TRUE);

    let result_after = jump(2, 1, 1, 1, map, goal);
    assert result_after = Point(2, 1, TRUE);

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

    let result_after: Point = jump(1, 1, 0, 1, map, Point(-1, -1, -1));
    assert result_after = Point(1, 1, TRUE);

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

    let result_after: Point = jump(1, 1, 0, 1, map, Point(-1, -1, -1));
    assert result_after = Point(1, 1, TRUE);

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

    let result_after: Point = jump(1, 1, 2, 1, map, Point(-1, -1, -1));
    assert result_after = Point(1, 1, TRUE);

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

    let result_after: Point = jump(1, 1, 2, 1, map, Point(-1, -1, -1));
    assert result_after = Point(1, 1, TRUE);

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

    let result_after: Point = jump(1, 1, 1, 0, map, Point(-1, -1, -1));
    assert result_after = Point(1, 1, TRUE);

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

    let result_after: Point = jump(1, 1, 1, 0, map, Point(-1, -1, -1));
    assert result_after = Point(1, 1, TRUE);

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

    let result_after: Point = jump(1, 1, 1, 2, map, Point(-1, -1, -1));
    assert result_after = Point(1, 1, TRUE);

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

    let result_after: Point = jump(1, 1, 1, 2, map, Point(-1, -1, -1));
    assert result_after = Point(1, 1, TRUE);

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
    
    let result_after: Point = jump(2, 1, 1, 2, map, Point(-1, -1, -1));
    assert result_after = Point(2, 1, TRUE);

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
    
    let result_after: Point = jump(1, 1, 0, 2, map, Point(-1, -1, -1));
    assert result_after = Point(1, 1, TRUE);

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
    
    let result_after: Point = jump(2, 1, 1, 0, map, Point(-1, -1, -1));
    assert result_after = Point(2, 1, TRUE);

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
    
    let result_after: Point = jump(1, 2, 0, 1, map, Point(-1, -1, -1));
    assert result_after = Point(1, 2, TRUE);

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

    let result_after: Point = jump(0, 1, 1, 2, map, Point(-1, -1, -1));
    assert result_after = Point(0, 1, TRUE);

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
    
    let result_after: Point = jump(1, 1, 2, 2, map, Point(-1, -1, -1));
    assert result_after = Point(1, 1, TRUE);

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
    
    let result_after: Point = jump(1, 1, 2, 0, map, Point(-1, -1, -1));
    assert result_after = Point(1, 1, TRUE);

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

    let result_after: Point = jump(1, 1, 2, 0, map, Point(-1, -1, -1));
    assert result_after = Point(1, 1, TRUE);

    return ();
}

// Giving parent (P) and actual (A) has an obstacle in (y - 1) position
// When call jump()
// Then method will return actual node as jump point
// Map width = 20, height = 10
//   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9
// 0 O O O O O O O O O O O O O O O O O O O O
// 1 O O X O O O O O O O O O O O X O O O O O
// 2 O O X O O P O O O O O O O X X O O O O O
// 3 O O X O O O A O O O O O X X X X O O O O
// 4 O X X X O O O O J X X X X X X X O O O O
// 5 O O X O O O O O O O O O O O O X X O O O
// 6 O O X O O O X X X O O O O O O X X O O O
// 7 O O O O O O O O O O O O O O O O O O O O
// 8 O O O O O O O O O O O O O O O O O O O O
// 9 O O O O O O O O O O O O O O O O O O O O
@external
func test_find_path_with_large_map{pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let dict_ptr: DictAccess* = create_dict(UNDEFINED);
    tempvar map_grids: felt* = cast(new(O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O,
                                        O, O, X, O, O, O, O, O, O, O, O, O, O, O, X, O, O, O, O, O,
                                        O, O, X, O, O, O, O, O, O, O, O, O, O, X, X, O, O, O, O, O,
                                        O, O, X, O, O, O, O, O, O, O, O, O, O, X, X, O, O, O, O, O,
                                        O, X, X, X, O, O, O, O, O, O, O, O, X, X, X, X, O, O, O, O,
                                        O, O, X, O, O, O, O, O, O, X, X, X, X, X, X, X, O, O, O, O,
                                        O, O, X, O, O, O, O, O, O, O, O, O, O, O, O, X, X, O, O, O,
                                        O, O, X, O, O, O, X, X, X, O, O, O, O, O, O, X, X, O, O, O,
                                        O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O,
                                        O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O, O),  felt*);
    let map = Map(map_grids, 20, 10);
    let (result_after_lenght: felt, result_after: Point*) = find_path{pedersen_ptr=pedersen_ptr, range_check_ptr=range_check_ptr, dict_ptr=dict_ptr}(1, 7, 14, 7, map);
    // let result_after: Point = jump(3, 6, 2, 5, map, Point(-1, -1, -1));
    // assert result_after_lenght = 123;
    // let result_after: Point = jump(4, 6, 3, 6, map, Point(-1, -1, -1));
    // assert result_after = Point(-1, -1, -1);
    return ();
}

// Giving parent (P) and actual (A) has an obstacle in (y - 1) position
// When call jump()
// Then method will return actual node as jump point
// Map width = 20, height = 10
//   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9
// 0 O O O O O O O O O O O O O O O O O O O O
// 1 O O X O O O O O O O O O O O X O O O O O
// 2 O O X O O P O O O O O O O X X O O O O O
// 3 O O X O O O A O O O O O X X X X O O O O
// 4 O X X X O O O O J X X X X X X X O O O O
// 5 O O X O O O O O O O O O O O O X X O O O
// 6 O O X O O O X X X O O O O O O X X O O O
// 7 O O O O O O O O O O O O O O O O O O O O
// 8 O O O O O O O O O O O O O O O O O O O O
// 9 O O O O O O O O O O O O O O O O O O O O
@external
func test_find_path_with_large_map2{pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let dict_ptr: DictAccess* = create_dict(UNDEFINED);
    tempvar map_grids: felt* = cast(new(
            O, O, O, O, O, O, O, O, X, O, O, O, O, O, X, X, X, O, O, O, 
            O, O, O, O, O, O, O, X, O, O, O, O, O, O, X, O, O, O, O, O,
            O, O, O, O, O, O, X, O, O, O, O, O, O, X, X, O, X, X, X, X,
            O, O, O, O, O, X, X, O, O, O, O, O, O, X, O, O, X, O, O, O,
            O, O, O, O, O, X, O, O, O, O, O, O, X, O, O, O, X, O, O, O,
            O, O, O, O, O, X, O, O, X, O, O, X, X, O, O, O, X, X, X, X,
            O, O, O, O, O, X, O, O, X, O, O, X, O, O, O, O, O, O, O, O,
            O, O, O, O, X, X, O, X, O, O, X, O, O, O, O, O, O, O, O, O,
            O, O, O, O, X, O, X, O, O, O, X, O, O, O, O, O, X, X, O, O,
            O, O, O, X, O, O, X, O, O, X, O, O, O, O, O, X, X, X, O, O,
            O, O, O, X, O, O, X, O, O, X, O, O, O, O, X, X, O, X, O, O,
            O, O, O, X, O, O, X, O, X, X, O, O, O, X, O, O, O, O, X, O,
            O, O, O, X, X, X, X, X, X, O, O, X, X, O, O, O, O, O, X, O,
            O, O, O, O, O, X, X, O, O, O, X, X, O, O, O, O, O, O, X, O,
            O, X, O, O, O, O, O, O, X, X, O, O, O, O, O, O, O, O, X, O,
            X, X, X, X, X, X, X, O, X, O, O, O, O, X, O, O, O, O, X, O,
            O, O, X, O, X, X, X, X, X, O, O, O, O, X, O, O, O, O, X, O,
            O, O, O, O, X, X, X, O, X, O, O, O,  O, X, O, O, O, O, X, O,
            O, O, O, O, O, X, O, X, X, O, O, O, O, X, X, X, X, X, X, O,
            O, O, X, O, O, X, O, O, X, O, O, O, O, O, O, O, O, O, O, O),  felt*);
    let map = Map(map_grids, 20, 20);
    let start_x = 2;
    let start_y = 2;
    let end_x = 17;
    let end_y = 16;
    let (result_after_lenght: felt, result_after: Point*) = find_path{pedersen_ptr=pedersen_ptr, range_check_ptr=range_check_ptr, dict_ptr=dict_ptr}(start_x, start_y, end_x, end_y, map);

    return ();
}

// Map width = 8, height = 8
//   0 1 2 3 4 5 6 7 
// 0 O O O O O O O O 
// 1 O O O O O O O O 
// 2 O O O O X O O O 
// 3 O P A O X O M O 
// 4 O O O O X O O O 
// 5 O O O O X O O O 
// 6 O O O O X O O O 
// 7 O O O O O O O O 
@external
func test_find_path_with_small_map{pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let dict_ptr: DictAccess* = create_dict(UNDEFINED);
    
    tempvar map_grids: felt* = cast(new(O, O, O, X, O, O, O, O, O,
                                        O, O, O, X, O, O, O, O, O,
                                        O, O, O, X, X, X, O, O, O,
                                        O, O, O, O, O, X, O, O, O,
                                        O, O, O, O, O, X, O, O, O,
                                        O, O, O, O, O, X, O, O, O,
                                        O, O, O, O, X, X, O, O, O,
                                        O, O, O, X, X, O, O, O, O,
                                        O, O, O, O, O, O, O, O, O,),  felt*);
    let map = Map(map_grids, 9, 9);

    let start_x = 1;
    let start_y = 4;
    let end_x = 7;
    let end_y = 4;
    let (result_after_lenght: felt, result_after: Point*) = find_path{pedersen_ptr=pedersen_ptr, range_check_ptr=range_check_ptr, dict_ptr=dict_ptr}(start_x, start_y, end_x, end_y, map);

    return ();
}
