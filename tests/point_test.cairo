%lang starknet
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE

from src.models.point import Point, contains_point, contains_all_points
// Giving a point that exists in the point array,
// When call contains_point(),
// Then the method should return TRUE.
@external
func test_contains_point_happy_path{range_check_ptr}() {
    let points_length = 9;
    tempvar points: felt* = cast(new(0, 0, 0,
                                     0, 0, 0,
                                     0, 0, 0,), felt*);

    let result = contains_point(points, points_length, 1, 0);
    assert result = TRUE;

    return();
}

// Giving a point that not exists in the point array,
// When call contains_point(),
// Then the method should return FALSE.
@external
func test_contains_point_out_of_array{range_check_ptr}() {
    let points_length = 9;
    tempvar points: felt* = cast(new(0, 0, 0,
                                     0, 0, 0,
                                     0, 0, 0,), felt*);

    let result = contains_point(points, points_length, 3, 2);
    assert result = FALSE;

    return();
}

// Giving an empty array checking if contains any point,
// When call contains_point(),
// Then the method should return FALSE.
@external
func test_contains_point_empty_array{range_check_ptr}() {
    let points: felt* = alloc();
    let points_length = 0;

    let result = contains_point(points, points_length, 3, 0);
    assert result = FALSE;

    return();
}

// Giving a two arrays that has same points (without compare walkable value),
// When call contains_all_points(),
// Then the method should return TRUE.
@external
func test_contains_all_points_happy_path{range_check_ptr}() {
    let points_length = 9;
    tempvar points: felt* = cast(new(0, 0, 0,
                                     0, 1, 0,
                                     0, 0, 1,), felt*);

    let others_length = 9;
    tempvar others: felt* = cast(new(0, 0, 0,
                                     0, 1, 0,
                                     0, 0, 1,), felt*);

    let result = contains_all_points(points, points_length, others, others_length);
    assert result = TRUE;

    return();
}

// Giving a two arrays that has first array distinct (without compare walkable value),
// When call contains_all_points(),
// Then the method should return FALSE.
@external
func test_contains_all_points_first_array_distinct{range_check_ptr}() {
    let points_length = 9;
    tempvar points: felt* = cast(new(0, 1, 0,
                                     0, 0, 0,
                                     0, 0, 0,), felt*);

    let others_length = 9;
    tempvar others: felt* = cast(new(0, 0, 0,
                                     0, 0, 0,
                                     0, 0, 0,), felt*);

    let result = contains_all_points(points, points_length, others, others_length);
    assert result = FALSE;

    return();
}

// Giving a two arrays that has second array distinct (without compare walkable value),
// When call contains_all_points(),
// Then the method should return FALSE.
@external
func test_contains_all_points_second_array_distinct{range_check_ptr}() {
    let points_length = 9;
    tempvar points: felt* = cast(new(0, 0, 0,
                                     0, 0, 0,
                                     0, 0, 0,), felt*);

    let others_length = 9;
    tempvar others: felt* = cast(new(0, 1, 0,
                                     0, 0, 0,
                                     0, 0, 0,), felt*);

    let result = contains_all_points(points, points_length, others, others_length);
    assert result = FALSE;

    return();
}

// Giving a two arrays with distinct lenght,
// When call contains_all_points(),
// Then the method should return FALSE.
@external
func test_contains_all_points_distinct_len{range_check_ptr}() {
    let points_length = 3;
    tempvar points: felt* = cast(new(0, 0, 0), felt*);

    let others_length = 2;
    tempvar others: felt* = cast(new(0, 0), felt*);

    let result = contains_all_points(points, points_length, others, others_length);
    assert result = FALSE;

    return();
}

// Giving a point that exists in the point array (check also walkable value),
// When call contains_point_equals(),
// Then the method should return TRUE.
@external
func test_contains_point_equals_happy_path{range_check_ptr}() {
    let points_length = 3;
    tempvar points: felt* = cast(new(0, 1, 0), felt*);

    let result = contains_point(points, points_length, 1, 1);
    assert result = TRUE;

    return();
}

// Giving a point that exists in the point array but walkable value dont match,
// When call contains_point_equals(),
// Then the method should return FALSE.
@external
func test_contains_point_equals_walkable_value_dont_match{range_check_ptr}() {
    let points_length = 5;
    tempvar points: felt* = cast(new(0, 0, 0, 0, 0), felt*);

    let result = contains_point(points, points_length, 1, 1);
    assert result = FALSE;

    return();
}

// Giving a point that not exists in the point,
// When call contains_point_equals(),
// Then the method should return FALSE.
@external
func test_contains_point_equals_out_of_array{range_check_ptr}() {
    let points_length = 2;
    tempvar points: felt* = cast(new(0, 0), felt*);

    let result = contains_point(points, points_length, 3, 1);
    assert result = FALSE;

    return();
}

// Giving an empty array checking if contains any point,
// When call contains_point_equals(),
// Then the method should return FALSE.
@external
func test_contains_point_equals_empty_array{range_check_ptr}() {
    let points: felt* = alloc();
    let points_length = 0;

    let result = contains_point(points, points_length, 4, 1);
    assert result = FALSE;

    return();
}

