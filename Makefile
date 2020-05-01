VER=0.5
build:
	docker build . -t dropbox -t asdlfkj31h/dropbox:${VER}

push:
	docker push asdlfkj31h/dropbox:${VER}
