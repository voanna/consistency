#include <mex.h>
#include "chi2double.h"
#include "chi2float.h"

/*
  computes the chi² distance between the input arguments
  d(X,Y) = sum ((X(i)-Y(i))²)/(X(i)+Y(i))
*/

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	if (nrhs == 0)
	{
		mexPrintf("Usage: d = chi2_mex(X,Y);\n");
		mexPrintf("where X and Y are matrices of dimension [dim,npts]\n");
		mexPrintf("\nExample\n a = rand(2,10);\n b = rand(2,20);\n d = chi2_mex(a,b);\n");
		return;
	}

	if (nrhs != 1 && nrhs != 2){
		mexPrintf("one or two arguments required");
		return;
	}

	switch (nrhs) {
	case 1:{
		unsigned int dim = mxGetM(prhs[0]);
		unsigned int pts = mxGetN(prhs[0]);
		mwSize dims[2];
		dims[0] = (mwSize)pts; dims[1] = (mwSize)pts;

		mxClassID type = mxGetClassID(prhs[0]);

		switch (type) {
		case mxSINGLE_CLASS:{
			float *vecA = (float*)mxGetPr(prhs[0]);
			plhs[0] =  mxCreateNumericArray(2, dims, type, mxREAL);
			float *dist = (float *)mxGetPr(plhs[0]);
			for (unsigned int i=0; i<pts; i++){
				dist[i*pts+i]=0.0;
				for (unsigned int j=i+1; j<pts; j++){
					chi2_distance_float(dim,(int)1,&vecA[i*dim],(int)1,&vecA[j*dim],&dist[i*pts+j]);
					dist[j*pts+i] = dist[i*pts+j];
				}
			}
			break;
		}
		case mxDOUBLE_CLASS:{
			double *vecA = mxGetPr(prhs[0]);
			plhs[0] =  mxCreateNumericArray(2, dims, type, mxREAL);
			double *dist = (double *)mxGetPr(plhs[0]);
			for (unsigned int i=0; i<pts; i++){
				dist[i*pts+i]=0.0;
				for (unsigned int j=i; j<pts; j++){
					chi2_distance_double(dim,1,&vecA[i*dim],1,&vecA[j*dim],&dist[i*pts+j]);
					dist[j*pts+i] = dist[i*pts+j];
				}
			}
			break;

		}
		default:
			mexPrintf("input type not supported\n");
			return;
		}
		break;
	}
	case 2:{

		if (mxGetNumberOfDimensions(prhs[0]) != 2 || mxGetNumberOfDimensions(prhs[1]) != 2)
		{
			mexPrintf("inputs must be two dimensional");
			return;
		}

		unsigned int dim = mxGetM(prhs[0]);

		if (dim != mxGetM(prhs[1]))
		{
			mexPrintf("Dimension mismatch");
			return;
		}

		unsigned int ptsA = mxGetN(prhs[0]);
		unsigned int ptsB = mxGetN(prhs[1]);

		mwSize dims[2];
		dims[0]= ptsA;
		dims[1]= ptsB;

		mxClassID type = mxGetClassID(prhs[0]);

		switch (type) {
		case mxSINGLE_CLASS:{
			float *vecA = (float*)mxGetPr(prhs[0]);
			float *vecB = (float*)mxGetPr(prhs[1]);
			plhs[0] =  mxCreateNumericArray(2, dims, type, mxREAL);
			float *dist = (float *)mxGetPr(plhs[0]);
			chi2_distance_float(dim,ptsB,vecB,ptsA,vecA,dist);
			break;
		}
		case mxDOUBLE_CLASS:{
			double *vecA = mxGetPr(prhs[0]);
			double *vecB = mxGetPr(prhs[1]);
			plhs[0] =  mxCreateNumericArray(2, dims, type, mxREAL);
			double *dist = (double *)mxGetPr(plhs[0]);
			chi2_distance_double(dim,ptsB,vecB,ptsA,vecA,dist);
			break;
		}
		default:
			mexPrintf("input type not supported\n");
			return;
		}
		break;
	}
	default:{
		assert(0);
	}
	}
		
	return;
}

