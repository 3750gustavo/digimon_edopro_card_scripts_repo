--Gargomon
local s,id,o=GetID()
function s.initial_effect(c)
	Fusion.AddProcMixN(c, true, true,37501190,1,aux.FilterBoolFunction(Card.IsSetCard,0x3763),1)
	--Move itself to another monster zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(aux.seqmovcon)
	e3:SetTarget(s.movetg)
	e3:SetOperation(s.moveop)
	c:RegisterEffect(e3)
	--Fusion.AddProcMix(c,s.digivice,true,37501183,s.digivice)
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
end
function s.digivice(c)
	return c:IsCode(37501101) or c:IsCode(37501161)
end
function s.digimon(c)
	return c:IsCode(37501107)
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
function s.filtrada(c)
	return true
end
function s.movetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckAdjacent() and Duel.IsExistingTarget(s.filtrada,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local c = e:GetHandler()
	local seq = c:GetSequence()
	local pos = c:GetSequence()
	local qt = 0
	while Duel.SelectYesNo(tp,aux.Stringid(id,2)) do
		Card.MoveAdjacent(e:GetHandler())
		pos = c:GetSequence()
	end
	if pos >= seq then
		qt = pos - seq
	else
		qt = seq - pos
	end
	local cartas_em_campo = Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	if qt > cartas_em_campo then qt=cartas_em_campo end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.filtrada,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,qt,qt,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.moveop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end