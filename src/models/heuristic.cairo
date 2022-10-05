%lang starknet
from starkware.cairo.common.math import sqrt
from starkware.cairo.common.math_cmp import is_le

func octile{range_check_ptr}(distance_x, distance_y) -> felt {
    let SQRT2 = sqrt(2);
    if (is_le(distance_x, distance_y + 1) == 1) {
        return (SQRT2 - 1) * distance_x + distance_y;
    } else {
        return (SQRT2 - 1) * distance_y + distance_x;
    }
}