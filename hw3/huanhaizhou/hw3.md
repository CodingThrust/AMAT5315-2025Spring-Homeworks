# Homework 3

1. (Version and CI/CD)
   1. MIT License.
      As a user,
      - I can obtain a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so.
      - I cannot exclude the copyright notice and the MIT license permission notice in any copies or substantial portions of the Software.
   2. Yes. In the ``Project.toml`` file of `OMEinsum.jl`, the ``[compat]`` section specifically states:
      ```toml
      [compat]
      ChainRulesCore = "1"
      ```
      This means that `OMEinsum.jl` is compatible with any version of `ChainRulesCore` that starts with 1.
   3. $$ 
      89\%
      $$ By checking the codecov badge on the repository's README.
2. (Create a package)
   <https://github.com/fliingelephant/MyFirstPackage.jl>
3. (Big-$O$ notation)
   1. $$
        \text{O}(2^n)
      $$
   2. $$
        \text{O}(n)
      $$
4. (Graph representation) The adjacency matrix of the graph is: 
   $$
   \begin{bmatrix}
   0 & 1 & 1 & 0 & 0 \\
   1 & 0 & 1 & 1 & 0 \\
   1 & 1 & 0 & 0 & 1 \\
   0 & 1 & 0 & 0 & 1 \\
   0 & 0 & 1 & 1 & 0
   \end{bmatrix}, 
   $$
   whose columns and rows are indexed by vertices 0, 1, 2, 3, 4.