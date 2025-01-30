--Koichi Kimura
local s,id,o=GetID()
function s.initial_effect(c)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
end
function s.efilter(e,te,c)
	return te:IsActiveType(TYPE_MONSTER) and (c:IsRace(RACE_FAI
) or c:IsAttribute(ATTRIBUTE_LIGHT))
end