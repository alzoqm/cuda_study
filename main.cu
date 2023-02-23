#include "tensor.h"
#include "matOper.h"

__host__ int main()
{
srand(time(NULL));
    Tensor<float> tensor1(2, {3, 512, 256});
    Tensor<float> tensor2(1, {3, 256, 128});
    Tensor<float> tensor3({3, 512, 128});
    Tensor<float> tensor3_cpu({3, 512, 128});
    Tensor<float> tensor4(3, {128});
    clock_t cpu_start = clock();
    mat_mul(tensor1, tensor2, tensor3_cpu);
    clock_t cpu_end = clock();
    double cpu_time = (double)(cpu_end - cpu_start) / CLOCKS_PER_SEC;

    size_t before_free, before_total;
    cudaMemGetInfo(&before_free, &before_total);
    printf("Total GPU memory: %lu MB\nbefore Free GPU memory: %lu MB\n", before_total/1000000, before_free/1000000);
    
    clock_t compile_start = clock();
    tensor1.cuda();
    tensor2.cuda();
    tensor3.cuda();
    tensor4.cuda();
    clock_t compile_end = clock();
    double compile_time = (double)(compile_end - compile_start) / CLOCKS_PER_SEC;

    size_t free, total;
    cudaMemGetInfo(&free, &total);
    printf("after Free GPU memory: %lu MB\n", free/1000000);
    printf("diff before after memory: %lu MB\n\n", before_free/1000000- free/1000000);

    clock_t gpu_start = clock();
    mat_mul(tensor1, tensor2, tensor3);
    matadd(tensor3, tensor4, tensor3);
    clock_t gpu_end = clock();
    double gpu_time = (double)(gpu_end - gpu_start) / CLOCKS_PER_SEC;

    printf("cpu_time: %f\n", cpu_time);
    printf("GPU compile time: %f\n", compile_time);
    printf("GPU time: %f\n", gpu_time);
    printf("GPU sum time: %f\n", compile_time+gpu_time);
    printf("\n");
    tensor3_cpu.print();
    tensor3.print();

    return 0;
}
