deploy:
	git add .
	git commit -m "update"
	git push -u origin master
	hexo generate
	hexo deploy
