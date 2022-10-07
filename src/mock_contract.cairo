%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.dict import DictAccess
from starkware.cairo.common.bool import TRUE, FALSE

from src.models.point import Point
from src.utils.map_factory import generate_map
from src.utils.dictionary import create_dict
from src.constants.point_status import OPENED, CLOSED
from src.constants.point_attribute import UNDEFINED
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
    // Mapa de 10x10
    tempvar points: felt* = cast(new(0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,
                                     0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,
                                     0,0,0,0,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,
                                     0,0,0,0,1,0,1,0,0,0,0,1,1,1,0,0,1,1,1,1,
                                     0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,
                                     0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                     0,0,0,0,1,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,
                                     0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,
                                     0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,
                                     0,0,1,1,1,0,0,0,0,1,0,0,1,1,1,1,1,1,1,1,
                                     0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,
                                     0,0,0,1,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,
                                     0,0,0,1,1,0,0,0,0,1,0,0,1,1,0,0,1,1,0,0,
                                     0,0,0,1,1,0,0,0,0,1,0,0,1,1,0,1,0,0,0,0,
                                     0,0,0,1,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,
                                     0,0,0,1,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,
                                     0,0,0,1,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,
                                     0,0,0,1,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,
                                     0,0,0,1,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,
                                     0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0),  felt*);

     let map = generate_map(points, 20, 20); 
     let dict_ptr: DictAccess* = create_dict(UNDEFINED);
    
    let start_x = 1;
    let start_y = 2;
    let end_x = 16;
    let end_y = 16;
    let (result_after_lenght: felt, result_after: Point*) = find_path{pedersen_ptr=pedersen_ptr, range_check_ptr=range_check_ptr, dict_ptr=dict_ptr}(start_x, start_y, end_x, end_y, map);
    
    // print_point_array(result_after, result_after_lenght, 0);
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

