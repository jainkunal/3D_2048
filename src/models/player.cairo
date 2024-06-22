use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Player {
    #[key]
    address: ContractAddress,
    games_won: u256,
    games_lost: u256
}

// The GamePlayer is the store for the state in each game
// #[derive(Copy, Drop, Serde, Debug)]
// #[dojo::model]
// struct GamePlayer {
//     #[key]
//     address: ContractAddress,
//     #[key]
//     game_id: u128,
// }

// trait GamePlayerTrait {
//     fn new(game_id: u128, address: ContractAddress) -> GamePlayer;
//     fn is_finished(self: GamePlayer) -> bool;
// }

// impl GamePlayerImpl of GamePlayerTrait {
//     // logic to create the game player
//     fn new(game_id: u128, address: ContractAddress) -> GamePlayer {
//         let game_player = GamePlayer {
//             address: address,
//             game_id: game_id,
//         };
//         game_player
//     }

//     fn is_finished(self: GamePlayer) -> bool {
//         false
//     }
// }