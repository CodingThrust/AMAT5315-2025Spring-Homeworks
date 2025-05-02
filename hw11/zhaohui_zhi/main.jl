using OMEinsum
using Test
using LinearAlgebra
using HiddenMarkovModel
using Test
A=randn(4,4)
v=collect(1.0:4)

A1=randn(4,4)
A2=randn(4,4)
A3=randn(4,4)
A4=randn(4,4)
@test ein"ij,j ->i"(A,v) == A*v
@test ein"ii ->"(A)[1] == tr(A)
@test ein"ij ->ji"(A) == A'
@test ein"ij ->j"(A) ==  sum(A,dims=1)[1,:]
@test ein"ij,jk,kl,lm,mn ->in"(A,A1,A2,A3,A4) ≈ A*A1*A2*A3*A4
@test ein"ij,ij->ij"(A, A)== A.*A


##==##==##==##==##==# Hidden Markov Model #==##==##==##==##==##==##==##==##==##==

observations=[0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1].+1
learned_hmm = baum_welch(observations, 2, 2)

@show learned_hmm
@test generate_sequence(learned_hmm,12)[1] == observations
