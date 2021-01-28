***Implementation steps for the 2D CFAR process***

1. Select number of Training and Guard cells for range and doppler velocity.
2. Select a suitable value for offsetting the threshold value.
3. Prepare a logical mask of size (2*Tr+2*Gr+1, 2*Td+2*Gd+1), for the extraction of training cells.
4. Preallocate signal_CFAR as a matrix of zeros with same size as Range Doppler Map. This will be used to store the thresholded signal.
5. Loop through all values in Range Doppler Map (RDM). Consider Training and Gaurd cell sizes while selecting loop limits.
6. Carry out following steps in loop:
	i) Extract training cells from RDM.
	ii) Convert values in training cells into linear scale.
	iii) Calculate average of values in training cells.
	iv) Convert average into decibells.
	v) Carry out thresholding: If value in Cell under test is greater than threshold, value in cell under test is made 1.

***Selection of Training, Guard cells and offset***

1. Selection of Training cells
Optimization experience: 
Started with lower number of training cells in range and doppler, but many false positives(noise identified as signal) were observed.
As number of training cells were increased, the false positives were suppressed.
Learning:
If training cells are high, threshold curve in that direction becomes flatter, which has the following effect:
	i) On the upside, noise would be effectively suppressed, due to the uniform curve.
	ii) On the down side, nearby vehicles/ objects would also come into the training cells.
So, when we have many vehicles close together, low training cell number has to be adopted.
Taking this into consideration, the training cell size in Range and Doppler are optimised.

2. Selection of Guard cells
Gaurd cells are used to prevent signal leaking into training cells.
If low number is selected, signal may leak into training cell.
Since the signal in the doppler direction is very well resolved, we select a higher number of guard cells in the doppler direction.

3. Selection of offset
If a higher offset is used, signal will be identified as noise (False negative)
If a lower offset is used, noise is identified as signal (False positive)
Taking this into consideration, the offset is optimised.

***Steps taken to suppress the non-thresholded cells at the edges***

The signal_CFAR(To store thresholded signal) variable was initialized with zeros before entering the loop.
This variable was a matrix of same size of Range Doppler map.
The loop limits were designed, keeping in mind the size of the edges.
This automatically ensures that, the edge cells stay with the initial values of zero.