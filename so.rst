.. SPDX-License-Identifier: GFDL-1.3-or-later

写个自己的技能吧！
==================

所以我想写这个……
----------------

相信看了《创建第一个技能》之后，你会觉得：“哇，写技能只要抄现成的就行了，这也太简单了吧？”

话是这么说，但是……如果没技能可以抄呢？
例如有人会认为吕蒙在如今的环境太拉了，想要加强一下吕蒙，于是写出了……

  吕蒙 9999（为第一次接触DIY的人说一下，这个9（或者0）是勾玉的意思，绝不是9999血那么夸张）

  克己：你可以跳过任意阶段，视为使用一张无距离和次数限制的【杀】。

眼尖的人可能会发现了——这不夏侯渊的\ **〖神速〗**\ 加强版嘛，抄便是了！
于是你跑去了shzl，把\ ``shensu``\ 搬到了你的扩展包里；
改之前先取个不一样的名字，暂且叫这个吕蒙是\ ``st__lvmeng``\ ，克己是\ ``st__keji``\ 吧。
最终通过Ctrl+F和或人工或批量的查找替换，我们的克己的代码看上去长这样：

.. hint::

  不要乱改别人的技能！修改前先看好你在不在你写的扩展包的文件里！

  不要乱改别人的技能！修改前先看好你在不在你写的扩展包的文件里！

  不要乱改别人的技能！修改前先看好你在不在你写的扩展包的文件里！

  （重要的事情说三遍）

.. code-block:: lua

  local st__keji = fk.CreateTriggerSkill{
    name = "st__keji",
    anim_type = "offensive",
    events = {fk.EventPhaseChanging},
    can_trigger = function(self, event, target, player, data)
      if target == player and player:hasSkill(self.name) then
        if data.to == Player.Judge then
          return true
        elseif data.to == Player.Play then
          return not player:isNude()
        end
      end
    end,
    on_cost = function(self, event, target, player, data)
      local room = player.room
      local targets = {}
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if not player:isProhibited(p, Fk:cloneCard("slash")) then
          table.insert(targets, p.id)
        end
      end
      if #targets == 0 then return end
      if data.to == Player.Judge then
        local to = room:askForChoosePlayers(player, targets, 1, 1, "#st__keji1-choose", self.name, true)
        if #to > 0 then
          self.cost_data = {to[1]}
          return true
        end
      elseif data.to == Player.Play then
        --FIXME: 这个方法在没有装备牌的时候不会询问！会暴露手牌信息！
        local tos, id = room:askForChooseCardAndPlayers(player, targets, 1, 1, ".|.|.|.|.|equip", "#st__keji2-choose", self.name, true)
        if #tos > 0 then
          self.cost_data = {tos[1], id}
          return true
        end
      end
    end,
    on_use = function(self, event, target, player, data)
      local room = player.room
      if data.to == Player.Judge then
        player:skip(Player.Judge)
        player:skip(Player.Draw)
      elseif data.to == Player.Play then
        player:skip(Player.Play)
        room:throwCard({self.cost_data[2]}, self.name, player, player)
      end
      room:useVirtualCard("slash", nil, player, player.room:getPlayerById(self.cost_data[1]), self.name, true)
      return true
    end,
  }

.. hint::

  在lua中，\ ``-- XXXXXX``\ 是注释，它用于在代码里写文本以起到注解的作用；它不是代码，也不会被解释。
  所以可以通过在代码行前面加\ ``--``\ 来屏蔽掉它右边的代码。

不对啊！我一不问选项，二不弃装备牌，这该怎么办？
那就只能去掉对应的内容了，而这需要你对你要修改的部分有全面的认知……

尝试读懂别人的代码（无注释）
----------------------------

你现在看到的，是一个触发技\ ``TriggerSkill``\ ，可以说，触发技是整个新月杀里最复杂的技能种类了。
不过不用担心，毕竟都说了，这本质上是\ **〖神速〗**\ 加强版，只需要把不需要的判定和流程删掉不就完事了？
那删哪个就要看你怎么理解代码了……

和理想/参考书不同，现实中的代码可不会有人写注释，因此想要读懂他人的代码的话只能靠自己理解和实际测试。
首先让我们来剖析这个触发技的结构：

  - \ ``name``\ ：这个是技能的名字，所有检索技能的手段都是检索这个参数，不要搞错了。

  - \ ``anim_type``\ ：这个是技能播放的动画，具体可用参数可以查询游戏根目录的文档(doc)。

  - \ ``events``\ ：这个是技能触发的时机。

  众所周知，触发技，顾名思义就是需要触发的技能；
  一个时机触发时，它会搜索所有技能中events带有这个时机的技能，然后根据结算顺序逐个触发技能。

  - \ ``can_trigger``\ ：这个控制技能什么时候可以触发。

  - \ ``on_cost``\ ：这个控制技能问你要什么，一般这时候是“询问发动”，返回\ *true*\ 则是可以发动。

  - \ ``on_use``\ ：这个就是技能的主体了。

    .. hint::

      有些时机触发的触发技返回\ *true*\ 会终止对应的时机，具体以相似技能为准。

所有的参数都被大括号\ ``{}``\ 包裹起来，以\ ``,``\ 作为分割，
这样就组成了一个\ **table**\ ，也就是常说的“表”。

像这样被诸如\ ``{}``\ 、\ ``function XXX end``\ 或\ ``if XXX end``\ 包裹起来的区域，
我们一般会将两端内的代码缩进一格，以标明它们是同一层的代码。

.. hint::

  养成对齐缩进的习惯有助大家的身心健康；
  一般情况下，你键入\ ``end``\ 后插件会自动帮你退一格缩进。

接下来我们开始逐个解析我们要改的\ **〖神速〗**\ 的代码吧。

.. code-block:: lua

    can_trigger = function(self, event, target, player, data)
      if target == player and player:hasSkill(self.name) then
        if data.to == Player.Judge then
          return true
        elseif data.to == Player.Play then
          return not player:isNude()
        end
      end
    end,

\ ``can_trigger``\ 部分有两个\ ``if``\ ，从外到内，它们分别探测这些：

- 如果时机目标（\ ``target``\ ，此处为转变阶段的玩家）为玩家（\ ``player``\ ），且玩家有本技能时：

  - 如果目标要转移到判定阶段\ ``Player.Judge``\ ：允许触发。

  - 如果目标要转移到出牌阶段\ ``Player.Play``\ ：玩家有牌的话允许触发。

很简单，而且你已经能猜到要改什么了，但先别急：

.. code-block:: lua

    on_cost = function(self, event, target, player, data)
      local room = player.room
      local targets = {}
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if not player:isProhibited(p, Fk:cloneCard("slash")) then
          table.insert(targets, p.id)
        end
      end
      if #targets == 0 then return end
      if data.to == Player.Judge then
        local to = room:askForChoosePlayers(player, targets, 1, 1, "#st__keji1-choose", self.name, true)
        if #to > 0 then
          self.cost_data = {to[1]}
          return true
        end
      elseif data.to == Player.Play then
        --FIXME: 这个方法在没有装备牌的时候不会询问！会暴露手牌信息！
        local tos, id = room:askForChooseCardAndPlayers(player, targets, 1, 1, ".|.|.|.|.|equip", "#st__keji2-choose", self.name, true)
        if #tos > 0 then
          self.cost_data = {tos[1], id}
          return true
        end
      end
    end,

\ ``on_cost``\ 部分有些复杂……但还是可以分析一下：

- 首先是这一段：

  .. code-block:: lua
    
        for _, p in ipairs(room:getOtherPlayers(player)) do
          if not player:isProhibited(p, Fk:cloneCard("slash")) then
            table.insert(targets, p.id)
          end
        end

  这一段的话……最里面的\ ``table.insert``\ 是往\ **targets**\ 里插入\ **p.id**\ ，这个\ ``p``\ 取自房间内的其他玩家，轮流查询。