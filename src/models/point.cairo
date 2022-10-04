%lang starknet
from starkware.cairo.common.bool import TRUE, FALSE

struct Point {
    x: felt,
    y: felt,
    walkable: felt,
}

struct PointWithParent {
    x: felt,
    y: felt,
    walkable: felt,
    parent: Point*,
    status: felt,
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

func point_equals(point: Point, other: Point) -> felt{
    if (point.x == other.x and point.y == other.y and point.walkable == other.walkable) {
        return TRUE;
    }
    return FALSE;
}