use starknet::ContractAddress;

#[derive(Drop, Serde)]
#[dojo::model]
struct Position {
    #[key]
    game_id: u32,
    #[key]
    tile_id: u32,
    x: u32,
    y: u32,
    z: u32
}

#[derive(Drop, Serde)]
#[dojo::model]
struct Value {
    #[key]
    game_id: u32,
    #[key]
    tile_id: u32,
    value: u32,
}

#[derive(Drop, Serde)]
#[dojo::model]
struct Mergeable {
    #[key]
    game_id: u32,
    #[key]
    tile_id: u32,
    can_merge: bool,
}

#[derive(Drop, Serde)]
#[dojo::model]
struct Movable {
    #[key]
    game_id: u32,
    #[key]
    tile_id: u32,
    can_move: bool,
}