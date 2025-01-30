-- kentaurosmon
local s,id=GetID()
local contadores
function s.initial_effect(c)
	c:EnableCounterPermit(0xb195)
	c:SetCounterLimit(0xb195,1)
	-- Fusion Summon
	Fusion.AddProcMixN(c, true, true,37501129,1,aux.FilterBoolFunction(Card.IsSetCard,0x3763),2)
	Fusion.AddProcMixN(c, true, true,37501167,1,aux.FilterBoolFunction(Card.IsSetCard,0x3763),2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCountLimit(1,id+10)
	e1:SetRange(LOCATION_ONFIELD)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- Special Summon Digiegg
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.pctcon)
	e2:SetTarget(s.pcttg)
	e2:SetOperation(s.pctop)
	c:RegisterEffect(e2)
	--protection
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e3:SetType(EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCode(EFFECT_CANNOT_TO_GRAVE)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_TO_HAND)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_CANNOT_TO_DECK) 
	c:RegisterEffect(e5)
	local e6=e3:Clone()
	e6:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	c:RegisterEffect(e6)
	local e7=e3:Clone()
	e7:SetCode(EFFECT_IMMUNE_EFFECT)
	c:RegisterEffect(e7)
	local e9 = Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,1))
	e9:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e9:SetCode(EFFECT_DESTROY_REPLACE)
	e9:SetProperty(EFFECT_FLAG_NO_TURN_RESET+EFFECT_FLAG_SINGLE_RANGE)
	e9:SetRange(LOCATION_ONFIELD)
	e9:SetCountLimit(1,id+100)
	e9:SetTarget(s.reptg)
	e9:SetOperation(s.disop)
	c:RegisterEffect(e9)
	--Neither monster can be destroyed by battle
	local e66=Effect.CreateEffect(c)
	e66:SetType(EFFECT_TYPE_FIELD)
	e66:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e66:SetRange(LOCATION_MZONE)
	e66:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e66:SetTarget(s.indestg)
	e66:SetValue(1)
	c:RegisterEffect(e66)
	--banish itself if this card is disabled
	local e0 = Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EVENT_CHAIN_SOLVED)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCondition(s.negado)
	e0:SetOperation(s.banish)
	c:RegisterEffect(e0)
	-- return from banish to field at the end phase
	local e8 = Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,4))
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_IGNORE_RANGE)
	e8:SetCode(EVENT_PHASE+PHASE_END)
	e8:SetRange(LOCATION_REMOVED)
	e8:SetTarget(s.reneguede)
	e8:SetOperation(s.renegado)
	c:RegisterEffect(e8)
	if not s.global_check then
		s.global_check=true
		s[0]=nil
		s[1]=nil
	end
	--summon success
	local e11=Effect.CreateEffect(c)
	e11:SetDescription(aux.Stringid(id,2))
	e11:SetCategory(CATEGORY_COUNTER)
	e11:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e11:SetCode(EVENT_SPSUMMON_SUCCESS)
	e11:SetTarget(s.addct)
	e11:SetOperation(s.addc)
	c:RegisterEffect(e11)
	-- no damage
	local e12 = Effect.CreateEffect(c)
	e12:SetType(EFFECT_TYPE_SINGLE)
	e12:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e12:SetCondition(aux.TRUE)
	e12:SetValue(1)
	c:RegisterEffect(e12)
	local e13 = Effect.CreateEffect(c)
	e13:SetType(EFFECT_TYPE_SINGLE)
	e13:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e13:SetCondition(aux.TRUE)
	e13:SetValue(1)
	c:RegisterEffect(e13)
	--destroy replace
	local e21=Effect.CreateEffect(c)
	e21:SetDescription(aux.Stringid(id,3))
	e21:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e21:SetCode(EFFECT_DESTROY_REPLACE)
	e21:SetRange(LOCATION_MZONE)
	e21:SetCountLimit(1)
	e21:SetTarget(s.destg)
	e21:SetValue(s.value)
	e21:SetOperation(s.desop)
	c:RegisterEffect(e21)
	-- ganha 500atk/def se tiver SHIELD/escudo
	local e22=Effect.CreateEffect(c)
	e22:SetType(EFFECT_TYPE_SINGLE)
	e22:SetCode(EFFECT_UPDATE_ATTACK)
	e22:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e22:SetRange(LOCATION_MZONE)
	e22:SetCondition(s.calcula)
	e22:SetValue(500)
	c:RegisterEffect(e22)
	local e23=e22:Clone()
	e23:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e23)
	c:RegisterFlagEffect(FLAG_DIVINE_HIERARCHY,0,0,0,1)
end
s.counter_list={0xb195}
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
function s.indestg(e,c)
	local handler=e:GetHandler()
	return c==handler or c==handler:GetBattleTarget()
end
function s.negado(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_DISABLED)
end
function s.banish(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsHasEffect(EFFECT_DISABLE) then
		Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
	end
end
function s.reneguede(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
end
function s.renegado(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp = c:GetControler()
	-- return card to field 
	if not Duel.SpecialSummon(c,SUMMON_TYPE_SPECIAL,tp,tp,true,true,POS_FACEUP) then
		Debug.ShowHint("nao foi dessa vez.")
	end
end
function s.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0xb195)
end
function s.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		if contadores then 
			contadores = contadores + 1
		else 
			contadores = 1
		end 
	end
end
function s.dfilter(c)
	return not c:IsReason(REASON_REPLACE) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and (c:IsSetCard(0xdf7) or c:IsSetCard(0xf0f))
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local count=eg:FilterCount(s.dfilter,nil)
		e:SetLabel(count)
		return count>0 and contadores>0
	end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.value(e,c)
	return c:IsFaceup() and c:GetLocation()==LOCATION_MZONE and (c:IsSetCard(0xdf7) or c:IsSetCard(0xf0f))
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local count=e:GetLabel()
	contadores=contadores-count
end
function s.calcula(e,tp,eg,ep,ev,re,r,rp)
	if contadores then
		return contadores > 0
	else
		return false
	end
end