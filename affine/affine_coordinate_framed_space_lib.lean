import .affine_coordinate_framed_space
import .affine_space_type
import .list_as_k_tuple
import linear_algebra.matrix
universes u v w
/-
This file defines the following types:
affine_coord_space
affine_tuple_basis
affine_coord_basis
transform_path

affine_coord_frame.standard 
affine_coord_frame.base_frame 
affine_coord_frame.origin_coords
affine_coord_frame.basis_coords 
affine_coord_space.origin
affine_coord_space.basis
affine_coord_space.frame
affine_coord_space.standard_space
affine_coord_space.mk_with_standard
affine_coord_space.get_base_space
affine_coord_space.mk_coord_point
affine_coord_space.mk_coord_vec
affine_coord_space.mk_point
affine_coord_space.mk_vec
affine_coord_space.mk_basis
affine_coord_space.mk_frame
affine_coord_space.mk_tuple_frame
affine_coord_space.mk_derived
affine_coord_frame.get_coords
affine_coord_space.mk_derived_from_coords
affine_coord_space.mk_from_frame

affine_coord_frame.build_path
affine_coord_space.find_transform_path
-/

namespace aff_lib

open aff_fr
variables 
    (K : Type v) 
    (n : ℕ) 
    [inhabited K] 
    [field K] 
    --(fr : affine_tuple_coord_frame K n)
    (fr : affine_coord_frame K n)
/-
attribute [reducible]
abbreviation affine_coord_space :=
    affine_space_type 
        (aff_coord_pt K n fr)
        K
        (aff_coord_vec K n fr)
-/

structure affine_coord_space
    extends 
    affine_space_type 
        (aff_coord_pt K n fr)
        K
        (aff_coord_vec K n fr)
    := 
    mk ::

attribute [reducible]
def affine_coord_space.pt_type 
    (sp : affine_coord_space K n fr)
    :=
        (aff_coord_pt K n fr) 

attribute [reducible]
def affine_coord_space.vec_type 
    (sp : affine_coord_space K n fr)
    :=
        (aff_coord_vec K n fr) 

attribute [reducible]
def affine_tuple_basis :=
    (fin n) → aff_vec_coord_tuple K n

attribute [reducible]
def affine_coord_basis :=
    (fin n) → aff_coord_vec K n fr


attribute [reducible]
abbreviation square_matrix
    (K : Type u)
    (n : ℕ)
    [inhabited K] 
    [field K] 
    := matrix (fin n) (fin n ) K
 
attribute [reducible]
abbreviation col_matrix
    (K : Type u)
    (n : ℕ)
    [inhabited K] 
    [field K] 
    := matrix (fin n) (fin 1) K


/-
Helper method to retrieve the origin of coord space defined in
terms of a particular frame (which has an origin that we need to retrieve)
-/

abbreviation zero := vecl.zero_vector K n

def list.to_basis_vec : fin n → list K := λ x, (zero K n).update_nth (x.1 + 1) 1

lemma len_basis_vec_fixed (x : fin n) : (list.to_basis_vec K n x).length = n + 1 :=
by rw [list.to_basis_vec, list.update_nth_length, len_zero]

lemma head_basis_vec_fixed (x : fin n) : (list.to_basis_vec K n x).head = 0 :=
begin
    have h₁ : list.to_basis_vec K n x = (zero K n).update_nth (x.1 + 1) 1 := rfl,
    have h₂ : ∀ (hd a : K) (tl : list K) (n' : ℕ), ((hd :: tl).update_nth (n' + 1) a).head = (hd :: tl).head := by {intros, rw list.update_nth, refl},
    rw h₁,
    induction n with n',
    have h₃ : zero K 0 = [0] := rfl,
    rw [h₃, h₂],
    refl,

    have h₄ : zero K n'.succ = 0 :: zero K n' := rfl,
    rw [h₄, h₂],
    refl
end

def std_basis : fin n → aff_vec_coord_tuple K n :=
λ x, ⟨list.to_basis_vec K n x, len_basis_vec_fixed K n x, head_basis_vec_fixed K n x⟩

def affine_coord_frame.standard : affine_coord_frame K n := 
    (affine_coord_frame.tuple ⟨pt_zero K n, std_basis K n, begin
        rw is_basis,
        split,
        rw linear_independent,
        simp only [finsupp.total, finsupp.lsum, ⊥, add_equiv.coe_mk],
        ext,
        split,
        intro h,
        sorry,
        intro h,
        sorry,

        simp only [submodule.span, set.range, ⊤, set.univ, Inf],
        ext,
        split,
        intro h,
        exact true.intro,
        intro h,
        sorry
    end⟩)

def affine_tuple_coord_frame.standard : affine_tuple_coord_frame K n :=
    ⟨pt_zero K n, std_basis K n, sorry⟩
-- This is type of frame when retrieved from a base space
attribute [reducible]
def affine_coord_frame.base_frame 
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
: affine_coord_frame K n → affine_coord_frame K n
| (affine_coord_frame.tuple base) := affine_coord_frame.standard K n
| (affine_coord_frame.derived _ _ _ fr) := fr

attribute [reducible]
def affine_coord_frame.origin_coords
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
     : affine_coord_frame K n → aff_pt_coord_tuple K n
| (affine_coord_frame.tuple base) := base.origin
| (affine_coord_frame.derived o _ _ _) := o


attribute [reducible]
def affine_coord_frame.basis_coords 
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    : affine_coord_frame K n → affine_tuple_basis K n
| (affine_coord_frame.tuple base) := base.basis
| (affine_coord_frame.derived _ b _ _) := b

/-
Helper method to retrieve the origin of ℕ-indexed coord space defined in
terms of a particular frame (which has an origin that we need to retrieve)
-/
attribute [reducible]
def affine_coord_space.origin
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    {fr : affine_coord_frame K n}
    (sp : affine_coord_space K n fr)
    : aff_coord_pt K n (affine_coord_frame.base_frame fr)
    :=
        ⟨affine_coord_frame.origin_coords (affine_coord_frame.base_frame fr)⟩

/-
Helper method to retrieve the basis of coord space defined in
terms of a particular frame (which has a basis that we need to retrieve)
-/
attribute [reducible]
def affine_coord_space.basis
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    {fr : affine_coord_frame K n}
    (sp : affine_coord_space K n fr)
    : affine_coord_basis K n (affine_coord_frame.base_frame fr)
    :=
        λ i : fin n, ⟨(affine_coord_frame.basis_coords (affine_coord_frame.base_frame fr)) i⟩


attribute [reducible]
def affine_coord_space.frame
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    {fr : affine_coord_frame K n}
    (sp : affine_coord_space K n fr)
    := 
        fr

attribute [reducible]
def affine_coord_vec.frame
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    {fr : affine_coord_frame K n}
    (v : aff_coord_vec K n fr)
    := 
        fr

attribute [reducible]
def affine_coord_point.frame
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    {fr : affine_coord_frame K n}
    (v : aff_coord_pt K n fr)
    := 
        fr

abbreviation affine_coord_space.standard_space
    := affine_coord_space K n (affine_coord_frame.standard K n)

attribute [reducible]
def affine_coord_space.mk_with_standard
    : affine_coord_space.standard_space K n
    := ⟨⟨⟩⟩

attribute [reducible]
def affine_coord_space.get_base_space
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    {fr : affine_coord_frame K n}
    (sp : affine_coord_space K n fr)
    : affine_coord_space K n (affine_coord_frame.base_frame fr)
    :=
        ⟨⟨⟩⟩

attribute [reducible]
def affine_coord_space.mk_coord_point
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    {fr : affine_coord_frame K n}
    (sp : affine_coord_space K n fr)
    (val : vector K n)
    : aff_pt_coord_tuple K n
    := ⟨[1]++val.1,begin
        have h₁ : ([1] ++ val.1).length = [1].length + val.1.length := by {rw [list.singleton_append, vecl.len_cons, add_comm], refl},
        rw [h₁, val.2, add_comm],
        refl
    end,begin
        rw list.singleton_append,
        refl
    end⟩

attribute [reducible]
def affine_coord_space.mk_coord_vec
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    {fr : affine_coord_frame K n}
    (sp : affine_coord_space K n fr)
    (val : vector K n)
    : aff_vec_coord_tuple K n
    := ⟨[0]++val.1,begin
        have h₁ : ([0] ++ val.1).length = [0].length + val.1.length := by {rw [list.singleton_append, vecl.len_cons, add_comm], refl},
        rw [h₁, val.2, add_comm],
        refl
    end,begin
        rw list.singleton_append,
        refl
    end⟩

attribute [reducible]
def affine_coord_space.mk_point
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    {fr : affine_coord_frame K n}
    (sp : affine_coord_space K n fr)
    (val : vector K n)
    : aff_coord_pt K n fr
    := ⟨⟨[1]++val.1,begin
        have h₁ : ([1] ++ val.1).length = [1].length + val.1.length := by {rw [list.singleton_append, vecl.len_cons, add_comm], refl},
        rw [h₁, val.2, add_comm],
        refl
    end,begin
        rw list.singleton_append,
        refl
    end⟩⟩

attribute [reducible]
def affine_coord_space.mk_vec
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    {fr : affine_coord_frame K n}
    (sp : affine_coord_space K n fr)
    (val : vector K n)
    : aff_coord_vec K n fr
    := ⟨⟨[0]++val.1,begin
        have h₁ : ([0] ++ val.1).length = [0].length + val.1.length := by {rw [list.singleton_append, vecl.len_cons, add_comm], refl},
        rw [h₁, val.2, add_comm],
        refl
    end,begin
        rw list.singleton_append,
        refl
    end⟩⟩

    --:= ⟨⟩

/-
slight issue here, 
because the type of a derived frame does not contain the original frame,
i don't raise an explicit type error if the space's frame
 and frame's base frame don't match
fix for now is just to supply a coord tuple frame
-/
attribute [reducible]
def affine_coord_space.mk_basis
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    {fr : affine_coord_frame K n}
    (sp : affine_coord_space K n fr)
    (vecs : vector (aff_coord_vec K n fr) n)
     : affine_coord_basis K n fr
    := 
        λ i : fin n, vecs.nth i
    
attribute [reducible]
def affine_coord_space.mk_frame
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    {fr : affine_coord_frame K n}
    (sp : affine_coord_space K n fr)
    (pt : aff_coord_pt K n fr)
    (basis : affine_coord_basis K n fr)
    
    := 
        (affine_coord_frame.derived pt.1 (λ i:fin n,(basis i).1) sorry)

attribute [reducible]
def affine_coord_space.mk_tuple_frame
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    {fr : affine_coord_frame K n}
    (sp : affine_coord_space K n fr)
    (pt : aff_coord_pt K n fr)
    (basis : affine_coord_basis K n fr)
    : affine_tuple_coord_frame K n
    := 
        ⟨pt.1, (λ i:fin n,(basis i).1),sorry⟩

attribute [reducible]
def affine_coord_space.mk_derived
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    {fr : affine_coord_frame K n}
    (sp : affine_coord_space K n fr)
    (pt : aff_coord_pt K n fr)
    (basis : affine_coord_basis K n fr)
    : affine_coord_space K n 
        (affine_coord_frame.derived pt.1 (λ i:fin n,(basis i).1) sorry fr)
    := ⟨⟨⟩⟩

/-
[0] + rest of list
[1] + rest of list
strip out coordinates from aff_coord_pt and turn it into a vector
aff_coord_vec
aff_coord_vec.list
=> vector

(l : list K)
(len_fixed : l.length = n + 1)

-/
/-
attribute [reducible]
def coord_helper 
    {K : Type v}
    {n : ℕ}
    (l : list K)
    (pf : l.length = n+1)
    :  vector K n
| (h::t) := ⟨t,sorry⟩
| [] := ⟨[],sorry⟩
-/
attribute [reducible]
def coord_helper
    {K : Type v}
    {n : ℕ }
    (l : list K)--aff_coord_pt SO list is NEVER 0
    (pf : l.length = n + 1)
    : vector K n
:= begin
    cases l with h t,
    contradiction,
    exact ⟨t,begin
        have h₁ : t.length = (h :: t).length - 1 := rfl,
        rw [h₁, pf],
        refl
    end⟩
end

attribute [reducible]
def affine_coord_vec.get_coords 
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    {fr : affine_coord_frame K n}
    (v : aff_coord_vec K n fr)
    : vector K n
    :=
    coord_helper v.1.1 v.1.2

attribute [reducible]
def affine_coord_pt.get_coords 
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    {fr : affine_coord_frame K n}
    (v : aff_coord_pt K n fr)
    : vector K n
    :=
    coord_helper v.1.1 v.1.2

attribute [reducible]
def affine_tuple_vec.get_coords 
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    (v : aff_vec_coord_tuple K n )
    : vector K n
    :=
    coord_helper v.1 v.2

attribute [reducible]
def affine_tuple_pt.get_coords 
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    (v : aff_pt_coord_tuple K n )
    : vector K n
    :=
    coord_helper v.1 v.2

attribute [reducible]    
def affine_tuple_vec.as_matrix
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    (v : aff_vec_coord_tuple K n )
    : matrix (fin n) (fin 1) K
    :=
    λ i one, (coord_helper  v.1 v.2).nth i

attribute [reducible]
def affine_tuple_pt.as_matrix
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    (v : aff_pt_coord_tuple K n )
    : matrix (fin n) (fin 1) K
    :=
    λ i one, (coord_helper v.1 v.2).nth i


attribute [reducible]
def affine_coord_frame.get_coords
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    : affine_coord_frame K n → affine_tuple_coord_frame K n
| (affine_coord_frame.tuple b) := b
| (affine_coord_frame.derived o b _ _) := ⟨o,b,sorry⟩

attribute [reducible]
def affine_coord_space.mk_derived_from_coords
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    {fr : affine_coord_frame K n}
    (sp : affine_coord_space K n fr)
    (f : affine_tuple_coord_frame K n)
    : affine_coord_space K n 
        (affine_coord_frame.derived f.1 (λ i:fin n,(f.2 i)) sorry fr)
    := ⟨⟨⟩⟩

attribute [reducible]
def affine_coord_space.mk_from_frame
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    (fr : affine_coord_frame K n)
    : affine_coord_space K n fr 
    := ⟨⟨⟩⟩

structure transform_path
    (K : Type v)
    (n : ℕ)
    [inhabited K] 
    [field K] :=
    mk:: 
    (from_ : list (affine_tuple_coord_frame K n))
    (to_ : list (affine_tuple_coord_frame K n))


attribute [reducible]
def affine_coord_frame.build_path
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    :  affine_coord_frame K n → list (affine_tuple_coord_frame K n)
| (affine_coord_frame.tuple b) := [b]
| (affine_coord_frame.derived o b p f) := ⟨o,b,p⟩::(affine_coord_frame.build_path f)

attribute [reducible]
def affine_coord_space.find_transform_path
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    {fr1 : affine_coord_frame K n}
    (from_sp : affine_coord_space K n fr1)
    {fr2 : affine_coord_frame K n}
    (to_sp : affine_coord_space K n fr2)
    : transform_path K n
    := ⟨affine_coord_frame.build_path fr1, affine_coord_frame.build_path fr2⟩


structure transform_path'
    (K : Type v)
    (n : ℕ)
    [inhabited K] 
    [field K] :=
    mk:: 
    (from_ : list (affine_coord_frame K n))
    (to_ : list (affine_coord_frame K n))


attribute [reducible]
def affine_coord_frame.build_path'
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    :  affine_coord_frame K n → list (affine_coord_frame K n)
| (affine_coord_frame.tuple b) := [(affine_coord_frame.tuple b)]
| (affine_coord_frame.derived o b p f) := (affine_coord_frame.derived o b p f)::(affine_coord_frame.build_path' f)

attribute [reducible]
def affine_coord_space.find_transform_path'
    {K : Type v}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    {fr1 : affine_coord_frame K n}
    (from_sp : affine_coord_space K n fr1)
    {fr2 : affine_coord_frame K n}
    (to_sp : affine_coord_space K n fr2)
    : transform_path' K n
    := ⟨affine_coord_frame.build_path' fr1, affine_coord_frame.build_path' fr2⟩


def affine_vec_coord_tuple.as_matrix
    {K : Type u}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    (v : aff_vec_coord_tuple K n)
    : col_matrix K n
    :=
    λ i one, (@aff_lib.coord_helper K n v.1 v.2).nth i

attribute [reducible]
def affine_pt_coord_tuple.as_matrix
    {K : Type u}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    (v : aff_pt_coord_tuple K n)
    : col_matrix K n
    :=
    λ i one, (@aff_lib.coord_helper K n v.1 v.2).nth i

attribute [reducible]
def affine_coord_vec.to_matrix
    {K : Type u}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    {fr : affine_coord_frame K n}
    (v : aff_coord_vec K n fr)
    : col_matrix K n
    :=
    affine_vec_coord_tuple.as_matrix v.1

attribute [reducible]
def affine_coord_pt.to_matrix
    {K : Type u}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    {fr : affine_coord_frame K n}
    (v : aff_coord_pt K n fr)
    : col_matrix K n
    :=
    affine_pt_coord_tuple.as_matrix v.1

attribute [reducible]
def affine_coord_vec.to_indexed
    {K : Type u}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    {fr : affine_coord_frame K n}
    (v : aff_coord_vec K n fr)
    : fin n → K
    :=
    λ i, (@aff_lib.coord_helper K n v.1.1 v.1.2).nth i

attribute [reducible]
def affine_coord_pt.to_indexed
    {K : Type u}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    {fr : affine_coord_frame K n}
    (v : aff_coord_pt K n fr)
    : fin n → K 
    :=
    λ i, (@aff_lib.coord_helper K n v.1.1 v.1.2).nth i

attribute [reducible]
def affine_vec_coord_tuple.to_indexed
    {K : Type u}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    (v : aff_vec_coord_tuple K n )
    : fin n → K 
    :=
    λ i, (@aff_lib.coord_helper K n v.1 v.2).nth i

attribute [reducible]
def affine_pt_coord_tuple.to_indexed
    {K : Type u}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    (v : aff_pt_coord_tuple K n )
    : fin n → K 
    :=
    λ i, (@aff_lib.coord_helper K n v.1 v.2).nth i

attribute [reducible]
def col_matrix.as_list_helper
    {K : Type u}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    (coords : col_matrix K n)
    : fin n → list K
| ⟨nat.zero,p⟩ := [(coords ⟨nat.zero,p⟩ 1)]
| ⟨nat.succ k,p⟩ := 
    --append current index to result of recursive step and return
    let kp : k < n := begin
      have h₁ : k < k.succ := begin
        rw eq.symm (nat.one_add k),
        simp only [nat.succ_pos', lt_add_iff_pos_left]
      end,
      apply has_lt.lt.trans,
      exact h₁,
      exact p
    end in
    let upd := [(coords ⟨k, kp⟩ 1)] in
    have (⟨k, kp⟩ : fin n) < (⟨k.succ,p⟩ : fin n), from begin
      simp only [subtype.mk_lt_mk],
      rw eq.symm (nat.one_add k),
      simp only [nat.succ_pos', lt_add_iff_pos_left]
    end,
    (col_matrix.as_list_helper ⟨k,kp⟩)++upd
using_well_founded {rel_tac := λ _ _, `[exact ⟨_, measure_wf (λi, i.val)⟩]}

attribute [reducible]
def col_matrix.as_list
  {K : Type u}
  {n : ℕ}
  [inhabited K]
  [field K]
  : col_matrix K n → list K
:= begin
  intro mat,
  cases n with n',
  exact [],
  have h₁ : n' < n'+1 := 
    begin
      by linarith,
    end,
  have h₂ : n'.succ = n'+1 :=
    begin
      simp 
    end,
  have h₃ : n' < n'.succ :=
    begin
      simp [h₁, h₂ ]
    end,
  exact (col_matrix.as_list_helper mat (⟨n',h₃⟩ : fin (nat.succ n'))),
end


attribute [reducible]
def indexed.as_list_helper
    {K : Type u}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    (coords : fin n → K)
    : fin n → list K
| ⟨nat.zero,p⟩ := [(coords ⟨nat.zero,p⟩)]
| ⟨nat.succ k,p⟩ := 
    --append current index to result of recursive step and return
    let kp : k < n := begin
      have h₁ : k < k.succ := begin
        rw eq.symm (nat.one_add k),
        simp only [nat.succ_pos', lt_add_iff_pos_left]
      end,
      apply has_lt.lt.trans,
      exact h₁,
      exact p
    end in
    let upd := [(coords ⟨k, kp⟩)] in
    have (⟨k, kp⟩ : fin n) < (⟨k.succ,p⟩ : fin n), from begin
      simp only [subtype.mk_lt_mk],
      rw eq.symm (nat.one_add k),
      simp only [nat.succ_pos', lt_add_iff_pos_left]
    end,
    --have t : a < (a + b), from sorry,
    (indexed.as_list_helper ⟨k,kp⟩)++upd --$ λ _, sorry
using_well_founded {rel_tac := λ _ _, `[exact ⟨_, measure_wf (λi, i.val)⟩]}

attribute [reducible]
def indexed.as_list
  {K : Type u}
  {n : ℕ}
  [inhabited K]
  [field K]
  : (fin n → K) → list K
:= begin
  intro mat,
  cases n with n',
  exact [],
  have h₁ : n' < n'+1 := 
    begin
      by linarith,
    end,
  have h₂ : n'.succ = n'+1 :=
    begin
      simp 
    end,
  have h₃ : n' < n'.succ :=
    begin
      simp [h₁, h₂ ]
    end,
  exact (indexed.as_list_helper mat (⟨n',h₃⟩ : fin (nat.succ n'))),
end

attribute [reducible]
def affine_coord_pt.from_matrix
    {K : Type u}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    (fr : affine_coord_frame K n)
    (coords : col_matrix K n)
    : aff_coord_pt K n fr
    := 
    ⟨⟨[1]++(col_matrix.as_list coords), begin
      suffices h₁ : (col_matrix.as_list coords).length = n, from begin
        have h₂ : ([1] ++ col_matrix.as_list coords).length = [1].length + (col_matrix.as_list coords).length := begin
          simp only [list.length, zero_add, list.singleton_append],
          rw add_comm
        end,
        rw h₂,
        simp only [list.length, zero_add],
        rw [h₁, add_comm]
      end,
      induction n with n',
      simp only [list.length],
      have h₁ : coords.as_list = coords.as_list_helper (⟨n',_⟩ : fin (nat.succ n')) := rfl,
      rw h₁,
      cases n' with n'',
      refl,
      have h₂ : coords.as_list_helper ⟨n''.succ, _⟩ = (coords.as_list_helper ⟨n'',_⟩)++[(coords ⟨n'', _⟩ 1)] := rfl,
      rw h₂,
      have h₃ : ∀ (coords : col_matrix K n''.succ), coords.as_list = coords.as_list_helper ⟨n'',_⟩ := by {intros, refl},
      rw h₁,
      
    end, rfl⟩⟩

attribute [reducible]
def affine_coord_vec.from_matrix
    {K : Type u}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    (fr : affine_coord_frame K n)
    (coords : col_matrix K n)
    : aff_coord_vec K n fr
    := 
    ⟨⟨[0]++(col_matrix.as_list coords),sorry,rfl⟩⟩

attribute [reducible]
def affine_coord_pt.from_indexed
    {K : Type u}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    (fr : affine_coord_frame K n)
    (coords : fin n → K)
    : aff_coord_pt K n fr
    := 
    ⟨⟨[1]++(indexed.as_list coords),sorry,rfl⟩⟩

attribute [reducible]
def affine_coord_vec.from_indexed
    {K : Type u}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    (fr : affine_coord_frame K n)
    (coords : fin n → K)
    : aff_coord_vec K n fr
    := 
    ⟨⟨[0]++(indexed.as_list coords),sorry,rfl⟩⟩


attribute [reducible]
def affine_pt_coord_tuple.from_indexed
    {K : Type u}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    (coords : fin n → K)
    : aff_pt_coord_tuple K n
    := 
    ⟨[1]++(indexed.as_list coords),sorry,rfl⟩

attribute [reducible]
def affine_vec_coord_tuple.from_indexed
    {K : Type u}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    (coords : fin n → K)
    : aff_vec_coord_tuple K n
    := 
    ⟨[0]++(indexed.as_list coords),sorry,rfl⟩
  
attribute [reducible]
def affine_coord_frame.get_basis_matrix
    {K : Type u}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    (fr : affine_coord_frame K n)
    : square_matrix K n
    := 
    λ i j,
    (aff_lib.affine_tuple_vec.get_coords  
    (
        (aff_lib.affine_coord_frame.basis_coords 
            fr) j))
    .nth i


attribute [reducible]
def affine_coord_frame.get_origin_matrix
    {K : Type u}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    (fr : affine_coord_frame K n)
    : col_matrix K n
    := 
    affine_pt_coord_tuple.as_matrix
        (aff_lib.affine_coord_frame.origin_coords 
            fr)

attribute [reducible]
def affine_tuple_coord_frame.get_basis_matrix
    {K : Type u}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    (fr : affine_tuple_coord_frame K n)
    : square_matrix K n
    := 
    λ i j,
    (aff_lib.affine_tuple_vec.get_coords  
    (
        (fr.basis) j))
    .nth i


attribute [reducible]
def affine_tuple_coord_frame.get_origin_matrix
    {K : Type u}
    {n : ℕ}
    [inhabited K] 
    [field K] 
    (fr : affine_tuple_coord_frame K n)
    : col_matrix K n
    := 
    affine_pt_coord_tuple.as_matrix
        (fr.origin)


end aff_lib