+++
title = 'Cuda实现CNN推理与卷积'
date = 2023-10-17T10:31:05+08:00
draft = true
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
