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