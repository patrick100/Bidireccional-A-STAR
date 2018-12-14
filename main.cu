#include <iostream>
#include "priority_queue.cuh"
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <cuda.h>
#include <device_functions.h>
#include <cuda_runtime_api.h>

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <iostream>

#include <fstream>
#include <string>

using namespace std;


#define NUM_NODES 5

typedef struct
{
    int start;     // Index of first adjacent node in Ea    
    int length;    // Number of adjacent nodes 
} Node2;


__global__ void CUDA_A_STAR_KERNEL(Node2 *Va, int *Ea, bool *Fa, bool *Xa, int *Ca,bool *done)
{

    int id = threadIdx.x + blockIdx.x * blockDim.x;
    if (id > NUM_NODES)
        *done = false;


    if (Fa[id] == true && Xa[id] == false)
    {
        printf("%d ", id); //This printf gives the order of vertices in BFS 
        Fa[id] = false;
        Xa[id] = true;
        __syncthreads(); 
        //int k = 0;
        //int i;
        int start = Va[id].start;
        int end = start + Va[id].length;
        for (int i = start; i < end; i++) 
        {
            int nid = Ea[i];


            //printf(" nid %d\n", nid );
            //cout<<nid<<endl;
            
            if (Xa[nid] == false)
            {
                Ca[nid] = Ca[id] + 1;
                Fa[nid] = true;
                *done = false;
            }

        }

    }

}

const int tam_map = 100;

char m[tam_map][tam_map];

void cargar_mapa(){

    //CARGANDO EL MAPA
  
    //int w, h;

      string line;
      ifstream myfile ("mapa.csv");

      //w = h = tam_map;  
       //vector<vector<char>> mapa(100,vector<char>(100,0));
      int x=0;
      int y=0;
      int value=0;

      if (myfile.is_open())
      {
        while ( getline (myfile,line) )
        {
          if(x<=tam_map-1){

            y=0;
            for (int i = 0; i < line.size(); ++i)
            {
                if(line[i]=='1' || line[i]=='0' ){
                  
                  //mapa[x][y] = line[i];

                  value = (int)line[i] - 48;
                  m[x][y] = value;
                  //cout<<m[x][y]<<" ";
                  y++;  
                }
                
            }
            //cout<<endl;
            //cout <<'\n';
            x++;
          }

        }
        myfile.close();
      }

      else cout << "Unable to open file";

}


__global__ void print_mapGPU(char *map)
{
    // Thread indexing within Grid - note these are
    // in column major order.
    //int tidx = threadIdx.x + blockIdx.x * blockDim.x;
    //int tidy = threadIdx.y + blockIdx.y * blockDim.y;

    // a_ij = a[i][j], where a is in row major order
    //int a_ij = a[tidy +  tidx*N];
    for (int i = 0; i < 20; ++i)
    {
        for (int j = 0; j < 20; ++j)
        {
            printf("%d ", map[i*j]);
        }
        printf("\n");
    }

} 



void print_mapCPU()
{
    for (int i = 0; i < 20; ++i)
    {
        for (int j = 0; j < 20; ++j)
        {
            printf("%d ", m[i][j] );
        }
        printf("\n");
    }
} 


int main(){

    //CARGANDO EL MAPA GPU
    cargar_mapa();


    //Copiar el mapa al device

    char *map;
    //char *map_d;
    const size_t map_size = sizeof(char) * size_t(tam_map*tam_map);
    cudaMalloc((void **)&map, map_size); 
    
    cudaMemcpy(map, m, map_size, cudaMemcpyHostToDevice);

    cout<<"MAP EN CPU: "<<endl;
    print_mapCPU();

    cout<<"MAP EN GPU: "<<endl;
    print_mapGPU<<<1,1>>>(map); 
    cudaDeviceSynchronize();


    //CARGANDO LA PRIORITY QUEUE EN EL KERNEL
    cudaError_t err = cudaSuccess;
    printf("CUDA A START WORKING... \n");
    
    //int num_threads = STR_LENGTH;

    int num_threads = 1;
    int num_blocks = 1;

    int tam = 5;
    //size_t size = tam*sizeof(int);

    size_t size = tam*sizeof(Node);

    //int *nodes_host = malloc(tam * sizeof(int));


    /*
    int* nodes_host = (int*)malloc(size);
    int* nodes_device = (int*)malloc(size);
    */

    Node* nodes_host = (Node*)malloc(size);
    Node* nodes_device = (Node*)malloc(size);

    /*
    Point* start = (Point) malloc(sizeof(*Point));
    start.x = 0; start.y=0;

    //start = {0,0};

    //Point end = (Point)malloc(sizeof(Point));
    //start.x = 100; start.y = 100;

    Point *end = (end*) malloc(sizeof(*end));
    end  = {100,100};
    */


    //size_t tam_node = sizeof(Point);

    //cudaMalloc(&start_d, tam_node);
    //cudaMalloc(&end_d, tam_node);

    cudaMalloc(&nodes_device, size);
    queue<<<num_blocks,num_threads>>>(nodes_device,15);

    //point& s, point& e, map& mp
    //search<<<num_blocks,num_threads>>>(start,end,nodes_device);

    cudaDeviceSynchronize();

    err = cudaMemcpy(nodes_host,nodes_device,size,cudaMemcpyDeviceToHost);

    cudaFree(nodes_device);

    if (err != cudaSuccess)
    {
        fprintf(stderr, "error code %s)!\n", cudaGetErrorString(err));
        //exit(EXIT_FAILURE);
    }

    
    for(int i = 0; i < tam; i++)
	{
	  	printf(" costo:%d distancia:%d posicion:%d,%d  parent:%d,%d  \n", nodes_host[i].cost, nodes_host[i].dist, nodes_host[i].pos.x,nodes_host[i].pos.y , nodes_host[i].parent.x, nodes_host[i].parent.y );
	    //printf(" distancia:%d \n", *(nodes_host[i])->dist);   
    }


}