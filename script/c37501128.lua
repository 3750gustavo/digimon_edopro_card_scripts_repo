--BurningGreymon
local s,id,o=GetID()
function s.initial_effect(c)
	Fusion.AddProcCodeRep(c,37501116,1)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	--fusion Summon this card on your opponent's turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_MAIN_END)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.syncon)
	e1:SetTarget(s.syntg)
	e1:SetOperation(s.synop)
	c:RegisterEffect(e1)
	-- special summon a takuya when destroyed	
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.pctcon)
	e3:SetTarget(s.pcttg)
	e3:SetOperation(s.pctop)
	c:RegisterEffect(e3)
	-- this card atk and def becomes the same +1 as the strongest opponent monster
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SET_ATTACK_FINAL)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_REPEAT+EFFECT_FLAG_DELAY+EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(s.adval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_SET_DEFENSE_FINAL)
	c:RegisterEffect(e5)
	--ATK check
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(id)
	c:RegisterEffect(e7)
	-- gain opponent monsters effect protections while they are on the field 
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_ADJUST)
	e6:SetRange(LOCATION_ONFIELD)
	e6:SetOperation(s.copycards)
	c:RegisterEffect(e6)
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL,nil)
end
function s.splimit(e,se,sp,st)
	return true
end
function s.filtra(c)
	return c:IsCode(37501116)
end
function s.pctcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
  end
function s.pcttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
  end
function s.pctop(e,tp,eg,ep,ev,re,r,rp)
	local token =Duel.CreateToken(tp,37501116)  
	Duel.MoveToField(token,tp,tp,LOCATION_MZONE,POS_FACEUP,true)
  end
function s.syncon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and Duel.IsExistingMatchingCard(s.filtra,tp,LOCATION_MZONE,0,1,nil) and not e:GetHandler():IsStatus(STATUS_CHAINING)
end
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsFusionSummonableCard() end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_EXTRA)
end
function s.synop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local g = Duel.SelectMatchingCard(tp,s.filtra,tp,LOCATION_MZONE,0,1,1,nil)
		Duel.SetFusionMaterial(g)
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		Duel.SpecialSummon(c,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	end
end
function s.filter(c)
	return c:IsFaceup() and not c:IsCode(id)
end
function s.adval(e,c)
	local g=Duel.GetMatchingGroup(s.filter,e:GetHandlerPlayer(),0,LOCATION_MZONE,nil)
	if g==nil or #g==0 then 
		return 3000
	else
		local tg,val=g:GetMaxGroup(Card.GetAttack)
		if tg == nil or val == nil then return 3000 end
		--if biggest atk is less then 3000, return 3000
		if val <= 3000 then
			return 3000
		else --else return biggest atk +1
			return val+1
		end
	end
	return 3000
end
function s.imune(c,e)
	return c:IsImmuneToEffect(e)
end
function s.alvobatalha(c,e)
	return not c:IsCanBeBattleTarget(e:GetHandler())
end
function s.alvoefeito(c,e)
	return not c:IsCanBeEffectTarget(e)
end
function s.alvorelease(c,e)
	return not c:IsReleasable()
end
function s.copycards(e,tp,eg,ep,ev,re,r,rp)
	local carta=e:GetHandler()
	local g=Duel.GetFirstMatchingCard(s.imune,tp,0,LOCATION_ONFIELD,nil,e)
	if g then
		local e1 = Effect.CreateEffect(carta)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_ONFIELD)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE) -- reseta na troca de fase
		carta:RegisterEffect(e1)
		g = nil
	end
	g = Duel.GetFirstMatchingCard(s.alvobatalha,tp,0,LOCATION_ONFIELD,nil,e)
	if g then
		local e1 = Effect.CreateEffect(carta)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_ONFIELD)
		e1:SetValue(aux.imval2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE)
		carta:RegisterEffect(e1)
		g = nil
	end
	g = Duel.GetFirstMatchingCard(s.alvoefeito,tp,0,LOCATION_ONFIELD,nil,e)
	if g then
		local e1 = Effect.CreateEffect(carta)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_ONFIELD)
		e1:SetValue(aux.TRUE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE)
		carta:RegisterEffect(e1)
		g = nil
	end
	g = Duel.GetFirstMatchingCard(s.alvorelease,tp,0,LOCATION_ONFIELD,nil,e)
	if g then
		local e1 = Effect.CreateEffect(carta)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_ONFIELD)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE)
		carta:RegisterEffect(e1)
		local e2 = e1:Clone()
		e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		carta:RegisterEffect(e2)
		g = nil
	end
end