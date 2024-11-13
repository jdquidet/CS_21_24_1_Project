import random

# Constants
SIZE = 3
WIN_TILE = 512
TILE_VALUES = [2, 4, 8, 16, 32, 64, 128, 256, 512]

# Helper functions to display the grid and handle tile movements
def print_grid(grid):
    """Print the 3x3 grid."""
    print("+---+---+---+")
    for row in grid:
        print("|", end=" ")
        for tile in row:
            if tile == 0:
                print("   ", end="|")
            else:
                print(f" {tile:3}", end="|")
        print("\n+---+---+---+")

def add_random_tile(grid):
    """Place a new tile (2) randomly in an empty spot."""
    empty_cells = [(r, c) for r in range(SIZE) for c in range(SIZE) if grid[r][c] == 0]
    if empty_cells:
        r, c = random.choice(empty_cells)
        grid[r][c] = 2

def is_game_over(grid):
    """Check if the game is over (no empty cells and no valid moves)."""
    # Check if there's any empty tile
    for r in range(SIZE):
        for c in range(SIZE):
            if grid[r][c] == 0:
                return False
            # Check if adjacent tiles can combine
            if r < SIZE - 1 and grid[r][c] == grid[r + 1][c]:
                return False
            if c < SIZE - 1 and grid[r][c] == grid[r][c + 1]:
                return False
    return True

def is_win(grid):
    """Check if the player has reached the WIN_TILE."""
    for row in grid:
        if WIN_TILE in row:
            return True
    return False

def compress(grid):
    """Move all non-zero tiles to the left (or top for columns)."""
    new_grid = []
    for row in grid:
        new_row = [tile for tile in row if tile != 0]
        new_row += [0] * (SIZE - len(new_row))
        new_grid.append(new_row)
    return new_grid

def merge(grid):
    """Merge the tiles in the grid if two adjacent tiles are the same."""
    for r in range(SIZE):
        for c in range(SIZE - 1):
            if grid[r][c] == grid[r][c + 1] and grid[r][c] != 0:
                grid[r][c] *= 2
                grid[r][c + 1] = 0
    return grid

def reverse(grid):
    """Reverse the rows of the grid (used for right movement)."""
    return [row[::-1] for row in grid]

def transpose(grid):
    """Transpose the grid (used for up/down movements)."""
    return [[grid[r][c] for r in range(SIZE)] for c in range(SIZE)]

def move_left(grid):
    """Move the tiles to the left."""
    grid = compress(grid)
    grid = merge(grid)
    grid = compress(grid)
    return grid

def move_right(grid):
    """Move the tiles to the right."""
    grid = reverse(grid)
    grid = move_left(grid)
    return reverse(grid)

def move_up(grid):
    """Move the tiles up."""
    grid = transpose(grid)
    grid = move_left(grid)
    return transpose(grid)

def move_down(grid):
    """Move the tiles down."""
    grid = transpose(grid)
    grid = move_right(grid)
    return transpose(grid)

def main():
    """Main game loop."""
    # Start the game with user choice
    print("Welcome to 2048!")
    choice = input("Choose [1] for New Game, [2] to Start from a State: ")
    
    if choice == '1':
        # Start a new game with a random grid
        grid = [[0] * SIZE for _ in range(SIZE)]
        add_random_tile(grid)
        add_random_tile(grid)
    elif choice == '2':
        # Start from a user-defined state
        grid = []
        print("Enter the current board state (9 numbers, 0 for empty):")
        for _ in range(SIZE):
            row = list(map(int, input().split()))
            grid.append(row)
    else:
        print("Invalid choice. Exiting.")
        return
    
    # Game loop
    while True:
        print_grid(grid)
        
        # Check for win
        if is_win(grid):
            print("Congratulations! You have reached the 512 tile!")
            break
        
        # Check for game over
        if is_game_over(grid):
            print("Game Over...")
            break
        
        # Get player input for movement
        move = input("Enter a move (W=Up, A=Left, S=Down, D=Right, X=Exit): ").upper()
        
        if move == 'X':
            print("Game Over.")
            break
        elif move == 'W':
            grid = move_up(grid)
        elif move == 'A':
            grid = move_left(grid)
        elif move == 'S':
            grid = move_down(grid)
        elif move == 'D':
            grid = move_right(grid)
        else:
            print("Invalid move. Please try again.")
            continue
        
        # Add a new random tile after the move
        add_random_tile(grid)

if __name__ == "__main__":
    main()
