import organised.order.segment

open_locale classical
open set

variable [B : incidence_order_geometry]

open incidence_geometry incidence_order_geometry

include B

/--Two points `a` `b` are on the same side of a line if segment `a` `b`
doesn't intersects with the line.
-/
def same_side_line (l : set pts) (a b : pts) : Prop := ¬(l ♥ (a-ₛb).inside)

/--Segment `a` `b` intersects with the line and not at `a` or `b`. -/
def diff_side_line (l : set pts) (a b : pts) : Prop :=
(l ♥ (a-ₛb).inside) ∧ a ∉ l ∧ b ∉ l

lemma plane_separation
{l : set pts} {a b : pts} (ha : a ∉ l) (hb : b ∉ l) :
(same_side_line l a b ∨ diff_side_line l a b)
∧ ¬(same_side_line l a b ∧ diff_side_line l a b) :=
begin
  unfold same_side_line diff_side_line, unfold two_pt_segment,
  split,
  apply not_or_of_imp, intro h,
  exact ⟨h, ha, hb⟩,
  intro hf,
  exact hf.1 hf.2.1
end

lemma same_or_diff_line_strict
{l : set pts} {a b : pts} (ha : a ∉ l) (hb : b ∉ l) :
(same_side_line l a b ∨ diff_side_line l a b)
∧ ¬(same_side_line l a b ∧ diff_side_line l a b) :=
begin
  unfold same_side_line diff_side_line, unfold two_pt_segment,
  split,
  rw or_and_distrib_left,
  split, exact or.comm.mp (em _),
  right, exact ⟨ha, hb⟩,
  push_neg,
  intros hf ht, exact absurd ht hf
end

lemma not_same_side_line {l : set pts} {a b : pts} (ha : a ∉ l) (hb : b ∉ l) :
¬(same_side_line l a b) ↔ (diff_side_line l a b) :=
begin
  split, intro hns,
  cases (same_or_diff_line_strict ha hb).1 with hs hd,
  exact absurd hs hns, exact hd,
  intros hd hs,
  exact absurd (by exact ⟨hs, hd⟩) (same_or_diff_line_strict ha hb).2
end

lemma not_diff_side_line {l : set pts} {a b : pts} (ha : a ∉ l) (hb : b ∉ l) :
¬(diff_side_line l a b) ↔ (same_side_line l a b)
:= by rw [←not_iff_not.mpr (not_same_side_line ha hb), not_not]

lemma same_side_line_refl {l : set pts} {a : pts} (ha : a ∉ l) :
same_side_line l a a :=
begin
  unfold same_side_line intersect, 
  rw segment_singleton, rw not_nonempty_iff_eq_empty, ext1, simp,
  intros h hxa, rw hxa at h, exact ha h
end

lemma same_side_line_symm {l : set pts} {a b : pts} :
same_side_line l a b → same_side_line l b a :=
by {unfold same_side_line, rw segment_symm, simp}

lemma diff_side_line_symm {l : set pts} {a b : pts} :
diff_side_line l a b → diff_side_line l b a :=
by {unfold diff_side_line, rw segment_symm, tauto}

lemma same_side_line_not_in {x y : pts} {l : set pts} :
same_side_line l x y → x ∉ l ∧ y ∉ l :=
begin
  intro hlxy, unfold same_side_line intersect at hlxy, rw not_nonempty_iff_eq_empty at hlxy,
  split,
  intro hxl, have : x ∈ l ∩ (x-ₛy).inside, simp, exact ⟨hxl, by {unfold two_pt_segment, simp}⟩,
  rw hlxy at this, exact this,
  intro hyl, have : y ∈ l ∩ (x-ₛy).inside, simp, exact ⟨hyl, by {unfold two_pt_segment, simp}⟩,
  rw hlxy at this, exact this
end

lemma same_side_line_neq {a b x y : pts} :
same_side_line (a-ₗb) x y → x ≠ a ∧ x ≠ b :=
begin
  intro hxy,
  split; intro hf;
  rw hf at hxy,
  exact (same_side_line_not_in hxy).1 (pt_left_in_line a b),
  exact (same_side_line_not_in hxy).1 (pt_right_in_line a b)
end

lemma same_side_line_neq' {a b x y : pts} :
same_side_line (a-ₗb) x y → y ≠ a ∧ y ≠ b :=
λhxy, same_side_line_neq (same_side_line_symm hxy)

lemma same_side_line_noncollinear {a b c d : pts} :
same_side_line (a-ₗb) c d → a ≠ b → noncollinear a b c ∧ noncollinear a b d :=
begin
  intros hcd hab,
  split; intro h,
  exact (same_side_line_not_in hcd).1 (collinear_in12 h hab),
  exact (same_side_line_not_in hcd).2 (collinear_in12 h hab)
end

lemma diff_side_line_neq {a b x y : pts} :
diff_side_line (a-ₗb) x y → x ≠ a ∧ x ≠ b :=
begin
  intro hxy,
  split; intro hf;
  rw hf at hxy,
  exact hxy.2.1 (pt_left_in_line a b),
  exact hxy.2.1 (pt_right_in_line a b)
end

lemma diff_side_line_neq' {a b x y : pts} :
diff_side_line (a-ₗb) x y → y ≠ a ∧ y ≠ b :=
λhxy, diff_side_line_neq (diff_side_line_symm hxy)

private lemma same_side_line_trans_noncollinear {l : set pts} (hl : l ∈ lines) {a b c : pts} :
noncollinear a b c → same_side_line l a b → same_side_line l b c → same_side_line l a c :=
begin
  unfold same_side_line, intros h hlab hlbc,
  rw segment_symm at hlbc,
  intro hlac,
  replace h : noncollinear a c b,
    unfold noncollinear collinear, unfold noncollinear collinear at h,
    intro hf, apply h, rcases hf with ⟨l, hl, hal, hcl, hbl⟩,
    exact ⟨l, hl, hal, hbl, hcl⟩, 
  cases (pasch h hl (same_side_line_not_in hlab).1 (same_side_line_not_in hlbc).1
    (same_side_line_not_in hlab).2 hlac).1 with hf hf,
  exact hlab hf, exact hlbc hf
end

lemma same_side_line_trans {l : set pts} (hl : l ∈ lines) {a b c : pts} :
same_side_line l a b → same_side_line l b c → same_side_line l a c :=
begin
  by_cases collinear a b c; intros hlab hlbc,
  by_cases hab : a = b, rw ←hab at hlbc, exact hlbc,
  by_cases hbc : b = c, rw hbc at hlab, exact hlab,
  by_cases hac : a = c, rw hac, exact same_side_line_refl (same_side_line_not_in hlbc).2,
  rcases h with ⟨m, hm, ham, hbm, hcm⟩,
  have hd : ∃ d : pts, d ∈ l ∧ d ∉ m,
    rcases two_pt_on_one_line hl with ⟨x, y, hxy, hxl, hyl⟩,
    have hlm : l ≠ m, intro hlm, rw ←hlm at ham, exact (same_side_line_not_in hlab).1 ham,
    by_contra, push_neg at h,
    exact hxy (two_line_one_pt hl hm hlm hxl (h x hxl) hyl (h y hyl)),
  rcases hd with ⟨d, hdl, hdm⟩,
  cases is_between_extend (show d ≠ a, by {intro hda, rw hda at hdm, exact hdm ham}) with e hdae,
  have hlae : same_side_line l a e,
    intro hlae, cases hlae with f hf,
    have hflae : f ∈ l ∧ f ∈ (a-ₗe),
      simp at hf,
      exact ⟨hf.1, segment_in_line a e hf.2⟩,
    have hdlae : d ∈ l ∧ d ∈ (a-ₗe),
      simp at hf,
      split, exact hdl,
      rcases is_between_collinear hdae with ⟨n, hn, hdn, han, hen⟩,
      have := (two_pt_one_line (line_in_lines (is_between_not_eq hdae).2.2) hn
        ((is_between_not_eq hdae).2.2) ⟨pt_left_in_line a e, pt_right_in_line a e⟩ ⟨han, hen⟩),
      rw this, exact hdn,
    have hneq : l ≠ (a-ₗe),
      intro hf, have := (same_side_line_not_in hlab).1,
      rw hf at this, exact this (pt_left_in_line a e),
    have hdf : d = f, from two_line_one_pt hl (line_in_lines (is_between_not_eq hdae).2.2)
      hneq hdlae.1 hdlae.2 hflae.1 hflae.2,
    rw hdf at hdae,
    unfold two_pt_segment at hf, simp at hf,
    have := is_between_not_eq hdae,
    rcases hf.2 with hf | hf | hf,
    exact this.1 hf, exact this.2.1 hf,
  exact (collinear_between (is_between_collinear hf)).2.2.1 ⟨hf, hdae⟩,
  have hbae : noncollinear b a e,
    rintros ⟨n, hn, hbn, han, hen⟩,
    have hem : e ∈ m,
      rw two_pt_one_line hm hn hab ⟨ham, hbm⟩ ⟨han, hbn⟩, exact hen,
    have hd : d ∈ (a-ₗe),
      rcases is_between_collinear hdae with ⟨n, hn, hdn, han, hen⟩,
      have := (two_pt_one_line (line_in_lines (is_between_not_eq hdae).2.2) hn
        ((is_between_not_eq hdae).2.2) ⟨pt_left_in_line a e, pt_right_in_line a e⟩ ⟨han, hen⟩),
      rw this, exact hdn,
    have := two_pt_one_line hm (line_in_lines (is_between_not_eq hdae).2.2)
      (is_between_not_eq hdae).2.2 ⟨ham, hem⟩ ⟨pt_left_in_line a e, pt_right_in_line a e⟩,
    rw ←this at hd,
    exact hdm hd,
  have hebc : noncollinear e b c,
    rintros ⟨n, hn, hen, hbn, hcn⟩,
    rw ←(two_pt_one_line hm hn hbc ⟨hbm, hcm⟩ ⟨hbn, hcn⟩) at hen,
    exact hbae ⟨m, hm, hbm, ham, hen⟩,
  have haec : noncollinear a e c,
    rintros ⟨n, hn, han, hen, hcn⟩,
    rw ←(two_pt_one_line hm hn hac ⟨ham, hcm⟩ ⟨han, hcn⟩) at hen,
    exact hbae ⟨m, hm, hbm, ham, hen⟩,
  have hlbe := same_side_line_trans_noncollinear hl hbae (same_side_line_symm hlab) hlae,
  have hlec := same_side_line_trans_noncollinear hl hebc (same_side_line_symm hlbe) hlbc,
  exact same_side_line_trans_noncollinear hl haec hlae hlec,
  exact same_side_line_trans_noncollinear hl h hlab hlbc
end

/--Two points `a` `b` are on the same side of the point `o` if
they are collinear and `o` is not in segment `a` `b`.
-/
def same_side_pt (o a b : pts) : Prop :=
o ∉ (a-ₛb).inside ∧ collinear o a b

/--`o` is in segment `a` `b` but is not `a` and `b`. -/
def diff_side_pt (o a b : pts) : Prop :=
o ∈ (a-ₛb).inside ∧ a ≠ o ∧ b ≠ o

lemma same_side_pt_neq {o a b : pts} (hoab : same_side_pt o a b) : a ≠ o ∧ b ≠ o :=
begin
  unfold same_side_pt at hoab, unfold two_pt_segment at hoab,
  split,
  intro hao, rw hao at hoab,
  simp at hoab, exact hoab,
  intro hbo, rw hbo at hoab,
  simp at hoab, exact hoab
end

lemma diff_side_pt_collinear {o a b : pts} : diff_side_pt o a b → collinear o a b :=
begin
  intro hoab,
  by_cases a = b,
    rw h, exact ⟨(b-ₗo), line_in_lines hoab.2.2,
      pt_right_in_line b o, pt_left_in_line b o, pt_left_in_line b o⟩,
  exact ⟨(a-ₗb), line_in_lines h,
    (segment_in_line a b) hoab.1, pt_left_in_line a b, pt_right_in_line a b⟩
end

theorem line_separation
{p a b : pts} (hpab : collinear p a b) (hap : a ≠ p) (hbp : b ≠ p) : 
(same_side_pt p a b ∨ diff_side_pt p a b) ∧
¬(same_side_pt p a b ∧ diff_side_pt p a b) :=
begin
  unfold same_side_pt diff_side_pt,
  split, by_cases hp : p ∈ (a-ₛb).inside,
  right, exact ⟨hp, hap, hbp⟩,
  left, exact ⟨hp, hpab⟩,
  push_neg,
  intros h₁ h₂, exact absurd h₂ h₁.1
end

lemma not_same_side_pt
{p a b : pts} (hpab : collinear p a b) (ha : a ≠ p) (hb : b ≠ p) :
(¬same_side_pt p a b ↔ diff_side_pt p a b) :=
begin
  have := line_separation hpab ha hb,
  split,
  intro hs,
  cases this.1 with h h,
  exact absurd h hs, exact h,
  intro hd,
  cases (not_and_distrib.mp this.2) with h h,
  exact h, exact absurd hd h
end

lemma not_diff_side_pt
{p a b : pts} (hpab : collinear p a b) (ha : a ≠ p) (hb : b ≠ p) :
(¬diff_side_pt p a b ↔ same_side_pt p a b) :=
by rw [←not_iff_not.mpr (not_same_side_pt hpab ha hb), not_not]

lemma same_side_pt_refl {a b : pts} (hab : a ≠ b) : same_side_pt a b b :=
begin
  split, rw segment_singleton, exact hab,
  exact ⟨a-ₗb, line_in_lines hab, pt_left_in_line a b, pt_right_in_line a b, pt_right_in_line a b⟩
end

lemma same_side_pt_symm {a b c : pts} :
same_side_pt a b c → same_side_pt a c b :=
begin
  unfold same_side_pt,
  intro habc, split,
  rw segment_symm, exact habc.1,
  rcases habc.2 with ⟨l, hl, hal, hbl, hcl⟩,
  exact ⟨l, hl, hal, hcl, hbl⟩
end

lemma diff_side_pt_symm {a b c : pts} :
diff_side_pt a b c → diff_side_pt a c b :=
begin
  unfold diff_side_pt, rw segment_symm, tauto
end

lemma same_side_pt_line {a b c : pts} : same_side_pt a b c
→ collinear a b c ∧ a ≠ b ∧ a ≠ c
∧ ∀ {l : set pts}, l ∈ lines → a ∈ l ∧ b ∉ l ∧ c ∉ l → same_side_line l b c :=
begin
  intro habc, split, exact habc.2,
  have hab := (same_side_pt_neq habc).1.symm,
  have hac := (same_side_pt_neq habc).2.symm,
  split, exact hab,
  split, exact hac,
  intros l hl habcl,
  by_cases hbc : b = c, rw ←hbc,
  exact same_side_line_refl habcl.2.1,
  rintros ⟨x, hxl, hxbc⟩,
  have hlab : l ≠ (a-ₗb),
    intro hf, rw hf at habcl, exact habcl.2.1 (pt_right_in_line a b),
  have hxab : x ∈ (a-ₗb),
    rcases habc.2 with ⟨l, hl, hal, hbl, hcl⟩,
    rw (two_pt_one_line (line_in_lines hab) hl hab
      ⟨pt_left_in_line a b, pt_right_in_line a b⟩ ⟨hal, hbl⟩),
    rw (two_pt_one_line hl (line_in_lines hbc) hbc
      ⟨hbl, hcl⟩ ⟨pt_left_in_line b c, pt_right_in_line b c⟩),
    exact (segment_in_line b c) hxbc,
  rw ←(two_line_one_pt hl (line_in_lines hab) hlab habcl.1
    (pt_left_in_line a b) hxl hxab) at hxbc,
  unfold two_pt_segment at hxbc, simp at hxbc,
  unfold same_side_pt at habc, unfold two_pt_segment at habc, simp at habc,
  exact habc.1 hxbc,
end

lemma diff_side_pt_line {a b c : pts} : diff_side_pt a b c
→ collinear a b c ∧ a ≠ b ∧ a ≠ c
∧ ∀ {l : set pts}, l ∈ lines → a ∈ l ∧ b ∉ l ∧ c ∉ l → diff_side_line l b c :=
begin
  intro h, split, exact (diff_side_pt_collinear h),
  split, exact h.2.1.symm, split, exact h.2.2.symm,
  intros l hl habcl, use a,
  exact ⟨habcl.1, h.1⟩, exact ⟨habcl.2.1, habcl.2.2⟩,
end

lemma is_between_diff_side_pt {a b c : pts} :
is_between a b c ↔ diff_side_pt b a c :=
begin
  unfold diff_side_pt, unfold two_pt_segment,
  split, intro habc,
  simp, split, right, right, exact habc,
  rcases is_between_collinear habc with ⟨l, hl, hal, hbl, hcl⟩,
  exact ⟨(is_between_not_eq habc).1, (is_between_not_eq habc).2.2.symm⟩,
  simp, intros h hab hcb,
  rcases h with h | h | h,
  exact absurd h.symm hab,
  exact absurd h.symm hcb,
  exact h
end

lemma is_between_same_side_pt {a b c : pts} :
is_between a b c ↔ same_side_pt a b c ∧ same_side_pt c a b :=
begin
  split, intro habc,
  unfold same_side_pt, unfold two_pt_segment,
  simp, split; split,
  intro hf, rcases hf with hab | hac | hbac,
  exact (is_between_not_eq habc).1 hab,
  exact (is_between_not_eq habc).2.1 hac,
  exact (collinear_between (is_between_collinear habc)).2.2.1 ⟨habc, hbac⟩,
  exact (is_between_collinear habc),
  intro hf, rcases hf with hca | hcb | hacb,
  exact (is_between_not_eq habc).2.1 hca.symm,
  exact (is_between_not_eq habc).2.2 hcb.symm,
  exact (collinear_between (is_between_collinear habc)).2.1 ⟨habc, hacb⟩,
  rcases is_between_collinear habc with ⟨l, hl, hal, hbl, hcl⟩,
  exact ⟨l, hl, hcl, hal, hbl⟩,
  unfold same_side_pt, unfold two_pt_segment, simp, push_neg,
  intros h₁ habc h₂ hcab,
  rcases (collinear_between habc).1 h₁.1 h₁.2.1 h₂.2.1.symm with h | h | h,
  exact h, exact absurd h h₂.2.2, exact absurd h h₁.2.2
end

lemma same_side_line_pt {a b c : pts}: (collinear a b c ∧ a ≠ b ∧ a ≠ c
∧ ∃ {l : set pts}, l ∈ lines ∧ a ∈ l ∧ b ∉ l ∧ c ∉ l ∧ same_side_line l b c)
→ same_side_pt a b c :=
begin
  rintros ⟨habc, hab, hac, l, hl, hal, hbl, hcl, hlbc⟩,
  rw ←(not_diff_side_pt habc hab.symm hac.symm), intro hf,
  have := (diff_side_pt_line hf).2.2.2 hl ⟨hal, hbl, hcl⟩,
  exact (plane_separation hbl hcl).2 ⟨hlbc, this⟩
end

lemma diff_side_line_pt {a b c : pts}: (collinear a b c ∧ a ≠ b ∧ a ≠ c
∧ ∃ {l : set pts}, l ∈ lines ∧ a ∈ l ∧ b ∉ l ∧ c ∉ l ∧ diff_side_line l b c)
→ diff_side_pt a b c :=
begin
  rintros ⟨habc, hab, hac, l, hl, hal, hbl, hcl, hlbc⟩,
  rw ←(not_same_side_pt habc hab.symm hac.symm), intro hf,
  have := (same_side_pt_line hf).2.2.2 hl ⟨hal, hbl, hcl⟩,
  exact (plane_separation hbl hcl).2 ⟨this, hlbc⟩
end

private lemma line_pt_exist {a b c : pts} (habc : collinear a b c) (hab : a ≠ b) (hac : a ≠ c) : 
∃ l ∈ to_incidence_geometry.lines, a ∈ l ∧ b ∉ l ∧ c ∉ l :=
begin
  rcases habc with ⟨l, hl, hal, hbl, hcl⟩,
  have hd : ∃ d : pts, noncollinear a b d ∧ d ∉ l,
    cases noncollinear_exist hab with d habd, use d, split, exact habd,
    intro hdl, exact habd ⟨l, hl, hal, hbl, hdl⟩,
  rcases hd with ⟨d, habd, hdl⟩,
  have hb : b ∉ (a-ₗd),
    intro hb, exact habd ⟨(a-ₗd), line_in_lines (noncollinear_neq habd).2.1,
      pt_left_in_line a d, hb, pt_right_in_line a d⟩,
  have hc : c ∉ (a-ₗd),
    intro hc, rw two_pt_one_line hl (line_in_lines (noncollinear_neq habd).2.1)
      hac ⟨hal, hcl⟩ ⟨pt_left_in_line a d, hc⟩ at hbl,
    exact hb hbl,
  exact ⟨(a-ₗd), line_in_lines (noncollinear_neq habd).2.1, pt_left_in_line a d, hb, hc⟩
end

lemma same_side_pt_trans {a b c d : pts} :
same_side_pt a b c → same_side_pt a c d → same_side_pt a b d :=
begin
  intros habc hacd,
  have habc' := same_side_pt_line habc,
  have hacd' := same_side_pt_line hacd,
  apply same_side_line_pt,
  split,
  rcases habc'.1 with ⟨l, hl, hal, hbl, hcl⟩,
  rcases hacd'.1 with ⟨m, hm, ham, hcm, hdm⟩,
  rw two_pt_one_line hm hl hacd'.2.1 ⟨ham, hcm⟩ ⟨hal, hcl⟩ at hdm,
  exact ⟨l, hl, hal, hbl, hdm⟩,
  split, exact habc'.2.1,
  split, exact hacd'.2.2.1,
  rcases line_pt_exist habc'.1 habc'.2.1 habc'.2.2.1 with ⟨l, hl, hal, hbl, hcl⟩,
  have hdl : d ∉ l,
    intro hdl,
    rcases hacd'.1 with ⟨m, hm, ham, hcm, hdm⟩,
    rw two_pt_one_line hm hl hacd'.2.2.1 ⟨ham, hdm⟩ ⟨hal, hdl⟩ at hcm,
    exact hcl hcm,
  exact ⟨l, hl, hal, hbl, hdl, same_side_line_trans hl (habc'.2.2.2 hl ⟨hal, hbl, hcl⟩)
    (hacd'.2.2.2 hl ⟨hal, hcl, hdl⟩)⟩
end

lemma is_between_trans {a b c d : pts} :
is_between a b c → is_between b c d → is_between a b d ∧ is_between a c d :=
begin
  have : ∀ {a b c d : pts}, is_between a b c → is_between b c d → is_between a b d ,
    intros a b c d habc hbcd,
    rcases is_between_collinear habc with ⟨l, hl, hal, hbl, hcl⟩,
    rcases is_between_collinear hbcd with ⟨m, hm, hbm, hcm, hdm⟩,
    have h₁ : ¬same_side_pt b a c,
      rw not_same_side_pt ⟨l, hl, hbl, hal, hcl⟩ (is_between_not_eq habc).1
        (is_between_not_eq habc).2.2.symm,
      exact is_between_diff_side_pt.mp habc,
    have h₂ :  same_side_pt b c d, from (is_between_same_side_pt.mp hbcd).1,
    rw is_between_diff_side_pt,
    rw two_pt_one_line hm hl (is_between_not_eq habc).2.2 ⟨hbm, hcm⟩ ⟨hbl, hcl⟩ at hdm,            
    rw ←not_same_side_pt ⟨l, hl, hbl, hal, hdm⟩ (is_between_not_eq habc).1
      (is_between_not_eq hbcd).2.1.symm,
    intro h₃, replace h₂ := same_side_pt_symm h₂,
    exact h₁ (same_side_pt_trans h₃ h₂),
  intros habc hbcd, split, exact this habc hbcd,
  rw is_between_symm at habc hbcd, rw is_between_symm,
  exact this hbcd habc
end

lemma is_between_trans' {a b c d : pts} :
is_between a b d → is_between b c d → is_between a b c ∧ is_between a c d :=
begin
  have : ∀ {a b c d : pts}, is_between a b d → is_between b c d → is_between a b c ,
    intros a b c d habd hbcd,
    rcases is_between_collinear habd with ⟨l, hl, hal, hbl, hdl⟩,
    rcases is_between_collinear hbcd with ⟨m, hm, hbm, hcm ,hdm⟩,
    rw two_pt_one_line hm hl (is_between_not_eq habd).2.2 ⟨hbm, hdm⟩ ⟨hbl, hdl⟩ at hcm,
    rw [is_between_diff_side_pt, ←not_same_side_pt ⟨l, hl, hbl, hal, hcm⟩
      (is_between_not_eq habd).1 (is_between_not_eq hbcd).1.symm],
    intro hbac, have hbad := same_side_pt_trans hbac (is_between_same_side_pt.mp hbcd).1,
    rw [is_between_diff_side_pt, ←not_same_side_pt ⟨l, hl, hbl, hal, hdl⟩] at habd,
    exact habd hbad, exact habd.2.1, exact habd.2.2,
  intros habd hbcd,
  have habc := this habd hbcd,
  exact ⟨habc, (is_between_trans habc hbcd).2⟩
end

lemma same_side_pt_between {a b c : pts} :
same_side_pt a b c → b ≠ c → is_between a b c ∨ is_between a c b :=
begin
  intros habc hbc,
  rcases (collinear_between habc.2).1 (same_side_pt_neq habc).1.symm
    (same_side_pt_neq habc).2.symm hbc with h | h | h,
  left, exact h, right, exact h,
  rw [is_between_diff_side_pt, ←not_same_side_pt habc.2] at h, exact absurd habc h,
  exact (same_side_pt_neq habc).1,
  exact (same_side_pt_neq habc).2
end

lemma is_between_same_side_pt_is_between {a b c d : pts} :
is_between a b c → same_side_pt b c d → is_between a b d :=
begin
  intros habc hbcd,
  by_cases hcd : c = d,
    rw hcd at habc, exact habc,
  cases same_side_pt_between hbcd hcd,
  exact (is_between_trans habc h).1,
    exact (is_between_trans' habc h).1
end

lemma diff_side_line_cancel {l : set pts} (hl : l ∈ lines) {a b c : pts} :
diff_side_line l a b → diff_side_line l b c → same_side_line l a c :=
begin
  intros h₁ h₂,
  have hab : a ≠ b,
    intro hf, rw ←hf at h₁, unfold diff_side_line intersect at h₁, rw segment_singleton at h₁,
    cases h₁.1 with a' ha', simp at ha', rw ←ha'.2 at h₁, exact h₁.2.1 ha'.1,
  by_cases hac : a = c,
    rw ←hac, exact same_side_line_refl h₁.2.1,
  have hbc : b ≠ c,
    intro hf, rw ←hf at h₂, unfold diff_side_line intersect at h₂, rw segment_singleton at h₂,
    cases h₂.1 with b' hb', simp at hb', rw ←hb'.2 at h₂, exact h₂.2.1 hb'.1,
  by_cases habc : collinear a b c,
    cases h₁.1 with x hx,
    have : diff_side_pt x a b,
      unfold diff_side_pt, split, exact hx.2,
      split; intro hf; rw ←hf at hx, exact h₁.2.1 hx.1, exact h₁.2.2 hx.1,
    rw ←is_between_diff_side_pt at this,
    by_contra hlac, rw not_same_side_line at hlac, cases hlac.1 with y hy,
    have hyac := (segment_in_line a c) hy.2,
    rcases habc with ⟨m, hm, ham, hbm, hcm⟩,
    rw two_pt_one_line (line_in_lines hac) hm hac
      ⟨pt_left_in_line a c, pt_right_in_line a c⟩ ⟨ham, hcm⟩ at hyac,
    rw two_pt_one_line hm (line_in_lines hab) hab ⟨ham, hbm⟩
      ⟨pt_left_in_line a b, pt_right_in_line a b⟩ at hyac,
    have hneq : l ≠ (a-ₗb),
      intro hf, have := pt_left_in_line a b, rw ←hf at this, exact h₁.2.1 this,
    have hxy := two_line_one_pt hl (line_in_lines hab) hneq hx.1
      ((segment_in_line a b) hx.2) hy.1 hyac,
    rw ←hxy at hy, unfold two_pt_segment at hy, simp at hy,
    rcases hy.2 with hya | hyc | hy,
    exact (is_between_not_eq this).1.symm hya, rw ←hyc at hlac, exact hlac.2.2 hy.1,
    cases h₂.1 with z hz,
    have hzbc := (segment_in_line b c) hz.2,
    rw two_pt_one_line (line_in_lines hbc) hm hbc
      ⟨pt_left_in_line b c, pt_right_in_line b c⟩ ⟨hbm, hcm⟩ at hzbc,
    rw two_pt_one_line hm (line_in_lines hab) hab ⟨ham, hbm⟩
      ⟨pt_left_in_line a b, pt_right_in_line a b⟩ at hzbc,
    have hxz := two_line_one_pt hl (line_in_lines hab) hneq hx.1
      ((segment_in_line a b) hx.2) hz.1 hzbc,
    rw ←hxz at hz, unfold two_pt_segment at hz, simp at hz,
    rcases hz.2 with hzb | hzc | hz,
    exact (is_between_not_eq this).2.2 hzb, rw ←hzc at hlac, exact hlac.2.2 hz.1,
    rcases (collinear_between ⟨m, hm, ham, hbm, hcm⟩).1 hab hac hbc with habc | hacb | hbac,
    exact (collinear_between (is_between_collinear this)).2.1
      ⟨this, (is_between_trans' habc hz).1⟩,
    exact (collinear_between (is_between_collinear hy)).2.1
      ⟨hy, (is_between_trans' hacb (by {rw is_between_symm, exact hz})).1⟩,
    exact (collinear_between (is_between_collinear this)).2.2.1
      ⟨this, by {rw is_between_symm, exact (is_between_trans' hbac hy).1}⟩,
    exact h₁.2.1, exact h₂.2.2,
  by_contra h₃,
  rw not_same_side_line h₁.2.1 h₂.2.2 at h₃,
  unfold diff_side_line at h₁ h₂ h₃,
  exact (pasch habc hl h₁.2.1 h₁.2.2 h₂.2.2 h₁.1).2 ⟨h₃.1, h₂.1⟩
end

lemma diff_side_pt_cancel {a b c d : pts} :
diff_side_pt a b c → diff_side_pt a b d → same_side_pt a c d :=
begin
  intros habc habd,
  replace habc := diff_side_pt_line habc,
  replace habd := diff_side_pt_line habd,
  have hacd := collinear_trans habc.1 habd.1 habc.2.1,
  apply same_side_line_pt, split,
  exact hacd,
  split, exact habc.2.2.1, split, exact habd.2.2.1,
  rcases line_pt_exist hacd habc.2.2.1 habd.2.2.1 with ⟨l, hl, hal, hcl, hdl⟩,
  have hbl : b ∉ l,
    intro hbl,
    rw two_pt_one_line hl (line_in_lines habc.2.1) habc.2.1 at hcl, exact hcl
      (collinear_in12 habc.1 habc.2.1),
    exact ⟨hal, hbl⟩, exact ⟨pt_left_in_line a b, pt_right_in_line a b⟩,
  have h₁ := habc.2.2.2 hl ⟨hal, hbl, hcl⟩,
  have h₂ := habd.2.2.2 hl ⟨hal, hbl, hdl⟩,
  exact ⟨l, hl, hal, hcl, hdl, diff_side_line_cancel hl (diff_side_line_symm h₁) h₂⟩
end

lemma diff_side_same_side_line {l : set pts} (hl : l ∈ lines) {a b c : pts} :
diff_side_line l a b → same_side_line l b c → diff_side_line l a c :=
begin
  intros hlab hlbc,
  rw ←(not_same_side_line hlab.2.1 (same_side_line_not_in hlbc).2),
  rw ←not_same_side_line at hlab, intro hlac,
  exact hlab (same_side_line_trans hl hlac (same_side_line_symm hlbc)),
  exact hlab.2.1, exact hlab.2.2
end

lemma diff_side_same_side_pt {a b c d : pts} :
diff_side_pt a b c → same_side_pt a b d → diff_side_pt a c d :=
begin
  intros habc habd,
  rw ←not_same_side_pt, rw ←not_same_side_pt at habc,
  intro hacd, exact habc (same_side_pt_trans habd (same_side_pt_symm hacd)),
  exact (diff_side_pt_collinear habc), exact habc.2.1, exact habc.2.2,
  exact collinear_trans (diff_side_pt_collinear habc) habd.2 habc.2.1.symm,
  exact habc.2.2, exact (same_side_pt_neq habd).2
end

private lemma two_pt_segment_pt_prep {a b a' b' : pts} :
(a-ₛb) = (a'-ₛb') → a = a' → b = b' :=
begin
  intros haba'b' haa',
  replace haba'b' : (a-ₛb).inside = (a-ₛb').inside, rw [haba'b', ←haa'],
  by_contra hbb',
  by_cases hab : a = b, rw hab at haba'b',
    rw segment_singleton at haba'b',
    cases (two_pt_between hbb') with x hbxb',
    have hx : x ∈ (b-ₛb').inside,
      unfold two_pt_segment, simp, right, right, exact hbxb',
    rw ←haba'b' at hx, simp at hx, exact (is_between_not_eq hbxb').1 hx.symm,
  by_cases hab' : a = b', rw hab' at haba'b',
    rw segment_singleton at haba'b',
    cases (two_pt_between hbb') with x hbxb',
    have hx : x ∈ (b-ₛb').inside,
      unfold two_pt_segment, simp, right, right, exact hbxb',
    rw [segment_symm, haba'b'] at hx, simp at hx, exact (is_between_not_eq hbxb').2.2 hx,
  by_cases habb' : collinear a b b',
    rcases (collinear_between habb').1 hab hab' hbb' with h | h | h,
    cases (two_pt_between (is_between_not_eq h).2.2) with x hbxb',
    have haxb' := (is_between_trans' h hbxb').2,
    have h₁ : x ∈ (a-ₛb').inside,
      unfold two_pt_segment, simp, right, right, exact haxb',
    have h₂ : x ∉ (a-ₛb).inside,
      unfold two_pt_segment, simp, intro hf,
      rcases hf with hf | hf | hf,
      exact (is_between_not_eq (is_between_trans' h hbxb').2).1 hf.symm,
      exact (is_between_not_eq hbxb').1 hf.symm,
      have habx := (is_between_trans' h hbxb').1,
      exact (collinear_between (is_between_collinear hf)).2.1 ⟨hf, habx⟩,
    rw haba'b' at h₂, exact absurd h₁ h₂,
    cases (two_pt_between (is_between_not_eq h).2.2) with x hb'xb,
    have haxb := (is_between_trans' h hb'xb).2,
    have h₁ : x ∈ (a-ₛb).inside,
      unfold two_pt_segment, simp, right, right, exact haxb,
    have h₂ : x ∉ (a-ₛb').inside,
      unfold two_pt_segment, simp, intro hf,
      rcases hf with hf | hf | hf,
      exact (is_between_not_eq (is_between_trans' h hb'xb).2).1 hf.symm,
      exact (is_between_not_eq hb'xb).1 hf.symm,
      have hab'x := (is_between_trans' h hb'xb).1,
      exact (collinear_between (is_between_collinear hf)).2.1 ⟨hf, hab'x⟩,
    rw haba'b' at h₁, exact absurd h₁ h₂,
    cases (two_pt_between hab) with x haxb,
    have h₁ : x ∈ (a-ₛb).inside,
      unfold two_pt_segment, simp, right, right, exact haxb,
    have h₂ : x ∉ (a-ₛb').inside,
      unfold two_pt_segment, simp, intro hf,
      rw is_between_symm at h,
      rcases hf with hf | hf | hf,
      exact (is_between_not_eq haxb).1 hf.symm,
      exact (is_between_not_eq (is_between_trans' h haxb).2).1 hf.symm,
      have hb'ax := (is_between_trans' h haxb).1,
      rw is_between_symm at hf,
      exact (collinear_between (is_between_collinear hf)).2.1 ⟨hf, hb'ax⟩,
    rw haba'b' at h₁, exact absurd h₁ h₂,
    cases (two_pt_between hab) with x haxb,
    have h : x ∈ (a-ₛb').inside,
      rw ←haba'b', unfold two_pt_segment, simp, right, right, exact haxb,
    unfold two_pt_segment at h, simp at h, rcases h with h | h | h,
    exact absurd h (is_between_not_eq haxb).1.symm,
    rw h at haxb, rcases (is_between_collinear haxb) with ⟨l, hl, hal, hb'l, hbl⟩,
    exfalso, exact habb' ⟨l, hl, hal, hbl, hb'l⟩,
    rcases (is_between_collinear haxb) with ⟨l, hl, hal, hxl, hbl⟩,
    rcases (is_between_collinear h) with ⟨m, hm, ham, hxm, hb'm⟩,
    rw two_pt_one_line hm hl (is_between_not_eq haxb).1 ⟨ham, hxm⟩ ⟨hal, hxl⟩ at hb'm,
    exfalso, exact habb' ⟨l, hl, hal, hbl, hb'm⟩
end

lemma two_pt_segment_pt {a b a' b' : B.pts} :
(a-ₛb) = (a'-ₛb') → (a = a' ∧ b = b') ∨ (a = b' ∧ b = a') :=
begin
  intros haba'b',
  have := pt_left_in_segment a b,
  rw haba'b' at this, rcases this with ha | ha | ha,
  have := pt_left_in_segment a' b',
  rw ←haba'b' at this, rcases this with ha' | ha' | ha',
  simp at ha ha',  rw is_between_symm at ha, have hf := (is_between_trans ha ha').2, 
  have := pt_right_in_segment a b,
  rw haba'b' at this, rcases this with hb | hb | hb,
  simp at hb, rw is_between_symm at hf,
  exfalso, exact (collinear_between (is_between_collinear hb)).2.2.1 ⟨hb, hf⟩,
  exact absurd hb (is_between_not_eq ha').2.2.symm,
  exact absurd hb (is_between_not_eq hf).2.1.symm,
  exact absurd ha' (is_between_not_eq ha).1,
  right, rw segment_symm at haba'b',
  simp at ha',
  exact ⟨two_pt_segment_pt_prep haba'b' ha'.symm, ha'.symm⟩,
  left,
  exact ⟨ha, two_pt_segment_pt_prep haba'b' ha⟩,
  right, simp at ha,
  rw segment_symm a' b' at haba'b',
  exact ⟨ha, two_pt_segment_pt_prep haba'b' ha⟩
end