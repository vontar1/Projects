import numpy as np
#import tensorflow as tf
from Paint import draw
#import tensorflow_datasets as tfds
import matplotlib.pyplot as plt


class NeuralNetwork:
    BATCH_SIZE = 256
    LEARNING_RATE = 0.03
    HIDDEN_SIZE = 64

    def __init__(self, hidden_layer_count, output_size, input_size):
        self.hidden_layers = []
        self.hidden_layers.append(Layer(input_size, NeuralNetwork.HIDDEN_SIZE))

        for _ in range(hidden_layer_count - 1):
            self.hidden_layers.append(Layer(NeuralNetwork.HIDDEN_SIZE, NeuralNetwork.HIDDEN_SIZE))

        self.output_layer = Layer(NeuralNetwork.HIDDEN_SIZE, output_size)

    def save_model(self, path):
        weights = [layer.weights for layer in self.hidden_layers[1:]]
        biases = [layer.biases for layer in self.hidden_layers[1:]]

        np.savez(path,
                 hidden_weights_layer1=self.hidden_layers[0].weights,
                 hidden_biases_layer1=self.hidden_layers[0].biases,
                 hidden_weights=weights,
                 hidden_biases=biases,
                 output_weights=self.output_layer.weights,
                 output_biases=self.output_layer.biases)

    def load_model(self, path):
        data = np.load(path, allow_pickle=True)
        self.hidden_layers[0].weights = data['hidden_weights_layer1']
        self.hidden_layers[0].biases = data['hidden_biases_layer1']

        for layer, w, b in zip(self.hidden_layers[1:], data['hidden_weights'], data['hidden_biases']):
            layer.weights = w
            layer.biases = b
        self.output_layer.weights = data['output_weights']
        self.output_layer.biases = data['output_biases']

    def forward_pass(self, batch):
        _softmax = Softmax()

        prev_output = batch

        for layer in self.hidden_layers:
            prev_output = layer.forward(prev_output)[1]

        self.output_layer.forward(prev_output)
        final_output = _softmax.forward(self.output_layer.output)

        return final_output

    @staticmethod
    def get_error(final_output, y_true):
        _cross_entropy = CrossEntropy()
        _error = _cross_entropy.forward(y_true, final_output)
        return _error

    def backprop(self, y_pred, y_true, batch):
        sample_count = batch.shape[0]
        layer_error = y_pred - y_true
        _relu = Relu()

        dWx = []
        dbx = []

        layers = self.hidden_layers + [self.output_layer]
        for i in reversed(range(len(layers))):
            layer = layers[i]

            #Get the input to this layer
            if i == 0:
                prev_activation = batch
            else:
                prev_activation = layers[i - 1].activated_output

            #Weight and bias gradients
            dW = prev_activation.T.dot(layer_error) / sample_count
            db = np.sum(layer_error, axis=0, keepdims=True) / sample_count

            #Store gradients
            dWx.append(dW)
            dbx.append(db)

            #Compute error for previous layer
            if i != 0:  # don't propagate past input
                relu_grad = ReluDeriv.forward(layers[i - 1].output)
                layer_error = (layer_error.dot(layer.weights.T)) * relu_grad

        #Restore order
        dWx.reverse()
        dbx.reverse()

        return dWx, dbx

    def train(self, path, inputs, y_true, runs=500):
        input_batches = np.array_split(inputs, len(inputs) // NeuralNetwork.BATCH_SIZE)
        y_batches = np.array_split(y_true, len(inputs) // NeuralNetwork.BATCH_SIZE)

        for run in range(runs):
            for batch, y_batch in zip(input_batches, y_batches):
                final_output = self.forward_pass(batch)

                dWx, dbx = self.backprop(final_output, y_batch, batch)

                for i in range(len(self.hidden_layers) + 1):
                    if i == len(self.hidden_layers):
                        self.output_layer.weights -= NeuralNetwork.LEARNING_RATE * dWx[i]
                        self.output_layer.biases -= NeuralNetwork.LEARNING_RATE * dbx[i]
                    else:
                        self.hidden_layers[i].weights -= NeuralNetwork.LEARNING_RATE * dWx[i]
                        self.hidden_layers[i].biases -= NeuralNetwork.LEARNING_RATE * dbx[i]
            if run % 10 == 0:
                full_output = self.forward_pass(inputs)
                print(f"run: {run}, loss: {NeuralNetwork.get_error(full_output, y_true)}")

        self.save_model(path)

    def test_model(self, test_input):
        output = self.forward_pass(test_input)
        max_index = np.argmax(output)
        _v = max_index
        _m = output[0, max_index] * 100

        output[0, max_index] = 0
        max_index1 = np.argmax(output)
        print(f"model prediction: {class_to_char(_v)} with a confidence score of {_m}%\n"
              f"second option: {class_to_char(max_index1)} with a confidence score of {output[0, max_index1] * 100}%")


class Layer:
    def __init__(self, n_features, layer_size):
        self.weights = np.random.randn(n_features, layer_size) * 0.1
        self.biases = np.random.randn(1, layer_size)
        self.output = None
        self.activated_output = None

    def forward(self, n_input):
        self.output = np.dot(n_input, self.weights) + self.biases
        self.activated_output = Relu.forward(self.output)
        return self.output, self.activated_output


class Relu:
    # Activation function for the hidden layers, allows for non-linear outputs
    @staticmethod
    def forward(x):
        output =  np.maximum(0, x)
        return output


class ReluDeriv:
    @staticmethod
    def forward(x):
        output = (x > 0).astype(float)
        return output


class Softmax:
    def __init__(self):
        self.output = None

    # Activation function for the output layer, converts the values to probabilities that add to 1
    def forward(self, x):
        remove_max = np.exp(x - np.max(x, axis=1, keepdims=True))
        self.output = np.clip(remove_max / np.sum(remove_max, axis=1, keepdims=True), 1e-10, 1.0)
        return self.output


class CrossEntropy:
    output = 0

    # Calculates the loss of the neural network over the whole batch
    def forward(self, res_true, res_prediction):
        self.output = -np.mean(np.sum(res_true * np.log(res_prediction), axis=1))
        return self.output


def class_to_char(class_id):
    if 0 <= class_id <= 9:
        return str(class_id)  # digits
    elif 10 <= class_id <= 35:
        return chr(65 + (class_id - 10))  # uppercase A-Z
    elif 36 <= class_id <= 61:
        return chr(97 + (class_id - 36))  # lowercase a-z
    else:
        return "?"

def preprocess_image(img):
    # img shape: (28,28)
    img = np.rot90(img, -1)  # rotate 90° clockwise
    img = np.fliplr(img)     # flip left-right
    return img

if __name__ == '__main__':
    '''
    ds_train = tfds.load("emnist/byclass", split="train", as_supervised=True)

    ds_train_small = ds_train.shuffle(100000).take(100000)

    X_train = []
    y_train = []
    for image, label in ds_train_small:
        X_train.append(image.numpy())
        y_train.append(label.numpy())

    X_train = np.array(X_train)
    y_train = np.array(y_train)

    # Normalize and reshape for a fully connected network
    X_train = np.array([preprocess_image(x) for x in X_train]).reshape(-1, 28 * 28) / 255.0

    # One-hot encode labels
    y_train = tf.keras.utils.to_categorical(y_train, 62)
    '''

    number_classification = NeuralNetwork(4, 62, 28 * 28)
    #number_classification.train(r"D:\Eliran\eliran\myProject11th\NeuralNetworks\saved_weights.npz", X_train, y_train)
    number_classification.load_model(r"D:\eliran\eliran\myProject11th\NeuralNetworks\saved_weights.npz")

    '''
    picture = X_test[int(input("Enter a number 1-10000 "))]

    number_classification.test_model(picture)
    image = picture.reshape(28, 28)
    plt.imshow(image, cmap='gray')  # 'gray' for grayscale
    plt.show()
    '''

    while True:
        picture = draw()
        number_classification.test_model(picture.reshape(-1, 28 * 28) / 255.0)
