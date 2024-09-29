#include "Algoimwrapper.h"
#include "AlgoimC.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#ifdef _MSC_VER  // For Microsoft compilers
#include <errno.h>  // errno_t is defined here
#else  // For GCC or other compilers
typedef int errno_t;  // Define errno_t as int for non-MSVC compilers
#endif

// For delegate transfer
// Define the implementation of the phi function
double phi_function(double* x) {
    // Implement the Ellipsoid function here
    // For example, for a 2D Ellipsoid, the equation could be: x[0]*x[0] + 4.0*x[1]*x[1] - 1.0
    return x[0] * x[0] + 4.0 * x[1] * x[1] - 1.0;
}

double* grad_function(const double* x) {
    double* gradient = malloc(2 * sizeof(double)); // Allocate memory for the gradient
    if (gradient == NULL) {
        // Handle memory allocation failure
        return NULL;
    }
    gradient[0] = 2.0 * x[0];
    gradient[1] = 8.0 * x[1];
    return gradient;
}

void outputQuadratureRuleAsVtpXML(QuadScheme q, const char* fn) {
    int dim = q.dimension;

    if (dim != 2 && dim != 3) {
        fprintf(stderr, "XML output is support only for 2D and 3D schemes.\n");
        exit(EXIT_FAILURE); // Exit the program with a failure status
    }

    const double* nodes = q.nodes;
    const double* weights = q.weights;
    size_t size = (size_t)(q.size);
    FILE* stream;
    errno_t err;

#ifdef _MSC_VER  // Use fopen_s for Microsoft compilers
    err = fopen_s(&stream, fn, "w");
    if (err != 0) {
        printf("Error opening file: %s\n", fn);
        return;
    }
#else  // Use standard fopen for GCC or other compilers
    stream = fopen(fn, "w");
    if (stream == NULL) {
        printf("Error opening file: %s\n", fn);
        return;
    }
#endif

    fprintf(stream, "<?xml version=\"1.0\"?>\n");
    fprintf(stream, "<VTKFile type=\"PolyData\" version=\"0.1\" byte_order=\"LittleEndian\">\n");
    fprintf(stream, "<PolyData>\n");
    fprintf(stream, "<Piece NumberOfPoints=\"%zu\" NumberOfVerts=\"%zu\" NumberOfLines=\"0\" NumberOfStrips=\"0\" NumberOfPolys=\"0\">\n", size, size);
    fprintf(stream, "<Points>\n");
    fprintf(stream, "  <DataArray type=\"Float32\" Name=\"Points\" NumberOfComponents=\"3\" format=\"ascii\">\n");
    for (size_t i = 0; i < size; ++i) {
        fprintf(stream, "    %.2f %.2f %.2f\n", nodes[i*dim], nodes[i*dim+1], (dim == 3 ? nodes[i * dim + 2] : 0.0));
    }
    fprintf(stream, "  </DataArray>\n");
    fprintf(stream, "</Points>\n");
    fprintf(stream, "<Verts>\n");
    fprintf(stream, "  <DataArray type=\"Int32\" Name=\"connectivity\" format=\"ascii\">\n");
    for (size_t i = 0; i < size; ++i) {
        fprintf(stream, "    %zu\n", i);
    }
    fprintf(stream, "  </DataArray>\n");
    fprintf(stream, "  <DataArray type=\"Int32\" Name=\"offsets\" format=\"ascii\">\n");
    for (size_t i = 1; i <= size; ++i) {
        fprintf(stream, "    %zu\n", i);
    }
    fprintf(stream, "  </DataArray>\n");
    fprintf(stream, "</Verts>\n");
    fprintf(stream, "<PointData Scalars=\"w\">\n");
    fprintf(stream, "  <DataArray type=\"Float32\" Name=\"w\" NumberOfComponents=\"1\" format=\"ascii\">\n");
    for (size_t i = 0; i < size; ++i) {
        fprintf(stream, "    %.2f\n", weights[i]);
    }
    fprintf(stream, "  </DataArray>\n");
    fprintf(stream, "</PointData>\n");
    fprintf(stream, "</Piece>\n");
    fprintf(stream, "</PolyData>\n");
    fprintf(stream, "</VTKFile>\n");

    fclose(stream);
}

//A hardcoded test for different calls
int main(int argc, char* argv[]) {
	//example_calculation(1);
    bool printNodes = false;
    int q = 3;
    Poly myPoly;
    int dim = 2;
    quadType intType = Volume;
    int* myNumbers = NULL;
    double* coefVal = NULL;
    //myPoly.dimension = dim; // Example dimension value
    //int myNumbers[] = { 0,0,2,0,0,2 };
    //myPoly.exp = &myNumbers; // Assigning the pointer to exp
    //double coefVal[] = { -1,1,4 }; // Example coefficient value
    //myPoly.coef = &coefVal; // Assigning the pointer to coef
    //myPoly.size = 3;

    //Example test cases
    if (dim == 2) {
        myPoly.dimension = dim;
        myNumbers = (int*)malloc(6 * sizeof(int));
        if (myNumbers == NULL) {
            printf("Memory allocation failed\n");
            return 1;
        }
        myNumbers[0] = 0;
        myNumbers[1] = 0;
        myNumbers[2] = 2;
        myNumbers[3] = 0;
        myNumbers[4] = 0;
        myNumbers[5] = 2;

        myPoly.exp = myNumbers;

        coefVal = (double*)malloc(3 * sizeof(double));
        if (coefVal == NULL) {
            printf("Memory allocation failed\n");
            free(myNumbers);
            return 1;
        }
        coefVal[0] = -1;
        coefVal[1] = 1;
        coefVal[2] = 4;

        myPoly.coef = coefVal;
        myPoly.size = 3;
    }
    else {
        myPoly.dimension = dim;
        myNumbers = (int*)malloc(12 * sizeof(int));
        if (myNumbers == NULL) {
            printf("Memory allocation failed\n");
            return 1;
        }
        myNumbers[0] = 0;
        myNumbers[1] = 0;
        myNumbers[2] = 0;
        myNumbers[3] = 2;
        myNumbers[4] = 0;
        myNumbers[5] = 0;
        myNumbers[6] = 0;
        myNumbers[7] = 2;
        myNumbers[8] = 0;
        myNumbers[9] = 0;
        myNumbers[10] = 0;
        myNumbers[11] = 2;

        myPoly.exp = myNumbers;

        coefVal = (double*)malloc(4 * sizeof(double));
        if (coefVal == NULL) {
            printf("Memory allocation failed\n");
            free(myNumbers);
            return 1;
        }
        coefVal[0] = -1;
        coefVal[1] = 1;
        coefVal[2] = 4;
        coefVal[3] = 9;

        myPoly.coef = coefVal;
        myPoly.size = 4;
    }

    // Calling routine from 2015 Paper
    QuadScheme AlgoimScheme = call_quad_general_poly(myPoly,q, intType);

    double vol =0.0, vol1 = 0.0, vol2 = 0.0;
    for (int k = 0; k < AlgoimScheme.size; k++) {
        if (printNodes) {
            printf("x: ");
            for (int dim = 0; dim < AlgoimScheme.dimension; dim++) {
                printf("%lf ", AlgoimScheme.nodes[k * AlgoimScheme.dimension + dim]);
            }
            printf(" w: %lf \n", AlgoimScheme.weights[k]);
        }


        vol += AlgoimScheme.weights[k];
    }
    printf(" Volume: %lf \n", vol);

    outputQuadratureRuleAsVtpXML(AlgoimScheme,"algoim1.vtp");


    // Calling routine from 2022 Paper
    QuadScheme AlgoimScheme2 = call_quad_multi_poly(myPoly, q, q, intType);

    for (int k = 0; k < AlgoimScheme2.size; k++) {
        if (printNodes) {
            printf("x: ");
            for (int dim = 0; dim < AlgoimScheme2.dimension; dim++) {
                printf("%lf ", AlgoimScheme2.nodes[k * AlgoimScheme2.dimension + dim]);
            }
            printf(" w: %lf \n", AlgoimScheme2.weights[k]);
        }

        vol1 += AlgoimScheme2.weights[k];
    }

    printf(" Volume: %lf \n", vol1);
    outputQuadratureRuleAsVtpXML(AlgoimScheme2, "algoim2.vtp");

    // Calling routine from 2022 Paper with Lagrange interpolation
    PhiData myData;
    const double points[9][2] = {
        {-1.0, -1.0}, {0.0, -1.0}, {1.0, -1.0},
        {-1.0, 0.0}, {0.0, 0.0}, {1.0, 0.0},
        {-1.0, 1.0}, {0.0, 1.0}, {1.0, 1.0}
    };

    const double points_1dy[9] = {
        4.0, 3.0, 4.0,
        0.0, -1.0, 0.0,
        4.0, 3.0, 4.0
    };

    const double* points_1dx = (double[]){ -1.0, 0.0, 1.0 };

    const double* l[2] = { points_1dx, points_1dx };

    // Assign values to PhiData
    myData.dimension = 2;

    const int sizes[2] = { 3, 3 };
    myData.sizes = sizes;

    myData.x = l;
    myData.y = points_1dy;

    QuadScheme AlgoimScheme3 = call_quad_multi_poly_withData(myData, q, q, intType);

    for (int k = 0; k < AlgoimScheme3.size; k++) {
        if (printNodes) {
            printf("x: ");
            for (int dim = 0; dim < AlgoimScheme3.dimension; dim++) {
                printf("%lf ", AlgoimScheme3.nodes[k * AlgoimScheme3.dimension + dim]);
            }
            printf(" w: %lf \n", AlgoimScheme3.weights[k]);
        }
        vol2 += AlgoimScheme3.weights[k];
    }

    printf(" Volume: %lf \n", vol2);
    outputQuadratureRuleAsVtpXML(AlgoimScheme3, "algoim3.vtp");

    return 0;

}

QuadScheme BoSSS_GetVolumeScheme(const int dim, const int p, const int q, const int* sizes, const double* x, const double* y)
{
    quadType intType = Volume;
    PhiData myData;

    // Assign values to PhiData
    myData.dimension = dim;
    myData.sizes = sizes;
    myData.x = x;
    myData.y = y;

    QuadScheme AlgoimScheme = call_quad_multi_poly_withData(myData, p, q, intType);
    return AlgoimScheme;
}

QuadScheme BoSSS_GetSurfaceScheme(const int dim, const int p, const int q, const int* sizes, const double* x, const double* y)
{
    quadType intType = Surface;
    PhiData myData;

    // Assign values to PhiData
    myData.dimension = dim;
    myData.sizes = sizes;
    myData.x = x;
    myData.y = y;

    QuadScheme AlgoimScheme = call_quad_multi_poly_withData(myData, p, q, intType);
    return AlgoimScheme;
}