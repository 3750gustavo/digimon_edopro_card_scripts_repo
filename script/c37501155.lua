--Dorumon
local s,id,o=GetID()
function s.initial_effect(c)
	Fusion.AddProcMixN(c,true,true,37501124,1,aux.FilterBoolFunction(Card.IsSetCard,0x3763),1)
	--Fusion.AddProcMix(c,s.digivice,true,s.digimon,s.digivice2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
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
	--Targeted monster loses 500 atk
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(s.targeta)
	e5:SetOperation(s.opereta)
	c:RegisterEffect(e5)
end
function s.digivice(c)
	return c:IsCode(37501101) or c:IsCode(37501119)
end
function s.digimon(c)
	return c:IsCode(37501100)
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
function s.targeta(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.opereta(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e)  then
		--lose 500 atk
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(-500)
		tc:RegisterEffect(e1)
	end
end