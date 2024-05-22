+++
title = 'Cuda实现CNN推理与卷积'
date = 2023-10-17T10:31:05+08:00
draft = true
tags = ["课程作业"]
+++

# 导语

ucas 2023 赵地老师GPU架构与编程课程大作业一

要求：cuda不调库实现CNN推理 加分：cuda不调库实现CNN训练

# 分析

实现CNN推理的话应该只需要用cuda实现CNN的正向传播，训练就都得实现。

参考一下[LeNet5_CNN](https://github.com/aammya8/LeNet5_CNN)

这个项目大概是ece408课程的大作业，就是直接实现了LeNet5

然后他的Makefile对编译的每个东西都include了一个[libgputk](https://github.com/KastnerRG/cse160-WI23/tree/315bf09ecd72973ba1e2a461844d10349751f08c/libgputk#libgputk)，应该是他们课程给的一个用来调试的库，直接全删了依然可以编译。

然后再按照课程要求，在每个nvcc命令后面加上编译选项 `-Xcompiler "-O3 -std=c++14" -gencode arch=compute_60,code=sm_60 -gencode arch=compute_61,code=sm_61 -gencode arch=compute_70,code=sm_70 -rdc=true`

# 源码分析

makefile如下

```makefile
m2:		m2.o custom
		nvcc -o m2 -lm -lcuda -lrt m2.o ece408net.o src/network.o src/mnist.o src/layer/*.o src/loss/*.o src/layer/custom/*.o -I./ -Xcompiler "-O3 -std=c++14" -gencode arch=compute_60,code=sm_60 -gencode arch=compute_61,code=sm_61 -gencode arch=compute_70,code=sm_70 -rdc=true

m2.o:		m2.cc
		nvcc --compile m2.cc  -I./ -Xcompiler "-O3 -std=c++14" -gencode arch=compute_60,code=sm_60 -gencode arch=compute_61,code=sm_61 -gencode arch=compute_70,code=sm_70 -rdc=true

ece408net.o:    ece408net.cc
		nvcc --compile ece408net.cc  -I./ -Xcompiler "-O3 -std=c++14" -gencode arch=compute_60,code=sm_60 -gencode arch=compute_61,code=sm_61 -gencode arch=compute_70,code=sm_70 -rdc=true

network.o:	src/network.cc
		nvcc --compile src/network.cc -o src/network.o  -I./ -Xcompiler "-O3 -std=c++14" -gencode arch=compute_60,code=sm_60 -gencode arch=compute_61,code=sm_61 -gencode arch=compute_70,code=sm_70 -rdc=true

mnist.o:	src/mnist.cc
		nvcc --compile src/mnist.cc -o src/mnist.o  -I./ -Xcompiler "-O3 -std=c++14" -gencode arch=compute_60,code=sm_60 -gencode arch=compute_61,code=sm_61 -gencode arch=compute_70,code=sm_70 -rdc=true

layer:		src/layer/conv.cc src/layer/ave_pooling.cc src/layer/conv_cpu.cc src/layer/conv_cust.cc src/layer/fully_connected.cc src/layer/max_pooling.cc src/layer/relu.cc src/layer/sigmoid.cc src/layer/softmax.cc 
		nvcc --compile src/layer/ave_pooling.cc -o src/layer/ave_pooling.o  -I./ -Xcompiler "-O3 -std=c++14" -gencode arch=compute_60,code=sm_60 -gencode arch=compute_61,code=sm_61 -gencode arch=compute_70,code=sm_70 -rdc=true
		nvcc --compile src/layer/conv.cc -o src/layer/conv.o  -I./ -Xcompiler "-O3 -std=c++14" -gencode arch=compute_60,code=sm_60 -gencode arch=compute_61,code=sm_61 -gencode arch=compute_70,code=sm_70 -rdc=true
		nvcc --compile src/layer/conv_cpu.cc -o src/layer/conv_cpu.o  -I./ -Xcompiler "-O3 -std=c++14" -gencode arch=compute_60,code=sm_60 -gencode arch=compute_61,code=sm_61 -gencode arch=compute_70,code=sm_70 -rdc=true
		nvcc --compile src/layer/conv_cust.cc -o src/layer/conv_cust.o  -I./ -Xcompiler "-O3 -std=c++14" -gencode arch=compute_60,code=sm_60 -gencode arch=compute_61,code=sm_61 -gencode arch=compute_70,code=sm_70 -rdc=true
		nvcc --compile src/layer/fully_connected.cc -o src/layer/fully_connected.o  -I./ -Xcompiler "-O3 -std=c++14" -gencode arch=compute_60,code=sm_60 -gencode arch=compute_61,code=sm_61 -gencode arch=compute_70,code=sm_70 -rdc=true
		nvcc --compile src/layer/max_pooling.cc -o src/layer/max_pooling.o  -I./ -Xcompiler "-O3 -std=c++14" -gencode arch=compute_60,code=sm_60 -gencode arch=compute_61,code=sm_61 -gencode arch=compute_70,code=sm_70 -rdc=true
		nvcc --compile src/layer/relu.cc -o src/layer/relu.o  -I./ -Xcompiler "-O3 -std=c++14" -gencode arch=compute_60,code=sm_60 -gencode arch=compute_61,code=sm_61 -gencode arch=compute_70,code=sm_70 -rdc=true
		nvcc --compile src/layer/sigmoid.cc -o src/layer/sigmoid.o  -I./ -Xcompiler "-O3 -std=c++14" -gencode arch=compute_60,code=sm_60 -gencode arch=compute_61,code=sm_61 -gencode arch=compute_70,code=sm_70 -rdc=true
		nvcc --compile src/layer/softmax.cc -o src/layer/softmax.o  -I./ -Xcompiler "-O3 -std=c++14" -gencode arch=compute_60,code=sm_60 -gencode arch=compute_61,code=sm_61 -gencode arch=compute_70,code=sm_70 -rdc=true

custom:
		nvcc --compile src/layer/custom/cpu-new-forward.cc -o src/layer/custom/cpu-new-forward.o  -I./ -Xcompiler "-O3 -std=c++14" -gencode arch=compute_60,code=sm_60 -gencode arch=compute_61,code=sm_61 -gencode arch=compute_70,code=sm_70 -rdc=true
		nvcc --compile src/layer/custom/gpu-utils.cu -o src/layer/custom/gpu-utils.o  -I./ -Xcompiler "-O3 -std=c++14" -gencode arch=compute_60,code=sm_60 -gencode arch=compute_61,code=sm_61 -gencode arch=compute_70,code=sm_70 -rdc=true
		nvcc --compile src/layer/custom/gpu-new-forward-optimized.cu -o src/layer/custom/gpu-new-forward-optimized.o  -I./ -Xcompiler "-O3 -std=c++14" -gencode arch=compute_60,code=sm_60 -gencode arch=compute_61,code=sm_61 -gencode arch=compute_70,code=sm_70 -rdc=true

loss:           src/loss/cross_entropy_loss.cc src/loss/mse_loss.cc 
		nvcc --compile src/loss/cross_entropy_loss.cc -o src/loss/cross_entropy_loss.o  -I./ -Xcompiler "-O3 -std=c++14" -gencode arch=compute_60,code=sm_60 -gencode arch=compute_61,code=sm_61 -gencode arch=compute_70,code=sm_70 -rdc=true
		nvcc --compile src/loss/mse_loss.cc -o src/loss/mse_loss.o  -I./ -Xcompiler "-O3 -std=c++14" -gencode arch=compute_60,code=sm_60 -gencode arch=compute_61,code=sm_61 -gencode arch=compute_70,code=sm_70 -rdc=true


clean:
		rm m2
		rm m2.o

run: 		m2
		./m2 1000

```

最终得到的可执行文件是m2，是m2.o和ece408net.o组成的，先查看一下生成m2.o的源码m2.cc

```cpp
#include "ece408net.h"

void inference_only(int batch_size) {

  std::cout<<"Loading fashion-mnist data...";
  MNIST dataset("./data/"); # class MNIST定义在minst.h里
  dataset.read_test_data(batch_size);
  std::cout<<"Done"<<std::endl;
  
  std::cout<<"Loading model...";
  Network dnn = createNetwork_GPU(); # 通过createNetworkGPU来建立dnn模型
  std::cout<<"Done"<<std::endl;

  dnn.forward(dataset.test_data); # 进行正向传播，得到结果
  float acc = compute_accuracy(dnn.output(), dataset.test_labels);
  std::cout<<std::endl;
  std::cout<<"Test Accuracy: "<<acc<< std::endl;
  std::cout<<std::endl;
}

int main(int argc, char* argv[]) {

  int batch_size = 10000;
  
  if(argc == 2){
    batch_size = atoi(argv[1]);
  }

  std::cout<<"Test batch size: "<<batch_size<<std::endl;
  inference_only(batch_size);

  return 0;
}

```

追踪一下控制流把。

## 读取数据集

首先是读取dataset，定义了一个MNIST类，在minst.h和minst.cc里声明和实现

mnist.h

```cpp
#ifndef SRC_MNIST_H_
#define SRC_MNIST_H_

#include <fstream>
#include <iostream>
#include <string>
#include "./utils.h"

class MNIST {
 private:
  std::string data_dir;

 public:
  Matrix train_data;
  Matrix train_labels;
  Matrix test_data;
  Matrix test_labels;

  void read_mnist_data(std::string filename, Matrix& data, int batch_size=-1);
  void read_mnist_label(std::string filename, Matrix& labels, int batch_size=-1);

  explicit MNIST(std::string data_dir) : data_dir(data_dir) {}
  void read();
  void read_test_data(int batch_size); 
};

#endif  // SRC_MNIST_H_

```

`explicit MNIST(std::string data_dir) : data_dir(data_dir) {}` 是MNIST类的构造函数，接受一个string类型的data_dir，并使用成员初始化列表将该参数的值赋给 `data_dir` 成员变量，且构造函数体为空，即构造的时候不做其他操作（cpp苦手），在代码里使用 `MNIST dataset('./data')`就是给dataset的对象的private变量data_dir赋值为 `./data`explicit声明是要求cpp不要进行强制类型转换

**成员初始化列表**

```cpp
class MyClass {
public:
    // 成员初始化列表初始化成员变量 x 和 y
    MyClass(int a, int b) : x(a), y(b) {
        // 构造函数体（如果需要）
        // 可以在这里执行其他操作
    }

private:
    int x;
    int y;
};
```

语法类似上面，给private赋值



然后使用MNIST类的read_test_data()方法读取数据集

```cpp
void MNIST::read_test_data(int batch_size) {
  read_mnist_data(data_dir + "t10k-86-images-idx3-ubyte", test_data, batch_size);
  read_mnist_label(data_dir + "t10k-86-labels-idx1-ubyte", test_labels, batch_size);
}
```

使用read_mnist_data方法读取ubyte数据集

```cpp
void MNIST::read_mnist_data(std::string filename, Matrix& data, int batch_size) {
  std::ifstream file(filename, std::ios::binary);
  // std::cout<<"Reading: "<<filename<<std::endl;
  if (file.is_open()) {
    int magic_number = 0;
    int number_of_images = 0;
    int n_rows = 0;
    int n_cols = 0;
    unsigned char label;
    file.read((char*)&magic_number, sizeof(magic_number));
    file.read((char*)&number_of_images, sizeof(number_of_images));
    file.read((char*)&n_rows, sizeof(n_rows));
    file.read((char*)&n_cols, sizeof(n_cols));
    //magic_number = ReverseInt(magic_number);
    //number_of_images = ReverseInt(number_of_images);
    //n_rows = ReverseInt(n_rows);
    //n_cols = ReverseInt(n_cols);

    if (batch_size > 0 && batch_size < number_of_images){
      number_of_images = batch_size;
    }

    // std::cout<<number_of_images<<","<<n_rows<<","<<n_cols<<std::endl;
    data.resize(n_cols * n_rows, number_of_images);
    for (int i = 0; i < number_of_images; i++) {
      for (int r = 0; r < n_rows; r++) {
        for (int c = 0; c < n_cols; c++) {
          unsigned char image = 0;
          file.read((char*)&image, sizeof(image));
          data(r * n_cols + c, i) = (float)image;
        }
      }
    }
  }
}
```

这里要说一下MNIST的ubyte数据集的结构

* 前4个字节：魔数（Magic Number） - 一个32位整数，用于标识文件的类型。
* 接下来4个字节：图像数量（Number of Images） - 一个32位整数，指示文件中包含的图像数量。
* 接下来4个字节：图像的行数（Number of Rows） - 一个32位整数，表示每个图像的行数。
* 接下来4个字节：图像的列数（Number of Columns） - 一个32位整数，表示每个图像的列数。
* 接下来的字节：图像数据 - 连续的字节序列，每个字节表示一个像素的灰度值，通常是8位的无符号字符。图像数据以行为主排列，依次为每个图像的每一行。

转为float的是CNN的需求，能够方便范围与归一化、求导和反向传播以及激活函数的非线性需求

## 读取模型

`Network dnn=createNetwork_GPU();`用来读取模型，Network类在network.h和network.cc声明与实现

```cpp
#ifndef SRC_NETWORK_H_
#define SRC_NETWORK_H_

#include <stdlib.h>
#include <vector>
#include <string>
#include <fstream>
#include "./layer.h"
#include "./loss.h"
#include "./optimizer.h"
#include "./utils.h"

class Network {
 private:
  std::vector<Layer*> layers;  // layer pointers
  Loss* loss;  // loss pointer
  float BIN_FILE_DELIM = 0xFFFFFFFF;

 public:
  Network() : loss(NULL) {}
  ~Network() {
    for (int i = 0; i < layers.size(); i ++) {
      delete layers[i];
    }
    if (loss) {
      delete loss;
    }
  }

  void add_layer(Layer* layer) { layers.push_back(layer); }
  void add_loss(Loss* loss_in) { loss = loss_in; }

  void forward(const Matrix& input);
  void backward(const Matrix& input, const Matrix& target);
  void update(Optimizer& opt);

  const Matrix& output() { return layers.back()->output(); }
  float get_loss() { return loss->output(); }
  /// Get the serialized layer parameters
  std::vector<std::vector<float> > get_parameters() const;
  /// Set the layer parameters
  void set_parameters(const std::vector< std::vector<float> >& param);
  /// Get the serialized derivatives of layer parameters
  std::vector<std::vector<float> > get_derivatives() const;
  /// Debugging tool to check parameter gradients
  void check_gradient(const Matrix& input, const Matrix& target, int n_points,
                      int seed = -1);
  void save_parameters(std::string filename);
  void load_parameters(std::string filename);
};

#endif  // SRC_NETWORK_H_

```

这里定义了Network的构造函数和析构函数，在创建Network的对象时将private变量loss设置为null，也就是不设置模型的损失函数，用delete将Network对象析构

而 `createNetwork_GPU()` 方法在ece408net.cc中实现

```cpp
Network createNetwork_GPU()
{
  Network dnn;

  Layer* conv1 = new Conv_Custom(1, 86, 86, 4, 7, 7);
  Layer* pool1 = new MaxPooling(4, 80, 80, 2, 2, 2);
  Layer* conv2 = new Conv_Custom(4, 40, 40, 16, 7, 7);
  Layer* pool2 = new MaxPooling(16, 34, 34, 4, 4, 4);
  Layer* fc3 = new FullyConnected(pool2->output_dim(), 32);
  Layer* fc4 = new FullyConnected(32, 10);
  Layer* relu1 = new ReLU;
  Layer* relu2 = new ReLU;
  Layer* relu3 = new ReLU;
  Layer* softmax = new Softmax;
  dnn.add_layer(conv1);
  dnn.add_layer(relu1);
  dnn.add_layer(pool1);
  dnn.add_layer(conv2);
  dnn.add_layer(relu2);
  dnn.add_layer(pool2);
  dnn.add_layer(fc3);
  dnn.add_layer(relu3);
  dnn.add_layer(fc4);
  dnn.add_layer(softmax);
  // loss
  Loss* loss = new CrossEntropy;
  dnn.add_loss(loss);

  //load weights
  dnn.load_parameters("./build/weights-86.bin");

  return dnn;
}
```
