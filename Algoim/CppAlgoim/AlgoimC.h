#pragma once

#ifdef _WIN32
#define DLL_EXPORT __declspec(dllexport) //windows
#else
#define DLL_EXPORT __attribute__((visibility("default"))) //linux
#endif

DLL_EXPORT QuadScheme BoSSS_GetVolumeScheme(const int dim, const int p, const int q, const int* sizes, const double* x, const double* y);
DLL_EXPORT QuadScheme BoSSS_GetSurfaceScheme(const int dim, const int p, const int q, const int* sizes, const double* x, const double* y);
DLL_EXPORT QuadSchemeCombo BoSSS_GetComboScheme(const int dim, const int p, const int q, const int* sizes, const double* x, const double* y);
DLL_EXPORT QuadScheme* BoSSS_GetVolumeSchemeTwoLS(const int dim, const int p1, const int p2, const int q, const int* sizes1, const int* sizes2, const double* x1, const double* x2, const double* y1, const double* y2);
DLL_EXPORT QuadScheme* BoSSS_GetSurfaceSchemeTwoLS(const int dim, const int p1, const int p2, const int q, const int* sizes1, const int* sizes2, const double* x1, const double* x2, const double* y1, const double* y2);
DLL_EXPORT QuadSchemeCombo BoSSS_GetComboSchemeTwoLS(const int dim, const int p1, const int p2, const int q, const int* sizes1, const int* sizes2, const double* x1, const double* x2, const double* y1, const double* y2);

