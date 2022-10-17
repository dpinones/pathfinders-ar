%lang starknet
from starkware.cairo.common.bool import TRUE, FALSE

func contains(array: felt*, array_len: felt, value: felt) -> felt {
    if (array_len == 0) {
        return FALSE;
    }

    if ([array] == value) {
        return TRUE;
    }

    return contains(array + 1, array_len - 1, value);
}


// First array contains all items of the other one
func contains_all(array: felt*, array_len: felt, other: felt*, other_len: felt) -> felt {
    if (array_len != other_len) {
        return FALSE;
    }

    return _contains_all(array, array_len, other, other_len);
}

func _contains_all(array: felt*, array_len: felt, other: felt*, other_len: felt) -> felt {
    if (array_len == 0) {
        return TRUE;
    }
    let founded_item = contains(other, other_len, [array]);
    if (founded_item == FALSE) {
        return FALSE;
    }
    return _contains_all(array + 1, array_len - 1, other, other_len);
}

func array_equals(array: felt*, array_len: felt, other: felt*, other_len: felt) -> felt {
    alloc_locals;
    let array_contains_other = contains_all(array, array_len, other, other_len);
    let other_contains_array = contains_all(other, other_len, array, array_len);

    if (array_contains_other == TRUE and other_contains_array == TRUE) {
        return TRUE;
    }

    return FALSE;
}

