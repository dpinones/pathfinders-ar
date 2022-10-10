%lang starknet

from src.utils.min_heap import heap_create, poll, add
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.dict_access import DictAccess

@external
func test_min_heap{range_check_ptr}() {
    let (heap: DictAccess*, heap_len) = heap_create();
    return();
}