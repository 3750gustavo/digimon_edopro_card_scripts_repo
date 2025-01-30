--EVO Evolution
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- Special Summon a Fusion Digimon from the Extra Deck
	local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.semfusao)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- Special Summon a Fusion Digimon from the Extra Deck if this card leaves the field
	local e4 = e1:Clone()
	e4:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e4:SetRange(LOCATION_ALL)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(s.spcon)
	c:RegisterEffect(e4)
	 --Add this card from GY to deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+10)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={0xdf7,0xf0f,0xd74}
function s.cfilter(e,c)
	return (c:IsSetCard(0xdf7) and c:IsType(TYPE_FUSION))
end
function s.cfilterfaceup(c)
	return c:IsSetCard(0xdf7) and c:IsType(TYPE_FUSION) and c:IsFaceup()
end
function s.thcfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsSetCard(0xdf7) and c:IsType(TYPE_FUSION)
		and c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.thcfilter,1,nil,tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoDeck(c,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end
function s.semfusao(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.cfilterfaceup,tp,LOCATION_ONFIELD,0,1,nil) then 
		return false
	end	
	return true
end
function s.filtroevolucao(c)
	return (c:IsSetCard(0xdf7) and c:IsMonster())
end
function s.extra_check(c, mc)
	return c:IsSetCard(0xdf7) and c:ListsCodeAsMaterial(mc:GetCode())
end
function s.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then Debug.ShowHint("chkc") return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsMonster() end
	if chk == 0 then Debug.ShowHint("chk") return Duel.IsExistingTarget(s.filtroevolucao,tp,LOCATION_GRAVE,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g = Duel.SelectTarget(tp,s.filtroevolucao,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc = Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local numEvolutions = 1
	for i = 1, numEvolutions do
		if Duel.SendtoDeck(tc,tp,SEQ_DECKSHUFFLE,REASON_EFFECT) == 0 then return end
		local g = Duel.GetMatchingGroup(s.extra_check,tp,LOCATION_EXTRA,0,nil,tc)
		if #g == 0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg = g:Select(tp,1,1,nil)
		local c = sg:GetFirst()
		if #sg > 0 then
			Duel.BreakEffect()
			Duel.SpecialSummonStep(c,SUMMON_TYPE_FUSION,tp,tp,true,true,POS_FACEUP)
			c:SetStatus(STATUS_SPSUMMON_STEP,false)
		end
		Duel.BreakEffect()
		tc = c
	end
	Duel.SpecialSummonComplete()
end
-- Effect: Special Summon a fusion Digimon from the Extra Deck when this card leaves the field
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c = e:GetHandler()
    return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD)
end