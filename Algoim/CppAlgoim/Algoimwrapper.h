// MyLibrary.h
#pragma once

// Conditional definition for MYLIBRARY_API
#ifdef _WIN32
    // Windows: Use __declspec(dllimport) or __declspec(dllexport)
    #define MYLIBRARY_API __declspec(dllimport)
#else
    // Linux: Empty definition for MYLIBRARY_API
    #define MYLIBRARY_API __attribute__((visibility("default")))
#endif

#ifndef ALGOIMWRAPPER_H
#define ALGOIMWRAPPER_H

#ifdef __cplusplus
extern "C" {
#endif
    // Define the Phi struct using typedef (for using delegates)
    typedef struct {
        int dimension;
        double (*func)(const double*);
        double* (*grad)(const double*);
    } PhiStruct;

    // Define the Poly struct using typedef (for using polynomials)
    typedef struct {
        int dimension;                  // dimension of the space
        int size;                       // number of terms
        const int* exp;                 // exponent of each variable in every term; size(exp) = size * dimension
        const double* coef;             // coefficient of each term; size(exp) = size; 
    } Poly;

    // Explicit function
    typedef struct {
        int dimension;                  // dimension of the space
        const int* sizes;               // array that stores size in each axes. (e.g., size[0] is the number of points in 0-th axis). Its size is equal to dimension.
        const double* x;                // coordinates stored in 1d array; size(x) = sizes[0] + sizes[1] + ... sizes[dimension-1] 
                                        // order: first coordinates 0-th axis, then 1-th axis ... until (dim-1)-th axis (x0[0], x0[1], ... , x0[sizes[0]-1], x1[0], x1[1], ... , x-(dim-1)[0]
        const double* y;                // level set values stored in 1d array for all the combinations of points in x; size(y) = sizes[0] * sizes[1] * ... sizes[dimension-1] 
                                        // mapping from index (i0,i1,i2, ..., i(d-1)) to i0 + i1*sizes[0] + i2*(sizes[0] * sizes[1], ... ) 
                                        // the increment in index changes the first axis (0-th axis), and if it reaches sizes[0] then second, and then if it also reaches sizes[1], third, ... the last 
                                        // (e.g. for 2d: y[0] is for (x0[0], x1[0]) and y[1] is for (x0[1], x1[0] )
    } PhiData;

    // Define quadrature scheme struct using typedef
    typedef struct {
        int dimension;                  // dimension of the space
        int size;                       // number of points/nodes
        double* nodes;                  // size(nodes) = size * dimension; array that stores coordinates of nodes in each axes. e.g. nodes[0]= 0th coordinate of 0.th node, nodes[1]= 1th coordinate of 0.th node
        double* weights;                // size(weights) = size; weights of each node
    } QuadScheme;

    // Define combo (surface + volume) quadrature scheme struct using typedef
    typedef struct {
        int dimension;                  // dimension of the space
        int sizeSurf;                   // number of points/nodes in surface scheme
        int sizeVol;                    // number of points/nodes in volume scheme
        double* nodes;                  // size(nodes) = (sizeSurf + sizeVol) * dimension; array that stores coordinates of nodes in each axes. e.g. nodes[0]= 0th coordinate of 0.th node, nodes[1]= 1th coordinate of 0.th node
        double* weights;                // size(weights) = sizeSurf + sizeVol; weights of each node
    } QuadSchemeCombo;

    // Define enum
    typedef enum {
        Combo,                          //surface + volume
        Surface,
        Volume
    } quadType;


	// Function prototypes
	MYLIBRARY_API int example_calculation(int a);
    MYLIBRARY_API QuadScheme call_quad_general_poly(Poly a, int q, quadType type);
    MYLIBRARY_API QuadScheme call_quad_multi_poly(Poly a, int p, int q, quadType type);
    MYLIBRARY_API QuadScheme call_quad_multi_poly_withData(PhiData a, int p, int q, quadType type);
    MYLIBRARY_API QuadSchemeCombo call_quad_multi_poly_withDataCombo(PhiData a, int p, int q, quadType type);
#ifdef __cplusplus
}
#endif

#endif // ALGOIMWRAPPER_H