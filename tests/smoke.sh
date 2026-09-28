#!/usr/bin/env bash
# 最小结构冒烟测试：纯文件断言、零依赖。跑法：bash tests/smoke.sh
# 覆盖 4 类机械约束（frontmatter 合法 / 文件引用存在 / 技能引用可解析 / 语言分层）。
# 判断类问题（规则语义、措辞形态）不在其列——那是审查的职责。
set -u
FAIL=0
fail() { echo "FAIL: $1"; FAIL=1; }

for skill in skills/*/SKILL.md; do
  # 1. frontmatter 合法：首行 ---、含 name 与 description、三行内闭合
  head -1 "$skill" | grep -qx -- '---' || fail "$skill: 缺 frontmatter 开栏"
  awk '/^---$/{n++} n==2{exit} n>=1' "$skill" | grep -q '^name:' || fail "$skill: frontmatter 缺 name"
  awk '/^---$/{n++} n==2{exit} n>=1' "$skill" | grep -q '^description:' || fail "$skill: frontmatter 缺 description"
  awk '/^---$/{n++} n==2{exit} n>=1' "$skill" | grep -q '^description:.\+' || fail "$skill: description 为空"
done

# 2. markdown 相对文件引用存在（[x](y.md) 与反引号相对路径 .md 引用）
for f in $(find skills -name '*.md'); do
  dir=$(dirname "$f")
  grep -o ']([A-Za-z0-9_./-]*\.md)' "$f" | sed 's/^](\(.*\))$/\1/' | while read -r ref; do
    [ -e "$dir/$ref" ] || echo "FAIL: $f 引用的 $ref 不存在"; done | grep -q FAIL && FAIL=1
done

# 3. superpowers:技能引用可解析（技能目录存在）
grep -rho 'superpowers:[a-z-]*' skills --include='*.md' | sort -u | while read -r ref; do
  name=${ref#superpowers:}
  [ -d "skills/$name" ] || echo "FAIL: $ref 无对应技能目录"
done | grep -q FAIL && FAIL=1

# 4. 语言分层：对照层（与官方 diff≤60，下次同步可直接套）与测试夹具保持英文，保逐字对照性
#    检测 CJK 首字节：U+4E00-U+9FFF 的 UTF-8 为 0xE4-0xE9 开头三字节（em dash / 全角引号是 E2/E3，不误报）
LANG_EN=(skills/verification-before-completion/SKILL.md
         skills/receiving-code-review/SKILL.md
         skills/systematic-debugging/SKILL.md
         skills/dispatching-parallel-agents/SKILL.md
         skills/using-git-worktrees/SKILL.md
         skills/systematic-debugging/test-*.md)
for f in "${LANG_EN[@]}"; do
  [ -e "$f" ] || { fail "$f: 语言契约清单中的文件不存在"; continue; }
  LC_ALL=C grep -q $'[\xe4-\xe9]' "$f" && fail "$f: 对照层/测试夹具须保持英文，含中文字符"
done

[ "$FAIL" = 0 ] && echo "smoke OK: $(ls skills/*/SKILL.md | wc -l) skills checked" || { echo "smoke FAILED"; exit 1; }
