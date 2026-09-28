#!/usr/bin/env bash
# 最小结构冒烟测试：纯文件断言、零依赖。跑法：bash tests/smoke.sh
# 覆盖 3 类机械约束（frontmatter 合法 / 文件引用存在 / 技能引用可解析）。
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

[ "$FAIL" = 0 ] && echo "smoke OK: $(ls skills/*/SKILL.md | wc -l) skills checked" || { echo "smoke FAILED"; exit 1; }
