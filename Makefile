VER=0.7
build:
	docker build . -t dropbox -t asdlfkj31h/dropbox:${VER} -t asdlfkj31h/dropbox:latest

push:
	docker push asdlfkj31h/dropbox:${VER}
	docker push asdlfkj31h/dropbox:latest
