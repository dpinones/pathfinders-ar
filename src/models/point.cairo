%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_in_range
from starkware.cairo.common.dict import DictAccess
from starkware.cairo.common.hash import hash2

from src.constants.point_attribute import PARENT, UNDEFINED
from src.constants.grid import X
from src.utils.condition import _and, _equals, _max
from src.utils.dictionary import read_entry, update_entry, write_entry
from src.utils.point_converter import convert_id_to_coords

struct Point {
    x: felt,
    y: felt,
}

// It allows us to retrieve a value associated with a (x, y) and a given attribute.
// In case that we dont set any value, returns an UNDEFINED value.
//
// @param: point- Point to get attribute.
// @param: attribute - Attribute name (could be any felt, but we use pre-defined ones from constants.point_attribute).
// @return: felt - Value mapped to an attribute.
func get_point_attribute{pedersen_ptr: HashBuiltin*, point_attribute: DictAccess*}(grid_id: felt, attribute: felt) -> felt {
    let (attribute_hash) = hash2{hash_ptr=pedersen_ptr}(grid_id, attribute);
    let value = read_entry{dict_ptr=point_attribute}(attribute_hash);

    return value;
}

// It allows us to set a value associated with a (x, y) and a given attribute.
//
// @param: point- Point to get attribute.
// @param: attribute - Attribute name (could be any felt, but we use pre-defined ones from constants.point_attribute).
// @param: new_value - Value that we are going to associate to the attribute.
// @return: felt - Value mapped to an attribute.
func set_point_attribute{pedersen_ptr: HashBuiltin*, point_attribute: DictAccess*}(grid_id: felt, attribute: felt, new_value: felt) {
    let (attribute_hash) = hash2{hash_ptr=pedersen_ptr}(grid_id, attribute);
    let actual_value = read_entry{dict_ptr=point_attribute}(attribute);

    if (actual_value == UNDEFINED) {
        write_entry{dict_ptr=point_attribute}(attribute_hash, new_value);
        return ();
    } else {
        update_entry{dict_ptr=point_attribute}(attribute_hash, actual_value, new_value);
        return ();
    }
}

// Check if an array of points contains a point with position (x, y).
//
// @param: points - The array of points.
// @param: len - The len of points.
// @param: x - The x position to check if exists in the array.
// @param: y - The y position to check if exists in the array.
// @return: felt - 1 if the point exists in the array, 0 otherwise.
func contains_point{range_check_ptr}(points: felt*, points_len: felt, grid_id: felt, walkable: felt) -> felt {
    alloc_locals;
    let grid_is_in_range = is_in_range(grid_id, 0, points_len);
    if (grid_is_in_range == FALSE) {
        return FALSE;
    } 

    let has_same_walkable_value = _equals(points[grid_id], walkable);
    if(has_same_walkable_value == FALSE) {
        return FALSE;
    } 

    return TRUE;
}

// Check if two arrays has the same points.
//
// @param: points - The array of points.
// @param: points_len - The len of points.
// @param: others - The array of points to compare.
// @param: other_len - The len of other.
// @return: felt - 1 if points and other contains all points eachother, 0 otherwise.
func contains_all_points{range_check_ptr}(points: felt*, points_len: felt, other: felt*, other_len: felt) -> felt {
    if (points_len != other_len) {
        return FALSE;
    }
    return _contains_all_points(points, other, 0, points_len);
}

func _contains_all_points{range_check_ptr}(points: felt*, others: felt*, idx: felt, arrays_len: felt) -> felt {
    if (idx == arrays_len) {
        return TRUE;
    }
    let was_found = contains_point(others, arrays_len, idx, points[idx]); 
    if (was_found == FALSE) {
        return FALSE;
    }
    return _contains_all_points(points, others, idx + 1, arrays_len);
}

// Returns a list with all the nodes linked by the parent attribute.
//
// @param: point - Initial node to get its parents.
// @param: width - Map width.
// @return: (felt, Point*) - The list of all nodes linked by parent attribute and len.
func build_reverse_path_from{pedersen_ptr: HashBuiltin*, range_check_ptr, point_attribute: DictAccess*, heap: DictAccess*}(point: Point, width: felt) -> (felt, Point*) {
    let res: Point* = alloc();
    assert res[0] = point;
    return _build_reverse_path_from(point, width, res, 1);
}

func _build_reverse_path_from{pedersen_ptr: HashBuiltin*, range_check_ptr, point_attribute: DictAccess*, heap: DictAccess*}(point: Point, width: felt, result: Point*, result_len: felt) -> (felt, Point*) {
    alloc_locals;
    let parent_id = get_point_attribute(point, PARENT);
    if (parent_id != UNDEFINED) {
        let (x, y) = convert_id_to_coords(parent_id, width);
        assert result[result_len] = Point(x, y);
        return _build_reverse_path_from(Point(x, y), width, result, result_len + 1);
    } else {
        return (result_len, result);    
    }
}

// Verify if two points are equals
//
// @param: point - point to compare.
// @param: other - other point to compare.
// @return: felt - TRUE if points are equals, FALSE otherwise.
func point_equals(point: Point, other: Point) -> felt {
    tempvar x_equal = _equals(point.x, other.x);
    tempvar y_equal = _equals(point.y, other.y);
    tempvar walkable_equal = _equals(point.walkable, other.walkable);
    tempvar points_are_equals = _and(x_equal, _and(y_equal, walkable_equal));

    return points_are_equals;
}