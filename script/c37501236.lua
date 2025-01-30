--Ranamon
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
	--battle indestructable
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_SINGLE)
	e11:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e11:SetValue(1)
	c:RegisterEffect(e11)
	--CANNOT_DIRECT_ATTACK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
	--cry when it fails to destroy a opponent monster in battle
	local e12=Effect.CreateEffect(c)
	e12:SetDescription(aux.Stringid(id,0))
	e12:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e12:SetCode(EVENT_DAMAGE_STEP_END)
	e12:SetCountLimit(1)
	e12:SetCondition(s.crycon)
	e12:SetOperation(s.cryop)
	c:RegisterEffect(e12)
end
function s.crycon(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToBattle() then return false end
	local t=nil
	if ev==0 then t=Duel.GetAttackTarget()
	else t=Duel.GetAttacker() end
	e:SetLabelObject(t)
	return t and t:IsRelateToBattle()
end
function s.cryop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimit(aux.FALSE)
	local c=e:GetHandler()
	--set attack final to 3000 until end phase
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SET_ATTACK_FINAL)
	e0:SetValue(3000)
	e0:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e0)
	--set def final to 3000 until end phase
	local e1=e0:Clone()
	e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
	c:RegisterEffect(e1)
	--cannot be destroyed by card effects until end phase
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--attack all enemies until end phase
	local e22=e0:Clone()
	e22:SetCode(EFFECT_ATTACK_ALL)
	e22:SetValue(1)
	c:RegisterEffect(e22)
end