use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct Game {
    #[key]
    game_id: u32,
    game_mode: GameMode
}

#[derive(Copy, Drop, Serde, PartialEq)]
enum GameMode {
    Single,
    AIMulti
}