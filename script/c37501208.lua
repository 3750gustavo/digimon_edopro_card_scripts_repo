--BanchoLeomon
local s,id,o=GetID()
function s.initial_effect(c)
	Fusion.AddProcMixN(c,true,true,37501207,1,aux.FilterBoolFunction(Card.IsSetCard,0x3763),3)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	--destroy
	local e11=Effect.CreateEffect(c)
	e11:SetDescription(aux.Stringid(id,1))
	e11:SetCategory(CATEGORY_DESTROY)
	e11:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e11:SetCode(EVENT_BATTLE_CONFIRM)
	e11:SetRange(LOCATION_MZONE)
	e11:SetCondition(s.casco)
	e11:SetOperation(s.needle)
	c:RegisterEffect(e11)
	--Cannot be destroyed
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(s.sortecon)
	e1:SetValue(s.sortevalue)
	c:RegisterEffect(e1)
	local e32=e1:Clone()
	e32:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e32)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetValue(2)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(s.pctcon)
	e4:SetTarget(s.pcttg)
	e4:SetOperation(s.pctop)
	c:RegisterEffect(e4)
end
function s.filterfriends(c)
	return c:IsFaceup() and c:IsSetCard(0xdf7) and c:IsType(TYPE_FUSION)
end
function s.sortecon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filterfriends,e:GetHandlerPlayer(),LOCATION_MZONE,0,e:GetHandler())
	return #g>0
end
function s.sortevalue(e,tp,eg,ep,ev,re,r,rp)
	local iterations = 3 -- Número de iterações do loop para gerar aleatórios antes de retornar o resultado final

	for i = 1, iterations do
		math.random() -- Descartar os primeiros valores gerados
	end

	return math.random() <= 0.89
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil)
end
function s.contactop(g,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL,nil)
end
function s.splimit(e,se,sp,st)
	return true
end
function s.pctcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
  end
  function s.pcttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
  end
  function s.pctop(e,tp,eg,ep,ev,re,r,rp)
	local token =Duel.CreateToken(tp,37501103)
	Duel.MoveToField(token,tp,tp,LOCATION_MZONE,POS_FACEUP,true)
  end
function s.casco(e,tp,eg,ep,ev,re,r,rp)
	 local c = e:GetHandler()
	 local clevel = c:GetLevel()
	 local atacante = Duel.GetAttacker()
	 local atacado = Duel.GetAttackTarget()
	 -- Effect only works during monster-vs-monster battles, not direct attacks
	 if not atacado or not atacante then return false end
	 if c==atacante and clevel>atacado:GetLevel() then return true end
	 if c==atacado and clevel>atacante:GetLevel() then return true end
	 return false
end
function s.needle(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	local atacante = Duel.GetAttacker()
	local atacado = Duel.GetAttackTarget()
	-- Effect only works during monster-vs-monster battles, not direct attacks
	if not atacado or not atacante then return end
	if c == atacante then
		Duel.Destroy(atacado,REASON_EFFECT)
		local dano = c:GetAttack() - atacado:GetAttack()
		if dano > 0 then
			Duel.Damage(1-tp,dano*2,REASON_EFFECT)
		else
			local dano = atacado:GetAttack() - c:GetAttack()
			Duel.Damage(1-tp,dano*2,REASON_EFFECT)
		end
	end
	if c == atacado then
		Duel.Destroy(atacante,REASON_EFFECT)
		local dano = c:GetAttack() - atacante:GetAttack()
		if dano > 0 then
			Duel.Damage(1-tp,dano*2,REASON_EFFECT)
		else
			local dano = atacante:GetAttack() - c:GetAttack()
			Duel.Damage(1-tp,dano*2,REASON_EFFECT)
		end
	end
end
