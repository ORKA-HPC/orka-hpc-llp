#include <sys/types.h> 
#include <math.h>
#include <stdio.h>
#include "liborkaxomp.h" 
#define N 1000

int check(int foo[1000],double bar[1000])
{
  if (foo[3] == 42 && bar[3] == 42) {
    printf("Success! Actual output matches the expected output!\n");
    return 0;
  }
   else {
    printf("foo[3] %d\n",foo[3]);
    printf("bar[3] %lf\n",bar[3]);
    return 1;
  }
}
static void OUT__1__7056__(unsigned long foop__,unsigned long barp__,int devid);

int main()
{
{
    xomp_set_verbose(1);
    struct llp_plugin llpPluginForDevid_0_defaultSpec;
    xomp_llp_load_plugin("llp_impl_ap2.so",&llpPluginForDevid_0_defaultSpec);
    int num_of_devices;
    num_of_devices = 1;
    xomp_init_plugin_map(num_of_devices);
    xomp_init_context_map(num_of_devices);
    xomp_insert_llp_plugin(0,&llpPluginForDevid_0_defaultSpec);
    xomp_insert_llp_context(0,(llpPluginForDevid_0_defaultSpec . init(1)));
    xomp_stage_deinitialisation(0);
  }
  xomp_acc_init();
  int foo[1000] = {(0)};
  double bar[1000] = {(0)};
  printf("bar[3] = %lf\n",bar[3]);
  printf("foo[3] = %d\n",foo[3]);
/* #pragma omp target map(tofrom : foo,bar) device(0){xomp_deviceDataEnvironmentEnter(0);unsigned long  ... */
{
    xomp_deviceDataEnvironmentEnter(0);
    unsigned long _dev_foo;
    int _dev_foo_size[1] = {1000};
    int _dev_foo_offset[1] = {0};
    int _dev_foo_dim[1] = {1000};
    _dev_foo = ((unsigned long )(xomp_deviceDataEnvironmentPrepareVariable(0,(void *)foo,1,sizeof(int ),_dev_foo_size,_dev_foo_offset,_dev_foo_dim,1,1)));
    unsigned long _dev_bar;
    int _dev_bar_size[1] = {1000};
    int _dev_bar_offset[1] = {0};
    int _dev_bar_dim[1] = {1000};
    _dev_bar = ((unsigned long )(xomp_deviceDataEnvironmentPrepareVariable(0,(void *)bar,1,sizeof(double ),_dev_bar_size,_dev_bar_offset,_dev_bar_dim,1,1)));
    OUT__1__7056__(_dev_foo,_dev_bar,0);
    xomp_deviceDataEnvironmentExit(0);
  }
  printf("bar[3] = %lf\n",bar[3]);
  printf("foo[3] = %d\n",foo[3]);
  return check(foo,bar);
}

static void OUT__1__7056__(unsigned long foop__,unsigned long barp__,int devid)
{
  struct llp_plugin *p;
  void *llp_context;
  p = xomp_get_llp_plugin_for_deviceid(devid);
  llp_context = xomp_get_llp_context_for_deviceid(devid);
  char typeArr[3];
  typeArr[0] = sizeof(unsigned long );
  typeArr[1] = sizeof(unsigned long );
  typeArr[2] = '\0';
  (p -> launch_blocking)("HlsKernel1000",1000,llp_context,typeArr,foop__,barp__,devid);
}
void HlsKernel1000(int (*OrkaParam0)[1000],double (*OrkaParam1)[1000]);

void HlsKernel1000(int (*OrkaParam0)[1000],double (*OrkaParam1)[1000])
{
  
#pragma HLS INTERFACE s_axilite port=return
  
#pragma HLS INTERFACE m_axi offset=slave port=OrkaParam0
  
#pragma HLS INTERFACE m_axi offset=slave port=OrkaParam1
  int (*foo)[1000] = (int (*)[1000])OrkaParam0;
  double (*bar)[1000] = (double (*)[1000])OrkaParam1;
  ( *foo)[3] = 42;
  ( *bar)[3] = ((double )( *foo)[3]);
}
