%lang starknet

from starkware.cairo.common.math_cmp import is_in_range
from src.utils.condition import _and

// Diagonal movements is represented as:
// horizotal = {-1, 0, 1}
// vertical = {-1, 0, 1}
struct Movement {
    horizontal: felt,
    vertical: felt,
}

func get_movement_type{range_check_ptr}(movement: Movement) -> felt {
    let is_valid_dx = is_in_range(movement.horizontal, -1, 2);
    let is_valid_dy = is_in_range(movement.vertical, -1, 2);
    let is_valid_movement = _and(is_valid_dx, is_valid_dy);
    
    with_attr error_message("Cannot identify movement type") {
        assert is_valid_movement = 1;
    }

    if (movement.horizontal != 0 and movement.vertical != 0) {
        return 'diagonal';
    }
    if (movement.horizontal != 0) {
        return 'horizontal';
    }
    if (movement.vertical != 0) {
        return 'vertical';
    }
    
    with_attr error_message("Cannot identify movement type") {
        assert 1 = 0;
    }
    return 'none';
}