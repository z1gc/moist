-- 输入英文后，如果输入完全匹配该单词，则会立刻 commit（上屏）。
-- 或者候选中都是英文的时候，也会直接上屏（这个看个人喜好，我自己不太习惯英文的候选功能）。
-- 例如“rust”就会直接匹配上屏。
-- 可能会产生一定的反作用，建议使用双拼方案，跟英文字母的重合率非常低。
-- 如果真的遇到了跟英文重合的情况，使用“'”符号进行分词即可解决，例如“ru'st”。
-- 只适合短暂的英文输入，例如只需要某个单词的情况，对于长英文还是建议 shift 切换。
-- 对于一些确认没什么问题又常用的单词（通常比较短），可以试着加入到自定义字典里。
-- https://github.com/hchunhui/librime-lua/wiki/Scripting#lua_filter

-- 一些奇奇怪怪的词，可能对规则有影响：
-- what => 网状
-- lua.. => 路政
-- key.. => 可以
-- i'm
-- value.. => 杀戮场
-- that => 唐装
-- the.. => 唐朝（th 开头的双拼似乎都有问题，智能 ABC 方案下）

local function filter(input, env)
  -- Not so familiar with lua... TODO: with_index?
  local i = 0
  local submit = env.engine.context.input
  local count = 0

  -- To avoid use-after-free (when `context:clear()` is called, all of the
  --  candidates are invalided, including those already `yielded`), we save
  --  the candidates here.
  local stash = {}

  for cand in input:iter() do
    if i < 7 and cand.text:match("^[%a\' ]+$") then
      if i == 0 and cand.text:lower() == submit:lower() then
        count = 65535
      else
        count = count + 1
      end

      if count >= 7 then
        -- We're ready!
        goto commit
      end
    end

    -- Follow the lua, we starting from 1 (from 0 is allowed as JS, but the for
    --  loop will be some kind of "weird", the for loop range is inclusive).
    i = i + 1
    stash[i] = cand
  end

  if i == count then
    goto commit
  end

  -- Poping stashes, TODO: performance?
  for i = 1, #stash do
    yield(stash[i])
  end

  -- https://stackoverflow.com/a/75339489
  do return end

  ::commit::
  env.engine.context:clear()
  env.engine:commit_text(submit)
end

return filter
