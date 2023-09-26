import os

import matplotlib.pyplot as plt
# Read the training log file
log_file = os.path.join( 'models','training_log.txt')
with open(log_file, 'r') as file:
    lines = file.readlines()

# Extract time information
epoch_times = []
step_times = []
for line in lines:
    if line.startswith('epoch:'):
        epoch_time = float(line.split('time: ')[1].split(' sec')[0])
        epoch_times.append(epoch_time)
    elif line.startswith('step:'):
        step_time = float(line.split('time: ')[1].split(' sec')[0])
        step_times.append(step_time)

# Plot the graph
epochs = range(1, len(epoch_times) + 1)
steps = range(1, len(step_times) + 1)

plt.figure(figsize=(10, 6))
plt.plot(epochs, epoch_times, label='Epoch Time')
plt.plot(steps, step_times, label='Step Time')
plt.xlabel('Epochs/Steps')
plt.ylabel('Time (seconds)')
plt.title('Training Time per Epoch and Step')
plt.legend()
plt.grid(True)
plt.show()
