%lang starknet
from starkware.cairo.common.math_cmp import is_le

func _or(x, y) -> felt {
    if ((x - 1) * (y - 1) == 0){
        return 1;
    }
    return 0;
}

func _and(x, y) -> felt {
    if (x * y == 1){
        return 1;
    }
    return 0;
}

func _not(x) -> felt {
    if (x == 0){
        return 1;
    }
    return 0;
}

func _abs{range_check_ptr}(x) -> felt {
    if (is_le(x, -1) == 1) {
        return x * -1;
    }
    return x;
}
