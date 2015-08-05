deploy:
	git add . --all
	git commit -m "update"
	git push -u origin master
	hexo generate
	hexo deploy
