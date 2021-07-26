lemma congr_angle_add {a b c d a' b' c' d' : C.pts} (hd : inside_angle d b a c) (hb'c' : diff_side_line (a'-ₗd') b' c')
(hbac : noncollinear b a c) (h₁ : ∠ b a d ≅ₐ ∠ b' a' d') (h₂ : ∠ d a c ≅ₐ ∠ d' a' c') :
inside_angle d' a' b' c' ∧ (∠ b a c ≅ₐ ∠ b' a' c') :=
begin
  have hab := (noncollinear_not_eq hbac).1.symm,
  have hac := (noncollinear_not_eq hbac).2.1,
  have hbc := (noncollinear_not_eq hbac).2.2.symm,
  have wtlg : ∃ p : C.pts, inside_angle p b a c ∧ ∠ b a d = ∠ b a p ∧ ∠ d a c = ∠ p a c ∧ C.is_between b p c,
    cases crossbar hbac hd with p hp, use p,
    by_cases hdp : d = p,
      rw ←hdp at hp, unfold two_pt_segment at hp, simp at hp, rcases hp.2 with hp | hp | hp,
      rw hp at hd, exact absurd (pt_right_in_line a b) (same_side_line_not_in (line_in_lines hab) hd.1).2,
      rw hp at hd, exact absurd (pt_right_in_line a c) (same_side_line_not_in (line_in_lines hac) hd.2).2,
      rw ←hdp, exact ⟨hd, rfl, rfl, hp⟩,
    have had : a ≠ d,
      have := same_side_line_not_in (line_in_lines hab) hd.1,
      intro had, rw ←had at this, exact this.2 (pt_left_in_line a b),
    have hap : a ≠ p,
      intro hap, rw ←hap at hp, have : a ∈ (b-ₗc), from (segment_in_line b c) hp.2,
      exact hbac ⟨b-ₗc, line_in_lines hbc, pt_left_in_line b c, this, pt_right_in_line b c⟩,
    have ha : a ∈ ↑(line d p),
      have ha := pt_left_in_line a d,
      rw two_pt_one_line (line_in_lines had) (line_in_lines hdp) hdp
        ⟨pt_right_in_line a d, (ray_in_line a d) hp.1⟩ ⟨pt_left_in_line d p, pt_right_in_line d p⟩ at ha,
      exact ha,
    have hadp : same_side_pt a d p,
      cases hp.1 with h h, exact h, simp at h, exact absurd h.symm hap,
    have : same_side_line (a-ₗb) d p,
      rintros ⟨x, hx⟩,
      have : (a-ₗb) ≠ (d-ₗp),
        intro hf, have := pt_left_in_line d p, rw ←hf at this,
        exact (same_side_line_not_in (line_in_lines hab) hd.1).2 this,
      have hax := two_line_one_pt (line_in_lines hab) (line_in_lines hdp) this (pt_left_in_line a b) ha hx.1 ((segment_in_line d p) hx.2),
      rw ←hax at hx,
      unfold two_pt_segment at hx, simp at hx, rcases hx.2 with hx | hx | hx,
      exact had hx, exact hap hx,
      rw [is_between_diff_side_pt, ←not_same_side_pt hadp.2 had.symm hap.symm] at hx,
      exact hx hadp,
    split, split,
    exact same_side_line_trans (line_in_lines hab) hd.1 this,
    have : same_side_line (a-ₗc) d p,
      rintros ⟨x, hx⟩,
      have : (a-ₗc) ≠ (d-ₗp),
        intro hf, have := pt_left_in_line d p, rw ←hf at this,
        exact (same_side_line_not_in (line_in_lines hac) hd.2).2 this,
      have hax := two_line_one_pt (line_in_lines hac)
        (line_in_lines hdp) this (pt_left_in_line a c) ha hx.1 ((segment_in_line d p) hx.2),
      rw ←hax at hx,
      have : same_side_pt a d p,
        cases hp.1 with h h, exact h, simp at h, exact absurd h.symm hap,
      unfold two_pt_segment at hx, simp at hx, rcases hx.2 with hx | hx | hx,
      exact had hx, exact hap hx,
      rw [is_between_diff_side_pt, ←not_same_side_pt this.2 had.symm hap.symm] at hx,
      exact hx this,
    exact same_side_line_trans (line_in_lines hac) hd.2 this,
    split, exact angle_same_side b hadp,
    split, rw [angle_symm, angle_same_side c hadp, angle_symm],
    unfold two_pt_segment at hp, simp at hp, rcases hp.2 with hpb | hpc | hp,
    rw hpb at hp, have := pt_right_in_line a d,
--have := same_side_line_not_in (line_in_lines hac) hd.2,
  rcases wtlg with ⟨p, hp, hp₁, hp₂⟩, rw hp₁ at h₁, rw hp₂ at h₂, clear hd h₁ h₂ hp₁ hp₂ d,
  rename [p d, hp hd],
end