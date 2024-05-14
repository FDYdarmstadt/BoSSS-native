#pragma once
__declspec(dllexport) QuadScheme GetVolumeScheme(const int dim, const int p, const int q, const int* sizes, const double* x, const double* y);
__declspec(dllexport) QuadScheme GetSurfaceScheme(const int dim, const int p, const int q, const int* sizes, const double* x, const double* y);