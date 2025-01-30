--Angemon
local s,id,o=GetID()
function s.initial_effect(c)
	Fusion.AddProcMix(c,true,true,37501170,s.digivice)
	Fusion.AddProcMix(c,true,true,37501171,s.digivice)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	--Unaffected by Card Effects
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_IMMUNE_EFFECT)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(s.efilter)
	c:RegisterEffect(e0)
	--atk change
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.temcoisa)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--attackall
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetCondition(s.temcoisa)
	e2:SetValue(999)
	c:RegisterEffect(e2)
	--digiovo
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
function s.digivice(c)
	return c:IsCode(37501101) or c:IsCode(37501161)
end
function s.temcoisa(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	local tp = c:GetControler()
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(200)
		c:RegisterEffect(e1)
	end
end
function s.efilter(e,te)
	local rp = te:GetHandlerPlayer() -- player dando alvo,te seria o evento ou tipo de carta
	local c = e:GetHandler() -- eu
	local tp = c:GetControler()
	local tc = te:GetHandler() -- carta dando alvo em mim
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and te:IsActiveType(TYPE_SPELL)
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