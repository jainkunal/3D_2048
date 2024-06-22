use threed_2048::models::moves::Direction;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use threed_2048::models::game::{Game, GameMode};

// define the interface
#[dojo::interface]
trait IActions {
    fn move(ref world: IWorldDispatcher, game_id: u32, direction: Direction);
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::{IActions, next_position};
    use starknet::{ContractAddress, get_caller_address};
    use threed_2048::models::moves::Direction;
    use threed_2048::models::game::{Game, GameMode};

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

            // Update the world state with the new moves data and position.
            // set!(world, (moves, next));
            // Emit an event to the world to notify about the player's move.
            // emit!(world, (Moved { player, direction }));
        }
    }
}

// Define function like this:
fn next_position(direction: Direction) -> Direction {
//     match direction {
//         Direction::None => { return position; },
//         Direction::Left => { position.vec.x -= 1; },
//         Direction::Right => { position.vec.x += 1; },
//         Direction::Up => { position.vec.y -= 1; },
//         Direction::Down => { position.vec.y += 1; },
//     };
    direction
}
