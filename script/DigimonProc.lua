if not DigimonProc then
    DigimonProc = {}

    -- Verifica se um Card tem um código específico como material.
    -- @param c Card: O Card a ser verificado.
    -- @param... int code id: Os códigos a serem verificados como materiais do Card.
    -- @return boolean: Verdadeiro se o Card tem pelo menos um dos códigos especificados como material, falso caso contrário.
    function ListsMaterialAsCode(c, ...)
        if not c.material then return false end
        local codes = {...}
        for _, mcode in ipairs(c.material) do
        for _, code in ipairs(codes) do
            if code == mcode then return true end
        end
        end
        return false
    end
    -- Devolve um Digimon.
    -- @param c Card: O Digimon a ser devolvido.
    -- @param tp int: O jogador que controla o Digimon.
    -- @return boolean: Verdadeiro se a devolução foi bem-sucedida, falso caso contrário.
    function DigimonProc.devolve(c,tp)
        local g = DigimonProc.GetDevolve(c,c:GetCode())
        if #g == 0 then return false end
        if Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) == 0 then return false end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg = g:Select(tp,1,1,nil)
        local tc = sg:GetFirst()
        if #sg > 0 then 
            Duel.BreakEffect()
            Duel.SpecialSummonStep(tc,SUMMON_TYPE_FUSION,tp,tp,true,true,POS_FACEUP)
            tc:SetStatus(STATUS_SPSUMMON_STEP,false)
        else
            return false
        end
        Duel.BreakEffect()
        return true
    end
    -- Devolve um Digimon.
    -- @param c Card: O Digimon a ser devolvido.
    -- @param tp int: O jogador que controla o Digimon.
    -- @return tc: O Digimon devolvido.
    function DigimonProc.devolvetc(c,tp)
        local g = DigimonProc.GetDevolve(c,c:GetCode())
        if #g == 0 then return false end
        if Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) == 0 then return false end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg = g:Select(tp,1,1,nil)
        local tc = sg:GetFirst()
        if #sg > 0 then 
            Duel.BreakEffect()
            Duel.SpecialSummonStep(tc,SUMMON_TYPE_FUSION,tp,tp,true,true,POS_FACEUP)
            tc:SetStatus(STATUS_SPSUMMON_STEP,false)
        else
            return tc
        end
        Duel.BreakEffect()
        return tc
    end
    -- Evolui um Digimon.
    -- @param c Card: O Digimon a ser evoluído.
    -- @param tp int: O jogador que controla o Digimon.
    -- @return boolean: Verdadeiro se a evolução foi bem-sucedida, falso caso contrário.
    function DigimonProc.evolve(c,tp)
        local g = Duel.GetMatchingGroup(DigimonProc.canEvolveTo,tp,LOCATION_EXTRA,0,nil,c)
        if #g == 0 then return false end
        if Duel.SendtoGrave(c,REASON_EFFECT) == 0 then return false end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg = g:Select(tp,1,1,nil)
        local tc = sg:GetFirst()
        if #sg > 0 then 
            Duel.BreakEffect()
            Duel.SpecialSummonStep(tc,SUMMON_TYPE_FUSION,tp,tp,true,true,POS_FACEUP)
            tc:SetStatus(STATUS_SPSUMMON_STEP,false)
        else
            return false
        end
        Duel.BreakEffect()
        return true
    end

    -- Verifica se um Digimon pode evoluir.
    -- @param c Card: O Digimon a ser verificado.
    -- @return boolean: Verdadeiro se o Digimon pode evoluir, falso caso contrário.
    function DigimonProc.canEvolve(c)
        if c==nil then return nil end
        return c:IsFaceup() and c:IsSetCard(0xdf7) and c:IsMonster() and DigimonProc.HasEvolution(c,c:GetCode())
    end

    -- Verifica se um Digimon tem evolução.
    -- @param c Card: O Digimon a ser verificado.
    -- @return boolean: Verdadeiro se o Digimon tem evolução, falso caso contrário.
    function DigimonProc.HasEvolution(c,code)
        if c==nil then return false end
        return Duel.GetMatchingGroupCount(Card.ListsCodeAsMaterial,c:GetControler(),LOCATION_EXTRA,0,nil,code)>0
    end

    -- Verifica se um Digimon tem devolução.
    -- @param c Card: O Digimon a ser verificado.
    -- @return boolean: Verdadeiro se o Digimon tem devolução, falso caso contrário.
    function DigimonProc.HasDevolve(tc,code)
        Debug.ShowHint("checando grupo")
        local g = Duel.GetMatchingGroup(DigimonProc.extra_check,tc:GetControler(),LOCATION_EXTRA,0,nil,tc)
        return #g>0
    end

    function DigimonProc.extra_check(c,mc)
        return c:IsSetCard(0xdf7) and mc:ListsCodeAsMaterial(c:GetCode())
    end

    -- Verifica se um Digimon pode evoluir para outro Digimon específico.
    -- @param c Card: O Digimon de origem.
    -- @param mc Card: O Digimon de destino.
    -- @return boolean: Verdadeiro se o Digimon de origem pode evoluir para o Digimon de destino, falso caso contrário.
    function DigimonProc.canEvolveTo(c,mc)
        return mc:ListsCodeAsMaterial(c:GetOriginalCode()) --checa se mc lista c como material
    end

    -- Retorna um grupo com as próximas evoluções possíveis de um Digimon.
    -- @param c Card: O Digimon cujas evoluções serão retornadas.
    -- @return Group: Um grupo de Cards representando as próximas evoluções possíveis.
    function DigimonProc.GetEvolution(c,code)
        if c==nil then return nil end
        if DigimonProc.HasEvolution(c,code) then
            local g = Duel.GetMatchingGroup(Card.ListsCodeAsMaterial,c:GetControler(),LOCATION_EXTRA,0,nil,code)
            return g
        else
            return nil
        end
    end

    -- Retorna um grupo com as próximas evoluções possíveis de um Digimon, limitadas por um nível máximo.
    -- @param c Card: O Digimon cujas evoluções serão retornadas.
    -- @param nivelmax int: O nível máximo das evoluções retornadas.
    -- @return Group: Um grupo de Cards representando as próximas evoluções possíveis.
    function DigimonProc.GetEvolutionMax(c,code,nivelmax)
        if c==nil then return nil end
        if DigimonProc.HasEvolution(c,code) then
            local g = Duel.GetMatchingGroup(Card.ListsCodeAsMaterial,c:GetControler(),LOCATION_EXTRA,0,nil,code)
            g = g:Filter(aux.FilterBoolFunction(Card.IsLevelBelow,nivelmax),nil)
            return g
        else
            return nil
        end
    end

    -- Retorna um grupo com as devoluções possíveis de um Digimon.
    -- @param c Card: O Digimon cujas devoluções serão retornadas.
    -- @return Group: Um grupo de Cards representando as devoluções possíveis.
    function DigimonProc.GetDevolve(tc,code)
        if tc==nil then return nil end
        if DigimonProc.HasDevolve(tc,code) then
            local g = Duel.GetMatchingGroup(DigimonProc.extra_check,tc:GetControler(),LOCATION_EXTRA,0,nil,tc)
            return g
        else
            return nil
        end
    end

    -- Retorna o objeto card da fusão/evolução de nível solicitado de um Digimon.
    -- @param c Card: O Digimon de origem.
    -- @param nivel int: O nível solicitado da evolução.
    -- @return Card or nil: O objeto card da evolução de nível solicitado, ou nil se não for encontrado.
    function DigimonProc.GetEvolutionCard(c,nivel,code)
        if c:GetLevel() == nivel then
            return c
        else
            while true do
                if c:GetLevel() < nivel then --deseja evoluir
                    local g = DigimonProc.GetEvolution(c,code)
                    if g then
                        local tc = g:Select(c:GetControler(),1,1,false,c):GetFirst()
                        if tc then
                            if tc:GetLevel() == nivel then --achamos o nivel desejado
                                return tc
                            else -- nao achamos o nivel desejado
                                c = tc --escolha um ramo de evolucao
                                code = tc:GetOriginalCode()
                            end
                        end
                    else
                        break    
                    end
                else -- deseja devoluir
                    local g = DigimonProc.GetDevolve(c,code)
                    if g then
                        local tc = g:Select(c:GetControler(),1,1,false,c):GetFirst()
                        if tc then
                            if tc:GetLevel() == nivel then --achamos o nivel desejado
                                return tc
                            else -- nao achamos o nivel desejado
                                c = tc --escolha um ramo de evolucao
                                code = tc:GetOriginalCode()
                            end
                        end
                    else
                        break
                    end
                end
            end
        end
        return nil -- não encontrou a carta com o nível solicitado.
    end
    --versao recursiva
    function DigimonProc.GetEvolutionCardRE(c,nivel,code)
        if c:GetLevel()==nivel then
            return c
        elseif c:GetLevel()<nivel then -- deseja evoluir
            local g=DigimonProc.GetEvolution(c,code)
            if g then
                local tc=g:Select(c:GetControler(),1,1,false,c):GetFirst()
                if tc then
                    return DigimonProc.GetEvolutionCardRE(tc,nivel,tc:GetOriginalCode())
                end
            end
        else -- deseja devolver
            local g=DigimonProc.GetDevolve(c,code)
            if g then
                local tc=g:Select(c:GetControler(),1,1,false,c):GetFirst()
                if tc then
                    return DigimonProc.GetEvolutionCardRE(tc,nivel,tc:GetOriginalCode())
                end
            end
        end
        return nil -- não encontrou a carta com o nível solicitado.
    end

    -- Retorna o código ID da fusão/evolução de nível solicitado de um Digimon.
    -- @param c Card: O Digimon de origem.
    -- @param nivel int: O nível solicitado da evolução.
    -- @return int or nil: O código ID da evolução de nível solicitado, ou nil se não for encontrado.
    function DigimonProc.GetEvolutionID(c, nivel,code)
        if c:GetLevel() == nivel then
            return code
        else
            while true do
                if c:GetLevel() < nivel then --deseja evoluir
                    local g = DigimonProc.GetEvolution(c,code)
                    if g then
                        local tc = g:Select(c:GetControler(),1,1,false,c):GetFirst()
                        if tc then
                            if tc:GetLevel() == nivel then --achamos o nivel desejado
                                return tc:GetOriginalCode()
                            else -- nao achamos o nivel desejado
                                c = tc --escolha um ramo de evolucao
                                code = tc:GetOriginalCode()
                            end
                        end
                    else
                        break    
                    end
                else -- deseja devoluir
                    local g = DigimonProc.GetDevolve(c,code)
                    if g then
                        local tc = g:Select(c:GetControler(),1,1,false,c):GetFirst()
                        if tc then
                            if tc:GetLevel() == nivel then --achamos o nivel desejado
                                return tc:GetOriginalCode()
                            else -- nao achamos o nivel desejado
                                c = tc --escolha um ramo de evolucao
                                code = tc:GetOriginalCode()
                            end
                        end
                    else
                        break
                    end
                end
            end
        end
    end

    -- Retorna um grupo de Digimons de um determinado nível a partir de um material inicial.
    -- @param c Card: O material inicial.
    -- @param nivel int: O nível dos Digimons retornados.
    -- @return Group: Um grupo de Cards representando os Digimons de nível especificado.
    function DigimonProc.GetDigimonStageGroup(c,nivel,code)
        local grupo = Group.CreateGroup()
        local fim = true
        if c:GetLevel()==nivel then
            return grupo
        else
            while fim do
                if c:GetLevel() < nivel then --deseja evoluir
                    local g = DigimonProc.GetEvolution(c,code)
                    if g then
                        local tc = g:Select(c:GetControler(),1,1,false,c):GetFirst()
                        if tc then
                            if tc:GetLevel()==nivel then
                                -- add g card to grupo then returns grupo
                                grupo:Merge(g)
                                return grupo
                            else
                                c = tc
                                code = tc:GetOriginalCode()
                            end
                        end
                    else
                        fim = false
                        return grupo
                    end
                else 
                    local g = DigimonProc.GetDevolve(c,code)
                    if g then 
                        local tc = g:Select(c:GetControler(),1,1,false,c):GetFirst()
                        if tc then 
                            if tc:GetLevel()==nivel then 
                                return g 
                            else 
                                c = tc 
                                code = tc:GetOriginalCode() 
                            end 
                        end 
                    else 
                        fim = false 
                        return grupo 
                    end 
                end 
            end 
        end 
    end

    --funcoes auxiliares para brotar digiovo
    function DigimonProc.eggcon(e,tp,eg,ep,ev,re,r,rp)
        return bit.band(r,REASON_EFFECT+REASON_BATTLE) ~= 0
    end
    function DigimonProc.eggtg(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk == 0 then return true end
    end
    function DigimonProc.eggop(e,tp,eg,ep,ev,re,r,rp)
        local token = Duel.CreateToken(tp,37501103)
        Duel.MoveToField(token,tp,tp,LOCATION_MZONE,POS_FACEUP,true)
    end
    --fusao contato
    function DigimonProc.contactfil(tp)
        return Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil)
    end
    function DigimonProc.contactonfield(tp)
        return Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,0,nil)
    end
    function DigimonProc.contactforlegends(tp)
        return Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD+LOCATION_REMOVED,0,nil)
    end
    function DigimonProc.contactopforlegends(g,tp)
        Duel.ConfirmCards(1-tp,g)
        Duel.SendtoDeck(g,tp,SEQ_DECKSHUFFLE,REASON_COST+REASON_MATERIAL)
    end
    function DigimonProc.contactop(g,tp)
        Duel.ConfirmCards(1-tp,g)
        Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL,nil)
    end
    function DigimonProc.splimit(e,se,sp,st)
        return true
    end
end    