%lang starknet
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE

from src.models.point import Point, contains_point, contains_point_equals, contains_all_points

// Giving a point that exists in the point array,
// When call contains_point(),
// Then the method should return TRUE.
@external
func test_contains_point_happy_path() {
    let points: Point* = alloc();
    let points_lenght = 5;
    assert points[0] = Point(0, 0, TRUE);
    assert points[1] = Point(0, 1, TRUE);
    assert points[2] = Point(0, 3, TRUE);
    assert points[3] = Point(0, 4, TRUE);
    assert points[4] = Point(0, 5, TRUE);

    let result = contains_point(points, points_lenght, 0, 1);
    assert result = TRUE;

    return();
}

// Giving a point that not exists in the point array,
// When call contains_point(),
// Then the method should return FALSE.
@external
func test_contains_point_out_of_array() {
    let points: Point* = alloc();
    let points_lenght = 5;
    assert points[0] = Point(0, 0, TRUE);
    assert points[1] = Point(0, 1, TRUE);
    assert points[2] = Point(0, 3, TRUE);
    assert points[3] = Point(0, 4, TRUE);
    assert points[4] = Point(0, 5, TRUE);

    let result = contains_point(points, points_lenght, 3, 3);
    assert result = FALSE;

    return();
}

// Giving an empty array checking if contains any point,
// When call contains_point(),
// Then the method should return FALSE.
@external
func test_contains_point_empty_array() {
    let points: Point* = alloc();
    let points_lenght = 0;

    let result = contains_point(points, points_lenght, 3, 3);
    assert result = FALSE;

    return();
}

// Giving a two arrays that has same points (without compare walkable value),
// When call contains_all_points(),
// Then the method should return TRUE.
@external
func test_contains_all_points_happy_path() {
    let points: Point* = alloc();
    let points_lenght = 5;
    assert points[0] = Point(0, 0, TRUE);
    assert points[1] = Point(0, 1, TRUE);
    assert points[2] = Point(0, 3, TRUE);
    assert points[3] = Point(0, 4, TRUE);
    assert points[4] = Point(0, 5, TRUE);

    let others: Point* = alloc();
    let others_lenght = 5;
    assert others[0] = Point(0, 0, TRUE);
    assert others[1] = Point(0, 1, TRUE);
    assert others[2] = Point(0, 3, TRUE);
    assert others[3] = Point(0, 4, TRUE);
    assert others[4] = Point(0, 5, TRUE);

    let result = contains_all_points(points, points_lenght, others, others_lenght);
    assert result = TRUE;

    return();
}

// Giving a two arrays that has first array distinct (without compare walkable value),
// When call contains_all_points(),
// Then the method should return FALSE.
@external
func test_contains_all_points_first_array_distinct() {
    let points: Point* = alloc();
    let points_lenght = 5;
    assert points[0] = Point(0, 0, TRUE);
    assert points[1] = Point(0, 1, TRUE);
    assert points[2] = Point(0, 3, TRUE);
    assert points[3] = Point(0, 4, TRUE);
    assert points[4] = Point(0, 5, TRUE);

    let others: Point* = alloc();
    let others_lenght = 5;
    assert others[0] = Point(0, 0, TRUE);
    assert others[1] = Point(1, 1, TRUE); // different x
    assert others[2] = Point(0, 3, TRUE);
    assert others[3] = Point(0, 4, TRUE);
    assert others[4] = Point(0, 5, TRUE);

    let result = contains_all_points(points, points_lenght, others, others_lenght);
    assert result = FALSE;

    return();
}

// Giving a two arrays that has second array distinct (without compare walkable value),
// When call contains_all_points(),
// Then the method should return FALSE.
@external
func test_contains_all_points_second_array_distinct() {
    let points: Point* = alloc();
    let points_lenght = 5;
    assert points[0] = Point(0, 0, TRUE);
    assert points[1] = Point(1, 1, TRUE); // different x
    assert points[2] = Point(0, 3, TRUE);
    assert points[3] = Point(0, 4, TRUE);
    assert points[4] = Point(0, 5, TRUE);

    let others: Point* = alloc();
    let others_lenght = 5;
    assert others[0] = Point(0, 0, TRUE);
    assert others[1] = Point(0, 1, TRUE); 
    assert others[2] = Point(0, 3, TRUE);
    assert others[3] = Point(0, 4, TRUE);
    assert others[4] = Point(0, 5, TRUE);

    let result = contains_all_points(points, points_lenght, others, others_lenght);
    assert result = FALSE;

    return();
}

// Giving a two arrays with distinct lenght,
// When call contains_all_points(),
// Then the method should return FALSE.
@external
func test_contains_all_points_distinct_len() {
    let points: Point* = alloc();
    let points_lenght = 3;
    assert points[0] = Point(0, 0, TRUE);
    assert points[1] = Point(1, 1, TRUE);
    assert points[2] = Point(0, 3, TRUE);

    let others: Point* = alloc();
    let others_lenght = 2;
    assert others[0] = Point(0, 0, TRUE);
    assert others[1] = Point(0, 1, TRUE); 

    let result = contains_all_points(points, points_lenght, others, others_lenght);
    assert result = FALSE;

    return();
}

// Giving a point that exists in the point array (check also walkable value),
// When call contains_point_equals(),
// Then the method should return TRUE.
@external
func test_contains_point_equals_happy_path() {
    let points: Point* = alloc();
    let points_lenght = 5;
    assert points[0] = Point(0, 0, TRUE);
    assert points[1] = Point(0, 1, TRUE);
    assert points[2] = Point(0, 3, TRUE);
    assert points[3] = Point(0, 4, TRUE);
    assert points[4] = Point(0, 5, TRUE);

    let result = contains_point_equals(points, points_lenght, 0, 1, TRUE);
    assert result = TRUE;

    return();
}

// Giving a point that exists in the point array but walkable value dont match,
// When call contains_point_equals(),
// Then the method should return FALSE.
@external
func test_contains_point_equals_walkable_value_dont_match() {
    let points: Point* = alloc();
    let points_lenght = 5;
    assert points[0] = Point(0, 0, TRUE);
    assert points[1] = Point(0, 1, TRUE);
    assert points[2] = Point(0, 3, TRUE);
    assert points[3] = Point(0, 4, TRUE);
    assert points[4] = Point(0, 5, TRUE);

    let result = contains_point_equals(points, points_lenght, 0, 1, FALSE);
    assert result = FALSE;

    return();
}

// Giving a point that not exists in the point,
// When call contains_point_equals(),
// Then the method should return FALSE.
@external
func test_contains_point_equals_out_of_array() {
    let points: Point* = alloc();
    let points_lenght = 2;
    assert points[0] = Point(0, 0, TRUE);
    assert points[1] = Point(0, 1, TRUE);

    let result = contains_point_equals(points, points_lenght, 3, 3, TRUE);
    assert result = FALSE;

    return();
}

// Giving an empty array checking if contains any point,
// When call contains_point_equals(),
// Then the method should return FALSE.
@external
func test_contains_point_equals_empty_array() {
    let points: Point* = alloc();
    let points_lenght = 0;

    let result = contains_point_equals(points, points_lenght, 2, 2, TRUE);
    assert result = FALSE;

    return();
}

