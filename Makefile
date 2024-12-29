run:
	hugo server --buildDrafts

deploy:
	hugo
	cd public && zip -r blog.zip * && mv blog.zip ../
	scp blog.zip larsgard@bytecode.no:/var/www/
	rm -rf /var/www/html/blogg
	ssh bytecode.no unzip -o /var/www/blog.zip -d /var/www/html/blogg
