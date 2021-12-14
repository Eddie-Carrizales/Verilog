
/**********************************************************************
Evan Nibbe
21 November 2021
better_base.c
This program is based on the work of steve icarus, using his format
which he used to calculate an integer to the power of an integer to
instead be used for things like my_sqrt, newton's method (for finding the 
roots of polynomials), and for getting user input.
the comments made by him are:
ivtest/vpi/pr1693971.c
Latest commit 89796a3 on Feb 26, 2015
History
1 contributor
209 lines (185 sloc) 6.99 KB
 * $my_pow example -- PLI application using VPI routines
 *
 * C source to calculate the result of a number to the power of an
 * exponent. The result is returned as a 32-bit integer.
 *
 * Usage: result = $my_pow(<base>,<exponent>);
 *
 * For the book, "The Verilog PLI Handbook" by Stuart Sutherland
 *  Copyright 1999 & 2001, Kluwer Academic Publishers, Norwell, MA, USA
 *   Contact: www.wkap.il
 *  Example copyright 1998, Sutherland HDL Inc, Portland, Oregon, USA
 *   Contact: www.sutherland-hdl.com
 *********************************************************************/

#define VPI_1995 0 /* set to non-zero for Verilog-1995 compatibility */

#include <stdlib.h>    /* ANSI C standard library */
#include <stdio.h>     /* ANSI C standard input/output library */
#include <stdarg.h>    /* ANSI C standard arguments library */
#include "vpi_user.h"  /* IEEE 1364 PLI VPI routine library  */

#if VPI_1995
#include "../vpi_1995_compat.h"  /* kludge new Verilog-2001 routines */
#endif

/* prototypes of PLI application routine names */
#ifdef IVERILOG_V0_8
static PLI_INT32 PLIbook_PowSizetf(char *user_data);
static PLI_INT32 PLIbook_PowCalltf(char *user_data);
static PLI_INT32 PLIbook_PowCompiletf(char *user_data);
static PLI_INT32 PLIbook_NewtonCalltf(char *user_data);
static PLI_INT32 PLIbook_NewtonCompiletf(char *user_data);
static PLI_INT32 PLIbook_UserCalltf(char *user_data);
static PLI_INT32 PLIbook_UserCompiletf(char *user_data);
#else
static PLI_INT32 PLIbook_PowSizetf(PLI_BYTE8 *user_data);
static PLI_INT32 PLIbook_PowCalltf(PLI_BYTE8 *user_data);
static PLI_INT32 PLIbook_PowCompiletf(PLI_BYTE8 *user_data);
static PLI_INT32 PLIbook_NewtonCalltf(PLI_BYTE8 *user_data);
static PLI_INT32 PLIbook_NewtonCompiletf(PLI_BYTE8 *user_data);
static PLI_INT32 PLIbook_UserCalltf(PLI_BYTE8 *user_data);
static PLI_INT32 PLIbook_UserCompiletf(PLI_BYTE8 *user_data);
#endif
static PLI_INT32 PLIbook_PowStartOfSim(s_cb_data *callback_data);

/**********************************************************************
 * $my_pow Registration Data
 * (add this function name to the vlog_startup_routines array)
 *********************************************************************/
void my_sqrt_register(void)
{
  s_vpi_systf_data tf_data;
  s_cb_data        cb_data_s;
  vpiHandle        callback_handle;

  tf_data.type        = vpiSysFunc;
  tf_data.sysfunctype = vpiSysFuncSized;
  tf_data.tfname      = "$my_sqrt";
  tf_data.calltf      = PLIbook_PowCalltf;
  tf_data.compiletf   = PLIbook_PowCompiletf;
  tf_data.sizetf      = PLIbook_PowSizetf;
  tf_data.user_data   = NULL;
  vpi_register_systf(&tf_data);

  cb_data_s.reason    = cbStartOfSimulation;
  cb_data_s.cb_rtn    = PLIbook_PowStartOfSim;
  cb_data_s.obj       = NULL;
  cb_data_s.time      = NULL;
  cb_data_s.value     = NULL;
  cb_data_s.user_data = NULL;
  callback_handle = vpi_register_cb(&cb_data_s);
  vpi_free_object(callback_handle);  /* don't need callback handle */
}

//the first argument is the estimate,
//the second argument is the number of numbers (the constant followed by coefficients of increasing powers of x)
void newton_register(void)
{
  s_vpi_systf_data tf_data;
  s_cb_data        cb_data_s;
  vpiHandle        callback_handle;

  tf_data.type        = vpiSysFunc;
  tf_data.sysfunctype = vpiSysFuncSized;
  tf_data.tfname      = "$newton";
  tf_data.calltf      = PLIbook_NewtonCalltf;
  tf_data.compiletf   = PLIbook_NewtonCompiletf;
  tf_data.sizetf      = PLIbook_PowSizetf;
  tf_data.user_data   = NULL;
  vpi_register_systf(&tf_data);

  cb_data_s.reason    = cbStartOfSimulation;
  cb_data_s.cb_rtn    = PLIbook_PowStartOfSim;
  cb_data_s.obj       = NULL;
  cb_data_s.time      = NULL;
  cb_data_s.value     = NULL;
  cb_data_s.user_data = NULL;
  callback_handle = vpi_register_cb(&cb_data_s);
  vpi_free_object(callback_handle);  /* don't need callback handle */
}

//for getting user input, this will take two dummy arguments.
void user_register(void)
{
  s_vpi_systf_data tf_data;
  s_cb_data        cb_data_s;
  vpiHandle        callback_handle;

  tf_data.type        = vpiSysFunc;
  tf_data.sysfunctype = vpiSysFuncSized;
  tf_data.tfname      = "$user";
  tf_data.calltf      = PLIbook_UserCalltf;
  tf_data.compiletf   = PLIbook_UserCompiletf;
  tf_data.sizetf      = PLIbook_PowSizetf;
  tf_data.user_data   = NULL;
  vpi_register_systf(&tf_data);

  cb_data_s.reason    = cbStartOfSimulation;
  cb_data_s.cb_rtn    = PLIbook_PowStartOfSim;
  cb_data_s.obj       = NULL;
  cb_data_s.time      = NULL;
  cb_data_s.value     = NULL;
  cb_data_s.user_data = NULL;
  callback_handle = vpi_register_cb(&cb_data_s);
  vpi_free_object(callback_handle);  /* don't need callback handle */
}

/**********************************************************************
 * Sizetf application
 *********************************************************************/
#ifdef IVERILOG_V0_8
static PLI_INT32 PLIbook_PowSizetf(char *user_data)
#else
static PLI_INT32 PLIbook_PowSizetf(PLI_BYTE8 *user_data)
#endif
{
  (void)user_data;  /* Parameter is not used. */
  //vpi_printf("\n$my_pow PLI sizetf function.\n\n");
  return(32);   /* $my_pow returns 32-bit values */
}

/**********************************************************************
 * compiletf application to verify valid systf args.
 *********************************************************************/
#ifdef IVERILOG_V0_8
static PLI_INT32 PLIbook_PowCompiletf(char *user_data)
#else
static PLI_INT32 PLIbook_PowCompiletf(PLI_BYTE8 *user_data)
#endif
{
  vpiHandle systf_handle, arg_itr, arg_handle;
  PLI_INT32 tfarg_type;
  int       err_flag = 0;

  (void)user_data;  /* Parameter is not used. */

  vpi_printf("\n$my_sqrt PLI compiletf function.\n\n");

  do { /* group all tests, so can break out of group on error */
    systf_handle = vpi_handle(vpiSysTfCall, NULL);
    arg_itr = vpi_iterate(vpiArgument, systf_handle);
    if (arg_itr == NULL) {
      vpi_printf("ERROR: $my_sqrt requires 1 argument; has none\n");
      err_flag = 1;
      break;
    }
    arg_handle = vpi_scan(arg_itr);
    tfarg_type = vpi_get(vpiType, arg_handle);
    if ( (tfarg_type != vpiReg) &&
         (tfarg_type != vpiIntegerVar) &&
         (tfarg_type != vpiConstant)   ) {
      vpi_printf("ERROR: $my_sqrt arg1 must be number, variable or net\n");
      err_flag = 1;
      break;
    }
    arg_handle = vpi_scan(arg_itr);
    if (arg_handle != NULL) {
      vpi_printf("ERROR: $my_sqrt only takes 1 argument\n");
      err_flag = 1;
      break;
    }
  } while (0 == 1); /* end of test group; only executed once */

  if (err_flag) {
    vpi_control(vpiFinish, 1);  /* abort simulation */
  }
  return(0);
}
#ifdef IVERILOG_V0_8
static PLI_INT32 PLIbook_NewtonCompiletf(char *user_data)
#else
static PLI_INT32 PLIbook_NewtonCompiletf(PLI_BYTE8 *user_data)
#endif
{
  vpiHandle systf_handle, arg_itr, arg_handle;
  PLI_INT32 tfarg_type;
  int       err_flag = 0;

  (void)user_data;  /* Parameter is not used. */

  vpi_printf("\n$newton PLI compiletf function.\n\n");

  do { /* group all tests, so can break out of group on error */
    systf_handle = vpi_handle(vpiSysTfCall, NULL);
    arg_itr = vpi_iterate(vpiArgument, systf_handle);
    if (arg_itr == NULL) {
      vpi_printf("ERROR: $newton requires 3 arguments; has none\n");
      err_flag = 1;
      break;
    }
    arg_handle = vpi_scan(arg_itr);
    tfarg_type = vpi_get(vpiType, arg_handle);
    if ( (tfarg_type != vpiReg) &&
         (tfarg_type != vpiIntegerVar) &&
         (tfarg_type != vpiConstant)   ) {
      vpi_printf("ERROR: $newton arg1 must be number, variable or net\n");
      err_flag = 1;
      break;
    }
    arg_handle = vpi_scan(arg_itr);
    if (arg_handle == NULL) {
      vpi_printf("ERROR: $newton requires 2nd argument\n");
      err_flag = 1;
      break;
    }
    tfarg_type = vpi_get(vpiType, arg_handle);
    if ( (tfarg_type != vpiReg) &&
         (tfarg_type != vpiIntegerVar) &&
         (tfarg_type != vpiConstant)   ) {
      vpi_printf("ERROR: $newton arg2 must be number, variable or net\n");
      err_flag = 1;
      break;
    }
    if (vpi_scan(arg_itr) == NULL) {
      vpi_printf("ERROR: $newton requires 3 arguments; has too few\n");
      vpi_free_object(arg_itr);
      err_flag = 1;
      break;
    }
  } while (0 == 1); /* end of test group; only executed once */

  if (err_flag) {
    vpi_control(vpiFinish, 1);  /* abort simulation */
  }
  return(0);
}
#ifdef IVERILOG_V0_8
static PLI_INT32 PLIbook_UserCompiletf(char *user_data)
#else
static PLI_INT32 PLIbook_UserCompiletf(PLI_BYTE8 *user_data)
#endif
{
	//no arguments are technically required.

  (void)user_data;  /* Parameter is not used. */



  return(0);
}

/**********************************************************************
 * calltf to calculate base to power of exponent and return result.
 *********************************************************************/
#include <math.h>
#ifdef IVERILOG_V0_8
static PLI_INT32 PLIbook_PowCalltf(char *user_data)
#else
static PLI_INT32 PLIbook_PowCalltf(PLI_BYTE8 *user_data)
#endif
{
  s_vpi_value value_s;
  vpiHandle   systf_handle, arg_itr, arg_handle;
  PLI_INT32   base;
  double      result;

  (void)user_data;  /* Parameter is not used. */

  //vpi_printf("\n$my_pow PLI calltf function.\n\n");

  systf_handle = vpi_handle(vpiSysTfCall, NULL);
  arg_itr = vpi_iterate(vpiArgument, systf_handle);
  if (arg_itr == NULL) {
    vpi_printf("ERROR: $my_sqrt failed to obtain systf arg handles\n");
    return(0);
  }

  /* read base from systf arg 1 (compiletf has already verified) */
  arg_handle = vpi_scan(arg_itr);
  value_s.format = vpiIntVal;
  vpi_get_value(arg_handle, &value_s);
  base = value_s.value.integer;

  /* read exponent from systf arg 2 (compiletf has already verified) */
  //arg_handle = vpi_scan(arg_itr);
  vpi_free_object(arg_itr); /* not calling scan until returns null */
  //vpi_get_value(arg_handle, &value_s);
  //expo = value_s.value.integer;

  /* calculate result of base to power of exponent */
  result = sqrt( (double)base)*10000;

  /* write result to simulation as return value $my_pow */
  value_s.value.integer = (PLI_INT32)result;
  vpi_put_value(systf_handle, &value_s, NULL, vpiNoDelay);
  return(0);
}
static double orig_f(int n, int *array, double est) {
        if (n<=0) return 0;
        double x=est;
        double result=array[0];
        for (int i=1; i<n; i++) {
                result+=array[i]*x;
                x*=est; //will go to square, then cube, then ^4, and on
        }
        return result;
}
static double deriv_f(int n, int *array, double est) {
        if (n<=1) return 0;
        double x=est;
        double result=array[1];
        for (int i=2; i<n; i++) {
                result+=array[i]*x*i; //x^2 now is 2*x
                x*=est;
        }
        return result;
}
static double iteration(int n, int *array, double est) {
        double der=deriv_f(n, array, est);
        if (der<.0001 && der>-.0001) return est; //if the derivative gets too close to 0, then this means we are where we are closest to a result
        return est-orig_f(n, array, est)/der;
}
#ifdef IVERILOG_V0_8
static PLI_INT32 PLIbook_NewtonCalltf(char *user_data)
#else
static PLI_INT32 PLIbook_NewtonCalltf(PLI_BYTE8 *user_data)
#endif
{
  s_vpi_value value_s;
  vpiHandle   systf_handle, arg_itr, arg_handle;
  PLI_INT32   num_args, *array, i;
  double      result, est;

  (void)user_data;  /* Parameter is not used. */

  //vpi_printf("\n$my_pow PLI calltf function.\n\n");

  systf_handle = vpi_handle(vpiSysTfCall, NULL);
  arg_itr = vpi_iterate(vpiArgument, systf_handle);
  if (arg_itr == NULL) {
    vpi_printf("ERROR: $newton failed to obtain systf arg handles\n");
    return(0);
  }

  /* read base from systf arg 1 (compiletf has already verified) */
  arg_handle = vpi_scan(arg_itr);
  value_s.format = vpiIntVal;
  vpi_get_value(arg_handle, &value_s);
  est = value_s.value.integer;

  /* read exponent from systf arg 2 (compiletf has already verified) */
  arg_handle = vpi_scan(arg_itr);
  vpi_get_value(arg_handle, &value_s);
  num_args = value_s.value.integer;
	array=(PLI_INT32*)malloc(sizeof(PLI_INT32)*num_args);
	for (i=0; i<num_args && arg_itr!=NULL; i++) {
  		arg_handle = vpi_scan(arg_itr);
  		vpi_get_value(arg_handle, &value_s);
  		array[i] = value_s.value.integer;
	}
  vpi_free_object(arg_itr); /* not calling scan until returns null */

  /* calculate result of base to power of exponent */
  result = iteration(num_args, array, est); //pow( (double)base, (double)expo );
	while (fabs(result-est)>.0001) {
		est=result;
		result=iteration(num_args, array, est);
	}
	free(array);
	vpi_printf("On the C side, the result of Newton's method was %f\n", result);
	result*=10000;
  /* write result to simulation as return value $my_pow */
  value_s.value.integer = (PLI_INT32)result;
  vpi_put_value(systf_handle, &value_s, NULL, vpiNoDelay);
  return(0);
}
#ifdef IVERILOG_V0_8
static PLI_INT32 PLIbook_UserCalltf(char *user_data)
#else
static PLI_INT32 PLIbook_UserCalltf(PLI_BYTE8 *user_data)
#endif
{
  s_vpi_value value_s;
  vpiHandle   systf_handle, arg_itr;
  int      result; //, c, neg;

  (void)user_data;  /* Parameter is not used. */

  //vpi_printf("\n$my_pow PLI calltf function.\n\n");

  systf_handle = vpi_handle(vpiSysTfCall, NULL);
  arg_itr = vpi_iterate(vpiArgument, systf_handle);
  if (arg_itr == NULL) {
    ;
	//vpi_printf("ERROR: $my_pow failed to obtain systf arg handles\n");
    //return(0);
  }

  /* read base from systf arg 1 (compiletf has already verified) */
  //arg_handle = vpi_scan(arg_itr);
  //value_s.format = vpiIntVal;
  //vpi_get_value(arg_handle, &value_s);
  //base = value_s.value.integer;

  /* read exponent from systf arg 2 (compiletf has already verified) */
  //arg_handle = vpi_scan(arg_itr);
  vpi_free_object(arg_itr); /* not calling scan until returns null */
  //vpi_get_value(arg_handle, &value_s);
  //expo = value_s.value.integer;

  /* calculate result of base to power of exponent */
  result = 0; //pow( (double)base, (double)expo );
	//c=' ';
	//neg=1;
	//vpi_scanf("%d\n", &result);
	//while ((c=getchar()) && c!=EOF && c!='\n') {
	//	if (c<='9' && c>='0') {
	//		result*=10;
	//		result+=c-'0';
	//	}
	//	if (c=='-') {
	//		neg=-1;
	//	}
	//}
	//result*=neg;

  /* write result to simulation as return value $my_pow */
  value_s.value.integer = (PLI_INT32)result;
  vpi_put_value(systf_handle, &value_s, NULL, vpiNoDelay);
  return(0);
}

/**********************************************************************
 * Start-of-simulation application
 *********************************************************************/
static PLI_INT32 PLIbook_PowStartOfSim(s_cb_data *callback_data)
{
  (void)callback_data;  /* Parameter is not used. */
  vpi_printf("\nStartOfSim callback for VPI functions.\n\n");
  return(0);
}
/*********************************************************************/


void (*vlog_startup_routines[])(void) =
{
    /*** add user entries here ***/
  my_sqrt_register,
	newton_register,
	//user_register, //it seems that the wait time on user input is too long for verilog to handle
  //PLIbook_test_user_data_register,
  0 /*** final entry must be 0 ***/
};
