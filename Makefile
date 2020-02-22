build:
	docker build . -t dropbox
	docker build . -t asdlfkj31h/dropbox:0.4

push:
	docker push asdlfkj31h/dropbox:0.4
