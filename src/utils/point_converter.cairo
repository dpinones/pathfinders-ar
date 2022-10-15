%lang starknet

from starkware.cairo.common.math import unsigned_div_rem

func convert_id_to_coords{range_check_ptr}(position: felt, grid_dimension: felt) -> (felt, felt) {
    let (y, x) = unsigned_div_rem(position, grid_dimension);
    return (x, y);
}

func convert_coords_to_id{range_check_ptr}(x: felt, y: felt, grid_width: felt) -> felt {
    return y * grid_width + x;
}