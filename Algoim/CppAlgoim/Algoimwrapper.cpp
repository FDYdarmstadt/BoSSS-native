#include "Algoimwrapper.h"
#include <stdio.h>
#include <iostream>
#include <iomanip>
#include <fstream>
#include "quadrature_general.hpp"
#include "quadrature_multipoly.hpp"
#include <functional>
#include <cassert>
#include <string>
#include <sstream>
#include <stdexcept>

using namespace algoim;


template<int D>
struct Ellipsoid
{
    template<typename T>
    T operator() (const uvector<T, D>& x) const
    {
        if constexpr (D == 2)
            return x(0) * x(0) + 4.0 * x(1) * x(1) - 1.0;
        else
            return x(0) * x(0) + 4.0 * x(1) * x(1) + 9.0 * x(2) * x(2) - 1.0;
    }

    template<typename T>
    uvector<T, D> grad(const uvector<T, D>& x) const
    {
        if constexpr (D == 2)
            return uvector<T, D>(2.0 * x(0), 8.0 * x(1));
        else
            return uvector<T, D>(2.0 * x(0), 8.0 * x(1), 18.0 * x(2));
    }
};


template<int D>
struct PhiDataPolyRef {
    const int* m_sizes;
    std::vector<int> m_offsets;
    int m_totSize;
    int m_dim;
    PhiData* m_data;

    void getResultsforPoints(const std::vector<std::vector<double>>& points) {
        int s = points.size();
        uvector<double, D> p;
        for (int si = 0; si < s; si++) {
            const std::vector<double>& point = points[si];
            std::cout << "x=(";
            for (size_t i = 0; i < point.size(); ++i) {
                std::cout << point[i];
                p(i) = point[i];
                if (i != point.size() - 1) {
                    std::cout << ", ";
                }
            }

            std::cout << ") ; f(x)= " << (*this)(p) << std::endl; //(*this)(p)
        }
    }

    PhiDataPolyRef(PhiData* inPhiData) : m_data(inPhiData), m_sizes(inPhiData->sizes), m_dim(inPhiData->dimension) {
        m_offsets = std::vector<int>(m_dim, 0); //new int[m_dim];
        //m_offsets[0] = 0; 
        m_totSize = m_sizes[0]; // size of y array, so size(y) = sizes[0] * sizes[1] * ... sizes[m_dim-1]

        for (int d = 1; d < m_dim; d++){
            m_offsets[d] = m_offsets[d-1] + m_sizes[d-1];
            m_totSize *= m_sizes[d];
        }

        if (m_dim > 8)
            throw std::out_of_range("Wrapper does not support dimensions greater than eight.");

    }

    template<typename T>
    T operator() (const uvector<T, D>& x) const {
        T result{}; // = static_cast<T>(0);

        int xind[D] = { 0 }; // from 1-d array to m_dim-d array for basis functions

        for (int i = 0; i < m_totSize; ++i) { // for each point
            //initiate the term;
            T loopResult = static_cast<T>(m_data->y[i]);

            // convert the index for 1-d array to the index xind for original array with D components
            int remainder = i % m_sizes[0];
            int divison = i / m_sizes[0];
            xind[0] = remainder;
            for (int d = 1; d < D; d++) {
                remainder = divison % m_sizes[d];
                divison = divison / m_sizes[d];
                xind[d] = remainder;
            }

            //for each dimension get the basis function
            for (int d = 0; d < D; d++) {
                loopResult = loopResult * this->getBasis(d, xind[d], x(d));
            }

            //Add term
            result += loopResult;
        }

        return result;
    }

    //returns N-th basis function in D-th component for input x
    template<typename T>
	T getBasis(int d, int n, const T x) const { //changed uppercase D to lowercase d since, it otherwise leads to shadowing of the type parameter D and fails with GCC copmiler.
        T ret = static_cast<T>(1);

        int offset = m_offsets[d]; //offset for d-th axis
        double xn = m_data->x[offset+n]; //get the x_N in d-th component

        if (x == ret * xn) 
            return ret;


        for (int i = 0; i < m_sizes[d]; i++) {
            if (i != n) {
                double xi = m_data->x[offset+i];
                ret *= (x - xi) / (xn - xi);
            }
        }

        return ret;
    }

    ~PhiDataPolyRef() = default;
};

template<int D>
struct PhiPolyRef {
    int m_sizes;
    int m_dim;
    Poly* m_poly;


    void getResultsforPoints(const std::vector<std::vector<double>>& points) {
        int s = points.size();
        uvector<double, D> p;
        for (int si = 0; si < s; si++) {
            const std::vector<double>& point = points[si];
            std::cout << "x=(";
            for (size_t i = 0; i < point.size(); ++i) {
                std::cout << point[i];
                p(i) = point[i];
                if (i != point.size() - 1) {
                    std::cout << ", ";
                }
            }
            
            std::cout << ") ; f(x)= " << (*this)(p) << std::endl; //(*this)(p)
        }
    }

    PhiPolyRef(Poly* inPolynom) : m_poly(inPolynom), m_sizes(inPolynom->size), m_dim(inPolynom->dimension) {
        if (m_dim > 8)
           throw std::out_of_range("Wrapper does not support dimensions greater than eight.");


        std::cout << "Instantiated a polynomial with " << m_sizes << " monomials in " << m_dim << " dimensions \n";
        std::cout << "Polynomial: " << toString() << "\n";
        std::cout << "Grad: " << toStringGrad() << "\n";

    }

    std::string toString() {
        std::stringstream ss{}; // Declare and initialize ss within the method

        for (int i = 0; i < m_sizes; ++i) {
            int xExp = i * m_dim;
            int yExp = i * m_dim + 1;
            ss << m_poly->coef[i] << "*x^" << m_poly->exp[xExp] << "*y^" << m_poly->exp[yExp];
            if (i != m_sizes - 1) {
                ss << " + ";
            }
        }
        return ss.str();

    }

    std::string toStringGrad() {
        std::vector<std::stringstream> ss; // Declare and initialize ss within the method
        std::stringstream ssX{}; // Declare and initialize ss within the method
        char axes[] = { 'x', 'y', 'z', 't', 'a', 'b', 'c', 'd' };
        ssX << "( ";
        for (int n = 0; n < D; n++) {
            for (int i = 0; i < m_sizes; ++i) {
                int xnExp = i * m_dim + n;
                ssX << m_poly->coef[i] * m_poly->exp[xnExp];
                
                for (int nOther = 0; nOther < D; nOther++) {
                    if (n == nOther) {
                        ssX << "*" << axes[nOther] << "^" << m_poly->exp[xnExp] - 1;
                    }
                    else {
                        ssX << "*" << axes[nOther] << "^" << m_poly->exp[xnExp];

                    }
                }
                
                if (i != m_sizes - 1) {
                    ssX << " + ";
                }
            }
            if (n == D-1) {
                ssX << " ) ";
            }else {
                ssX << " , ";

            }
        }

        return ssX.str();
    }

    int degree() const {
        int maxDegree = 0;

        for (int i = 0; i < m_sizes; ++i) { // for each monomial (term)
            int loopDegree = 0;

            //for each dimension
            for (int n = 0; n < D; n++) {
                int xnPos = i * D + n;
                loopDegree += m_poly->exp[xnPos];
            }

            if (loopDegree > maxDegree)
                maxDegree = loopDegree;
        }

        return maxDegree;
    }

    template<typename T>
    T operator() (const uvector<T, D>& x) const {
        T result{}; // = static_cast<T>(0);

        // Iterate over the coefficients and perform polynomial evaluation 
        for (int i = 0; i < m_sizes; ++i) { // for each monomial (term)
            //initiate monomial;
            T loopResult = static_cast<T>(m_poly->coef[i]);

            //for each dimension
            for (int n = 0; n < D; n++) {
                int xnPos = i * D + n;
                //multiply until exponent
                for (int xi = 0; xi < m_poly->exp[xnPos]; ++xi) {
                    loopResult *= x(n);
                }
            }

            //Add monomial
            result += loopResult;
        }

        return result;
    }


    template<typename T>
    uvector<T, D> grad(const uvector<T, D>& x) const {
        uvector<T, D> result{};

        // Iterate over the coefficients and perform polynomial evaluation
        for (int i = 0; i < m_sizes; ++i) { // for each monomial (term)
            for (int n = 0; n < D; n++) {
                int xnPos = i * D + n;
                
                //First take the derivative with respect to xn
                T xnloopResult = static_cast<T>(m_poly->coef[i] * m_poly->exp[xnPos]);
                for (int xi = 0; xi < m_poly->exp[xnPos] - 1; ++xi) {
                    xnloopResult *= x(n);
                }

                for (int nOther = 0; nOther < D && nOther != n; nOther++) { // loop over other dimensions
                    int xnPosOther = i * D + nOther; 
                    for (int xi = 0; xi < m_poly->exp[xnPosOther] ; ++xi) {
                        xnloopResult *= x(nOther);
                    }
                }
                result(n) += xnloopResult;
            }
        }

        return result;
    }
};


template<int D>
QuadScheme CastGeneralQuadScheme(const QuadratureRule<D>& Scheme) {
    QuadScheme ret;
    ret.dimension = D;

    int numNodes = Scheme.nodes.size(); // Get the number of nodes in the scheme
    ret.size = numNodes; // Assign the size

    // Allocate memory for nodes and weights arrays inside QuadScheme struct
    ret.nodes = new double[numNodes * D];
    ret.weights = new double[numNodes];

    int k = 0;
    for (const auto& node : Scheme.nodes) {
        // Copy the coordinates of the node to the nodes array
        for (int n = 0; n < D; n++) {
            ret.nodes[k * D + n] = static_cast<double>(node.x(n)); // Assign the values    
        }

        // Copy the weight of the node to the weights array
        ret.weights[k] = static_cast<double>(node.w);

        // Output node information (optional)
        //std::cout << "x: " << node.x << " w: " << node.w << "\N";

        k++;
    }
    return ret;
}

//Takes the algoim quadrature rule and casts it into the double format for C interface
template<int D>
QuadScheme CastMultiPolQuadScheme(const std::vector<uvector<real, D + 1>> Scheme, double xmin, double xmax, quadType type) {
    QuadScheme ret;
    ret.dimension = D;

    const int numNodes = Scheme.size(); // Get the number of nodes in the scheme
    ret.size = numNodes; // Assign the size

    // Allocate memory for nodes and weights arrays inside QuadScheme struct
    ret.nodes = new double[numNodes * D];
    ret.weights = new double[numNodes];

    // Calculate the scaling factor based on the quadType
    const double scale = (type == quadType::Surface) ? std::abs(pow(xmax - xmin, D - 1)) : std::abs(pow(xmax - xmin, D));

    for (int k = 0; k < numNodes; k++) {
        uvector<real, D + 1> node = Scheme[k];
        // Copy the coordinates of the node to the nodes array
        for (int n = 0; n < D; n++) {
            ret.nodes[k * D + n] = xmin + (xmax - xmin) * static_cast<double>(node(n)); // Assign the values while scaling back to the reference frame
        }

        // Copy the weight of the node to the weights array, also scale back to the reference element
        ret.weights[k] = static_cast<double>(node(D)) * scale;
    }

    return ret;
}

//Takes the algoim quadrature rule and casts it into the double format for C interface
template<int D>
QuadSchemeCombo CastMultiPolQuadSchemeCombo(const std::tuple<std::vector<uvector<real, D + 1>>, std::vector<uvector<real, D + 1>>> SchemeTuple, double xmin, double xmax, quadType type) {
    QuadSchemeCombo ret;
    ret.dimension = D;

    // Access the first and second elements
    auto surfScheme = std::get<0>(SchemeTuple);               // first item (surf)
    auto volScheme = std::get<1>(SchemeTuple);                // second item (phase0)

    const int numNodesSurf = surfScheme.size();               // Get the number of nodes in the surface scheme
    const int numNodesVol = volScheme.size();                 // Get the number of nodes in the volume scheme
    ret.sizeSurf = numNodesSurf;
	ret.sizeVol = numNodesVol;

    const int numNodes = numNodesSurf + numNodesVol;          // Get the total number of nodes in the schemes

    // Allocate memory for nodes and weights arrays inside QuadScheme struct
    ret.nodes = new double[numNodes * D];
    ret.weights = new double[numNodes];

    // Calculate the scaling factor based on the quadType
    const double scaleSurf = std::abs(pow(xmax - xmin, D - 1));
    const double scaleVol =  std::abs(pow(xmax - xmin, D));

    // Lambda to handle node processing
    auto processNode = [&](const uvector<real, D + 1>& node, int index, double scale) {
        for (int n = 0; n < D; n++) {
            ret.nodes[index * D + n] = xmin + (xmax - xmin) * static_cast<double>(node(n));
        }
        ret.weights[index] = static_cast<double>(node(D)) * scale;
        };

    // Surface nodes
    for (int k = 0; k < numNodesSurf; k++) {
        processNode(surfScheme[k], k, scaleSurf);
    }

    // Volume nodes
    for (int k = 0; k < numNodesVol; k++) {
        processNode(volScheme[k], numNodesSurf + k, scaleVol);
    }

    return ret;
}

template<int D, typename F>
std::vector<uvector<real, D + 1>> outputQuadSchemeSurface(const F& fphi, real xmin, real xmax, const uvector<int, D>& P, int q)
{
    // Construct phi by mapping [0,1] onto bounding box [xmin,xmax]
    xarray<real, D> phi(nullptr, P);
    algoim_spark_alloc(real, phi);

    //bernstein::bernsteinInterpolate<D>([&](const uvector<real, D>& x) { return fphi(xmin + x * (xmax - xmin)); }, phi);
    //scale the fphi function
    auto interpolated_fphi = [&](const uvector<real, D>& x) {
        uvector<real, D> modified_x = xmin + x * (xmax - xmin);
        return fphi(modified_x);
        };
    bernstein::bernsteinInterpolate<D>(interpolated_fphi, phi);

    // Build quadrature hierarchy
    ImplicitPolyQuadrature<D> ipquad(phi);


    std::vector<uvector<real, D + 1>> surf;
    ipquad.integrate_surf(AutoMixed, q, [&](const uvector<real, D>& x, real w, const uvector<real, D>& wn)
        {
            surf.push_back(add_component(x, D, w));
        });

    return surf;
}

template<int D, typename F>
std::vector<uvector<real, D + 1>> outputQuadSchemeVolume(const F& fphi, real xmin, real xmax, const uvector<int, D>& P, int q)
{
    // Construct phi by mapping [0,1] onto bounding box [xmin,xmax]
    xarray<real, D> phi(nullptr, P);
    algoim_spark_alloc(real, phi);

    //scale the fphi function
    auto interpolated_fphi = [&](const uvector<real, D>& x) {
        uvector<real, D> modified_x = xmin + x * (xmax - xmin);
        return fphi(modified_x);
        };
    bernstein::bernsteinInterpolate<D>(interpolated_fphi, phi);

    // Build quadrature hierarchy
    ImplicitPolyQuadrature<D> ipquad(phi);

    std::vector<uvector<real, D + 1>> phase0;
    ipquad.integrate(AutoMixed, q, [&](const uvector<real, D>& x, real w)
        {
            if (bernstein::evalBernsteinPoly(phi, x) > 0)
                phase0.push_back(add_component(x, D, w));
        });

    return phase0;
}

template<int D, typename F>
std::tuple<std::vector<uvector<real, D + 1>>, std::vector<uvector<real, D + 1>>> outputQuadSchemeCombo(const F& fphi, real xmin, real xmax, const uvector<int, D>& P, int q)
{
    // Construct phi by mapping [0,1] onto bounding box [xmin,xmax]
    xarray<real, D> phi(nullptr, P);
    algoim_spark_alloc(real, phi);

    //scale the fphi function
    auto interpolated_fphi = [&](const uvector<real, D>& x) {
        uvector<real, D> modified_x = xmin + x * (xmax - xmin);
        return fphi(modified_x);
        };
    bernstein::bernsteinInterpolate<D>(interpolated_fphi, phi);

    // Build quadrature hierarchy
    ImplicitPolyQuadrature<D> ipquad(phi);

    std::vector<uvector<real, D + 1>> phase0;
    ipquad.integrate(AutoMixed, q, [&](const uvector<real, D>& x, real w)
        {
            if (bernstein::evalBernsteinPoly(phi, x) > 0)
                phase0.push_back(add_component(x, D, w));
        });
    std::vector<uvector<real, D + 1>> surf;
    ipquad.integrate_surf(AutoMixed, q, [&](const uvector<real, D>& x, real w, const uvector<real, D>& wn)
        {
            surf.push_back(add_component(x, D, w));
        });
	
    //return the tuple of both quadrature rules
    return std::make_tuple(surf, phase0);
}

QuadScheme call_quad_general_poly(Poly poly, int q, quadType type) {

    //Assign the quadType parameter for Algoim ( if D=D : surface, if D<0: volume)
    int qType = type == quadType::Volume ? -1 : poly.dimension;

    switch (poly.dimension) {
    case 1: {
        PhiPolyRef<1> phi1(&poly);
        auto q1 = quadGen<1>(phi1, HyperRectangle<double, 1>(-1.0, 1.0), qType, -1, q);
        return CastGeneralQuadScheme(q1);
    }
    case 2: {
        PhiPolyRef<2> phi2(&poly);
        auto q2 = quadGen<2>(phi2, HyperRectangle<double, 2>(-1.0, 1.0), qType, -1, q);
        return CastGeneralQuadScheme(q2);
    }
    case 3: {
        PhiPolyRef<3> phi3(&poly);
        auto q3 = quadGen<3>(phi3, HyperRectangle<double, 3>(-1.0, 1.0), qType, -1, q);
        return CastGeneralQuadScheme(q3);
    }
    case 4: {
        PhiPolyRef<4> phi4(&poly);
        auto q4 = quadGen<4>(phi4, HyperRectangle<double, 4>(-1.0, 1.0), qType, -1, q);
        return CastGeneralQuadScheme(q4);
    }
    case 5: {
        PhiPolyRef<5> phi5(&poly);
        auto q5 = quadGen<5>(phi5, HyperRectangle<double, 5>(-1.0, 1.0), qType, -1, q);
        return CastGeneralQuadScheme(q5);
    }
    case 6: {
        PhiPolyRef<6> phi6(&poly);
        auto q6 = quadGen<6>(phi6, HyperRectangle<double, 6>(-1.0, 1.0), qType, -1, q);
        return CastGeneralQuadScheme(q6);
    }
    case 7: {
        PhiPolyRef<7> phi7(&poly);
        auto q7 = quadGen<7>(phi7, HyperRectangle<double, 7>(-1.0, 1.0), qType, -1, q);
        return CastGeneralQuadScheme(q7);
    }
    case 8: {
        PhiPolyRef<8> phi8(&poly);
        auto q8 = quadGen<8>(phi8, HyperRectangle<double, 8>(-1.0, 1.0), qType, -1, q);
        return CastGeneralQuadScheme(q8);
    }
    default:
        throw std::out_of_range("Wrapper does not support dimensions greater than eight i.e., 0 < dim <= 8");
    }

}
QuadScheme call_quad_multi_poly_surface(Poly poly, int p, int q) {
    //reference frame
    double xmin = -1.0;
    double xmax = 1.0;
    //int degreeOfPoly = poly
    switch (poly.dimension) {
    case 1: {
        throw std::out_of_range("Surface integrals are supported only for N > 1");
    }
    case 2: {
        PhiPolyRef<2> phi2(&poly);
        auto q2 = outputQuadSchemeSurface<2, PhiPolyRef<2>>(phi2, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<2>(q2, xmin, xmax, quadType::Surface);
    }
    case 3: {
        PhiPolyRef<3> phi3(&poly);
        auto q3 = outputQuadSchemeSurface<3, PhiPolyRef<3>>(phi3, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<3>(q3, xmin, xmax, quadType::Surface);
    }
    case 4: {
        PhiPolyRef<4> phi4(&poly);
        auto q4 = outputQuadSchemeSurface<4, PhiPolyRef<4>>(phi4, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<4>(q4, xmin, xmax, quadType::Surface);;
    }
    case 5: {
        PhiPolyRef<5> phi5(&poly);
        auto q5 = outputQuadSchemeSurface<5, PhiPolyRef<5>>(phi5, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<5>(q5, xmin, xmax, quadType::Surface);
    }
    case 6: {
        PhiPolyRef<6> phi6(&poly);
        auto q6 = outputQuadSchemeSurface<6, PhiPolyRef<6>>(phi6, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<6>(q6, xmin, xmax, quadType::Surface);
    }
    case 7: {
        PhiPolyRef<7> phi7(&poly);
        auto q7 = outputQuadSchemeSurface<7, PhiPolyRef<7>>(phi7, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<7>(q7, xmin, xmax, quadType::Surface);
    }
    case 8: {
        PhiPolyRef<8> phi8(&poly);
        auto q8 = outputQuadSchemeSurface<8, PhiPolyRef<8>>(phi8, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<8>(q8, xmin, xmax, quadType::Surface);
    }
    default:
        throw std::out_of_range("Wrapper does not support dimensions greater than eight i.e., 0 < dim <= 8");
    }
}

QuadScheme call_quad_multi_poly_surface(PhiData phiData, int p, int q) {
    //reference frame
    double xmin = -1.0;
    double xmax = 1.0;
    switch (phiData.dimension) {
    case 1: {
        throw std::out_of_range("Surface integrals are supported only for N > 1");
    }
    case 2: {

        PhiDataPolyRef<2> phi2(&phiData);
        auto q2 = outputQuadSchemeSurface<2, PhiDataPolyRef<2>>(phi2, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<2>(q2, xmin, xmax, quadType::Surface);
    }
    case 3: {
        PhiDataPolyRef<3> phi3(&phiData);
        auto q3 = outputQuadSchemeSurface<3, PhiDataPolyRef<3>>(phi3, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<3>(q3, xmin, xmax, quadType::Surface);
    }
    case 4: {
        PhiDataPolyRef<4> phi4(&phiData);
        auto q4 = outputQuadSchemeSurface<4, PhiDataPolyRef<4>>(phi4, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<4>(q4, xmin, xmax, quadType::Surface);;
    }
    case 5: {
        PhiDataPolyRef<5> phi5(&phiData);
        auto q5 = outputQuadSchemeSurface<5, PhiDataPolyRef<5>>(phi5, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<5>(q5, xmin, xmax, quadType::Surface);
    }
    case 6: {
        PhiDataPolyRef<6> phi6(&phiData);
        auto q6 = outputQuadSchemeSurface<6, PhiDataPolyRef<6>>(phi6, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<6>(q6, xmin, xmax, quadType::Surface);
    }
    case 7: {
        PhiDataPolyRef<7> phi7(&phiData);
        auto q7 = outputQuadSchemeSurface<7, PhiDataPolyRef<7>>(phi7, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<7>(q7, xmin, xmax, quadType::Surface);
    }
    case 8: {
        PhiDataPolyRef<8> phi8(&phiData);
        auto q8 = outputQuadSchemeSurface<8, PhiDataPolyRef<8>>(phi8, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<8>(q8, xmin, xmax, quadType::Surface);
    }
    default:
        throw std::out_of_range("Wrapper does not support dimensions greater than eight i.e., 0 < dim <= 8");
    }
}

QuadScheme call_quad_multi_poly_volume(PhiData phiData, int p, int q) {
    //reference frame
    double xmin = -1.0;
    double xmax = 1.0;
    switch (phiData.dimension) {
    case 1: {
        PhiDataPolyRef<1> phi1(&phiData);
        auto q1 = outputQuadSchemeVolume<1, PhiDataPolyRef<1>>(phi1, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<1>(q1, xmin, xmax, quadType::Volume);
    }
    case 2: {
        PhiDataPolyRef<2> phi2(&phiData);
        auto q2 = outputQuadSchemeVolume<2, PhiDataPolyRef<2>>(phi2, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<2>(q2, xmin, xmax, quadType::Volume);
    }
    case 3: {
        PhiDataPolyRef<3> phi3(&phiData);
        auto q3 = outputQuadSchemeVolume<3, PhiDataPolyRef<3>>(phi3, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<3>(q3, xmin, xmax, quadType::Volume);
    }
    case 4: {
        PhiDataPolyRef<4> phi4(&phiData);
        auto q4 = outputQuadSchemeVolume<4, PhiDataPolyRef<4>>(phi4, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<4>(q4, xmin, xmax, quadType::Volume);;
    }
    case 5: {
        PhiDataPolyRef<5> phi5(&phiData);
        auto q5 = outputQuadSchemeVolume<5, PhiDataPolyRef<5>>(phi5, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<5>(q5, xmin, xmax, quadType::Volume);
    }
    case 6: {
        PhiDataPolyRef<6> phi6(&phiData);
        auto q6 = outputQuadSchemeVolume<6, PhiDataPolyRef<6>>(phi6, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<6>(q6, xmin, xmax, quadType::Volume);
    }
    case 7: {
        PhiDataPolyRef<7> phi7(&phiData);
        auto q7 = outputQuadSchemeVolume<7, PhiDataPolyRef<7>>(phi7, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<7>(q7, xmin, xmax, quadType::Volume);
    }
    case 8: {
        PhiDataPolyRef<8> phi8(&phiData);
        auto q8 = outputQuadSchemeVolume<8, PhiDataPolyRef<8>>(phi8, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<8>(q8, xmin, xmax, quadType::Volume);
    }
    default:
        throw std::out_of_range("Wrapper does not support dimensions greater than eight i.e., 0 < dim <= 8");
    }
}


QuadScheme call_quad_multi_poly_volume(Poly poly, int p, int q) {
    //reference frame
    double xmin = -1.0;
    double xmax = 1.0;
    switch (poly.dimension) {
    case 1: {
        PhiPolyRef<1> phi1(&poly);
        auto q1 = outputQuadSchemeVolume<1, PhiPolyRef<1>>(phi1, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<1>(q1, xmin, xmax, quadType::Volume);
    }
    case 2: {
        PhiPolyRef<2> phi2(&poly);
        auto q2 = outputQuadSchemeVolume<2, PhiPolyRef<2>>(phi2, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<2>(q2, xmin, xmax, quadType::Volume);
    }
    case 3: {
        PhiPolyRef<3> phi3(&poly);
        auto q3 = outputQuadSchemeVolume<3, PhiPolyRef<3>>(phi3, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<3>(q3, xmin, xmax, quadType::Volume);
    }
    case 4: {
        PhiPolyRef<4> phi4(&poly);
        auto q4 = outputQuadSchemeVolume<4, PhiPolyRef<4>>(phi4, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<4>(q4, xmin, xmax, quadType::Volume);;
    }
    case 5: {
        PhiPolyRef<5> phi5(&poly);
        auto q5 = outputQuadSchemeVolume<5, PhiPolyRef<5>>(phi5, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<5>(q5, xmin, xmax, quadType::Volume);
    }
    case 6: {
        PhiPolyRef<6> phi6(&poly);
        auto q6 = outputQuadSchemeVolume<6, PhiPolyRef<6>>(phi6, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<6>(q6, xmin, xmax, quadType::Volume);
    }
    case 7: {
        PhiPolyRef<7> phi7(&poly);
        auto q7 = outputQuadSchemeVolume<7, PhiPolyRef<7>>(phi7, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<7>(q7, xmin, xmax, quadType::Volume);
    }
    case 8: {
        PhiPolyRef<8> phi8(&poly);
        auto q8 = outputQuadSchemeVolume<8, PhiPolyRef<8>>(phi8, xmin, xmax, p, q);
        return CastMultiPolQuadScheme<8>(q8, xmin, xmax, quadType::Volume);
    }
    default:
        throw std::out_of_range("Wrapper does not support dimensions greater than eight i.e., 0 < dim <= 8");
    }
}

/// <summary>
/// Return both surface and volume quad rules
/// </summary>
/// <param name="phiData">level set data</param>
/// <param name="p">number of points (level set degree + 1)</param>
/// <param name="q">requested degree of quadrature</param>
/// <returns></returns>
QuadSchemeCombo call_quad_multi_poly_combo(PhiData phiData, int p, int q) {
    //reference frame
    double xmin = -1.0;
    double xmax = 1.0;
    switch (phiData.dimension) {
    case 1: {
        throw std::out_of_range("Surface integrals are supported only for N > 1");
    }
    case 2: {
        PhiDataPolyRef<2> phi2(&phiData);
        auto q2 = outputQuadSchemeCombo<2, PhiDataPolyRef<2>>(phi2, xmin, xmax, p, q);
        return CastMultiPolQuadSchemeCombo<2>(q2, xmin, xmax, quadType::Volume);
    }
    case 3: {
        PhiDataPolyRef<3> phi3(&phiData);
        auto q3 = outputQuadSchemeCombo<3, PhiDataPolyRef<3>>(phi3, xmin, xmax, p, q);
        return CastMultiPolQuadSchemeCombo<3>(q3, xmin, xmax, quadType::Volume);
    }
    case 4: {
        PhiDataPolyRef<4> phi4(&phiData);
        auto q4 = outputQuadSchemeCombo<4, PhiDataPolyRef<4>>(phi4, xmin, xmax, p, q);
        return CastMultiPolQuadSchemeCombo<4>(q4, xmin, xmax, quadType::Volume);;
    }
    case 5: {
        PhiDataPolyRef<5> phi5(&phiData);
        auto q5 = outputQuadSchemeCombo<5, PhiDataPolyRef<5>>(phi5, xmin, xmax, p, q);
        return CastMultiPolQuadSchemeCombo<5>(q5, xmin, xmax, quadType::Volume);
    }
    case 6: {
        PhiDataPolyRef<6> phi6(&phiData);
        auto q6 = outputQuadSchemeCombo<6, PhiDataPolyRef<6>>(phi6, xmin, xmax, p, q);
        return CastMultiPolQuadSchemeCombo<6>(q6, xmin, xmax, quadType::Volume);
    }
    case 7: {
        PhiDataPolyRef<7> phi7(&phiData);
        auto q7 = outputQuadSchemeCombo<7, PhiDataPolyRef<7>>(phi7, xmin, xmax, p, q);
        return CastMultiPolQuadSchemeCombo<7>(q7, xmin, xmax, quadType::Volume);
    }
    case 8: {
        PhiDataPolyRef<8> phi8(&phiData);
        auto q8 = outputQuadSchemeCombo<8, PhiDataPolyRef<8>>(phi8, xmin, xmax, p, q);
        return CastMultiPolQuadSchemeCombo<8>(q8, xmin, xmax, quadType::Volume);
    }
    default:
        throw std::out_of_range("Wrapper does not support dimensions greater than eight i.e., 0 < dim <= 8");
    }
}

QuadScheme call_quad_multi_poly(Poly poly, int p, int q, quadType type) {

    if (type == quadType::Surface)
        return call_quad_multi_poly_surface(poly, p, q);
    else if (type == quadType::Volume)
        return call_quad_multi_poly_volume(poly, p, q);
    else
        throw std::out_of_range("Unknown type of quadrature type, it should be either surface or volume");
}

QuadScheme call_quad_multi_poly_withData(PhiData PhiData, int p, int q, quadType type) {

    if (type == quadType::Surface)
        return call_quad_multi_poly_surface(PhiData, p, q);
    else if (type == quadType::Volume)
        return call_quad_multi_poly_volume(PhiData, p, q);
    else
        throw std::out_of_range("Unknown type of quadrature type, it should be either surface or volume");
}

QuadSchemeCombo call_quad_multi_poly_withDataCombo(PhiData PhiData, int p, int q, quadType type) {
        return call_quad_multi_poly_combo(PhiData, p, q);
}

int example_calculation(int a) {
	printf("Hello world");

    std::cout << "Algoim Examples - High-order quadrature algorithms for implicitly defined domains\n\n";
    std::cout << std::fixed << std::setprecision(16);

    // Area of a 2D ellipse using automatic subdivision
    {
        std::cout << "Area of a 2D ellipse using automatic subdivision:\n";
        Ellipsoid<2> phi;
        auto q = quadGen<2>(phi, HyperRectangle<double, 2>(-1.1, 1.1), -1, -1, 4);
        for (const auto& node : q.nodes) {
            std::cout << "x: " << node.x << " w: " << node.w << "\n";
            // 'node' represents each individual node in the 'nodes' container
            // You can perform operations on 'node' here
            // For example, you can access members or call member functions of 'node'
        }
        double area = q([](const auto& x) { return 1.0; });
        std::cout << "  computed area = " << area << "\n";
        std::cout << "    (exact area = 1.5707963267948966)\n\n";
    }

	return 0;
}