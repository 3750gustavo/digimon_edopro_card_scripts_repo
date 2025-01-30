--Blast Digivolution
local s,id,o=GetID()
function s.initial_effect(c)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Add this card from GY to deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end
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
    if chk==0 then return e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoDeck(c,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,c)
    end
end
function s.filtroevolucao(c)
	return (c:IsSetCard(0xdf7) and c:IsMonster()) and s.filter(c) and Duel.IsExistingMatchingCard(s.extra_check,c:GetControler(),LOCATION_EXTRA,0,1,nil,c)
end
function s.extra_check(c, mc)
	return c:IsSetCard(0xdf7) and c:ListsCodeAsMaterial(mc:GetCode())
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and ev>=3000
end
function s.filter(c)
	return (c:IsMonster() and c:IsSetCard(0xdf7) and c:IsReason(REASON_DESTROY) and c:GetTurnID()==Duel.GetTurnCount() and c:IsLocation(LOCATION_GRAVE))
	 or
	  (c:IsFaceup() and c:IsSetCard(0xdf7) and c:IsMonster() and c:IsLocation(LOCATION_MZONE))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then Debug.ShowHint("chkc") return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and chkc:IsMonster() end
	if chk == 0 then Debug.ShowHint("chk") return Duel.IsExistingTarget(s.filtroevolucao,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g = Duel.SelectTarget(tp,s.filtroevolucao,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
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