%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.dict import DictAccess
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.registers import get_fp_and_pc

from src.constants.point_status import OPENED, CLOSED
from src.constants.point_attribute import PARENT, UNDEFINED
from src.utils.condition import _and, _equals
from src.utils.dictionary import read_entry, update_entry, write_entry
from src.utils.point_converter import convert_id_to_coords

struct Point {
    x: felt,
    y: felt,
    walkable: felt,
}

func get_point_attribute{pedersen_ptr: HashBuiltin*, dict_ptr: DictAccess*}(point: Point, attribute: felt) -> felt {
    let (point_hash) = hash2{hash_ptr=pedersen_ptr}(point.x, point.y);
    let (attribute_hash) = hash2{hash_ptr=pedersen_ptr}(point_hash, attribute);
    let value = read_entry{dict_ptr=dict_ptr}(attribute_hash);

    return value;
}

func set_point_attribute{pedersen_ptr: HashBuiltin*, dict_ptr: DictAccess*}(point: Point, attribute: felt, new_value: felt) {
    let (point_hash) = hash2{hash_ptr=pedersen_ptr}(point.x, point.y);
    let (attribute_hash) = hash2{hash_ptr=pedersen_ptr}(point_hash, attribute);
    let actual_value = read_entry{dict_ptr=dict_ptr}(attribute);

    if (actual_value == UNDEFINED) {
        write_entry{dict_ptr=dict_ptr}(attribute_hash, new_value);
        return ();
    } else {
        update_entry{dict_ptr=dict_ptr}(attribute_hash, actual_value, new_value);
        return ();
    }
}

// Check if an array of points contains a point with position (x, y)
//
// @param: points - The array of points
// @param: lenght - The lenght of points
// @param: x - The x position to check if exists in the array
// @param: y - The y position to check if exists in the array
// @return: felt - 1 if the point exists in the array, 0 otherwise  
func contains_point(points: Point*, points_lenght: felt, x: felt, y: felt) -> felt {
    return contains_point_internal(points, points_lenght, x, y);
}

func contains_point_internal(points: Point*, points_lenght: felt, x: felt, y: felt) -> felt {
    if (points_lenght == 0) {
        return FALSE;
    }

    if ([points].x == x and [points].y == y) {
        return TRUE;
    }

    return contains_point_internal(points + Point.SIZE, points_lenght - 1, x, y);
}

// Check if two arrays has the same points
//
// @param: points - The array of points
// @param: points_lenght - The lenght of points
// @param: other - The array of points to compare
// @param: other_lenght - The lenght of other
// @return: felt - 1 if points and other contains all points eachother, 0 otherwise
func contains_all_points(points: Point*, points_lenght: felt, other: Point*, other_lenght: felt) -> felt {
    if (points_lenght != other_lenght) {
        return FALSE;
    }

    return contains_all_points_internal(points, points_lenght, other, other_lenght);
}

func contains_all_points_internal(points: Point*, points_lenght: felt, other: Point*, other_lenght: felt) -> felt {
    if (points_lenght == 0) {
        return TRUE;
    }

    let founded = contains_point(other, other_lenght, [points].x, [points].y); 
    if (founded == 0) {
        return FALSE;
    }

    return contains_all_points_internal(points + Point.SIZE, points_lenght - 1, other , other_lenght);
}

// Check if an array of points contains a point with position (x, y)
// and if walkable are the same value in that point
//
// @param: points - The array of points
// @param: points_lenght - The lenght of points
// @param: x - The x position to check if exists in the array
// @param: y - The y position to check if exists in the array
// @param: walkable - The walkable to check if exists in the array
// @return: felt - 1 if points and other contains all points eachother and walkable values are the same, 0 otherwise
func contains_point_equals(points: Point*, points_lenght: felt, x: felt, y: felt, walkable: felt) -> felt {
    return contains_point_equals_internal(points, points_lenght, x, y, walkable);
}

func contains_point_equals_internal(points: Point*, points_lenght: felt, x: felt, y: felt, walkable: felt) -> felt {
    if (points_lenght == 0) {
        return FALSE;
    }

    if ([points].x == x and [points].y == y and [points].walkable == walkable) {
        return TRUE;
    }

    return contains_point_equals_internal(points + Point.SIZE, points_lenght - 1, x, y, walkable);
}

// Check if two arrays has the same points and walkables values
//
// @param: points - The array of points
// @param: points_lenght - The lenght of points
// @param: other - The array of points to compare
// @param: other_lenght - The lenght of other
// @return: felt - 1 if points and other contains all points eachother, 0 otherwise
func contains_all_points_equals(points: Point*, points_lenght: felt, other: Point*, other_lenght: felt) -> felt {
    if (points_lenght != other_lenght) {
        return FALSE;
    }

    return contains_all_points_equals_internal(points, points_lenght, other, other_lenght);
}

func contains_all_points_equals_internal(points: Point*, points_lenght: felt, other: Point*, other_lenght: felt) -> felt {
    if (points_lenght == 0) {
        return TRUE;
    }

    let founded = contains_point_equals(other, other_lenght, [points].x, [points].y, [points].walkable); 
    if (founded == 0) {
        return FALSE;
    }

    return contains_all_points_internal(points + Point.SIZE, points_lenght - 1, other , other_lenght);
}

func point_equals(point: Point, other: Point) -> felt {
    tempvar x_equal = _equals(point.x, other.x);
    tempvar y_equal = _equals(point.y, other.y);
    tempvar walkable_equal = _equals(point.walkable, other.walkable);
    tempvar points_are_equals = _and(x_equal, _and(y_equal, walkable_equal));

    if (points_are_equals == TRUE) {
        return TRUE;
    } else {
        return FALSE;
    }
}

func build_reverse_path_from{pedersen_ptr: HashBuiltin*, range_check_ptr, dict_ptr: DictAccess*}(point: Point, width: felt) -> (felt, Point*) {
    let res: Point* = alloc();
    assert res[0] = point;
    return build_reverse_path_from_internal(point, width, res, 1);
}

func build_reverse_path_from_internal{pedersen_ptr: HashBuiltin*, range_check_ptr, dict_ptr: DictAccess*}(point: Point, width: felt, result: Point*, result_lenght: felt) -> (felt, Point*) {
    alloc_locals;
    let parent_id = get_point_attribute(point, PARENT);
    if (parent_id != UNDEFINED) {
        let (x, y) = convert_id_to_coords(parent_id, width);
        // %{
        //     from requests import post
        //     json = { # creating the body of the post request so it's printed in the python script
        //         "Node": f"({ids.x}, {ids.y})"
        //     }
        //     post(url="http://localhost:5000", json=json) # sending the request to our small "server"
        // %}
        assert result[result_lenght] = Point(x, y, TRUE);
        return build_reverse_path_from_internal(Point(x, y, TRUE), width, result, result_lenght + 1);
    } else {
        return (result_lenght, result);    
    }
}