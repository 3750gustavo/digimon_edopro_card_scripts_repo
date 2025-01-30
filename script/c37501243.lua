--Mastemon
--Importando funções comuns de Digimon para evitar duplicação de código
Duel.LoadScript("DigimonProc.lua")
local s,id,o=GetID()
function s.initial_effect(c)
	Fusion.AddProcMix(c,true,true,37501186,37501216)
	Fusion.AddContactProc(c,DigimonProc.contactfil,DigimonProc.contactop,DigimonProc.splimit)
	--Tratando este cartão também como um atributo de luz
	local e11f=Effect.CreateEffect(c)
	e11f:SetType(EFFECT_TYPE_SINGLE)
	e11f:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e11f:SetRange(LOCATION_MZONE)
	e11f:SetCode(EFFECT_ADD_ATTRIBUTE)
	e11f:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e11f)
	--token
	local e11=Effect.CreateEffect(c)
	e11:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e11:SetDescription(aux.Stringid(id,1))
	e11:SetType(EFFECT_TYPE_QUICK_O)
	e11:SetCode(EVENT_FREE_CHAIN)
	e11:SetRange(LOCATION_MZONE)
	e11:SetCountLimit(1)
	e11:SetTarget(s.trazerdemos)
	e11:SetOperation(s.demos)
	c:RegisterEffect(e11)
	--controle da luz e escuridao
	local e12=Effect.CreateEffect(c)
	e12:SetDescription(aux.Stringid(id,2))
	e12:SetType(EFFECT_TYPE_QUICK_O)
	e12:SetCode(EVENT_FREE_CHAIN)
	e12:SetRange(LOCATION_MZONE)
	e12:SetTarget(s.target)
	e12:SetOperation(s.operation)
	c:RegisterEffect(e12)
	--Unaffected by Card Effects on opponent turn
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	--digiovo
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(DigimonProc.eggcon)
	e4:SetTarget(DigimonProc.eggtg)
	e4:SetOperation(DigimonProc.eggop)
	c:RegisterEffect(e4)
	c:RegisterFlagEffect(FLAG_DIVINE_HIERARCHY,0,0,0,1)
end
--Verifica se é o turno do oponente
function s.efilter(e,re)
	local tp = e:GetHandlerPlayer()
	return Duel.GetTurnPlayer()~=tp
end
--Função para criar um token no campo
function s.trazerdemos(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ft,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ft,tp,0)
end
function s.demos(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local fid=e:GetHandler():GetFieldID()
	for i=1,ft do
		local token=Duel.CreateToken(tp,37501214)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		--Inflict 1700 damage when destroyed
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_LEAVE_FIELD)
		e1:SetOperation(s.darkfire)
		token:RegisterEffect(e1,true)
	end
	Duel.SpecialSummonComplete()
end
--Função que inflige 1700 de dano ao oponente quando destruído
function s.darkfire(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- change tp value to the opposite player
	if c:GetPreviousControler()==0 then tp=1 else tp=0 end
	Duel.Damage(tp,1700,REASON_EFFECT)
end
function s.dna(c)
	return c:IsCode(37501214) and c:IsFaceup()
end
--Função para selecionar uma carta que é do atributo Luz ou Escuridão
function s.faxada(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) or c:IsAttribute(ATTRIBUTE_LIGHT)
end
--Função para escolher a carta que será alvo do efeito
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(s.faxada,tp,0,LOCATION_MZONE,1,nil) and Duel.IsExistingMatchingCard(s.dna,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetChainLimit(function(e,ep,tp)
						return e:GetHandler():IsOriginalCode(37501171,37501199)
					  end)
	local g=Duel.GetMatchingGroup(s.faxada,tp,0,LOCATION_MZONE,nil)
	Duel.SetTargetCard(g)
end
--Função para ativar a operação de negação de efeitos sobre a carta alvo
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimit(function(e,ep,tp)
						return e:GetHandler():IsOriginalCode(37501171,37501199)
					  end)
	local custo = Duel.SelectMatchingCard(tp,s.dna,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Destroy(custo,REASON_EFFECT)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		local fid=e:GetHandler():GetFieldID()
		local tc=g:GetFirst()
		local c=e:GetHandler()
		for tc in aux.Next(g) do
			--negates
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e3)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e4=e2:Clone()
			e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			tc:RegisterEffect(e4)
		end
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
	end
	g:KeepAlive()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(g)
		e1:SetCondition(s.rmcon)
		e1:SetOperation(s.rmop)
		Duel.RegisterEffect(e1,tp)
	end	
end
--Função para verificar se uma carta específica está marcada
function s.rmfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
--Função para verificar se a condição para remoção está satisfeita
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.rmfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
--Função para executar a remoção do jogo de uma carta alvo
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.rmfilter,nil,e:GetLabel())
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end