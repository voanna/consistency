#include "mex.h"

/*
  computes the chi² distance between the input arguments
  d(X,Y) = sum ((X(i)-Y(i))²)/(X(i)+Y(i))
*/

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	double *vecA, *vecB, *pA,*pB;
	double *dist, d1,d2;
	unsigned int i,j,ptsA,ptsB,dim,k,kptsA,kptsB;

	if (nrhs != 2){
		mexPrintf("at least two input arguments expected.");
		return;
	}

	if (mxGetNumberOfDimensions(prhs[0]) != 2 || mxGetNumberOfDimensions(prhs[1]) != 2)
	{
		mexPrintf("inputs must be two dimensional");
		return;
	}

	vecA = mxGetPr(prhs[0]);
	vecB = mxGetPr(prhs[1]);

	ptsA = mxGetM(prhs[0]);
	ptsB = mxGetM(prhs[1]);
	dim = mxGetN(prhs[0]);

	plhs[0] = mxCreateDoubleMatrix(ptsA,ptsB , mxREAL);
	dist = (double *)mxGetPr(plhs[0]);

	for ( i=0,pA=vecA ; i<ptsA ; i++,pA++ )
		for ( j=0,pB=vecB ; j<ptsB ; j++,pB++ )
		{
			for ( k=0,kptsA=0,kptsB=0 ; k<dim ; k++,kptsA+=ptsA,kptsB+=ptsB )
			{
				d1 = (pA[kptsA]-pB[kptsB])*(pA[kptsA]-pB[kptsB]);
				d2 = pA[kptsA]+pB[kptsB];
				dist[i+j*ptsA] += d1/(d2+1e-20);
			}


		}
	return;
}




