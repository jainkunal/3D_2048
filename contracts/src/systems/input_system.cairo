#[dojo::contract]
mod input_system {
    use array::ArrayTrait;
    use box::BoxTrait;
    use traits::Into;

    fn execute(ref world: IWorldDispatcher, direction: felt252) -> felt252 {
        // Handle input and return the direction
        // direction could be 'up', 'down', 'left', 'right'
        // You might want to validate the input here
        direction
    }
}