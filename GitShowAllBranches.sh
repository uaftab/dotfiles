
for b in "`git branch`"; do echo "$b"; done | tr -d "*" | xargs gitk
