-- Beelzemon
local s, id = GetID()
local contador
if contador == nil then 
	contador = 0
end
function s.initial_effect(c)
	-- Fusion Summon
	Fusion.AddProcMixN(c, true, true,37501131,1,aux.FilterBoolFunction(Card.IsSetCard,0x3763),3)
	Fusion.AddContactProc(c, s.contactfil, s.contactop, s.splimit)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.corrente)
	c:RegisterEffect(e2)
	--copy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCondition(s.copycon)
	e3:SetTarget(s.copytg)
	e3:SetOperation(s.copy)
	c:RegisterEffect(e3)
	-- Special Summon Digiegg
	local e4 = Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id, 0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(s.pctcon)
	e4:SetTarget(s.pcttg)
	e4:SetOperation(s.pctop)
	c:RegisterEffect(e4)
	-- se tiver 4 contadores ou mais, posso gastar 3 contadores para dar alvo e destruir uma spell ou trap virada pra cima em campo
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id, 1))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(s.targeta)
	e5:SetOperation(s.fogo)
	c:RegisterEffect(e5)
	-- +400atk/def for each counter
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetValue(s.calcula)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e7)
end

function s.copycon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsMonster()
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	Duel.SetTargetCard(bc)
end
function s.copy(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local code=tc:GetCode()
		local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD,1)
		c:RegisterFlagEffect(code,RESET_EVENT+RESETS_STANDARD,0,0)
		local e0=Effect.CreateEffect(c)
		e0:SetCode(id)
		e0:SetLabel(code)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e0,true)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ADJUST)
		e1:SetRange(LOCATION_MZONE)
		e1:SetLabel(cid)
		e1:SetLabelObject(e0)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetOperation(s.resetop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
	end
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
	return bit.band(r,REASON_EFFECT+REASON_BATTLE) ~= 0
end

function s.pcttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then return true end
end

function s.pctop(e,tp,eg,ep,ev,re,r,rp)
	local token = Duel.CreateToken(tp,37501103)
	Duel.MoveToField(token,tp,tp,LOCATION_MZONE,POS_FACEUP,true)
end
function s.corrente(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	local tp = c:GetControler()
	local code = c:GetCode()
	local numero_digimons_no_campo_exceto_eu = Duel.GetMatchingGroupCount(aux.FilterBoolFunction(Card.IsSetCard,0xdf7),tp,LOCATION_MZONE,0,code)
	if contador <= 10-numero_digimons_no_campo_exceto_eu then
		contador = contador + 1
	end
end

-- target/check if there is a face-up spell/trap to destroy
function s.targeta(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c = e:GetHandler()
	local tiros = 0
	if chk==0 then return contador>=3 and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	if contador >= 6 and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_SZONE,LOCATION_SZONE,2,nil) then 
		if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then -- quer destruir duas spell/trap?
			contador = 0
			tiros = 2
		else
			contador = contador - 3
			tiros = 1
		end
	elseif contador >= 3 and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) then 
		contador = contador - 3
		tiros = 1
	end
	local tc = Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_SZONE+LOCATION_FZONE,LOCATION_SZONE+LOCATION_FZONE,tiros,tiros,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,tiros,0,0)
end
function s.fogo(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

function s.calcula(e,c)
	return 400*contador
end