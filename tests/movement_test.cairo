%lang starknet
from src.models.movement import Movement, get_movement_type

@external
func test_get_movement_type{range_check_ptr}() {
    let result_after = get_movement_type(Movement(0, -1));
    assert result_after = 'vertical';

    let result_after = get_movement_type(Movement(0, 1));
    assert result_after = 'vertical';

    let result_after = get_movement_type(Movement(1, 0));
    assert result_after = 'horizontal';

    let result_after = get_movement_type(Movement(-1, 0));
    assert result_after = 'horizontal';

    let result_after = get_movement_type(Movement(1, 1));
    assert result_after = 'diagonal';

    let result_after = get_movement_type(Movement(-1, 1));
    assert result_after = 'diagonal';

    let result_after = get_movement_type(Movement(1, -1));
    assert result_after = 'diagonal';

    let result_after = get_movement_type(Movement(-1, -1));
    assert result_after = 'diagonal';

    return ();
}
