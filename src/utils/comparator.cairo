%lang starknet

from starkware.cairo.common.math_cmp import is_le

// a > b
func is_greather_strict{range_check_ptr}(a: felt, b: felt) -> felt {
    return is_le(b + 1 , a);
}

// a >= b
func is_greather_equal{range_check_ptr}(a: felt, b: felt) -> felt {
    return is_le(b, a);
}

// a < b
func is_less_strict{range_check_ptr}(a: felt, b: felt) -> felt {
    return is_le(a + 1, b);
}