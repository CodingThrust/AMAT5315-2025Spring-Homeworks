# Homework

1. Compress the following image to a storage size <100KB with the help of singular value decomposition (SVD) and fast Fourier transform (FFT). The code should be included in the submission.

   ![](corgi.png)

2. Evaluate the multiplication of two polynomials with fast Fourier transform (FFT) and inverse fast Fourier transform (IFFT). The two polynomials are given by
   ```math
   p(x) = 1 + 2x + 3x^2 + 4x^3 + 5x^4 + 6x^5 + 7x^6 + 8x^7 + 9x^8 + 10x^9\\
   q(x) = 10 + 9x + 8x^2 + 7x^3 + 6x^4 + 5x^5 + 4x^6 + 3x^7 + 2x^8 + x^9
   ```

3. Count the Flops of the Householder reflection algorithm.

4. (Optional) Design a numerical experiment to compare the Householder reflection and the Gram-Schmidt algorithm. Hint: Compare the result obtained from `Float64` and `Float32`.
