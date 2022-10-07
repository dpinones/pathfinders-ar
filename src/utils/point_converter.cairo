%lang starknet

from starkware.cairo.common.math import unsigned_div_rem

func convert_coords_to_id(x: felt, y: felt, width: felt) -> felt {
    return y * width + x;
}

func convert_id_to_coords{range_check_ptr}(id: felt, width: felt) -> (x: felt, y: felt) {
    let (y, x) = unsigned_div_rem(id, width);
    return (x, y);
}
