# Problem 2
using Pkg
Pkg.activate("./hw11/huanhaizhou/HiddenMarkovModel")
Pkg.instantiate()

using HiddenMarkovModel

using Test


observations = repeat([0, 1], 6).+1

learned_hmm = baum_welch(observations, 2, 2)

@info "Transition matrix:" learned_hmm.A
@info "Emission matrix:" learned_hmm.B

@test generate_sequence(learned_hmm,12)[1] == observations