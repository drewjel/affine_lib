import .add_group_action
import .g_space
import algebra.module linear_algebra.basis

universes u v w
variables (X : Type u) (K : Type v) (V : Type w) (ι : Type*)
[field K] [add_comm_group V] [vector_space K V]


abbreviation affine_space
  (X K V : Type*)
  [field K] [add_comm_group V] [vector_space K V] := add_torsor V X

variables (s : finset ι) (g : ι → K) (v : ι → V) [is_basis K v] [affine_space X K V]

open_locale big_operators

def affine_combination (g_add : ∑ i in s, g i = 1) := ∑ i in s, g i • v i

def barycenter (g_add : ∑ i in s, g i = 1) := g -- TODO: want to coerce g to be a list?

structure affine_frame :=
(ref_pt : X)
(vec : ι → V)
(basis : is_basis K vec)

structure vec_with_frame (basis: affine_frame X K V ι) :=
(vec : V)

structure pt_with_frame (basis: affine_frame X K V ι) :=
(pt : X)