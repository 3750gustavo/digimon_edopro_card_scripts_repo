--Rapidmon (Armor)
local s,id,o=GetID()
function s.initial_effect(c)
	Fusion.AddProcMix(c,true,true,37501192,37501193)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	--Cannot be destroyed
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e32=e1:Clone()
	e32:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e32)
	--negates target
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--cannot activate spells/traps when this card attack
	local e33=Effect.CreateEffect(c)
	e33:SetType(EFFECT_TYPE_FIELD)
	e33:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e33:SetCode(EFFECT_CANNOT_ACTIVATE)
	e33:SetRange(LOCATION_MZONE)
	e33:SetTargetRange(0,1)
	e33:SetValue(s.aclimit)
	e33:SetCondition(s.actcon)
	c:RegisterEffect(e33)
	--Move itself to another monster zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(aux.seqmovcon)
	e3:SetTarget(s.movetg)
	e3:SetOperation(s.moveop)
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
	Duel.SetChainLimit(aux.FALSE)
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
	Duel.SetChainLimit(aux.FALSE)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.actcon(e)
	return Duel.GetAttacker()==e:GetHandler()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckAdjacent() end
	Duel.SetChainLimit(aux.FALSE)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimit(aux.FALSE)
	local c = e:GetHandler()
	local seq = c:GetSequence()
	Card.MoveAdjacent(e:GetHandler())
	local pos = c:GetSequence()
	if pos ~= seq then
		Duel.NegateEffect(ev)
		Duel.Destroy(eg,REASON_EFFECT)
	end
end