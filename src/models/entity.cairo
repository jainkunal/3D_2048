use starknet::ContractAddress;

#[derive(Model, Drop, Serde)]
struct Position {
    #[key]
    game_id: u32,
    #[key]
    tile_id: u32,
    x: u32,
    y: u32,
    z: u32
}

#[derive(Model, Drop, Serde)]
struct Value {
    #[key]
    game_id: u32,
    #[key]
    tile_id: u32,
    value: u32,
}

#[derive(Model, Drop, Serde)]
struct Mergeable {
    #[key]
    game_id: u32,
    #[key]
    tile_id: u32,
    can_merge: bool,
}

#[derive(Model, Drop, Serde)]
struct Movable {
    #[key]
    game_id: u32,
    #[key]
    tile_id: u32,
    can_move: bool,
}