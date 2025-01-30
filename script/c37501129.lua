-- Chirinmon
local s,id=GetID()
function s.initial_effect(c)
	-- Fusion Summon
	Fusion.AddProcMix(c,true,true,37501127,37501119)
	Fusion.AddProcMix(c,true,true,37501157,37501119)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCountLimit(1,id+10)
	e1:SetRange(LOCATION_ONFIELD)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- Special Summon Digiegg
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.pctcon)
	e2:SetTarget(s.pcttg)
	e2:SetOperation(s.pctop)
	c:RegisterEffect(e2)
	--protection
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e3:SetType(EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCode(EFFECT_CANNOT_TO_GRAVE)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_TO_HAND)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_CANNOT_TO_DECK) 
	c:RegisterEffect(e5)
	local e6=e3:Clone()
	e6:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	c:RegisterEffect(e6)
	local e7=e3:Clone()
	e7:SetCode(EFFECT_IMMUNE_EFFECT)
	c:RegisterEffect(e7)
	local e9 = Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,1))
	e9:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e9:SetCode(EFFECT_DESTROY_REPLACE)
	e9:SetProperty(EFFECT_FLAG_NO_TURN_RESET+EFFECT_FLAG_SINGLE_RANGE)
	e9:SetRange(LOCATION_ONFIELD)
	e9:SetCountLimit(1,id+100)
	e9:SetTarget(s.reptg)
	e9:SetOperation(s.disop)
	c:RegisterEffect(e9)
	--Neither monster can be destroyed by battle
	local e66=Effect.CreateEffect(c)
	e66:SetType(EFFECT_TYPE_FIELD)
	e66:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e66:SetRange(LOCATION_MZONE)
	e66:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e66:SetTarget(s.indestg)
	e66:SetValue(1)
	c:RegisterEffect(e66)
	--banish itself if this card is disabled
	local e0 = Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EVENT_CHAIN_SOLVED)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCondition(s.negado)
	e0:SetOperation(s.banish)
	c:RegisterEffect(e0)
	-- return from banish to field at the end phase
	local e8 = Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_IGNORE_RANGE)
	e8:SetCode(EVENT_PHASE+PHASE_END)
	e8:SetRange(LOCATION_REMOVED)
	e8:SetOperation(s.renegado)
	c:RegisterEffect(e8)
	if not s.global_check then
		s.global_check=true
		s[0]=nil
		s[1]=nil
	end
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost, tp, LOCATION_ONFIELD + LOCATION_HAND, 0, nil)
end
function s.contactop(g,tp)
	Duel.ConfirmCards(1 - tp, g)
	Duel.SendtoGrave(g, REASON_COST + REASON_MATERIAL, nil)
end
function s.splimit(e,se,sp,st)
	return true
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	local loc,tg=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TARGET_CARDS)
	if not tg or not tg:IsContains(e:GetHandler()) then return false end
	return Duel.IsChainDisablable(ev) and loc~=LOCATION_DECK
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.NegateEffect(ev)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
function s.pctcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE) ~= 0
end
function s.pcttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then return true end
end
function s.pctop(e,tp,eg,ep,ev,re,r,rp)
	local token = Duel.CreateToken(tp,37501103)
	Duel.MoveToField(token,tp,tp,LOCATION_MZONE,POS_FACEUP,true)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReason(REASON_EFFECT) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	return true
end
function s.indestg(e,c)
	local handler=e:GetHandler()
	return c==handler or c==handler:GetBattleTarget()
end
function s.negado(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_DISABLED)
end
function s.banish(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsHasEffect(EFFECT_DISABLE) then
		Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
	end
end
function s.renegado(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp = c:GetControler()
	-- return card to field 
	if not Duel.SpecialSummon(c,SUMMON_TYPE_SPECIAL,tp,tp,true,true,POS_FACEUP) then
		Debug.ShowHint("nao foi dessa vez.")
	end
end