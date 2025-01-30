--Card Slash the Life!!
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetTarget(s.naotg)
	e0:SetOperation(s.nao)
	c:RegisterEffect(e0)
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
	local e22=Effect.CreateEffect(c)
	e22:SetDescription(aux.Stringid(id,0))
	e22:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e22:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e22:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e22:SetRange(LOCATION_SZONE)
	e22:SetCode(EVENT_DESTROYED)
	e22:SetCountLimit(3)
	e22:SetCondition(s.condition)
	e22:SetTarget(s.drtg)
	e22:SetOperation(s.drop)
	c:RegisterEffect(e22)
	--Prevent activations in response to your monsters' effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(s.chainop)
	c:RegisterEffect(e3)
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
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if ep==tp and (rc:IsOriginalSetCard(0x3765)) or (rc:IsOriginalSetCard(0x3764)) then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,rp,tp)
	return tp==rp
end
function s.sixfilter(c,e,tp)
	return c:IsSetCard(0xdf7) and c:GetPreviousControler()==tp and Duel.IsExistingMatchingCard(s.extrafilter,tp,LOCATION_EXTRA,0,1,nil,c:GetAttribute(),e,tp,c:GetLevel())
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.sixfilter,1,nil,tp)
end
function s.extrafilter(c,att,e,tp,level)
	return c:IsAttribute(att)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetLevel()<level
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.thcfilter,1,nil,tp)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local sg=eg:Filter(s.sixfilter,nil,e,tp)
	local tc=sg:GetFirst()
	if tc then
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.extrafilter,tp,LOCATION_EXTRA,0,1,1,nil,tc:GetAttribute(),e,tp,tc:GetLevel())
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	end
end
function s.nao(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimit(aux.FALSE)
end
function s.naotg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetChainLimit(aux.FALSE)
end