--Tommy Himi
local s,id,o=GetID()
function s.initial_effect(c)
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	--defup
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
end
function s.atkdeffilter(c)
	return c:IsFaceup() and (c:IsSetCard(0xf0f) or c:IsSetCard(0xd74))
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(s.atkdeffilter,c:GetControler(),LOCATION_MZONE,0,c)*200
end