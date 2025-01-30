--Mercurymon
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Special summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	--also treated as MACHINE
	local e0f=Effect.CreateEffect(c)
	e0f:SetType(EFFECT_TYPE_SINGLE)
	e0f:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0f:SetRange(LOCATION_MZONE)
	e0f:SetCode(EFFECT_ADD_RACE)
	e0f:SetValue(RACE_MACHINE)
	c:RegisterEffect(e0f)
	--Replace target
	local e22=Effect.CreateEffect(c)
	e22:SetDescription(aux.Stringid(id,0))
	e22:SetType(EFFECT_TYPE_QUICK_F)
	e22:SetCode(EVENT_CHAINING)
	e22:SetRange(LOCATION_MZONE)
	e22:SetCondition(s.tarcon)
	e22:SetTarget(s.tartg)
	e22:SetOperation(s.tarop)
	c:RegisterEffect(e22)
end
function s.tarcon(e,tp,eg,ep,ev,re,r,rp)
	if e==re or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return #g==1 and g:GetFirst()==e:GetHandler()
end
function s.tarfilter(c,ev)
	return Duel.CheckChainTarget(ev,c)
end
function s.tartg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return c~=chkc end
	if chk==0 then return true end
	Duel.SetChainLimit(aux.FALSE)
end
function s.tarop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimit(aux.FALSE)
	local g=Group.CreateGroup()
	g:AddCard(re:GetHandler())
	Duel.ChangeTargetCard(ev,g)
end