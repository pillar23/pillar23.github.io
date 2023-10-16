# 获取当前日期
current_date=$(date +%Y-%m-%d)
# $current_date = Get-Date -Format "yyyy-MM-dd"

# 提交消息
commit_message="Update for $current_date"

# 提交到Git
git add . && git commit -m "$commit_message" && git push