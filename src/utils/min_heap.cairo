%lang starknet

from src.constants.point_attribute import UNDEFINED
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.math import unsigned_div_rem
from src.utils.condition import _and
from src.utils.comparator import is_greather_strict, is_greather_equal, is_less_strict 
from starkware.cairo.common.default_dict import default_dict_new, default_dict_finalize
from starkware.cairo.common.dict import dict_write, dict_read, dict_update

// Credits: Based on @parketh max heap implementation (cairo-ds)

// Create an empty binary heap.
// @dev Empty dict entries are initialised at -1.
// @return heap : Pointer to empty dictionary containing heap
// @return heap_len : Length of heap
func heap_create{range_check_ptr}() -> (heap : DictAccess*, heap_len : felt) {
    alloc_locals;
    let (local heap) = default_dict_new(default_value=UNDEFINED);
    default_dict_finalize(dict_accesses_start=heap, dict_accesses_end=heap, default_value=UNDEFINED);

    return (heap, 0);
}

// Delete root value from max heap.
// @dev Heap must be passed as an implicit argument
// @dev tempvars used to handle revoked references for implicit args
// @param heap_len : Length of heap
// @return root : Root value deleted from tree
func poll{range_check_ptr, heap : DictAccess*}(heap_len: felt) -> (felt, felt) {
    alloc_locals; 
    if (heap_len == 0) {
        return (-1, 0);
    } 
    let (root) = dict_read{dict_ptr=heap}(key=0);
    let (end) = dict_read{dict_ptr=heap}(key=heap_len - 1);
    dict_update{dict_ptr=heap}(key=heap_len - 1, prev_value=end, new_value= - 1);
    
    let heap_len_pos = is_le(2, heap_len);
    if (heap_len_pos == 1) {
        dict_update{dict_ptr=heap}(key=0, prev_value=root, new_value=end);
        heapifyDown(0, heap_len - 1);
        tempvar range_check_ptr=range_check_ptr;
        tempvar heap=heap;
    } else {
        tempvar range_check_ptr=range_check_ptr;
        tempvar heap=heap;
    }
    return (root, heap_len - 1);
}


// Insert new value to max heap.
// @dev Heap must be passed as an implicit argument
// @param heap_len : Length of heap
// @param val : New value to insert into heap
// @return new_len : New length of heap
func add{range_check_ptr, heap: DictAccess*}(heap_len: felt, val: felt) -> felt {
    alloc_locals;
    dict_write{dict_ptr=heap}(key=heap_len, new_value=val);
    heapifyUp(heap_len, heap_len);
    return heap_len + 1;
}

func heapifyUp{range_check_ptr, heap: DictAccess*}(idx: felt, heap_len: felt) {
    alloc_locals;

    if (idx == 0) {
        return ();
    }

    let (parent_idx, _) = unsigned_div_rem(idx - 1, 2);
    let (node_value) = dict_read{dict_ptr=heap}(key=idx);
    let (parent_value) = dict_read{dict_ptr=heap}(key=parent_idx);
    let parent_is_greather = is_greather_strict(parent_value, node_value);
    
    if (parent_is_greather == FALSE) {
        return();
    }

    dict_update{dict_ptr=heap}(key=idx, prev_value=node_value, new_value=parent_value);
    dict_update{dict_ptr=heap}(key=parent_idx, prev_value=parent_value, new_value=node_value);

    return heapifyUp(parent_idx, heap_len);
}

func heapifyDown{range_check_ptr, heap: DictAccess*}(idx: felt, heap_len: felt) {
    alloc_locals;
    let (node_value) = dict_read{dict_ptr=heap}(key=idx);
    let node_has_left_child = has_left_child(idx, heap_len); 
    if (node_has_left_child == FALSE) {
        return();
    }
    let smallest_child_idx = get_smallest_child_idx(idx, heap_len);

    tempvar range_check_ptr = range_check_ptr;
    tempvar heap = heap;

    let (node_value) = dict_read{dict_ptr=heap}(key=idx);
    let (smallest_child_value) = dict_read{dict_ptr=heap}(key=smallest_child_idx);
    let node_value_is_smallest = is_less_strict(node_value, smallest_child_value); // +1 for <
    
    if (node_value_is_smallest == TRUE) {
        return();
    } else {
        swap(idx, smallest_child_idx);
        tempvar range_check_ptr = range_check_ptr;
        tempvar heap = heap;
    }

    return heapifyDown(smallest_child_idx, heap_len); 
}

func get_smallest_child_idx{range_check_ptr, heap: DictAccess*}(idx: felt, heap_len: felt) -> felt {
    alloc_locals;
    let left_child_idx = get_left_child_idx(idx);
    let left_child_value = left_child(idx);

    let node_has_right_child = has_right_child(idx, heap_len);
    let right_child_value = right_child(idx);
    let right_child_is_smallest = is_less_strict(right_child_value, left_child_value); // <
    
    let has_right_child_and_is_small = _and(node_has_right_child, right_child_is_smallest);
    if (has_right_child_and_is_small == TRUE) {
        let right_child_idx = get_right_child_idx(idx);
        return right_child_idx;
    } else {
        return left_child_idx;
    }
}


// Aux

// Swap dictionary entries at two indices.
// @dev Heap must be passed as an implicit argument
// @param idx_a : Index of first dictionary entry to be swapped
// @param idx_b : Index of second dictionary entry to be swapped
func swap{range_check_ptr, heap: DictAccess*} (idx_a : felt, idx_b : felt) {
    let (elem_a) = dict_read{dict_ptr=heap}(key=idx_a);
    let (elem_b) = dict_read{dict_ptr=heap}(key=idx_b);
    dict_update{dict_ptr=heap}(key=idx_a, prev_value=elem_a, new_value=elem_b);
    dict_update{dict_ptr=heap}(key=idx_b, prev_value=elem_b, new_value=elem_a);
    return ();
}

func get_left_child_idx(parent_idx: felt) -> felt {
    return 2 * parent_idx + 1;
}

func get_right_child_idx(parent_idx: felt) -> felt {
    return 2 * parent_idx + 2;
}

func get_parent_idx{range_check_ptr}(child_idx: felt) -> felt {
    if (child_idx == 0) {
        return 0;
    }
    let (parent_idx, _) = unsigned_div_rem(child_idx - 1, 2);
    return parent_idx;
}

func has_left_child{range_check_ptr}(idx: felt, heap_len: felt) -> felt {
    let left_child_idx = get_left_child_idx(idx);
    let has_left_child = is_less_strict(left_child_idx, heap_len); // get_right_child(idx) < heap_len
    
    return has_left_child;
}

func has_right_child{range_check_ptr}(idx: felt, heap_len: felt) -> felt {
    let right_child_idx = get_right_child_idx(idx);
    let has_right_child = is_less_strict(right_child_idx, heap_len); // get_right_child(idx) < heap_len
    
    return has_right_child;
}

func has_parent{range_check_ptr}(idx: felt, heap_len: felt) -> felt {
    let parent_idx = get_parent_idx(idx);
    let has_parent = is_greather_equal(parent_idx, 0);

    return has_parent;
}

func left_child{heap : DictAccess*}(parent_idx: felt) -> felt {
    let left_child_idx = get_left_child_idx(parent_idx);
    let (left_child) = dict_read{dict_ptr=heap}(key=left_child_idx);

    return left_child;
}

func right_child{heap : DictAccess*}(parent_idx: felt) -> felt {
    let right_child_idx = get_right_child_idx(parent_idx);
    let (right_child) = dict_read{dict_ptr=heap}(key=right_child_idx);

    return right_child;
}

func parent{range_check_ptr, heap : DictAccess*}(child_idx: felt) -> felt { 
    let parent_idx = get_parent_idx(child_idx);
    let (parent) = dict_read{dict_ptr=heap}(key=parent_idx);

    return parent;
}