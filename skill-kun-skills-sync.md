# Kun Skills 多机同步 Skill

> 本文档用于把 Kun / `.agents` skills 在多台机器之间通过 Git 同步。真实密码、Token、机器私有配置不得进入仓库。

## 当前来源机器状态

12700K 本机已完成初始化：

```text
C:\Users\gaoxi\.agents\skills\    ← git repo，已 init + commit
├── huawei-switch-ssh\SKILL.md    ← 新 skill（密码已脱敏）
├── shenlan-ops\...               ← 运维 skills
└── ...                           ← 60+ skills
```

## 推送到 GitHub

首次推送前，在 GitHub 创建一个私有仓库，例如：

```text
https://github.com/<your-username>/kun-skills.git
```

然后在 12700K 执行：

```powershell
cd C:\Users\gaoxi\.agents\skills
git remote add origin https://github.com/<your-username>/kun-skills.git
git push -u origin main
```

如果仓库已经配置过 `origin`，先检查：

```powershell
git remote -v
git status
```

## 其他机器首次拉取

如果目标机器已有 skills 目录，先备份：

```powershell
Rename-Item C:\Users\<user>\.agents\skills C:\Users\<user>\.agents\skills.bak
```

再克隆：

```powershell
git clone https://github.com/<your-username>/kun-skills.git C:\Users\<user>\.agents\skills
```

macOS / Linux 可使用：

```bash
mv ~/.agents/skills ~/.agents/skills.bak
git clone https://github.com/<your-username>/kun-skills.git ~/.agents/skills
```

## 每次工作前

```powershell
cd C:\Users\<user>\.agents\skills
git pull --rebase
git status
```

必须确认工作区干净后再修改 skill，避免多机并行修改导致冲突。

## 修改后提交

```powershell
git add -A
git commit -m "一句话说清楚改了啥"
git push
```

macOS / Linux 同理：

```bash
git add -A
git commit -m "一句话说清楚改了啥"
git push
```

## 关键约束

1. 密码必须使用占位符，真实密码不放进 skill。通过交接文档、密码管理器或本机环境变量注入。
2. 每次改前先 `git pull --rebase`，两台机器同时改同一文件时可能产生冲突。
3. 发生冲突时不要自动解决，停止并让人裁决。
4. `huawei-switch-ssh` skill 会在下次 Kun 启动后自动出现在 skill 列表里，也可在对话中提到“华为交换机 SSH”触发。
5. 建议 GitHub 仓库设为 private；若设为 public，必须先做一次完整脱敏审计。

## 脱敏检查

提交或推送前至少执行：

```powershell
git diff --cached
git status
```

重点检查：

- 交换机、路由器、服务器真实密码
- API Token、Cookie、Session、私钥
- `.env*`、日志、备份、导出的配置文件
- 内网敏感拓扑中不该公开的访问凭据

如发现敏感信息已经提交，立即停止 push，先改写提交历史或新建干净仓库。

---

*最后更新：2026-06-18*
