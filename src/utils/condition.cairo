%lang starknet
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.bool import TRUE, FALSE

func _or(x, y) -> felt {
    if ((x - 1) * (y - 1) == 0){
        return TRUE;
    }
    return FALSE;
}

func _and(x, y) -> felt {
    if (x * y == 1){
        return TRUE;
    }
    return FALSE;
}

func _not(x) -> felt {
    if (x == 0){
        return TRUE;
    }
    return FALSE;
}

func _abs{range_check_ptr}(x) -> felt {
    if (is_le(x, -1) == 1) {
        return x * -1;
    }
    return x;
}

func _equals(value: felt, other: felt) -> felt {
    if (value == other) {
        return TRUE;
    } else {
        return FALSE;
    }
}

func _max{range_check_ptr}(value: felt, other: felt) -> felt {
    let value_is_le = is_le(value, other);
    if (value_is_le == TRUE) {
        return other;
    } else {
        return value;
    }
}