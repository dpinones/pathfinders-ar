%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.find_element import find_element
from starkware.cairo.common.bool import TRUE, FALSE

from src.jps import identify_successors, jump
from tests.maps.map_factory import generate_map_with_obstacles
from src.models.point import Point, contains_all_points, contains_point_equals_internal
from src.models.map import Map, get_all_neighbours_of, get_inmediate_neighbours, get_point_by_position, map_equals


@external
func test_get_inmediate_neighbours_happy_path{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    // setup map
    let points: Point* = alloc();
    let obstacles: Point* = alloc();

    let (points_len: felt, points: Point*) = generate_map_with_obstacles(5, 5, obstacles, 0); 
    let map = Map(points, 25, 5, 5);

    let (result_after_len, result_after) = get_inmediate_neighbours(map, 1, 1);

    let (points_expected: Point*) = alloc();
    assert points_expected[0] = Point(0, 0, 1);
    assert points_expected[1] = Point(1, 0, 1);
    assert points_expected[2] = Point(2, 0, 1);
    assert points_expected[3] = Point(0, 1, 1);
    assert points_expected[4] = Point(2, 1, 1);
    assert points_expected[5] = Point(0, 2, 1);
    assert points_expected[6] = Point(1, 2, 1);
    assert points_expected[7] = Point(2, 2, 1);

    let contains = contains_all_points(result_after, result_after_len, points_expected, 8);
    assert contains = TRUE;

    return ();
}

@external
func test_get_inmediate_neighbours_corner{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    // setup map
    let points: Point* = alloc();
    let obstacles: Point* = alloc();

    let (points_len: felt, points: Point*) = generate_points_with_obstacles(4, 4, obstacles, 0); 
    let map = Map(points, 16, 4, 4);

    let (result_after_len, result_after) = get_inmediate_neighbours(map, 0, 0);

    let (points_expected: Point*) = alloc();
    assert points_expected[0] = Point(0, 1, 1);
    assert points_expected[1] = Point(1, 1, 1);
    assert points_expected[2] = Point(1, 0, 1);

    let contains = contains_all_points(result_after, result_after_len, points_expected, 3);
    assert contains = TRUE;

    return ();
}

@external
func test_get_point_by_position{range_check_ptr}() {
    alloc_locals;
    // setup map
    let (points: Point*) = alloc();
    assert points[0] = Point(0, 0, 1);
    assert points[1] = Point(1, 0, 1);
    assert points[2] = Point(2, 0, 1);
    assert points[3] = Point(3, 0, 1);
    assert points[4] = Point(4, 0, 1);
    assert points[5] = Point(0, 1, 1);
    assert points[6] = Point(1, 1, 1);
    assert points[7] = Point(2, 1, 1);
    assert points[8] = Point(3, 1, 1);
    assert points[9] = Point(4, 1, 1);
    assert points[10] = Point(0, 2, 1);
    assert points[11] = Point(1, 2, 1);
    assert points[12] = Point(2, 2, 0);
    assert points[13] = Point(3, 2, 1);
    assert points[14] = Point(4, 2, 1);
    assert points[15] = Point(0, 3, 1);
    assert points[16] = Point(1, 3, 1);
    assert points[17] = Point(2, 3, 1);
    assert points[18] = Point(3, 3, 1);
    assert points[19] = Point(4, 3, 1);
    assert points[20] = Point(0, 4, 1);
    assert points[21] = Point(1, 4, 1);
    assert points[22] = Point(2, 4, 1);
    assert points[23] = Point(3, 4, 1);
    assert points[24] = Point(4, 4, 1);

    let map = Map(points, 25, 5, 5);

    let result_after = get_point_by_position(map, 0, 4);
    assert result_after = Point(0, 4, 1);

    %{ expect_revert("TRANSACTION_FAILED", "Point (10, 4) is out of map range.") %}
    let result_after = get_point_by_position(map, 10, 4);


    return ();
}

@external
func test_get_all_neighbours_of_internal{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    
    alloc_locals;
    // setup map
    let (points: Point*) = alloc();
    assert points[0] = Point(0, 0, 1);
    assert points[1] = Point(1, 0, 1);
    assert points[2] = Point(2, 0, 1);
    assert points[3] = Point(3, 0, 1);
    assert points[4] = Point(4, 0, 1);
    assert points[5] = Point(0, 1, 1);
    assert points[6] = Point(1, 1, 1);
    assert points[7] = Point(2, 1, 1);
    assert points[8] = Point(3, 1, 1);
    assert points[9] = Point(4, 1, 1);
    assert points[10] = Point(0, 2, 1);
    assert points[11] = Point(1, 2, 1);
    assert points[12] = Point(2, 2, 0);
    assert points[13] = Point(3, 2, 1);
    assert points[14] = Point(4, 2, 1);
    assert points[15] = Point(0, 3, 1);
    assert points[16] = Point(1, 3, 1);
    assert points[17] = Point(2, 3, 1);
    assert points[18] = Point(3, 3, 1);
    assert points[19] = Point(4, 3, 1);
    assert points[20] = Point(0, 4, 1);
    assert points[21] = Point(1, 4, 1);
    assert points[22] = Point(2, 4, 1);
    assert points[23] = Point(3, 4, 1);
    assert points[24] = Point(4, 4, 1);
    let map = Map(points, 25, 5, 5);

    // llamo a la funcion
    let (result_after_len, result_after) = get_all_neighbours_of(map, Point(1, 1, 0));

    let (points_expected: Point*) = alloc();
    assert points_expected[0] = Point(0, 0, 1);
    assert points_expected[1] = Point(1, 0, 1);
    assert points_expected[2] = Point(2, 0, 1);
    assert points_expected[3] = Point(0, 1, 1);
    assert points_expected[4] = Point(2, 1, 1);
    assert points_expected[5] = Point(0, 2, 1);
    assert points_expected[6] = Point(1, 2, 1);
    // assert points_expected[7] = Point(2, 2, 1);

    let contains = contains_all_points(result_after, result_after_len, points_expected, 7);
    assert contains = TRUE;

    return ();
}


@external
func test_jump{range_check_ptr}() {

    alloc_locals;
    // let obstacles: Point* = alloc();
    // assert obstacles[0] = Point(1, 2, 0);

    // let (points_len: felt, points: Point*) = generate_points_with_obstacles(4, 4, obstacles, 1); 
    // let result_after = jump(1, 1, 0, 1, Map(points, points_len, 4, 4), Point(3, 3, 1));
    // assert result_after = Point(1, 1, 1);

    // sin obstaculos horizontal
    // let obstacles: Point* = alloc();
    // let (points_len: felt, points: Point*) = generate_points_with_obstacles(4, 4, obstacles, 0); 
    // let result_after = jump(1, 1, 0, 1, Map(points, points_len, 4, 4), Point(3, 1, 1));
    // assert result_after = Point(3, 1, 1);

    // sin obstaculos diagonal
    let obstacles: Point* = alloc();
    let (points_len: felt, points: Point*) = generate_points_with_obstacles(3, 3, obstacles, 0); 
    let result_after = jump(1, 1, 0, 0, Map(points, points_len, 3, 3), Point(2, 2, 1));
    assert result_after = Point(2, 2, 1);

    return ();
}