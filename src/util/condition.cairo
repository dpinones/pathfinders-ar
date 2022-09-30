%lang starknet

func _or(x, y) -> felt {
    if ((x - 1) * (y - 1) == 0){
        return 1;
    }
    return 0;
}

func _and(x, y) -> felt {
    if (x * y == 1){
        return 1;
    }
    return 0;
}

func _not(x) -> felt {
    if (x == 0){
        return 1;
    }
    return 0;
}