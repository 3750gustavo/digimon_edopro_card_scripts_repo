--Garudamon
--common digimon function are loaded from here, to avoid copy and paste
Duel.LoadScript("DigimonProc.lua")
local s,id,o=GetID()
function s.initial_effect(c)
	Fusion.AddProcMix(c,s.digivice,true,37501240,s.digivice)
	Fusion.AddProcMix(c,s.digivice,true,37501188,s.digivice)
	Fusion.AddContactProc(c,DigimonProc.contactfil,DigimonProc.contactop,DigimonProc.splimit)
	--digiovo
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(DigimonProc.eggcon)
	e4:SetTarget(DigimonProc.eggtg)
	e4:SetOperation(DigimonProc.eggop)
	c:RegisterEffect(e4)
	--when this card declares an attack, it inflict damage and reduce all opponent monsters atk by this card atk and destroy any reduced to 0
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetCountLimit(1)
	e5:SetOperation(s.reduceop)
	c:RegisterEffect(e5)
end
function s.digivice(c)
	return c:IsCode(37501101) or c:IsCode(37501119)
end
function s.reduceop(e,tp,eg,ep,ev,re,r,rp)
	Debug.ShowHint("Garudamon attack effect triggered!")
	local c = e:GetHandler()
	local atk = c:GetAttack()
	Debug.ShowHint("Garudamon ATK: " .. atk)

	if atk <= 0 then
		Debug.ShowHint("ATK is 0 or negative, returning")
		return
	end -- Segurança caso ATK seja 0 ou negativo

	-- Captura o dano REAL que chegou ao oponente (respeita redução de dano)
	local damage = Duel.Damage(1-tp, atk, REASON_EFFECT)
	Debug.ShowHint("Damage inflicted: " .. damage)
	if damage <= 0 then
		Debug.ShowHint("No damage inflicted, returning")
		return
	end

	local destroygroup = Group.CreateGroup()

	-- Pega monstros do OPONENTE (1-tp) e não do jogador atual
	local g = Duel.GetMatchingGroup(Card.IsFaceup, 1-tp, LOCATION_MZONE, 0, nil)
	Debug.ShowHint("Opponent face-up monsters found: " .. #g)

	for tc in aux.Next(g) do
		Debug.ShowHint("Processing monster: " .. tc:GetCode())
		local e1 = Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-damage) -- Usa o dano real infligido
		tc:RegisterEffect(e1)
		Debug.ShowHint("Reduced ATK by " .. damage .. ", new ATK: " .. tc:GetAttack())

		-- Destroi apenas os que ficarem EXATAMENTE com ATK 0
		if tc:GetAttack() == 0 then
			Debug.ShowHint("Monster ATK reduced to 0, adding to destroy group")
			destroygroup:AddCard(tc)
		end
	end

	if #destroygroup > 0 then
		Debug.ShowHint("Destroying " .. #destroygroup .. " monsters")
		Duel.Destroy(destroygroup, REASON_EFFECT)
	else
		Debug.ShowHint("No monsters to destroy")
	end
end