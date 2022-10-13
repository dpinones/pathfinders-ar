%lang starknet

from src.utils.min_heap import heap_create, poll, add
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.dict import dict_write, dict_read, dict_update

@external
func test_min_heap{range_check_ptr}() {
    alloc_locals;
    let (heap: DictAccess*, heap_len) = heap_create();
    let new_len = add{range_check_ptr=range_check_ptr, heap=heap}(heap_len, 5);
    let new_len = add{range_check_ptr=range_check_ptr, heap=heap}(new_len, 7);
    let new_len = add{range_check_ptr=range_check_ptr, heap=heap}(new_len, 4);
    let new_len = add{range_check_ptr=range_check_ptr, heap=heap}(new_len, 12);
    let new_len = add{range_check_ptr=range_check_ptr, heap=heap}(new_len, 1);
    assert new_len = 5;

    let (val, new_len) = poll{range_check_ptr=range_check_ptr, heap=heap}(new_len);
    assert val = 1;
    assert new_len = 4;
    
    let (val, new_len) = poll{range_check_ptr=range_check_ptr, heap=heap}(new_len);
    assert val = 4;
    assert new_len = 3;

    let (val, new_len) = poll{range_check_ptr=range_check_ptr, heap=heap}(new_len);
    assert val = 5;
    assert new_len = 2;

    let (val, new_len) = poll{range_check_ptr=range_check_ptr, heap=heap}(new_len);
    assert val = 7;
    assert new_len = 1;

    let (val, new_len) = poll{range_check_ptr=range_check_ptr, heap=heap}(new_len);
    assert val = 12;
    assert new_len = 0;

    let (val, new_len) = poll{range_check_ptr=range_check_ptr, heap=heap}(new_len);
    assert val = -1;
    assert new_len = 0;
    return();
}

