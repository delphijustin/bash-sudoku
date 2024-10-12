#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Load Sudoku puzzles from file
load_puzzle() {
    puzzle_file="level$2.puz"
    if [[ ! -f "$puzzle_file" ]]; then
        echo "Puzzle file not found!"
        echo "Either incorrect level# was enter or not found"
        exit 1
    fi

    # Read a specific puzzle line (e.g., first line)
    puzzle=$(sed "${1}q;d" "$puzzle_file")
    # Convert the puzzle string into a 9x9 board array
    for ((i = 0; i < 81; i++)); do
        board[$i]=${puzzle:$i:1}
    done
}

# Function to print the current Sudoku board with colors
print_board() {
    clear
    echo "Sudoku Board:"
    for ((i = 0; i < 81; i++)); do
        # Pre-filled numbers are printed in cyan
        if [[ ${board[i]} -ne 0 ]]; then
            printf "${CYAN}${board[i]}${RESET} "
        else
            printf "_ " # Empty cells are shown as zeroes for now
        fi

        # Print new line after every 9 cells
        if (( (i + 1) % 9 == 0 )); then
            echo ""
        fi
    done
}

# Function to check if a move is valid
is_valid_move() {
    local row=$1
    local col=$2
    local num=$3

    # Check the row
    for ((i = 0; i < 9; i++)); do
        if [[ ${board[row * 9 + i]} -eq $num ]]; then
            return 1
        fi
    done

    # Check the column
    for ((i = 0; i < 9; i++)); do
        if [[ ${board[i * 9 + col]} -eq $num ]]; then
            return 1
        fi
    done

    # Check the 3x3 sub-grid
    local start_row=$((row / 3 * 3))
    local start_col=$((col / 3 * 3))
    for ((i = 0; i < 3; i++)); do
        for ((j = 0; j < 3; j++)); do
            if [[ ${board[(start_row + i) * 9 + (start_col + j)]} -eq $num ]]; then
                return 1
            fi
        done
    done

    return 0
}

# Main game loop
start_game() {
    puzzle_number=$1

    # Load puzzle based on user selection
    load_puzzle $puzzle_number $2

    while true; do
        print_board

        # Get user input
        echo "Enter row (0-8), column (0-8), and number (1-9) separated by spaces (or type 'q' to quit):"
        read row col num

        # Exit the game if user types 'q'
        if [[ $row == "q" ]]; then
            echo "Quitting game."
            break
        fi

        # Validate input
        if [[ $row =~ ^[0-8]$ && $col =~ ^[0-8]$ && $num =~ ^[1-9]$ ]]; then
            # Check if the move is valid
            if is_valid_move $row $col $num; then
                # Place the number on the board, newly added numbers in green
                board[row * 9 + col]=$num
                print_board  # Refresh board
            else
                echo "Invalid move! Try again."
            fi
        else
            echo "Invalid input! Please enter numbers between 0-8 for row and column, and 1-9 for the number."
        fi
    done
}

# Start the game by selecting a puzzle number
echo "Enter Level#(1..5):"
read level_number
echo "Enter puzzle number to play (1-N):"
read puzzle_number
start_game $puzzle_number $level_number
