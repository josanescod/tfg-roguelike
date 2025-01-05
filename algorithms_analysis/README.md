# Algorithms Analysis

This folder contains data and scripts for analyzing the performance of the game's algorithms.

## Instructions

1. Open Godot Engine and select the `tfg-rlike` project.
2. Open `world.tscn`, select the `LevelBuilder` node, and edit `level_builder.gd`.
3. In `func _ready()`, uncomment `create_csv_file()` and `run_test_algo()`, comment `generate_map()`.
4. In `run_test_algo()`, set `max_R` (max rooms) to a value between 1 and 41.
5. Run the scene (press `F6`).
6. On Linux, the `test_results.csv` will be saved to `~/.local/share/godot/app_userdata/tfg-rglike`.
7. Copy the `test_results.csv` to the `algorithms_analysis` folder.
8. Set up the Python environment:
    ```bash
    python -m venv .env
    source .env/bin/activate
    pip install -r requirements.txt
    ```
9. Run the analysis:
    ```bash
    python compare_algo.py
    ```
10. Deactivate the environment:
    ```bash
    deactivate
    ```

You can now visualize and analyze the algorithm performance.
