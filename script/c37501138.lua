--Digisoul Charge kanzentai
Duel.LoadScript("DigimonProc.lua") --lida com evolucoes de digimon
local s,id,o=GetID()
function s.initial_effect(c)
	-- Special Summon a Fusion Digimon from the Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+100)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	 --Add this card from GY to deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+10)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Can activate from hand during opponent's turn
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e3:SetRange(LOCATION_HAND)
	c:RegisterEffect(e3)
end
s.listed_series={0xdf7}
function s.cfilter(e,c)
	return (c:IsSetCard(0xdf7) and c:IsType(TYPE_FUSION))
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
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end
function s.filtroevolucao(c)
	return (c:IsFaceup() and c:IsSetCard(0xdf7) and c:IsMonster())
end
function s.extra_check(c,mc)
	return c:IsSetCard(0xdf7) and c:ListsCodeAsMaterial(mc:GetCode()) and c:IsLevelBelow(8)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsMonster() end
	if chk==0 then return Duel.IsExistingTarget(DigimonProc.canEvolve,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	Duel.SetChainLimit(aux.FALSE)
	local g=Duel.SelectTarget(tp,DigimonProc.canEvolve,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_EXTRA)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimit(aux.FALSE)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	while true do
		local g=DigimonProc.GetEvolutionMax(tc,tc:GetCode(),8)
		if #g==0 then break end
		if Duel.SendtoGrave(tc,REASON_EFFECT)==0 then break end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		local c=sg:GetFirst()
		if #sg>0 then
			Duel.BreakEffect()
			Duel.SpecialSummonStep(c,SUMMON_TYPE_FUSION,tp,tp,true,true,POS_FACEUP)
			c:SetStatus(STATUS_SPSUMMON_STEP,false)
		end
		Duel.BreakEffect()
		tc=c
	end
	Duel.SpecialSummonComplete()
end