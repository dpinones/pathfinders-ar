%lang starknet

from src.constants.point_attribute import UNDEFINED
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.default_dict import default_dict_new, default_dict_finalize
from starkware.cairo.common.dict import dict_write, dict_read, dict_update

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
func poll{range_check_ptr, heap : DictAccess*}(heap_len: felt) -> felt {
    alloc_locals; 
    let (root) = dict_read{dict_ptr=heap}(key=0);
    let (end) = dict_read{dict_ptr=heap}(key=heap_len-1);
    dict_update{dict_ptr=heap}(key=heap_len-1, prev_value=end, new_value=-1);

    let heap_len_pos = is_le(2, heap_len);
    if (heap_len_pos == 1) {
        dict_update{dict_ptr=heap}(key=0, prev_value=root, new_value=end);
        heapifyDown(0, heap_len);
        tempvar range_check_ptr=range_check_ptr;
        tempvar heap=heap;
    } else {
        tempvar range_check_ptr=range_check_ptr;
        tempvar heap=heap;
    }
    return root;
}

// Insert new value to max heap.
// @dev Heap must be passed as an implicit argument
// @param heap_len : Length of heap
// @param val : New value to insert into heap
// @return new_len : New length of heap
func add{range_check_ptr, heap : DictAccess*}(heap_len : felt, val : felt) -> felt {
    alloc_locals;
    dict_write{dict_ptr=heap}(key=heap_len, new_value=val);
    heapifyUp(heap_len, heap_len);

    return heap_len + 1;
}

func heapifyUp{range_check_ptr, heap: DictAccess*}(idx: felt, heap_len: felt) {
    alloc_locals;
    let node_has_parent = has_parent(idx, heap_len);
    if (node_has_parent == TRUE) {
        let parent_value = parent(idx);
        let (node_value) = dict_read{dict_ptr=heap}(key=idx);
        let parent_is_greather = is_le(node_value + 1, parent_value); //nodevalue +1

        if(parent_is_greather == TRUE) {
            let parent_idx = get_parent_idx(idx);
            swap(parent_idx, idx);
            heapifyUp(parent_idx, heap_len);
        } else {
            tempvar heap = heap;
            tempvar range_check_ptr = range_check_ptr;
        }
    } else {
        tempvar heap = heap;
        tempvar range_check_ptr = range_check_ptr;
    }
    return ();
}

func heapifyDown{range_check_ptr, heap: DictAccess*}(idx: felt, heap_len: felt) {
    alloc_locals;
    let has_left_child = has_left_child(idx, heap_len); 
    if (has_left_child == FALSE) {
        return();
    }
    local smallest_child_idx = get_left_child_idx(idx);
    let has_right_child = has_right_child(idx, heap_len);
    let right_child_value = right_child(idx);
    let left_child_value = left_child(idx);
    let right_child_is_smallest = is_le(right_child_value, left_child_value + 1); // <
    
    if (right_child_is_small == TRUE) {
        smallest_child_idx = get_right_child_idx(idx);
        tempvar range_check_ptr = range_check_ptr;
        tempvar heap = heap;
    } else {
        smallest_child_idx = smallest_child_idx;
        tempvar range_check_ptr = range_check_ptr;
        tempvar heap = heap;
    }

    tempvar range_check_ptr = range_check_ptr;
    tempvar heap = heap;

    let node_value = dict_read{dict_ptr=heap}(key=idx);
    let smalles_child_value = dict_read{dict_ptr=heap}(key=smallest_child_idx);
    let node_value_is_smallest = is_le(node_value, smalles_child_value + 1); // +1 for <
    if (node_value_is_smallest == TRUE) {
        return();
    } else {
        swap(idx, smallest_child_idx);
        tempvar range_check_ptr = range_check_ptr;
        tempvar heap = heap;
    }

    heapifyDown(smallest_child_idx, heap_len); 
}

// Aux

// Swap dictionary entries at two indices.
// @dev Heap must be passed as an implicit argument
// @param idx_a : Index of first dictionary entry to be swapped
// @param idx_b : Index of second dictionary entry to be swapped
func swap{heap: DictAccess*} (idx_a : felt, idx_b : felt) {
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

func get_parent_idx(child_idx: felt) -> felt {
    return (child_idx - 1) / 2;
}

func has_left_child(idx: felt, heap_len: felt) -> felt {
    let left_child_idx = get_left_child_idx(idx);
    let has_left_child = is_le(left_child_idx, heap_len + 1); // get_right_child(idx) < heap_len
    
    return has_left_child;
}

func has_right_child(idx: felt, heap_len: felt) -> felt {
    let right_child_idx = get_right_child_idx(idx);
    let has_right_child = is_le(right_child_idx, heap_len + 1); // get_right_child(idx) < heap_len
    
    return has_right_child;
}

func has_parent(idx: felt, heap_len: felt) -> felt {
    let parent_idx = get_parent_idx(idx);
    let has_parent = is_le(0, parent_idx);

    return has_parent;
}

func left_child{heap : DictAccess*}(parent_idx: felt) -> felt {
    let left_child_idx = get_left_child_idx(parent_idx);
    let left = dict_read{dict_ptr=heap}(key=left_child_idx);

    return left;
}

func right_child{heap : DictAccess*}(parent_idx: felt) -> felt {
    let right_child_idx = get_right_child_idx(parent_idx);
    let right = dict_read{dict_ptr=heap}(key=right_child_idx);

    return right;
}

func parent{heap : DictAccess*}(child_idx: felt) -> felt { 
    let parent_idx = get_parent_idx(child_idx);
    let parent = dict_read{dict_ptr=heap}(key=parent_idx);

    return parent;
}