# RTL Implementation of Motor Control ANN
This repository contains a Verilog implementation of a hardware accelerator for a multi-layer perceptron neural network. The design is optimized for real-time motor control, specifically predicting Pulse Width Modulation signals based on motor telemetry.

## Architecture Overview
The accelerator computes inference for a fully connected neural network using a time-multiplexed datapath. It processes four normalized input features: Speed Reference, Speed, Current, and Bus Voltage, to output a single PWM prediction.

## Hardware Specifications
* Data Format: 16-bit Fixed-Point (Q4.12)
* Inference Latency: 68 clock cycles per prediction
* Core Components:
  * Controller: Finite State Machine managing the pipelined routing
  * MAC Unit: Multiply-Accumulate block for continuous vector dot products
  * ROM: Stores pre-trained, quantized network weights and biases
  * RAM: Temporary storage for hidden layer activations

## Statistical Metrics
* Mean Absolute Error: 0.046425
* Root Mean Squared Error: 0.052058
