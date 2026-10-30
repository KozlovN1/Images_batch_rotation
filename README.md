Version 1.2

- Summary

The program performs the rotation of a series of raster images in a chosen mode and saves the resulting images in a designated directory

- Description

The program is designed primarily to preprocess series of images obtained in experiments. It operates in one of three modes numerated in accordance with the complexity of the transformation. Mode 1 rotates all the images at the same angle, defined by user. Mode 2 is for the case when the filmed object is at rotation with a constant rate: so, user has to provide the number of frames per revolution, and the angle is calculated for each image (the program expects there are no omitted images). Mode 3 is for the case of rotation at a varying rate (for instance, rotational oscillations, or libration): a special file is to be prepared containing the data on the coordinate of each image, the program then reads this data and rotates all the images so as to see the rotating object immobile.

The resulting images are exported in the same format as the original ones. Three formats are supported: *.bmp, *.tif (exported uncompressed), *.jpg (exported 100 quality).

Upon the launch the program shows a wizard allowing to configure its parameters. After a successfull execution the parameters are safed in a config file in the directory with images. When the program is run repeatedly in the same folder the pararmeters are taken from this file and can be modified.
The rotation functionality itself depends on the Image Processing Toolbox.

- Parameters

anglemode   may take one of the three values:
    1 - manually input a fixed angle, 
    2 - rotation at constant rate: fixed angle * number of steps, 
    3 - read the angle value from a file

suffix   may take the following values:
    *.bmp or *.tif or *.jpg or *.tiff or *.jpeg

phi_file  should point to a specially formatted file: 
    the file should contain four columns with names "phi,x_c,y_c,dphase" - vector|value|value|value

x_c and y_c   are the desired coordinates of the center of rotation (optional).
