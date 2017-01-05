// xorshift* uniform prng with Box Muller transform

#include "cl_defs.h"

void xorshift(__private ulong *const x)
{
   *x ^= *x >> 12;
   *x ^= *x << 25;
   *x ^= *x >> 27;
}

__kernel
void gen_grands(__global ulong *const restrict state,
                __global real_t *const restrict grands)
{
   const size_t gid = get_global_id(0);
   const size_t gsz = get_global_size(0);

   for (size_t id=gid; id<N/2; id+=gsz)
   {
      ulong s0 = state[2*id+0];
      ulong s1 = state[2*id+1];

      xorshift(&s0);
      xorshift(&s1);

      state[2*id+0] = s0;
      state[2*id+1] = s1;

      // u0, u1 are between 0 and 1
      const ulong c = 0x2545F4914F6CDD1Dl;
      const real_t u0 = (s0 * c)/0xFFFFFFFFFFFFFFFF.p0;
      const real_t u1 = (s1 * c)/0xFFFFFFFFFFFFFFFF.p0;

      const real_t r = SQRT(-2*LOG(u0));

      // TODO: look into sincos(), sinpi(), cospi()
      const real_t costheta = COS(2*PI*u1);
      const real_t sintheta = SIN(2*PI*u1);

      grands[2*id+0] = r * costheta;
      grands[2*id+1] = r * sintheta;
   }
}