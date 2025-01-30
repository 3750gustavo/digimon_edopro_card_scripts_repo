--Aldamon
Duel.LoadScript("DigimonProc.lua")
local s,id,o=GetID()
function s.initial_effect(c)
	Fusion.AddProcMix(c,true,true,37501128,37501117)
	Fusion.AddContactProc(c,DigimonProc.contactforlegends,DigimonProc.contactopforlegends,DigimonProc.splimit)
	--also treated as Fiend
    local e0f=Effect.CreateEffect(c)
    e0f:SetType(EFFECT_TYPE_SINGLE)
    e0f:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0f:SetRange(LOCATION_MZONE)
    e0f:SetCode(EFFECT_ADD_RACE)
    e0f:SetValue(RACE_FIEND)
    c:RegisterEffect(e0f)
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
	--remove code from all continuos spell and field spells your opponent controls has their effects changed
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e11:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e11:SetCode(EVENT_ADJUST)
	e11:SetRange(LOCATION_MZONE)
	e11:SetTargetRange(0,LOCATION_ONFIELD)
	e11:SetOperation(s.valor)
	c:RegisterEffect(e11)
	--summon takuya if destroyed
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(DigimonProc.eggcon)
	e4:SetTarget(DigimonProc.eggtg)
	e4:SetOperation(s.pctop)
	c:RegisterEffect(e4)
	--this card atk and def becomes the same +1 as the strongest opponent monster
	local e44=Effect.CreateEffect(c)
	e44:SetType(EFFECT_TYPE_SINGLE)
	e44:SetCode(EFFECT_UPDATE_ATTACK)
	e44:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_REPEAT+EFFECT_FLAG_DELAY+EFFECT_FLAG_IGNORE_IMMUNE)
	e44:SetRange(LOCATION_MZONE)
	e44:SetValue(s.adval)
	c:RegisterEffect(e44)
	local e5=e44:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
	--gain opponent monsters effect protections while they are on the field 
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_ADJUST)
	e6:SetRange(LOCATION_ONFIELD)
	e6:SetOperation(s.copycards)
	c:RegisterEffect(e6)
	--ATK check
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(id)
	c:RegisterEffect(e7)
end
function s.filtrohibrido(c)
	return c:IsCode(37501117) --hybrid form
end
function s.filtrobesta(c)
	return c:IsCode(37501128) --beast form
end
--summon human form when destroyed
function s.pctop(e,tp,eg,ep,ev,re,r,rp)
	local token =Duel.CreateToken(tp,37501116) --human form
	Duel.MoveToField(token,tp,tp,LOCATION_MZONE,POS_FACEUP,true)
end
--check for hybrid+beast form onfield+removed
function s.syncon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and Duel.IsExistingMatchingCard(s.filtrohibrido,tp,LOCATION_MZONE+LOCATION_REMOVED,0,1,nil) and Duel.IsExistingMatchingCard(s.filtrobesta,tp,LOCATION_MZONE+LOCATION_REMOVED,0,1,nil) and not e:GetHandler():IsStatus(STATUS_CHAINING)
end
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsFusionSummonableCard() end
	Duel.SetOperationInfo(0,CATEGORY_,e:GetHandler(),1,tp,LOCATION_EXTRA)
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
function s.filterval(c)
	return c:IsFaceup() and not c:IsCode(id)
end
function s.adval(e,c)
	local g=Duel.GetMatchingGroup(s.filterval,e:GetHandlerPlayer(),0,LOCATION_MZONE,nil)
	if g==nil or #g==0 then 
		return 0
	else
		local tg,val=g:GetMaxGroup(Card.GetAttack)
		if tg == nil or val == nil then return 0 end
		--if biggest atk is less then 4000, return 0
		if val <= 4000 then
			return 0
		else --else return biggest atk +1
			return (val+1)-4000
		end
	end
	return 0
end
function s.filtercontinuosfield(c)
	return (c:IsContinuousSpell() or c:IsFieldSpell()) and c:IsFaceup()
end
function s.valor(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filtercontinuosfield,tp,0,LOCATION_SZONE+LOCATION_FZONE,nil)
	if #g>0 then
		local tc=g:GetFirst()
		while tc do
			tc:ReplaceEffect(37501258,RESET_EVENT+RESETS_STANDARD)
			tc=g:GetNext()
		end
	end	
end

function s.filter(c,e,t)
	if t==1 then return c:IsImmuneToEffect(e) end
	if t==2 then return not c:IsCanBeBattleTarget(e:GetHandler()) end
	if t==3 then return not c:IsCanBeEffectTarget(e) end
	if t==4 then return not c:IsReleasable() end
	return false
end
function s.copycards(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	for i=1,4 do
	local g=Duel.GetFirstMatchingCard(s.filter,tp,0,LOCATION_ONFIELD,nil,e,i)
	if g then local e1=Effect.CreateEffect(c) e1:SetType(EFFECT_TYPE_SINGLE) e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE) e1:SetRange(LOCATION_ONFIELD) if i==1 then e1:SetCode(EFFECT_IMMUNE_EFFECT) e1:SetValue(1) elseif i==2 then e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET) e1:SetValue(aux.imval2) elseif i==3 then e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET) e1:SetValue(aux.TRUE) elseif i==4 then e1:SetCode(EFFECT_UNRELEASABLE_SUM) e1:SetValue(1) local e2=e1:Clone() e2:SetCode(EFFECT_UNRELEASABLE_NONSUM) c:RegisterEffect(e2) end e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE) c:RegisterEffect(e1) g=nil
end end end