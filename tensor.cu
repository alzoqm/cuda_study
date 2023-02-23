#include "tensor.h"

using namespace std;


template <typename T>
Tensor<T>::Tensor(initializer_list<uint16_t> shape) // Constructor for the Tensor class
{
    this->dim = static_cast<int8_t>(shape.size()); // Assign the number of dimensions

    // Store the shape information in a vector
    this->tensor_shape = vector<uint16_t>(shape);

    // Calculate the total size of the tensor by multiplying the shape information
    this->sum_size = 1;
    for(int i=0; i<dim; i++)
    {
        this->sum_size = this->sum_size * this->tensor_shape[i];
    }

    // Calculate the number of rows and columns in the tensor
    this->m = this->tensor_shape[this->dim-1];
    this->n = this->sum_size / this->m;

    // Allocate memory for the 'value' array and fill it with 0
    this->value = new T[this->sum_size];
    memset(this->value, 0, sizeof(T)*this->sum_size);

    // Set the 'is_cuda' member to false (indicating that the tensor is not stored on a GPU)
    this->is_cuda = false;
}

template <typename T>
Tensor<T>::Tensor(vector<uint16_t> shape) // Constructor allocation Value to Tensor
{
    this->dim = static_cast<int8_t>(shape.size()); // Assign the number of dimensions

    // Store the shape information in a vector
    this->tensor_shape = vector<uint16_t>(shape);

    // Calculate the total size of the tensor by multiplying the shape information
    this->sum_size = 1;
    for(int i=0; i<dim; i++)
    {
        this->sum_size = this->sum_size * this->tensor_shape[i];
    }

    // Calculate the number of rows and columns in the tensor
    this->m = this->tensor_shape[this->dim-1];
    this->n = this->sum_size / this->m;

    // Allocate memory for the 'value' array and fill it with 0
    this->value = new T[this->sum_size];
    memset(this->value, 0, sizeof(T)*this->sum_size);

    // Set the 'is_cuda' member to false (indicating that the tensor is not stored on a GPU)
    this->is_cuda = false;
}

template <typename T>
Tensor<T>Tensor(initializer_list<T> value, initializer_list<uint16_t> shape)
{
    this->dim = static_cast<int8_t>(shape.size()); // Assign the number of dimensions

    // Store the shape information in a vector
    this->tensor_shape = vector<uint16_t>(shape);

    // Calculate the total size of the tensor by multiplying the shape information
    this->sum_size = 1;
    for(int i=0; i<dim; i++)
    {
        this->sum_size = this->sum_size * this->tensor_shape[i];
    }

    // Calculate the number of rows and columns in the tensor
    this->m = this->tensor_shape[this->dim-1];
    this->n = this->sum_size / this->m;

    // Allocate memory for the 'value' array and copy the values from the input 'value' argument
    this->value = new T[this->sum_size];
    copy(value.begin(), value.end(), this->value);

    // Set the 'is_cuda' member to false (indicating that the tensor is not stored on a GPU)
    this->is_cuda = false;
}

template <typename T>
Tensor(initializer_list<T> value, initializer_list<uint16_t> shape) // Constructor allocation Value to Tensor
{
    this->dim = static_cast<int8_t>(shape.size()); // Assign the number of dimensions

    // Store the shape information in a vector
    this->tensor_shape = vector<uint16_t>(shape);

    // Calculate the total size of the tensor by multiplying the shape information
    this->sum_size = 1;
    for(int i=0; i<dim; i++)
    {
        this->sum_size = this->sum_size * this->tensor_shape[i];
    }

    // Calculate the number of rows and columns in the tensor
    this->m = this->tensor_shape[this->dim-1];
    this->n = this->sum_size / this->m;
    
    // Allocate memory for the 'value' and copy the values from the input 'value' argument
    this->value = new T[this->sum_size];
    for(int i=0; i<this->sum_size; i++)
    {
        this->value[i] = value;
    }
    //memcpy(this->value, value, this->sum_size*sizeof(T));

    // Set the 'is_cuda' member to false (indicating that the tensor is not stored on a GPU)
    this->is_cuda = false;
}

template <typename T>
Tensor<T>::~Tensor() // Destructor for the Tensor class
{   
    if(this->is_cuda==true) // Check if the tensor is stored on a GPU or in CPU memory
    {
        cudaFree(this->value);
        this->value=NULL;
    }
    else // else in cpu
    {
        delete this->value;
        this->value=NULL;
    }
}

template <typename T>
vector<uint16_t> Tensor<T>::shape() // Returns the shape of the Tensor2D as an array of unsigned short integers
{
    return this->tensor_shape;
}

template <typename T>
T *Tensor<T>::return_value() // Returns the value of the Tensor2D as an array of template
{
    T* value = new T[this->sum_size]; // Allocate memory for a temporary value array
    if (this->is_cuda) {
        T* cpu_value = new T[this->sum_size]; // Allocate memory for a temporary CPU value array
        cudaError_t status = cudaMemcpy(cpu_value, this->value, this->sum_size * sizeof(T), cudaMemcpyDeviceToHost); // Copy data from device to host
        if (status != cudaSuccess) {
            cerr << "Error: " << cudaGetErrorString(status) << endl;
            exit(EXIT_FAILURE);
        }
        copy(cpu_value, cpu_value + this->sum_size, value); // Copy the CPU value array to the temporary value array
        delete[] cpu_value; // Free the temporary CPU value array
    } else {
        copy(this->value, this->value + this->sum_size, value); // Copy the value array to the temporary value array
    }
    return value; // Return the temporary value array
}

template <typename T>
void Tensor<T>::print()
{   
    if(this->is_cuda==true)
    {
        this->cpu();
        printf("(value: \n");
        unsigned int *check_size = new unsigned int[this->dim+1];
        for (unsigned int i = 0; i <= this->dim; i++) 
        {
            check_size[i] = 1;
        }
        for(int i=this->dim-1; i>=0; i--)
        {
            check_size[i] = this->tensor_shape[i] * check_size[i+1];
        }
        if(this->n <= 6)
        {
            for(int i=0; i<this->n; i++)
            {
                if(this->m <= 6)
                {
                    for(int j=0; j<this->m; j++)
                    {
                        for(int k=0; k<this->dim; k++)
                        {
                            if((i*this->m+j)%check_size[k]==0)
                            {
                                printf("[");
                            }
                        }
                        cout<<value[i*this->m+j];
                        if(j != this->m-1)
                        {
                            printf(", ");
                        }
                        for(int k=0; k<this->dim; k++)
                        {
                            if((i*this->m+j)%check_size[k] == check_size[k]-1)
                            {
                                printf("]");
                            }
                        }
                    }
                    printf("\n");
                }
                else
                {
                    for(int j=0; j<3; j++)
                    {
                        for(int k=0; k<this->dim; k++)
                        {
                            if((i*this->m+j)%check_size[k]==0)
                            {
                                printf("[");
                            }
                        }
                        cout<<value[i*this->m+j];
                        printf(", ");
                    }
                    printf("..... ");
                    for(int j=this->m-3; j<this->m; j++)
                    {
                        cout<<value[i*this->m+j];
                        if(j != this->m-1)
                        {
                            printf(", ");
                        }
                        for(int k=0; k<this->dim; k++)
                        {
                            if((i*this->m+j)%check_size[k] == check_size[k]-1)
                            {
                                printf("]");
                            }
                        }
                    }
                    printf("\n");
                }
            }
        }
        else
        {
            for(int i=0; i<3; i++)
            {
                if(this->m <= 6)
                {
                    for(int j=0; j<this->m; j++)
                    {
                        for(int k=0; k<this->dim; k++)
                        {
                            if((i*this->m+j)%check_size[k]==0)
                            {
                                printf("[");
                            }
                        }
                        cout<<value[i*this->m+j];
                        if(j != this->m-1)
                        {
                            printf(", ");
                        }
                        for(int k=0; k<this->dim; k++)
                        {
                            if((i*this->m+j)%check_size[k] == check_size[k]-1)
                            {
                                printf("]");
                            }
                        }
                    }
                    printf("\n");
                }
                else
                {
                    for(int j=0; j<3; j++)
                    {
                        for(int k=0; k<this->dim; k++)
                        {
                            if((i*this->m+j)%check_size[k]==0)
                            {
                                printf("[");
                            }
                        }
                        cout<<value[i*this->m+j];
                        printf(", ");
                    }
                    printf("..... ");
                    for(int j=this->m-3; j<this->m; j++)
                    {
                        cout<<value[i*this->m+j];
                        if(j != this->m-1)
                        {
                            printf(", ");
                        }
                        for(int k=0; k<this->dim; k++)
                        {
                            if((i*this->m+j)%check_size[k] == check_size[k]-1)
                            {
                                printf("]");
                            }
                        }
                    }
                    printf("\n");
                }
            }
            printf(". . .\n");
            printf(". . .\n");
            for(int i=this->n-3; i<this->n; i++)
            {
                if(this->m <= 6)
                {
                    for(int j=0; j<this->m; j++)
                    {
                        for(int k=0; k<this->dim; k++)
                        {
                            if((i*this->m+j)%check_size[k]==0)
                            {
                                printf("[");
                            }
                        }
                        cout<<value[i*this->m+j];
                        if(j != this->m-1)
                        {
                            printf(", ");
                        }
                        for(int k=0; k<this->dim; k++)
                        {
                            if((i*this->m+j)%check_size[k] == check_size[k]-1)
                            {
                                printf("]");
                            }
                        }
                    }
                    printf("\n");
                }
                else
                {
                    for(int j=0; j<3; j++)
                    {
                        for(int k=0; k<this->dim; k++)
                        {
                            if((i*this->m+j)%check_size[k]==0)
                            {
                                printf("[");
                            }
                        }
                        cout<<value[i*this->m+j];
                        printf(", ");
                    }
                    printf("....., ");
                    for(int j=this->m-3; j<this->m; j++)
                    {
                        cout<<value[i*this->m+j];
                        if(j != this->m-1)
                        {
                            printf(", ");
                        }
                        for(int k=0; k<this->dim; k++)
                        {
                            if((i*this->m+j)%check_size[k] == check_size[k]-1)
                            {
                                printf("]");
                            }
                        }
                    }
                    printf("\n");
                }
            }
        }
        printf("shape: (");
        for(int i=0; i<this->dim; i++)
        {
            printf("%d", this->tensor_shape[i]);
            if(i!=this->dim-1)
            {
                printf(", ");
            }
        }
        printf(")\n");
        this->cuda();
        cout<<"is_cuda: "<<this->is_cuda<<")\n";
    }
    else
    {
        printf("(value: \n");
        unsigned int *check_size = new unsigned int[this->dim+1];
        for (unsigned int i = 0; i <= this->dim; i++) 
        {
            check_size[i] = 1;
        }
        for(int i=this->dim-1; i>=0; i--)
        {
            check_size[i] = this->tensor_shape[i] * check_size[i+1];
        }
        if(this->n <= 6)
        {
            for(int i=0; i<this->n; i++)
            {
                if(this->m <= 6)
                {
                    for(int j=0; j<this->m; j++)
                    {
                        for(int k=0; k<this->dim; k++)
                        {
                            if((i*this->m+j)%check_size[k]==0)
                            {
                                printf("[");
                            }
                        }
                        cout<<value[i*this->m+j];
                        if(j != this->m-1)
                        {
                            printf(", ");
                        }
                        for(int k=0; k<this->dim; k++)
                        {
                            if((i*this->m+j)%check_size[k] == check_size[k]-1)
                            {
                                printf("]");
                            }
                        }
                    }
                    printf("\n");
                }
                else
                {
                    for(int j=0; j<3; j++)
                    {
                        for(int k=0; k<this->dim; k++)
                        {
                            if((i*this->m+j)%check_size[k]==0)
                            {
                                printf("[");
                            }
                        }
                        cout<<value[i*this->m+j];
                        printf(", ");
                    }
                    printf("....., ");
                    for(int j=this->m-3; j<this->m; j++)
                    {
                        cout<<value[i*this->m+j];
                        if(j != this->m-1)
                        {
                            printf(", ");
                        }
                        for(int k=0; k<this->dim; k++)
                        {
                            if((i*this->m+j)%check_size[k] == check_size[k]-1)
                            {
                                printf("]");
                            }
                        }
                    }
                    printf("\n");
                }
            }
        }
        else
        {
            for(int i=0; i<3; i++)
            {
                if(this->m <= 6)
                {
                    for(int j=0; j<this->m; j++)
                    {
                        for(int k=0; k<this->dim; k++)
                        {
                            if((i*this->m+j)%check_size[k]==0)
                            {
                                printf("[");
                            }
                        }
                        cout<<value[i*this->m+j];
                        if(j != this->m-1)
                        {
                            printf(", ");
                        }
                        for(int k=0; k<this->dim; k++)
                        {
                            if((i*this->m+j)%check_size[k] == check_size[k]-1)
                            {
                                printf("]");
                            }
                        }
                    }
                    printf("\n");
                }
                else
                {
                    for(int j=0; j<3; j++)
                    {
                        for(int k=0; k<this->dim; k++)
                        {
                            if((i*this->m+j)%check_size[k]==0)
                            {
                                printf("[");
                            }
                        }
                        cout<<value[i*this->m+j];
                        printf(", ");
                    }
                    printf("....., ");
                    for(int j=this->m-3; j<this->m; j++)
                    {
                        cout<<value[i*this->m+j];
                        if(j != this->m-1)
                        {
                            printf(", ");
                        }
                        for(int k=0; k<this->dim; k++)
                        {
                            if((i*this->m+j)%check_size[k] == check_size[k]-1)
                            {
                                printf("]");
                            }
                        }
                    }
                    printf("\n");
                }
            }
            printf(". . .\n");
            printf(". . .\n");
            for(int i=this->n-3; i<this->n; i++)
            {
                if(this->m <= 6)
                {
                    for(int j=0; j<this->m; j++)
                    {
                        for(int k=0; k<this->dim; k++)
                        {
                            if((i*this->m+j)%check_size[k]==0)
                            {
                                printf("[");
                            }
                        }
                        cout<<value[i*this->m+j];
                        if(j != this->m-1)
                        {
                            printf(", ");
                        }
                        for(int k=0; k<this->dim; k++)
                        {
                            if((i*this->m+j)%check_size[k] == check_size[k]-1)
                            {
                                printf("]");
                            }
                        }
                    }
                    printf("\n");
                }
                else
                {
                    for(int j=0; j<3; j++)
                    {
                        for(int k=0; k<this->dim; k++)
                        {
                            if((i*this->m+j)%check_size[k]==0)
                            {
                                printf("[");
                            }
                        }
                        cout<<value[i*this->m+j];
                        printf(", ");
                    }
                    printf("....., ");
                    for(int j=this->m-3; j<this->m; j++)
                    {
                        cout<<value[i*this->m+j];
                        if(j != this->m-1)
                        {
                            printf(", ");
                        }
                        for(int k=0; k<this->dim; k++)
                        {
                            if((i*this->m+j)%check_size[k] == check_size[k]-1)
                            {
                                printf("]");
                            }
                        }
                    }
                    printf("\n");
                }
            }
        }
        printf("shape: (");
        for(int i=0; i<this->dim; i++)
        {
            printf("%d", this->tensor_shape[i]);
            if(i!=this->dim-1)
            {
                printf(", ");
            }
        }
        printf(")\n");
        cout<<"is_cuda: "<<this->is_cuda<<")\n";
    }
}

template <typename T>
void Tensor<T>::cuda() // Copy the tensor data from the CPU memory to the GPU memory.
    {
        if(this->is_cuda==true)
        {
            return;
        }
        // Allocate temporary memory on the GPU to store the tensor data
        cudaMalloc((void**)&this->temp_value, sizeof(T)*this->sum_size); 
        // Copy the tensor data from the CPU memory to the temporary GPU memory
        cudaMemcpy(this->temp_value, this->value, sizeof(T)*this->sum_size, cudaMemcpyHostToDevice);
        delete this->value; // Delete the original tensor data in the CPU memory

        // Allocate memory on the GPU to store the tensor data
        cudaMalloc((void**)&this->value, sizeof(T)*this->sum_size);
        // Copy the tensor data from the temporary GPU memory to the GPU memory
        cudaMemcpy(this->value, this->temp_value, sizeof(T)*this->sum_size, cudaMemcpyDeviceToDevice);
        // Free the temporary GPU memory
        cudaFree(this->temp_value);
        // Update the flag to indicate that the tensor data is now stored on the GPU
        this->is_cuda = true;
    }

template <typename T>
void Tensor<T>::cpu() // allocate the tensor data from the GPU memory to the CPU memory.
{
    if(this->is_cuda==false)
    {
        return;
    }
    // Allocate temporary memory on the CPU to store the tensor data
    this->temp_value = new T[this->sum_size];
    // Copy the tensor data from the GPU memory to the temporary CPU memory
    cudaMemcpy(this->temp_value, this->value, sizeof(T)*this->sum_size, cudaMemcpyDeviceToHost);
    cudaFree(this->value); // Free the GPU memory

    // Allocate memory on the CPU to store the tensor data
    this->value = new T[this->sum_size];
    // Copy the tensor data from the temporary CPU memory to the CPU memory
    memcpy(this->value, this->temp_value, this->sum_size*sizeof(T));
    // Delete the temporary CPU memory
    delete this->temp_value;
    // Update the flag to indicate that the tensor data is now stored on the CPU
    this->is_cuda = false;
}

template <typename T>
void Tensor<T>::squeeze(int dim=300) // Later, change default value custom NoneType
{
    if(dim==300)
    {
        if(this->sum_size==1)
        {
            this->dim = 1;
            this->tensor_shape = {1};
            return;
        }

        int one_dim_cnt=0;
        for(int i=0; i<this->dim; i++)
        {
            if(this->tensor_shape[i] == 1)
            {
                one_dim_cnt += 1;
            }
        }
        if(one_dim_cnt==0)
        {
            return;
        }

        vector<uint16_t> temp_tensor_shape(this->dim-one_dim_cnt);
        int cnt=0;
        for(int i=0; i<this->dim; i++)
        {
            if(this->tensor_shape[i] != 1)
            {
                temp_tensor_shape[cnt] = this->tensor_shape[i];
                cnt += 1;
            }
        }

        this->dim = this->dim-one_dim_cnt;
        this->tensor_shape = move(temp_tensor_shape);

        return;
    }
    else
    {
        if(dim < 0)
        {
            dim = this->dim+dim;
        }
        if(this->tensor_shape[dim] != 1)
        {
            throw invalid_argument("tensor.tensor_shape[argument] is not 1\n");
        }
        vector<uint16_t> temp_tensor_shape(this->dim-1);
        int cnt = 0;
        for(int i=0; i<this->dim; i++)
        {
            if(i==dim)
            {
                continue;
            }
            temp_tensor_shape[cnt] = this->tensor_shape[i];
            cnt += 1;
        }
        this->dim = this->dim-1;
        this->tensor_shape = move(temp_tensor_shape);
        return;
    }
}

template <typename T>
void Tensor<T>::unsqueeze(int dim)
{
    if(dim < 0)
    {
        dim = this->dim + 1 + dim;
    }
    if(dim > this->dim+1)
    {
        throw invalid_argument("argument > this->dim+1\n");
    }

    vector<uint16_t> temp_tensor_shape(this->dim + 1);
    int cnt = 0;
    for(int i=0; i<this->dim+1; i++)
    {
        if(dim==i)
        {
            temp_tensor_shape[i] = 1;
        }
        else
        {
            temp_tensor_shape[i] = this->tensor_shape[cnt];
            cnt+=1;
        }
    }
    this->dim += 1;
    this->tensor_shape = move(temp_tensor_shape);
}

template <typename T>
void Tensor<T>::reshape(initializer_list<int16_t> reshape_array)
{
    int temp_reshape_sum = 1;
    uint32_t reshape_sum = 1;
    int8_t m1_check = 0; // -1 check
    int8_t m1_index = -1;
    int dim = reshape_array.size();

    short* array_ptr = new short[dim];
    copy(reshape_array.begin(), reshape_array.end(), array_ptr);

    for (int i = 0; i < dim; i++)
    {
        if (array_ptr[i] == -1)
        {
            m1_check += 1;
            m1_index = i;
        }
        temp_reshape_sum *= array_ptr[i];
    }

    if (m1_check >= 2)
    {
        throw runtime_error("The value '-1' can only be used once.\n");
    }

    if (temp_reshape_sum < 0) // using -1
    {
        reshape_sum = (-temp_reshape_sum);

        if (this->sum_size % reshape_sum != 0)
        {
            throw runtime_error("The total size of the original tensor and the size of the newly defined shape must be the same.1\n");
        }

        short m1_value = this->sum_size / reshape_sum;
        array_ptr[m1_index] = m1_value;
        reshape_sum *= array_ptr[m1_index];
    }
    else
    {
        reshape_sum = temp_reshape_sum;
    }

    if (this->sum_size != reshape_sum)
    {
        throw runtime_error("The total size of the original tensor and the size of the newly defined shape must be the same.\n");
    }

    this->dim = dim;
    this->tensor_shape.clear();
    this->tensor_shape.reserve(dim);
    copy(array_ptr, array_ptr + dim, back_inserter(this->tensor_shape));

    delete[] array_ptr;
}