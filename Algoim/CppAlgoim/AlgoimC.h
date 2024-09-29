#pragma once

#ifdef _WIN32
#define DLL_EXPORT __declspec(dllexport) //windows
#else
#define DLL_EXPORT __attribute__((visibility("default"))) //linux
#endif

DLL_EXPORT QuadScheme BoSSS_GetVolumeScheme(const int dim, const int p, const int q, const int* sizes, const double* x, const double* y);
DLL_EXPORT QuadScheme BoSSS_GetSurfaceScheme(const int dim, const int p, const int q, const int* sizes, const double* x, const double* y);
