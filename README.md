Predicting When Saliency Maps are Accurate and Eye Fixations Consistent
=================
Anna Volokitin, Michael Gygli, Xavier Boix, CVPR 2016

Send feedback, suggestions and questions to voanna AT vision.ee.ethz.ch
____
This is a simplified version of the code written for the computational experiments to test whether we can predict the accuracy of saliency maps and the consistency of eye-fixations among different observers directly from the image.  Our experimental results are reported in the [paper](http://www.cv-foundation.org/openaccess/content_cvpr_2016/papers/Volokitin_Predicting_When_Saliency_CVPR_2016_paper.pdf).

###Paths
All of the paths in the script are relative to the symlink `~/predicting_constistency`.  So if you download this project and symlink it to `~/predicting_constistency`, everything should just work

### Datasets
#### MIT1003
Download the MIT1003 dataset of eye fixations and associated evaluation code from the  "Eye tracking database" section of http://people.csail.mit.edu/tjudd/WherePeopleLook/index.html	into the data/MIT/ directory (you need to create this directory first)

You will also need to download the evaluation code from the MIT Saliency Benchmark https://github.com/cvzoya/saliency, which you can also place into the data/MIT/ directory.  Make sure to add it onto the matlab path as well

####PASCAL 
850 images from Pascal 2010, described in http://cbi.gatech.edu/salobj/, download from http://cbi.gatech.edu/salobj/download/salObj.zip into data/pascal


### Saliency Maps
Your favorite saliency map algorithms should be placed in the `maps/` directory with uppercase model name (eg. JUDD) To compute the saliency accuracies, place saliency maps for the MIT1003 and Pascal datasets in the directories `maps/MIT` and `pascal/algmaps` respectively.  The saliency maps should have the same base filenames as the original images
Note that the saliency maps may need to be optimized by adding center bias and blur, as mentioned in the MIT Saliency Benchmark

### Saliency Accuracy
To evaluate the maps, run score_saliency.m in matlab, and set the paths at the top of the script. These accuracies will be saved to `outputs/accuracies/pascal` and `outputs/accuracies/MIT` as `model_scores.mat` files

### Extracting AlexNet features
#### Dependencies

 - Python with numpy
 - caffe + python bindings from http://caffe.berkeleyvision.org/installation.html

The relevant scripts are in `src/extract_features/`

First we need to get the weights of the reference caffe AlexNet model.  We can get these by running this script https://github.com/sguada/caffe-public/blob/master/models/get_caffe_reference_imagenet_model.sh in the `/path/to/caffe/examples/imagenet` directory.  You will get the weights in a file named `caffe_reference_imagenet_model`.  Now we just need to copy the `imagenet_deploy_1_crop.prototxt` file from the root directory of this project into the same directory as the weights

To extract the AlexNet features for each image in a directory, run
`python compute_deep_features.py image_directory output_directory layer` 
(more documentation inside the function)

The features will be saved as imagename.extention.txt in the output_directory. To be consistent with the rest of our functions, set `output_directory` to `outputs/features/MIT{pascal}/whole/`

To compute the spatial and semantic features as well, run
`python writeSemSpatFeatures.py,` which will place the features into `outputs/features/MIT{pascal}/sem/` and `outputs/features/MIT{pascal}/spat/`


### Eye-fixation Consistency (for MIT1003 only)
The `src/consistency/consistency_score_K_S.m` script will compute the eye fixation consistency values for `K` held-out observers and `S` splits using a particular metric.

The outputs will be saved to `outputs/consistencies/MIT/` as `.MAT` files
#### Dependencies
You need to download two scripts from the LabelMeToolbox and place them into the `src/consistency` directory

 1.  https://github.com/CSAILVision/LabelMeToolbox/blob/master/imagemanipulation/LMimpad.m
 2.  https://github.com/CSAILVision/LabelMeToolbox/blob/master/imagemanipulation/imresizepad.m

### Running the SVR
#### Dependencies
 - You need to download a matlab script for computing a cartesian product of cell arrays from https://www.mathworks.com/matlabcentral/fileexchange/10064-allcomb-varargin- and place it in the src/ directory
 - If using the chi^2 kernel for the SVR,  to get a fast chi^2 distance, compile chi2dist.m from the `third_party/mpi-chi2/` directory of this repository
 - LIBSVM with matlab bindings available from https://www.csie.ntu.edu.tw/~cjlin/libsvm/#download
 - To make the plots work you need to get `rotateXLabels.m` https://www.mathworks.com/matlabcentral/fileexchange/27812-rotate-x-axis-tick-labels/content/rotateXLabels.m

The function to regress from AlexNet features to saliency map accuracies and to eye-fixation consistency is the same, just the parameters are different.

The SVMs were run in a batch setting, which is why each instance of `compare_SVR(z)` computes one combination of the kernels, metrics, models, features, indexed by the input argument `z`.  To run all possible combinations, you have to run this script with all possible input indices.   Intermediate results (SVR loss, pearson and spearman correlation of prediction wrt to ground truth, as well as the C, gamma and p parameters of the SVR) of the computation will be stored in `outputs/svr/experiment-name/z.mat`  Note that a separate grid search was run for each `z`.

Make sure you are calling the svmtrain of LIBSVM and not the python built in one!

A matfile containing the parameters of the experiment will be saved as  `outputs/svr/experiment-name_setup.mat`
These results can then be assembled into one tensor by calling `assemble_SVR_results(experiment-name)` in matlab, which will create a new matfile `outputs/svr/experiment-name.mat`
We can now visualise these results using the `View_compare_SVR.m` script
