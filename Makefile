deploy:
	git add .
	git commit -m "update"
	git remote add origin https://github.com/HeXA-UNIST/hexa-blog.git
	git push -u origin master
	hexo generate
	hexo deploy
