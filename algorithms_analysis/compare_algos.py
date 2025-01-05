import pandas as pd
import matplotlib
# Use Agg backend for non-interactive environments
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# Read the CSV file
df = pd.read_csv('test_results.csv')

# Create figure
plt.figure(figsize=(10, 6))

# Plot execution time comparison
for algorithm in df['Algorithm'].unique():
    data = df[df['Algorithm'] == algorithm]
    plt.plot(data['Rooms'], data['Execution Time'], marker='o', label=algorithm)

plt.title('Algorithm Execution Time vs Number of Rooms')
plt.xlabel('Number of Rooms')
plt.ylabel('Execution Time (ms)')
plt.grid(True)
plt.legend()

# Adjust layout
plt.tight_layout()

# Save the plot and print confirmation message
output_file = 'execution_time_plot.png'
plt.savefig(output_file, dpi=300, bbox_inches='tight')
print(f"Plot has been saved as '{output_file}'")

# Close the figure to free memory
plt.close()
