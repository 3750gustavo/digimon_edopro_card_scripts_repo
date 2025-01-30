--Petaldramon
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--also treated as plant
	local e0f=Effect.CreateEffect(c)
	e0f:SetType(EFFECT_TYPE_SINGLE)
	e0f:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0f:SetRange(LOCATION_MZONE)
	e0f:SetCode(EFFECT_ADD_RACE)
	e0f:SetValue(RACE_PLANT)
	c:RegisterEffect(e0f)
	--Special summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	--atkdown
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_SINGLE)
	e11:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e11:SetCode(EFFECT_UPDATE_ATTACK)
	e11:SetRange(LOCATION_MZONE)
	e11:SetValue(s.val)
	c:RegisterEffect(e11)
	--disable field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_DISABLE_FIELD)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
function s.disop(e,tp)
	local c=e:GetHandler()
	local seq=c:GetSequence()
	local g=c:GetColumnZone(LOCATION_MZONE,1,1)
	return g
end
function s.val(e,c)
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)*(-800)
end