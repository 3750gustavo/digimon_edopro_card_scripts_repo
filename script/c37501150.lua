--Duskmon
Duel.LoadScript("DigimonProc.lua")
local s,id,o=GetID()
function s.initial_effect(c)
	Fusion.AddProcCodeRep(c,37501149,1)
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
	--immune to light and fairy monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	--summon koichi if destroyed
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
	-- quick effect tribute a LIGHT ATTRIBUTE monster
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetProperty(EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCost(s.custoluz)
	e5:SetOperation(s.luzop)
	c:RegisterEffect(e5)
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
	return c:IsCode(37501149)
end
function s.pctcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
  end
  function s.pcttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
  end
  function s.pctop(e,tp,eg,ep,ev,re,r,rp)
	local token =Duel.CreateToken(tp,37501149)
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
function s.filtroluz(c,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.filtroescuridao(c,tp)
	return c:IsAttribute(ATTRIBUTE_DARK)
end
function s.efilter(e,te)
	local cd = te:GetHandler()
	if te:IsSpellTrapEffect() then
		return false
	else
		return cd:IsRace(RACE_FAIRY) or cd:IsAttribute(ATTRIBUTE_LIGHT)
	end
end
function s.custoluz(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.filtroluz,1,false,nil,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroupCost(tp,s.filtroluz,1,1,false,nil,nil,tp)
	Duel.Release(g,REASON_COST)
end
function s.valordaluz(e,c)
	return (Duel.GetMatchingGroupCount(s.filtroluz,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil)+Duel.GetMatchingGroupCount(s.filtroescuridao,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil))*1000
end
--card c gets the effect of cannot be destroyed by battle and effects
function s.luzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Cannot be destroyed
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- gain 1000atk/def for each LIGHT and DARK monster on the field
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e4:SetValue(s.valordaluz)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
end	