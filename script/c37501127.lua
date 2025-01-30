-- Reppamon
local s,id=GetID()
function s.initial_effect(c)
	-- Fusion Summon
	Fusion.AddProcMix(c,true,true,37501125,37501119)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	--negate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e3:SetCountLimit(1,id)
	e3:SetRange(LOCATION_ONFIELD)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	-- Special Summon Digiegg
	local e4 = Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(s.pctcon)
	e4:SetTarget(s.pcttg)
	e4:SetOperation(s.pctop)
	c:RegisterEffect(e4)
	local e5 = Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetProperty(EFFECT_FLAG_NO_TURN_RESET+EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_ONFIELD)
	e5:SetCountLimit(1,id)
	e5:SetTarget(s.reptg)
	e5:SetOperation(s.disop)
	c:RegisterEffect(e5)
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