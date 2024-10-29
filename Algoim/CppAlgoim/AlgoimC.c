#include "Algoimwrapper.h"
#include "AlgoimC.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <time.h>

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
    int err;

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

// Helper function to print and calculate volume
void printVolume(QuadScheme AlgoimScheme, bool printNodes, double* vol) {
    for (int k = 0; k < AlgoimScheme.size; k++) {
        if (printNodes) {
            printf("x: ");
            for (int dim = 0; dim < AlgoimScheme.dimension; dim++) {
                printf("%lf ", AlgoimScheme.nodes[k * AlgoimScheme.dimension + dim]);
            }
            printf(" w: %lf \n", AlgoimScheme.weights[k]);
        }
        *vol += AlgoimScheme.weights[k];
    }
}

// A hardcoded test for different calls
int main(int argc, char* argv[]) {

    example_calculation(1);

    return 0;

    // Start the timer
    clock_t start, end;
    start = clock();

    printf("      ___           ___           ___           ___           ___     \n");
    printf("     /\\  \\         /\\  \\         /\\  \\         /\\  \\         /\\  \\    \n");
    printf("    /::\\  \\       /::\\  \\       /::\\  \\       /::\\  \\       /::\\  \\   \n");
    printf("   /:/\\:\\  \\     /:/\\:\\  \\     /:/\\ \\  \\     /:/\\ \\  \\     /:/\\ \\  \\  \n");
    printf("  /::\\~\\:\\__\\   /:/  \\:\\  \\   _\\:\\~\\ \\  \\   _\\:\\~\\ \\  \\   _\\:\\~\\ \\  \\ \n");
    printf(" /:/\\:\\ \\:|__| /:/__/ \\:\\__\\ /\\ \\:\\ \\ \\__\\ /\\ \\:\\ \\ \\__\\ /\\ \\:\\ \\ \\__\\\n");
    printf(" \\:\\~\\:\\/:/  / \\:\\  \\ /:/  / \\:\\ \\:\\ \\/__/ \\:\\ \\:\\ \\/__/ \\:\\ \\:\\ \\/__/\n");
    printf("  \\:\\ \\::/  /   \\:\\  /:/  /   \\:\\ \\:\\__\\    \\:\\ \\:\\__\\    \\:\\ \\:\\__\\  \n");
    printf("   \\:\\/:/  /     \\:\\/:/  /     \\:\\/:/  /     \\:\\/:/  /     \\:\\/:/  /  \n");
    printf("    \\::/__/       \\::/  /       \\::/  /       \\::/  /       \\::/  /   \n");
    printf("     ~~            \\/__/         \\/__/         \\/__/         \\/__/    \n");
    printf("                                                                      \n");
    printf("Welcome to BoSSS - Algoim interface \n");
    printf("Performing an example calculation ...\n \n");
    printf("Ellipse with a=0.5 b=1, exact area is pi/2 (1.5707963267948966) \n");
    printf(" \n");

	//example_calculation(1);
    bool printNodes = false;
    int q = 3;
    int p = 3; //number of points to describe polynomial
    Poly myPoly;
    int dim = 2;
    quadType intType = Volume;
    int* myNumbers = NULL;
    double* coefVal = NULL;

    // Print parameters and their values
    printf("Parameters and their values:\n");
    printf("printNodes: %s\n", printNodes ? "true" : "false");
    printf("Quadrature order: %d\n", q);
    printf("Dim: %d\n", dim);
    printf("integral Type: %s\n", intType == Volume ? "Volume" : "Surface");
    printf("\n");

    printf("1) Calculating with routine from 2015 paper and passing a polynomial\n");
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
    } else if (dim ==3){
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
    } else {
        printf("Dimension is not supported");
        return 1;
    }

    // Calling routine from 2015 Paper
    QuadScheme AlgoimScheme = call_quad_general_poly(myPoly,q, intType);

    double vol =0.0, vol1 = 0.0, vol2 = 0.0;
    printVolume(AlgoimScheme, printNodes, &vol);
    printf(" Volume: %lf \n", vol);

    outputQuadratureRuleAsVtpXML(AlgoimScheme,"algoim1.vtp");

    printf("\n");


    // Calling routine from 2022 Paper
    printf("2) Calculating with routine from 2022 paper and passing a polynomial\n");
    for (int i = 0; i < myPoly.size; i++) {
        coefVal[i] = -coefVal[i]; //level-set should be negatively manipulated
    }
    myPoly.coef = coefVal;

    QuadScheme AlgoimScheme2 = call_quad_multi_poly(myPoly, p, q, intType);
    printVolume(AlgoimScheme, printNodes, &vol1);
    printf(" Volume: %lf \n", vol1);
    outputQuadratureRuleAsVtpXML(AlgoimScheme2, "algoim2.vtp");
    printf("\n");

    // Calling routine from 2022 Paper with Lagrange interpolation
    printf("3) Calculating with routine from 2022 paper and passing data at Lagrange points\n");
    PhiData myData;

    const double points[9][2] = {
        {-1.0, -1.0}, {0.0, -1.0}, {1.0, -1.0},
        {-1.0, 0.0}, {0.0, 0.0}, {1.0, 0.0},
        {-1.0, 1.0}, {0.0, 1.0}, {1.0, 1.0}
    };

    const double points_1dx_combined[6] = { -1.0, 0.0, 1.0, -1.0, 0.0, 1.0 }; // nodes in x + nodes in y (concatenated from of points array)

    const double points_1dy[9] = {
    -4.0, -3.0, -4.0,
    0.0, +1.0, 0.0,
    -4.0, -3.0, -4.0
    };

    const int sizes[2] = { 3, 3 };

    // Assign values to PhiData
    myData.dimension = 2;
    myData.sizes = sizes;
    myData.x = points_1dx_combined;
    myData.y = points_1dy;

    QuadScheme AlgoimScheme3 = call_quad_multi_poly_withData(myData, p, q, intType);

    printVolume(AlgoimScheme, printNodes, &vol2);
    printf(" Volume: %lf \n", vol2);
    outputQuadratureRuleAsVtpXML(AlgoimScheme3, "algoim3.vtp");

    printf("\nPerforming a performance study, calling routinefrom quadrature order 0 to 19, each with 1000 times)\n");
    for (int i = 0; i < 1000; i++)
    {
        for (int k = 0; k < 20; k++) {
            AlgoimScheme3 = call_quad_multi_poly_withData(myData, p, k, intType);
        }
    }

    // Freeing allocated memory
    free(myPoly.exp);
    free(myPoly.coef);

    // End the timer
    end = clock();

    // Calculate and print the elapsed time
    double elapsed_time = ((double)(end - start)) / CLOCKS_PER_SEC;
    printf("\nTotal elapsed time: %f seconds\n", elapsed_time);

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

QuadSchemeCombo BoSSS_GetComboScheme(const int dim, const int p, const int q, const int* sizes, const double* x, const double* y)
{
    quadType intType = Combo;
    PhiData myData;

    // Assign values to PhiData
    myData.dimension = dim;
    myData.sizes = sizes;
    myData.x = x;
    myData.y = y;

    QuadSchemeCombo AlgoimScheme = call_quad_multi_poly_withDataCombo(myData, p, q, intType);
    return AlgoimScheme;
}

QuadScheme BoSSS_GetVolumeSchemeTwoLS(const int dim, const int p1, const int p2, const int q, const int* sizes1, const int* sizes2, const double* x1, const double* x2, const double* y1, const double* y2)
{
    quadType intType = Volume;
    PhiData myDataA, myDataB;

    // Assign values to PhiData
    myDataA.dimension = dim;
    myDataA.sizes = sizes1;
    myDataA.x = x1;
    myDataA.y = y1;

    myDataB.dimension = dim;
    myDataB.sizes = sizes2;
    myDataB.x = x2;
    myDataB.y = y2;

    QuadScheme AlgoimScheme = call_quad_multi_poly_withDataTwoLS(myDataA, myDataB, p1, p2, q, intType);
    return AlgoimScheme;
}

QuadScheme BoSSS_GetSurfaceSchemeTwoLS(const int dim, const int p1, const int p2, const int q, const int* sizes1, const int* sizes2, const double* x1, const double* x2, const double* y1, const double* y2)
{
    quadType intType = Surface;
    PhiData myDataA, myDataB;

    // Assign values to PhiData
    myDataA.dimension = dim;
    myDataA.sizes = sizes1;
    myDataA.x = x1;
    myDataA.y = y1;

    myDataB.dimension = dim;
    myDataB.sizes = sizes2;
    myDataB.x = x2;
    myDataB.y = y2;

    QuadScheme AlgoimScheme = call_quad_multi_poly_withDataTwoLS(myDataA, myDataB, p1, p2, q, intType);
    return AlgoimScheme;
}

QuadSchemeCombo BoSSS_GetComboSchemeTwoLS(const int dim, const int p1, const int p2, const int q, const int* sizes1, const int* sizes2, const double* x1, const double* x2, const double* y1, const double* y2)
{
    quadType intType = Combo;
    PhiData myDataA, myDataB;

    // Assign values to PhiData
    myDataA.dimension = dim;
    myDataA.sizes = sizes1;
    myDataA.x = x1;
    myDataA.y = y1;

    myDataB.dimension = dim;
    myDataB.sizes = sizes2;
    myDataB.x = x2;
    myDataB.y = y2;

    QuadSchemeCombo AlgoimScheme = call_quad_multi_poly_withDataComboTwoLS(myDataA, myDataB, p1, p2, q, intType);
    return AlgoimScheme;
}
