// C code to implement Priority Queue
// using Linked List
#include <stdio.h>
#include <stdlib.h>

//#define min(a, b) ((a) < (b) ? (a) : (b))
//#define max(a, b) ((a) > (b) ? (a) : (b))


typedef struct point {
    int x; 
    int y;   
} Point;


__device__ Point newPoint(int a,int b){
    
    Point my_point = {a,b};
    return my_point;
}

/*sobrecarga de funciones */
__device__ bool equal_point(Point &a, const Point &b){
    if(a.x==b.x && a.y==b.y)
        return true;
    else
        return false;
}

__device__ void sum_point(Point &a,const Point &b){
    a.x += b.x;a.y += b.y;
}



 
// Node
typedef struct node {
    Point pos, parent;
    int dist, cost;
    struct node* next;
 
} Node;


 
// Function to Create A New Node
__device__ Node* newNode(int cost, int dist,const Point &pos, const Point &parent)
{
    Node* temp = (Node*)malloc(sizeof(Node));
    
    temp->cost = cost;
    temp->dist = dist;
    temp->pos = pos;
    temp->parent = parent;
    temp->next = NULL;
 
    return temp;
}
 
// Return the value at head
int peek(Node** head)
{
    return (*head)->dist;
}
 
// Removes the element with the
// highest priority form the list
void pop(Node** head)
{
    Node* temp = *head;
    (*head) = (*head)->next;
    free(temp);
}
 
// Function to push according to priority
__device__ void push(Node** head,Node *temp)
{
    Node* start = (*head);
 
    // Create new Node
    //Node* temp = newNode(d, p);
 
    // Special Case: The head of list has lesser
    // priority than new node. So insert new
    // node before head node and change head node.
    if ((*head)->dist > temp->dist) {
 
        // Insert New Node before head
        temp->next = *head;
        (*head) = temp;
    }
    else {
 
        // Traverse the list and find a
        // position to insert new node
        while (start->next != NULL && start->next->dist < temp->dist) {
            start = start->next;
        }
 
        // Either at the ends of the list
        // or at required position
        temp->next = start->next;
        start->next = temp;
    }
}
 
// Function to check is list is empty
int isEmpty(Node** head)
{
    return (*head) == NULL;
}


//__device__ const char *STR = "HELLO WORLD!";
//const char STR_LENGTH = 12;



__device__ Node* pq;

__device__ Point start_d;

__device__ Point end_d;





//__device__ Node *(nodes_device[5]);

//__device__ int nodes_device[5];

//__device__ int *nodes_device = malloc(5 * sizeof *ptr);

//__device__ int* nodes_device = (int*)malloc(5*sizeof(int));

__device__ void save(Node *nodes_device){

	  printf("GUARDANDO NODOS EN GPU\n");

	  int tams = (int)( sizeof(nodes_device) / sizeof(nodes_device[0]));
	  //printf("TAM: %d\n", tams);

	  int i=0;

      nodes_device[i] = *pq;
	  //nodes_device[i] = pq->dist;



	  //printf("%d\n", pq->data );

	  while (pq->next != NULL) {
         //start = start->next;
         i++;
         nodes_device[i]= *pq->next;
         //nodes_device[i]= pq->next->dist;
         //printf("%d\n", pq->next->data);
         pq = pq->next;
      }

      for (int i = 0; i < tams; ++i)
      {
      	  printf("%d\n", nodes_device[i]);
      }

      printf("RECUPERANDO NODOS EN CPU\n");

}



//int *nodes_device

__global__ void queue(Node *nodes_device, int a)
{
    //printf("%c\n", STR[threadIdx.x % STR_LENGTH]);
    //Node* pq = newNode(4, 1);
    
    //calculardist()
    //newNode(int cost, int dist,Point &pos, Point &parent)
    pq = newNode(0, 14, newPoint(0,0), newPoint(0,0));
    
    //pq = newNode(4,1);

    printf(" A: %d \n", a );


    start_d = newPoint(0,0);
    end_d = newPoint(100,100);


    printf("start: %d,%d   end: %d,%d \n ", start_d.x,start_d.y,end_d.x,end_d.y);

    
    push(&pq, newNode(0, 21, newPoint(0,1), newPoint(0,0)) );
    push(&pq, newNode(1, 8, newPoint(0,3), newPoint(0,1))  );
    push(&pq, newNode(2, 5, newPoint(2,3), newPoint(0,3))  );
    push(&pq, newNode(3, 12, newPoint(1,4), newPoint(2,3)) );
    

    save(nodes_device);

}


/*

__global__ search(Point *start, Point *end, int *nodes_device ){

    //end = e; start = s; m = mp;


    //int cost, int dist,const Point &pos, const Point &parent

    pq = newNode(1, 1000, start, newPoint(0,0));
    

    //pq = newNode(4,1);
    //push(&pq, newNode(0, 21, newPoint(0,1), newPoint(0,0)) );
    //push(&pq, newNode(1, 8, newPoint(0,3), newPoint(0,1))  );
    //push(&pq, newNode(2, 5, newPoint(2,3), newPoint(0,3))  );
    //push(&pq, newNode(3, 12, newPoint(1,4), newPoint(2,3)) );
    

    save(nodes_device);

}*/







/*
int main()
{
    // Create a Priority Queue
    // 7->4->5->6

     cudaError_t err = cudaSuccess;
    printf("CUDA WORKING... \n");
    
    //int num_threads = STR_LENGTH;

    int num_threads = 1;
    int num_blocks = 1;

    //Node* mypq = (Node*)malloc(sizeof(Node));
    //Node* pq;
    //Node* mypq;
    //Node* pq = (Node*)malloc(sizeof(Node));
    

    int tam = 5;
    size_t size = tam*sizeof(int);

    //int *nodes_host = malloc(tam * sizeof(int));

    int* nodes_host = (int*)malloc(size);
    int* nodes_device = (int*)malloc(size);


    //int  nodes_host[5];

    
    for (int i = 0; i < tam; ++i)
    {
    	nodes_host[i] = malloc(sizeof(int));
    }



    cudaMalloc(&nodes_device, size);

	//cudaMalloc(&nodes_device, size);
    queue<<<num_blocks,num_threads>>>(nodes_device);
    cudaDeviceSynchronize();

    err = cudaMemcpy(nodes_host,nodes_device,size,cudaMemcpyDeviceToHost);

    cudaFree(nodes_device);

    if (err != cudaSuccess)
    {
        fprintf(stderr, "error code %s)!\n", cudaGetErrorString(err));
        //exit(EXIT_FAILURE);
    }

    //cudaMemcpyToSymbol("nodes_device",nodes_host , size);
    //int tams = (int)( sizeof(nodes_host) / sizeof(nodes_host[0]));
    //printf("TAM: %d\n", tams);

    
    for(int i = 0; i < tam; i++)
	{
	  	printf("%d\n", nodes_host[i]);
	}
	


    
    //print_array(nodes_host);
    /*
    while (!isEmpty(&mypq)) {
        printf("%d ", peek(&mypq));
        pop(&mypq);
    }
    printf("\n");
    
	

    return 0;
}
*/