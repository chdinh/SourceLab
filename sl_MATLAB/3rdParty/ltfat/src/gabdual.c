#include "config.h"
#include "ltfat.h"


void LTFAT_NAME(gabdual_long)(const LTFAT_COMPLEX *g,
			      const int L, const int a,
			      const int M, LTFAT_COMPLEX *gd)
{
   LTFAT_COMPLEX *gf = ltfat_malloc(L*sizeof(LTFAT_COMPLEX));
   LTFAT_COMPLEX *gdf = ltfat_malloc(L*sizeof(LTFAT_COMPLEX));
  
   LTFAT_NAME(wfac)(g, L, a, M, gf);
   LTFAT_NAME(gabdual_fac)((const LTFAT_COMPLEX *)gf,L,a,M,gdf);
   LTFAT_NAME(iwfac)((const LTFAT_COMPLEX *)gdf,L,a,M,gd);

   ltfat_free(gdf);
   ltfat_free(gf);

}


void LTFAT_NAME(gabdualreal_long)(const LTFAT_REAL *g,
				  const int L, const int a,
				  const int M, LTFAT_REAL *gd)
{
   LTFAT_COMPLEX *gf = ltfat_malloc(L*sizeof(LTFAT_COMPLEX));
   LTFAT_COMPLEX *gdf = ltfat_malloc(L*sizeof(LTFAT_COMPLEX));
  
   LTFAT_NAME(wfac_r)(g, L, a, M, gf);
   LTFAT_NAME(gabdual_fac)((const LTFAT_COMPLEX *)gf,L,a,M,gdf);
   LTFAT_NAME(iwfac_r)((const LTFAT_COMPLEX *)gdf,L,a,M,gd);

   ltfat_free(gdf);
   ltfat_free(gf);

}
