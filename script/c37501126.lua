-- Believer
local s,id= GetID()
function s.initial_effect(c)
	-- Activate this card by discarding 1 card
	local e0 = Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	e0:SetCost(s.cost)
	c:RegisterEffect(e0)
	-- Special Summon a Fusion Digimon from the Extra Deck
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- Special Summon a Fusion Digimon from the Extra Deck if this card leaves the field
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 4))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_NEGATE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	-- Add this card from the GY to the deck
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id, 2))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_series = {0xdf7}
-- Activation cost: Discard 1 card from the hand
function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, e:GetHandler())
	end
	Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST + REASON_DISCARD)
end
--- Check if there is a fusion Digimon in the Extra Deck that lists a face-up Digimon on the field as material
---@param c any
---@param e any
function s.filter(c)
	return (c:IsFaceup() and c:IsSetCard(0xdf7) and c:IsMonster()) and Duel.IsExistingMatchingCard(aux.FilterBoolFunction(Card.ListsCodeAsMaterial,c:GetCode()),c:GetControler(),LOCATION_EXTRA,0,1,nil)
end
-- Check if there is a fusion Digimon in the Extra Deck that lists a face-up Digimon on the field as material
function s.extra_check(c,mc)
	return c:IsSetCard(0xdf7) and c:ListsCodeAsMaterial(mc:GetCode())
end
-- Check if there is a fusion Digimon in the Extra Deck that lists a face-up Digimon on the field as material
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsMonster() end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- Send a valid Digimon you control to the GY and then special summon a fusion Digimon from the Extra Deck that lists it as a material, ignoring summoning conditions
function s.operation(e, tp, eg, ep, ev, re, r, rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if Duel.SendtoGrave(tc,REASON_EFFECT)==0 then return end
	local g=Duel.GetMatchingGroup(s.extra_check,tp,LOCATION_EXTRA,0,nil,tc)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,1,nil)
	if #sg>0 then
		Duel.BreakEffect()
		Duel.SpecialSummon(sg, 0, tp, tp, true,true, POS_FACEUP)
		sg:GetFirst():CompleteProcedure()
	end
end
-- Effect: Special Summon a fusion Digimon from the Extra Deck when this card leaves the field
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- Effect: Add this card from the GY to the deck
function s.thcon(e, tp, eg, ep, ev, re, r, rp)
	local c = eg:GetFirst()
	return c:IsReason(REASON_BATTLE + REASON_EFFECT) and c:IsSetCard(0xdf7) and c:IsType(TYPE_FUSION)
		and c:GetPreviousControler() == tp and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return e:GetHandler():IsAbleToDeck()
	end
	Duel.SetOperationInfo(0, CATEGORY_TODECK, e:GetHandler(), 1, 0, 0)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoDeck(c, tp, SEQ_DECKSHUFFLE, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, c)
	end
end