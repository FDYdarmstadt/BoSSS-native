#define PARAM1              void* _1
#define PARAM2     PARAM1,  void* _2
#define PARAM3     PARAM2,  void* _3
#define PARAM4     PARAM3,  void* _4
#define PARAM5     PARAM4,  void* _5
#define PARAM6     PARAM5,  void* _6
#define PARAM7     PARAM6,  void* _7
#define PARAM8     PARAM7,  void* _8
#define PARAM9     PARAM8,  void* _9
#define PARAM10    PARAM9,  void* _10
#define PARAM11    PARAM10, void* _11
#define PARAM12    PARAM11, void* _12
#define PARAM13    PARAM12, void* _13

#define CALL1              _1
#define CALL2      CALL1,  _2
#define CALL3      CALL2,  _3
#define CALL4      CALL3,  _4
#define CALL5      CALL4,  _5
#define CALL6      CALL5,  _6
#define CALL7      CALL6,  _7
#define CALL8      CALL7,  _8
#define CALL9      CALL8,  _9
#define CALL10     CALL9,  _10
#define CALL11     CALL10, _11
#define CALL12     CALL11, _12
#define CALL13     CALL12, _13


#ifdef _WINDOWS
#define DLL_EXPORT __declspec(dllexport)
#define METIS_API
#else
#define DLL_EXPORT
#define METIS_API
#endif


#define MAKE_FORTRAN_EXPORT(funcname,NoArgs)         \
void METIS_API funcname(PARAM##NoArgs);                     \
DLL_EXPORT void BoSSS_##funcname(PARAM##NoArgs) {      \
    funcname(CALL##NoArgs);                  \
}
