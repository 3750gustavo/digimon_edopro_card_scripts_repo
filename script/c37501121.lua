--RizeGreymon
local s,id=GetID()
function s.initial_effect(c)
	-- Fusion Summon
	Fusion.AddProcMix(c,true,true,37501120,37501119)
	Fusion.AddProcMix(c,true,true,37501176,37501119)
	Fusion.AddContactProc(c, s.contactfil, s.contactop, s.splimit)
	-- Special Summon Digiegg
	local e4 = Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id, 0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(s.pctcon)
	e4:SetTarget(s.pcttg)
	e4:SetOperation(s.pctop)
	c:RegisterEffect(e4)
	-- Battle Indestructible
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(1)
	e2:SetValue(s.valcon)
	c:RegisterEffect(e2)
	-- Disable Destroyed Monster Effect
	local e3 = Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLED)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
function s.valcon(e, re, r, rp)
	return (r & REASON_BATTLE) ~= 0
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost, tp, LOCATION_ONFIELD + LOCATION_HAND, 0, nil)
end
function s.contactop(g, tp)
	Duel.ConfirmCards(1 - tp, g)
	Duel.SendtoGrave(g, REASON_COST + REASON_MATERIAL, nil)
end
function s.splimit(e, se, sp, st)
	return true
end
function s.pctcon(e, tp, eg, ep, ev, re, r, rp)
	return bit.band(r, REASON_EFFECT + REASON_BATTLE) ~= 0
end
function s.pcttg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return true end
end
function s.pctop(e, tp, eg, ep, ev, re, r, rp)
	local token = Duel.CreateToken(tp, 37501103)
	Duel.MoveToField(token, tp, tp, LOCATION_MZONE, POS_FACEUP, true)
end
function s.disop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local d = Duel.GetAttackTarget()
	local pos = d:GetSequence()
	if d == c then 
		d = Duel.GetAttacker()
		pos = d:GetSequence()
	 end
	if not d or c:IsStatus(STATUS_BATTLE_DESTROYED) or not d:IsStatus(STATUS_BATTLE_DESTROYED) then
		return
	end
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT + RESETS_STANDARD_EXC_GRAVE)
	d:RegisterEffect(e1)
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT + RESETS_STANDARD_EXC_GRAVE)
	d:RegisterEffect(e2)
	local adjPos1 = pos + 1 -- Position of the adjacent zone (pos+1)
	local adjPos2 = pos - 1 -- Position of the adjacent zone (pos-1)
	if adjPos1 <= 4 then
			Debug.ShowHint("entrou no if da direita")
			local adjCard1 = Duel.GetFieldCard(1-tp,LOCATION_MZONE,adjPos1) -- Get the card in the adjacent zone (pos+1)
			if adjCard1 then
				Duel.Destroy(adjCard1, REASON_EFFECT)
				local e3 = Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_DISABLE)
				e3:SetReset(RESET_EVENT + RESETS_STANDARD_EXC_GRAVE)
				adjCard1:RegisterEffect(e3)
				local e4 = Effect.CreateEffect(c)
				e4:SetType(EFFECT_TYPE_SINGLE)
				e4:SetCode(EFFECT_DISABLE_EFFECT)
				e4:SetReset(RESET_EVENT + RESETS_STANDARD_EXC_GRAVE)
				adjCard1:RegisterEffect(e4)
			end
		end
		if adjPos2 >= 0 then
			Debug.ShowHint("entrou no if da esquerda")
			local adjCard2 = Duel.GetFieldCard(1-tp,LOCATION_MZONE,adjPos2) -- Get the card in the adjacent zone (pos-1)
			if adjCard2 then
				Duel.Destroy(adjCard2, REASON_EFFECT)
				local e5 = Effect.CreateEffect(c)
				e5:SetType(EFFECT_TYPE_SINGLE)
				e5:SetCode(EFFECT_DISABLE)
				e5:SetReset(RESET_EVENT + RESETS_STANDARD_EXC_GRAVE)
				adjCard2:RegisterEffect(e5)
				local e6 = Effect.CreateEffect(c)
				e6:SetType(EFFECT_TYPE_SINGLE)
				e6:SetCode(EFFECT_DISABLE_EFFECT)
				e6:SetReset(RESET_EVENT + RESETS_STANDARD_EXC_GRAVE)
				adjCard2:RegisterEffect(e6)
			end
		end
		-- destroy by battle c if still on field
		if d:IsLocation(LOCATION_MZONE) and d:IsRelateToBattle() then
			Duel.Destroy(d, REASON_BATTLE)
			--negate the effects of the destroyed monster
			local e7 = Effect.CreateEffect(c)
			e7:SetType(EFFECT_TYPE_SINGLE)
			e7:SetCode(EFFECT_DISABLE)
			e7:SetReset(RESET_EVENT + RESETS_STANDARD_EXC_GRAVE)
			d:RegisterEffect(e7)
			local e8 = Effect.CreateEffect(c)
			e8:SetType(EFFECT_TYPE_SINGLE)
			e8:SetCode(EFFECT_DISABLE_EFFECT)
			e8:SetReset(RESET_EVENT + RESETS_STANDARD_EXC_GRAVE)
			d:RegisterEffect(e8)
		end
end