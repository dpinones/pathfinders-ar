%lang starknet

from src.utils.point_converter import convert_id_to_coords, convert_coords_to_id

// Giving point (x, y) = (1, 2) with a map with width = 5
// when call convert_coords_to_id
// Should return the id 11
@external
func test_convert_coord_to_id_happy_path{range_check_ptr}() {
    let x = 1;
    let y = 2;
    let width = 5;

    let expected_id = 11;

    let result = convert_coords_to_id(x, y, width);
    assert result = expected_id;
    
    return();
}

// Giving point (x, y) = (0, 4) with a map with width = 5
// when call convert_coords_to_id
// Should return the id 4
@external
func test_convert_coord_to_id_x_zero_value{range_check_ptr}() {
    let x = 0;
    let y = 4;
    let width = 5;

    let expected_id = 20;

    let result = convert_coords_to_id(x, y, width);
    assert result = expected_id;
    
    return();
}

// Giving point (x, y) = (4, 0) with a map with width = 5
// when call convert_coords_to_id
// Should return the id 20
@external
func test_convert_coord_to_id_y_zero_value{range_check_ptr}() {
    let x = 4;
    let y = 0;
    let width = 5;

    let expected_id = 4;

    let result = convert_coords_to_id(x, y, width);
    assert result = expected_id;
    
    return();
}

// Giving id = 11 with a map with width = 5
// when call convert_id_to_coords
// Should return the coords (x, y) = (1, 2)
@external
func test_convert_id_to_coord_happy_path{range_check_ptr}() {
    let id = 11;    
    let width = 5;
    let expected_x = 1;
    let expected_y = 2;

    let (result_x, result_y) = convert_id_to_coords(id, width);
    assert (result_x, result_y) = (expected_x, expected_y);
    
    return();
}

// Giving id = 4 with a map with width = 5
// when call convert_id_to_coords
// Should return the coords (x, y) = (0, 4)
@external
func test_convert_id_to_coord_x_zero_value{range_check_ptr}() {
    let id = 20;    
    let width = 5;
    let expected_x = 0;
    let expected_y = 4;

    let (result_x, result_y) = convert_id_to_coords(id, width);
    assert (result_x, result_y) = (expected_x, expected_y);
    
    return();
}


// Giving id = 4 with a map with width = 5
// when call convert_id_to_coords
// Should return the coords (x, y) = (4, 0)
@external
func test_convert_id_to_coord_y_zero_value{range_check_ptr}() {
    let id = 4;    
    let width = 5;
    let expected_x = 4;
    let expected_y = 0;

    let (result_x, result_y) = convert_id_to_coords(id, width);
    assert (result_x, result_y) = (expected_x, expected_y);
    
    return();
}