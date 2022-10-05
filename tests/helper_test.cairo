%lang starknet
from starkware.cairo.common.default_dict import default_dict_new, default_dict_finalize
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.dict import dict_write, dict_update, dict_read, DictAccess
from starkware.cairo.common.alloc import alloc

from starkware.cairo.common.registers import get_fp_and_pc

from src.models.point_status import OPENED, CLOSED, UNDEFINED
from src.models.point import Point
from src.utils.dictionary import add_entries, create_dict, read_entry, update_entry, write_entry
from src.utils.map_factory import generate_map_without_obstacles


@external 
func test_otro{syscall_ptr: felt*, range_check_ptr}() {
    alloc_locals;
    let (__fp__, _) = get_fp_and_pc();
    local point: Point = Point(2, 1, TRUE);
    local mem_pos_direction = cast(new (&point), felt);

    let keys: felt* = alloc();
    let values: felt* = alloc();

    let dict_ptr: DictAccess* = create_dict(UNDEFINED);

    let value = read_entry{dict_ptr=dict_ptr}(mem_pos_direction);
    assert value = UNDEFINED;

    write_entry{dict_ptr=dict_ptr}(mem_pos_direction, OPENED);
    let value = read_entry{dict_ptr=dict_ptr}(mem_pos_direction);
    assert value = OPENED;

    write_entry{dict_ptr=dict_ptr}(mem_pos_direction, CLOSED);
    let value = read_entry{dict_ptr=dict_ptr}(mem_pos_direction);
    assert value = CLOSED;

    return();
}
