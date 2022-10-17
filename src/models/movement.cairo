%lang starknet

from starkware.cairo.common.math_cmp import is_in_range
from src.utils.condition import _and
from starkware.cairo.common.math import abs_value
from src.utils.condition import _max
from src.utils.point_converter import convert_id_to_coords, convert_coords_to_id

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

func get_movement_direction{range_check_ptr}(node_grid: felt, parent_grid: felt, width: felt) -> (dx: felt, dy: felt) {
    let (x, y) = convert_id_to_coords(node_grid, width);
    let (px, py) = convert_id_to_coords(parent_grid, width);

    return get_movement_direction_coords(x, y, px, py);
}

func get_movement_direction_coords{range_check_ptr}(x: felt, y: felt, px: felt, py: felt) -> (dx: felt, dy: felt) {
    alloc_locals;
    tempvar pre_dx = x - px;
    tempvar abs_value_x_minus_px = abs_value(pre_dx);
    tempvar max_between_x_minus_px_and_one = _max(abs_value_x_minus_px, 1);
    tempvar dx = pre_dx / max_between_x_minus_px_and_one;

    tempvar pre_dy = y - py;
    tempvar abs_value_y_minus_py = abs_value(pre_dy);
    tempvar max_between_y_minus_py_and_one = _max(abs_value_y_minus_py, 1);
    tempvar dy = pre_dy / max_between_y_minus_py_and_one;

    return (dx = dx, dy = dy);
}