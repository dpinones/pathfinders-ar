%lang starknet

from starkware.cairo.common.math import unsigned_div_rem

func convert_id_to_coords{range_check_ptr}(position: felt, grid_dimension: felt) -> (row: felt, col: felt) {
    let (row, col) = unsigned_div_rem(position, grid_dimension);
    return (col, row);
}

func convert_coords_to_id{range_check_ptr}(x: felt, y: felt, grid_width: felt) -> felt {
    tempvar multiple = y * grid_width;
    return y * grid_width + x;
}