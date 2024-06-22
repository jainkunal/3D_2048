use threed_2048::models::moves::Direction;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use threed_2048::models::game::{Game, GameMode};
use threed_2048::models::entity::{Position, Value, Mergeable};

// define the interface
#[dojo::interface]
trait IActions {
    fn move(ref world: IWorldDispatcher, game_id: u32, direction: Direction);
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::{IActions, get_tile_at};
    use starknet::{ContractAddress, get_caller_address};
    use threed_2048::models::moves::Direction;
    use threed_2048::models::game::{Game, GameMode};
    use threed_2048::models::entity::{Position, Value, Mergeable};

    #[derive(Copy, Drop, Serde)]
    #[dojo::model]
    #[dojo::event]
    struct Moved {
        #[key]
        player: ContractAddress,
        direction: Direction,
    }

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        // Implementation of the move function for the ContractState struct.
        fn move(ref world: IWorldDispatcher, game_id: u32, direction: Direction) {
            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();

            // Retrieve the player's game.
            let mut game = get!(world, (player, game_id), (Game));
            let tile_count = game.tile_count;

            let mut y: usize = 0;
            loop {
                if (y >= game.height) {
                    break;
                }
                // process_row(ref world, game_id, tile_count, y, game.width);

                let mut merged = false;
                // let mut x: usize = 0;
                // loop {
                //     if (x >= game.width) {
                //         break;
                //     }
                //     merged.append(false);
                //     x += 1;
                // };

                let mut x: usize = 0;
                loop {
                    if (x >= game.width) {
                        break;
                    }
                    if let Option::Some(tile_id) = get_tile_at(@world, game_id, tile_count, x, y) {
                        let mut current_x = x;
                        while current_x > 0 && get_tile_at(@world, game_id, tile_count, current_x - 1, y).is_none() {
                            // move_tile(ref world, game_id, tile_id, current_x - 1, y);
                            let mut position = get!(world, (game_id, tile_id), (Position));
                            set!(
                                world,
                                (
                                    Position {
                                        game_id,
                                        tile_id,
                                        x: current_x - 1,
                                        y: y,
                                        z: position.z,
                                    }
                                )
                            );
                            current_x -= 1;
                        }
                    }
                    x += 1;
                };

                // Merge Tiles Logic
                let mut x: usize = 1;
                loop {
                    if (x >= game.width) {
                        break;
                    }
                    if let Option::Some(current_id) = get_tile_at(@world, game_id, tile_count, x, y) {
                        if let Option::Some(left_id) = get_tile_at(@world, game_id, tile_count, x - 1, y) {
                            let current_value = (get!(world, (game_id, current_id), (Value))).value;
                            let left_value = (get!(world, (game_id, left_id), (Value))).value;

                            if current_value == left_value && !merged {
                                // Merge Tiles

                                // merged[x - 1] = true;
                                merged = true;

                                let mut xx: usize = x + 1;
                                loop {
                                    if xx >= game.width {
                                        break;
                                    }
                                    // Move Tile
                                    if let Option::Some(tile_id) = get_tile_at(@world, game_id, tile_count, xx, y) {
                                        let mut position = get!(world, (game_id, tile_id), (Position));
                                        set!(
                                            world,
                                            (
                                                Position {
                                                    game_id,
                                                    tile_id,
                                                    x: xx - 1,
                                                    y: y,
                                                    z: position.z,
                                                }
                                            )
                                        );
                                    }
                                    xx += 1;
                                };
                            } else {
                                merged = false;
                            }
                        } else {
                            merged = false;
                        }
                    } else {
                        merged = false;
                    }
                };

                y += 1;
            };

            // Update the world state with the new moves data and position.
            // set!(world, (moves, next));
            // Emit an event to the world to notify about the player's move.
            // emit!(world, (Moved { player, direction }));
        }
    }
}

fn get_tile_at(world: @IWorldDispatcher, game_id: u32, tile_count: u32, x: u32, y: u32) -> Option<u32> {
    let mut i: usize = 0;
    let result = loop {
        if (i >= tile_count) {
            break Option::None;
        }
        let position = get!(*world, (game_id, i), (Position));
        if position.x == x && position.y == y {
            break Option::Some(i);
        }
    };
    result
}

// fn process_row(ref world: IWorldDispatcher, game_id: u32, tile_count: u32, y: u32, width: u32) {
//     let mut x: usize = 0;
//     loop {
//         if (x >= width) {
//             break;
//         }
//         if let Option::Some(tile_id) = get_tile_at(@world, game_id, tile_count, x, y) {
//             let mut current_x = x;
//             while current_x > 0 && get_tile_at(@world, game_id, tile_count, current_x - 1, y).is_none() {
//                 // move_tile(ref world, game_id, tile_id, current_x - 1, y);
//                 let mut position = get!(world, (game_id, tile_id), (Position));
//                 set!(
//                     world,
//                     (
//                         Position {
//                             game_id,
//                             tile_id,
//                             x: current_x - 1,
//                             y: y,
//                             z: position.z,
//                         }
//                     )
//                 );
//             }
//         }
//         x += 1;
//     };
// }

// fn move_tile(ref world: IWorldDispatcher, game_id: u32, tile_id: u32, new_x: u32, new_y: u32) {
//     let mut position = get!(world, (game_id, tile_id), (Position));
//     set!(
//         world,
//         (
//             Position {
//                 game_id,
//                 tile_id,
//                 x: new_x,
//                 y: new_y,
//                 z: position.z,
//             }
//         )
//     );
// }