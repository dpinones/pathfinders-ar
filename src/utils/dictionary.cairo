%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.default_dict import default_dict_new, default_dict_finalize
from starkware.cairo.common.dict import dict_write, dict_read, dict_update
from starkware.cairo.common.dict_access import DictAccess

from src.constants.point_attribute import UNDEFINED

// Credits to: @parketh for the original implementation.

// Returns the value for the specified key in a dictionary.
func create_attribute_dict{range_check_ptr}() -> DictAccess* {
    alloc_locals;
    // First create an empty dictionary and finalize it.
    // All keys will be set to value of initial_value.
    let (local dict) = default_dict_new(default_value=UNDEFINED);

    // Finalize the dictionary. This ensures default value is correct.
    default_dict_finalize(
        dict_accesses_start=dict, dict_accesses_end=dict, default_value=UNDEFINED
    );

    return dict;
}

// Recursively populates the dictionary with specified key-value pairs.
func add_entries{dict_ptr: DictAccess*}(keys: felt*, values: felt*, len: felt) {
    if (len == 0) {
        return ();
    } else {
        dict_write(key=keys[0], new_value=values[0]);
        add_entries(keys + 1, values + 1, len - 1);
        return ();
    }
}

// Reads entry from dictionary
func read_entry{dict_ptr: DictAccess*}(key: felt) -> felt {
    let (val) = dict_read(key=key);
    return val;
}

// Updates dictionary entry
func update_entry{dict_ptr: DictAccess*}(key, prev_value, new_value) {
    dict_update(key=key, prev_value=prev_value, new_value=new_value);
    return ();
}

// Write dictionary entry
func write_entry{dict_ptr: DictAccess*}(key, new_value) {
    dict_write(key=key, new_value=new_value);
    return ();
}