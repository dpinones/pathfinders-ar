%lang starknet

from src.utils.min_heap_custom import heap_create, poll, add
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.dict import dict_write, dict_read, dict_update

@external
func test_min_heap_custom{range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;
    let (heap: DictAccess*, heap_len) = heap_create();
    let new_len = add{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, heap=heap}(heap_len, 0, 5);
    let new_len = add{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, heap=heap}(new_len, 1, 7);
    let new_len = add{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, heap=heap}(new_len, 2, 4);
    let new_len = add{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, heap=heap}(new_len, 3, 12);
    let new_len = add{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, heap=heap}(new_len, 4, 1);
    assert new_len = 5;

    let (grid, val, new_len) = poll{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, heap=heap}(new_len);
    assert val = 1;
    assert grid = 4;
    assert new_len = 4;
    
    let (grid, val, new_len) = poll{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, heap=heap}(new_len);
    assert val = 4;
    assert grid = 2;
    assert new_len = 3;

    let (grid, val, new_len) = poll{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, heap=heap}(new_len);
    assert val = 5;
    assert grid = 0;
    assert new_len = 2;
    
    let (grid, val, new_len) = poll{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, heap=heap}(new_len);
    assert val = 7;
    assert grid = 1;
    assert new_len = 1;
    
    let (grid, val, new_len) = poll{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, heap=heap}(new_len);
    assert val = 12;
    assert grid = 3;
    assert new_len = 0;
    
    let (grid, val, new_len) = poll{range_check_ptr=range_check_ptr, pedersen_ptr=pedersen_ptr, heap=heap}(new_len);
    assert val = -1;
    assert grid = -1;
    assert new_len = 0;
    return();
}

