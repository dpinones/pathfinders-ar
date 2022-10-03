%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE

from src.models.point import Point
from src.models.map import Map
from src.utils.map_factory import generate_map_with_obstacles, generate_map_without_obstacles
from src.jps import jump

// Definition 2. Node y is the jump point from node x, heading in direction ~d, if y minimizes the value k such that y = x+k~d
// and one of the following conditions holds:
// 1. Node y is the goal node.
// 2. Node y has at least one neighbour whose evaluation is forced according to Definition 1.
// 3. ~d is a diagonal move and there exists a node z = y +ki~di
// which lies ki ∈ N steps in direction ~di ∈ { ~d1,~d2} such that z is a jump point from y by condition 1 or condition 2.

// K = 1 (test case in first iteration)
// Node y is the goal node.

// Giving parent and actual (next) nodes
// When actual is the goal and call jump()
// Then method will return actual node as jump point
// Map:
// O O O O
// O P G O
// O O O O
// O O O O
@external
func test_jump_next_node_is_goal{range_check_ptr}() {
    alloc_locals;
    let map = generate_map_without_obstacles(4, 4); 
    let goal = Point(2, 1, TRUE);

    let result_after = jump(2, 1, 1, 1, map, goal);
    assert result_after = Point(2, 1, TRUE);

    return ();
}

// Giving parent (P) and actual (A) has an obstacle in (y + 1) position
// When call jump()
// Then method will return actual node as jump point
// Map:
// O O O O
// O P A O
// O O X O
// O O O O
@external
func test_jump_with_horizontal_right_obstacle_in_y_plus_1{range_check_ptr}() {
    alloc_locals;
    let obstacles: Point* = alloc();
    let obstacles_len = 1;
    assert obstacles[0] = Point(2, 2, FALSE);

    let map = generate_map_with_obstacles(4, 4, obstacles, obstacles_len); 
    let result_after: Point = jump(2, 1, 1, 1, map, Point(3, 3, TRUE));
    assert result_after = Point(2, 1, TRUE);

    return ();
}

// Giving parent (P) and actual (A) has an obstacle in (y - 1) position
// When call jump()
// Then method will return actual node as jump point
// Map:
// O O X O
// O P A O
// O O O O
// O O O O
@external
func test_jump_with_horizontal_right_obstacle_in_y_minus_1{range_check_ptr}() {
    alloc_locals;
    let obstacles: Point* = alloc();
    let obstacles_len = 1;
    assert obstacles[0] = Point(2, 0, FALSE);

    let map = generate_map_with_obstacles(4, 4, obstacles, obstacles_len); 
    let result_after: Point = jump(2, 1, 1, 1, map, Point(3, 3, TRUE));
    assert result_after = Point(2, 1, TRUE);

    return ();
}

// Giving parent (P) and actual (A) has an obstacle in (y - 1) position
// When call jump()
// Then method will return actual node as jump point
// Map:
// O O X O
// O O A P
// O O O O
// O O O O
@external
func test_jump_with_horizontal_left_obstacle_in_y_minus_1{range_check_ptr}() {
    alloc_locals;
    let obstacles: Point* = alloc();
    let obstacles_len = 1;
    assert obstacles[0] = Point(2, 0, FALSE);

    let map = generate_map_with_obstacles(4, 4, obstacles, obstacles_len); 
    let result_after: Point = jump(2, 1, 3, 1, map, Point(3, 3, TRUE));
    assert result_after = Point(2, 1, TRUE);

    return ();
}