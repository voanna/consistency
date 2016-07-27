"""
Script to create semantic and spatial variants of convolutional features using max-pooling
"""
import numpy as np
import os
import ipdb
def reshapeFeature(layer, feature):
	"""
Original data from CNN layer is F x M x N, where F is the size of 
the feature and M x N are the (square) spatial dimensions.  The feature
is constructed though deep_feature=np.hstack(np.hstack(deep_feature))
This function undoes the horizontal stacking and returns a 
mulitdimensional array
	"""
	dimensions = {'data' : (3, 227, 227),
	 	'conv1' : (96, 55, 55), 
	 	'pool1' : (96, 27, 27),
	 	'norm1' : (96, 27, 27), # we have this
	 	'conv2' : (256, 27, 27), # we have this
	 	'pool2' : (256, 13, 13),
		'norm2' : (256, 13, 13)	,
		'conv3' : (384, 13, 13)	, # we have this
		'conv4' : (384, 13, 13)	, # we have this
		'conv5' : (256,	 13, 13),
		'pool5' : (256, 6, 6), # we have this
		'fc6' : (4096), # we have this
		'fc7' : (4096), # we have this
		'fc8' : (1000), # we have this
		'prob': (1000)
	}
	s = dimensions[layer.lower()]
	if isinstance(s, tuple): # otherwise, we know feature is not matrix
		matrix = feature.reshape((s[1],s[0],s[2]))
		matrix = np.transpose(matrix, (1,0,2))
		print np.shape(matrix)
		return matrix
	else : 
		print 'In the layer ' + layer + ", there is only one-dimensional data, this doesn't make sense"
		return feature

def semanticFeature(feature, layer):
	"""
Finds highest response for each element of F across entire space M x N
	"""
	matrix = reshapeFeature(layer, feature)
	assert len(matrix.shape) > 1, 'In the layer ' + layer + 'there are no semantic features separate from spatial ones'
	semFeat = matrix.mean(axis=(1,2))
	return semFeat

def spatialFeature(feature, layer) :
	"""
For each point (x, y) in the M x N spatial field, finds maximum of F 
feature response
	"""	
	matrix = reshapeFeature(layer, feature)
	assert len(matrix.shape) > 1, 'In the layer ' + layer + 'there are no spatial features separate from semantic ones'
	spatFeat = matrix.max(axis=0).flatten()
	return spatFeat

# Set these paths and layers
layers = ['conv4']#['norm1', 'norm2', 'conv3', 'conv4', 'pool5']
spatResDir = '~/predicting_consistency/outputs/features/MIT/spat/'
semResDir = '~/predicting_consistency/outputs/features/MIT/sem/'
wholeLayerDir = '~/predicting_consistency/outputs/features/MIT/whole/'

spatResDir = os.path.expanduser(spatResDir)
semResDir = os.path.expanduser(semResDir)
wholeLayerDir = os.path.expanduser(wholeLayerDir)
for layer in layers :
	print 'Starting on layer ' + layer
	i = 0
	directory = os.path.join(wholeLayerDir, layer)
	listing = os.listdir(directory)
	if not os.path.exists(os.path.join(spatResDir, layer)):
		os.makedirs(os.path.join(spatResDir, layer))
   	if not os.path.exists(os.path.join(semResDir, layer)):
		os.makedirs(os.path.join(semResDir, layer))
	for f in listing :
		print 'computing file ' + str(i)
	 	file = open(os.path.join(directory, f))
	 	content =  file.read().split()
	 	feature = np.asarray(map(float, content))
		# compute spatial and semantic features here
		spatFeat = spatialFeature(feature, layer)
		semFeat = semanticFeature(feature, layer)
		# create files to save into and open
		out_file_spat = os.path.join(spatResDir, layer, f)
		out_file_sem = os.path.join(semResDir, layer, f)
		fspat = open(out_file_spat,'w')
		fsem = open(out_file_sem, 'w')
		# save features to file
		np.savetxt(fspat, spatFeat)
		np.savetxt(fsem, semFeat)
		i = i + 1



