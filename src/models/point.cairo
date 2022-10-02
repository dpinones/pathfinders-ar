%lang starknet

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
    if (0 == points_lenght) {
        return 0;
    }

    if ([points].x == x and [points].y == y) {
        return 1;
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
        return 0;
    }

    return contains_all_points_internal(points, points_lenght, other, other_lenght);
}

func contains_all_points_internal(points: Point*, points_lenght: felt, other: Point*, other_lenght: felt) -> felt {
    if (0 == other_lenght ) {
        return 1;
    }

    let not_found_flag = contains_point(points, points_lenght, [points].x, [points].y); 
    if (not_found_flag == 0) {
        return 0;
    }

    return contains_all_points_internal(points, points_lenght, other + Point.SIZE, other_lenght - 1);
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
    if (0 == points_lenght) {
        return 0;
    }

    if ([points].x == x and [points].y == y and [points].walkable == walkable) {
        return 1;
    }

    return contains_point_equals_internal(points + Point.SIZE, points_lenght - 1, x, y, walkable);
}
