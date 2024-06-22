#[derive(Serde, Copy, Drop, Introspect)]
enum Direction {
    None,
    Left,
    Right,
    Up,
    Down,
    Back,
    Front
}

impl DirectionIntoFelt252 of Into<Direction, felt252> {
    fn into(self: Direction) -> felt252 {
        match self {
            Direction::None => 0,
            Direction::Left => 1,
            Direction::Right => 2,
            Direction::Up => 3,
            Direction::Down => 4,
            Direction::Back => 5,
            Direction::Front => 6,
        }
    }
}