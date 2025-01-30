--DoruGreymon
local s,id,o=GetID()
function s.initial_effect(c)
	Fusion.AddProcMixN(c,true,true,37501157,1,aux.FilterBoolFunction(Card.IsSetCard,0x3763),1,37501156,1)
	Fusion.AddProcMixN(c,true,true,37501206,1,aux.FilterBoolFunction(Card.IsSetCard,0x3763),1,37501156,1)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	--virus
	local e3 = Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLED)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(s.pctcon)
	e4:SetTarget(s.pcttg)
	e4:SetOperation(s.pctop)
	c:RegisterEffect(e4)
	--Targeted monster loses 1000 atk
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_NEGATE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(s.targeta)
	e5:SetOperation(s.opereta)
	c:RegisterEffect(e5)
	--also treated as dragon
	local e0f=Effect.CreateEffect(c)
	e0f:SetType(EFFECT_TYPE_SINGLE)
	e0f:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0f:SetRange(LOCATION_MZONE)
	e0f:SetCode(EFFECT_ADD_RACE)
	e0f:SetValue(RACE_DRAGON)
	c:RegisterEffect(e0f)
end
function s.digivice(c)
	return c:IsCode(37501101) or c:IsCode(37501119)
end
function s.digimon(c)
	return c:IsCode(37501100)
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil)
end
function s.contactop(g,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL,nil)
end
function s.splimit(e,se,sp,st)
	return true
end

function s.pctcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
function s.pcttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.pctop(e,tp,eg,ep,ev,re,r,rp)
	local token =Duel.CreateToken(tp,37501103)  
	Duel.MoveToField(token,tp,tp,LOCATION_MZONE,POS_FACEUP,true)
end
function s.targeta(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.opereta(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e)  then
		--lose 1000 atk
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(-1000)
		tc:RegisterEffect(e1)
		--check if tc has x-antibody setcode(0xb19)
		if tc:IsSetCard(0xb19) then return end
		--check if tc level is below or equal to c
		if tc:IsLevelBelow(c:GetLevel()) then 
			Duel.BreakEffect()
			--negate tc effects
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			local e3=e2:Clone()
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			tc:RegisterEffect(e3)
			if tc:IsType(TYPE_TRAPMONSTER) then
				local e4=e2:Clone()
				e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				tc:RegisterEffect(e4)
			end
		end
	end
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
	local adjPos1 = pos + 1 -- Position of the adjacent zone (pos+1)
	local adjPos2 = pos - 1 -- Position of the adjacent zone (pos-1)
	if adjPos1 <= 4 then
			local adjCard1 = Duel.GetFieldCard(1-tp,LOCATION_MZONE,adjPos1) -- Get the card in the adjacent zone (pos+1)
			if adjCard1 then
				if not adjCard1:IsSetCard(0xb19) then
				if adjCard1:IsLevelBelow(c:GetLevel()) then
				--negate effects
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				adjCard1:RegisterEffect(e2)
				local e3=e2:Clone()
				e3:SetCode(EFFECT_DISABLE_EFFECT)
				adjCard1:RegisterEffect(e3)
				if adjCard1:IsType(TYPE_TRAPMONSTER) then
					local e4=e2:Clone()
					e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
					adjCard1:RegisterEffect(e4)
						end
					end
				end
			end
		end
		if adjPos2 >= 0 then
			local adjCard2 = Duel.GetFieldCard(1-tp,LOCATION_MZONE,adjPos2) -- Get the card in the adjacent zone (pos-1)
			if adjCard2 then
				if not adjCard2:IsSetCard(0xb19) then
				if adjCard2:IsLevelBelow(c:GetLevel()) then
				--negate effects
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				adjCard2:RegisterEffect(e2)
				local e3=e2:Clone()
				e3:SetCode(EFFECT_DISABLE_EFFECT)
				adjCard2:RegisterEffect(e3)
				if adjCard2:IsType(TYPE_TRAPMONSTER) then
					local e4=e2:Clone()
					e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
					adjCard2:RegisterEffect(e4)
						end
				   end
			   end
			end
		end
		-- destroy by battle c if still on field
		if d:IsLocation(LOCATION_MZONE) and d:IsRelateToBattle() then
			Duel.Destroy(d, REASON_BATTLE)
		end
end