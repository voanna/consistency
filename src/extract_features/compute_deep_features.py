import os
import sys
import numpy as np
import matplotlib.pyplot as plt
import glob

# Make sure that caffe is on the python path:
caffe_root = '/path/to/caffe/'
import sys
sys.path.insert(0, caffe_root + 'python')

import caffe

net = caffe.Classifier(caffe_root + 'examples/imagenet/imagenet_deploy_1_crop.prototxt',
               caffe_root + 'examples/imagenet/caffe_reference_imagenet_model')


def init():

	caffe.set_mode_cpu()
	# input preprocessing: 'data' is the name of the input blob == net.inputs[0]
	transformer = caffe.io.Transformer({'data': net.blobs['data'].data.shape})
	transformer.set_mean('data', np.load(caffe_root + 'python/caffe/imagenet/ilsvrc_2012_mean.npy').mean(1).mean(1))
	transformer.set_channel_swap('data', (2,1,0))
	transformer.set_raw_scale('data', 255.0)
	
def getDeepFeature(imgPath,layer):

	scores = net.predict([caffe.io.load_image(imgPath)], oversample=False)

	deep_feature = net.blobs[layer].data
	deep_feature=deep_feature.squeeze()
	deep_feature=deep_feature.mean(0)
	
	if len(deep_feature.shape)>1:
		deep_feature=np.hstack(np.hstack(deep_feature))
	return deep_feature



def run_directory(path,outdir,layer,step,pattern):
	if not os.path.isdir(outdir):
		os.makedirs(outdir)

	search_str=path + '/' + pattern
	print('%s\n' % search_str)
	images=glob.glob(search_str)
	images.sort()
	nb_images=len(images)


	for imgNr in range(0,nb_images,step):
		name=os.path.basename(images[imgNr])
		out_file=outdir+ '/'+ name + '.txt'
		#print(out_file)
		#print(images[imgNr])
		if os.path.isfile(out_file) == False:
			df=getDeepFeature(images[imgNr],layer)
		
			with open(out_file,'w') as f:
				for idx in range(len(df)):
					f.write('%5.10f ' % df[idx])



if __name__=='__main__':
	if len(sys.argv) <3: 
		print("\nNot enough arguments. Call with:")
		print("\t./compute_deep_features.py imgPath outputDir [layerName] [pattern] [stepSize]\n")
		print('Default parameters:')
		print("pattern \t\t *.*")
		print("stepSize    \t\t 1\t\t(i.e. process every image)")
		print("layerName    \t\t fc6\t(See more available layers at: ")
		print("http://nbviewer.ipython.org/github/BVLC/caffe/blob/master/examples/filter_visualization.ipynb)")
		print("\n")
	else:
	
		path=sys.argv[1]
		outdir=sys.argv[2]
			
		layer='fc6'
		step=1
		pattern=False
		if len(sys.argv)>=4:
			layer=sys.argv[3]
		if len(sys.argv)>=5:
			pattern=sys.argv[4]
		if len(sys.argv)>=6:			
			step=int(sys.argv[5])

		print('Running for directory %s' % path)
		# Initiailize
		init()
		
		# Run for directory
		if pattern==False:
			run_directory(path,outdir,layer,step,'*.*')
		else:
			print('Pattern: %s\n' % pattern)
			run_directory(path,outdir,layer,step,pattern)

