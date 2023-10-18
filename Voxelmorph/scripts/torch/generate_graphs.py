import matplotlib.pyplot as plt

epochs = []
losses = []

with open('models/training_log.txt', 'r') as file:
    for line in file:
        if line.startswith('epoch:'):
            epoch_loss = line.strip().split()
            epoch = int(epoch_loss[1])
            loss = float(epoch_loss[8])
            epochs.append(epoch)
            losses.append(loss)

plt.plot(epochs, losses)
plt.xlabel('Epoch')
plt.ylabel('Loss')
plt.title('Training Loss')
plt.show()
