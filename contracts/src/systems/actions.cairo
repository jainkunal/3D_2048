use threed_2048::models::moves::Direction;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use threed_2048::models::game::{Game, GameMode};
use threed_2048::models::entity::{Tile};
use threed_2048::utils::random::{Random, RandomImpl};
use starknet::{ContractAddress, get_caller_address};

// define the interface
#[dojo::interface]
trait IActions {
    fn create_game(ref world: IWorldDispatcher) -> u32;
    fn move(ref world: IWorldDispatcher, game_id: u32, direction: Direction);
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::{IActions, get_tile_at, get_spawn_tile_location_and_value};
    use starknet::{ContractAddress, get_caller_address};
    use threed_2048::models::moves::Direction;
    use threed_2048::models::player::Player;
    use threed_2048::models::game::{Game, GameMode};
    use threed_2048::models::entity::{Tile};

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
        fn create_game(ref world: IWorldDispatcher) -> u32 {
            let player = get_caller_address();
            let player_entity = get!(world, player, (Player));

            let game_id = player_entity.last_game_id + 1;

            set!(
                world,
                Game {
                    player,
                    game_id: player_entity.last_game_id + 1,
                    game_mode: GameMode::Single,
                    width: 4,
                    height: 4,
                    tile_count: 1,
                    score: 0,
                    state: 1
                },
            );

            let r = get_spawn_tile_location_and_value(@world, player, game_id, 0, 4, 4);
            let (spawn_x, spawn_y, spawn_value) = r.unwrap();
            set!(world, (
                Tile {
                    player,
                    game_id,
                    tile_id: 0,
                    x: spawn_x,
                    y: spawn_y,
                    z: 0,
                    value: spawn_value
                },
            ));

            game_id
        }

        // Implementation of the move function for the ContractState struct.
        fn move(ref world: IWorldDispatcher, game_id: u32, direction: Direction) {
            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();

            // Retrieve the player's game.
            let mut game = get!(world, (player, game_id), (Game));
            let mut tile_count = game.tile_count;
            let mut score = game.score;


            // Code to process direction left
            match direction {
                Direction::Left => {
                    let mut y: usize = 0;
                    loop {
                        if (y >= game.height) {
                            break;
                        }

                        let mut merged = false;

                        let mut x: usize = 0;
                        loop {
                            if (x >= game.width) {
                                break;
                            }
                            if let Option::Some(tile_id) = get_tile_at(@world, player, game_id, tile_count, x, y) {
                                let mut current_x = x;
                                let tile = get!(world, (player, game_id, tile_id), (Tile));
                                while current_x > 0 && get_tile_at(@world, player, game_id, tile_count, current_x - 1, y).is_none() {
                                    // move_tile(ref world, game_id, tile_id, current_x - 1, y);
                                    set!(
                                        world,
                                        (
                                            Tile {
                                                player,
                                                game_id,
                                                tile_id,
                                                x: current_x - 1,
                                                y: y,
                                                z: tile.z,
                                                value: tile.value,
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
                            if let Option::Some(current_tile_id) = get_tile_at(@world, player, game_id, tile_count, x, y) {
                                if let Option::Some(left_tile_id) = get_tile_at(@world, player, game_id, tile_count, x - 1, y) {
                                    let current_tile = get!(world, (player, game_id, current_tile_id), (Tile));
                                    let left_tile = get!(world, (player, game_id, left_tile_id), (Tile));
                                    let current_value = current_tile.value;
                                    let left_value = left_tile.value;

                                    if current_value == left_value && !merged {
                                        // Merge Tiles
                                        set!(
                                            world,
                                            (
                                                Tile {
                                                    player,
                                                    game_id,
                                                    tile_id: left_tile_id,
                                                    x: left_tile.x,
                                                    y: left_tile.y,
                                                    z: left_tile.z,
                                                    value: left_tile.value * 2
                                                }
                                            )
                                        );
                                        score += left_tile.value * 2;

                                        let last_index_tile = get!(world, (player, game_id, tile_count - 1), (Tile));
                                        set!(
                                            world,
                                            (
                                                Tile {
                                                    player,
                                                    game_id,
                                                    tile_id: current_tile_id,
                                                    x: last_index_tile.x,
                                                    y: last_index_tile.y,
                                                    z: last_index_tile.z,
                                                    value: last_index_tile.value
                                                }
                                            )
                                        );
                                        delete!(world, (last_index_tile));
                                        tile_count -= 1;

                                        // merged[x - 1] = true;
                                        merged = true;

                                        let mut xx: usize = x + 1;
                                        loop {
                                            if xx >= game.width {
                                                break;
                                            }
                                            // Move Tile
                                            if let Option::Some(tile_id) = get_tile_at(@world, player, game_id, tile_count, xx, y) {
                                                let tile = get!(world, (player, game_id, tile_id), (Tile));
                                                set!(
                                                    world,
                                                    (
                                                        Tile {
                                                            player,
                                                            game_id,
                                                            tile_id,
                                                            x: xx - 1,
                                                            y: y,
                                                            z: tile.z,
                                                            value: tile.value,
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

                            x += 1;
                        };

                        y += 1;
                    }
                },
                Direction::Right => {
                    let mut y: u32 = 0;
                    loop {
                        if y >= game.height {
                            break;
                        }
                
                        let mut merged = false;
                
                        // Move tiles to the right
                        let mut x: u32 = game.width - 1;
                        loop {
                            if let Option::Some(tile_id) = get_tile_at(@world, player, game_id, tile_count, x, y) {
                                let mut current_x = x;
                                let tile = get!(world, (player, game_id, tile_id), (Tile));
                                while current_x < game.width - 1 && get_tile_at(@world, player, game_id, tile_count, current_x + 1, y).is_none() {
                                    set!(
                                        world,
                                        (
                                            Tile {
                                                player,
                                                game_id,
                                                tile_id,
                                                x: current_x + 1,
                                                y,
                                                z: tile.z,
                                                value: tile.value,
                                            }
                                        )
                                    );
                                    current_x += 1;
                                }
                            }
                            if x == 0 {
                                break;
                            }
                            x -= 1;
                        };
                
                        // Merge Tiles Logic
                        let mut x: u32 = game.width - 2;
                        loop {
                            if let Option::Some(current_tile_id) = get_tile_at(@world, player, game_id, tile_count, x, y) {
                                if let Option::Some(right_tile_id) = get_tile_at(@world, player, game_id, tile_count, x + 1, y) {
                                    let current_tile = get!(world, (player, game_id, current_tile_id), (Tile));
                                    let right_tile = get!(world, (player, game_id, right_tile_id), (Tile));
                                    let current_value = current_tile.value;
                                    let right_value = right_tile.value;
                
                                    if current_value == right_value && !merged {
                                        // Merge Tiles
                                        set!(
                                            world,
                                            (
                                                Tile {
                                                    player,
                                                    game_id,
                                                    tile_id: right_tile_id,
                                                    x: right_tile.x,
                                                    y: right_tile.y,
                                                    z: right_tile.z,
                                                    value: right_tile.value * 2
                                                }
                                            )
                                        );
                                        score += right_tile.value * 2;
                
                                        let last_index_tile = get!(world, (player, game_id, tile_count - 1), (Tile));
                                        set!(
                                            world,
                                            (
                                                Tile {
                                                    player,
                                                    game_id,
                                                    tile_id: current_tile_id,
                                                    x: last_index_tile.x,
                                                    y: last_index_tile.y,
                                                    z: last_index_tile.z,
                                                    value: last_index_tile.value
                                                }
                                            )
                                        );
                                        delete!(world, (last_index_tile));
                                        tile_count -= 1;
                
                                        merged = true;
                
                                        if x > 0 {
                                            let mut xx: u32 = x - 1;
                                            loop {
                                                // Move Tile
                                                if let Option::Some(tile_id) = get_tile_at(@world, player, game_id, tile_count, xx, y) {
                                                    let tile = get!(world, (player, game_id, tile_id), (Tile));
                                                    set!(
                                                        world,
                                                        (
                                                            Tile {
                                                                player,
                                                                game_id,
                                                                tile_id,
                                                                x: xx + 1,
                                                                y,
                                                                z: tile.z,
                                                                value: tile.value,
                                                            }
                                                        )
                                                    );
                                                }
                                                if xx == 0 {
                                                    break;
                                                }
                                                xx -= 1;
                                            };
                                        }
                                    } else {
                                        merged = false;
                                    }
                                } else {
                                    merged = false;
                                }
                            } else {
                                merged = false;
                            }

                            if x == 0 {
                                break;
                            }
                            x -= 1;
                        };
                
                        y += 1;
                    }
                },
                Direction::Up => {
                    let mut x: u32 = 0;
                    loop {
                        if x >= game.width {
                            break;
                        }
                    
                        let mut merged = false;
                    
                        let mut y: u32 = 0;
                        loop {
                            if y >= game.height {
                                break;
                            }
                            if let Option::Some(tile_id) = get_tile_at(@world, player, game_id, tile_count, x, y) {
                                let mut current_y = y;
                                let tile = get!(world, (player, game_id, tile_id), (Tile));
                                while current_y > 0 && get_tile_at(@world, player, game_id, tile_count, x, current_y - 1).is_none() {
                                    set!(
                                        world,
                                        (
                                            Tile {
                                                player,
                                                game_id,
                                                tile_id,
                                                x: x,
                                                y: current_y - 1,
                                                z: tile.z,
                                                value: tile.value,
                                            }
                                        )
                                    );
                                    current_y -= 1;
                                }
                            }
                            y += 1;
                        };
                    
                        // Merge Tiles Logic
                        let mut y: u32 = 1;
                        loop {
                            if y >= game.height {
                                break;
                            }
                            if let Option::Some(current_tile_id) = get_tile_at(@world, player, game_id, tile_count, x, y) {
                                if let Option::Some(above_tile_id) = get_tile_at(@world, player, game_id, tile_count, x, y - 1) {
                                    let current_tile = get!(world, (player, game_id, current_tile_id), (Tile));
                                    let above_tile = get!(world, (player, game_id, above_tile_id), (Tile));
                                    let current_value = current_tile.value;
                                    let above_value = above_tile.value;
                    
                                    if current_value == above_value && !merged {
                                        // Merge Tiles
                                        set!(
                                            world,
                                            (
                                                Tile {
                                                    player,
                                                    game_id,
                                                    tile_id: above_tile_id,
                                                    x: above_tile.x,
                                                    y: above_tile.y,
                                                    z: above_tile.z,
                                                    value: above_tile.value * 2
                                                }
                                            )
                                        );
                                        score += above_tile.value * 2;
                    
                                        let last_index_tile = get!(world, (player, game_id, tile_count - 1), (Tile));
                                        set!(
                                            world,
                                            (
                                                Tile {
                                                    player,
                                                    game_id,
                                                    tile_id: current_tile_id,
                                                    x: last_index_tile.x,
                                                    y: last_index_tile.y,
                                                    z: last_index_tile.z,
                                                    value: last_index_tile.value
                                                }
                                            )
                                        );
                                        delete!(world, (last_index_tile));
                                        tile_count -= 1;
                    
                                        merged = true;
                    
                                        let mut yy: u32 = y + 1;
                                        loop {
                                            if yy >= game.height {
                                                break;
                                            }
                                            // Move Tile
                                            if let Option::Some(tile_id) = get_tile_at(@world, player, game_id, tile_count, x, yy) {
                                                let tile = get!(world, (player, game_id, tile_id), (Tile));
                                                set!(
                                                    world,
                                                    (
                                                        Tile {
                                                            player,
                                                            game_id,
                                                            tile_id,
                                                            x: x,
                                                            y: yy - 1,
                                                            z: tile.z,
                                                            value: tile.value,
                                                        }
                                                    )
                                                );
                                            }
                                            yy += 1;
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
                    
                            y += 1;
                        };
                    
                        x += 1;
                    }
                },
                Direction::Down => {
                    let mut x: u32 = 0;
                    loop {
                        if x >= game.width {
                            break;
                        }
                
                        let mut merged = false;
                
                        // Move tiles downward
                        let mut y: u32 = game.height - 1;
                        loop {
                            if let Option::Some(tile_id) = get_tile_at(@world, player, game_id, tile_count, x, y) {
                                let mut current_y = y;
                                let tile = get!(world, (player, game_id, tile_id), (Tile));
                                while current_y < game.height - 1 && get_tile_at(@world, player, game_id, tile_count, x, current_y + 1).is_none() {
                                    set!(
                                        world,
                                        (
                                            Tile {
                                                player,
                                                game_id,
                                                tile_id,
                                                x,
                                                y: current_y + 1,
                                                z: tile.z,
                                                value: tile.value,
                                            }
                                        )
                                    );
                                    current_y += 1;
                                }
                            }
                            if y == 0 {
                                break;
                            }
                            y -= 1;
                        };
                
                        // Merge Tiles Logic
                        let mut y: u32 = game.height - 2;
                        loop {
                            if let Option::Some(current_tile_id) = get_tile_at(@world, player, game_id, tile_count, x, y) {
                                if let Option::Some(bottom_tile_id) = get_tile_at(@world, player, game_id, tile_count, x, y + 1) {
                                    let current_tile = get!(world, (player, game_id, current_tile_id), (Tile));
                                    let bottom_tile = get!(world, (player, game_id, bottom_tile_id), (Tile));
                                    let current_value = current_tile.value;
                                    let bottom_value = bottom_tile.value;
                
                                    if current_value == bottom_value && !merged {
                                        // Merge Tiles
                                        set!(
                                            world,
                                            (
                                                Tile {
                                                    player,
                                                    game_id,
                                                    tile_id: bottom_tile_id,
                                                    x: bottom_tile.x,
                                                    y: bottom_tile.y,
                                                    z: bottom_tile.z,
                                                    value: bottom_tile.value * 2
                                                }
                                            )
                                        );
                                        score += bottom_tile.value * 2;
                
                                        let last_index_tile = get!(world, (player, game_id, tile_count - 1), (Tile));
                                        set!(
                                            world,
                                            (
                                                Tile {
                                                    player,
                                                    game_id,
                                                    tile_id: current_tile_id,
                                                    x: last_index_tile.x,
                                                    y: last_index_tile.y,
                                                    z: last_index_tile.z,
                                                    value: last_index_tile.value
                                                }
                                            )
                                        );
                                        delete!(world, (last_index_tile));
                                        tile_count -= 1;
                
                                        merged = true;
                
                                        if y > 0 {
                                            let mut yy: u32 = y - 1;
                                            loop {
                                                // Move Tile
                                                if let Option::Some(tile_id) = get_tile_at(@world, player, game_id, tile_count, x, yy) {
                                                    let tile = get!(world, (player, game_id, tile_id), (Tile));
                                                    set!(
                                                        world,
                                                        (
                                                            Tile {
                                                                player,
                                                                game_id,
                                                                tile_id,
                                                                x,
                                                                y: yy + 1,
                                                                z: tile.z,
                                                                value: tile.value,
                                                            }
                                                        )
                                                    );
                                                }
                                                if yy == 0 {
                                                    break;
                                                }
                                                yy -= 1;
                                            };
                                        }
                                    } else {
                                        merged = false;
                                    }
                                } else {
                                    merged = false;
                                }
                            } else {
                                merged = false;
                            }
                
                            if y == 0 {
                                break;
                            }
                            y -= 1;
                        };
                
                        x += 1;
                    }
                },
                Direction::Back => {},
                Direction::Front => {},
                Direction::None => {},
            }

            let r = get_spawn_tile_location_and_value(@world, player, game_id, tile_count, game.height, game.width);
            if r.is_some() {
                let (spawn_x, spawn_y, spawn_value) = r.unwrap();
                set!(world, (
                    Tile {
                        player,
                        game_id,
                        tile_id: tile_count,
                        x: spawn_x,
                        y: spawn_y,
                        z: 0,
                        value: spawn_value
                    },
                    Game {
                        player,
                        game_id,
                        game_mode: game.game_mode,
                        width: game.width,
                        height: game.height,
                        tile_count: tile_count + 1,
                        score,
                        state: game.state, // 1: Playing, 2: Game Over, 3: Won
                    }
                ))
            }

            // Update the world state with the new moves data and position.
            // set!(world, (moves, next));
            // Emit an event to the world to notify about the player's move.
            // emit!(world, (Moved { player, direction }));
        }
    }
}

fn get_tile_at(world: @IWorldDispatcher, player: ContractAddress, game_id: u32, tile_count: u32, x: u32, y: u32) -> Option<u32> {
    let mut i: usize = 0;
    let result = loop {
        if (i >= tile_count) {
            break Option::None;
        }
        let tile = get!(*world, (player, game_id, i), (Tile));
        if tile.x == x && tile.y == y {
            break Option::Some(i);
        }
        i += 1;
    };
    result
}

fn get_spawn_tile_location_and_value(world: @IWorldDispatcher, player: ContractAddress, game_id: u32, tile_count: u32, height: u32, width: u32) -> Option<(u32, u32, u32)> {
    let empty_positions = find_empty_positions(world, player, game_id, tile_count, height, width);

    if empty_positions.len() == 0 {
        return Option::None;
    }

    let mut randomizer = RandomImpl::new();
    let random_index = randomizer.between::<u128>(0, empty_positions.len().into());
    let (x, y) = *empty_positions.at(random_index.try_into().unwrap());

    let value_prob = randomizer.between::<u128>(0, 10_u128);
    let value: u32 = if value_prob == 0 { 4 } else { 2 };

    Option::Some((x, y, value))
}


fn find_empty_positions(world: @IWorldDispatcher, player: ContractAddress, game_id: u32, tile_count: u32, height: u32, width: u32) -> Array<(u32, u32)> {
    let mut empty_positions = ArrayTrait::new();
    
    let mut y = 0;
    loop {
        if y >= height {
            break;
        }
        let mut x = 0;
        loop {
            if x >= width {
                break;
            }
            if get_tile_at(world, player, game_id, tile_count, x, y).is_none() {
                empty_positions.append((x, y));
            }
            x += 1;
        };
        y += 1;
    };
    empty_positions
}
