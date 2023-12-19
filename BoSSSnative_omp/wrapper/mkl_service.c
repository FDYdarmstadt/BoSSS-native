#include <mkl_service.h>

//_Mkl_Api(int,MKL_Set_Num_Threads_Local,(int nth))
//#define mkl_set_num_threads         MKL_Set_Num_Threads
void BoSSS_set_num_threads(int nth) {
	mkl_set_num_threads(nth); 
}

//_Mkl_Api(int,MKL_Get_Max_Threads,(void))
//#define mkl_get_max_threads         MKL_Get_Max_Threads
int BoSSS_get_num_threads() {
	return mkl_get_max_threads()); 
}


//_Mkl_Api(void,MKL_Set_Num_Stripes,(int nstripes))
//#define mkl_set_num_stripes         MKL_Set_Num_Stripes

//_Mkl_Api(int,MKL_Get_Num_Stripes,(void))
//#define mkl_get_num_stripes         MKL_Get_Num_Stripes

//_Mkl_Api(int,MKL_Domain_Set_Num_Threads,(int nth, int MKL_DOMAIN))
//#define mkl_domain_set_num_threads  MKL_Domain_Set_Num_Threads

//_Mkl_Api(int,MKL_Domain_Get_Max_Threads,(int MKL_DOMAIN))
//#define mkl_domain_get_max_threads  MKL_Domain_Get_Max_Threads

//_Mkl_Api(void,MKL_Set_Dynamic,(int bool_MKL_DYNAMIC))
//#define mkl_set_dynamic             MKL_Set_Dynamic

//_Mkl_Api(int,MKL_Get_Dynamic,(void))
//#define mkl_get_dynamic             MKL_Get_Dynamic

