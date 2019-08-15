#define PARAM0
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
#define PARAM14    PARAM13, void* _14
#define PARAM15    PARAM14, void* _15
#define PARAM16    PARAM15, void* _16
#define PARAM83    PARAM16, void* _17, void* _18, void* _19, void* _20, void* _21, void* _22, void* _23, void* _24, void* _25, void* _26, void* _27, void* _28, void* _29, void* _30, void* _31, void* _32, void* _33, void* _34, void* _35, void* _36, void* _37, void* _38, void* _39, void* _40, void* _41, void* _42, void* _43, void* _44, void* _45, void* _46, void* _47, void* _48, void* _49, void* _50, void* _51, void* _52, void* _53, void* _54, void* _55, void* _56, void* _57, void* _58, void* _59, void* _60, void* _61, void* _62, void* _63, void* _64, void* _65, void* _66, void* _67, void* _68, void* _69, void* _70, void* _71, void* _72, void* _73, void* _74, void* _75, void* _76, void* _77, void* _78, void* _79, void* _80, void* _81, void* _82, void* _83

#define CALL0
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
#define CALL14     CALL13, _14
#define CALL15     CALL14, _15
#define CALL16     CALL15, _16
#define CALL83     CALL16, _17, _18, _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35, _36, _37, _38, _39, _40, _41, _42, _43, _44, _45, _46, _47, _48, _49, _50, _51, _52, _53, _54, _55, _56, _57, _58, _59, _60, _61, _62, _63, _64, _65, _66, _67, _68, _69, _70, _71, _72, _73, _74, _75, _76, _77, _78, _79, _80, _81, _82, _83

#ifdef _WINDOWS
#define DLL_EXPORT __declspec(dllexport)
#define dMUMPS_API
#else
#define DLL_EXPORT
#define dMUMPS_API
#endif


#define MAKE_FORTRAN_EXPORT(funcname,NoArgs)         \
void dMUMPS_API funcname(PARAM##NoArgs);                     \
DLL_EXPORT void BoSSS_##funcname(PARAM##NoArgs) {      \
    funcname(CALL##NoArgs);                  \
}
