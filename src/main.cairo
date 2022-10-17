// Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from src.models.point import Point
from src.models.map import Map
from src.utils.map_factory import generate_map
from src.utils.dictionary import create_attribute_dict
from src.utils.min_heap_custom import heap_create
from src.constants.point_status import OPENED, CLOSED
from src.constants.point_attribute import UNDEFINED
from src.jps import jump, find_path
from starkware.cairo.common.dict import DictAccess

@view
func path_finder{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(start_x: felt, start_y: felt, end_x: felt, end_y: felt, grids_len: felt, grids: felt*, width: felt, height: felt) -> (
    points_len: felt, points: Point*
) {
    alloc_locals;
    let map = generate_map(grids, width, height);
    let point_attribute: DictAccess* = create_attribute_dict(); 
    let heap: DictAccess* = heap_create(); 
    let (result_after_lenght: felt, result_after: Point*) = find_path{pedersen_ptr=pedersen_ptr, range_check_ptr=range_check_ptr, point_attribute=point_attribute, heap=heap}(start_x, start_y, end_x, end_y, map);
    return (result_after_lenght, result_after,);
}

