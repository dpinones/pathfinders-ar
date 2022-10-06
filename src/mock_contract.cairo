%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.dict import DictAccess
from starkware.cairo.common.bool import TRUE, FALSE

from src.models.point import Point
from src.utils.map_factory import generate_map_with_obstacles, generate_map_without_obstacles
from src.utils.dictionary import create_dict
from src.models.point_status import OPENED, CLOSED
from src.models.point_attribute import UNDEFINED
from src.jps import jump, find_path

// Map width = 8, height = 8
//   0 1 2 3 4 5 6 7 
// 0 S O O O O O O O 
// 1 O X O X O O O O 
// 2 O O O O X X O O 
// 3 O O O O X O X O 
// 4 O O O O X O O O 
// 5 O O O O X O O O 
// 6 O O O O X O O O 
// 7 O O O O O O O G
@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    arr_len: felt, arr: felt*
) {
    alloc_locals;
    let obstacles: Point* = alloc();
    let obstacles_len = 94;
    assert obstacles[0] = Point(3, 0,  FALSE);
    assert obstacles[1] = Point(3, 1,  FALSE);
    assert obstacles[2] = Point(4, 2,  FALSE);
    assert obstacles[3] = Point(5, 2, FALSE);
    assert obstacles[4] = Point(11, 2, FALSE);
    assert obstacles[5] = Point(12, 2, FALSE);
    assert obstacles[6] = Point(13, 2, FALSE);
    assert obstacles[7] = Point(14, 2, FALSE);
    assert obstacles[8] = Point(15, 2, FALSE);
    assert obstacles[9] = Point(16, 2, FALSE);
    assert obstacles[10] = Point(17, 2, FALSE);
    assert obstacles[11] = Point(18, 2, FALSE);
    assert obstacles[12] = Point(19, 2, FALSE);
    assert obstacles[13] = Point(14, 1, FALSE);
    assert obstacles[14] = Point(15, 1, FALSE);
    assert obstacles[15] = Point(16, 1, FALSE);
    assert obstacles[16] = Point(17, 1, FALSE);
    assert obstacles[17] = Point(18, 1, FALSE);
    assert obstacles[18] = Point(19, 1, FALSE);
    assert obstacles[19] = Point(16, 0, FALSE);
    assert obstacles[20] = Point(17, 0, FALSE);
    assert obstacles[21] = Point(18, 0, FALSE);
    assert obstacles[22] = Point(19, 0, FALSE);
    assert obstacles[23] = Point(4, 3, FALSE);
    assert obstacles[24] = Point(6, 3, FALSE);
    assert obstacles[25] = Point(11, 3, FALSE);
    assert obstacles[26] = Point(12,  3, FALSE);
    assert obstacles[27] = Point(13, 3, FALSE);
    assert obstacles[28] = Point(16, 3, FALSE);
    assert obstacles[29] = Point(17, 3, FALSE);
    assert obstacles[30] = Point(18, 3, FALSE);
    assert obstacles[31] = Point(19, 3, FALSE);
    assert obstacles[32] = Point(4, 4, FALSE);
    assert obstacles[33] = Point(16, 4, FALSE);
    assert obstacles[34] = Point(17, 4, FALSE);
    assert obstacles[35] = Point(18, 4, FALSE);
    assert obstacles[36] = Point(19, 4, FALSE);
    assert obstacles[37] = Point(4, 5, FALSE);
    assert obstacles[38] = Point(4, 6, FALSE);
    assert obstacles[39] = Point(13, 6, FALSE);
    assert obstacles[40] = Point(14, 6, FALSE);
    assert obstacles[41] = Point(15, 6, FALSE);
    assert obstacles[42] = Point(8, 7, FALSE);
    assert obstacles[43] = Point(9, 7, FALSE);
    assert obstacles[44] = Point(10, 7, FALSE);
    assert obstacles[45] = Point(7, 8, FALSE);
    assert obstacles[46] = Point(11, 8, FALSE);
    assert obstacles[47] = Point(2, 9, FALSE);
    assert obstacles[48] = Point(3, 9, FALSE);
    assert obstacles[49] = Point(4, 9, FALSE);
    assert obstacles[50] = Point(9, 9, FALSE);
    assert obstacles[51] = Point(12, 9, FALSE);
    assert obstacles[52] = Point(13, 9, FALSE);
    assert obstacles[53] = Point(14, 9, FALSE);
    assert obstacles[54] = Point(15, 9, FALSE);
    assert obstacles[55] = Point(16, 9, FALSE);
    assert obstacles[56] = Point(17, 9, FALSE);
    assert obstacles[57] = Point(18, 9, FALSE);
    assert obstacles[58] = Point(19, 9, FALSE);
    assert obstacles[59] = Point(3, 10, FALSE);
    assert obstacles[60] = Point(9, 10, FALSE);
    assert obstacles[61] = Point(3, 11, FALSE);
    assert obstacles[62] = Point(4, 11, FALSE);
    assert obstacles[63] = Point(9, 11, FALSE);
    assert obstacles[64] = Point(3, 12, FALSE);
    assert obstacles[65] = Point(4, 12, FALSE);
    assert obstacles[66] = Point(9, 12, FALSE);
    assert obstacles[67] = Point(12, 12, FALSE);
    assert obstacles[68] = Point(13, 12, FALSE);
    assert obstacles[69] = Point(16, 12, FALSE);
    assert obstacles[70] = Point(17, 12, FALSE);
    assert obstacles[71] = Point(3, 13, FALSE);
    assert obstacles[72] = Point(4, 13, FALSE);
    assert obstacles[73] = Point(9, 13, FALSE);
    assert obstacles[74] = Point(12, 13, FALSE);
    assert obstacles[75] = Point(13, 13, FALSE);
    assert obstacles[76] = Point(15, 13, FALSE);
    assert obstacles[77] = Point(3, 14, FALSE);
    assert obstacles[78] = Point(4, 14, FALSE);
    assert obstacles[79] = Point(9, 14, FALSE);
    assert obstacles[80] = Point(14, 14, FALSE);
    assert obstacles[81] = Point(3, 15, FALSE);
    assert obstacles[82] = Point(4, 15, FALSE);
    assert obstacles[83] = Point(9, 15, FALSE);
    assert obstacles[84] = Point(3, 16, FALSE);
    assert obstacles[85] = Point(4, 16, FALSE);
    assert obstacles[86] = Point(9, 16, FALSE);
    assert obstacles[87] = Point(3, 17, FALSE);
    assert obstacles[88] = Point(4, 17, FALSE);
    assert obstacles[89] = Point(9, 17, FALSE);
    assert obstacles[90] = Point(3, 18, FALSE);
    assert obstacles[91] = Point(4, 18, FALSE);
    assert obstacles[92] = Point(9, 18, FALSE);
    assert obstacles[93] = Point(9, 19, FALSE);

    let map = generate_map_with_obstacles(20, 20, obstacles, obstacles_len); 
    let dict_ptr: DictAccess* = create_dict(UNDEFINED);
    
    let start_x = 1;
    let start_y = 2;
    let end_x = 16;
    let end_y = 16;
    let (result_after_lenght: felt, result_after: Point*) = find_path{pedersen_ptr=pedersen_ptr, range_check_ptr=range_check_ptr, dict_ptr=dict_ptr}(start_x, start_y, end_x, end_y, map);
    
    print_point_array(result_after, result_after_lenght, 0);
    // let result_after: Point = jump(2, 3, 1, 4, map, Point(-1, -1, -1));
    // assert result_after = Point(4, 1, TRUE);

    return ();
}

@view
func product_mapping{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> () {
    return ();
}

func print_point_array(array: Point*, array_len: felt, index: felt) {
    if (array_len == 0) {
        return ();
    }
    let node = [array];
    %{
        from requests import post
        json = { # creating the body of the post request so it's printed in the python script
            "1": f"node index:  {ids.index} ({ids.node.x}, {ids.node.y}) "
        }
        post(url="http://localhost:5000", json=json) # sending the request to our small "server"
    %}

    return print_point_array(array + Point.SIZE, array_len - 1, index + 1);
}