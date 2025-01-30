--Mako Toy Gun
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--set original atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
end
function s.value(e,c)
	local original = c:GetBaseAttack()
	local texto = c:GetTextAttack()
	local atk = c:GetAttack()
	local diferenca = texto-original
	if original == texto then
		local atk_final = texto
		return atk_final
	else
	if (diferenca)>0 then
		local atk_final = atk+diferenca
		return atk_final
	else
		local atk_final = atk
		return atk_final
	end
	end	
	return texto
end