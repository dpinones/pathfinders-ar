// Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from src.models.point import Point
from src.models.map import Map
from src.utils.map_factory import generate_map_static
from src.utils.dictionary import create_dict
from src.models.point_status import OPENED, CLOSED
from src.models.point_attribute import UNDEFINED
from src.jps import jump, find_path
from starkware.cairo.common.dict import DictAccess


@view
func path_finder{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(start_x: felt, start_y: felt, end_x: felt, end_y: felt, grids_len: felt, grids: felt*, width: felt, height: felt) -> (
    points_len: felt, points: Point*
) {
    alloc_locals;
    let map = generate_map_static(grids, width, height);
    let dict_ptr: DictAccess* = create_dict(UNDEFINED); 
    let (result_after_lenght: felt, result_after: Point*) = find_path{pedersen_ptr=pedersen_ptr, range_check_ptr=range_check_ptr, dict_ptr=dict_ptr}(start_x, start_y, end_x, end_y, map);
    return (result_after_lenght, result_after,);
}

