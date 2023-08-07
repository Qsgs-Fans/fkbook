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
于是你跑去了shzl，把\ ``shensu``\ 搬到了你的扩展包里。
先取个不一样的名字，暂且叫这个吕蒙是\ ``st__lvmeng``\ ，克己是\ ``st__keji``\ 吧。
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
