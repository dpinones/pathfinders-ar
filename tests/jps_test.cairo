%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE

from src.models.point import Point
from src.models.map import Map
from src.utils.map_factory import generate_map_with_obstacles, generate_map_without_obstacles
from src.jps import jump

// Giving parent (P) and actual (G) 
// When actual is the goal and call jump()
// Then method will return actual node as jump point
// Map:
// O O O 
// O P G 
// O O O 
@external
func test_jump_actual_node_is_the_goal{range_check_ptr}() {
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
func test_jump_with_horizontal_right_obstacle_in_y_plus_1{range_check_ptr}() {
    alloc_locals;
    let obstacles: Point* = alloc();
    let obstacles_len = 1;
    assert obstacles[0] = Point(1, 2, FALSE);

    let map = generate_map_with_obstacles(3, 3, obstacles, obstacles_len); 
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
func test_jump_with_horizontal_right_obstacle_in_y_minus_1{range_check_ptr}() {
    alloc_locals;
    let obstacles: Point* = alloc();
    let obstacles_len = 1;
    assert obstacles[0] = Point(1, 0, FALSE);

    let map = generate_map_with_obstacles(3, 3, obstacles, obstacles_len); 
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
func test_jump_with_horizontal_left_obstacle_in_y_minus_1{range_check_ptr}() {
    alloc_locals;
    let obstacles: Point* = alloc();
    let obstacles_len = 1;
    assert obstacles[0] = Point(1, 0, FALSE);

    let map = generate_map_with_obstacles(3, 3, obstacles, obstacles_len); 
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
func test_jump_with_horizontal_left_obstacle_in_y_plus_1{range_check_ptr}() {
    alloc_locals;
    let obstacles: Point* = alloc();
    let obstacles_len = 1;
    assert obstacles[0] = Point(1, 2, FALSE);

    let map = generate_map_with_obstacles(3, 3, obstacles, obstacles_len); 
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
func test_jump_with_vertical_down_obstacle_in_x_plus_1{range_check_ptr}() {
    alloc_locals;
    let obstacles: Point* = alloc();
    let obstacles_len = 1;
    assert obstacles[0] = Point(2, 1, FALSE);

    let map = generate_map_with_obstacles(3, 3, obstacles, obstacles_len); 
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
func test_jump_with_vertical_down_obstacle_in_x_minus_1{range_check_ptr}() {
    alloc_locals;
    let obstacles: Point* = alloc();
    let obstacles_len = 1;
    assert obstacles[0] = Point(0, 1, FALSE);

    let map = generate_map_with_obstacles(3, 3, obstacles, obstacles_len); 
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
func test_jump_with_vertical_up_obstacle_in_x_plus_1{range_check_ptr}() {
    alloc_locals;
    let obstacles: Point* = alloc();
    let obstacles_len = 1;
    assert obstacles[0] = Point(2, 1, FALSE);

    let map = generate_map_with_obstacles(3, 3, obstacles, obstacles_len); 
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
func test_jump_with_vertical_up_obstacle_in_x_minus_1{range_check_ptr}() {
    alloc_locals;
    let obstacles: Point* = alloc();
    let obstacles_len = 1;
    assert obstacles[0] = Point(2, 1, FALSE);

    let map = generate_map_with_obstacles(3, 3, obstacles, obstacles_len); 
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
func test_jump_with_diagonal_up_right_obstacle_in_x_minus_1{range_check_ptr}() {
    alloc_locals;
    let obstacles: Point* = alloc();
    let obstacles_len = 1;
    assert obstacles[0] = Point(1, 1, FALSE);

    let map = generate_map_with_obstacles(3, 3, obstacles, obstacles_len); 
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
func test_jump_with_diagonal_up_right_obstacle_in_y_plus_1{range_check_ptr}() {
    alloc_locals;
    let obstacles: Point* = alloc();
    let obstacles_len = 1;
    assert obstacles[0] = Point(1, 2, FALSE);

    let map = generate_map_with_obstacles(3, 3, obstacles, obstacles_len); 
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
func test_jump_with_diagonal_down_right_obstacle_in_x_minus_1{range_check_ptr}() {
    alloc_locals;
    let obstacles: Point* = alloc();
    let obstacles_len = 1;
    assert obstacles[0] = Point(1, 1, FALSE);

    let map = generate_map_with_obstacles(3, 3, obstacles, obstacles_len); 
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
func test_jump_with_diagonal_down_right_obstacle_in_y_minus_1{range_check_ptr}() {
    alloc_locals;
    let obstacles: Point* = alloc();
    let obstacles_len = 1;
    assert obstacles[0] = Point(1, 1, FALSE);

    let map = generate_map_with_obstacles(3, 3, obstacles, obstacles_len); 
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
func test_jump_with_diagonal_up_left_obstacle_in_x_plus_1{range_check_ptr}() {
    alloc_locals;
    let obstacles: Point* = alloc();
    let obstacles_len = 1;
    assert obstacles[0] = Point(1, 1, FALSE);

    let map = generate_map_with_obstacles(3, 3, obstacles, obstacles_len); 
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
func test_jump_with_diagonal_up_left_obstacle_in_y_plus_1{range_check_ptr}() {
    alloc_locals;
    let obstacles: Point* = alloc();
    let obstacles_len = 1;
    assert obstacles[0] = Point(1, 2, FALSE);

    let map = generate_map_with_obstacles(3, 3, obstacles, obstacles_len); 
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
func test_jump_with_diagonal_down_left_obstacle_in_x_plus_1{range_check_ptr}() {
    alloc_locals;
    let obstacles: Point* = alloc();
    let obstacles_len = 1;
    assert obstacles[0] = Point(2, 1, FALSE);

    let map = generate_map_with_obstacles(3, 3, obstacles, obstacles_len); 
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
func test_jump_with_diagonal_down_left_obstacle_in_y_minus_1{range_check_ptr}() {
    alloc_locals;
    let obstacles: Point* = alloc();
    let obstacles_len = 1;
    assert obstacles[0] = Point(1, 0, FALSE);

    let map = generate_map_with_obstacles(3, 3, obstacles, obstacles_len); 
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
func test_jump_with_large_map{range_check_ptr}() {
    alloc_locals;
    let obstacles: Point* = alloc();
    let obstacles_len = 29;
    assert obstacles[0] = Point(2, 1,  FALSE);
    assert obstacles[1] = Point(14, 1, FALSE);
    assert obstacles[2] = Point(2, 2, FALSE);
    assert obstacles[3] = Point(13, 2, FALSE);
    assert obstacles[4] = Point(14, 2, FALSE);
    assert obstacles[5] = Point(2, 3, FALSE);
    assert obstacles[6] = Point(12, 3, FALSE);
    assert obstacles[7] = Point(13, 3, FALSE);
    assert obstacles[8] = Point(14, 3, FALSE);
    assert obstacles[9] = Point(15, 3, FALSE);
    assert obstacles[10] = Point(1, 4, FALSE);
    assert obstacles[11] = Point(4, 2, FALSE);
    assert obstacles[12] = Point(3, 4, FALSE);
    assert obstacles[13] = Point(9, 4, FALSE);
    assert obstacles[14] = Point(10, 4, FALSE);
    assert obstacles[15] = Point(11, 4, FALSE);
    assert obstacles[16] = Point(12, 4, FALSE);
    assert obstacles[17] = Point(13, 4, FALSE);
    assert obstacles[18] = Point(14, 4, FALSE);
    assert obstacles[19] = Point(15, 4, FALSE);
    assert obstacles[20] = Point(2, 5, FALSE);
    assert obstacles[21] = Point(15, 5, FALSE);
    assert obstacles[22] = Point(16, 5, FALSE);
    assert obstacles[23] = Point(2, 6, FALSE);
    assert obstacles[24] = Point(7, 6, FALSE);
    assert obstacles[25] = Point(6, 6, FALSE);
    assert obstacles[26] = Point(8, 6, FALSE);
    assert obstacles[27] = Point(15, 6, FALSE);
    assert obstacles[28] = Point(16, 6, FALSE);

    //let map = generate_map_with_obstacles(50, 50, obstacles, obstacles_len); 
    let map = generate_map_with_obstacles(100, 100, obstacles, obstacles_len); 
    // let result_after: Point = jump(3, 6, 2, 5, map, Point(-1, -1, -1));
    // assert result_after = Point(3, 6, TRUE);

    // let result_after: Point = jump(4, 6, 3, 6, map, Point(-1, -1, -1));
    // assert result_after = Point(-1, -1, -1);

    return ();
}