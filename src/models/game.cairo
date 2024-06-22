use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct Game {
    #[key]
    game_id: u32,
    game_mode: GameMode,
    width: u32,
    height: u32,
    tile_count: u32,
    score: u32,
    state: u8, // 1: Playing, 2: Game Over, 3: Won
}

#[derive(Copy, Drop, Serde, PartialEq)]
enum GameMode {
    Single,
    AIMulti
}