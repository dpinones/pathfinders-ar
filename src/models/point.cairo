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
    walkable: felt,
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

// Check if the (x,y) coordinates are accessible:
//   (1) The point is inside the map 
//   (2) The point has the attribute as walkable in TRUE
//
// @param: map - Map from which we want to verify.
// @param: x - X position.
// @param: y - Y position.
// @return: Point - Returns TRUE if conditions (1) and (2) are met.
func is_walkable_at{range_check_ptr}(grids: felt*, grids_len: felt, grid_id: felt) -> felt {
    let is_in_map = is_in_range(grid_id, 0, grids_len);
    if (is_in_map == FALSE) {
        return FALSE;
    }
    if (grids[grid_id] == X) {
        return FALSE;
    } else {
        return TRUE;
    }
}

// Check if an array of points contains a point with position (x, y).
//
// @param: points - The array of points.
// @param: lenght - The lenght of points.
// @param: x - The x position to check if exists in the array.
// @param: y - The y position to check if exists in the array.
// @return: felt - 1 if the point exists in the array, 0 otherwise.
func contains_point(points: felt*, points_lenght: felt, grid_id: felt) -> felt {
    if (points_lenght == 0) {
        return FALSE;
    }
    if ([points] == grid_id) {
        return TRUE;
    }

    return contains_point(points + 1, points_lenght - 1, grid_id);
}

// Check if two arrays has the same points.
//
// @param: points - The array of points.
// @param: points_lenght - The lenght of points.
// @param: other - The array of points to compare.
// @param: other_lenght - The lenght of other.
// @return: felt - 1 if points and other contains all points eachother, 0 otherwise.
func contains_all_points{range_check_ptr}(points: felt*, points_lenght: felt, other: felt*, other_lenght: felt) -> felt {
    if (points_lenght != other_lenght) {
        return FALSE;
    }
    return _contains_all_points(points, points_lenght, other, other_lenght);
}

func _contains_all_points{range_check_ptr}(points: felt*, points_lenght: felt, other: felt*, other_lenght: felt) -> felt {
    if (points_lenght == 0) {
        return TRUE;
    }
    let founded = contains_point(other, other_lenght, [points]); 
    if (founded == 0) {
        return FALSE;
    }

    return _contains_all_points(points + 1, points_lenght - 1, other , other_lenght);
}

// Check if an array of points contains a point with position (x, y)
// and if walkable are the same value in that point.
//
// @param: points - The array of points.
// @param: points_lenght - The lenght of points.
// @param: x - The x position to check if exists in the array.
// @param: y - The y position to check if exists in the array.
// @param: walkable - The walkable to check if exists in the array.
// @return: felt - 1 if points and other contains all points eachother and walkable values are the same, 0 otherwise.
func contains_point_equals{range_check_ptr}(points: felt*, points_lenght: felt, grid_id: felt, walkable: felt) -> felt {
    if (points_lenght == 0) {
        return FALSE;
    }
    let point_is_walkable = is_walkable_at(points, points_lenght, [points]);
    if ([points] == grid_id) {
        if (point_is_walkable == walkable) {
            return TRUE;
        } else {
            return FALSE;
        }
    }
    return contains_point_equals(points + 1, points_lenght - 1, grid_id, walkable);
}

// Check if two arrays has the same points and walkables values.
//
// @param: points - The array of points.
// @param: points_lenght - The lenght of points.
// @param: other - The array of points to compare.
// @param: other_lenght - The lenght of other.
// @return: felt - TRUE if points and other contains all points eachother, FALSE otherwise.
func contains_all_points_equals{range_check_ptr}(points: felt*, points_lenght: felt, other: felt*, other_lenght: felt) -> felt {
    if (points_lenght != other_lenght) {
        return FALSE;
    }

    return _contains_all_points_equals(points, points_lenght, other, other_lenght);
}

func _contains_all_points_equals{range_check_ptr}(points: felt*, points_lenght: felt, other: felt*, other_lenght: felt) -> felt {
    if (points_lenght == 0) {
        return TRUE;
    }

    let point_is_walkable = is_walkable_at(points, points_lenght, [points]);
    let founded = contains_point_equals(other, other_lenght, [points], point_is_walkable); 
    if (founded == 0) {
        return FALSE;
    }

    return _contains_all_points_equals(points + 1, points_lenght - 1, other , other_lenght);
}

// Returns a list with all the nodes linked by the parent attribute.
//
// @param: point - Initial node to get its parents.
// @param: width - Map width.
// @return: (felt, Point*) - The list of all nodes linked by parent attribute and length.
func build_reverse_path_from{pedersen_ptr: HashBuiltin*, range_check_ptr, point_attribute: DictAccess*, heap: DictAccess*}(point: Point, width: felt) -> (felt, Point*) {
    let res: Point* = alloc();
    assert res[0] = point;
    return _build_reverse_path_from(point, width, res, 1);
}

func _build_reverse_path_from{pedersen_ptr: HashBuiltin*, range_check_ptr, point_attribute: DictAccess*, heap: DictAccess*}(point: Point, width: felt, result: Point*, result_lenght: felt) -> (felt, Point*) {
    alloc_locals;
    let parent_id = get_point_attribute(point, PARENT);
    if (parent_id != UNDEFINED) {
        let (x, y) = convert_id_to_coords(parent_id, width);
        assert result[result_lenght] = Point(x, y, TRUE);
        return _build_reverse_path_from(Point(x, y, TRUE), width, result, result_lenght + 1);
    } else {
        return (result_lenght, result);    
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