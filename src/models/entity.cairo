use starknet::ContractAddress;

#[derive(Model, Drop, Serde)]
struct Position {
    #[key]
    entity_id: u32,
    x: u32,
    y: u32,
}

#[derive(Model, Drop, Serde)]
struct Value {
    #[key]
    entity_id: u32,
    value: u32,
}

#[derive(Model, Drop, Serde)]
struct Mergeable {
    #[key]
    entity_id: u32,
    can_merge: bool,
}

#[derive(Model, Drop, Serde)]
struct Movable {
    #[key]
    entity_id: u32,
    can_move: bool,
}

#[derive(Model, Drop, Serde)]
struct Renderable {
    #[key]
    entity_id: u32,
    color_r: u8,
    color_g: u8,
    color_b: u8,
    width: u32,
    height: u32,
    text: felt252,
}

#[derive(Model, Drop, Serde)]
struct Size {
    #[key]
    entity_id: u32,
    width: u32,
    height: u32,
}

#[derive(Model, Drop, Serde)]
struct ScoreValue {
    #[key]
    entity_id: u32,
    score: u32,
}

#[derive(Model, Drop, Serde)]
struct CurrentState {
    #[key]
    entity_id: u32,
    state: u8, // 1: Playing, 2: Game Over, 3: Won
}