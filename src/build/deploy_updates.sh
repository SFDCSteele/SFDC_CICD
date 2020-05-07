echo "###deploy_updates.sh--->passed in parameters $1 ---and--- $2"
rm $1
git archive -o $1 HEAD $(git diff --name-only HEAD^)
zip -r $1 $2
