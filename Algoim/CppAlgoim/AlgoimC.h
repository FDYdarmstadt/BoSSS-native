#pragma once

#ifdef _WIN32
#define DLL_EXPORT __declspec(dllexport)
#else
#define DLL_EXPORT
#endif

DLL_EXPORT QuadScheme GetVolumeScheme(const int dim, const int p, const int q, const int* sizes, const double* x, const double* y);
DLL_EXPORT QuadScheme GetSurfaceScheme(const int dim, const int p, const int q, const int* sizes, const double* x, const double* y);
