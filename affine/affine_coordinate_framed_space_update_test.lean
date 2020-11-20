import data.real.basic
import .affine_coordinate_framed_space_update_lib
--import .real_affine_coordinate_space_lib

noncomputable theory

open aff_lib
--create R3 with an explicit standard frame. 
--points and vectors expressed in standar frame
def R3 := aff_lib.affine_coord_space.mk_with_standard ℝ 3

--define one origin and 3 basis vectors in R3
def R3_pt1 := aff_lib.affine_coord_space.mk_point R3 ⟨[0,0,0], by refl⟩
def R3_vec1 := aff_lib.affine_coord_space.mk_vec R3 ⟨[1,0,0], by refl⟩
def R3_vec2 := aff_lib.affine_coord_space.mk_vec R3 ⟨[0,1,0], by refl⟩
def R3_vec3 := aff_lib.affine_coord_space.mk_vec R3 ⟨[0,0,1], by refl⟩

--get origin of R3 - which is the origin of the standard frame
def origin : _ := affine_coord_space.origin R3


#check origin

--get basis of R3 - basis of standard frame
def basis := affine_coord_space.basis R3


--test various torsor over vector space operations operations
#check origin
#check basis 1 -ᵥ basis 2 --expected : pass
#check basis 1 +ᵥ basis 2 --expected : pass
#check origin +ᵥ origin --expected : fail
#check origin -ᵥ origin --expected : pass
#check basis 1 
#check basis 1 -ᵥ origin --expected : fail
#check origin -ᵥ basis 2 --expected : pass?
#check origin +ᵥ basis 2 --expected : pass


--create another, different set of vectors and a point in R3
def R3_pt1' := aff_lib.affine_coord_space.mk_point R3 ⟨[1,1,1], by refl⟩
def R3_vec1' := aff_lib.affine_coord_space.mk_vec R3 ⟨[2,0,0], by refl⟩
def R3_vec2' := aff_lib.affine_coord_space.mk_vec R3 ⟨[0,2,0], by refl⟩
def R3_vec3' := aff_lib.affine_coord_space.mk_vec R3 ⟨[0,0,2], by refl⟩

--create a derived frame using the point and set of vectors
def der_fr := affine_coord_space.mk_frame 
    R3 
    R3_pt1' 
    (λ i : fin 3, vector.nth (⟨[R3_vec1', R3_vec3', R3_vec2'], sorry⟩ : vector _ 3) i)
    sorry

#check option

--create a new isomorphic space to R3 with standard frame, by equipping R3
--with a derived frame of the standard frame, yielding a new coordinate space
def der_sp := 
    affine_coord_space.mk_derived_from_coords R3 (affine_coord_frame.get_coords der_fr)

--get the origin and basis of the newly derived space which are the origin and
--basis of the derived frame
def der_origin := affine_coord_space.origin der_sp
def der_basis := affine_coord_space.basis der_sp

--test various torsor operations - different frames should not be added
--coordinatized vs. coordinate free
#check der_basis 1 +ᵥ basis 2
#check der_basis 2 +ᵥ der_basis 2
#check der_basis 1 -ᵥ basis 1
#check der_origin -ᵥ der_origin
#check der_origin -ᵥ origin

--get the base frame of R3 equipped with standard frame, which is the standard frame
def base_R3_fr := affine_coord_frame.base_frame 
                    (affine_coord_space.frame R3)

--base frame of der_sp is the frame of (R3 equipped with standard frame)
def base_der_sp_fr := affine_coord_frame.base_frame 
                    (affine_coord_space.frame der_sp)
--base space of std R3 is std R3 (equal up to computation)
def base_R3 := affine_coord_space.get_base_space R3

/-
R3 base space -> make derived space "der_sp" from derived frame
-> get base space OF der_sp, again R3
base_der_sp == R3
-/
def base_der_sp := affine_coord_space.get_base_space der_sp
--def base_der_sp_fr := affine_coord_space.frame base_der_sp
def R3_fr := affine_coord_space.frame R3

--tests show equivalent spaces and frames are equal up to computation
def base_vec := affine_coord_space.mk_vec base_der_sp ⟨[0,0,0], by refl⟩
lemma eqsp : R3 = base_der_sp := by refl
lemma eqs : R3_fr = base_der_sp_fr -- expected pass
    := by refl
lemma eqs : der_fr = base_der_sp_fr --expected fail
    := by refl
/-
base_vec ∈ base_der_sp.
basis 2 ∈ R3
however, R3 == base_der_sp
-/

#check (affine_coord_space.frame base_der_sp)
#check (affine_coord_space.frame R3)
lemma eqfr : (affine_coord_space.frame base_der_sp) = (affine_coord_space.frame R3) := by refl

-- issue here demonstrates that equal frames up to computation are not
-- necessarily equal values. this should be revisited.
def base_vec_R3 := affine_coord_space.mk_vec R3 ⟨[0,0,0], by refl⟩
#check has_vadd.vadd base_vec /-+ᵥ-/ base_vec_R3 -- expected: pass or no??
/-
none of the overloads are applicable
error for aff_fr.pt_plus_vec
type mismatch at application
  aff_fr.pt_plus_vec base_vec
term
-/
#check (affine_coord_space.frame base_der_sp)
--#reduce (affine_coord_space.frame base_der_sp)


def R3_pt1'' := aff_lib.affine_coord_space.mk_point R3 ⟨[1,-1,1], by refl⟩
def R3_vec1'' := aff_lib.affine_coord_space.mk_vec R3 ⟨[0,1,0], by refl⟩
def R3_vec2'' := aff_lib.affine_coord_space.mk_vec R3 ⟨[0,0,1], by refl⟩
def R3_vec3'' := aff_lib.affine_coord_space.mk_vec R3 ⟨[1,0,0], by refl⟩
--combine derived frame func into mk derived space

def other_der_fr := affine_coord_space.mk_frame 
    R3 
    R3_pt1'' 
    (λ i : fin 3, vector.nth (⟨[R3_vec1'', R3_vec3'', R3_vec2''], sorry⟩ : vector _ 3) i)
    sorry

def other_der_sp := affine_coord_space.mk_derived_from_coords R3 (affine_coord_frame.get_coords other_der_fr)


def der_to_other_der_path := affine_coord_space.find_transform_path
    der_sp other_der_sp

#check der_to_other_der_path.from_
#check der_to_other_der_path.to_