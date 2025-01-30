--Shibayama Junpei
local s,id,o=GetID()
function s.initial_effect(c)
	--cannot be destroyed if zoe or any of her fusion for is on field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(s.zoecon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e32=e1:Clone()
	e32:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e32)
end
local zoe_code = 37501203
function s.filterzoe(c)
	if c:IsType(TYPE_FUSION) then
	return c:IsFaceup() and c:ListsCodeAsMaterial(zoe_code)
	else return c:IsFaceup() and c:IsCode(zoe_code) end
end
function s.zoecon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filterzoe,e:GetHandlerPlayer(),LOCATION_MZONE,0,e:GetHandler())
	return #g>0
end
