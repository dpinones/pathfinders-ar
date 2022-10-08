%lang starknet

from src.utils.point_converter import convert_id_to_coords, convert_coords_to_id

@external
func test_convert_coord_to_id_happy_path{range_check_ptr}() {
    let tryx = 1;
    let tryy = 2;
    let width = 5;
    let expected = 11;

    let actual = convert_coords_to_id(tryx, tryy, width);
    assert actual = expected;
    let (x, y) = convert_id_to_coords(actual, width);
    assert (x, y) = (tryx, tryy);

    let tryx = 3;
    let tryy = 1;
    let expected = 8;
    let actual = convert_coords_to_id(tryx, tryy, width);
    assert actual = expected;
    let (x, y) = convert_id_to_coords(actual, width);
    assert (x, y) = (tryx, tryy);

    let tryx = 1;
    let tryy = 3;
    let expected = 16;
    let actual = convert_coords_to_id(tryx, tryy, width);
    assert actual = expected;
    let (x, y) = convert_id_to_coords(actual, width);
    assert (x, y) = (tryx, tryy);

    return();
}