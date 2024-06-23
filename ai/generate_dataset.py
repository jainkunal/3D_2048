import numpy as np
import random

def create_initial_state():
    state = np.zeros((4, 4, 4), dtype=int)
    for _ in range(2):
        add_random_tile(state)
    return state

def add_random_tile(state):
    empty_cells = np.argwhere(state == 0)
    if empty_cells.size > 0:
        index = tuple(random.choice(empty_cells))
        state[index] = 2 if random.random() < 0.9 else 4

def move(state, direction):
    new_state = state.copy()
    if direction in [1, 2]:  # Left or Right
        new_state = np.apply_along_axis(merge_line, 1, new_state)
    elif direction in [3, 4]:  # Up or Down
        new_state = np.apply_along_axis(merge_line, 0, new_state)
    elif direction in [5, 6]:  # Back or Front
        new_state = np.apply_along_axis(merge_line, 2, new_state)
    
    if direction in [2, 4, 6]:  # Right, Down, Front
        new_state = np.flip(new_state, axis=(direction // 2) - 1)
    
    return new_state

def merge_line(line):
    line = line[line != 0]
    for i in range(len(line) - 1):
        if line[i] == line[i + 1]:
            line[i] *= 2
            line[i + 1] = 0
    line = line[line != 0]
    return np.pad(line, (0, 4 - len(line)))

def get_best_move(state):
    best_score = -1
    best_move = None
    for direction in range(1, 7):
        new_state = move(state.copy(), direction)
        if np.array_equal(new_state, state):
            continue  # Skip invalid moves
        score = calculate_score(new_state)
        if score > best_score:
            best_score = score
            best_move = direction
    return best_move if best_move is not None else random.randint(1, 6)

def calculate_score(state):
    # This function calculates a score for a given state
    # You can adjust this heuristic based on your game strategy
    score = np.sum(state)  # Base score is sum of all tiles
    
    # Bonus for empty cells
    score += np.count_nonzero(state == 0) * 10
    
    # Bonus for higher values in corners
    corners = [state[0,0,0], state[0,0,3], state[0,3,0], state[0,3,3],
               state[3,0,0], state[3,0,3], state[3,3,0], state[3,3,3]]
    score += sum(corners) * 2
    
    return score

def generate_dataset(num_samples):
    states = []
    actions = []
    for _ in range(num_samples):
        state = create_initial_state()
        for _ in range(random.randint(5, 50)):  # Simulate more moves
            direction = random.randint(1, 6)
            new_state = move(state, direction)
            if not np.array_equal(new_state, state):
                state = new_state
                add_random_tile(state)
        best_move = get_best_move(state)
        states.append(state.flatten())
        actions.append(best_move)
    return np.array(states), np.array(actions)

# Generate the dataset
X, y = generate_dataset(100000)

# Save the dataset
np.savez_compressed('3d_2048_dataset.npz', X=X, y=y)

# Print some statistics to verify diversity
unique, counts = np.unique(y, return_counts=True)
for action, count in zip(unique, counts):
    print(f"Action {action}: {count} ({count/len(y)*100:.2f}%)")